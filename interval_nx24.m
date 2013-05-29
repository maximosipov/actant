function awd_i = interval_nx24(awd, n1, n2)
% INTERVAL_NX24 Select 24-hour aligned interval with start and end days
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
%   Returns 24-hour aligned interval with specified length and starting
%   day from unalighed AWD data structure.
%
% Arguments:
%   awd - AWD data structure
%   n1 - starting day, relative to the first day of recording
%   n2 - last day of the interval
%
% Results:
%   awd_i - AWD data structure with only selected interval of data
%

    data = awd.data;
    sampling = awd.sampling;
    time = awd.time;

    data_append = append_24(data, time, sampling);
    data_split = split_24(data_append, sampling);
    if n1 > size(data_split, 1) || n2 > size(data_split, 1) || n2 <= n1,
        error('INTERVAL_NX24: Invalid interval from %i to %i\n', n1, n2);
    end
    awd_i = awd;
    awd_i.data = unsplit_24(data_split(n1:n2,:,:));
    awd_i.time = '00:00:00';
    awd_i.date = datestr(addtodate(datenum(awd.date), n1-1, 'day'));

end
