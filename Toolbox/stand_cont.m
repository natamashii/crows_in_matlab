function [performances_s, performances_c, ...
        resp_freq_s, resp_freq_c, rec_times_s, rec_times_c] = ...
        stand_cont(rsp_mat_path, who_analysis, ...
        exp_idx, numerosities, patterns)

% Function to load from response matrices, divided into standard/control

% Get Data
path_resp = [rsp_mat_path, who_analysis]; % adapt path
filelist_rsp = dir(path_resp);  % list of all data & subfolders
subfolders_rsp = filelist_rsp([filelist_rsp(:).isdir]); % extract subfolders
subfolders_rsp = {subfolders_rsp(3:end).name};  % list of subfolder names (experiments)

exp_path_resp = [path_resp, subfolders_rsp{exp_idx}, '\'];	% path with data of current experiment

filelist_rsp = dir(fullfile(exp_path_resp, '*.mat'));  % list of all response matrices
names_rsp = {filelist_rsp.name};	% file names

% Pre allocation
performances_s = zeros(length(names_rsp), length(patterns), ...
    size(numerosities, 1), size(numerosities, 2));
resp_freq_s = zeros(length(names_rsp), length(patterns), ...
    size(numerosities, 1), size(numerosities, 2));
rec_times_s = cell(length(names_rsp), length(patterns), ...
    size(numerosities, 1), size(numerosities, 2));
performances_c = zeros(length(names_rsp), length(patterns), ...
    size(numerosities, 1), size(numerosities, 2));
resp_freq_c = zeros(length(names_rsp), length(patterns), ...
    size(numerosities, 1), size(numerosities, 2));
rec_times_c = cell(length(names_rsp), length(patterns), ...
    size(numerosities, 1), size(numerosities, 2));

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
                % get current trials: Standard Conditions
                curr_trials = curr_resp(curr_resp(:, 1) == 1 & ...
                    curr_resp(:, 2) == pattern & ...
                    curr_resp(:, 3) == rel_nums(1) & ...
                    curr_resp(:, 5) ~= 9 & ...
                    curr_resp(:, 6) == rel_nums(test_idx), :);

                % get indices of correct trials
                corr_idx = find(curr_resp(:, 1) == 1 & ...
                    curr_resp(:, 2) == pattern & ...
                    curr_resp(:, 3) == rel_nums(1) & ...
                    curr_resp(:, 5) == 0 & ...
                    curr_resp(:, 6) == rel_nums(test_idx));

                % get correct trials
                corr_trials = curr_trials(curr_trials(:, 5) == 0, :);
                % get error trials
                err_trials = curr_trials(curr_trials(:, 5) == 1, :);

                % Reaction Times
                rec_times_s{idx, pattern, sample_idx, test_idx} = ...
                    [curr_resp(corr_idx, 7)];

                % Performance
                performances_s(idx, pattern, sample_idx, test_idx) = ...
                    size(corr_trials, 1) / ...
                    (size(corr_trials, 1) + size(err_trials, 1));

                % Response Frequency
                % match trials: subject hit match (correct trials)
                if test_idx == 1
                    resp_freq_s(idx, pattern, sample_idx, test_idx) = ...
                        size(corr_trials, 1) / ...
                        (size(corr_trials, 1) + size(err_trials, 1));
                % non-match trials: subject hit non-match (error trials)
                else
                    resp_freq_s(idx, pattern, sample_idx, test_idx) = ...
                        size(err_trials, 1) / ...
                        (size(corr_trials, 1) + size(err_trials, 1));
                end

                % get current trials: Control Conditions
                curr_trials = curr_resp(curr_resp(:, 1) == 2 & ...
                    curr_resp(:, 2) == pattern & ...
                    curr_resp(:, 3) == rel_nums(1) & ...
                    curr_resp(:, 5) ~= 9 & ...
                    curr_resp(:, 6) == rel_nums(test_idx), :);

                % get indices of correct trials
                corr_idx = find(curr_resp(:, 1) == 2 & ...
                    curr_resp(:, 2) == pattern & ...
                    curr_resp(:, 3) == rel_nums(1) & ...
                    curr_resp(:, 5) == 0 & ...
                    curr_resp(:, 6) == rel_nums(test_idx));

                % get correct trials
                corr_trials = curr_trials(curr_trials(:, 5) == 0, :);
                % get error trials
                err_trials = curr_trials(curr_trials(:, 5) == 1, :);

                % Reaction Times
                rec_times_c{idx, pattern, sample_idx, test_idx} = ...
                    [curr_resp(corr_idx, 7)];

                % Performance
                performances_c(idx, pattern, sample_idx, test_idx) = ...
                    size(corr_trials, 1) / ...
                    (size(corr_trials, 1) + size(err_trials, 1));

                % Response Frequency
                % match trials: subject hit match (correct trials)
                if test_idx == 1
                    resp_freq_c(idx, pattern, sample_idx, test_idx) = ...
                        size(corr_trials, 1) / ...
                        (size(corr_trials, 1) + size(err_trials, 1));
                % non-match trials: subject hit non-match (error trials)
                else
                    resp_freq_c(idx, pattern, sample_idx, test_idx) = ...
                        size(err_trials, 1) / ...
                        (size(corr_trials, 1) + size(err_trials, 1));
                end

            end
        end
    end
end



end