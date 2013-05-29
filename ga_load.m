function data = ga_load(file)
% GA_LOAD Load information from GENEActiv CSV file
%
% Copyright (C) 2011-2013, Maxim Osipov
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
