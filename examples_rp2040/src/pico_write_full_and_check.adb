-----------------------------------------------------------------------------
--  Implementation of writing the full EEPROM using I2C
--  Pico version
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with RP.Device;
with RP.GPIO;
with RP.I2C_Master;

with Pico;

with Delay_Provider;
with EEPROM_I2C.MC24XX01;
--  with EEPROM_I2C.MC24XX16;

with Helpers;

procedure Pico_Write_Full_And_Check is

   --  Definitions of the connections to the EEPROM
   Eeprom_I2C_Port : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2C_0;

   --  potential test targets
   Eeprom_1K       : EEPROM_I2C.MC24XX01.EEPROM_Memory_MC24XX01
     (Delay_Provider.Delay_MS'Access,
      EEPROM_I2C.MC24XX01.I2C_DEFAULT_ADDRESS,
      Eeprom_I2C_Port'Access);
--     Eeprom_16K       : EEPROM_I2C.MC24XX16.EEPROM_Memory_MC24XX16
--       (Delay_Provider.Delay_MS'Access,
--        EEPROM_I2C.MC24XX16.I2C_DEFAULT_ADDRESS,
--        Eeprom_I2C_Port'Access);

   Eeprom_SDA       : RP.GPIO.GPIO_Point renames Pico.GP0;
   Eeprom_SCL       : RP.GPIO.GPIO_Point renames Pico.GP1;

   --  Trigger button when to read/write the byte from the EEPROM
   --  This trigger is generated using a function generator
   --    providing a square signal with a settable frequency
   Button       : RP.GPIO.GPIO_Point renames Pico.GP16;

   --  EEPROM under test
   --  renames help to minimize the changes in the code below
   EEPROM : EEPROM_I2C.EEPROM_Memory'Class := Eeprom_1K;

begin
   Helpers.Initialize (Eeprom_SDA,
                       Eeprom_SCL,
                       Eeprom_I2C_Port,
                       Button,
                       Pico.XOSC_Frequency);

   --  as always, visual help is appreciated
   Pico.LED.Configure (RP.GPIO.Output);

   --  just some visual help
   Pico.LED.Set;

   Helpers.
     Check_Full_Size (EEPROM,
                      Helpers.Pico_Led_Off'Access);

   --  headers involved
   Helpers.
     Check_Header_Only (EEPROM,
                        Helpers.Pico_Led_Off'Access);
   Helpers.
     Check_Header_And_Full_Pages (EEPROM,
                                  Helpers.Pico_Led_Off'Access);
   Helpers.
     Check_Header_And_Tailing (EEPROM,
                               Helpers.Pico_Led_Off'Access);
   Helpers.
     Check_Header_And_Full_Pages_And_Tailing (EEPROM,
                                              Helpers.Pico_Led_Off'Access);

   --  full pages involved
   Helpers.
     Check_Full_Pages (EEPROM,
                       Helpers.Pico_Led_Off'Access);
   Helpers.
     Check_Full_Pages_And_Tailing (EEPROM,
                                   Helpers.Pico_Led_Off'Access);
end Pico_Write_Full_And_Check;
