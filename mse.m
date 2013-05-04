function [entropy, conf95] = mse(data, m, r, s, cb)
% MSE Calculate multi scale entropy using SampEn algorithm
%
% Copyright (C) 2011 Maxim Osipov
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU Affero General Public License as published
% by the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Affero General Public License for more details.
%
% You should have received a copy of the GNU Affero General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% Description:
%   The function takes a column vector of data and calculates Multi-Scale
%   Entropy of order m, similarity r and for scales from the s vector.
%
% Arguments:
%   data - column vector with data
%   m - pattern length
%   r - similarity criteria (% of std)
%   s - scales vector
%   cb - callback function to be called after each scale processing
%
% Results:
%   entropy - vector with entropy (length of scales)
%

    R = r*std(data);
    len_orig = length(data);
    entropy = zeros(1, length(s));
    conf95 = zeros(1, length(s));
    for i = 1:length(s),
        len_coarse = floor(len_orig/s(i));
        % coarse grain
        coarse = sum(reshape(...
            data(1:(len_orig-rem(len_orig,s(i)))),...
            s(i), len_coarse), 1)'./s(i);
        % calculate sample entropy
        [entropy(i), conf95(i)] = sampen(coarse, m, R);
        if exist('cb', 'var'),
            cb(length(s),i);
        end
    end
end
