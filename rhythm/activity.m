function [is, iv, l5, m10, ra] = activity(ts, ts_l5, ts_m10)
% ACTIVITY Returns array of rest/activity characteristics
%
% Description:
%   The function takes a column vector of data (should be adjusted to 24 
%   hours) and calculates M10, L5, RA, IS and IV activity characteristics.
%
%   Arguments:
%     ts - timeseries of data
%
%   Results:
%     is - inter-daily stability
%     iv - intra-daily variability
%     l5 - average level at 5 least active hours
%     m10 - average level at 10 most active hours
%     ra - relative amplitude ra = (m10-l5)/(m10+l5)
%
%   Reference:
%
%   Van Someren, Eus JW, et al. "Bright light therapy: improved sensitivity
%   to its effects on rest-activity rhythms in Alzheimer patients by
%   application of nonparametric methods." Chronobiology international 16.4
%   (1999): 505-518.
%
% See also L5M10.
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

% resample to 1 minute
t_start = ceil(min(ts.Time)*24*60)/(24*60);
t_end = floor(max(ts.Time)*24*60)/(24*60);
ts_rs = resample(ts, linspace(t_start, t_end, (t_end-t_start)*24*60));

% create periodogram (skip first and last days as it may be incomplete)
t_start = ceil(min(ts_rs.Time));
t_end = floor(max(ts_rs.Time));
data24 = zeros(24*60, t_end-t_start);
for i=t_start:t_end-1,
    idx = find((ts_rs.Time >= i) & (ts_rs.Time < i+1));
    ts_24 = getsamples(ts_rs, idx);
    if length(ts_24) ~= size(data24, 1)
        fprintf(1, 'activity: missing data or not constant sampling rate\n');
    else
        data24(:,i-t_start+1) = ts_24.Data;
    end
end

% IS
n = size(data24, 1)*size(data24, 2);
p = size(data24, 2);
m = mean(mean(data24));
is = (n*sum((mean(data24,1)-m).^2))/...
        (p*sum(sum((data24-m).^2)));

% TODO: IV WRONG!!! See van Someren
n = length(ts_rs.Data);
iv = (n*sum((ts_rs.Data(2:n)-ts_rs.Data(1:n-1)).^2))/...
        ((n-1)*sum((ts_rs.Data-mean(ts_rs.Data)).^2));

if nargin == 3,
    % L5
    l5_v = zeros(length(ts_l5.Time), 1);
    for i=1:length(l5_v),
        idx = find((ts.Time >= ts_l5.Time(i)) & (ts.Time < ts_l5.Data(i)));
        ts_w = getsamples(ts, idx);
        l5_v(i) = sum(ts_w.Data);
    end
    l5 = mean(l5_v);

    % M10
    m10_v = zeros(length(ts_m10.Time), 1);
    for i=1:length(m10_v),
        idx = find((ts.Time >= ts_m10.Time(i)) & (ts.Time < ts_m10.Data(i)));
        ts_w = getsamples(ts, idx);
        m10_v(i) = sum(ts_w.Data);
    end
    m10 = mean(m10_v);

    % RA
    ra = (m10-l5)/(m10+l5);
end
