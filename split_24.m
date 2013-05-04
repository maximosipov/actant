function data_split = split_24(data, sampling)
% SPLIT_24 Split actimetry to an array of 24 hours x N days x M vars
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
%   Receives the alighned to 00:00 time vectors of input data and splits it
%   into 24 hours x N days array for further analysis.
%
% Arguments:
%   data - column vectors of data starting and ending at 00:00 (adjust_24)
%   sampling - sampling frequency (in min)
%
% Results:
%   data_split - 24 hours (row) x N days (col) x 2 (act,light)
%
% See also ADJUST_24.
%

    day = 24*60/sampling;
    days = size(data,1)/day;
    data_split = zeros(days, day, size(data,2));
    for i = 0:(days-1),
        data_split(i+1,:,:) =...
            reshape(data((i*day+1):((i+1)*day),:), [1 day size(data,2)]);
    end;
end
