clc
clear
close all

% Script for sorting behavioural data

% Note
% so far, condition & standard stimuli trials thrown together (must be checked beforehand!!)
% maybe add response latency as 7th column lol

%% Pre Definition
% Path definition
base_path = 'D:\MasterThesis\analysis\data\';
figure_path = 'D:\MasterThesis\figures\';
spk_folderpath = [base_path, 'spk\'];
rsp_mat_folderpath = [base_path, 'response_matrices\'];
rsp_time_folderpath = [base_path, 'response_latencies\'];

who_analysis = {'humans\'; 'jello\'; 'uri\'};
curr_who = 1;    % set who to analyze
curr_exp = 2;    % set which experiment to analyze

% all numerosities relevant
numerosities = [3, 4, 5, 6, 7; % sample
    2, 2, 3, 3, 3;  % test 1 numbers
    5, 6, 7, 4, 4;  % test 2 numbers
    6, 7, 8, 9, 10]';  % test 3 numbers
patterns = {{'P1', 'P2', 'P3', 'PR'}, {'P1', 'P2', 'P3'}};

to_save = true; % if result shall be saved
to_correct = true; % if response matrices shall be corrected

% for Plotting
colours_pattern = {[0.8008 0.2578 0.7266]; [0.1445 0.4336 0.2070]; [0.1211 0.5195 0.6289]};
colours_numbers = {[0 0.4460 0.7410]; [0.8500 0.3250 0.0980]; ...
    [0.9290 0.6940 0.1250]; [0.3010 0.7450 0.9330]; [0.6350 0.0780 0.1840]};
format = 'svg';
error_plot = {'STD'; 'SEM'};
plot_font = 12;
plot_pos = [451, 259, 1146, 690];   % default PaperPosition size of figure


n_boot = 10000;
confidence_level = 0.95;      % For a 95% CI
alpha = 1 - confidence_level;
lower_percentile = alpha / 2;
upper_percentile = (1 - alpha / 2);



%% Correct Response Matrix
if to_correct
    % get file names
    path = [spk_folderpath, who_analysis{curr_who}]; % adapt path
    filelist_rsp = dir(fullfile(path, '*.spk'));  % list of all spk files
    names_rsp = {filelist_rsp.name};

    % iterate over files
    for idx = 1:length(names_rsp)
        % load data
        curr_file_rsp = names_rsp{idx}; % current file
        curr_spk = spk_read([path curr_file_rsp]); % current spike data
        curr_resp = getresponsematrix(curr_spk); % current response matrix
        % correct the response matrix
        corr_resp = respmat_corr(curr_resp, numerosities);

        % get reaction times
        curr_react = NaN(size(curr_resp, 1), 1);

        % get indices of all not abunded trials (or only correct ones if
        % this doesnt work) (yep it doesnt work with some failed trials for
        % whatever reason
        [rel_idx, ~] = find(corr_resp(:, 5) == 0);
        curr_reacts = getreactiontimes(curr_spk, 25, 41, rel_idx)'; % in s
        curr_reacts = curr_reacts * 1000; % in ms
        curr_react(rel_idx) = curr_reacts;

        % save the corrected response matrix
        if to_save
            save(fullfile([rsp_mat_folderpath, who_analysis{curr_who}], [curr_file_rsp, '_resp.mat']), 'corr_resp');
            save(fullfile([rsp_time_folderpath, who_analysis{curr_who}], [curr_file_rsp, '_react.mat']), 'curr_react');
        end
    end
end

%% Sum Average Performance for each Pattern
% Get Data: Response Matrices
path_resp = [rsp_mat_folderpath, who_analysis{curr_who}]; % adapt path
filelist_rsp = dir(path_resp);  % list of all data & subfolders
subfolders_rsp = filelist_rsp([filelist_rsp(:).isdir]); % extract subfolders
subfolders_rsp = {subfolders_rsp(3:end).name};  % list of subfolder names (experiments)

exp_path_resp = [path_resp, subfolders_rsp{curr_exp}, '\'];	% path with data of current experiment

filelist_rsp = dir(fullfile(exp_path_resp, '*.mat'));  % list of all response matrices
names_rsp = {filelist_rsp.name};	% file names

% Get Data: Response Latencies
path_react = [rsp_time_folderpath, who_analysis{curr_who}]; % adapt path
filelist_react = dir(path_react);  % list of all data & subfolders
subfolders_react = filelist_react([filelist_react(:).isdir]); % extract subfolders
subfolders_react = {subfolders_react(3:end).name};  % list of subfolder names (experiments)

exp_path_react = [path_react, subfolders_react{curr_exp}, '\'];	% path with data of current experiment

filelist_react = dir(fullfile(exp_path_react, '*.mat'));  % list of all response matrices
names_react = {filelist_react.name};	% file names

% Pre allocation
% performance for each cond
% dim 1: subject/session ; dim 2: pattern ; dim 3: samples ; dim 4: test number
performances = zeros(length(names_rsp), length(patterns{curr_exp}), size(numerosities, 1), size(numerosities, 2));
reaction_times = cell(length(names_react), length(patterns{curr_exp}), size(numerosities, 1), size(numerosities, 2));

% mean & error over subject/sessions, for each test number, pattern, sample
mean_perf_s = zeros(length(patterns{curr_exp}), size(numerosities, 1), size(numerosities, 2));
mean_RT_s = zeros(length(patterns{curr_exp}), size(numerosities, 1), size(numerosities, 2));
error_perf_s = zeros(2, length(patterns{curr_exp}), size(numerosities, 1), size(numerosities, 2)); % dim 1: 1 = STD, 2 = SEM
error_RT_s = zeros(2, length(patterns{curr_exp}), size(numerosities, 1), size(numerosities, 2)); % dim 1: 1 = STD, 2 = SEM

% mean & error over subjects/sessions & test numbers, for each pattern, sample
mean_perf = zeros(length(patterns{curr_exp}), size(numerosities, 1));
mean_RT = zeros(length(patterns{curr_exp}), size(numerosities, 1));
error_perf = zeros(2, length(patterns{curr_exp}), size(numerosities, 1)); % dim 1: 1 = STD, 2 = SEM
error_RT = zeros(2, length(patterns{curr_exp}), size(numerosities, 1)); % dim 1: 1 = STD, 2 = SEM



median_RT = zeros(length(patterns{curr_exp}), size(numerosities, 1));
median_RT_s = zeros(length(patterns{curr_exp}), size(numerosities, 1), size(numerosities, 2));
bootstrap_sem = zeros(3, length(patterns{curr_exp}), size(numerosities, 1));
bootstrap_sem_s = zeros(3, length(patterns{curr_exp}), size(numerosities, 1), size(numerosities, 2));

% iterate over all files
for idx = 1:length(names_rsp)
    % load response matrix
    curr_file_rsp = names_rsp{idx};
    curr_file_react = names_react{idx};
    curr_resp = load([exp_path_resp, curr_file_rsp]).corr_resp;
    curr_react = load([exp_path_react, curr_file_react]).curr_react;

    % iterate over each pattern
    for pattern = 1:length(patterns{curr_exp})
        % extract trials of current pattern

        % iterate over samples
        for sample_idx = 1:size(numerosities, 1)
            rel_nums = numerosities(sample_idx, :);	% sample & test numbers

            % iterate over test numbers
            for test_idx = 1:size(numerosities, 2)
                % DEBUG
                curr_trials = curr_resp(curr_resp(:, 2) == pattern & ...
                    curr_resp(:, 3) == rel_nums(1) & ... 
                    curr_resp(:, 6) == rel_nums(test_idx), :);

                % get correct trials
                corr_trials = curr_trials(curr_trials(:, 5) == 0, :);

                % get indices of those trials
                rel_idx = find(curr_resp(:, 2) == pattern & ...
                    curr_resp(:, 3) == rel_nums(1) & ...
                    curr_resp(:, 5) == 0 & ...
                    curr_resp(:, 6) == rel_nums(test_idx)); 

                % get performance
                perf_trials = size(corr_trials, 1) / size(curr_trials, 1);
                performances(idx, pattern, sample_idx, test_idx) = perf_trials;

                % get reaction time
                reaction_times{idx, pattern, sample_idx, test_idx} = [curr_react(rel_idx)];
            end
        end
    end
end

% calculate average performance/RT for each pattern & sample
% take mean over subjects/sessions & test numbers


% iterate over patterns
for pattern = 1:length(patterns{curr_exp})

    % iterate over samples
    for sample_idx = 1:size(numerosities, 1)
        % concat RTs for all test numbers & subject/session, for each
        % pattern & sample
        RT_test_nums = vertcat(reaction_times{:, pattern, sample_idx, :});

        % calculate average over subjects/sessions & test numbers
        mean_perf(pattern, sample_idx) = ...
            mean(performances(:, pattern, sample_idx, :), "all");
        mean_RT(pattern, sample_idx) = ...
            mean(RT_test_nums, "omitnan");
        median_RT(pattern, sample_idx) = ...
            median(RT_test_nums, "omitnan");
        % calculate corresponding error: STD
        error_perf(1, pattern, sample_idx) = ...
    		std(performances(:, pattern, sample_idx, :), [], "all");
        error_RT(1, pattern, sample_idx) = ...
            std(RT_test_nums, [], "omitnan");
    	% calculate corresponding error: SEM
    	error_perf(2, pattern, sample_idx) = ...
    		std(performances(:, pattern, sample_idx, :), [], "all") ...
    		/ sqrt(numel(performances(:, pattern, sample_idx, :)));
        error_RT(2, pattern, sample_idx) = ...
            std(RT_test_nums, [], "omitnan") / sqrt(numel(RT_test_nums));

        % add bootstrap
        bootstrap_median = zeros(n_boot, 1);
        % resample n-th times
        for b_idx = 1:n_boot
            % generate random indices
            resample_idx = randi(length(RT_test_nums), length(RT_test_nums), 1);

            % make bootstrap sample
            bootstrap_sample = RT_test_nums(resample_idx);

            % calculate median of current bootstrap sample
            bootstrap_median(b_idx) = median(bootstrap_sample);
        end
        % bootstrap statistics
        bootstrap_sem(1, pattern, sample_idx) = std(bootstrap_median);

        % confidence interval
        sorted_bootstrap_median = sort(bootstrap_median);   % sort the shit
        bootstrap_sem(2, pattern, sample_idx) = median_RT(pattern, sample_idx) - ...
            prctile(sorted_bootstrap_median, lower_percentile);
        bootstrap_sem(3, pattern, sample_idx) = median_RT(pattern, sample_idx) - ... 
            prctile(sorted_bootstrap_median, upper_percentile);

        
        % iterate over test numbers
        for test_idx = 1:size(numerosities, 2)
            % concat RTs for all subject/session, for each test number,
            % pattern & sample
            RT_test_nums = vertcat(reaction_times{:, pattern, sample_idx, test_idx});

            % compute mean/median performance & RT over subjects/session
            mean_perf_s(pattern, sample_idx, test_idx) = ...
                mean(performances(:, pattern, sample_idx, test_idx), "all");
            mean_RT_s(pattern, sample_idx, test_idx) = ...
                mean(RT_test_nums, "omitnan");
            median_RT_s(pattern, sample_idx, test_idx) = ...
                median(RT_test_nums, "omitnan");
            % calculate corresponding error: STD
            error_perf_s(1, pattern, sample_idx, test_idx) = ...
        		std(performances(:, pattern, sample_idx, test_idx), [], "all");
            error_RT_s(1, pattern, sample_idx, test_idx) = ...
                std(RT_test_nums, [], "omitnan");
        	% calculate corresponding error: SEM
        	error_perf_s(2, pattern, sample_idx, test_idx) = ...
        		std(performances(:, pattern, sample_idx, test_idx), [], "all") ...
        		/ sqrt(numel(performances(:, pattern, sample_idx, test_idx)));
            error_RT_s(2, pattern, sample_idx, test_idx) = ...
                std(RT_test_nums, [], "omitnan") / sqrt(numel(RT_test_nums));

            % add bootstrap
            bootstrap_median = zeros(n_boot, 1);
            % resample n-th times
            for b_idx = 1:n_boot
                % generate random indices
                resample_idx = randi(length(RT_test_nums), length(RT_test_nums), 1);

                % make bootstrap sample
                bootstrap_sample = RT_test_nums(resample_idx);

                % calculate median of current bootstrap sample
                bootstrap_median(b_idx) = median(bootstrap_sample);
            end
            % bootstrap statistics
            bootstrap_sem_s(1, pattern, sample_idx, test_idx) = std(bootstrap_median);

            % confidence interval
            sorted_bootstrap_median = sort(bootstrap_median);   % sort the shit
            bootstrap_sem_s(2, pattern, sample_idx, test_idx) = median_RT_s(pattern, sample_idx, test_idx) - ...
                prctile(sorted_bootstrap_median, lower_percentile);
            bootstrap_sem_s(3, pattern, sample_idx, test_idx) = median_RT_s(pattern, sample_idx, test_idx) - ...
                prctile(sorted_bootstrap_median, upper_percentile);

        end

    end
end

%% Plot
set(0, 'defaultfigurecolor', [1 1 1])  % set figure background to white

% pre definition


% Mean Performance for Each Pattern with STD

fig = figure();

[ax, leg_patch, leg_label] = plot_first(numerosities(:, 1)', mean_perf, ...
    squeeze(error_perf(1, :, :)), squeeze(error_perf(1, :, :)), ...
    patterns, curr_exp, colours_pattern, plot_font);

% Subplot Adjustments
ax.YLim = [-0.1 1.1];
ax.XLim = [2.9 7.1];
ax.XTick = numerosities(:, 1);
ax.XTickLabel = num2str(numerosities(:, 1));
ax.XLabel = "Sample Numerosity";
ax.XLabel.FontSize = plot_font;
ax.YLabel = "Performance";
ax.YLabel.FontSize = plot_font;

% Add Legend
leg = legend(leg_patch, leg_label);
leg.Location = "bestoutside";
leg.Box = "off";
leg.TextColor = "k";
leg.FontSize = plot_font;
title(leg, 'Pattern', 'FontSize', plot_font)

% Figure Adjustments        TO FUNCTION
set(gcf, 'Color', [1 1 1])  % set figure background to white (again)
% change figure size
set(gcf, 'PaperUnits', 'points')
set(gcf, 'PaperPosition', [plot_pos(1) plot_pos(2) plot_pos(3)/2 plot_pos(4)/2])
% figure title
fig_title = title(['Mean Performance of ' who_analysis{curr_who}(1:end-1) ', Exp ' ...
    num2str(curr_exp) ', with ' error_plot{er}]);
fig_title.FontSize = plot_font;
fig_title.Color = "k";

% save figure
fig.Renderer = "painters";
fig_name = ['mean_perf_' who_analysis{curr_who}(1:end-1) '_exp' ...
    num2str(curr_exp) '_' error_plot{er} '.' format];
saveas(fig, [figure_path, fig_name], format)
