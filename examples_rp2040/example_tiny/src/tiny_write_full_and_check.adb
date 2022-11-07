-----------------------------------------------------------------------------
--  Implementation of writing the full EEPROM using I2C
--  Tiny version
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL;

with RP.GPIO;

with Tiny;
with Tiny_LED;

with Delay_Provider;
with EEPROM_I2C;

with Helpers;

procedure Tiny_Write_Full_And_Check is

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
   Button       : RP.GPIO.GPIO_Point renames Tiny.GP7;

begin
   Tiny.Initialize;

   Helpers.Initialize (Button,
                       Tiny.XOSC_Frequency);

   --  as always, visual help is appreciated
   Tiny.LED_Blue.Configure (RP.GPIO.Output);
   Tiny.LED_Green.Configure (RP.GPIO.Output);
   Tiny.LED_Red.Configure (RP.GPIO.Output);

   --  just some visual help
   Tiny.Switch_Off (This => Tiny.LED_Blue);
   Tiny.Switch_Off (This => Tiny.LED_Green);
   Tiny.Switch_Off (This => Tiny.LED_Red);

   Tiny.Switch_On (This => Tiny.LED_Green);

   Dip_Selector := Helpers.Eeprom_Code_Selected;

   --  check the DIP selector
   if Dip_Selector < HAL.UInt4 (EEP_DIP_Valid_Selector'First)
     or Dip_Selector > HAL.UInt4 (EEP_DIP_Valid_Selector'Last)
   then
      loop
         Tiny.Switch_Off (Tiny.LED_Green);
         Delay_Provider.Delay_MS (MS => 50);
         Tiny.Switch_On (Tiny.LED_Green);
         Delay_Provider.Delay_MS (MS => 50);
      end loop;
   end if;

   --  show value
   for Bleep in 1 .. Dip_Selector loop
      Tiny.Switch_Off (Tiny.LED_Green);
      Delay_Provider.Delay_MS (MS => 250);
      Tiny.Switch_On (Tiny.LED_Green);
      Delay_Provider.Delay_MS (MS => 250);
   end loop;

   Delay_Provider.Delay_MS (MS => 1000);
   Tiny.Switch_On (Tiny.LED_Green);

   EEP_Selected := All_DIPs (EEP_DIP_Valid_Selector (Dip_Selector));

   --  the full monty
   Helpers.
     Check_Full_Size (EEP_Selected,
                      Tiny_LED.Tiny_Led_Off'Access);

   --     --  headers involved
--     Helpers.
--       Check_Header_Only (EEPROM,
--                          Tiny_LED.Tiny_Led_Off'Access);
--     Helpers.
--       Check_Header_And_Full_Pages (EEPROM,
--                                    Tiny_LED.Tiny_Led_Off'Access);
--     Helpers.
--       Check_Header_And_Tailing (EEPROM,
--                                 Tiny_LED.Tiny_Led_Off'Access);
--     Helpers.
--       Check_Header_And_Full_Pages_And_Tailing (EEPROM,
--                                            Tiny_LED.Tiny_Led_Off'Access);
--
--     --  full pages involved
--     Helpers.
--       Check_Full_Pages (EEPROM,
--                         Tiny_LED.Tiny_Led_Off'Access);
--     Helpers.
--       Check_Full_Pages_And_Tailing (EEPROM,
--                                     Tiny_LED.Tiny_Led_Off'Access);

   loop
      Tiny.Switch_Off (Tiny.LED_Green);
      Delay_Provider.Delay_MS (MS => 500);
      Tiny.Switch_On (Tiny.LED_Green);
      Delay_Provider.Delay_MS (MS => 500);
   end loop;

end Tiny_Write_Full_And_Check;
