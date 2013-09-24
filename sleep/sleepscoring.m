function [sleep, data] = sleepscoring(counts, timeStamps, onsetTime, offsetTime,... 
                                      epoch, sensitivity, method, snooze)
% SLEEPSCORING Convert the waveform amplitude into bins
%
% Copyright (c) 2011-2013 Bart te Lindert
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
%
% The MIT License (MIT) / http://opensource.org/licenses/MIT 
%
% Description:
%   function sleepscoring scores sleep parameters per night on a time
%   series from 12:00-12:00
%
% Arguments:
%   counts - N-by-1 column vector of count data of 1 day between 12:00-12:00
%   timeStamps - N-by-1 series with time stamps [datenums]
%   onsetTime - datenum of 'in bed time' or 'lights off time' 
%   offsetTime - datenum of 'out of bed time' or 'final wake time'
%   epoch - epoch length (s): 
%       15s (default), 30s, 60s, 120
%   sensitivity - sensitivity of algorithm: 
%       'l' (low), 'm' (medium, default) or 'h' (high)
%   method - method of sleep onset calculation: 
%       'i' (immobility, default), 's' (sleep/wake), 'none' (no estimation)
%   snooze - whether to use the algorithm to calculate final wake time:
%   'on' (default) or 'off'
%
% Results:
%   sleep - output of sleep parameters
%   data - output of data %%%%%%%%%%%%%%% convert to edf file????????????

% Set default arguments 
if nargin < 4
    %%%%%%%%%%%%%%%%%%%%%%%TODOthrow error%%%%%%%%%
elseif nargin == 4
    epoch = 15;
    sensitivity = 'm';
    method = 'i';
    snooze = 'on';
elseif nargin == 5
    sensitivity = 'm';
    method = 'i';
    snooze = 'on';
elseif nargin == 6
    method = 'i';
    snooze = 'on';
elseif nargin == 7
    snooze = 'on';
end    

% define sensitivity threshold
if strcmpi(sensitivity, 'l')
    thres = 20;
elseif strcmpi(sensitivity, 'm')
    thres = 40;
elseif strcmpi(sensitivity, 'h')
    thres = 80;
end

% number of epochs per minute
epochsPer1Min = 60/epoch;

% find indices of algorithm onset and offset in time stamps
iAlgorithmOnset = find(onsetTime >= timeStamps);
iAlgorithmOnset = size(iAlgorithmOnset,1);
iAlgorithmOffset = find(offsetTime >= timeStamps);
iAlgorithmOffset = size(iAlgorithmOffset,1);
assumedSleepEpochs = (iAlgorithmOffset-iAlgorithmOnset)*epoch;

% store first set of sleep variables
sleep.method = method;
sleep.sensitivity = sensitivity;
sleep.epoch = epoch;
sleep.bed_time = datestr(onsetTime); %%% remove
sleep.lights_out = datestr(timeStamps(iAlgorithmOnset)); % identical to above?
sleep.get_up_time = datestr(offsetTime);%%% remove
sleep.timeInBedHours = datestr(assumedSleepEpochs/(24*3600),'HH:MM');
sleep.timeInBedMins = (iAlgorithmOffset-iAlgorithmOnset)*(epoch/60);

%% rescore data based on sensitivity algorithm
%  see Actiware manual for specifics of the scoring algorithm
%  within one minute of epoch t0 data is divided by 5
%  within 2 minutes of epoch t0 data is divided by 25
%  epoch t0 is multiplied by 4 (for a 15 s epoch), by 2 (for a 30 s epoch), 
%  by 1 (for a 1 min epoch) and by 0.5 (for a 2 min epoch).

%%%%%% implement much simpler version of Oxford uni...
%%% CHECK PERFORMANCE VS OLD SCRIPTS
%%% CORRECT FOR FILTER OFFSET

% define filter coefficients
if epoch == 15
    coefs = [(1/25), (1/25), (1/25), (1/25), (1/5), (1/5), (1/5), (1/5), 4,...
             (1/5), (1/5), (1/5), (1/5), (1/25), (1/25), (1/25), (1/25)];
