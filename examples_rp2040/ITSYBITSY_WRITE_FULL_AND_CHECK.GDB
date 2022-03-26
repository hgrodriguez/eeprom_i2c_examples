file bin/itsybitsy_write_full_and_check
target extended-remote localhost:3333
load
break ItsyBitsy_Write_Full_And_Check
set print element 0
