-----------------------------------------------------------------------------
--  Helpers package for different functions/procedures to minimize
--  code duplication
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with RP.GPIO;

with EEPROM_I2C;

package Helpers is

   type LED_Off is access procedure;

   procedure Initialize (Trigger_Port : RP.GPIO.GPIO_Point;
                         Frequency    : Natural);

   procedure Trigger_Enable;
   procedure Trigger_Disable;
   function Trigger_Is_Enabled return Boolean;

   procedure Wait_For_Trigger_Fired;
   procedure Wait_For_Trigger_Resume;

   procedure Check_Full_Size (EEP_Enum   : EEPROM_I2C.EEPROM_Chip;
                              CB_LED_Off : LED_Off);

   --     procedure Check_Header_Only
   --       (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
   --        CB_LED_Off : LED_Off);
   --
   --     procedure Check_Header_And_Full_Pages
   --       (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
   --        CB_LED_Off : LED_Off);
   --
   --     procedure Check_Header_And_Tailing
   --       (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
   --        CB_LED_Off : LED_Off);
   --
   --     procedure Check_Header_And_Full_Pages_And_Tailing
   --       (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
   --        CB_LED_Off : LED_Off);
   --
   --     procedure Check_Full_Pages
   --       (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
   --        CB_LED_Off : LED_Off);
   --
   --     procedure Check_Full_Pages_And_Tailing
   --       (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
   --        CB_LED_Off : LED_Off);

end Helpers;
