function [ts, markup, vals] = sleep(acc_z, header, args)
% SLEEP Convert the raw ACC to actigraphic counts and markup epochs as sleep/wake
%
% Description:
%   The function wraps sleepscoring to provide ACTANT compatible interface.
%   
%
% Arguments:
%   data - input data timeseries
%   args - Cell array of arguments

% %   sleep diary
% %   epoch - epoch length (s): 
% %       15s (default), 30s, 60s, 120
% %   sensitivity - sensitivity of algorithm: 
% %       'l' (low), 'm' (medium, default) or 'h' (high)
% %   method - method of sleep onset calculation: 
% %       'i' (immobility, default), 's' (sleep/wake), 'none' (no estimation)
% %   snooze - whether to use the algorithm to calculate final wake time:
% %   'on' (default) or 'off'
%
% Results (all optional):
%   ts - Generated timeseries
%   markup - Generated data markup
%   vals - Cell array of results
%
% Copyright (c) 2011-2013 Bart te Lindert
%
% See also: te Lindert BHW; Van Someren EJW. Sleep estimates using
%           microelectromechanical systems (MEMS). SLEEP 2013;
%           36(5):781-789
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

%% PRE-PROCESSING
% get sampling frequency
fs = header{3,1}.Measurement_Frequency;

% set filter specifications
cf_low = 3;             % lower cut off frequency (Hz)
cf_hi = 11;             % high cut off frequency (Hz)
order = 5;              % filter order
pass = 'bandpass';      % filter type
w1 = cf_low/(fs/2);     % normalized frequency low
w2 = cf_hi/(fs/2);      % normalized frequency high
[b, a] = butter(order,[w1 w2],pass); 

% filter z data only
z_filt = filtfilt(b, a, acc_z.Data); 
% filtfilt no option for time series directly
% filter/filtfilt(b, a, x) or filter(ts, b, a);

% convert data to 128 bins between 0 and 5
z_filt = abs(z_filt);
topEdge = 5;
botEdge = 0; 
numBins = 128; 

binEdges = linspace(botEdge, topEdge, numBins+1);
[~, binned] = histc(z_filt, binEdges);

% convert to counts/epoch
epoch_length = 15;

%%%%%%%%%%%% TO DO: start at the nearest whole minute %%%%%%
%%%% also reshape time vector and pick first line? 

counts = max2epochs(binned, fs, epoch_length);

    % NOTE: Please be aware that the algorithm used here has only been
    % validated for 15 sec epochs and 50 Hz data. The formula (1) used below
    % is based on these settings. The longer the epoch, the higher the
    % constant offset/residual noise (18 in this case). Sampling frequencies 
    % will probably affect the constant offset probably less. However, due 
    % to the band-pass of 3-11 Hz used above and human movement frequencies 
    % of up to 10 Hz, a sampling of less than 30 Hz is not reliable.

% subtract constant offset and multiply with factor for distal location
counts = (counts-18).*3.07;                             % ---> formula (1)

% set any negative values to 0
indices = counts < 0;
counts(indices) = 0;

%% CREATE TIMESERIES
% create a new time series for the epoch data
basetime = datevec(time(1));
basetimeVec = repmat(basetime,[numel(counts) 1]);
% add 15 seconds for every step
basetimeVec(:,6) = (0:15:numel(counts)*15)'; %
counts_time = datenum(basetimeVec); % MATLAB datenum format

% create timeseries
counts = timeseries(counts_data, counts_time, 'Name', 'ACC');
ts.DataInfo.Unit = '';
% ts.TimeInfo.Units = 'days';
% ts.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

% get algorithm settings - vars

% get bedtimes and wake times

% score on successive days, for the number of days the sleep consensus diary has been
% filled out

% store results in a seperate struct - perhaps restruct header as well?

%%


end