function binnumber = bins(data, max, numBins)
% BINS Convert the waveform amplitude into bins
%
% Copyright (C) 2013 Bart te Lindert
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
%   data - N-by-1 column vector of accelerometry data 
%   max - Upper limit of amplitude to be divided in bins
%   numbins - Number of bins to divide range
%
% Results:
%   binnumber - N-by-1 column vector of bin number (between 0 and maxRange)

binedges = linspace(0, max, numBins+1);
[~, binnumber] = histc(abs(data), binedges);
