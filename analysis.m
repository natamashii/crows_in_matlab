clear
close all
clc

folderpath = 'D:\MasterThesis\analysis\data\spk\';
filelist = dir(fullfile(folderpath, '*.spk'));

names = {filelist.name};

for idx = 1:length(names)
    curr_file = names{idx};
    dmn_gr_plot(extractBefore(curr_file, '.'))
end