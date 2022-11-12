with HAL.I2C;

with RP.Device;
with RP.GPIO;
with RP.I2C_Master;

with Pico;

package Configuration is

   --  Definitions of the connections to the EEPROM
   Eeprom_I2C_Port : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2CM_0;
   Eeprom_SDA      : RP.GPIO.GPIO_Point renames Pico.GP0;
   Eeprom_SCL      : RP.GPIO.GPIO_Point renames Pico.GP1;

   --  Definitions for the Pimoroni LED Matrix
   use HAL;
   Matrix_Address : constant HAL.I2C.I2C_Address := 16#62# * 2;

   --  Definitions for the DIP switch ports to read
   DIP_1 : RP.GPIO.GPIO_Point renames Pico.GP19;
   DIP_2 : RP.GPIO.GPIO_Point renames Pico.GP18;
   DIP_4 : RP.GPIO.GPIO_Point renames Pico.GP17;
   DIP_8 : RP.GPIO.GPIO_Point renames Pico.GP16;
end Configuration;
