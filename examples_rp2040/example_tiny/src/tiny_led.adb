with Tiny;

package body Tiny_LED is

   procedure Tiny_Led_Off is
   begin
      Tiny.Switch_Off (This => Tiny.LED_Green);
   end Tiny_Led_Off;

end Tiny_LED;
