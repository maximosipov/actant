function epochdata = maxrms2epochs(data, fs, epoch)
% MAXRMS2EPOCHS Converts data into epochs
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
%   Function maxrms2epochs converts data to epochs of length epoch. It takes 
%   the length of the xyz vector.
%
% Arguments:
%   data - N-by-1 time series
%   fs -  sampling frequency (Hz) of time series data
%   epoch - required epoch length (s)
%
% Results:
%   epochdata - series of epochs with length epoch

data = sqrt(data(:,1).^2 + data(:,2).^2 + data(:,3).^2);

% length in full seconds
seconds = floor(length(data)/fs);

% rectify
data = abs(data);       

% reshape data to samples/second-by-seconds matrix
data = data(1:seconds*fs);
data = reshape(data, fs, seconds);

% find max per second (i.e. across column)
data = max(data, [], 1);

% reshape data to epoch length-by-epochs matrix
data = data(:);
nepochs = floor(length(data)/epoch);
data = data(1:nepochs*epoch);

% sum per epoch (i.e. across column)
data = reshape(data, epoch, nepochs);
epochdata = sum(data,1);

% force column vector
epochdata = epochdata(:);  
end
