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

   Helpers.Display_Code_Selected (Dip_Selector);

   --  check the DIP selector
   if not Helpers.Code_Selected_Is_Valid (Dip_Selector) then
      loop
         Pico.LED.Clear;
         Delay_Provider.Delay_MS (MS => 50);
         Pico.LED.Set;
         Delay_Provider.Delay_MS (MS => 50);
      end loop;
   end if;

   Delay_Provider.Delay_MS (MS => 1000);
   Pico.LED.Set;

   EEP_Selected := Helpers.All_DIPs (Helpers.
                                       EEP_DIP_Valid_Selector (Dip_Selector));

   --  the full monty
   Helpers.
     Check_Full_Size (EEP_Selected,
                      Pico_LED.Pico_Led_Off'Access);

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

   Helpers.Display_Success;
   loop
      Pico.LED.Clear;
      Delay_Provider.Delay_MS (MS => 500);
      Pico.LED.Set;
      Delay_Provider.Delay_MS (MS => 500);
   end loop;
end Pico_Write_Full_And_Check;
