-----------------------------------------------------------------------------
--  Implementation of writing the full EEPROM using I2C
--  ItsyBitsy version
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL;

with RP.GPIO;

with ItsyBitsy;
with ItsyBitsy_LED;

with Delay_Provider;

with EEPROM_I2C;

with Helpers;

procedure ItsyBitsy_Write_Full_And_Check is

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
   Button       : RP.GPIO.GPIO_Point renames ItsyBitsy.GP1;

begin
   Helpers.Initialize (Button,
                       ItsyBitsy.XOSC_Frequency);

   --  as always, visual help is appreciated
   ItsyBitsy.LED.Configure (RP.GPIO.Output);

   --  just some visual help
   ItsyBitsy.LED.Set;

   Dip_Selector := Helpers.Eeprom_Code_Selected;

   --  check the DIP selector
   if Dip_Selector < HAL.UInt4 (EEP_DIP_Valid_Selector'First)
     or Dip_Selector > HAL.UInt4 (EEP_DIP_Valid_Selector'Last)
   then
      loop
         ItsyBitsy.LED.Clear;
         Delay_Provider.Delay_MS (MS => 50);
         ItsyBitsy.LED.Set;
         Delay_Provider.Delay_MS (MS => 50);
      end loop;
   end if;

   --  show value
   Delay_Provider.Delay_MS (MS => 1000);
   ItsyBitsy.LED.Clear;
   Delay_Provider.Delay_MS (MS => 1000);
   for Bleep in 1 .. Dip_Selector loop
      ItsyBitsy.LED.Set;
      Delay_Provider.Delay_MS (MS => 250);
      ItsyBitsy.LED.Clear;
      Delay_Provider.Delay_MS (MS => 250);
   end loop;

   Delay_Provider.Delay_MS (MS => 1000);
   ItsyBitsy.LED.Set;

   EEP_Selected := All_DIPs (EEP_DIP_Valid_Selector (Dip_Selector));

   --  the full monty
   Helpers.
     Check_Full_Size (EEP_Selected,
                      ItsyBitsy_LED.ItsyBitsy_Led_Off'Access);

--     --  headers involved
--     Helpers.
--       Check_Header_Only (EEPROM,
--                          ItsyBitsy_LED.ItsyBitsy_Led_Off'Access);
--     Helpers.
--       Check_Header_And_Full_Pages (EEPROM,
--                                    ItsyBitsy_LED.ItsyBitsy_Led_Off'Access);
--     Helpers.
--       Check_Header_And_Tailing (EEPROM,
--                                 ItsyBitsy_LED.ItsyBitsy_Led_Off'Access);
--     Helpers.
--       Check_Header_And_Full_Pages_And_Tailing (EEPROM,
--                                                ItsyBitsy_LED.
--                                                  ItsyBitsy_Led_Off'Access);
--
--     --  full pages involved
--     Helpers.
--       Check_Full_Pages (EEPROM,
--                         ItsyBitsy_LED.ItsyBitsy_Led_Off'Access);
--     Helpers.
--       Check_Full_Pages_And_Tailing (EEPROM,
--                                     ItsyBitsy_LED.ItsyBitsy_Led_Off'Access);

   loop
      ItsyBitsy.LED.Clear;
      Delay_Provider.Delay_MS (MS => 500);
      ItsyBitsy.LED.Set;
      Delay_Provider.Delay_MS (MS => 500);
   end loop;

end ItsyBitsy_Write_Full_And_Check;
