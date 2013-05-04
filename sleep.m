%
% Returns array of rest/activity characteristics.
%
% Copyright (C) 2011 Maxim Osipov
% 
% data - column array of activity data
% time - start of measurements
% sampling - sampling rate in min
%
% son - sleep onset time
% soff - sleep offset time
% smid - sleep midpoint
% sp - sleep period
% tst - total sleep time
% sl - sleep latency
% se - sleep efficiency
% sb - sleep bouts
%


function [son, soff, smid, sp, tst, sl, se, sb] =...
        awdsleep(data, time, sampling)
    son = 0;
    soff = 0;
    smid = 0;
    tib = 0;
    sp = 0;
    tst = 0;
    sl = 0;
    se = 0;
    sb = 0;
end
