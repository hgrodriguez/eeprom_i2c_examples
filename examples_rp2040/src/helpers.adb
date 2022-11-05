-----------------------------------------------------------------------------
--  Implementation of
--  Helpers package for different functions / procedures to minimize
--  code duplication
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL.I2C;

with RP.Device;
with RP.Clock;
with RP.I2C_Master;

with Configuration;

with Delay_Provider;

with Random_UInt_8;

with EEPROM_I2C.MC24XX01;
with EEPROM_I2C.MC24XX02;
with EEPROM_I2C.MC24XX16;
with EEPROM_I2C.MC24XX64;
with EEPROM_I2C.MC24XX512;

package body Helpers is

   --  potential test targets
   Eeprom_1K       : aliased EEPROM_I2C.MC24XX01.EEPROM_Memory_MC24XX01
     (Delay_Provider.Delay_MS'Access,
      EEPROM_I2C.MC24XX01.I2C_DEFAULT_ADDRESS,
      Configuration.Eeprom_I2C_Port'Access);

   Eeprom_2K       : aliased EEPROM_I2C.MC24XX02.EEPROM_Memory_MC24XX02
     (Delay_Provider.Delay_MS'Access,
      EEPROM_I2C.MC24XX02.I2C_DEFAULT_ADDRESS,
      Configuration.Eeprom_I2C_Port'Access);

   Eeprom_16K       : aliased EEPROM_I2C.MC24XX16.EEPROM_Memory_MC24XX16
     (Delay_Provider.Delay_MS'Access,
      EEPROM_I2C.MC24XX16.I2C_DEFAULT_ADDRESS,
      Configuration.Eeprom_I2C_Port'Access);

   Eeprom_64K       : aliased EEPROM_I2C.MC24XX64.EEPROM_Memory_MC24XX64
     (Delay_Provider.Delay_MS'Access,
      EEPROM_I2C.MC24XX64.I2C_DEFAULT_ADDRESS,
      Configuration.Eeprom_I2C_Port'Access);

   --     Eeprom_128K       : EEPROM_I2C.MC24XX128.EEPROM_Memory_MC24XX128
   --       (Delay_Provider.Delay_MS'Access,
   --        EEPROM_I2C.MC24XX128.I2C_DEFAULT_ADDRESS,
   --        Eeprom_I2C_Port'Access);
   --     pragma Warnings (Off, Eeprom_128K);
   --     Eeprom_256K       : EEPROM_I2C.MC24XX256.EEPROM_Memory_MC24XX256
   --       (Delay_Provider.Delay_MS'Access,
   --        EEPROM_I2C.MC24XX256.I2C_DEFAULT_ADDRESS,
   --        Eeprom_I2C_Port'Access);
   --     pragma Warnings (Off, Eeprom_256K);

   Eeprom_512K       : aliased EEPROM_I2C.MC24XX512.EEPROM_Memory_MC24XX512
     (Delay_Provider.Delay_MS'Access,
      EEPROM_I2C.MC24XX512.I2C_DEFAULT_ADDRESS,
      Configuration.Eeprom_I2C_Port'Access);

   All_EEPs                     : constant array
     (EEPROM_I2C.EEC_MC24XX01 .. EEPROM_I2C.EEC_MC24XX512)
     of
       EEPROM_I2C.Any_EEPROM_Memory :=
         (EEPROM_I2C.EEC_MC24XX01  => Helpers.Eeprom_1K'Access,
          EEPROM_I2C.EEC_MC24XX02  => Helpers.Eeprom_2K'Access,
          EEPROM_I2C.EEC_MC24XX16  => Helpers.Eeprom_16K'Access,
          EEPROM_I2C.EEC_MC24XX64  => Helpers.Eeprom_64K'Access,
          EEPROM_I2C.EEC_MC24XX512 => Helpers.Eeprom_512K'Access);

   use HAL;

   use EEPROM_I2C;

   THE_TIMEOUT_IN_MS : constant Natural := 1_000;

   The_Trigger : RP.GPIO.GPIO_Point;

   procedure Fill_With_Random_Data (Fill_Data : out HAL.I2C.I2C_Data);
   procedure Verify_Data (Expected   : in out HAL.I2C.I2C_Data;
                          Actual     : in out HAL.I2C.I2C_Data;
                          CB_LED_Off : LED_Off);

   procedure Initialize  (Trigger_Port : RP.GPIO.GPIO_Point;
                         Frequency    : Natural) is
   begin
      --  standard initialization
      RP.Clock.Initialize (Frequency);
      RP.Clock.Enable (RP.Clock.PERI);
      RP.Device.Timer.Enable;
      RP.GPIO.Enable;

      --  configure the I2C port
      Configuration.Eeprom_SDA.Configure (Mode => RP.GPIO.Output,
                                          Pull => RP.GPIO.Pull_Up,
                                          Func => RP.GPIO.I2C);
      Configuration.Eeprom_SCL.Configure (Mode => RP.GPIO.Output,
                                          Pull => RP.GPIO.Pull_Up,
                                          Func => RP.GPIO.I2C);
      Configuration.Eeprom_I2C_Port.Configure (Baudrate => 400_000);

      The_Trigger := Trigger_Port;
      --  define a trigger input to enable oscilloscope tracking
      RP.GPIO.Configure (This => The_Trigger,
                         Mode => RP.GPIO.Input,
                         Pull => RP.GPIO.Pull_Down,
                         Func => RP.GPIO.SIO);
   end Initialize;

   Trigger    : Boolean := False;

   procedure Trigger_Enable is
   begin
      Trigger := True;
   end Trigger_Enable;

   procedure Trigger_Disable is
   begin
      Trigger := False;
   end Trigger_Disable;

   function Trigger_Is_Enabled return Boolean is
     (Trigger);

   procedure Wait_For_Trigger_Fired is
   begin
      if not Trigger_Is_Enabled then
         return;
      end if;

      loop
         exit when RP.GPIO.Get (The_Trigger);
      end loop;
   end Wait_For_Trigger_Fired;

   procedure Wait_For_Trigger_Resume is
   begin
      if not Trigger_Is_Enabled then
         return;
      end if;

      loop
         exit when not RP.GPIO.Get (The_Trigger);
      end loop;
   end Wait_For_Trigger_Resume;

   procedure Fill_With_Random_Data (Fill_Data : out HAL.I2C.I2C_Data) is
      LUT_Index : Natural := Random_UInt_8.LUT'First;
   begin
      for Idx in Fill_Data'First .. Fill_Data'Last loop
         Fill_Data (Idx) := Random_UInt_8.LUT (LUT_Index);
         if LUT_Index = Random_UInt_8.LUT'Last then
            LUT_Index := Random_UInt_8.LUT'First;
         else
            LUT_Index := LUT_Index + 1;
         end if;
      end loop;
   end Fill_With_Random_Data;

   procedure Wipe_And_Verify
     (EEP               : in out EEPROM_I2C.EEPROM_Memory'Class;
      CB_LED_Off        : LED_Off;
      Wipe_Data         : in out HAL.I2C.I2C_Data;
      Read_Data         : in out HAL.I2C.I2C_Data);
   procedure Wipe_And_Verify
     (EEP               : in out EEPROM_I2C.EEPROM_Memory'Class;
      CB_LED_Off        : LED_Off;
      Wipe_Data         : in out HAL.I2C.I2C_Data;
      Read_Data         : in out HAL.I2C.I2C_Data) is
      EE_Status : EEPROM_I2C.EEPROM_Operation_Result;
   begin
      EEPROM_I2C.Wipe (This   => EEP,
                       Status => EE_Status);

      if EE_Status.E_Status /= EEPROM_I2C.Ok then
         CB_LED_Off.all;
         loop
            null;
         end loop;
      end if;

      EEPROM_I2C.Read (EEP,
                       Mem_Addr   => 0,
                       Data       => Read_Data,
                       Status     => EE_Status,
                       Timeout_MS => THE_TIMEOUT_IN_MS);
      if EE_Status.E_Status /= EEPROM_I2C.Ok then
         CB_LED_Off.all;
         loop
            null;
         end loop;
      end if;

      Verify_Data (Expected => Wipe_Data,
                   Actual => Read_Data,
                   CB_LED_Off => CB_LED_Off);
   end Wipe_And_Verify;

   procedure Check_Full_Size
     (EEP_Enum   : EEPROM_I2C.EEPROM_Chip;
      CB_LED_Off : LED_Off) is
      EEP        : EEPROM_I2C.EEPROM_Memory'Class := All_EEPs (EEP_Enum).all;
      Ref_Data   : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes))
        := (others => 16#FF#);
      Read_Data  : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
      EE_Status  : EEPROM_I2C.EEPROM_Operation_Result;
   begin
      Delay_Provider.Delay_MS (MS => 5);

      Wipe_And_Verify (EEP        => EEP,
                       CB_LED_Off => CB_LED_Off,
                       Wipe_Data => Ref_Data,
                       Read_Data => Read_Data);
      Delay_Provider.Delay_MS (MS => 5);

      Helpers.Fill_With_Random_Data (Fill_Data => Ref_Data);

      Delay_Provider.Delay_MS (MS => 5);
      EEPROM_I2C.Write (EEP,
                        Mem_Addr   => 0,
                        Data       => Ref_Data,
                        Status     => EE_Status,
                        Timeout_MS => THE_TIMEOUT_IN_MS);
      Delay_Provider.Delay_MS (MS => 5);

      if EE_Status.E_Status /= EEPROM_I2C.Ok then
         CB_LED_Off.all;
         loop
            null;
         end loop;
      end if;

      Delay_Provider.Delay_MS (MS => 5);
      EEPROM_I2C.Read (EEP,
                       Mem_Addr   => 0,
                       Data       => Read_Data,
                       Status     => EE_Status,
                       Timeout_MS => THE_TIMEOUT_IN_MS);
      Delay_Provider.Delay_MS (MS => 50);

      if EE_Status.E_Status /= EEPROM_I2C.Ok then
         CB_LED_Off.all;
         loop
            null;
         end loop;
      end if;

      Verify_Data (Expected => Ref_Data,
                   Actual => Read_Data,
                   CB_LED_Off => CB_LED_Off);
   end Check_Full_Size;

   --     procedure Check_Header_Only
   --       (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
   --        CB_LED_Off : LED_Off) is
   --        Mem_Addr    : constant HAL.UInt32
   --          := HAL.UInt32 (EEP.C_Bytes_Per_Page) / 2 - 1;
   --        Ref_Data    : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
   --        Read_Data   : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
   --        EE_Status   : EEPROM_I2C.EEPROM_Operation_Result;
   --
   --     begin
   --        EEPROM_I2C.Wipe (This   => EEP,
   --                         Status => EE_Status);
   --        if EE_Status.E_Status /= EEPROM_I2C.Ok then
   --           CB_LED_Off.all;
   --           loop
   --              null;
   --           end loop;
   --        end if;
   --
   --        Helpers.Fill_With (Fill_Data => Ref_Data);
   --
   --        EEPROM_I2C.Write (EEP,
   --                          Mem_Addr   => Mem_Addr,
   --                          Data       => Ref_Data,
   --                          Status     => EE_Status,
   --                          Timeout_MS => THE_TIMEOUT_IN_MS);
   --
   --        if EE_Status.E_Status /= EEPROM_I2C.Ok then
   --           CB_LED_Off.all;
   --           loop
   --              null;
   --           end loop;
   --        end if;
   --
   --        EEPROM_I2C.Read (EEP,
   --                         Mem_Addr   => Mem_Addr,
   --                         Data       => Read_Data,
   --                         Status     => EE_Status,
   --                         Timeout_MS => THE_TIMEOUT_IN_MS);
   --        if EE_Status.E_Status /= EEPROM_I2C.Ok then
   --           CB_LED_Off.all;
   --           loop
   --              null;
   --           end loop;
   --        end if;
   --
   --        Verify_Data (Expected => Ref_Data,
   --                     Actual => Read_Data,
   --                     CB_LED_Off => CB_LED_Off);
   --     end Check_Header_Only;
   --
   --     procedure Check_Header_And_Full_Pages
   --       (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
   --        CB_LED_Off : LED_Off) is
   --        Ref_Data    : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
   --        Read_Data   : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
   --        EE_Status   : EEPROM_I2C.EEPROM_Operation_Result;
   --        Mem_Addr    : constant HAL.UInt32
   --          := HAL.UInt32 (EEP.C_Bytes_Per_Page) / 2 - 1;
   --
   --     begin
   --        EEPROM_I2C.Wipe (This   => EEP,
   --                         Status => EE_Status);
   --        if EE_Status.E_Status /= EEPROM_I2C.Ok then
   --           CB_LED_Off.all;
   --           loop
   --              null;
   --           end loop;
   --        end if;
   --
   --        Helpers.Fill_With (Fill_Data => Ref_Data);
   --
   --        EEPROM_I2C.Write (EEP,
   --                          Mem_Addr   => Mem_Addr,
   --                          Data       => Ref_Data,
   --                          Status     => EE_Status,
   --                          Timeout_MS => THE_TIMEOUT_IN_MS);
   --
   --        if EE_Status.E_Status /= EEPROM_I2C.Ok then
   --           CB_LED_Off.all;
   --           loop
   --              null;
   --           end loop;
   --        end if;
   --
   --        EEPROM_I2C.Read (EEP,
   --                         Mem_Addr   => Mem_Addr,
   --                         Data       => Read_Data,
   --                         Status     => EE_Status,
   --                         Timeout_MS => THE_TIMEOUT_IN_MS);
   --        if EE_Status.E_Status /= EEPROM_I2C.Ok then
   --           CB_LED_Off.all;
   --           loop
   --              null;
   --           end loop;
   --        end if;
   --
   --        Helpers.Verify_Data (Expected => Ref_Data,
   --                             Actual => Read_Data,
   --                             CB_LED_Off => CB_LED_Off);
   --     end Check_Header_And_Full_Pages;
   --
   --     procedure Check_Header_And_Tailing
   --       (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
   --        CB_LED_Off : LED_Off) is
   --        Ref_Data    : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
   --        Read_Data   : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
   --        EE_Status   : EEPROM_I2C.EEPROM_Operation_Result;
   --        Mem_Addr    : constant HAL.UInt32
   --          := HAL.UInt32 (EEP.C_Bytes_Per_Page) / 2 - 1;
   --
   --     begin
   --        EEPROM_I2C.Wipe (This   => EEP,
   --                         Status => EE_Status);
   --        if EE_Status.E_Status /= EEPROM_I2C.Ok then
   --           CB_LED_Off.all;
   --           loop
   --              null;
   --           end loop;
   --        end if;
   --
   --        Helpers.Fill_With (Fill_Data => Ref_Data);
   --
   --        EEPROM_I2C.Write (EEP,
   --                          Mem_Addr   => Mem_Addr,
   --                          Data       => Ref_Data,
   --                          Status     => EE_Status,
   --                          Timeout_MS => THE_TIMEOUT_IN_MS);
   --
   --        if EE_Status.E_Status /= EEPROM_I2C.Ok then
   --           CB_LED_Off.all;
   --           loop
   --              null;
   --           end loop;
   --        end if;
   --
   --        EEPROM_I2C.Read (EEP,
   --                         Mem_Addr   => Mem_Addr,
   --                         Data       => Read_Data,
   --                         Status     => EE_Status,
   --                         Timeout_MS => THE_TIMEOUT_IN_MS);
   --        if EE_Status.E_Status /= EEPROM_I2C.Ok then
   --           CB_LED_Off.all;
   --           loop
   --              null;
   --           end loop;
   --        end if;
   --
   --        Helpers.Verify_Data (Expected => Ref_Data,
   --                             Actual => Read_Data,
   --                             CB_LED_Off => CB_LED_Off);
   --     end Check_Header_And_Tailing;
   --
   --     procedure Check_Header_And_Full_Pages_And_Tailing
   --       (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
   --        CB_LED_Off : LED_Off) is
   --        Ref_Data    : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
   --        Read_Data   : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
   --        EE_Status   : EEPROM_I2C.EEPROM_Operation_Result;
   --        Mem_Addr    : constant HAL.UInt32
   --          := HAL.UInt32 (EEP.C_Bytes_Per_Page) / 2 - 1;
   --
   --     begin
   --        EEPROM_I2C.Wipe (This   => EEP,
   --                         Status => EE_Status);
   --        if EE_Status.E_Status /= EEPROM_I2C.Ok then
   --           CB_LED_Off.all;
   --           loop
   --              null;
   --           end loop;
   --        end if;
   --
   --        Helpers.Fill_With (Fill_Data => Ref_Data);
   --
   --        EEPROM_I2C.Write (EEP,
   --                          Mem_Addr   => Mem_Addr,
   --                          Data       => Ref_Data,
   --                          Status     => EE_Status,
   --                          Timeout_MS => THE_TIMEOUT_IN_MS);
   --
   --        if EE_Status.E_Status /= EEPROM_I2C.Ok then
   --           CB_LED_Off.all;
   --           loop
   --              null;
   --           end loop;
   --        end if;
   --
   --        EEPROM_I2C.Read (EEP,
   --                         Mem_Addr   => Mem_Addr,
   --                         Data       => Read_Data,
   --                         Status     => EE_Status,
   --                         Timeout_MS => THE_TIMEOUT_IN_MS);
   --        if EE_Status.E_Status /= EEPROM_I2C.Ok then
   --           CB_LED_Off.all;
   --           loop
   --              null;
   --           end loop;
   --        end if;
   --
   --        Helpers.Verify_Data (Expected => Ref_Data,
   --                             Actual => Read_Data,
   --                             CB_LED_Off => CB_LED_Off);
   --     end Check_Header_And_Full_Pages_And_Tailing;
   --
   --     procedure Check_Full_Pages
   --       (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
   --        CB_LED_Off : LED_Off) is
   --        Ref_Data    : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
   --        Read_Data   : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
   --        EE_Status   : EEPROM_I2C.EEPROM_Operation_Result;
   --        Mem_Addr    : constant HAL.UInt32
   --          := 2 * HAL.UInt32 (EEP.C_Bytes_Per_Page);
   --
   --     begin
   --        EEPROM_I2C.Wipe (This   => EEP,
   --                         Status => EE_Status);
   --        if EE_Status.E_Status /= EEPROM_I2C.Ok then
   --           CB_LED_Off.all;
   --           loop
   --              null;
   --           end loop;
   --        end if;
   --
   --        Helpers.Fill_With (Fill_Data => Ref_Data);
   --
   --        EEPROM_I2C.Write (EEP,
   --                          Mem_Addr   => Mem_Addr,
   --                          Data       => Ref_Data,
   --                          Status     => EE_Status,
   --                          Timeout_MS => THE_TIMEOUT_IN_MS);
   --
   --        if EE_Status.E_Status /= EEPROM_I2C.Ok then
   --           CB_LED_Off.all;
   --           loop
   --              null;
   --           end loop;
   --        end if;
   --
   --        EEPROM_I2C.Read (EEP,
   --                         Mem_Addr   => Mem_Addr,
   --                         Data       => Read_Data,
   --                         Status     => EE_Status,
   --                         Timeout_MS => THE_TIMEOUT_IN_MS);
   --        if EE_Status.E_Status /= EEPROM_I2C.Ok then
   --           CB_LED_Off.all;
   --           loop
   --              null;
   --           end loop;
   --        end if;
   --
   --        Helpers.Verify_Data (Expected => Ref_Data,
   --                             Actual => Read_Data,
   --                             CB_LED_Off => CB_LED_Off);
   --     end Check_Full_Pages;
   --
   --     procedure Check_Full_Pages_And_Tailing
   --       (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
   --        CB_LED_Off : LED_Off) is
   --        Ref_Data    : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
   --        Read_Data   : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
   --        EE_Status   : EEPROM_I2C.EEPROM_Operation_Result;
   --        Mem_Addr    : constant HAL.UInt32
   --          := 2 * HAL.UInt32 (EEP.C_Bytes_Per_Page);
   --
   --     begin
   --        EEPROM_I2C.Wipe (This   => EEP,
   --                         Status => EE_Status);
   --        if EE_Status.E_Status /= EEPROM_I2C.Ok then
   --           CB_LED_Off.all;
   --           loop
   --              null;
   --           end loop;
   --        end if;
   --
   --        Helpers.Fill_With (Fill_Data => Ref_Data);
   --
   --        EEPROM_I2C.Write (EEP,
   --                          Mem_Addr   => Mem_Addr,
   --                          Data       => Ref_Data,
   --                          Status     => EE_Status,
   --                          Timeout_MS => THE_TIMEOUT_IN_MS);
   --
   --        if EE_Status.E_Status /= EEPROM_I2C.Ok then
   --           CB_LED_Off.all;
   --           loop
   --              null;
   --           end loop;
   --        end if;
   --
   --        EEPROM_I2C.Read (EEP,
   --                         Mem_Addr   => Mem_Addr,
   --                         Data       => Read_Data,
   --                         Status     => EE_Status,
   --                         Timeout_MS => THE_TIMEOUT_IN_MS);
   --        if EE_Status.E_Status /= EEPROM_I2C.Ok then
   --           CB_LED_Off.all;
   --           loop
   --              null;
   --           end loop;
   --        end if;
   --
   --        Helpers.Verify_Data (Expected => Ref_Data,
   --                             Actual => Read_Data,
   --                             CB_LED_Off => CB_LED_Off);
   --     end Check_Full_Pages_And_Tailing;

   procedure Verify_Data (Expected   : in out HAL.I2C.I2C_Data;
                          Actual     : in out HAL.I2C.I2C_Data;
                          CB_LED_Off : LED_Off) is
      pragma Warnings (Off, Expected);
      pragma Warnings (Off, Actual);
   begin
      for Idx in Expected'First .. Expected'Last loop
         if Actual (Idx) /= Expected (Idx) then
            CB_LED_Off.all;
            loop
               null;
            end loop;
         end if;
      end loop;
   end Verify_Data;

end Helpers;
