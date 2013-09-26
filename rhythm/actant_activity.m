function [ts, markup, vals] = actant_activity(data, args)
% ACTANT_ACTIVITY Wrapper function for ACTIVITY
%
% Description:
%   The function wraps sampen to provide ACTANT compatible interface.
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

ts = [];
markup = [];
vals = {};

% No arguments passed - return arguments definition
if nargin == 0,
    vals{1, 1} = '_'; vals{1, 2} = 'Non-param. Analysis';
    return;
end

% We had some arguments - perform analysis
data_arg = data.Data;

[ts_l5, ts_m10] = l5m10(data);
[is, iv, l5, m10, ra] = activity(data, ts_l5, ts_m10);

vals{1, 1} = 'IS'; vals{1, 2} = num2str(is); 
vals{2, 1} = 'IV'; vals{2, 2} = num2str(iv); 
vals{3, 1} = 'L5'; vals{3, 2} = num2str(l5); 
vals{4, 1} = 'M10'; vals{4, 2} = num2str(m10); 
vals{5, 1} = 'RA'; vals{5, 2} = num2str(ra); 

markup = timeseries('L5_M10');
markup.DataInfo.Unit = 'days';
markup.TimeInfo.Units = 'days';
markup.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

markup = addsample(markup, 'Data', ts_l5.Data, 'Time', ts_l5.Time);
markup = addsample(markup, 'Data', ts_m10.Data, 'Time', ts_m10.Time);