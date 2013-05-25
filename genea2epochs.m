function [countEpochs luxEpochs tempEpochs] = genea2epochs(zdata, lux, temperature, fs)
% GENEA2EPOCHS Convert the waveform amplitude into bins
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
%   Function genea2epochs converts the raw waveform of z-axis data, light 
%   and temperature data sampled at 'fs' Hz to epochs of 'epoch' duration. 
%   Accelerometer data will be filtered and regressed to obtain Actiwatch 
%   equivalent counts
%
% Arguments:
%   z - N-by-1 column vector of Geneactiv z-axis accelerometer data
%   lux - N-by-1 column vector of light recording
%   temperature - N-by-1 column vector of temperature data
%   fs - sampling frequency of data
%
% Results:
%   countEpochs - time series with sum of second max counts/epoch
%   luxEpochs - time series with mean lux per epoch
%   tempEpochs - time series of mean temperature per epoch

% filter characteristics
threshold   = 18;
cf_low      = 3;                % lower cut off frequency (Hz)
cf_hi       = 11;               % upper cut off frequency (Hz)
order       = 5;                % filter order
pass        = 'bandpass';       % filter type
w1          = cf_low/(fs/2);    % normalized lower frequency
w2          = cf_hi/(fs/2);     % normalized upper frequency
[b, a]      = butter(order,[w1 w2],pass); 

% bandpass filter z-axis data
zfiltered = filtfilt(b, a, zdata);

% convert data to bins
zbinned = bins(zfiltered, 5, 128);

% convert to 15s epochs
countEpochs = max2epochs(zbinned, fs, 15);

% subtract threshold and multiply with factor 
% (see te Lindert & van Someren, 2013)
countEpochs = (countEpochs-threshold).*3.07;

% set all negative values to 0
indices         = countEpochs < 0;
countEpochs(indices) = 0;
luxEpochs       = mean2epochs(lux, fs, 15);
tempEpochs      = mean2epochs(temperature, fs, 15);

end    