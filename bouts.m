function nbouts = bouts(indices)
% BOUTS Calculates average duration of a continous wake or sleep bout
%
% Copyright (C) 2013 Bart te Lindert
%
% Copyright (c) 2011-2013 Bart te Lindert
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
%
% The MIT License (MIT) / http://opensource.org/licenses/MIT 
%
% Description:
%   Function bouts calculates the duration of a continous wake or sleep bout
%
% Arguments:
%   indices - indices of wake/sleep epochs (i.e. activity above/below a given
%   threshold)
%
% Results:
%   nbouts - N-by-1 vector of bout duration in epochs;
%            length(nbouts) = number of continuous bouts

b = 1;
nbouts(b) = 1;
for p = 2:length(indices)
    % check for new bout
    if indices(p-1) ~= indices(p)-1 
        % new bout
        b = b+1;
        nbouts(b) = 1;
    else % same bout
        % add 1 to length
        nbouts(b) = nbouts(b)+1;
    end
end