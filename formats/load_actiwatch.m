function ts = load_actiwatch(file)
% LOAD_ACTIWATCH Load activity data from Actiwatch AWD file
%
% Description:
%   The function takes an AWD file with activity data and loads it into a
%   timeseries object (light data is ignored).
%
% Arguments:
%   file - Actiwatch AWD file name
%
% Results:
%   ts - Structure of timeseries
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

fid = fopen(file, 'r');
if (fid == -1)
    errordlg(['Could not open file ' file], 'Error', 'modal');
    return;
end

% read file header, ignore ID
fgetl(fid);
day = fgetl(fid);
hour = fgetl(fid);
% create datenum
start = datenum([day ' ' hour], 'dd-mmm-yyyy HH:MM');
sampling = fscanf(fid, '%u', 1);
if (sampling == 1)
    sampling = 15;
elseif (sampling == 2)
    sampling = 30;   
elseif (sampling == 4)
    sampling = 60;
elseif (sampling == 8)
    sampling = 120;
else
    errordlg('Unknown sampling rate', 'Error', 'modal');
    return;
end
% convert to datenum
sampling = sampling/(24*60*60);
fclose(fid);

% read activity data
% awd files sometimes contain 'M' strings in a second column, causing
% csvread to fail. Use textscan instead, and keep 1st column only.
%data = csvread(file, 7, 0);
fid = fopen(file);
    tmp = textscan(fid, '%f%s', 'headerlines', 7, 'delimiter', ',');
    data = tmp{:,1};
fclose(fid);

len = length(data);
time = linspace(start, start + sampling*(len - 1), len);

% create timeseries
ts.act = timeseries(data(:, 1), time, 'Name', 'ACT');
ts.act.DataInfo.Unit = 'counts';
ts.act.TimeInfo.Units = 'seconds';
%ts.act.TimeInfo.Increment = sampling;
ts.act.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

if size(data,2) == 2    
    ts.light = timeseries(data(:, 2), time, 'Name', 'LIGHT');
    ts.light.DataInfo.Unit = 'lux';
    ts.light.TimeInfo.Units = 'seconds';
    %ts.act.TimeInfo.Increment = sampling;
    ts.light.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
end

