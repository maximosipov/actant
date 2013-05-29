function [l5, m10] = l5m10(data, sampling)
% ACTIVITY Mark least active 5 (l5) and most active 10 (m10) hour periods
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
