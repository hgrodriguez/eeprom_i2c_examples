-----------------------------------------------------------------------------
--  Implementation of writing the full EEPROM using I2C
--  Pico version
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL;

with RP.GPIO;

with Pico;
with Pico_LED;

with Delay_Provider;

with EEPROM_I2C;

with Helpers;

procedure Pico_Write_Full_And_Check is

   use HAL;

   type EEP_DIP_Valid_Selector is new HAL.UInt4 range
     EEPROM_I2C.EEPROM_Chip'Pos (EEPROM_I2C.EEC_MC24XX01) + 1
     ..
       EEPROM_I2C.EEPROM_Chip'Pos (EEPROM_I2C.EEC_MC24XX512) + 1;

   All_DIPs : constant array (EEP_DIP_Valid_Selector) of EEPROM_I2C.EEPROM_Chip
     := (1 => EEPROM_I2C.EEC_MC24XX01,
         2 => EEPROM_I2C.EEC_MC24XX02,
         3 => EEPROM_I2C.EEC_MC24XX16,
         4 => EEPROM_I2C.EEC_MC24XX64,
         5 => EEPROM_I2C.EEC_MC24XX512);

   Dip_Selector : HAL.UInt4 := 0;
   EEP_Selected : EEPROM_I2C.EEPROM_Chip;

   --  Trigger button when to read/write the byte from the EEPROM
   --  This trigger is generated using a function generator
   --    providing a square signal with a settable frequency
   Button       : RP.GPIO.GPIO_Point renames Pico.GP16;

begin
   Helpers.Initialize (Button,
                       Pico.XOSC_Frequency);

   --  as always, visual help is appreciated
   Pico.LED.Configure (RP.GPIO.Output);

   --  just some visual help
   Pico.LED.Set;

   Dip_Selector := Helpers.Eeprom_Code_Selected;

   --  check the DIP selector
   if Dip_Selector < HAL.UInt4 (EEP_DIP_Valid_Selector'First)
     or Dip_Selector > HAL.UInt4 (EEP_DIP_Valid_Selector'Last)
   then
      loop
         Pico.LED.Clear;
         Delay_Provider.Delay_MS (MS => 50);
         Pico.LED.Set;
         Delay_Provider.Delay_MS (MS => 50);
      end loop;
   end if;

   --  show value
   Delay_Provider.Delay_MS (MS => 1000);   Pico.LED.Clear;
   Delay_Provider.Delay_MS (MS => 1000);
   for Bleep in 1 .. Dip_Selector loop
      Pico.LED.Set;
      Delay_Provider.Delay_MS (MS => 250);
      Pico.LED.Clear;
      Delay_Provider.Delay_MS (MS => 250);
   end loop;

   Delay_Provider.Delay_MS (MS => 1000);
   Pico.LED.Set;

   if False then
      EEP_Selected := All_DIPs (EEP_DIP_Valid_Selector (Dip_Selector));

      --  the full monty
      Helpers.
        Check_Full_Size (EEP_Selected,
                         Pico_LED.Pico_Led_Off'Access);
   end if;

   --  headers involved
   --     Helpers.
   --       Check_Header_Only (EEPROM,
   --                          Pico_LED.Pico_Led_Off'Access);
   --     Helpers.
   --       Check_Header_And_Full_Pages (EEPROM,
   --                                    Pico_LED.Pico_Led_Off'Access);
   --     Helpers.
   --       Check_Header_And_Tailing (EEPROM,
   --                                 Pico_LED.Pico_Led_Off'Access);
   --     Helpers.
   --       Check_Header_And_Full_Pages_And_Tailing (EEPROM,
   --                                           Pico_LED.Pico_Led_Off'Access);
   --
   --     --  full pages involved
   --     Helpers.
   --       Check_Full_Pages (EEPROM,
   --                         Pico_LED.Pico_Led_Off'Access);
   --     Helpers.
   --       Check_Full_Pages_And_Tailing (EEPROM,
   --                                     Pico_LED.Pico_Led_Off'Access);

   loop
      Pico.LED.Clear;
      Delay_Provider.Delay_MS (MS => 500);
      Pico.LED.Set;
      Delay_Provider.Delay_MS (MS => 500);
   end loop;
end Pico_Write_Full_And_Check;
