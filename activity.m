function [is, iv, m10, l5, ra] = activity(data, sampling)
% ACTIVITY Returns array of rest/activity characteristics
%
% Copyright (C) 2011 Maxim Osipov
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU Affero General Public License as published
% by the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Affero General Public License for more details.
%
% You should have received a copy of the GNU Affero General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
