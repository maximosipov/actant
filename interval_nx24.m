function awd_i = interval_nx24(awd, n1, n2)
% INTERVAL_NX24 Select 24-hour aligned interval with start and end days
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
%   Returns 24-hour aligned interval with specified length and starting
%   day from unalighed AWD data structure.
%
% Arguments:
%   awd - AWD data structure
%   n1 - starting day, relative to the first day of recording
%   n2 - last day of the interval
%
% Results:
%   awd_i - AWD data structure with only selected interval of data
%

    data = awd.data;
    sampling = awd.sampling;
    time = awd.time;

    data_append = append_24(data, time, sampling);
    data_split = split_24(data_append, sampling);
    if n1 > size(data_split, 1) || n2 > size(data_split, 1) || n2 <= n1,
        error('INTERVAL_NX24: Invalid interval from %i to %i\n', n1, n2);
    end
    awd_i = awd;
    awd_i.data = unsplit_24(data_split(n1:n2,:,:));
    awd_i.time = '00:00:00';
    awd_i.date = datestr(addtodate(datenum(awd.date), n1-1, 'day'));

end