elseif epoch == 30
    coefs = [(1/25), (1/25), (1/5), (1/5), 2, (1/5), (1/5), (1/25), (1/25)];
elseif epoch == 60
    coefs = [(1/25), (1/5), 2, (1/5), (1/25)];
elseif epoch == 120
    coefs = [(1/25), (1/2), (1/25)];
end

% apply the convolution of the data
score = filter(coeff, 1, counts);

% mark epochs as wake if score is equal or greater than thres
wake = score >= thres;
    
% IMMOBILITY: SLEEP ONSET AND FINAL WAKE TIME ESTIMATION
%   An epoch is scored as MOBILE if the number of 
%   activity counts recorded in that epoch is greater 
%   than or equal to the epoch length in 15-second intervals. 
%   For example,there are four 15-second intervals for a 
%   1-minute epoch length; hence, the activity value in an epoch 
%   must be greater than, or equal to 4 to be scored as MOBILE.
    

% SLEEP ONSET
% Find the first period of 10 minutes of continuous immobility and 
% allow for 1 epoch of activity above threshold epoch/15
if strcmpi(method, 'i');        
    % number of epochs in 10 minute window
    epochsPer10min = epochsPer1Min*10; 
    % period between sleep onset and offset    
    for k = iAlgorithmOnset:iAlgorithmOffset
        % calulate number of mobile epochs
        n = counts(k:k+epochsPer10min-1) >= epoch/15;
        % allow for 1 epochs of mobility
        if sum(n) <= 1; 
            break 
        else
        end
    end
    iSleepOnset = k;

    % FINAL WAKE TIME
    if strcmpi(snooze, 'on')
        for k = iAlgorithmOffset:-1:iAlgorithmOnset
            % calculate number of mobile epochs
            n = counts(k-epochsPer10Min+1:k) >= epoch/15;
            if sum(n) <= 1;
                break 
            else
            end
        end
        iFinalWakeTime = k;
    elseif strcmpi(snooze, 'off')
        iFinalWakeTime = iAlgorithmOffset;
    end

% SLEEP/WAKE: SLEEP ONSET AND FINAL WAKE TIME ESTIMATION
% Sleep/wake: estimating sleep onset
% find first period of 5 minutes of consecutive sleep epochs

% SLEEP ONSET
elseif strcmpi(method, 's')
    epochsPer5Min = epochsPer1Min*5;
        for k = iAlgorithmOnset:iAlgorithmOffset
            n = wake(k:k+epochsPer5Min-1) == 0;
            if sum(n) == epochsPer5Min; % i.e. all epochs are sleep
                break 
            else
            end
        end
    iSleepOnset = k;

    % FINAL WAKE TIME
    if strcmpi(snooze, 'on')
        for k = iAlgorithmOffset:-1:iAlgorithmOnset
            n = wake(k-epochsPer5Min+1:k) == 0;
            if sum(n) == epochsPer5Min;
                break 
            else
            end
        end
        iFinalWakeTime = k; 
    elseif strcpmi(snooze, 'off')
        iFinalWakeTime = iAlgorithmOffset; 
    end

elseif strcmpi(method, 'none')       
    iSleepOnset = iAlgorithmOnset;
    iFinalWakeTime = iAlgorithmOffset;

end

% RESULTS: sleep onset time 
sleep.sleepOnset = datestr(timeStamps(iSleepOnset));

% RESULTS: final wake time
sleep.finalWakeTime = datestr(timeStamps(iFinalWakeTime));

% calculate wake bouts
% can use wake series here %%%%%%%%%%%%%%%%
iWake = find(score(iSleepOnset:iFinalWakeTime) >= thres); %??? greater or equal??? 
wakeBouts = bouts(iWake); 
sleep.wakeBouts = length(wakeBouts);

