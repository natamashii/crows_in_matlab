function [performances, resp_freq, rec_times] = ...
    sort_behav(rsp_mat_folderpath, who_analysis, curr_exp, numerosities, patterns)

% function to load & extract performances/reaction times from response
% matrices

% Pre allocation
performances = zeros();
resp_freq = zeros();
rec_times = zeros();

% Get Data
path_resp = [rsp_mat_folderpath, who_analysis]; % adapt path
filelist_rsp = dir(path_resp);  % list of all data & subfolders
subfolders_rsp = filelist_rsp([filelist_rsp(:).isdir]); % extract subfolders
subfolders_rsp = {subfolders_rsp(3:end).name};  % list of subfolder names (experiments)

exp_path_resp = [path_resp, subfolders_rsp{curr_exp}, '\'];	% path with data of current experiment

filelist_rsp = dir(fullfile(exp_path_resp, '*.mat'));  % list of all response matrices
names_rsp = {filelist_rsp.name};	% file names

% iterate over all files
for idx = 1:length(names_rsp)
    % load response matrix
    curr_file_rsp = names_rsp{idx};
    curr_resp = load([exp_path_resp, curr_file_rsp]).corr_resp;

    % iterate over each pattern
    for pattern = 1:length(patterns)

        % iterate over samples
        for sample_idx = 1:size(numerosities, 1)
            rel_nums = numerosities(sample_idx, :);	% sample & test numbers

            % iterate over test numbers
            for test_idx = 1:size(numerosities, 2)
                curr_trials = curr_resp(curr_resp(:, 2) == pattern & ...
                    curr_resp(:, 3) == rel_nums(1) & ...
                    curr_resp(:, 5) ~= 9 & ...
                    curr_resp(:, 6) == rel_nums(test_idx), :);

                % get correct trials
                corr_trials = curr_trials(curr_trials(:, 5) == 0, :);
                % get indices of correct trials
                corr_idx = find(curr_resp(:, 2) == pattern & ...
                    curr_resp(:, 3) == rel_nums(1) & ...
                    curr_resp(:, 5) == 0 & ...
                    curr_resp(:, 6) == rel_nums(test_idx)); 

                % get error trials
                err_trials = curr_trials(curr_trials(:, 5) == 1, :);

                % compute response frequency
                % match trials: subject hit to match (correct trials)
                if test_idx == 1
                    resp_freq(idx, pattern, sample_idx, test_idx) = ...
                        size(corr_trials, 1) / ...
                        (size(corr_trials, 1) + size(err_trials, 1));
                    rec_times(idx, pattern, sample_idx, test_idx) = ...
                        [curr_react(corr_idx, 7)];
                % non-match trials: subject hit to non-match (error trials)
                else
                    resp_freq(idx, pattern, sample_idx, test_idx) = ...
                        size(err_trials, 1) / ...
                        (size(corr_trials, 1) + size(err_trials, 1));
                end
            end
            
            % compute performance
            curr_trials = curr_resp(curr_resp(:, 2) == pattern & ...
                    curr_resp(:, 3) == rel_nums(1) & ...
                    curr_resp(:, 5) ~= 9, :);
            % get correct trials
            corr_trials = curr_trials(curr_trials(:, 5) == 0, :);

            performances(idx, pattern, sample_idx) = ...
                size(corr_trials, 1) / size(curr_trials, 1);

        end
    end
end



end