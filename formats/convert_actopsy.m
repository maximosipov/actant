function status = convert_actopsy(fin, fout)
% LOAD_ACTOPSY Convert data from Actopsy CSV files to plain Actant MAT
%
% Description:
%   The function takes a CSV files with data from the Actopsy app and
%   resamples it to generate mean profile. The data can be acceleration,
%   light, calls/texts or location. For calls/texts markups are created
%   and for location distance travelled between two data samples.
%
% Arguments:
%   fin - Actopsy CSV file name
%   fout - Output MAT file name
%
% Results:
%   status - Logical conversion status
%
% Copyright (C) 2013, Maxim Osipov
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

% Request resulting epoch length
status = false;
fid = fopen(fin, 'r');
if (fid == -1)
    errordlg(['Could not open file ' fin], 'Error', 'modal');
    return;
end

% Check what file we've got
typestr = fgets(fid);
unitstr = fgets(fid);
if strcmp(typestr, sprintf('NAME,ACCX,ACCY,ACCZ\n')),
    type = 1;
    actant_datasets{1} = activity_light(type, fid, fin);
    actant_sources{1} = fin;
    save(fout, 'actant_sources', 'actant_datasets', '-v7.3');
elseif strcmp(typestr, sprintf('NAME,LIGHT\n')),
    type = 2;
    actant_datasets{1} = activity_light(type, fid, fin);
    actant_sources{1} = fin;
    save(fout, 'actant_sources', 'actant_datasets', '-v7.3');
elseif strcmp(typestr, sprintf('NAME,LAT,LON\n')),
    type = 3;
    actant_datasets{1} = location(type, fid, fin);
    actant_sources{1} = fin;
    save(fout, 'actant_sources', 'actant_datasets', '-v7.3');
elseif strcmp(typestr, sprintf('NAME,TYPE,DIR,ID,LENGTH\n')),
    type = 4;
    [actant_datasets{1} actant_datasets{2}] = calls_texts(type, fid, fin);
    actant_sources{1} = fin;
    actant_sources{2} = fin;
    save(fout, 'actant_sources', 'actant_datasets', '-v7.3');
else
    errordlg(sprintf(['Unknown data\n' typestr unitstr]), 'Error', 'modal');
    return;
end

% Save file
fclose(fid);
status = true;

function ts = activity_light(type, fid, fin)
    % Define waitbar increment (we are positioned just next to header)
    fi = dir(fin);
    fs = fi.bytes;
    tmp = fgets(fid);
    winc = length(tmp)/fs;
    % Ask about conversion epoch
    str = inputdlg('Epoch length (in seconds):', 'Epoch length', 1, {'60'});
    if (length(str) == 1),
        epoch = str2num(str{1});
    else
        epoch = 60;
    end
    % Create timeseries
    switch type,
        case 1,
            ts = timeseries('ACT');
            ts.DataInfo.Unit = 'm/s^2';
        case 2,
            ts = timeseries('LIGHT');
            ts.DataInfo.Unit = 'lux';
    end
    ts.TimeInfo.Units = 'days';
    ts.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    % Initialize conversion cycle
    block = 1000;
    wpos = 0;
    n = 1;
    tinc = 1*epoch/(24*60*60);
    hw = waitbar(0, 'Please wait while the data is converted...');
    switch type,
        case 1,
            tmp = textscan(tmp, '%s%f%f%f', 'Delimiter', ',');
            accum = abs(sqrt(tmp{2}.^2 + tmp{3}.^2 + tmp{4}.^2) - 9.81);
        case 2,
            tmp = textscan(tmp, '%s%f', 'Delimiter', ',');
            accum = tmp{2};
    end
    tpos = ceil(datenum(tmp{1}, 'yyyy-mm-dd HH:MM:SS.FFF')/tinc)*tinc;
    % Read/convert data in blocks
    while ~feof(fid),
        switch type,
            case 1,
                tmp = textscan(fid, '%s%f%f%f', block, 'Delimiter', ',');
                val = abs(sqrt(tmp{2}.^2 + tmp{3}.^2 + tmp{4}.^2) - 9.81);
            case 2,
                tmp = textscan(fid, '%s%f', block, 'Delimiter', ',');
                val = tmp{2};
        end
        time = datenum(tmp{1}, 'yyyy-mm-dd HH:MM:SS.FFF');
        % accumulate values for each period
        for i=1:length(time),
            if time(i) < tpos,
                accum = accum + val(i);
                n = n + 1;
            else
                ts = addsample(ts, 'Data', accum/n, 'Time', tpos);
                tpos = tpos + tinc;
                accum = val(i);
                n = 1;
            end
        end
        % update waitbar
        wpos = wpos + winc*block;
        if wpos > 1,
            wpos = 1;
        end
        waitbar(wpos, hw);
    end
    waitbar(1, hw);
    close (hw);


