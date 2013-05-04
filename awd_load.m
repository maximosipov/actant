function data = awd_load(awdfile)
% AWD_LOAD Load information from an AWD file
%
% Copyright (C) 2011-2012 Maxim Osipov
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
%   The function takes an AWD file with activity/light data and loads it 
%   into a structure.
%
% Arguments:
%   awdfile - AWD file name
%
% Results:
%   data - structures with the following fields:
%     file - file name (awdfile)
%     id - study-specific measurement ID
%     date - measurement start date
%     time - measurement start time
%     sampling - sampling rate in min (only 1 and 2 are valid values)
%     age - person age
%     watch - watch serial number
%     sex - person sex
%     data - actual data
%

    fid = fopen(awdfile, 'r');
    if (fid == -1)
        error('Could not open file %s', awdfile);
    end

    % initialize results
    data.file = awdfile;
    data.id = 'unknown';
    data.date = '01-Jan-1900';
    data.time = '00:00:00';
    data.sampling = 1;
    data.age = 0;
    data.watch = '000000';
    data.sex = 'M';
    data.data = [];

    % read file header
    data.id = fgetl(fid);
    data.date = fgetl(fid);
    data.time = fgetl(fid);
    data.sampling = fscanf(fid, '%u', 1);
    if (data.sampling == 4)
        data.sampling = 1;
    else if (data.sampling == 8)
            data.sampling = 2;
        end
    end
    data.age = fscanf(fid, '%u', 1);
    data.watch = fscanf(fid, '%s', 1);
    data.sex = fscanf(fid, '%s', 1);
    fclose(fid);
    
    % read activity data
    data.data = csvread(awdfile, 7, 0);
end
