function [ts, vals] = actant_l5m10(args)
% ACTANT_L5M10 Wrapper function for L5M10
%
% Description:
%   The function wraps Least Active 5 hours and Most Active 10 hours
%   activity segmentation method to provide ACTANT compatible interface.
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
% See also L5M10.
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
    vals{1, 1} = '_';       vals{1, 2} = 'STR'; vals{1, 3} = 'L5/M10';
    vals{2, 1} = 'Data';    vals{2, 2} = 'TS';  vals{2, 3} = '1';
    return;
end

% We had some arguments - perform analysis
data_arg = args{2, 3};

[ts{1} ts{2}] = l5m10(data_arg);
