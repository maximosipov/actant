function [ts, vals] = oakley(act, args1, args2)
% OAKLEY markup epochs with activity counts as sleep/wake and extract sleep
% parameters
%
% Description:
%   todo
%   
%
% Arguments:
%   data  - Input data timeseries (can be ACCZ or ACT)
%   args1 - {5 x 1} Cell array of algorithm arguments
%           Algorithm -   'oakley'
%           Method -      'i'    (immobility) - DEFAULT 
%                         's'    (sleep/wake)
%                         'none' (no estimation)
%           Sensitivity - 'l'    (low)
%                         'm'    (medium)     - DEFAULT
%                         'h'    (high)
%           Snooze -      'on' - DEFAULT
%                         'off'
%           Time window - 5      (minutes)
%                         7      (minutes)
%                         10     (minutes)    - DEFAULT 
%   args2 - {DAYS x 8} Cell array of sleep consensus diary inputs:
%           {'Date', 'Bed time', 'Lights off', 'Latency', 'Wake times',...
%           'Wake duration', 'Wake time', 'Out of bed'};
%
% Results (all optional):
%   ts -   Cell array of timeseries
%   vals - Cell array of sleep results
%
% Copyright (c) 2011-2013 Bart te Lindert
%
% See also: Oakley NR. Validation with polysomnography of the Sleepwatch 
%           sleep/wake scoring algorithm used by the Actiwatch activity 
%           monitor system: Technical Report to Mini-Mitter Co., Inc., 1997.
%
%           te Lindert BHW; Van Someren EJW. Sleep estimates using
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

%% FIRST CHECK FOR SUFFICIENT INPUT ARGUMENTS
vals = {};

if nargin < 3
    errordlg('Not enough input arguments', 'Error', 'modal')
    return
end

%% THEN CHECK IF NONE OF THE ARGUMENTS IS EMPTY
if isempty(act)
    errordlg('Not enough input arguments', 'Error', 'modal')
    return
elseif isempty(args1)
    errordlg('No method selected', 'Error', 'modal')
    return
elseif isempty(args2)
    errordlg('Please provide Sleep Consensus Diary data', 'Error', 'modal')
    return
end


%% CHECK DATA INPUT FORMAT
if strcmpi(act.Name, 'ACT')
    % data is counts data
    data = act.Data;
    time = act.Time;
    
    % get sampling/epoch duration
    % assume increment in minutes and seconds
    increment = datestr(time(2)-time(1), 'MM:SS');
    
    if strcmpi(increment, '00:15')
        sampling = 15;
    elseif strcmpi(increment, '00:30')
        sampling = 30;
    elseif strcmpi(increment, '01:00')
        sampling = 60;
    elseif strcmpi(increment, '02:00')
        sampling = 120;
    else
        % display error message
        errordlg('Epoch duration not recognized. It can be 15s, 30s, 1min, 2min ONLY!', 'Error', 'modal');
        return
    end
elseif strcmpi(act.Name, 'ACCZ')
    % data is raw z-axis accelerometry of Geneactiv
    % data needs to be converted to counts using function awd (bottom of this
    % script)
    act = awd(act);
    data = act.Data;
    time = act.Time;
    sampling = 15;
else
    % display error message
    errordlg('Algorithm can only be applied to ACT or ACCZ data!', 'Error', 'modal');
    return
end

if nargin == 1
    errordlg('No algorithm and SCD data available!', 'Error', 'modal');
    return;
elseif nargin == 2
    errordlg('Please fill out Sleep Consensus Diary!', 'Error', 'modal');
    return;
end

%% INITIALIZE VARIABLES 
days = size(args2, 1);
vals = cell(19, days);

