-----------------------------------------------------------------------------
--  Helpers package for different functions/procedures to minimize
--  code duplication
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL.I2C;

with RP.GPIO;
with RP.I2C_Master;

with EEPROM_I2C;

package Helpers is

   type LED_Off is access procedure;

   procedure Initialize (SDA          : in out RP.GPIO.GPIO_Point;
                         SCL          : in out RP.GPIO.GPIO_Point;
                         I2C_Port     : in out RP.I2C_Master.I2C_Master_Port;
                         Trigger_Port : RP.GPIO.GPIO_Point;
                         Frequency    : Natural);

   procedure Trigger_Enable;
   procedure Trigger_Disable;
   function Trigger_Is_Enabled return Boolean;

   procedure Wait_For_Trigger_Fired;
   procedure Wait_For_Trigger_Resume;

   procedure Fill_With (Fill_Data : out HAL.I2C.I2C_Data;
                        Byte      : HAL.UInt8 := 16#FF#);

   procedure Check_Full_Size
     (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
      CB_LED_Off : LED_Off);

   procedure Check_Header_Only
     (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
      CB_LED_Off : LED_Off);

   procedure Check_Header_And_Full_Pages
     (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
      CB_LED_Off : LED_Off);

   procedure Check_Header_And_Tailing
     (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
      CB_LED_Off : LED_Off);

   procedure Check_Header_And_Full_Pages_And_Tailing
     (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
      CB_LED_Off : LED_Off);

   procedure Check_Full_Pages
     (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
      CB_LED_Off : LED_Off);

   procedure Check_Full_Pages_And_Tailing
     (EEP        : in out EEPROM_I2C.EEPROM_Memory'Class;
      CB_LED_Off : LED_Off);

   procedure Verify_Data (Expected   : HAL.I2C.I2C_Data;
                          Actual     : HAL.I2C.I2C_Data;
                          CB_LED_Off : LED_Off);

   procedure ItsyBitsy_Led_Off;
   procedure Pico_Led_Off;
   procedure Tiny_Led_Off;

end Helpers;
