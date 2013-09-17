function epochdata = mean2epochs(data, fs, epoch)
% MEAN2EPOCHS Converts data into epochs by taking the mean
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
%   Function 'mean2epochs' converts data to epochs of length epoch. It takes
%   the mean valuex per epoch length. 
%
% Arguments:
%   data - N-by-1 time series
%   fs - sampling frequency (Hz) of time series data
%   epoch - required epoch length in seconds
%
% Results:
%   epochdata - series of epochs with length epoch

% force column vector
data = data(:);                

% length in seconds
nepochs = floor(length(data)/(fs*epoch));  

% reshape data to epoch-by-epochs matrix
data = data(1:nepochs*fs*epoch);
data = reshape(data, fs*epoch, nepochs);

% average per epoch (i.e. across column)
epochdata = mean(data,1);

% force column vector
epochdata(:); 
end