with RP.Device;
with RP.GPIO;
with RP.I2C_Master;

with Pico;

package Configuration is

   --  Definitions of the connections to the EEPROM
   Eeprom_I2C_Port : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2CM_0;
   Eeprom_SDA      : RP.GPIO.GPIO_Point renames Pico.GP0;
   Eeprom_SCL      : RP.GPIO.GPIO_Point renames Pico.GP1;

   --  Definitions for the DIP switch ports to read
   DIP_1 : RP.GPIO.GPIO_Point renames Pico.GP12;
   DIP_2 : RP.GPIO.GPIO_Point renames Pico.GP13;
   DIP_4 : RP.GPIO.GPIO_Point renames Pico.GP14;
   DIP_8 : RP.GPIO.GPIO_Point renames Pico.GP15;
end Configuration;
