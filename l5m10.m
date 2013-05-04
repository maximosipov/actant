function [l5, m10] = l5m10(data, sampling)
% ACTIVITY Mark least active 5 (l5) and most active 10 (m10) hour periods
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
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU Affero General Public License for more details.
%
% You should have received a copy of the GNU Affero General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% Description:
%   The function takes a column vector of data (should be adjusted to 24 
%   hours) and returns 2 vectors of markup with least active 5 and most
%   active 10 hours. The search is performed by looking for consequent
%   l5 minimum and m10 maximum using 18 hour window from the end of the
%   last identified segment.
%
%   Arguments:
%     data - 24 hours adjusted column vector of data
%     sampling - sampling rate in minutes
%
%   Results:
%     l5 - column vector of 5 least active hours markup
%     m10 - column vector of 10 most active hours markup
%
% See also SPLIT_24, ACTIVITY.

%     %% Load and pre-process data
%     clear all; close all;
%     addpath('lib');
%     awddata = a0_preprocess(awd_loaddir('data'));
%     data = awddata(1).data(:,1);
%     sampling = awddata(1).sampling;

    %%
    h = 60/sampling;
    l5 = false(length(data), 1);
    m10 = false(length(data), 1);

    % L5
    window = h*5;
    l5f = filter(ones(1,window),1,data');
    l5f = [l5f(h*5+1:length(l5f)), zeros(1, h*5)];

    % M10
    window = h*10;
    m10f = filter(ones(1,window),1,data');
    m10f = [m10f(h*10+1:length(m10f)), zeros(1, h*10)];

    % Find L5 and M10 locations in first 24 hours and continue searching
    % for ...-L5-M10-L5-... sequences
    i = 1;
    flook = 1:h*18;
    l5i = find(l5f(flook) == min(l5f(flook)), 1, 'first');
    m10i = find(m10f(flook) == max(m10f(flook)), 1, 'first');
    if l5i < m10i,
        next_max = true;
    else
        next_max = false;
    end
    while i+length(flook) < length(data),
        if next_max,
            l5(l5i:l5i+h*5) = true;
            % next l5 is after next m10
            flook = m10i:m10i+h*18;
            l5i = m10i + find(l5f(flook) == min(l5f(flook)), 1, 'first');
            i = l5i;
        else
            m10(m10i:m10i+h*10) = true;
            % next m10 is after next l5
            flook = l5i:l5i+h*18;
            m10i = l5i + find(m10f(flook) == max(m10f(flook)), 1, 'first');
            i = m10i;
        end
        next_max = ~next_max;
    end
    % and mark the last 24 hours
    l5e = l5i+h*5;
    if l5e > length(l5),
        l5e = length(l5);
    end
    l5(l5i:l5e) = true;
    m10e = m10i+h*10;
    if m10e > length(m10),
        m10e = length(m10);
    end
    m10(m10i:m10e) = true;
    
%     %% Plot
%     figure('Name', 'L5-M10 segmentation');
%     subplot(3,1,1); plot(data);
%     axis([0 length(data) min(data) max(data)]);
%     subplot(3,1,2); plot(l5, 'b'); hold on; plot(m10, 'r'); hold off;
%     axis([0 length(data) -1 2]);
%     subplot(3,1,3); plot(l5f, 'b'); hold on; plot(m10f, 'r'); hold off;
%     axis([0 length(data) min(l5f) max(m10f)]);

end
