function status = convert_actopsy(fin, fout, epoch)
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
%   epoch - Optional epoch length in seconds
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
    % Ask about conversion epoch
    if nargin == 2,
        str = inputdlg('Epoch length (in seconds):', 'Epoch length', 1, {'60'});
        if (length(str) == 1),
            epoch = str2num(str{1});
        else
            epoch = 60;
        end
    end
    ts = activity(fid, fin, epoch);
elseif strcmp(typestr, sprintf('NAME,ACCX,ACCY,ACCZ,ACC,COUNT\n')),
    % Do not convert
    ts = activity_noconv(fid, fin);
elseif strcmp(typestr, sprintf('NAME,LIGHT\n')),
    % Ask about conversion epoch
    if nargin == 2,
        str = inputdlg('Epoch length (in seconds):', 'Epoch length', 1, {'60'});
        if (length(str) == 1),
            epoch = str2num(str{1});
        else
            epoch = 60;
        end
    end
    ts = light(fid, fin, epoch);
elseif strcmp(typestr, sprintf('NAME,LIGHT,COUNT\n')),
    % Do not convert
    ts = light_noconv(fid, fin);
elseif strcmp(typestr, sprintf('NAME,LAT,LON\n')),
    ts = location(fid, fin);
elseif strcmp(typestr, sprintf('NAME,TYPE,DIR,ID,LENGTH\n')),
    ts = calls_texts(fid, fin);
elseif strcmp(typestr, sprintf('NAME,HAPPY+,CONFIDENT+,SLEEP-,TALK+,ACTIVITY+,ALTMAN\r\n')),
    ts = altman(fid, fin);
elseif strcmp(typestr, sprintf('NAME,ASLEEP,NIGHT_WAKE,EARLY_WAKE,SLEEP+,SAD+,APPETITE-,APPETITE+,WEIGHT-,WEIGHT+,CONCENTRATION,SELF-,SUICIDE,INTEREST-,ENERGY-,SLOW+,RESTLESS+,QIDS\r\n')),
    ts = qids(fid, fin);
else
    errordlg(sprintf(['Unknown data\n' typestr unitstr]), 'Error', 'modal');
    return;
end

% Save file
save(fout, '-struct', 'ts', '-v7.3');
fclose(fid);
status = true;

% Converts to localtime from yyyy-mm-dd HH:MM:SS.FFF+ZZZZ
function t = localtime(s)
        t = datenum(s, 'yyyy-mm-dd HH:MM:SS.FFF');
        zh = cellfun(@(x) x(24:26), s, 'UniformOutput', false);
        zm = cellfun(@(x) x(27:28), s, 'UniformOutput', false);
        zh_num = str2double(zh)/(24);
        zm_num = str2double(zm)/(24*60) .* sign(zh_num);
        t = t + zh_num/(24) + zm_num/(24*60);

