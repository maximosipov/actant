function epochdata = max2epochs(data, fs, epoch)
% MAX2EPOCHS Aggregates maximal values per second across epochs
%
% Description:
%   The function converts a time series to epochs of length epoch. It will 
%   pick the peak values per second and sums these values over the epoch 
%   This is an pre-processing step that is performed online on the 
%   CamNtech/Respironics AWD/AWL devices
%
% Arguments:
%   data - input data timeseries
%   fs - sampling frequency of the data
%   epoch - required epoch length in seconds
%
% Results:
%   epochdata - series of epochs
%
% See also MEAN2EPOCHS
%
% Copyright (C) 2011-2013, Bart te Lindert
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

% force column vector
data = data(:); 

% length in full seconds
seconds = floor(length(data)/fs);

% rectify
data = abs(data);       

% reshape data to samples-by-seconds matrix
data = data(1:seconds*fs);
data = reshape(data, fs, seconds);

% find max per second (i.e. across column)
data = max(data, [], 1);

% reshape data to epoch-by-epochs matrix
data = data(:);
N = length(data);
nepochs = floor(N/epoch);
data = data(1:nepochs*epoch);

% sum per epoch (i.e. across column)
data = reshape(data, epoch, nepochs);
epochdata = sum(data, 1);

epochdata = epochdata(:);   % force column vector
end
