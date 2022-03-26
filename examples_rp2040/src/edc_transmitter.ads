-----------------------------------------------------------------------------
--  EDC transmitter for showing values on the EDC
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with Edc_Client.LED;

package Edc_Transmitter is
   --------------------------------------------------------------------------
   --  Initializes the UART trasnmitter.
   --  This must be called before any other procedure can be called.
   --------------------------------------------------------------------------
   procedure Initialize;

   --------------------------------------------------------------------------
   --  Transmits the given LED control string to the dashboard.
   --------------------------------------------------------------------------
   procedure Transmit_LED (Control : Edc_Client.LED.LED_String);

end Edc_Transmitter;