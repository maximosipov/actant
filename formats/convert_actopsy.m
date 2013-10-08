function status = convert_actopsy(fin, fout)
% LOAD_ACTOPSY Convert activity data from Actopsy CSV file to plain
%              activity MAT
%
% Description:
%   The function takes a CSV files with activity data from the Actopsy app
%   and resamples it to generate mean activity profile.
%
% Arguments:
%   fin - Actopsy CSV file name
%   fout - Output MAT file name
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
    errordlg(['Could not open file ' fin]);
    return;
end

% Define waitbar increment and initialize time
fi = dir(fin);
fs = fi.bytes;
tmp = fgets(fid);
tmp = fgets(fid);
ls = fgets(fid);
winc = length(ls)/fs;
frewind(fid);

% Check what file we've got
typestr = fgets(fid);
unitstr = fgets(fid);
if (~strcmp(typestr, sprintf('NAME,ACCX,ACCY,ACCZ\n'))),
    errordlg(sprintf(['Unknown data\n' typestr unitstr]));
    return;
end

% Ask about conversion epoch
str = inputdlg('Epoch length (in seconds):',...
    'Epoch length', 1, {'60'});
if (length(str) == 1),
    epoch = str2num(str{1});
else
    epoch = 60;
end

% Create timeseries
act = timeseries('ACT');
act.DataInfo.Unit = 'm/s^2';
act.TimeInfo.Units = 'days';
act.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

% Read/convert data
hw = waitbar(0, 'Please wait while the plot is updated...');
tmp = textscan(ls, '%s%f%f%f', 'Delimiter', ',');
block = 1000;
wpos = 0;
accum = 0;
n = 0;
tinc = 1*epoch/(24*60*60);
tpos = ceil(datenum(tmp{1}, 'yyyy-mm-dd HH:MM:SS.FFF')/tinc)*tinc;
while ~feof(fid),
    tmp = textscan(fid, '%s%f%f%f', block, 'Delimiter', ',');
    acc = abs(sqrt(tmp{2}.^2 + tmp{3}.^2 + tmp{4}.^2) - 9.81);
    time = datenum(tmp{1}, 'yyyy-mm-dd HH:MM:SS.FFF');
    % accumulate values for each period
    for i=1:length(time),
        if time(i) < tpos,
            accum = accum + acc(i);
            n = n + 1;
        else
            act = addsample(act, 'Data', accum/n, 'Time', tpos);
            tpos = tpos + tinc;
            accum = acc(i);
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

% Save file
save(fout, 'act', '-v7.3');

waitbar(1, hw);
close (hw);
fclose(fid);
status = true;

