function data = awd_load(awdfile)
% AWD_LOAD Load information from an AWD file
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