vals{1, 1}  = 'SCD: In bed time';
vals{2, 1}  = 'SCD: Lights off time';
vals{3, 1}  = 'SCD: Wake time';
vals{4, 1}  = 'SCD: Out of bed time';
vals{5, 1}  = 'Time in bed (min)';
vals{6, 1}  = 'Sleep onset time'; 
vals{7, 1}  = 'Sleep onset latency (min)';
vals{8, 1}  = 'Final wake time';
vals{9, 1}  = 'Assumed sleep time (min)';
vals{10, 1} = 'Snooze time 1 (min)';
vals{11, 1} = 'Snooze time 2 (min)';
vals{12, 1} = 'Wake after sleep onset (min)';
vals{13, 1} = 'Actual sleep time (min)';
vals{14, 1} = 'Sleep efficiency 1 (%)'; 
vals{15, 1} = 'Sleep efficiency 2 (%)'; 
vals{16, 1} = 'Number of wake bouts';
vals{17, 1} = 'Mean wake bout time (min)'; 
vals{18, 1} = 'Number of sleep bouts'; 
vals{19, 1} = 'Mean sleep bout time (min)';
vals{20, 1} = 'Mobile time (min)';
vals{21, 1} = 'Immobile time (min)';


method      = args1{2,2};
sensitivity = args1{3,2};
snooze      = args1{4,2};
timewindow  = args1{5,2};

%% GET THRESHOLD
% convert sensitivity to threshold
if strcmpi(sensitivity, 'l')
    thres = 80;
elseif strcmpi(sensitivity, 'm')
    thres = 40;
elseif strcmpi(sensitivity, 'h')
    thres = 20;
end

%% rescore data based on sensitivity algorithm
% see Actiware manual for specifics of the scoring algorithm, but in short:
% within 1 minute of the epoch of interest data is divided by 5
% within 2 minutes of the epoch of interest data is divided by 25
% the epoch of interest is multiplied by:
%   4 for 15 second epochs
%   2 for 30 second epochs
%   1 for 1 minute epochs
%   0.5 for 2 minute epochs

if sampling == 15
    coeff = [(1/25), (1/25), (1/25), (1/25),...
             (1/5), (1/5), (1/5), (1/5), 4,...
             (1/5), (1/5), (1/5), (1/5),...
             (1/25), (1/25), (1/25), (1/25)];
    shift = 9;
elseif sampling == 30
    coeff = [(1/25), (1/25),...
             (1/5), (1/5), 2,...
             (1/5), (1/5),...
             (1/25), (1/25)];
    shift = 5;
elseif sampling == 60
    coeff = [(1/25), (1/5), 1, (1/5), (1/25)];
    shift = 3;
elseif sampling == 120
    coeff = [(1/5), 0.5, (1/5)];
    shift = 2;
else 
    errordlg('Epoch duration not supported', 'Error', 'modal');
    return
end

% score data using oakley's algorithm
% TODO, add ref...
score = filter(coeff, 1, data);

% shift data backwards to correct for filter shift
score = [score(shift:end); zeros(shift-1, 1)];

%wake = NaN(size(score));
%wake(score > thres) = 1;

wake = score > thres;
% score epochs as MOBILE if counts >= 1
% An epoch is scored as MOBILE if the number of 
% activity counts recorded in that epoch is greater 
% than or equal to the epoch length in 15-second intervals. 
% For example,there are four 15-second intervals for a 
% 1-minute epoch length; hence, the activity value in a 1-min epoch 
% must be greater than, or equal to four to be scored as MOBILE.
% mobile = score > (sampling/15);

%% find sleep start and sleep end
ratio = 60/sampling;

% create time series of SCORE and WAKE to  allowdata selection based on time 
counts = timeseries(data, time, 'Name', 'ACT');
counts.DataInfo.Unit = 'counts';
score  = timeseries(score, time, 'Name', 'SCORE');
score.DataInfo.Unit = 'counts';
wake   = timeseries(wake, time, 'Name', 'WAKE');
wake.DataInfo.Unit = 'binary';

