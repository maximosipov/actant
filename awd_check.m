%
% Check validity of input data and print diagnostic information.
%
% Copyright (C) 2011 Maxim Osipov
% 
% awddata - input array with the following elements
%   {1} file - file name
%   {2} condition - 'sz', 'ctl', 'afd', 'afdh', 'afdl'
%   {3} subject - textual subject ID
%   {4} comment - textual comment, usually name of originator
%   {5} id - study-specific measurement ID
%   {6} date - measurement start date
%   {7} time - measurement start time
%   {8} sampling - sampling rate in min (only 1 and 2 are valid values)
%   {9} age - person age
%   {10} watch - watch serial number
%   {11} sex - person sex
%   {12} data - actual data
%


function awdcheck(awddata)
    for i = 1:length(awddata),
        if strcmp(awddata(i).sex, 'M') == 0,
            if strcmp(awddata(i).sex, 'F') == 0;
                fprintf(1, '%s: sex %s\n', awddata(i).file, awddata(i).sex);
            end
        end
    end
end
