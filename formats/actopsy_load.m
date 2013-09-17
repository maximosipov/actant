function data = actopsy_load(dirname)
% ACTOPSY_LOAD Load information from Actopsy CSV files directory
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
%   The function takes a CSV files with activity data from the Actopsy app
%   and loads it into a structure.
%
% Arguments:
%   dir - Input directory name
%
% Results:
%   data - structures with the following fields:
%     ts - vector of timestamps
%     acc_x - X acceleration
%     acc_y - Y acceleration
%     acc_z - Z acceleration
%

files = dir([dirname '/*.csv']);

% initialize results
data.ts = [];
data.acc_x = [];
data.acc_y = [];
data.acc_z = [];

for i=1:length(files),
    fid = fopen([dirname '/' files(i).name], 'r');
    if (fid == -1)
        error('Could not open file %s', files(i).name);
    end
    % read activity data
    tmp = textscan(fid, '%s%f%f%f', 'Delimiter', ',');
    fclose(fid);
    % ERROR: ignoring timezone here!
    data.ts = [data.ts; datenum(tmp{1}, 'yyyy-mm-dd HH:MM:SS.FFF')];
    data.acc_x = [data.acc_x; tmp{2}];
    data.acc_y = [data.acc_y; tmp{3}];
    data.acc_z = [data.acc_z; tmp{4}];
end