function ts = activity(fid, fin, epoch)
    % Define waitbar increment (we are positioned just next to header)
    fi = dir(fin);
    fs = fi.bytes;
    tmp = fgets(fid);
    winc = length(tmp)/fs;
    % Create timeseries
    ts.acc_x = timeseries('ACC_X');
    ts.acc_x.DataInfo.Unit = 'm/s^2';
    ts.acc_x.TimeInfo.Units = 'days';
    ts.acc_x.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    ts.acc_y = timeseries('ACC_Y');
    ts.acc_y.DataInfo.Unit = 'm/s^2';
    ts.acc_y.TimeInfo.Units = 'days';
    ts.acc_y.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    ts.acc_z = timeseries('ACC_Z');
    ts.acc_z.DataInfo.Unit = 'm/s^2';
    ts.acc_z.TimeInfo.Units = 'days';
    ts.acc_z.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    ts.acc = timeseries('ACC');
    ts.acc.DataInfo.Unit = 'm/s^2';
    ts.acc.TimeInfo.Units = 'days';
    ts.acc.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    ts.acc_avg = timeseries('ACC_AVG');
    ts.acc_avg.DataInfo.Unit = 'm/s^2';
    ts.acc_avg.TimeInfo.Units = 'days';
    ts.acc_avg.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    % We may not have any data
    if tmp == -1,
        return;
    end
    % Initialize conversion cycle
    block = 1000;
    wpos = 0;
    n = 1;
    tinc = 1*epoch/(24*60*60);
    hw = waitbar(0, 'Please wait while the data is converted...');
    tmp = textscan(tmp, '%s%f%f%f', 'Delimiter', ',');
    accum = abs(sqrt(tmp{2}.^2 + tmp{3}.^2 + tmp{4}.^2) - 9.81);
    tpos = ceil(localtime(tmp{1})/tinc)*tinc;
    % Read/convert data in blocks
    while ~feof(fid),
        tmp = textscan(fid, '%s%f%f%f', block, 'Delimiter', ',');
        val = abs(sqrt(tmp{2}.^2 + tmp{3}.^2 + tmp{4}.^2) - 9.81);
        time = localtime(tmp{1});
        % add raw samples
        ts.acc_x = addsample(ts.acc_x, 'Data', tmp{2}, 'Time', time);
        ts.acc_y = addsample(ts.acc_y, 'Data', tmp{3}, 'Time', time);
        ts.acc_z = addsample(ts.acc_z, 'Data', tmp{4}, 'Time', time);
        ts.acc = addsample(ts.acc, 'Data', val, 'Time', time);
        % accumulate values for each period
        for i=1:length(time),
            if time(i) < tpos,
                accum = accum + val(i);
                n = n + 1;
            else
                ts.acc_avg = addsample(ts.acc_avg, 'Data', accum/n, 'Time', tpos);
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


function ts = activity_noconv(fid, fin)
    tmp = fgets(fid);
    % Create timeseries
    ts.acc_x = timeseries('ACC_X');
    ts.acc_x.DataInfo.Unit = 'm/s^2';
    ts.acc_x.TimeInfo.Units = 'days';
    ts.acc_x.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    ts.acc_y = timeseries('ACC_Y');
    ts.acc_y.DataInfo.Unit = 'm/s^2';
    ts.acc_y.TimeInfo.Units = 'days';
    ts.acc_y.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    ts.acc_z = timeseries('ACC_Z');
    ts.acc_z.DataInfo.Unit = 'm/s^2';
    ts.acc_z.TimeInfo.Units = 'days';
    ts.acc_z.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    ts.acc = timeseries('ACC');
    ts.acc.DataInfo.Unit = 'm/s^2';
    ts.acc.TimeInfo.Units = 'days';
    ts.acc.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    ts.count = timeseries('COUNT');
    ts.count.DataInfo.Unit = 'samples';
    ts.count.TimeInfo.Units = 'days';
    ts.count.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    % We may not have any data
    if tmp == -1,
        return;
    end
    % Read/convert data in blocks
    tmp = textscan(fid, '%s%f%f%f%f%f', 'Delimiter', ',');
    time = localtime(tmp{1});
    % add raw samples
    ts.acc_x = addsample(ts.acc_x, 'Data', tmp{2}, 'Time', time);
    ts.acc_y = addsample(ts.acc_y, 'Data', tmp{3}, 'Time', time);
    ts.acc_z = addsample(ts.acc_z, 'Data', tmp{4}, 'Time', time);
    ts.acc = addsample(ts.acc, 'Data', tmp{5}, 'Time', time);
    ts.count = addsample(ts.count, 'Data', tmp{6}, 'Time', time);


function ts = light_noconv(fid, fin)
    tmp = fgets(fid);
    % Create timeseries
    ts.light = timeseries('LIGHT');
    ts.light.DataInfo.Unit = 'lux';
    ts.light.TimeInfo.Units = 'days';
    ts.light.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    ts.count = timeseries('COUNT');
    ts.count.DataInfo.Unit = 'samples';
    ts.count.TimeInfo.Units = 'days';
    ts.count.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    % We may not have any data
    if tmp == -1,
        return;
    end
    % Read/convert data in blocks
    tmp = textscan(fid, '%s%f%f', 'Delimiter', ',');
    time = localtime(tmp{1});
    % add raw samples
    ts.light = addsample(ts.light, 'Data', tmp{2}, 'Time', time);
    ts.count = addsample(ts.count, 'Data', tmp{3}, 'Time', time);


