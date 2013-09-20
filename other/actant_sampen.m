function [ts, markup, vals] = actant_sampen(data, args)
% ACTANT_SAMPEN Wrapper function for SAMPEN
%
% Description:
%   The function wraps sampen to provide ACTANT compatible interface.
%
% Arguments:
%   ts - input data timeseries
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
    vals{1, 1} = 'Method'; vals{1, 2} = 'SampEn';
    vals{2, 1} = 'm'; vals{2, 2} = '2';
    vals{3, 1} = 'r'; vals{3, 2} = '0.2';
    return;
end

% We had some arguments - perform analysis
data_arg = data.Data;
m_arg = str2num(args{2, 2});
r_arg = str2num(args{3, 2});

[entropy, conf95] = sampen(data_arg, m_arg, r_arg);

vals{1, 1} = 'SampEn'; vals{1, 2} = num2str(entropy); 
vals{2, 1} = '95% conf. int.'; vals{2, 2} = num2str(conf95); 

end
