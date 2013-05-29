function h = plot_heat24(awd, data_type, h)
% PLOT_HEAT24 Plot one-dimensional array as 24-hour 'heat' map
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
