function [ts, vals] = actant_apply(method, args, callback)
% ACTANT_APPLY Wrapper function to apply a method to multiple data windows
%
% Description:
%   The function applies any analysis method with ACTANT interface to a
%   cell array of data windows and generates timeseries of results. Each
%   datapoint in resulting timeseries represents results of method
%   application to a window with a timestamp equal to the timestamp of the
%   last datapoint in this window.
%
%   Note: If original method returns timeseries, these is discarded.
%
% Arguments:
%   method - method to apply
%   args - cell array of input timeseries and arguments
%
% Results (all optional):
%   ts - cell array of timeseries
%   vals - cell array of results
%
% When function called without arguments, array of function arguments and
% default values is returned in vals, prefixed with the method name.
%
% See also SPLIT.
%
% Copyright (C) 2011-2014, Maxim Osipov
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

% One arguments passed - return arguments definition
if nargin == 1,
    [~, vals] = method();
    return;
end

% Create timeseries objects
a = get_args(args, 1);
[~, d] = method(a);
t = get_stamp(a);
for j=1:size(d, 2),
    ts{j} = timeseries(d{j,1});
    ts{j}.DataInfo.Unit = 'N/A';
    ts{j}.TimeInfo.Units = 'days';
    ts{j}.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    ts{j} = addsample(ts{j}, 'Data', str2num(d{j,2}), 'Time', t);
end

% Run analysis for every window and add to timeseries
for i=2:get_length(args),
    if nargin == 3,
        callback(i);
    end
    a = get_args(args, i);
    [~, d] = method(a);
    t = get_stamp(a);
    for j=1:size(d, 2),
        ts{j} = addsample(ts{j}, 'Data', str2num(d{j,2}), 'Time', t);
    end
end

return;

% Get number of timeseries in the array
function l = get_length(args)
    l = 0;
    for i=1:length(args(:,2)),
        if strcmpi(args{i,2}, 'TS'),
            l = length(args{i,3});
            return;
        end
    end

% Prepare arguments for analysis on timeseries n
function a = get_args(args, n)
    a = args;
    for i=1:length(a(:,2)),
        if strcmpi(a{i,2}, 'TS'),
            t = a{i,3};
            a{i,3} = t{n};
        end
    end

% Get timestamp for analysis resutls
function t = get_stamp(args)
    t = 0;
    for i=1:length(args(:,2)),
        if strcmpi(args{i,2}, 'TS'),
            d = args{i,3};
            t = max(d.Time);
            return;
        end
    end
