clear
close all
clc

% Pre definition
folderpath = 'D:\MasterThesis\analysis\data\spk\uri\';
numerosities = [3, 4, 5, 6, 7; 
    2, 2, 3, 3, 3; 
    5, 6, 7, 4, 4; 
    6, 7, 8, 9, 10]';

% pre allocation

% get file names
filelist = dir(fullfile(folderpath, '*.spk'));

names = {filelist.name};

% iterate over files
%for idx = 1:length(names)
for idx = 1:1   %placeholder for debugging
    placeholder_name = 'U250708';   %placeholder for debugging
    % load data
    %curr_file = names{idx}; % current file
    curr_file = placeholder_name;
    curr_spk = spk_read([folderpath curr_file]); % current spike data
    curr_resp = getresponsematrix(curr_spk); % current response matrix
    % correct the response matrix
    corr_resp = respmat_corr(curr_resp, numerosities);
end