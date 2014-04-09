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
    vals{1, 1} = '_';               vals{1, 2} = 'Sleep Analysis';
    vals{2, 1} = 'ts_data';         vals{2, 2} = '1';
    vals{3, 1} = 'Algorithm';       vals{3, 2} = 'oakley';
    vals{4, 1} = 'Method';          vals{4, 2} = 'i';
    vals{5, 1} = 'Sensitivity';     vals{5, 2} = 'm';
    vals{6, 1} = 'Snooze';          vals{6, 2} = 'on';
    vals{7, 1} = 'Time window';     vals{7, 2} = 10; 
    vals{8, 1} = 'ts_bed_time';        vals{8, 2} = '1';
    vals{9, 1} = 'ts_lights_off';      vals{9, 2} = '1';
    vals{10, 1} = 'ts_latency';        vals{10, 2} = '1';
    vals{11, 1} = 'ts_wake_times';     vals{11, 2} = '1';
    vals{12, 1} = 'ts_wake_duration';  vals{12, 2} = '1';
    vals{13, 1} = 'ts_wake_time';      vals{13, 2} = '1';
    vals{14, 1} = 'ts_out_of_bed';     vals{14, 2} = '1';
    return;
end

% We had some arguments - prepare it for analysis
data_arg = args{2, 2};
args1 = args(3:7, :);
args2 = {};
for i=1:length(args{8,2}.Time),
    args2{i,1} = datestr(args{8,2}.Time(i), 'dd-mm-yy');
    for j=8:14,
        args2{i,j-6} = args{j,2}.Data(i);
    end
end

[ts{1}, vals] = oakley(data_arg, args1, args2);
