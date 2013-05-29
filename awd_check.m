%
% Check validity of input data and print diagnostic information.
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
% awddata - input array with the following elements
%   {1} file - file name
%   {2} condition - 'sz', 'ctl', 'afd', 'afdh', 'afdl'
%   {3} subject - textual subject ID
%   {4} comment - textual comment, usually name of originator
%   {5} id - study-specific measurement ID
%   {6} date - measurement start date
%   {7} time - measurement start time
%   {8} sampling - sampling rate in min (only 1 and 2 are valid values)
%   {9} age - person age
%   {10} watch - watch serial number
%   {11} sex - person sex
%   {12} data - actual data
%


function awdcheck(awddata)
    for i = 1:length(awddata),
        if strcmp(awddata(i).sex, 'M') == 0,
            if strcmp(awddata(i).sex, 'F') == 0;
                fprintf(1, '%s: sex %s\n', awddata(i).file, awddata(i).sex);
            end
        end
    end
end
