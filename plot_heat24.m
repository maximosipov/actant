function h = plot_heat24(awd, data_type, h)
% PLOT_HEAT24 Plot one-dimensional array as 24-hour 'heat' map
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
%   Plot data from one-dimensional array of 24-hour periodic data
%   (actimetery, light, etc.) as a 'head' map. Due to the nature of data
%   and to eliminate effect of outliers, as a darkest color value the
%   absolute minimum is taken and as brightest mean(data)+3*std(data).
%   Data is appended with zeros to start and end at midnight.
% 
% Arguments:
%   awd - complete description of AWD data
%   data_type - type of data to plot ('activity' or 'light')
%
% Results:
%   h - figure handle
%
% See also APPEND_24, SPLIT_24, PLOT_2X24.

    if strcmp(data_type, 'activity'),
        data = awd.data(:,1);
    elseif strcmp(data_type, 'light'),
        data = awd.data(:,2);
    else
        error('PLOT_HEAT24: Unknown data type %s\n', data_type);
    end
    name = [data_type ' of ' awd.id ' from ' awd.date ' ' awd.time];
    time = awd.time;
    sampling = awd.sampling;

    data_append = append_24(data, time, sampling);
    data_split = split_24(data_append, sampling);

    if ~exist('h', 'var'),
        h = figure('Name', name);
    end
    xscalemin = ((1:length(data_split(1,:,1)'))*sampling)';
    xscalenum = datenum(2011, 1, 1, floor(xscalemin/60), mod(xscalemin,60), 0);
    imagesc(xscalenum, [1 size(data_split, 1)],...
        data_split(:,:), [min(data) mean(data)+3*std(data)]);
    colorbar;
    if strcmp(data_type, 'Activity'),
        colormap(bone);
    elseif strcmp(data_type, 'Light'),
        colormap(hot);
    end
    datetick('x', 15);
    xlabel('Time'); ylabel('Day');
    htit = title(name);
    set(htit,'Interpreter','none')
end
