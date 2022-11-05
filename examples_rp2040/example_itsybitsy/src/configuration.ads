with RP.GPIO;
with RP.I2C_Master;

with ItsyBitsy;

package Configuration is

   --  Definitions of the connections to the EEPROM
   Eeprom_I2C_Port : RP.I2C_Master.I2C_Master_Port renames ItsyBitsy.I2C;
   Eeprom_SDA      : RP.GPIO.GPIO_Point renames ItsyBitsy.GP26;
   Eeprom_SCL      : RP.GPIO.GPIO_Point renames ItsyBitsy.GP27;

   --  Definitions for the DIP switch ports to read
   DIP_1 : RP.GPIO.GPIO_Point renames ItsyBitsy.GP18;
   DIP_2 : RP.GPIO.GPIO_Point renames ItsyBitsy.GP19;
   DIP_4 : RP.GPIO.GPIO_Point renames ItsyBitsy.GP20;
   DIP_8 : RP.GPIO.GPIO_Point renames ItsyBitsy.GP12;
end Configuration;
