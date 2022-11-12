-----------------------------------------------------------------------------
--  Helpers package for different functions/procedures to minimize
--  code duplication
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL;

with RP.GPIO;

with EEPROM_I2C;

package Helpers is

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

   type LED_Off is access procedure;

   procedure Initialize (Trigger_Port : RP.GPIO.GPIO_Point;
                         Frequency    : Natural);

   procedure Trigger_Enable;
   procedure Trigger_Disable;
   function Trigger_Is_Enabled return Boolean;

   procedure Wait_For_Trigger_Fired;
   procedure Wait_For_Trigger_Resume;

   function Eeprom_Code_Selected return HAL.UInt4;

   function Code_Selected_Is_Valid (Code : HAL.UInt4) return Boolean;

   procedure Display_Code_Selected (Code : HAL.UInt4);

   procedure Display_Failure;
   procedure Display_Success;

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
