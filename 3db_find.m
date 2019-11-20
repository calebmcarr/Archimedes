[~,maxi] = max(s21_GEN);
[~,3dblow] = min(abs(s21_GEN(1:maxi)+3));
[~,3dbhigh] = min(abs(s21_GEN(maxi:length(s21_GEN)-1)+3));
