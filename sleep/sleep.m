function [ts, markup, vals] = sleep(data, args)
% SLEEP Convert the raw ACC to actigraphic counts and score and markup as sleep/wake
%
% Description:
%   The function wraps sleepscoring to provide ACTANT compatible interface.
%   
%
% Arguments:
%   data - input data timeseries
%   args - Cell array of arguments

% %   sleep diary
% %   epoch - epoch length (s): 
% %       15s (default), 30s, 60s, 120
% %   sensitivity - sensitivity of algorithm: 
% %       'l' (low), 'm' (medium, default) or 'h' (high)
% %   method - method of sleep onset calculation: 
% %       'i' (immobility, default), 's' (sleep/wake), 'none' (no estimation)
% %   snooze - whether to use the algorithm to calculate final wake time:
% %   'on' (default) or 'off'
%
% Results (all optional):
%   ts - Generated timeseries
%   markup - Generated data markup
%   vals - Cell array of results
%
% Copyright (c) 2011-2013 Bart te Lindert
%
% See also: te Lindert BHW; Van Someren EJW. Sleep estimates using
%           microelectromechanical systems (MEMS). SLEEP 2013;
%           36(5):781-789
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



end