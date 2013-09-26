function [l5, m10] = l5m10(ts)
% ACTIVITY Mark least active 5 (l5) and most active 10 (m10) hour periods
%
% Description:
%   The function takes timeseries and returns 2 timeseries of markup with
%   least active 5 (l5) and most active 10 (m10) hours. The search is
%   performed by looking for consequent l5 minimum and m10 maximum using 18
%   hour window from the end of the last identified segment. Assumes uneven
%   sampling, so could be quite slow...
%
%   Arguments:
%     ts - timeseries of data
%
%   Results:
%     l5 - timeseries of L5 segmentation
%     m10 - timeseries of M10 segmentation
%
% Copyright (C) 2011-2013, Maxim Osipov
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without modification,
% are permitted provided that the following conditions are met:
%
%  - Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
%  - Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
%  - Neither the name of the University of Oxford nor the names of its
%    contributors may be used to endorse or promote products derived from this
%    software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
% ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
% IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
% INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
% BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
% DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
% OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
% OF THE POSSIBILITY OF SUCH DAMAGE.
%

t_lookup = 18/24;

l5 = timeseries('L5');
l5.DataInfo.Unit = 'days';
l5.TimeInfo.Units = 'days';
l5.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

m10 = timeseries('M10');
m10.DataInfo.Unit = 'days';
m10.TimeInfo.Units = 'days';
m10.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

% resample with 1 minute resolution
t_start = ceil(min(ts.Time)*24*60)/(24*60);
t_end = floor(max(ts.Time)*24*60)/(24*60);
ts_rs = resample(ts, linspace(t_start, t_end, (t_end-t_start)*24*60));

% create sum of 5 and 10 hours timeseries
d_5 = filter(ones(1,5*60), 1, ts_rs.Data);
ts_5 = timeseries(d_5, ts_rs.Time);
d_10 = filter(ones(1,10*60), 1, ts_rs.Data);
ts_10 = timeseries(d_10, ts_rs.Time);

t_start = min(ts_rs.Time);
if (6/24 < (t_start-floor(t_start))) && ((t_start-floor(t_start)) <= 21/24),
    % 6:00 - 21:00 - look for L5, ignore first 5 hours
    l5_lookup = true;
    t_start = t_start + 5/24;
else
    % 21:00 - 6:00 - look for M10 first
    l5_lookup = false;
end
t_end = t_start + t_lookup;

while t_start < max(ts_rs.Time)-10/24,
    if (l5_lookup),
        % look for L5
        i_w = find((ts_5.Time >= t_start) & (ts_5.Time < t_end));
        ts_w = getsamples(ts_5, i_w);
        [tmp idx] = min(ts_w.Data);
        t_end = ts_w.Time(idx);
        l5 = addsample(l5, 'Data', t_end, 'Time', t_end-5/24);
        l5_lookup = false;
    else
        % look for M10
        i_w = find((ts_10.Time >= t_start) & (ts_10.Time < t_end));
        ts_w = getsamples(ts_10, i_w);
        [tmp idx] = max(ts_w.Data);
        t_end = ts_w.Time(idx);
        m10 = addsample(m10, 'Data', t_end, 'Time', t_end-10/24);
        l5_lookup = true;
    end
    t_start = t_end;
    t_end = t_start + t_lookup;
end
