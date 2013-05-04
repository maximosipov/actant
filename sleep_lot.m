%
% Sleep/wake detection using Lotjonen method. Doesn't work actually.
%
% Copyright (C) 2011 Maxim Osipov
% 
% data - column array of activity data
%
% markup - sleep markup, where 0 is sleep and 1 is activity
%


function markup = awdsdet_lot(data)
    markup = zeros(length(data),1);
    for i = (1+11):(length(data)-11),
        s = data(i);
        mn = mean(data(i-7:i+7));
        nat = sum(data(i-11:i+11)>10);
        sd = std(data(i-8:i+8));
        ln = log(data(i)+0.1);
        markup(i) = 1.687 + 0.003*s - 0.034*mn -...
            0.419*nat + 0.007*sd - 0.127*ln;
    end
end
