function h = plot_days(h, start, plots, days, overlap, tsl, tsr, tsm, liml, limr)
% PLOT_DAYS yyplot with markup with multiple subplots and overlap
%
% Description:
%   Plot data from timeseries on left axis, right axis and patches on a
%   figure with 'plots' subplots each of 'days' days and with 'overlap'
%   days overlap.
% 
% Arguments:
%   h - figure handle
%   start - starting datenum (will be rounded down to midnight)
%   plots - number of plots to display
%   days - days on a single plot
%   overlap - days of overlap between subsequent plots
%   tsl - timeseries for left axis
%   tsr - timeseries for right axis (optional)
%   tsm - timeseries for markup (optional)
%   liml - left limits [low high] (optional)
%   limr - right limits [low high] (optional)
%
% Results:
%   h - figure handle
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

hw = waitbar(0, 'Please wait while the plot is updated...');

if ~exist('h', 'var'),
    h = figure;
else
    f = h;
    while ~isempty(f) && ~strcmp('figure', get(f,'type')),
        f = get(f, 'parent');
    end
    set(0, 'currentfigure', f);
    set(f, 'Renderer', 'zbuffer');
end
if nargin < 4,
    error('Not enough arguments');
end
if ~exist('liml', 'var') || isempty(liml),
    lylim = [min(min(tsl.Data)) max(max(tsl.Data))];
else
    lylim = liml;
end
if exist('tsr', 'var') && ~isempty(tsr),
    if ~exist('limr', 'var') || isempty(limr),
        rylim = [min(min(tsr.Data)) max(max(tsr.Data))];
    else
        rylim = limr;
    end
end


for i = 1:plots,
    ah = subplot_tight(plots, 1, i, [0.005 0.01]);
    % Get data subset
    t1 = floor(start + (i-1)*days - i*overlap);
    t2 = floor(start + i*days - i*overlap);
    tvld = find((tsl.Time > t1) & (tsl.Time < t2));
    tsld = getsamples(tsl, tvld);
    tsld_t = tsld.Time;
    tsld_d = tsld.Data;
    if isempty(tsld_t),
        tsld_t = [t1];
        tsld_d = [NaN];
    end
    if ~exist('tsr', 'var') || isempty(tsr),
        % Plot single axes
        H1 = stem(ah, tsld_t, tsld_d, 'filled', 'k', 'MarkerSize', 1);
        AX = gca;
        xlim(AX, [t1 t2]);
        ylim(AX, lylim);
        datetick(AX, 'x', 15, 'keeplimits');
        if (i < plots),
            set(AX, 'XTickLabel', '');
        end
        set(AX, 'YTickLabel', '');
        set(AX,'YColor','k');
        h = text((t1+t2)/2, (lylim(1)+lylim(2))/2,...
            [datestr(t1, 'dd-mmm-yyyy (ddd)') ' - ' datestr(t2-1, 'dd-mmm-yyyy (ddd)')],...
            'Color', [0.5 0.5 0.5],...
            'VerticalAlignment', 'middle',...
            'HorizontalAlignment', 'center');
        uistack(h, 'top');
    else
        % Plot double axes
        tvrd = find((tsr.Time > t1) & (tsr.Time < t2));
        tsrd = getsamples(tsr, tvrd);
        tsrd_t = tsrd.Time;
        tsrd_d = tsrd.Data;
        if isempty(tsrd_t),
            tsrd_t = [t1];
            tsrd_d = [NaN];
        end
        [AX,H1,H2] = plotyy(ah, tsld_t, tsld_d,...
                            tsrd_t, tsrd_d,...
                            'stem', 'stem');
        xlim(AX(1), [t1 t2]);
        xlim(AX(2), [t1 t2]);
        ylim(AX(1), lylim);
        ylim(AX(2), rylim);
        set(AX(1), 'box', 'off')
        set(AX(2), 'box', 'off')
        datetick(AX(1), 'x', 15, 'keeplimits');
        datetick(AX(2), 'x', 15, 'keeplimits');
        if (i < plots),
            set(AX(1), 'XTickLabel', '');
            set(AX(2), 'XTickLabel', '');
        end
        set(AX(1), 'YTickLabel', '');
        set(AX(2), 'YTickLabel', '');
        set(AX(1),'YColor','k');
        set(AX(2),'YColor','r');
        set(AX(2),'YDir','reverse');
        set(H1,'Color','k');
        set(H1,'MarkerSize', 1);
        set(H2,'Color','r');
        set(H2,'MarkerSize', 1);
        h = text((t1+t2)/2, (lylim(1)+lylim(2))/2,...
            [datestr(t1, 'dd-mmm-yyyy (ddd)') ' - ' datestr(t2-1, 'dd-mmm-yyyy (ddd)')],...
            'Color', [0.5 0.5 0.5],...
            'VerticalAlignment', 'middle',...
            'HorizontalAlignment', 'center');
        uistack(h, 'top');
    end
    % Plot markup
    % TODO - we plot all markup currently, some not visible, but want just a subset
    if exist('tsm', 'var') && ~isempty(tsm),
        tvmd = find((tsm.Time > t1-1) & (tsm.Time < t2+1));
        tsmd = getsamples(tsm, tvmd);
        if ~isempty(tsmd.Time),
            patch_x = [tsmd.Time'; tsmd.Data'; tsmd.Data'; tsmd.Time'];
            patch_y = zeros(size(patch_x));
            patch_y(3, :) = lylim(2);
            patch_y(4, :) = lylim(2);
            H = patch(patch_x, patch_y, [1, 1, 0]);
            set(H, 'edgecolor', 'none');
            uistack(H, 'bottom');
            xlim([t1 t2]);
            set(H, 'Clipping', 'on');
        end
    end
    waitbar(i/plots, hw);
end

waitbar(1, hw);
close(hw);

