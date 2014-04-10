function [ts, vals] = actant_mse(args)
% ACTANT_SAMPEN Wrapper function for SAMPEN
%
% Description:
%   The function wraps MSE to provide ACTANT compatible interface.
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
% See also SAMPEN.
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
    vals{1, 1} = '_';       vals{1, 2} = 'STR'; vals{1, 3} = 'MSE';
    vals{2, 1} = 'Data';    vals{2, 2} = 'TS';  vals{2, 3} = '1';
    vals{3, 1} = 'm';       vals{3, 2} = 'NUM'; vals{3, 3} = '2';
    vals{4, 1} = 'r';       vals{4, 2} = 'NUM'; vals{4, 3} = '0.2';
    vals{5, 1} = 'Scales Vector'; vals{5, 2} = 'STR'; vals{5, 3} = '1,2,3,4,5,6,7,8,9,10';
    return;
end

% We had some arguments - perform analysis
data_arg = args{2, 3}.Data;
m_arg = str2num(args{3, 3});
r_arg = str2num(args{4, 3});
scales_arg = str2num(args{5, 3});

[entropy, ~] = mse(data_arg, m_arg, r_arg, scales_arg);

for i=1:length(entropy),
    vals{i, 1} = ['SampEn[' num2str(i) ']'];
    vals{i, 2} = num2str(entropy(i)); 
end

end
