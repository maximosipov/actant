function [ts, vals] = actant_sampen_w(args)
% ACTANT_SAMPEN_W Wrapper function for SAMPEN with windows
%
% Description:
%   The function wraps sampen windowed analysis to provide an ACTANT
%   compatible interface.
%
% Arguments:
%   args - cell array of input timeseries and arguments
%
% Results (all optional):
%   ts - cell array of timeseries
%   vals - cell array of results
%
% When function called without arguments, array of function arguments and
% default values is returned in vals, prefixed with method name.
%
% See also SAMPEN.
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
    [~, vals] = actant_apply(@actant_sampen);
    vals{1, 1} = '_'; vals{1, 2} = 'SampEnW';
    vals{end+1, 1} = 'window'; vals{end, 2} = num2str(24*60*60);
    return;
end

% Find window length
w_arg = str2double(args{5, 2});
if isnan(w_arg) || ~isreal(w_arg),
    errordlg('Arguments shall be numeric!', 'Error', 'modal');
    return;
end

% Split timeseries arguments
for i=1:length(args(:,1)),
    if strncmpi(args{i,1}, 'ts_', 3),
        args{i,2} = split(args{i,2}, w_arg);
    end
end

[ts, vals] = actant_apply(@actant_sampen, args(1:end-1,:));

end
