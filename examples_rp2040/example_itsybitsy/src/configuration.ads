with HAL.I2C;

with RP.GPIO;
with RP.I2C_Master;

with ItsyBitsy;

package Configuration is

   --  Definitions of the connections to the EEPROM
   Eeprom_I2C_Port : RP.I2C_Master.I2C_Master_Port renames ItsyBitsy.I2C;
   Eeprom_SDA      : RP.GPIO.GPIO_Point renames ItsyBitsy.GP26;
   Eeprom_SCL      : RP.GPIO.GPIO_Point renames ItsyBitsy.GP27;

   --  Definitions for the Pimoroni LED Matrix
   use HAL;
   Matrix_Address : constant HAL.I2C.I2C_Address := 16#61# * 2;

   --  Definitions for the DIP switch ports to read
   DIP_1 : RP.GPIO.GPIO_Point renames ItsyBitsy.GP3;
   DIP_2 : RP.GPIO.GPIO_Point renames ItsyBitsy.GP2;
   DIP_4 : RP.GPIO.GPIO_Point renames ItsyBitsy.GP0;
   DIP_8 : RP.GPIO.GPIO_Point renames ItsyBitsy.GP1;
end Configuration;
