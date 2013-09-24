function [ts, markup, vals] = actant_sleepscoring(data, args)
% ACTANT_SLEEPSCORING Wrapper function for SLEEPSCORING
%
% Description:
%   The function wraps sleepscoring to provide ACTANT compatible interface.
%
% Arguments:
%   data - input data timeseries
%   args - Cell array of arguments
%
% Results (all optional):
%   ts - Generated timeseries
%   markup - Generated data markup
%   vals - Cell array of results
%
% When function called without arguments, array of function arguments and
% default values is returned in vals, prefixed with method name.
%
% See also SLEEPSCORING.
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

ts = [];
markup = [];
vals = {};

% No arguments passed - return arguments definition
if nargin == 0,
    vals{1, 1} = '_'; vals{1, 2} = 'SleepScoring';
    vals{2, 1} = 'Onset'; vals{2, 2} = '';
    vals{3, 1} = 'Offset'; vals{3, 2} = '';
    vals{4, 1} = 'Sensitivity'; vals{4, 2} = 'm';
    vals{5, 1} = 'Method'; vals{5, 2} = 'i';
    vals{6, 1} = 'Snooze'; vals{6, 2} = 'on';
    return;
end

% We had some arguments - perform analysis
onset_arg = datenum(args{2, 2});
offset_arg = datenum(args{3, 2});
sens_arg = args{4, 2};
method_arg = args{5, 2};
snooze_arg = args{6, 2};

if (onset_arg - floor(onset_arg) < 0.5),
    % after midnight, previous day noon
    noon1 = floor(onset_arg) - 0.5;
else
    % the same day noon
    noon1 = floor(onset_arg) + 0.5;
end
noon2 = noon1 + 1;
ts_idx =  find((data.Time > noon1) & (data.Time < noon2));
ts_val = getsamples(data, ts_idx);
data_arg = ts_val.Data;
time_arg = ts_val.Time;
epoch_arg = round((time_arg(2)-time_arg(1))*24*60*60);

[sleep, data] = sleepscoring(data_arg, time_arg,...
    onset_arg, offset_arg, epoch_arg, sens_arg, method_arg, snooze_arg);

vals{1, 1} = 'sleepOnsetLatencyMins'; vals{1, 2} = num2str(sleep.sleepOnsetLatencyMins); 
vals{2, 1} = 'sleepOnsetLatencyHours'; vals{2, 2} = num2str(sleep.sleepOnsetLatencyHours); 
vals{3, 1} = 'wakeAfterSleepOnsetMins'; vals{3, 2} = num2str(sleep.wakeAfterSleepOnsetMins); 
vals{4, 1} = 'wakeAfterSleepOnsetHours'; vals{4, 2} = num2str(sleep.wakeAfterSleepOnsetHours); 
vals{5, 1} = 'wakeAfterSleepOnsetPercent'; vals{5, 2} = num2str(sleep.wakeAfterSleepOnsetPercent); 
vals{6, 1} = 'actualSleepMins'; vals{6, 2} = num2str(sleep.actualSleepMins); 
vals{7, 1} = 'actualSleepHours'; vals{7, 2} = num2str(sleep.actualSleepHours); 
vals{8, 1} = 'actualSleepPercent'; vals{8, 2} = num2str(sleep.actualSleepPercent); 
vals{9, 1} = 'movementMins'; vals{9, 2} = num2str(sleep.movementMins); 
vals{10, 1} = 'movementPercent'; vals{10, 2} = num2str(sleep.movementPercent); 
vals{11, 1} = 'immobileMins'; vals{11, 2} = num2str(sleep.immobileMins); 
vals{12, 1} = 'immobilePercent'; vals{12, 2} = num2str(sleep.immobilePercent); 
vals{13, 1} = 'wakeBoutLengthMins'; vals{13, 2} = num2str(sleep.wakeBoutLengthMins); 
vals{14, 1} = 'wakeBoutLengthHours'; vals{14, 2} = num2str(sleep.wakeBoutLengthHours); 
vals{15, 1} = 'sleepBoutLengthMins'; vals{15, 2} = num2str(sleep.sleepBoutLengthMins); 
vals{16, 1} = 'sleepBoutLengthHours'; vals{16, 2} = num2str(sleep.sleepBoutLengthHours); 

end
