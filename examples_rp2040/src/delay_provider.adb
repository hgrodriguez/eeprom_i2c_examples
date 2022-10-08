-----------------------------------------------------------------------------
--  Implementation of delay provider
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with RP.Timer;

package body Delay_Provider is

   procedure Delay_MS (MS : Integer) is
      My_Delay   : constant RP.Timer.Time
        := RP.Timer.Milliseconds (T => Natural (MS));
      My_NowTime : constant RP.Timer.Time
        := RP.Timer.Clock;

      use RP.Timer;

   begin
      if MS > 0 then
         RP.Timer.Busy_Wait_Until (Deadline => My_NowTime + My_Delay);
      end if;
   end Delay_MS;

end Delay_Provider;