function ts = location(type, fid, fin)
    % Define waitbar increment (we are positioned just next to header)
    fi = dir(fin);
    fs = fi.bytes;
    tmp = fgets(fid);
    winc = length(tmp)/fs;
    % Create timeseries
    ts = timeseries('SPEED');
    ts.DataInfo.Unit = 'km/h';
    ts.TimeInfo.Units = 'days';
    ts.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    % Read/convert data
    hw = waitbar(0, 'Please wait while the data is converted...');
    wpos = 0;
    block = 1000;
    tmp = textscan(tmp, '%s%f%f', 'Delimiter', ',');
    time_prev = datenum(tmp{1}, 'yyyy-mm-dd HH:MM:SS.FFF');
    lat_prev = tmp{2};
    lon_prev = tmp{3};
    while ~feof(fid),
        tmp = textscan(fid, '%s%f%f', block, 'Delimiter', ',');
        time = datenum(tmp{1}, 'yyyy-mm-dd HH:MM:SS.FFF');
        lat = tmp{2};
        lon = tmp{3};
        % calculate distance from previous point
        for i=1:length(time),
            % cannot really calculate momentary speed
            if (time(i) > time_prev),
                % http://en.wikipedia.org/wiki/Great-circle_distance
                d_lat = degtorad(lat(i) - lat_prev);
                d_lon = degtorad(lon(i) - lon_prev);
                lat1 = degtorad(lat_prev);
                lat2 = degtorad(lat(i));
                a = sin(d_lat/2)^2 + (sin(d_lon/2)^2)*cos(lat1)*cos(lat2);
                c = 2*atan2(sqrt(a), sqrt(1-a));
                d = 6371*c; % in km
                speed = d/(time(i)-time_prev);
                ts = addsample(ts, 'Data', speed/24, 'Time', time(i));
            end
            time_prev = time(i);
            lat_prev = lat(i);
            lon_prev = lon(i);
        end
        % update waitbar
        wpos = wpos + winc*block;
        if wpos > 1,
            wpos = 1;
        end
        waitbar(wpos, hw);
    end
    waitbar(1, hw);
    close (hw);


function [calls texts] = calls_texts(type, fid, fin)
    texts = timeseries('TEXTS');
    texts.DataInfo.Unit = 'days';
    texts.TimeInfo.Units = 'days';
    texts.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    calls = timeseries('CALLS');
    calls.DataInfo.Unit = 'days';
    calls.TimeInfo.Units = 'days';
    calls.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    % Read/convert data
    hw = waitbar(0, 'Please wait while the data is converted...');
    block = 100;
    num_prev = '';
    len_prev = 0;
    while ~feof(fid),
        tmp = textscan(fid, '%s%s%s%s%f', block, 'Delimiter', ',');
        time = datenum(tmp{1}, 'yyyy-mm-dd HH:MM:SS.FFF');
        type = tmp{2};
        dir = tmp{3};
        num = tmp{4};
        len = tmp{5};
        % calculate distance from previous point
        for i=1:length(time),
            % cannot really calculate momentary speed
            if ~strcmp(num{i}, num_prev) && len(i) ~= len_prev,
                if strcmp(type(i), 'Call'),
                    texts = addsample(texts,...
                        'Data', time(i) + len(i)/(24*60*60), 'Time', time(i));
                elseif strcmp(type(i), 'Text'),
                    calls = addsample(calls,...
                        'Data', time(i) + len(i)/(24*60*60), 'Time', time(i));
                end
            end
            num_prev = num(i);
            len_prev = len(i);
        end
    end
    waitbar(1, hw);
    close (hw);
