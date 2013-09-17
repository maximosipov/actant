function [timeStampsDoublePlot, listOfDays, numberOfDays, iStartRecording] = time2doubleplot(counts, startOfRecording, epoch)
% TIME2DOUBLEPLOT Converts a time series of time stamps to a double plot
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
%   Converts a time series of time stamps to a double plot
%
% Arguments:
%   counts - activity counts of recording 
%   startOfRecording - datevec of onset of recording
%   epoch - duration of epoch in seconds
%
% Results:
%   timeStampsDoublePlot - epoch time stamps per 48 hours -by- days matrix?
%   listOfDays - DDMMYY ?
%   numberOfDays - ...
%   iStartRecording - index of onset of recording in double plot time
%   series

% This function will output a time stamp series for a double plot, and a ListOfDays that will be used in the hoem
% screen of the UI to view dates for the sleep diary.
% It will also output a time series of stamps for each epoch in the Counts
% data series.
% Counts = series of epochs
% StartRecording = datevec
% EpochDuraction = int in seconds

%%%% should be improved....

% extract start date from the datevec
startDate             = startOfRecording(1:3);
% all recordings should start at 00:00 for the double plot. 
startDate             = datenum([startDate 00 00 00]);
% number of seconds in a day
numberOfSecondsPerDay = 24*60*60;
% number of epochs in a day
numberOfEpochsPerDay  = floor(numberOfSecondsPerDay/epoch);
% number of recorded epochs
numberOfEpochs        = length(counts);
% number of full day recordings (using 'ceil' because of filling remainder of day
% with zeros)
numberOfDays          = ceil(numberOfEpochs/numberOfEpochsPerDay);
% allocate empty matrix for counts data in nepochs*ndays 
NewCounts             = zeros(numberOfEpochsPerDay, numberOfDays+1);
% number of nepochs*ndays
N                     = size(NewCounts,1)*size(NewCounts,2);

% create new time stamps for epochs

% allocate empty matrix for time stamps
timeStampsSeries            = zeros(size(NewCounts));
% set index 1 of matrix to StartDate (datenum)
timeStampsSeries(1)         = startDate;

% increase subsequent indices with the epoch duration
for i = 2:N;
    timeStampsSeries(i) = addtodate(timeStampsSeries(i-1), epoch, 'second');
end

% reshape time vector to 00:00-00:00 per column, (column = days, rows = epochs) 
timeStampsSeries = reshape(timeStampsSeries, size(NewCounts,1), size(NewCounts,2));

% find timestamp/index from where actual recording started
iStartRecording      = length(find(datenum(startOfRecording) >= timeStampsSeries));  

% paste data from here onwards...
NewCounts(iStartRecording:iStartRecording+numberOfEpochs-1)  = counts;

% convert 'counts' and 'timeStamps' to double plot data 00:00 -> 00:00 -> 00:00
timeStampsDoublePlot = [timeStampsSeries(:, 1:numberOfDays) ; timeStampsSeries(:, 2:end)];

listOfDays(1) = startDate;

for i = 2:size(NewCounts,2)
    listOfDays(i) = addtodate(listOfDays(i-1), 1, 'day');
end

listOfDays = datestr(startDate, 'dd-mm-yyyy');
end