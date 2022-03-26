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
      My_Delay : RP.Timer.Delays;
   begin
      if MS > 0 then
         RP.Timer.Delay_Milliseconds (This => My_Delay,
                                      Ms   => MS);
      end if;
   end Delay_MS;

end Delay_Provider;
