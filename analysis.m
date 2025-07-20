clear
close all
clc

%% Pre definition
% Path definition
base_path = 'D:\MasterThesis\analysis\data\';
spk_folderpath = [base_path, 'spk\'];
rsp_mat_folderpath = [base_path, 'response_matrices\'];

who_analysis = {'humans\'; 'jello\'; 'uri\'};
current_who = 1;

% all numerosities relevant
numerosities = [3, 4, 5, 6, 7; % sample
    2, 2, 3, 3, 3;  % test 1 numbers
    5, 6, 7, 4, 4;  % test 2 numbers 
    6, 7, 8, 9, 10]';  % test 3 numbers
patterns = {'P1', 'P2', 'P3', 'PR'};


to_save = true; % if result shall be saved
to_correct = false; % if response matrices shall be corrected

% pre allocation
all_resp_mat = {};
all_resp_mat_patterns = {};
all_resp_mat_nums = {};

%% Correct Response Matrix
if to_correct
    % get file names
    path = [spk_folderpath, who_analysis{current_who}]; % adapt path
    filelist = dir(fullfile(path, '*.spk'));  % list of all spk files
    names = {filelist.name};

    % iterate over files
    for idx = 1:length(names)
        %for idx = 1:1   %placeholder for debugging
        placeholder_name = 'U250708';   %placeholder for debugging
        % load data
        curr_file = names{idx}; % current file
        %curr_file = placeholder_name;
        curr_spk = spk_read([path curr_file]); % current spike data
        curr_resp = getresponsematrix(curr_spk); % current response matrix
        % correct the response matrix
        corr_resp = respmat_corr(curr_resp, numerosities);

        % save the corrected response matrix
        if to_save
            save(fullfile(rsp_mat_folderpath, [curr_file, '_resp.mat']), 'corr_resp');
        end
    end
end

%% Sum Average Performance for each Pattern in Humans
% for now: just ignore division into standard & control lol

% Get Data
path = [rsp_mat_folderpath, who_analysis{current_who}]; % adapt path
filelist = dir(path);  % list of all data & subfolders
subfolders = filelist([filelist(:).isdir]); % extract subfolders
subfolders = {subfolders(3:end).name};  % list of subfolder names (experiments)

current_exp = 2;
exp_path = [path, subfolders{current_exp}, '\'];

filelist = dir(fullfile(exp_path, '*.mat'));  % list of all response matrices
names = {filelist.name};

% iterate over all files
for idx = 1:1
    % load data
    curr_file = names{idx};
    curr_resp = load([exp_path, curr_file]).corr_resp;
    % store in resp mat cell
    all_resp_mat{idx} = curr_resp;

    % divide into Patterns
    amount_patterns = unique(curr_resp(:, 2));
    amount_patterns = amount_patterns(1:end - 1);   % remove abunded trials for now
    
    for pattern = 1:length(amount_patterns)
        resp_mat_pat = curr_resp(curr_resp(:, 2) == pattern, :);
        all_resp_mat_patterns{idx, pattern} = resp_mat_pat;
        % extract it into each num
        % pre allocation
        number_table = zeros(size(numerosities));
        % iterate over sample numbers
        for sample_idx = 1:size(numerosities, 1)
            sample = numerosities(sample_idx, 1);   % curr sample
            resp_mat_samp = resp_mat_pat(resp_mat_pat(:, 3) == sample);
            rel_nums = numerosities(sample_idx, :);
            for num = 1:size(rel_nums)
                % get relevant rows
                relevant_rows = resp_mat_samp(resp_mat_samp(:, 6) == rel_nums(num));
                % identify how many correct ones there are
                correct_trials = relevant_rows(relevant_rows(:, 5) == 0);
                number_table(sample_idx, num) = size(correct_trials, 1) / size(relevant_rows, 1);
            end
        end
        all_resp_mat_nums{idx, pattern} = number_table; % store the number table for current file
    end
end

% iterate over it again and take mean of each little version








% Plot
% as all in one plot? or three next to each other?