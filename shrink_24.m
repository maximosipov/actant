function data24 = shrink_24(data, time, sampling)
% SHRINK_24 Shrinks actimetry data to midnight start and end times
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
%   Input data cut at the start and end of the records to begin and end at
%   midnight (modulo 24 hours).
%
% Arguments:
%   data - column arrays of input data
%   time - record starting time
%   sampling - sampling frequency (in minutes)
%

    % get starting time
    hhmm = textscan(time, '%u', 2, 'delimiter', ':');
    hh = hhmm{1}(1);
    mm = hhmm{1}(2);
    if hh == 0 && mm == 0,
        start_adj = 1;
    else
        start_adj = fix((24*60 - ((hh*60)+mm))/sampling) + 1;
    end
    end_adj = size(data, 1) -...
        mod(size(data,1)-start_adj+1, (24*60)/sampling);
    
    % extend the data with zeros to start and finish at midnight 
    data24 = data(start_adj:end_adj, :);
end