for day = 1:days
    
    idx = day+1;
    
    % extract the correct date and time from the SCD 
    startTime = dateconversion(args2{day, 1}, args2{day, 3});
    endTime = dateconversion(args2{day, 1}, args2{day, 7});
    
    % get data from COUNTS and WAKE
    % only one will be used in either algorithm (i or sw), but both are 
    % needed for calculating the sleep parameters 
    % PLEASE NOTE THAT COUNTS AND NOT SCORE IS USED IN THE ALGORITHM
    tsScore = getsampleusingtime(counts, startTime, endTime);
    dataScore = tsScore.Data;
        
    tsWake = getsampleusingtime(wake, startTime, endTime);
    dataWake = tsWake.Data;
    
    % immobility algorithm
    if strcmpi(method, 'i'); 
        % find first period of 10 minutes of immobility and allow 1 epoch of
        % activity
        % threshold for activity depends on the number of 15s intervals in the
        % epoch time: e.g. 15 epoch/ 15 s interval => threshold = 1
        % 30 s epoch/ 15 s interval => threshold = 2
        % 1 min epoch / 15 s interval => threshold = 4
   
        % size of sliding window
        window = ratio*timewindow; % number of epoch in 10 minute window
        
        % sleep onset time
        for i = 1:numel(dataScore)
            % calulate number of mobile epochs
            n = dataScore(i:i+window-1) >= sampling/15;
            if sum(n) <= 1; % allow for max 1 epoch of mobility
                break 
            else
            end
        end
        
        % calculated sleep onset time
        idx_sot = i;
        
        if strcmpi(snooze, 'on');
            % final wake time
            for j = numel(dataScore):-1:1
                % calculate number of mobile epochs
                n = dataScore(j-window+1:j) >= sampling/15;
                if sum(n) <= 1; % allow for max 1 epoch of mobility
                    break 
                else
                end
            end

            % calculated final wake time
            idx_fwt = j;
        else
            idx_fwt = numel(dataScore);
        end
        
    % sleep/wake algorithm
    elseif strcmpi(method, 'sw')
        
        % sleep/wake algorithm: sleep onset estimation 
        % find first period of 5 minutes of consecutive sleep epochs

        % size of sliding window
        window = ratio*5;
        
        % sleep onset time
        for i = 1:numel(dataWake)
            n = dataWake(i:i+window-1) == 0;
            if sum(n) == window; % i.e. all epochs are sleep
                break 
            else
            end
        end
        
        % calculated sleep onset time
        idx_sot = i;
        
        if strcmpi(snooze, 'on');
            % final wake time
            for j = numel(dataWake):-1:1
                n = dataWake(j-window+1:j) == 0;
                if sum(n) == window;
                    break 
                else
                end
            end

            % calculated final wake time
            idx_fwt = j;
        else
            idx_fwt = numel(dataScore);
        end
        
    elseif strcmpi(method, 'None')       
        idx_sot = 1;
        idx_fwt = numel(dataScore);

    end

    % SCD: In bed time
    % The time the subjects gets into bed, as filled out in the sleep
    % consensus diary and passed to this function in args2
    %scdInBedTime = datenum(args2{day, 2})
    scdInBedTime = dateconversion(args2{day, 1}, args2{day, 2});
  
    % SCD: Lights off time/trying to fall asleep
    % The time the subjects switches off the lights or starts to try
    % to fall asleep, as filled out in the sleep consensus diary, 
    % and passed to this function in args2
    %scdLightsOffTime = datenum(args2{day, 3})
    scdLightsOffTime = dateconversion(args2{day, 1}, args2{day, 3});
    
    % SCD: Final wake time
    % The time the subject woke up, as filled out in the sleep consensus
    % diary and passed to this function in args2
    %scdFinalWakeTime = datenum(args2{day, 7})
    scdFinalWakeTime = dateconversion(args2{day, 1}, args2{day, 7}); 
    
    % SCD: Out of bed time
    % The time the subject got out of bed as filled out in the sleep consensus
    % diary and passed to this function in args2
    %scdOutOfBedTime = datenum(args2{day, 8})
    scdOutOfBedTime = dateconversion(args2{day, 1}, args2{day, 8});
    
    %%% NOTE: score is used instead of tsScore, because tsScore only contains 
    %%% data between 'scdLightsOff' and 'scdFinalWakeTime' 
    
    % Time in bed
    % Time (in minutes) between 'In bed time' and 'Out of bed time' 
    ts = getsampleusingtime(score, scdInBedTime, scdOutOfBedTime);
    timeInBed = numel(ts.Data)*(sampling/60);

    % Sleep onset time
    % Time the subject fell asleep as calculated by the algorithm
    ts = getsampleusingtime(score, tsScore.Time(idx_sot));
    sleepOnsetTime = ts.Time(1);
    
    % Sleep onset latency
    % Time it took the subject to fall asleep
    % Time (in minutes) between 'Lights off time' and 'Sleep onset time' 
    ts = getsampleusingtime(score, scdLightsOffTime, sleepOnsetTime);
    sleepOnsetLatency = numel(ts.Data(1:end-1))*(sampling/60);
    
    % Final wake time
    % Time the subject woke up in the morning as calculated by the
    % algorithm, if SNOOZE=ON.
    % If SNOOZE=OFF, time is equal to scdFinalWakeTime.
    ts = getsampleusingtime(score, tsScore.Time(idx_fwt));
    finalWakeTime = ts.Time(1);
    
    % Assumed sleep time
    % Time between 'Sleep onset time' and 'Final wake time'
    ts = getsampleusingtime(score, sleepOnsetTime, finalWakeTime);
    assumedSleepTime = numel(ts.Data(1:end-1))*(sampling/60);
    
    % Snooze time 1
    % Time between the calculated 'Final wake time' and 'Wake time' 
    % as reported in the Sleep Consensus Diary 
    ts = getsampleusingtime(score, finalWakeTime, scdFinalWakeTime);
    snoozeTime1 = numel(ts.Data-1)*(sampling/60);
    
    % Snooze time 2
    % Time between the calculated 'Final wake time' and 'Out of bed time' 
    % as reported in the Sleep Consensus Diary
    ts = getsampleusingtime(score, finalWakeTime, scdOutOfBedTime);
    snoozeTime2 = numel(ts.Data-1)*(sampling/60);
    
    % Wake after sleep onset
    % Number of epochs scored as WAKE between 'Sleep onset time' and 
    % 'Final wake time' multiplied by the epoch length.    
    ts = getsampleusingtime(score, sleepOnsetTime, finalWakeTime);
    indices = (ts.Data(1:end-1) >= thres);
    nwake = sum(indices);
    wakeAfterSleepOnset = nwake*(sampling/60);
    
    % Actual sleep time
    % Number of epochs scored as SLEEP between 'Sleep onset time' and 
    % 'Final wake time' multiplied by the epoch length.
    ts = getsampleusingtime(score, sleepOnsetTime, finalWakeTime);
    indices = (ts.Data(1:end-1) <= thres);
    nsleep = sum(indices);
    actualSleepTime = nsleep*(sampling/60);

    % Analysis period
    analysisPeriod = (numel(tsScore.Data)-1)*(sampling/60);
    
    % Sleep efficiency 1
    % 'Actual sleep time' divided by 'Analysis period' 
    % (Final wake time - Sleep onset time) multiplied by 100.
    sleepEfficiency1 = (actualSleepTime / analysisPeriod)*100;
    
    % Sleep efficiency 2
    % 'Actual sleep time' divided by 'Time in bed' multiplied by 100.
    sleepEfficiency2 = (actualSleepTime / timeInBed)*100;
    
    % Number of wake bouts
    % Number of continuous blocks, one or more epochs in duration, with 
    % each epoch of each block scored as WAKE between the 'Assumed sleep time'.
    ts = getsampleusingtime(score, sleepOnsetTime, finalWakeTime);
    indices = find(ts.Data > thres);
    b = bouts(indices); 
    numberOfWakeBouts = numel(b);

    % Mean wake bout time
    % 'Wake after sleep onset' divided by the 'Number of wake bouts'
    meanWakeBoutTime = wakeAfterSleepOnset/numberOfWakeBouts;

    % Number of sleep bouts
    % Number of continuous blocks, one or more epochs in duration, with 
    % each epoch of each block scored as SLEEP between the 'Assumed sleep time'.
    indices = find(ts.Data <= thres);
    b = bouts(indices); 
    numberOfSleepBouts = numel(b);
    
    % Mean sleep bout time
    % 'Actual sleep time' divided by the 'Number of sleep bouts'
    meanSleepBoutTime = actualSleepTime/numberOfSleepBouts;  
    
    % Mobile time
    % Total duration of epochs with activity (>0) in the 'Assumed sleep time' 
    % period
    ts = getsampleusingtime(score, sleepOnsetTime, finalWakeTime);
    mobileTime = (sum(ts.Data > 0))*(sampling/60);

    % Immobile time 
    % Total duration of epochs with no activity (=0) in the 'Assumed sleep time' 
    % period
    ts = getsampleusingtime(score, sleepOnsetTime, finalWakeTime);
    immobileTime = (sum(ts.Data == 0))*(sampling/60);
    
    % set calculated sleep parameters to vals{}
    vals{1, idx}  = datestr(scdInBedTime, 'dd-mmm-yy HH:MM:SS');
    vals{2, idx}  = datestr(scdLightsOffTime, 'dd-mmm-yy HH:MM:SS');
    vals{3, idx}  = datestr(scdFinalWakeTime, 'dd-mmm-yy HH:MM:SS');
    vals{4, idx}  = datestr(scdOutOfBedTime, 'dd-mmm-yy HH:MM:SS');
    vals{5, idx}  = timeInBed;
    vals{6, idx}  = datestr(sleepOnsetTime, 'dd-mmm-yy HH:MM:SS'); 
    vals{7, idx}  = sleepOnsetLatency;
    vals{8, idx}  = datestr(finalWakeTime, 'dd-mmm-yy HH:MM:SS');
    vals{9, idx}  = assumedSleepTime;
    vals{10, idx} = snoozeTime1;
    vals{11, idx} = snoozeTime2;
    vals{12, idx} = wakeAfterSleepOnset;
    vals{13, idx} = actualSleepTime;
    vals{14, idx} = sleepEfficiency1; 
    vals{15, idx} = sleepEfficiency2; 
    vals{16, idx} = numberOfWakeBouts;
    vals{17, idx} = meanWakeBoutTime; 
    vals{18, idx} = numberOfSleepBouts; 
    vals{19, idx} = meanSleepBoutTime;
    vals{20, idx} = mobileTime;
    vals{21, idx} = immobileTime;
    
    % finally, add sleep events (bedtime, waketime etc) to counts
    names = {'In bed time',...
             'Lights off time',...
             'Sleep onset time',...
             'Final wake time',...
             'Wake time',...
             'Out of bed time'};
    times =  {datestr(scdInBedTime    , 'dd-mmm-yy HH:MM:SS'),...
              datestr(scdLightsOffTime, 'dd-mmm-yy HH:MM:SS'),...
              datestr(sleepOnsetTime  , 'dd-mmm-yy HH:MM:SS'),...
              datestr(finalWakeTime   , 'dd-mmm-yy HH:MM:SS') ,...
              datestr(scdFinalWakeTime, 'dd-mmm-yy HH:MM:SS'),...
              datestr(scdOutOfBedTime , 'dd-mmm-yy HH:MM:SS')};
           
    counts = addevent(counts, names, times);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check s/w epochs ebtween gui and actiware
