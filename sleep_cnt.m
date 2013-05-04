%
% Sleep/wake detection using Lotjonen method, only epoch of 1min supported!
%
% Copyright (C) 2011 Maxim Osipov
% 
% data - column array of activity data
%
% markup - sleep markup, where 0 is sleep and 1 is awake
%


function markup = awdsdet_cnt(data, thres)
    if nargin < 2,
        thres = 40;
    end
    % FIXME: Shift the data back to account for filtering shift
    coeff = [(1/25), (1/5+1/25), 1, (1/5+1/25), (1/25)];
    score = filter(coeff,1,data);
    markup = score > thres;
end
