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
all_resp_mat_nums_correct = {};
all_resp_mat_nums_total = {};
all_resp_mat_nums_perc = {};
sum_behaviour = zeros(3, 3, size(numerosities, 1), size(numerosities, 2));
% dim 1 = version to compute (1 = sum of perc, 2 = sums of correct, 3 = sums of total)
% dim 2 = pattern (1 = P1, 2 = P2, 3 = P3)
% dim 3 = sample (3-7)
% dim 4 = corresponding test (1 = match, 2 = test 1, 3 = test 2, 4 = test
% 3)
perc_behaviour = zeros(3, 3, size(numerosities, 1), size(numerosities, 2));

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
for idx = 1:length(names)
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
        number_table_correct = zeros(size(numerosities));
        number_table_total = zeros(size(numerosities));
        number_table_perc = zeros(size(numerosities));
        % iterate over sample numbers
        for sample_idx = 1:size(numerosities, 1)
            sample = numerosities(sample_idx, 1);   % curr sample
            resp_mat_samp = resp_mat_pat(resp_mat_pat(:, 3) == sample, :);
            rel_nums = numerosities(sample_idx, :);
            for num = 1:size(rel_nums, 2)
                % get relevant rows
                relevant_rows = resp_mat_samp(resp_mat_samp(:, 6) == rel_nums(num), :);
                % identify how many correct ones there are
                correct_trials = relevant_rows(relevant_rows(:, 5) == 0, :);
                number_table_correct(sample_idx, num) = size(correct_trials, 1);
                number_table_total(sample_idx, num) = size(relevant_rows, 1);
                number_table_perc(sample_idx, num) = size(correct_trials, 1) / size(relevant_rows, 1);
                % add to overview arrays
                sum_behaviour(1, pattern, sample_idx, num) = ...
                    sum_behaviour(1, pattern, sample_idx, num) + ...
                    number_table_perc(sample_idx, num);
                sum_behaviour(2, pattern, sample_idx, num) = ...
                    sum_behaviour(2, pattern, sample_idx, num) + ...
                    number_table_correct(sample_idx, num);
                sum_behaviour(3, pattern, sample_idx, num) = ...
                    sum_behaviour(3, pattern, sample_idx, num) + ...
                    number_table_correct(sample_idx, num);
            end
        end
        all_resp_mat_nums_correct{idx, pattern} = number_table_correct; % store the number table for current file
        all_resp_mat_nums_total{idx, pattern} = number_table_total; % store the number table for current file
        all_resp_mat_nums_perc{idx, pattern} = number_table_perc; % store the number table for current file
    end
end

% iterate over it again and take mean of each little version
% do i take mean over all percentages or sum the correct & total trials and
% divide this?

% no i should iterate over cell and then use mean() and std() for
% distribution of percs and 
% i think i can only take mean of percs since the amount of correct trials
% depend on amount of total trials...
% guess im a bit stoopid and should go home now...
% and maybe i shouldnt use 4d arrays and instead cells cuz this makes
% dimension reduction shitty again...


% iterate over patterns
for pattern = 1:size(all_resp_mat_patterns, 2)
    % iterate over samples
    for sample_idx = 1:size(numerosities, 1)
        % iterate over sample-tests
        for num = 1:size(numerosities, 2)
            % Average computation
            perc_behaviour(1, pattern, sample_idx, num) = ...
                sum_behaviour(1, pattern, sample_idx, num) / size(all_resp_mat, 2);
        end
    end
end







% Plot
% as all in one plot? or three next to each other?