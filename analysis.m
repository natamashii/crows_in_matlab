clear
close all
clc

%% Pre definition
% Path definition
folderpath = 'D:\MasterThesis\analysis\data\spk\humans\';
save_basis = 'D:\MasterThesis\analysis\data\';
save_rsp_mat = [save_basis, 'response_matrices\'];

% all numerosities relevant
numerosities = [3, 4, 5, 6, 7; % sample
    2, 2, 3, 3, 3;  % test 1 numbers
    5, 6, 7, 4, 4;  % test 2 numbers 
    6, 7, 8, 9, 10]';  % test 3 numbers

to_save = true;

% pre allocation

% get file names
filelist = dir(fullfile(folderpath, '*.spk'));  % list of all 
names = {filelist.name};

% iterate over files
for idx = 1:length(names)
%for idx = 1:1   %placeholder for debugging
    placeholder_name = 'U250708';   %placeholder for debugging
    % load data
    curr_file = names{idx}; % current file
    %curr_file = placeholder_name;
    curr_spk = spk_read([folderpath curr_file]); % current spike data
    curr_resp = getresponsematrix(curr_spk); % current response matrix
    % correct the response matrix
    corr_resp = respmat_corr(curr_resp, numerosities);

    % save the corrected response matrix
    if to_save
        save(fullfile(save_rsp_mat, [curr_file, '_resp.mat']), 'corr_resp');
    end
end