function ts = light(fid, fin, epoch)
    % Define waitbar increment (we are positioned just next to header)
    fi = dir(fin);
    fs = fi.bytes;
    tmp = fgets(fid);
    winc = length(tmp)/fs;
    % Create timeseries
    ts.light = timeseries('LIGHT');
    ts.light.DataInfo.Unit = 'lux';
    ts.light.TimeInfo.Units = 'days';
    ts.light.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    ts.light_avg = timeseries('LIGHT_AVG');
    ts.light_avg.DataInfo.Unit = 'lux';
    ts.light_avg.TimeInfo.Units = 'days';
    ts.light_avg.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    % We may not have any data
    if tmp == -1,
        return;
    end
    % Initialize conversion cycle
    block = 1000;
    wpos = 0;
    n = 1;
    tinc = 1*epoch/(24*60*60);
    hw = waitbar(0, 'Please wait while the data is converted...');
    tmp = textscan(tmp, '%s%f', 'Delimiter', ',');
    accum = tmp{2};
    tpos = ceil(localtime(tmp{1})/tinc)*tinc;
    % Read/convert data in blocks
    while ~feof(fid),
        tmp = textscan(fid, '%s%f', block, 'Delimiter', ',');
        val = tmp{2};
        time = localtime(tmp{1});
        ts.light = addsample(ts.light, 'Data', val, 'Time', time);
        % accumulate values for each period
        for i=1:length(time),
            if time(i) < tpos,
                accum = accum + val(i);
                n = n + 1;
            else
                ts.light_avg = addsample(ts.light_avg, 'Data', accum/n, 'Time', tpos);
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


function ts = location(fid, fin)
    % Define waitbar increment (we are positioned just next to header)
    fi = dir(fin);
    fs = fi.bytes;
    tmp = fgets(fid);
    winc = length(tmp)/fs;
    % Create timeseries
    ts.lat = timeseries('LAT');
    ts.lat.DataInfo.Unit = 'deg';
    ts.lat.TimeInfo.Units = 'days';
    ts.lat.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    ts.lon = timeseries('LON');
    ts.lon.DataInfo.Unit = 'deg';
    ts.lon.TimeInfo.Units = 'days';
    ts.lon.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    ts.speed = timeseries('SPEED');
    ts.speed.DataInfo.Unit = 'km/h';
    ts.speed.TimeInfo.Units = 'days';
    ts.speed.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    % We may not have any data
    if tmp == -1,
        return;
    end
    % Read/convert data
    hw = waitbar(0, 'Please wait while the data is converted...');
    wpos = 0;
    block = 100;
    tmp = textscan(tmp, '%s%f%f', 'Delimiter', ',');
    time_prev = localtime(tmp{1});
    lat_prev = tmp{2};
    lon_prev = tmp{3};
    ts.lat = addsample(ts.lat, 'Data', lat_prev, 'Time', time_prev);
    ts.lon = addsample(ts.lon, 'Data', lon_prev, 'Time', time_prev);
    while ~feof(fid),
        tmp = textscan(fid, '%s%f%f', block, 'Delimiter', ',');
        time = localtime(tmp{1});
        lat = tmp{2};
        lon = tmp{3};
        ts.lat = addsample(ts.lat, 'Data', lat, 'Time', time);
        ts.lon = addsample(ts.lon, 'Data', lon, 'Time', time);
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
                ts.speed = addsample(ts.speed, 'Data', speed/24, 'Time', time(i));
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


