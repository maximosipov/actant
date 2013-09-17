function [is, iv, m10, l5, ra] = activity(data, sampling)
% ACTIVITY Returns array of rest/activity characteristics
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
% Description:
%   The function takes a column vector of data (should be adjusted to 24 
%   hours) and calculates M10, L5, RA, IS and IV activity characteristics.
%
%   Arguments:
%     data - 24 hours adjusted column vector of data
%     sampling - sampling rate in minutes
%
%   Results:
%     m10 - 10 most active hours
%     l5 - 5 least active hours
%     ra - relative amplitude ra = (m10-l5)/(m10+l5)
%     is - inter-daily stability
%     iv - intra-daily variability
%
% See also SPLIT_24.

    % check input arguments
    if fix(length(data)/(24*60/sampling)) < 2,
        error('DATA shall cover at least 2 days!');
    end
    if rem(length(data), 24*60/sampling) > 0,
        error('DATA shall ba a 24 hours adjusted column vector!');
    end

    % create periodogram (skip first and last days as it may be incomplete)
    data24 = split_24(data, sampling);

    % IS
    n = size(data24, 1)*size(data24, 2);
    p = size(data24, 2);
    m = mean(mean(data24));
    is = (n*sum((mean(data24,1)-m).^2))/...
            (p*sum(sum((data24-m).^2)));

    % IV WRONG!!! See van Someren
    n = length(data);
    iv = (n*sum((data(2:n)-data(1:n-1)).^2))/...
            ((n-1)*sum((data-mean(data)).^2));

    % M10
    window = 60/sampling*10;
    m10 = mean(max(filter(ones(1,window),1,data24'),[],2));

    % L5
    window = 60/sampling*5;
    l5 = mean(min(filter(ones(1,window),1,data24'),[],2));

    % RA
    ra = (m10-l5)/(m10+l5);
end
