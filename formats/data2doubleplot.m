function [dataDoublePlot] = data2doubleplot(data, epoch, iStartRecording)
% DATA2DOUBLEPLOT Converts a time series to a 48 hour double plot
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
%   The function divides the waveform amplitude (data) into numbins between 0 and max.
%   Used to match the Geneactiv amplitude (g) to the Actiwatch amplitude (counts),
%   such that 1g equals approximately 25 Actiwatch counts.
%
% Arguments:
%   data - N-by-1 column vector of epoch data 
%   epoch - epoch duration in seconds
%   iStartRecording - index of onset of recording in double plot
%
% Results:
%   dataDoublePlot -  data matrix with double plot data per day (columns)
%   -by- days (rows)


% number of seconds in a day
numberOfSecondsPerDay = 24*60*60;
% number of epochs in a day
numberOfEpochsPerDay  = floor(numberOfSecondsPerDay/epoch);
% number of recorded epochs
numberOfEpochs        = length(data);
% number of full day recordings
numberOfDays          = ceil(numberOfEpochs/numberOfEpochsPerDay);
% allocate empty matrix for counts data in nepochs*ndays 
newData               = zeros(numberOfEpochsPerDay, numberOfDays+1);
% paste data from here onwards...
newData(iStartRecording:iStartRecording+numberOfEpochs-1)  = data;
% convert Counts and TimeSeries to double plot data 00:00 -> 00:00 -> 00:00
dataDoublePlot        = [newData(:, 1:numberOfDays)  ; newData(:, 2:end)  ];
end