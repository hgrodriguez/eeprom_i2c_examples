-----------------------------------------------------------------------------
--  Implementation of
--  Helpers package for different functions / procedures to minimize
--  code duplication
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with RP.Device;
with RP.Clock;

package body Helpers is

   use HAL;

   use EEPROM_I2C;

   procedure Initialize_I2C (SDA      : in out RP.GPIO.GPIO_Point;
                             SCL      : in out RP.GPIO.GPIO_Point;
                             I2C_Port : in out RP.I2C_Master.I2C_Master_Port);

   The_Trigger : RP.GPIO.GPIO_Point;

   procedure Initialize  (SDA          : in out RP.GPIO.GPIO_Point;
                          SCL          : in out RP.GPIO.GPIO_Point;
                          I2C_Port     : in out RP.I2C_Master.I2C_Master_Port;
                          Trigger_Port : RP.GPIO.GPIO_Point;
                          Frequency    : Natural) is
   begin
      --  standard initialization
      RP.Clock.Initialize (Frequency);
      RP.Clock.Enable (RP.Clock.PERI);
      RP.Device.Timer.Enable;
      RP.GPIO.Enable;

      Initialize_I2C (SDA, SCL, I2C_Port);
      The_Trigger := Trigger_Port;
      --  define a trigger input to enable oscilloscope tracking
      RP.GPIO.Configure (This => The_Trigger,
                         Mode => RP.GPIO.Input,
                         Pull => RP.GPIO.Pull_Down,
                         Func => RP.GPIO.SIO);
   end Initialize;

   Trigger : Boolean := False;

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

   procedure Initialize_I2C
     (SDA      : in out RP.GPIO.GPIO_Point;
      SCL      : in out RP.GPIO.GPIO_Point;
      I2C_Port : in out RP.I2C_Master.I2C_Master_Port) is
   begin
      --  configure the I2C port
      SDA.Configure (Mode => RP.GPIO.Output,
                     Pull => RP.GPIO.Pull_Up,
                     Func => RP.GPIO.I2C);
      SCL.Configure (Mode => RP.GPIO.Output,
                     Pull => RP.GPIO.Pull_Up,
                     Func => RP.GPIO.I2C);
      I2C_Port.Configure (Baudrate => 400_000);

   end Initialize_I2C;

   procedure Fill_With (Fill_Data : out HAL.I2C.I2C_Data;
                        Byte      : HAL.UInt8 := 16#FF#) is
   begin
      for Idx in Fill_Data'First .. Fill_Data'Last loop
         Fill_Data (Idx) := Byte;
      end loop;
   end Fill_With;

   procedure Check_Full_Size
     (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
      CB_LED_Off : LED_Off) is
      Byte      : HAL.UInt8;
      Ref_Data  : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
      Read_Data : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
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

      Byte := 0;
      for Idx in Ref_Data'First .. Ref_Data'Last loop
         Ref_Data (Idx) := Byte;
         Byte := Byte + 1;
      end loop;

      EEPROM_I2C.Write (EEP,
                        Mem_Addr   => 0,
                        Data       => Ref_Data,
                        Status     => EE_Status,
                        Timeout_MS => 0);
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
                       Timeout_MS => 0);
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

   procedure Check_Header_Only
     (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
      CB_LED_Off : LED_Off) is
      Byte        : HAL.UInt8;
      Header_Data : HAL.I2C.I2C_Data (1
                                      ..
                                        Integer (EEP.C_Bytes_Per_Page) / 2);
      Mem_Addr    : constant HAL.UInt16 := EEP.C_Bytes_Per_Page / 2 - 1;
      Ref_Data    : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
      Read_Data   : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
      EE_Status   : EEPROM_I2C.EEPROM_Operation_Result;

   begin
      EEPROM_I2C.Wipe (This   => EEP,
                       Status => EE_Status);
      if EE_Status.E_Status /= EEPROM_I2C.Ok then
         CB_LED_Off.all;
         loop
            null;
         end loop;
      end if;

      Helpers.Fill_With (Fill_Data => Ref_Data);

      Byte := 16#01#;
      for Idx in Header_Data'First .. Header_Data'Last loop
         Header_Data (Idx) := Byte;
         Ref_Data (Integer (Mem_Addr) + Idx) := Header_Data (Idx);
         Byte := Byte + 1;
      end loop;

      EEPROM_I2C.Write (EEP,
                        Mem_Addr   => Mem_Addr,
                        Data       => Header_Data,
                        Status     => EE_Status,
                        Timeout_MS => 0);

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
                       Timeout_MS => 0);
      if EE_Status.E_Status /= EEPROM_I2C.Ok then
         CB_LED_Off.all;
         loop
            null;
         end loop;
      end if;

      Verify_Data (Expected => Ref_Data,
                           Actual => Read_Data,
                           CB_LED_Off => CB_LED_Off);
   end Check_Header_Only;

   procedure Check_Header_And_Full_Pages
     (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
      CB_LED_Off : LED_Off) is
      Byte        : HAL.UInt8;
      Ref_Data    : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
      Read_Data   : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
      EE_Status   : EEPROM_I2C.EEPROM_Operation_Result;
      EE_Data     : HAL.I2C.I2C_Data (1
                                      ..
                                        Integer (EEP.C_Bytes_Per_Page) / 2 +
                                        2 * Integer (EEP.C_Bytes_Per_Page));
      Mem_Addr    : constant HAL.UInt16 := EEP.C_Bytes_Per_Page / 2 - 1;

   begin
      EEPROM_I2C.Wipe (This   => EEP,
                       Status => EE_Status);
      if EE_Status.E_Status /= EEPROM_I2C.Ok then
         CB_LED_Off.all;
         loop
            null;
         end loop;
      end if;

      Helpers.Fill_With (Fill_Data => Ref_Data);

      Byte := 16#01#;
      for Idx in EE_Data'First .. EE_Data'Last loop
         EE_Data (Idx) := Byte;
         Ref_Data (Integer (Mem_Addr) + Idx) := EE_Data (Idx);
         Byte := Byte + 1;
      end loop;

      EEPROM_I2C.Write (EEP,
                        Mem_Addr   => Mem_Addr,
                        Data       => EE_Data,
                        Status     => EE_Status,
                        Timeout_MS => 0);

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
                       Timeout_MS => 0);
      if EE_Status.E_Status /= EEPROM_I2C.Ok then
         CB_LED_Off.all;
         loop
            null;
         end loop;
      end if;

      Helpers.Verify_Data (Expected => Ref_Data,
                           Actual => Read_Data,
                           CB_LED_Off => CB_LED_Off);
   end Check_Header_And_Full_Pages;

   procedure Check_Header_And_Tailing
     (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
      CB_LED_Off : LED_Off) is
      Byte        : HAL.UInt8;
      Ref_Data    : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
      Read_Data   : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
      EE_Status   : EEPROM_I2C.EEPROM_Operation_Result;
      EE_Data     : HAL.I2C.I2C_Data (1
                                      ..
                                        1 * Integer (EEP.C_Bytes_Per_Page));
      Mem_Addr    : constant HAL.UInt16 := EEP.C_Bytes_Per_Page / 2 - 1;

   begin
      EEPROM_I2C.Wipe (This   => EEP,
                       Status => EE_Status);
      if EE_Status.E_Status /= EEPROM_I2C.Ok then
         CB_LED_Off.all;
         loop
            null;
         end loop;
      end if;

      Helpers.Fill_With (Fill_Data => Ref_Data);

      Byte := 16#01#;
      for Idx in EE_Data'First .. EE_Data'Last loop
         EE_Data (Idx) := Byte;
         Ref_Data (Integer (Mem_Addr) + Idx) := EE_Data (Idx);
         Byte := Byte + 1;
      end loop;

      EEPROM_I2C.Write (EEP,
                        Mem_Addr   => Mem_Addr,
                        Data       => EE_Data,
                        Status     => EE_Status,
                        Timeout_MS => 0);

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
                       Timeout_MS => 0);
      if EE_Status.E_Status /= EEPROM_I2C.Ok then
         CB_LED_Off.all;
         loop
            null;
         end loop;
      end if;

      Helpers.Verify_Data (Expected => Ref_Data,
                           Actual => Read_Data,
                           CB_LED_Off => CB_LED_Off);
   end Check_Header_And_Tailing;

   procedure Check_Header_And_Full_Pages_And_Tailing
     (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
      CB_LED_Off : LED_Off) is
      Byte        : HAL.UInt8;
      Ref_Data    : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
      Read_Data   : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
      EE_Status   : EEPROM_I2C.EEPROM_Operation_Result;
      EE_Data     : HAL.I2C.I2C_Data (1
                                      ..
                                        2 * Integer (EEP.C_Bytes_Per_Page) +
                                        Integer (EEP.C_Bytes_Per_Page) / 2);
      Mem_Addr    : constant HAL.UInt16 := EEP.C_Bytes_Per_Page / 2 - 1;

   begin
      EEPROM_I2C.Wipe (This   => EEP,
                       Status => EE_Status);
      if EE_Status.E_Status /= EEPROM_I2C.Ok then
         CB_LED_Off.all;
         loop
            null;
         end loop;
      end if;

      Helpers.Fill_With (Fill_Data => Ref_Data);

      Byte := 16#01#;
      for Idx in EE_Data'First .. EE_Data'Last loop
         EE_Data (Idx) := Byte;
         Ref_Data (Integer (Mem_Addr) + Idx) := EE_Data (Idx);
         Byte := Byte + 1;
      end loop;

      EEPROM_I2C.Write (EEP,
                        Mem_Addr   => Mem_Addr,
                        Data       => EE_Data,
                        Status     => EE_Status,
                        Timeout_MS => 0);

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
                       Timeout_MS => 0);
      if EE_Status.E_Status /= EEPROM_I2C.Ok then
         CB_LED_Off.all;
         loop
            null;
         end loop;
      end if;

      Helpers.Verify_Data (Expected => Ref_Data,
                           Actual => Read_Data,
                           CB_LED_Off => CB_LED_Off);
   end Check_Header_And_Full_Pages_And_Tailing;

   procedure Check_Full_Pages
     (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
      CB_LED_Off : LED_Off) is
      Byte        : HAL.UInt8;
      Ref_Data    : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
      Read_Data   : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
      EE_Status   : EEPROM_I2C.EEPROM_Operation_Result;
      EE_Data     : HAL.I2C.I2C_Data (1
                                      ..
                                        4 * Integer (EEP.C_Bytes_Per_Page));
      Mem_Addr    : constant HAL.UInt16 := 2 * EEP.C_Bytes_Per_Page;

   begin
      EEPROM_I2C.Wipe (This   => EEP,
                       Status => EE_Status);
      if EE_Status.E_Status /= EEPROM_I2C.Ok then
         CB_LED_Off.all;
         loop
            null;
         end loop;
      end if;

      Helpers.Fill_With (Fill_Data => Ref_Data);

      Byte := 16#01#;
      for Idx in EE_Data'First .. EE_Data'Last loop
         EE_Data (Idx) := Byte;
         Ref_Data (Integer (Mem_Addr) + Idx) := EE_Data (Idx);
         Byte := Byte + 1;
      end loop;

      EEPROM_I2C.Write (EEP,
                        Mem_Addr   => Mem_Addr,
                        Data       => EE_Data,
                        Status     => EE_Status,
                        Timeout_MS => 0);

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
                       Timeout_MS => 0);
      if EE_Status.E_Status /= EEPROM_I2C.Ok then
         CB_LED_Off.all;
         loop
            null;
         end loop;
      end if;

      Helpers.Verify_Data (Expected => Ref_Data,
                           Actual => Read_Data,
                           CB_LED_Off => CB_LED_Off);
   end Check_Full_Pages;

   procedure Check_Full_Pages_And_Tailing
     (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
      CB_LED_Off : LED_Off) is
      Byte        : HAL.UInt8;
      Ref_Data    : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
      Read_Data   : HAL.I2C.I2C_Data (1 .. Integer (EEP.Size_In_Bytes));
      EE_Status   : EEPROM_I2C.EEPROM_Operation_Result;
      EE_Data     : HAL.I2C.I2C_Data (1
                                      ..
                                        2 * Integer (EEP.C_Bytes_Per_Page) +
                                        Integer (EEP.C_Bytes_Per_Page) / 2);
      Mem_Addr    : constant HAL.UInt16 := 2 * EEP.C_Bytes_Per_Page;

   begin
      EEPROM_I2C.Wipe (This   => EEP,
                       Status => EE_Status);
      if EE_Status.E_Status /= EEPROM_I2C.Ok then
         CB_LED_Off.all;
         loop
            null;
         end loop;
      end if;

      Helpers.Fill_With (Fill_Data => Ref_Data);

      Byte := 16#01#;
      for Idx in EE_Data'First .. EE_Data'Last loop
         EE_Data (Idx) := Byte;
         Ref_Data (Integer (Mem_Addr) + Idx) := EE_Data (Idx);
         Byte := Byte + 1;
      end loop;

      EEPROM_I2C.Write (EEP,
                        Mem_Addr   => Mem_Addr,
                        Data       => EE_Data,
                        Status     => EE_Status,
                        Timeout_MS => 0);

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
                       Timeout_MS => 0);
      if EE_Status.E_Status /= EEPROM_I2C.Ok then
         CB_LED_Off.all;
         loop
            null;
         end loop;
      end if;

      Helpers.Verify_Data (Expected => Ref_Data,
                           Actual => Read_Data,
                           CB_LED_Off => CB_LED_Off);
   end Check_Full_Pages_And_Tailing;

   procedure Verify_Data (Expected   : HAL.I2C.I2C_Data;
                          Actual     : HAL.I2C.I2C_Data;
                          CB_LED_Off : LED_Off) is
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
