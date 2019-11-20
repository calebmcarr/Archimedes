function [f1, f2, cf] = find3db(sparam, freq)
    [M,maxi] = max(sparam);
    b = fliplr(sparam(1:maxi));
    low3db = find(b<=(M-3),1);
    low3db = maxi - low3db;
    c = sparam(maxi:length(sparam)-1);
    high3db = find(c<=(M-3),1);
    high3db = maxi + high3db;
    f1 = freq(low3db);
    f2 = freq(high3db);
    if (f2/f1 >= 1.1)
        cf = sqrt(f1*f2);
    else
        cf = (f1 + f2)/2;
    end