file bin/tiny_write_full_and_check
target extended-remote localhost:3333
load
break Tiny_Write_Full_And_Check
set print element 0
