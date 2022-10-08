with Pico;

package body Pico_LED is

   procedure Pico_Led_Off is
   begin
      Pico.LED.Clear;
   end Pico_Led_Off;

end Pico_LED;