% calculate sleep bouts
iSleep = find(score(iSleepOnset:iFinalWakeTime) < thres); % less than or equal?? check
sleepBouts = bouts(iSleep); 
sleep.sleepBouts = length(sleepBouts);

%% calculate sleep parameters.
% epochs between sleep start and sleep end
assumedSleepEpochs = iFinalWakeTime-iSleepOnset;

% RESULTS: assumed sleep time
sleep.assumedSleepMins  = (assumedSleepEpochs*epoch)/60;
sleep.assumedSleepHours = datestr((assumedSleepEpochs*epoch)/(24*3600),...
                                    'HH:MM:SS');

% wake epochs between sleep start and sleep end 
indices    = score(iSleepOnset:iFinalWakeTime) >= thres; %?? greater or equal to?
wakeEpochs = sum(indices);

% RESULTS: sleep efficiency (SE) precentage
sleep.efficiency = ((assumedSleepEpochs-wakeEpochs)/(iAlgorithmOffset-iAlgorithmOnset))*100; %%%%%% CHECK!!! SE SS OR GUT BT

% RESULTS: sleep onset latency (SOL) time
sleep.sleepOnsetLatencyMins  = (assumedSleepEpochs*epoch)/60;
sleep.sleepOnsetLatencyHours = datestr((sleep.sleepOnsetLatencyMins*60)/(24*3600),...
                                        'HH:MM:SS');

% RESULTS: wake after sleep onset (WASO) time/percentage
sleep.wakeAfterSleepOnsetMins    = (wakeEpochs*epoch)/60;
sleep.wakeAfterSleepOnsetHours   = datestr((wakeEpochs*epoch)/(24*3600),...
                                            'HH:MM:SS');
sleep.wakeAfterSleepOnsetPercent = (wakeEpochs/(iFinalWakeTime-iSleepOnset))*100;

% RESULTS: actual sleep time/percentage
sleep.actualSleepMins      = ((assumedSleepEpochs-wakeEpochs)*epoch)/60;
sleep.actualSleepHours     = datestr(((assumedSleepEpochs-wakeEpochs)*epoch)/(24*3600),...
                                 'HH:MM:SS');
sleep.actualSleepPercent   = 100-sleep.wakeAfterSleepOnsetPercent;  

% number of movement epochs
movementEpochs             = length(find(counts(iSleepOnset:iFinalWakeTime) ~= 0));

% RESULTS: amount of time/percentage moving in the assumed sleep period
sleep.movementMins         = (movementEpochs*epoch)/60;
sleep.movementPercent      = (movementEpochs/assumedSleepEpochs)*100;

% RESULTS: amount of time/percentage immobile in the assumed sleep period
sleep.immobileMins         = ((assumedSleepEpochs-movementEpochs)*epoch)/60;
sleep.immobilePercent      = ((assumedSleepEpochs-movementEpochs)/assumedSleepEpochs)*100;

% RESULTS: mean wake bout time
sleep.wakeBoutLengthMins   = sleep.wakeAfterSleepOnsetMins/sleep.wakeBouts;
sleep.wakeBoutLengthHours  = datestr((sleep.wakeBoutLengthMins*60)/(24*3600),...
                                     'HH:MM:SS');
% RESULTS: mean sleep bout time
sleep.sleepBoutLengthMins  = sleep.actualSleepMin/sleep.sleepBouts;
sleep.sleepBoutLengthHours = datestr((sleep.sleepBoutsMins*60)/(24*3600),...
                                      'HH:MM:SS');

% RESULTS: time series data
data.timeStamps       = timeStamps;
data.counts           = counts;
data.score            = score;
data.wake             = wake;
%data.temperature       = temperature !!!!!!!!!!!
data.threshold        = thres;
data.iAlgorithmOnset  = iAlgorithmOnset; % this can be lights off or bed time!
data.iSleepOnset      = iSleepOnset;
data.iFinalWakeTime   = iFinalWakeTime;
data.iAlgorithmOffset = iAlgorithmOffset; % this can be out of bed or subjective final wake time
end