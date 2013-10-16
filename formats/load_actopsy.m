function ts = load_actopsy(file)
% LOAD_ACTOPSY Load activity data from Actopsy CSV file
%
% Description:
%   The function takes a CSV files with activity data from the Actopsy app
%   and loads it into timeseries objects.
%
% Arguments:
%   file - CSV file name
%
% Results:
%   ts - Cell array of timeseries
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
    error('Could not open file %s', file);
end

% read activity data
tmp = textscan(fid, '%s%f%f%f', 'Delimiter', ',');
fclose(fid);
% ERROR: ignoring timezone here!
time = datenum(tmp{1}, 'yyyy-mm-dd HH:MM:SS.FFF');

% create timeseries
out.acc_x = timeseries(tmp{2}, time, 'Name', 'ACCX');
out.acc_x.DataInfo.Unit = 'm/s^2';
out.acc_x.TimeInfo.Units = 'days';
out.acc_x.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

out.acc_y = timeseries(tmp{3}, time, 'Name', 'ACCY');
out.acc_y.DataInfo.Unit = 'm/s^2';
out.acc_y.TimeInfo.Units = 'days';
out.acc_y.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

out.acc_z = timeseries(tmp{4}, time, 'Name', 'ACCZ');
out.acc_z.DataInfo.Unit = 'm/s^2';
out.acc_z.TimeInfo.Units = 'days';
out.acc_z.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

ts{1} = out.acc_x;
ts{2} = out.acc_y;
ts{3} = out.acc_z;
