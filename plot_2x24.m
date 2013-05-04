function h = plot_2x24(awd, n1, n2, h)
% PLOT_2x24 Plot actimetry and light data on 24 hours multi-day plot
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
%   Plot the data from the 3-dimensional array of actimetery and light
%   data on a multi-day 24-hours plot.
% 
% Arguments:
%   awd - AWD data structure
%   n1 - first day to plot
%   n2 - last day to plot
%
% Results:
%   h - figure handle
%
% See also APPEND_24, SPLIT_24, PLOT_HEAT24.

    data = awd.data;
    name = [awd.id ' ' awd.date ' ' awd.time];
    time = awd.time;
    sampling = awd.sampling;

    data_append = append_24(data, time, sampling);
    data_split = split_24(data_append, sampling);

    if n1 > size(data_split, 1) || n2 > size(data_split, 1) || n2 <= n1,
        error('PLOT_2X24: Invalid interval from %i to %i\n', n1, n2);
    end

    if ~exist('h', 'var'),
        h = figure('Name', name);
    end
    xscalemin = ((1:length(data_split(1,:,1)'))*sampling)';
    xscalenum = datenum(2011, 1, 1, floor(xscalemin/60), mod(xscalemin,60), 0);
    for i = n1:n2,
        subplot(n2-n1+1, 1, i-n1+1);
        [AX,H1,H2] = plotyy(xscalenum, data_split(i,:,1)',...
               xscalenum, data_split(i,:,2)',...
              'plot', 'plot');
        datetick(AX(1), 'x', 15);
        datetick(AX(2), 'x', 15);
        xlabel('Time');
        set(get(AX(1),'Ylabel'),'String','Activity');
        set(get(AX(2),'Ylabel'),'String','Light');
        set(AX(1),'YColor','b');
        set(AX(2),'YColor','r');
        set(AX(2),'YDir','reverse');
        set(H1,'Color','b');
        set(H2,'Color','r');
        title(['Day ', num2str(i)]);
    end
end
