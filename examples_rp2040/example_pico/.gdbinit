file bin/pico_write_full_and_check
target extended-remote localhost:3333
load
break Pico_Write_Full_And_Check
break EEPROM_I2C.Wipe
set print element 0
