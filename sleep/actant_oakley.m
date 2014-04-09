function [ts, vals] = actant_oakley(args)
% ACTANT_OAKLEY Wrapper function for Oakley sleep segmentation
%
% Description:
%   The function wraps the Oakley sleep segmentation algorithm to provide
%   ACTANT compatible interface.
%
% Arguments:
%   args - Cell array of input timeseries and arguments
%
% Results (all optional):
%   ts - Cell array of timeseries
%   vals - Cell array of results
%
% When function called without arguments, array of function arguments and
% default values is returned in vals, prefixed with method name.
%
% See also OAKLEY.
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

ts = {};
vals = {};

% No arguments passed - return arguments definition
if nargin == 0,
    vals{1, 1} = '_'; vals{1, 2} = 'Sleep Consensus Diary';
    vals{2, 1} = 'ts_data'; vals{2, 2} = '1';
    vals{3, 1} = 'ts_bed_time'; vals{3, 2} = '1';
    vals{4, 1} = 'ts_lights_off'; vals{4, 2} = '1';
    vals{5, 1} = 'ts_latency'; vals{5, 2} = '1';
    vals{6, 1} = 'ts_wake_times'; vals{6, 2} = '1';
    vals{7, 1} = 'ts_wake_duration'; vals{7, 2} = '1';
    vals{8, 1} = 'ts_wake_time'; vals{8, 2} = '1';
    vals{9, 1} = 'ts_out_of_bed'; vals{9, 2} = '1';
    return;
end

% We had some arguments - perform analysis
data_arg = args{2, 2};
diary = sleep_consensus_diary(data_arg);

% Convert diary into timeseries
bed_time = timeseries('BED_TIME');
bed_time.DataInfo.Unit = 'days';
bed_time.TimeInfo.Units = 'time';
bed_time.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

lights_off = timeseries('LIGHTS_OFF');
lights_off.DataInfo.Unit = 'days';
lights_off.TimeInfo.Units = 'time';
lights_off.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

latency = timeseries('LATENCY');
latency.DataInfo.Unit = 'days';
latency.TimeInfo.Units = 'time';
latency.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

wake_times = timeseries('WAKE_TIMES');
wake_times.DataInfo.Unit = 'days';
wake_times.TimeInfo.Units = 'counts';
wake_times.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

wake_dur = timeseries('WAKE_DURATION');
wake_dur.DataInfo.Unit = 'days';
wake_dur.TimeInfo.Units = 'time';
wake_dur.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

wake_time = timeseries('WAKE_TIME');
wake_time.DataInfo.Unit = 'days';
wake_time.TimeInfo.Units = 'time';
wake_time.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

out_of_bed = timeseries('OUT_OF_BED');
out_of_bed.DataInfo.Unit = 'days';
out_of_bed.TimeInfo.Units = 'time';
out_of_bed.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

for i=1:length(size(diary, 1)),
    t = datenum(diary{i, 1}, 'dd-mm-yy');
    bed_time = addsample(bed_time, 'Data', diary{i, 2}, 'Time', t);
    lights_off = addsample(lights_off, 'Data', diary{i, 3}, 'Time', t);
    latency = addsample(latency, 'Data', diary{i, 4}, 'Time', t);
    wake_times = addsample(wake_times, 'Data', diary{i, 5}, 'Time', t);
    wake_dur = addsample(wake_dur, 'Data', diary{i, 6}, 'Time', t);
    wake_time = addsample(wake_time, 'Data', diary{i, 7}, 'Time', t);
    out_of_bed = addsample(out_of_bed, 'Data', diary{i, 8}, 'Time', t);
end

ts = {bed_time, lights_off, latency, wake_times, wake_dur, wake_time, out_of_bed};
