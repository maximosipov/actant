function data24 = unsplit_24(data_split)
% UNSPLIT_24 Un-split array of 24 hours x N days x M vars to column vectors
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
%   Receives a matrix of 24 hours x N days x M variables and converts it to
%   column vectors of values.
%
% Arguments:
%   data_split - 24 hours (row) x N days (col) x 2 (act,light)
%
% Results:
%   data_24 - column vectors of data
%
% See also SPLIT_24.

    points = size(data_split,1)*size(data_split,2);
    vars = size(data_split,3);
    data24 = zeros(points, vars);
    for i = 1:vars,
        data24(:,i) = reshape(data_split(:,:,i)', [points 1]);
    end;
end
