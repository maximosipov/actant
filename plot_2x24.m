function h = plot_2x24(awd, n1, n2, h)
% PLOT_2x24 Plot actimetry and light data on 24 hours multi-day plot
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
