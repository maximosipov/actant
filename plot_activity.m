function [h1, h2] = plot_activity(awddesc, is, iv, m10, l5, ra)
% PLOT_ACTIVITY Plot distributions of rest-activity characteristics
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
%   Plot distributions of rest-activity characteristics as scatter plot and
%   boxplot of normalized (zscore) data.
%
%   Arguments:
%     awddesc - descriptors of records
%     m10 - 10 most active hours
%     l5 - 5 least active hours
%     ra - relative amplitude ra = (m10-l5)/(m10+l5)
%     is - inter-daily stability
%     iv - intra-daily variability
%
%   Results:
%     h1, h2 - handles of plot figures
%
% See also ACTIVITY.

    %% Compare activity patterns
    h1 = figure('Name', 'Rest-activity characteristics (comparison)',...
        'Position', [0 0 640 480]);

    subplot(1,2,1);
    hold on;
    sel = awddesc.cond.sz;
    scatter(m10(sel), l5(sel), 'xr');
    sel = awddesc.cond.ctl;
    scatter(m10(sel), l5(sel), 'ob');
    hold off;
    xlabel('Most active 10 hours'); ylabel('Least active 5 hours');
    legend('Schizophrenia', 'Controls');
    title('Activity levels');

    subplot(1,2,2);
    hold on;
    sel = awddesc.cond.sz;
    scatter(is(sel), iv(sel), 'xr');
    sel = awddesc.cond.ctl;
    scatter(is(sel), iv(sel), 'ob');
    hold off;
    xlabel('Inter-daily stability'); ylabel('Intra-daily variability');
    legend('Schizophrenia', 'Controls');
    title('Activity variations');

    % Boxplot of all activity metrics
    l5s = zscore(l5);
    m10s = zscore(m10);
    ras = zscore(ra);
    ivs = zscore(iv);
    iss = zscore(is);
    acts = [l5s, m10s, ras, ivs, iss];
    counts = 1:5;

    h2 = figure('Name', 'Normalized rest-activity characteristics',...
        'Position', [0 0 640 480]);
    hold on;
    boxplot(acts(awddesc.cond.sz, counts), counts,...
        'positions', counts-0.2,...
        'plotstyle', 'traditional',...
        'boxstyle', 'filled',...
        'widths', 0.3,...
        'notch', 'on',...
        'symbol', 'r+',...
        'colors', 'r');
    boxplot(acts(awddesc.cond.ctl, counts), counts,...
        'positions', counts+0.2,...
        'plotstyle', 'traditional',...
        'widths', 0.3,...
        'notch', 'on',...
        'symbol', 'b*',...
        'colors', 'b');
    axis([0 6 -3 4]);
    set(gca,'XTickLabel',{' '; 'L5';'M10';'RA';'IV';'IS'; ' '})
    xlabel('Normalized rest-activity characteristics');
    ylabel('Value');
    title('Name');
end
