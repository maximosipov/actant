function [h1, h2] = plot_activity(awddesc, is, iv, m10, l5, ra)
% PLOT_ACTIVITY Plot distributions of rest-activity characteristics
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
