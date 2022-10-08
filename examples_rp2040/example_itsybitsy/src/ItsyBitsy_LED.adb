with ItsyBitsy;

package body ItsyBitsy_LED is

   procedure ItsyBitsy_Led_Off is
   begin
      ItsyBitsy.LED.Clear;
   end ItsyBitsy_Led_Off;

end ItsyBitsy_LED;
