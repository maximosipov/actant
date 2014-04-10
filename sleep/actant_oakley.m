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
    vals{1, 1} = '_';               vals{1, 2} = 'STR'; vals{1, 3} = 'Sleep Analysis';
    vals{2, 1} = 'Data';            vals{2, 2} = 'TS';  vals{2, 3} = '1';
    vals{3, 1} = 'Algorithm';       vals{3, 2} = 'STR'; vals{3, 3} = 'oakley';
    vals{4, 1} = 'Method';          vals{4, 2} = 'STR'; vals{4, 3} = 'i';
    vals{5, 1} = 'Sensitivity';     vals{5, 2} = 'STR'; vals{5, 3} = 'm';
    vals{6, 1} = 'Snooze';          vals{6, 2} = 'STR'; vals{6, 3} = 'on';
    vals{7, 1} = 'Time window';     vals{7, 2} = 'NUM'; vals{7, 3} = 10; 
    vals{8, 1} = 'Bed Time';        vals{8, 2} = 'TS';  vals{8, 3} = '2';
    vals{9, 1} = 'Lights Off';      vals{9, 2} = 'TS';  vals{9, 3} = '3';
    vals{10, 1} = 'Latency';        vals{10, 2} = 'TS'; vals{10, 3} = '4';
    vals{11, 1} = 'Wake Times';     vals{11, 2} = 'TS'; vals{11, 3} = '5';
    vals{12, 1} = 'Wake Duration';  vals{12, 2} = 'TS'; vals{12, 3} = '6';
    vals{13, 1} = 'Wake Time';      vals{13, 2} = 'TS'; vals{13, 3} = '7';
    vals{14, 1} = 'Out of Bed';     vals{14, 2} = 'TS'; vals{14, 3} = '8';
    return;
end

% We had some arguments - prepare it for analysis
data_arg = args{2, 3};
args1 = args(3:7, [1 3]);
args2 = {};
for i=1:length(args{8,3}.Time),
    args2{i,1} = datestr(args{8,3}.Time(i), 'dd-mm-yy');
    for j=8:14,
        args2{i,j-6} = args{j,3}.Data(i);
    end
end

[ts{1}, vals] = oakley(data_arg, args1, args2);
