with RP.GPIO;
with RP.I2C_Master;

with Tiny;

package Configuration is

   --  Definitions of the connections to the EEPROM
   Eeprom_I2C_Port : RP.I2C_Master.I2C_Master_Port renames Tiny.I2C_1;
   Eeprom_SDA      : RP.GPIO.GPIO_Point renames Tiny.GP26;
   Eeprom_SCL      : RP.GPIO.GPIO_Point renames Tiny.GP27;

   --  Definitions for the DIP switch ports to read
   DIP_1 : RP.GPIO.GPIO_Point renames Tiny.GP4;
   DIP_2 : RP.GPIO.GPIO_Point renames Tiny.GP5;
   DIP_4 : RP.GPIO.GPIO_Point renames Tiny.GP6;
   DIP_8 : RP.GPIO.GPIO_Point renames Tiny.GP7;
end Configuration;