save('sleepwake.mat', 'wake');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% define output timeseries
ts = counts;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUB FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function act = awd(ts)

% get ts data
data = get(ts, 'Data');
time = get(ts, 'Time');

% assume increment in milliseconds
increment = str2double(datestr(time(2)-time(1), 'FFF'));

% sampling frequency
fs = (1/increment)*1000;

if isnan(fs)
    errordlg('Samplig rate is NaN!');
    return
end

% set filter specifications
cf_low = 3;               % lower cut off frequency (Hz)
cf_hi  = 11;              % high cut off frequency (Hz)
order  = 5;               % filter order
pass   = 'bandpass';      % filter type
w1     = cf_low/(fs/2);   % normalized frequency low
w2     = cf_hi/(fs/2);    % normalized frequency high
[b, a] = butter(order, [w1 w2], pass); 

% filter z data only
z_filt = filtfilt(b, a, data); 

% convert data to 128 bins between 0 and 5
z_filt = abs(z_filt);
topEdge = 5;
botEdge = 0; 
numBins = 128; 

binEdges = linspace(botEdge, topEdge, numBins+1);
[~, binned] = histc(z_filt, binEdges);

% convert to counts/epoch
epoch = 15;
counts = max2epochs(binned, fs, epoch);

% NOTE: Please be aware that the algorithm used here has only been
% validated for 15 sec epochs and 50 Hz raw accelerometery (palmar-dorsal
% z-axis data. The formula (1) used below
% is based on these settings. The longer the epoch, the higher the
% constant offset/residual noise will be(18 in this case). Sampling frequencies 
% will probably affect the constant offset less. However, due 
% to the band-pass of 3-11 Hz used above and human movement frequencies 
% of up to 10 Hz, a sampling of less than 30 Hz is not reliable.

% subtract constant offset and multiply with factor for distal location
counts = (counts-18).*3.07;                   % ---> formula (1)

% set any negative values to 0
indices = counts < 0;
counts(indices) = 0;

% create a new time series for the epoch data
timeNum = zeros(size(counts));
timeNum(1) = datenum(time(1));
for i = 2:numel(timeNum)
    timeNum(i) = datenum(addtodate(timeNum(i-1), 15, 'second'));
end

% create timeseries
act = timeseries(counts, 'Name', 'ACT');
act.DataInfo.Unit  = 'counts';
act.TimeInfo.Units = 'seconds';

% create a uniform timeseries based on the start time and the epoch duration
% make sure the TimeInfo.Units of ts1 has already been set to seconds 
act = set(act, 'Time', timeNum);


end

function date = dateconversion(date, time)

time = num2str(time);
MM = str2double(time(end-1:end));
HH = str2double(time(1:end-2));
date = datevec(date, 'dd-mm-yy');
    
    if isempty(HH)
        HH = 0;
    end
    
    if isempty(MM)
        MM = 0;
    end

    if HH <= 15
        % participant went to bed after 00:00, so the date is equal to the
        % morning date as filled out in the SCD
        date = [date(1:3), HH, MM, 00];
        date = datenum(date);
    else
       % bed time is before 00:00 and 1 day is subtracted from the morning date 
        t = [date(1:3), HH, MM, 00];
        date = addtodate(datenum(t), -1, 'day');
    end
    
end

function nbouts = bouts(indices)
% BOUTS Calculates average duration of a continous wake or sleep bout
%
% Description:
%   Todo...
%
% Arguments:
%   indices - indices of wake/sleep epochs (i.e. activity above/below a given
%   threshold)
%
% Results:
%   nbouts - N-by-1 vector of bout duration in epochs;
%            length(nbouts) = number of continuous bouts

b = 1;
nbouts(b) = 1;
    for p = 2:length(indices)
        % check for new bout
        if indices(p-1) ~= indices(p)-1 
            % new bout
            b = b+1;
            nbouts(b) = 1;
        else % same bout
            % add 1 to length
            nbouts(b) = nbouts(b)+1;
        end
    end
end