function [entropy, conf95] = sampen(data, m, r)
% SAMPEN Calculate SampEn value
%
% Copyright (C) 2011 Maxim Osipov
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU Affero General Public License as published
% by the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Affero General Public License for more details.
%
% You should have received a copy of the GNU Affero General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% Description:
%   The function takes a column vector of data and calculates Sample
%   Entropy value of order m and similarity r.
%
% Arguments:
%   data - column vector with data
%   m - pattern length
%   r - similarity criteria (absolute value)
%
% Results:
%   entropy - Sample Entropy value
%

    len = length(data);
    % create an array of all m-templates
    tpl_len = len-m+1;
    tpl_data = zeros(tpl_len, m);
    i_tpl = 1;      % index of first template
    n_tpl = 0;      % length of first template series
    for i_data = 1:m,
        n_data = floor((len-i_data+1)/m)*m;
        i_tpl = i_tpl + n_tpl;
        n_tpl = floor(n_data/m);
        tpl_data(i_tpl:(i_tpl+n_tpl-1), :) =...
            reshape(data(i_data:(i_data+n_data-1)), m, n_tpl)';
    end
    % count template matches, excluding self-matches
    BB = zeros(1, tpl_len);
    tpl_data = repmat(tpl_data, 2, 1);
    for i_tpl = 2:tpl_len,
        tpl_diff = abs(tpl_data(1:tpl_len, :) -...
            tpl_data(i_tpl:i_tpl+tpl_len-1, :));
        BB(i_tpl-1) = sum(sum((tpl_diff < r), 2) == m);
    end
    B = sum(BB)/(len-m);
    % create an array of all m+1 templates
    mp = m+1;
    tpl_len = len-mp+1;
    tpl_data = zeros(tpl_len, mp);
    i_tpl = 1;      % index of first template
    n_tpl = 0;      % length of first template series
    for i_data = 1:mp,
        n_data = floor((len-i_data+1)/mp)*mp;
        i_tpl = i_tpl + n_tpl;
        n_tpl = floor(n_data/mp);
        tpl_data(i_tpl:(i_tpl+n_tpl-1), :) =...
            reshape(data(i_data:(i_data+n_data-1)), mp, n_tpl)';
    end
    % count template matches, excluding self-matches
    AA = zeros(1, tpl_len);
    tpl_data = repmat(tpl_data, 2, 1);
    for i_tpl = 2:tpl_len,
        tpl_diff = abs(tpl_data(1:tpl_len, :) -...
            tpl_data(i_tpl:i_tpl+tpl_len-1, :));
        AA(i_tpl-1) = sum(sum((tpl_diff < r), 2) == mp);
    end
    A = sum(AA)/(len-mp);
    
    % calculate value of sample entropy
    if (A<=0) || (B<=0),
        entropy = -log(1/(m*mp));
    else
        entropy = -log((A/(len-mp))/(B/(len-m)));
    end

    % calculate 95% confidence interval
    EE = AA(1:len-mp)./BB(1:len-mp);
    conf95 = std(EE)*tinv(0.95,length(EE))/sqrt(length(EE));
end

