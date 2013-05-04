function data = ga_load(file)
% GA_LOAD Load information from GENEActiv CSV file
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
%   file - Input file name
%
% Results:
%   data - structures with the following fields:
%     file - file name
%     id - study-specific measurement ID
%     date - measurement start date
%     time - measurement start time
%     sampling - sampling rate in min (only 1 and 2 are valid values)
%     age - person age
%     watch - watch serial number
%     sex - person sex
%     data - actual raw data
%     activity_x
%     activity_y
%     activity_z
%     light
%     button
%     temp
%

fid = fopen(file, 'r');
if (fid == -1)
    error('Could not open file %s', file);
end

% initialize results
data.file = file;
data.id = 'unknown';
data.date = '01-Jan-1900';
data.time = '00:00:00';
data.sampling = '1';
data.age = '0';
data.watch = '000000';
data.sex = 'M';
data.data = [];
data.activity_x = [];
data.activity_y = [];
data.activity_z = [];
data.light = [];
data.button = [];
data.temp = [];

% read file header
for i=1:3,
    string = fgetl(fid);
end
data.watch = sscanf(string, 'Device Unique Serial Code,%s', 1);
for i=1:8,
    string = fgetl(fid);
end
data.sampling = sscanf(string, 'Measurement Frequency,%i Hz', 1);
string = fgetl(fid);
data.date = sscanf(string, 'Start Time,%s', 1);
data.time = sscanf(string, ['Start Time,' data.date '%s'], 1);
data.time = data.time(1:8); % skip microseconds
for i=1:9,
    string = fgetl(fid);
end
data.id = sscanf(string, 'Subject Code,%s', 1);
string = fgetl(fid);
data.age = sscanf(string, 'Date of Birth,%s', 1);
string = fgetl(fid);
data.sex = sscanf(string, 'Sex,%s', 1);
if strcmp(data.sex, 'male'),
    data.sex = 'M';
else
    data.sex = 'F';
end

% read activity data
frewind(fid);
for i=1:101,
    string = fgetl(fid);
end
data.data = textscan(fid, '%s%f%f%f%f%f%f', 'Delimiter', ',');
fclose(fid);
data.activity_x = data.data{2};
data.activity_y = data.data{3};
data.activity_z = data.data{4};
data.light = data.data{5};
data.button = data.data{6};
data.temp = data.data{7};

% length of 3d vector
data.activity = sqrt(data.activity_x.^2 +...
                        data.activity_y.^2 +...
                        data.activity_z.^2);