function ts = calls_texts(fid, fin)
    ts.texts = timeseries('TEXTS');
    ts.texts.DataInfo.Unit = 'days';
    ts.texts.TimeInfo.Units = 'days';
    ts.texts.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    ts.calls = timeseries('CALLS');
    ts.calls.DataInfo.Unit = 'days';
    ts.calls.TimeInfo.Units = 'days';
    ts.calls.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    % Read/convert data
    hw = waitbar(0, 'Please wait while the data is converted...');
    block = 100;
    num_prev = '';
    len_prev = 0;
    while ~feof(fid),
        tmp = textscan(fid, '%s%s%s%s%f', block, 'Delimiter', ',');
        time = localtime(tmp{1});
        type = tmp{2};
        dir = tmp{3};
        num = tmp{4};
        len = tmp{5};
        % calculate distance from previous point
        for i=1:length(time),
            % cannot really calculate momentary speed
            if ~strcmp(num{i}, num_prev) && len(i) ~= len_prev,
                if strcmp(type(i), 'Call'),
                    ts.texts = addsample(ts.texts,...
                        'Data', time(i) + len(i)/(24*60*60), 'Time', time(i));
                elseif strcmp(type(i), 'Text'),
                    ts.calls = addsample(ts.calls,...
                        'Data', time(i) + len(i)/(24*60*60), 'Time', time(i));
                end
            end
            num_prev = num(i);
            len_prev = len(i);
        end
    end
    waitbar(1, hw);
    close (hw);


function ts = altman(fid, fin)
    ts.happy_p = timeseries('HAPPY+');
    ts.confident_p = timeseries('CONFIDENT+');
    ts.sleep_m = timeseries('SLEEP-');
    ts.talk_p = timeseries('TALK+');
    ts.activity_p = timeseries('ACTIVITY+');
    ts.altman = timeseries('ALTMAN');
    fields = fieldnames(ts);
    for i=1:numel(fields),
        ts.(fields{i}).DataInfo.Unit = 'days';
        ts.(fields{i}).TimeInfo.Units = 'days';
        ts.(fields{i}).TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    end
    % Read/convert data
    hw = waitbar(0, 'Please wait while the data is converted...');
    tmp = textscan(fid, '%s%f%f%f%f%f%f', 'Delimiter', ',');
    time = datenum(tmp{1}, 'yyyy-mm-dd HH:MM:SS');
    for i=1:numel(fields),
        ts.(fields{i}) = addsample(ts.(fields{i}), 'Data', tmp{i+1}, 'Time', time);
    end
    waitbar(1, hw);
    close (hw);


function ts = qids(fid, fin)
    ts.asleep = timeseries('ASLEEP');
    ts.night_wake = timeseries('NIGHT_WAKE');
    ts.early_wake = timeseries('EARLY_WAKE');
    ts.sleep_m = timeseries('SLEEP+');
    ts.sad_p = timeseries('SAD+');
    ts.appetite_m = timeseries('APPETITE-');
    ts.appetite_p = timeseries('APPETITE+');
    ts.weight_m = timeseries('WEIGHT-');
    ts.weight_p = timeseries('WEIGHT+');
    ts.concentration = timeseries('CONCENTRATION');
    ts.self_m = timeseries('SELF-');
    ts.suicide = timeseries('SUICIDE');
    ts.interest_m = timeseries('INTEREST-');
    ts.energy_m = timeseries('ENERGY-');
    ts.slow_p = timeseries('SLOW+');
    ts.restless_p = timeseries('RESTLESS+');
    ts.qids = timeseries('QIDS');
    fields = fieldnames(ts);
    for i=1:numel(fields),
        ts.(fields{i}).DataInfo.Unit = 'days';
        ts.(fields{i}).TimeInfo.Units = 'days';
        ts.(fields{i}).TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
    end
    % Read/convert data
    hw = waitbar(0, 'Please wait while the data is converted...');
    tmp = textscan(fid, '%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f', 'Delimiter', ',');
    time = datenum(tmp{1}, 'yyyy-mm-dd HH:MM:SS');
    for i=1:numel(fields),
        ts.(fields{i}) = addsample(ts.(fields{i}), 'Data', tmp{i+1}, 'Time', time);
    end
    waitbar(1, hw);
    close (hw);
