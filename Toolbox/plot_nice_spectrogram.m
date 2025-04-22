% plot nice spectrogram

[a,b]=ReadCbinFile('wh03pu04_111223_091125.46.cbin'); % file mit WN = wh05rd05_070323_091839.73.cbin, ohne WN wh05rd05_060323_091201.29.cbin
lv_spectrogram(a,b); % in here: adjust black background 
set(gcf,'position',[100 100 1000 200])
set(gca,'xlim',[6.75 8.4]) % 1.9 6.0




