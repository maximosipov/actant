function [ts, vals] = actant_activity_w(data, args)
% ACTANT_ACTIVITY_W Wrapper function for ACTIVITY with windows
%
% Description:
%   The function wraps non-parametric windowed analysis to provide an
%   ACTANT compatible interface.
%
% Arguments:
%   data - input data timeseries
%   args - cell array of arguments
%
% Results (all optional):
%   ts - cell array of timeseries
%   vals - cell array of results
%
% When function called without arguments, array of function arguments and
% default values is returned in vals, prefixed with method name.
%
% See also ACTIVITY.
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

% No arguments passed - return arguments definition
if nargin == 0,
    [~, vals] = actant_apply(@actant_activity);
    vals{1, 1} = '_';           vals{1, 2} = 'STR'; vals{1, 3} = 'Non Param. W';
    vals{end+1, 1} = 'window';  vals{end, 2} = 'NUM'; vals{end, 3} = num2str(7*24*60*60);
    return;
end

% We had some arguments - split data to windows and perform analysis
w_arg = str2double(args{4, 3});
if isnan(w_arg) || ~isreal(w_arg),
    errordlg('Arguments shall be numeric!', 'Error', 'modal');
    return;
end
data_arg = split(data, w_arg);

[ts, vals] = actant_apply(@actant_sampen, data_arg, args(1:end-1,:));

end
