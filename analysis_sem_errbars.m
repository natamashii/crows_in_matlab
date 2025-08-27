clc
clear
close all

% Script for sorting behavioural data

% Note
% so far, condition & standard stimuli trials thrown together (must be checked beforehand!!)
% maybe add response latency as 7th column lol
% rewrite code and separate analysis & plot
% save the analysis output somewhere
% save corrected shit directly into folders, so make lists of dates that
% should be implemented
% add something to avoid plotting nonsense like median performance

% response matrix
% col 1: stimulus type (standard (1) or control (2))
% col 2: pattern type (P1, P2, P3, P4)
% col 3: sample (3-7)
% col 4: match or non-match (0 = match, 1 = test 1, 2 = test 2, 3 = test 3,
% referring to Lena's table with test 1-3)
% col 5: bird response evaluation (0 = correct, 1 = error by bird, 9 =
% abundance by bird)
% col 6: test numerosity (2-10)
% col 7: response latency in ms

% Note: 9 in all columns for one row = abundance by bird

%% Pre Definition

who_analysis = {'humans\'; 'jello\'; 'uri\'};
curr_exp = 1;    % set which experiment to analyze
% crows: 1 = exp 1 100ms, 2 = exp 1 300ms, 3 = exp 1 50ms, 4 = exp 2 50ms
% humans: 1 = exp 1 50ms, 2 = exp 2 50ms, 3 = exp 3 50ms

% Path definition
base_path = 'D:\MasterThesis\analysis\data\';
figure_path = ['D:\MasterThesis\figures\progress_250814\' who_analysis{curr_who}];
spk_folderpath = [base_path, 'spk\'];
rsp_mat_folderpath = [base_path, 'analysed\'];

% all numerosities relevant
numerosities = [3, 4, 5, 6, 7; % sample
    2, 2, 3, 3, 3;  % test 1 numbers
    5, 6, 7, 4, 4;  % test 2 numbers
    6, 7, 8, 9, 10]';  % test 3 numbers
patterns = {'P1', 'P2', 'P3'};

% prompt to ask who to analyse
prompt = ['Who do you wish to plot? ' ...
    ' \n 1 - humans ' ...
    ' \n 2 - Jello ' ...
    ' \n 3 - Uri ' ...
    ' \n 4 - Crows (Jello + Uri) '];
who_analysis = who_analysis{str2double(input(prompt, "s"))};

% prompt to ask what to analyse & to plot
prompt = ['What do you wish to plot? ' ...
    ' \n 1 - mean/median of everything ' ...
    ' \n 2 - mean/median of matches only' ...
    ' \n 3 - mean/median for each test ("tuning curves") '];
plot_type = input(prompt, "s");

to_save = true; % if result shall be saved
to_correct = true; % if response matrices shall be corrected
to_plot = {true, true, true, false};
to_zoom = true;         % toggle to zoom in for RT plots

% for Plotting
colours_pattern = {[0.8008 0.2578 0.7266]; [0.1445 0.4336 0.2070]; [0.1211 0.5195 0.6289]};
colours_numbers = {[0 0.4460 0.7410]; [0.8500 0.3250 0.0980]; ...
    [0.9290 0.6940 0.1250]; [0.3010 0.7450 0.9330]; [0.6350 0.0780 0.1840]};
format = 'svg';
fig_title = '';

switch to_zoom
    case true
        error_plot = {{{'STD'; 'SEM'}, [-0.1 1.1], 'Performance', 'perf', 'Mean', (0:0.2:1)';
            {'STD'; 'SEM'}, [100 350], 'Response Latency [ms]', 'RT', 'Mean', (100:50:350)'};
            {{'STD'; 'CI'}, [-0.1 1.1], 'Performance', 'perf', 'Median', (0:0.2:1)';
            {'STD'; 'CI'}, [100 350], 'Response Latency [ms]', 'RT', 'Median', (100:50:350)'}};
    case false
        error_plot = {{{'STD'; 'SEM'}, [-0.1 1.1], 'Performance', 'perf', 'Mean', (0:0.2:1)';
            {'STD'; 'SEM'}, [200 600], 'Response Latency [ms]', 'RT', 'Mean', (200:100:600)'};
            {{'STD'; 'CI'}, [-0.1 1.1], 'Performance', 'perf', 'Median', (0:0.2:1)';
            {'STD'; 'CI'}, [200 600], 'Response Latency [ms]', 'RT', 'Median', (200:100:600)'}};
end

plot_font = 12;
plot_pos = [451, 259, 1146, 690];   % default PaperPosition size of figure

n_boot = 10000;
confidence_level = 0.95;      % For a 95% CI
alpha = 1 - confidence_level;
lower_percentile = alpha / 2;
upper_percentile = (1 - alpha / 2);

counter = 0;    % counter for progress bar
total_amount = 84;

%% Correct Response Matrix
if to_correct
    corr_resp(spk_folderpath, who_analysis, curr_exp);
end

%% Sum Average Performance for each Pattern
[performances, resp_freq, rec_times] = ...
    sort_behav(rsp_mat_folderpath, who_analysis, curr_exp, numerosities, patterns);

% Mean


%% 

% Pre allocation
% performance for each cond
% dim 1: subject/session ; dim 2: pattern ; dim 3: samples ; dim 4: test number
performances = zeros(length(names_rsp), length(patterns), size(numerosities, 1));
resp_freq = zeros(length(names_rsp), length(patterns), size(numerosities, 1), size(numerosities, 2));
reaction_times = cell(length(names_react), length(patterns), size(numerosities, 1), size(numerosities, 2));

% mean & error over subject/sessions, for each test number, pattern, sample
mean_resp_freq = zeros(length(patterns), size(numerosities, 1), size(numerosities, 2));
mean_RT_s = zeros(length(patterns), size(numerosities, 1), size(numerosities, 2));
error_resp_freq = zeros(2, length(patterns), size(numerosities, 1), size(numerosities, 2)); % dim 1: 1 = STD, 2 = SEM
error_RT_s = zeros(2, length(patterns), size(numerosities, 1), size(numerosities, 2)); % dim 1: 1 = STD, 2 = SEM

% mean & error over subjects/sessions & test numbers, for each pattern, sample
mean_perf = zeros(length(patterns), size(numerosities, 1));
mean_RT = zeros(length(patterns), size(numerosities, 1));
error_perf = zeros(2, length(patterns), size(numerosities, 1)); % dim 1: 1 = STD, 2 = SEM
error_RT = zeros(2, length(patterns), size(numerosities, 1)); % dim 1: 1 = STD, 2 = SEM

% median & error over subjects/sessions, for each test number, pattern, sample
median_perf = zeros(length(patterns), size(numerosities, 1));
median_resp_freq = zeros(length(patterns), size(numerosities, 1), size(numerosities, 2));
bootstrap_sem_perf = zeros(3, length(patterns), size(numerosities, 1));
bootstrap_sem_resp_freq = zeros(3, length(patterns), size(numerosities, 1), size(numerosities, 2));

median_RT = zeros(length(patterns), size(numerosities, 1));
median_RT_s = zeros(length(patterns), size(numerosities, 1), size(numerosities, 2));
bootstrap_sem_RT = zeros(3, length(patterns), size(numerosities, 1));
bootstrap_sem_RT_s = zeros(3, length(patterns), size(numerosities, 1), size(numerosities, 2));

% iterate over all files
for idx = 1:length(names_rsp)
    % load response matrix
    curr_file_rsp = names_rsp{idx};
    curr_file_react = names_react{idx};
    curr_resp = load([exp_path_resp, curr_file_rsp]).corr_resp;
    curr_react = load([exp_path_react, curr_file_react]).curr_react;

    % iterate over each pattern
    for pattern = 1:length(patterns)
        % extract trials of current pattern

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

                % get error trials
                err_trials = curr_trials(curr_trials(:, 5) == 1, :);

                % compute response frequency
                % match trials: subject hit to match (correct trials)
                if test_idx == 1
                    perf_trials = size(corr_trials, 1) / ...
                        (size(corr_trials, 1) + size(err_trials, 1));
                    resp_freq(idx, pattern, sample_idx, test_idx) = perf_trials;
                % non-match trials: subject hit to non-match (error trials)
                else
                    perf_trials = size(err_trials, 1) / ...
                        (size(corr_trials, 1) + size(err_trials, 1));
                    resp_freq(idx, pattern, sample_idx, test_idx) = perf_trials;
                end

                % get reaction time
                % get indices of correct trials
                rel_idx = find(curr_resp(:, 2) == pattern & ...
                    curr_resp(:, 3) == rel_nums(1) & ...
                    curr_resp(:, 5) == 0 & ...
                    curr_resp(:, 6) == rel_nums(test_idx)); 
                reaction_times{idx, pattern, sample_idx, test_idx} = [curr_react(rel_idx)];
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

%% calculate average performance/RT for each pattern & sample
% take mean over subjects/sessions & test numbers


% iterate over patterns
for pattern = 1:length(patterns)
    % iterate over samples
    for sample_idx = 1:size(numerosities, 1)
        % concat RTs for all test numbers & subject/session, for each
        % pattern & sample
        RT_test_nums = vertcat(reaction_times{:, pattern, sample_idx, :});

        % calculate average over subjects/sessions & test numbers
        mean_perf(pattern, sample_idx) = ...
            mean(performances(:, pattern, sample_idx), "all");
        median_perf(pattern, sample_idx) = ...
            median(performances(:, pattern, sample_idx), "all");
        mean_RT(pattern, sample_idx) = ...
            mean(RT_test_nums, "omitnan");
        median_RT(pattern, sample_idx) = ...
            median(RT_test_nums, "omitnan");
        % calculate corresponding error: STD
        error_perf(1, pattern, sample_idx) = ...
            std(performances(:, pattern, sample_idx), [], "all");
        error_RT(1, pattern, sample_idx) = ...
            std(RT_test_nums, [], "omitnan");
        % calculate corresponding error: SEM
        error_perf(2, pattern, sample_idx) = ...
            std(performances(:, pattern, sample_idx), [], "all") ...
            / sqrt(numel(performances(:, pattern, sample_idx)));
        error_RT(2, pattern, sample_idx) = ...
            std(RT_test_nums, [], "omitnan") / sqrt(sum(~isnan(RT_test_nums)));

        % add bootstrap
        bootstrap_median_RT = zeros(n_boot, 1);
        bootstrap_median_perf = zeros(n_boot, 1);
        % resample n-th times
        for b_idx = 1:n_boot
            % generate random indices
            resample_idx_RT = randi(length(RT_test_nums), length(RT_test_nums), 1);
            resample_idx_perf = randi(numel(performances(:, pattern, sample_idx)), ...
                numel(performances(:, pattern, sample_idx)), 1);

            % make bootstrap sample
            bootstrap_sample_RT = RT_test_nums(resample_idx_RT);
            bootstrap_sample_perf = performances(resample_idx_perf);

            % calculate median of current bootstrap sample
            bootstrap_median_RT(b_idx) = median(bootstrap_sample_RT, "omitnan");
            bootstrap_median_perf(b_idx) = median(bootstrap_sample_perf, "omitnan");
        end
        % bootstrap statistics
        bootstrap_sem_perf(1, pattern, sample_idx) = std(bootstrap_median_perf);
        bootstrap_sem_RT(1, pattern, sample_idx) = std(bootstrap_median_RT);

        % confidence interval
        sorted_bootstrap_median_RT = sort(bootstrap_median_RT);   % sort the shit
        sorted_bootstrap_median_perf = sort(bootstrap_median_perf);
        bootstrap_sem_RT(2, pattern, sample_idx) = median_RT(pattern, sample_idx) - ...
            prctile(sorted_bootstrap_median_RT, lower_percentile);
        bootstrap_sem_RT(3, pattern, sample_idx) = median_RT(pattern, sample_idx) - ...
            prctile(sorted_bootstrap_median_RT, upper_percentile);
        bootstrap_sem_perf(2, pattern, sample_idx) = median_perf(pattern, sample_idx) - ...
            prctile(sorted_bootstrap_median_perf, lower_percentile);
        bootstrap_sem_perf(3, pattern, sample_idx) = median_perf(pattern, sample_idx) - ...
            prctile(sorted_bootstrap_median_perf, upper_percentile);

        % iterate over test numbers
        for test_idx = 1:size(numerosities, 2)
            % concat RTs for all subject/session, for each test number,
            % pattern & sample
            RT_test_nums = vertcat(reaction_times{:, pattern, sample_idx, test_idx});

            % compute mean/median performance & RT over subjects/session
            mean_resp_freq(pattern, sample_idx, test_idx) = ...
                mean(resp_freq(:, pattern, sample_idx, test_idx), "all");
            mean_RT_s(pattern, sample_idx, test_idx) = ...
                mean(RT_test_nums, "omitnan");
            median_resp_freq(pattern, sample_idx, test_idx) = ...
                median(resp_freq(:, pattern, sample_idx, test_idx), "all");
            median_RT_s(pattern, sample_idx, test_idx) = ...
                median(RT_test_nums, "omitnan");
            % calculate corresponding error: STD
            error_resp_freq(1, pattern, sample_idx, test_idx) = ...
                std(resp_freq(:, pattern, sample_idx, test_idx), [], "all");
            error_RT_s(1, pattern, sample_idx, test_idx) = ...
                std(RT_test_nums, [], "omitnan");
            % calculate corresponding error: SEM
            error_resp_freq(2, pattern, sample_idx, test_idx) = ...
                std(resp_freq(:, pattern, sample_idx, test_idx), [], "all") ...
                / sqrt(numel(resp_freq(:, pattern, sample_idx, test_idx)));
            error_RT_s(2, pattern, sample_idx, test_idx) = ...
                std(RT_test_nums, [], "omitnan") / sqrt(sum(~isnan(RT_test_nums)));

            % add bootstrap
            bootstrap_median_RT = zeros(n_boot, 1);
            bootstrap_median_perf = zeros(n_boot, 1);

            % resample n-th times
            for b_idx = 1:n_boot
                % generate random indices
                resample_idx_RT = randi(length(RT_test_nums), length(RT_test_nums), 1);
                resample_idx_perf = randi(numel(resp_freq(:, pattern, sample_idx, test_idx)), ...
                    numel(resp_freq(:, pattern, sample_idx, test_idx)), 1);

                % make bootstrap sample
                bootstrap_sample_RT = RT_test_nums(resample_idx_RT);
                bootstrap_sample_perf = resp_freq(resample_idx_perf);

                % calculate median of current bootstrap sample
                bootstrap_median_RT(b_idx) = median(bootstrap_sample_RT, "omitnan");
                bootstrap_median_perf(b_idx) = median(bootstrap_median_perf, "omitnan");
            end
            % bootstrap statistics
            bootstrap_sem_RT_s(1, pattern, sample_idx, test_idx) = std(bootstrap_median_RT, [], "omitnan");
            bootstrap_sem_resp_freq(1, pattern, sample_idx, test_idx) = std(bootstrap_median_perf, [], "omitnan");

            % confidence interval
            sorted_bootstrap_median_RT = sort(bootstrap_median_RT);   % sort the shit
            sorted_bootstrap_median_perf = sort(bootstrap_median_perf);
            bootstrap_sem_RT_s(2, pattern, sample_idx, test_idx) = ...
                median_RT_s(pattern, sample_idx, test_idx) - ...
                prctile(sorted_bootstrap_median_RT, lower_percentile);
            bootstrap_sem_RT_s(3, pattern, sample_idx, test_idx) = ...
                median_RT_s(pattern, sample_idx, test_idx) - ...
                prctile(sorted_bootstrap_median_RT, upper_percentile);
            bootstrap_sem_resp_freq(2, pattern, sample_idx, test_idx) = ...
                median_resp_freq(pattern, sample_idx, test_idx) - ...
                prctile(sorted_bootstrap_median_perf, lower_percentile);
            bootstrap_sem_resp_freq(3, pattern, sample_idx, test_idx) = ...
                median_resp_freq(pattern, sample_idx, test_idx) - ...
                prctile(sorted_bootstrap_median_perf, upper_percentile);

            counter = counter + 1;
            progressbar(counter, total_amount)
        end
    end
end

%% Plot: Correct Trials Match & Non-Match TOGETHER
if to_plot{1}
    set(0, 'defaultfigurecolor', [1 1 1])  % set figure background to white

    % pre definition
    values = {mean_perf, median_perf; mean_RT, median_RT};
    % cols: mean/median, rows: performance/RT
    error_values = {{error_perf(1, :, :), error_perf(1, :, :); ...
        error_perf(2, :, :), error_perf(2, :, :)}, ...
        {bootstrap_sem_perf(1, :, :), bootstrap_sem_perf(1, :, :); ...
        bootstrap_sem_perf(2, :, :), bootstrap_sem_perf(3, :, :)};
        {error_RT(1, :, :), error_RT(1, :, :); ...
        error_RT(2, :, :), error_RT(2, :, :)}, ...
        {bootstrap_sem_RT(1, :, :), bootstrap_sem_RT(1, :, :); ...
        bootstrap_sem_RT(2, :, :), bootstrap_sem_RT(3, :, :)}};
    jitter_dots = [-0.2, 0, 0.2];

    % mean or median
    for m = 1:length(error_plot)
        % performance or response latency
        for p = 1:size(error_plot{m}, 1)
            % error type
            for er = 1:size(error_plot{m}{p, 1}, 1)
                fig = figure();
                % figure title
                fig_title = title([error_plot{m}{p, 5} ' ' ...
                    char(error_plot{m}{p, 3}) ...
                    ' of ' who_analysis{curr_who}(1:end-1) ', Exp ' ...
                    num2str(curr_exp) ', with ' char(error_plot{m}{p, 1}{er})]);

                % create subplot
                [ax, dot_plots, leg_patch, leg_label] = plot_first(numerosities(:, 1)', ...
                    jitter_dots, ...
                    values{p, m}, ...
                    squeeze(error_values{p, m}{er, 1}), ...
                    squeeze(error_values{p, m}{er, 2}), ...
                    patterns, curr_exp, colours_pattern, plot_font, p);

                % Figure Adjustments
                [fig_pretty, fig_title_pretty] = ...
                    prettify_plot(fig, plot_pos, fig_title, plot_font, true, leg_patch, leg_label);

                % Subplot Adjustments
                ax.YLim = error_plot{m}{p, 2};
                ax.YTick = error_plot{m}{p, 6};
                ax.YTickLabel = num2str(error_plot{m}{p, 6});
                for pattern = 1:length(dot_plots)
                    dot_plots{pattern}.LineStyle = "none";
                end
                ylabel(ax, error_plot{m}{p, 3});

                % save figure
                fig_name = [error_plot{m}{p, 5}, '_' error_plot{m}{p, 4} ...
                    '_' who_analysis{curr_who}(1:end-1) '_exp' ...
                    num2str(curr_exp) '_' char(error_plot{m}{p, 1}{er}) '.' format];
                saveas(fig_pretty, [figure_path, fig_name], format)

                close
                counter = counter + 1;
                progressbar(counter, total_amount)
            end
        end
    end
end
%% Plot: Correct Trials Match & Non-Match INDIVIDUALLY
if to_plot{2}
    set(0, 'defaultfigurecolor', [1 1 1])  % set figure background to white

    % pre definition
    values = {mean_resp_freq, median_resp_freq; mean_RT_s, median_RT_s};
    % cols: mean/median, rows: performance/RT
    error_values = {{error_resp_freq(1, :, :, :), error_resp_freq(1, :, :, :); ...
        error_resp_freq(2, :, :, :), error_resp_freq(2, :, :, :)}, ...
        {bootstrap_sem_resp_freq(1, :, :, :), bootstrap_sem_resp_freq(1, :, :, :); ...
        bootstrap_sem_resp_freq(2, :, :, :), bootstrap_sem_resp_freq(3, :, :, :)};
        {error_RT_s(1, :, :, :), error_RT_s(1, :, :, :); ...
        error_RT_s(2, :, :, :), error_RT_s(2, :, :, :)}, ...
        {bootstrap_sem_RT_s(1, :, :, :), bootstrap_sem_RT_s(1, :, :, :); ...
        bootstrap_sem_RT_s(2, :, :, :), bootstrap_sem_RT_s(3, :, :, :)}};
    jitter_dots = [-0.2, 0, 0.2];

    % mean or median
    for m = 1:length(error_plot)
        % performance or response latency
        for p = 1:size(error_plot{m}, 1)
            % error type
            for er = 1:size(error_plot{m}{p, 1}, 1)
                fig = figure();
                tiled = tiledlayout(fig, 1, size(numerosities, 1));
                tiled.TileSpacing = "compact";
                tiled.Padding = "compact";

                % Figure Adjustments
                set(gcf, 'Color', [1 1 1])  % set figure background to white (again)
                % change figure size
                set(gcf, 'PaperUnits', 'points')
                set(gcf, 'PaperPosition', ...
                    [plot_pos(1) plot_pos(2) plot_pos(3)*1.5 plot_pos(4)/2])
                % figure title
                fig_title = title(tiled, [error_plot{m}{p, 5} ' ' ...
                    char(error_plot{m}{p, 3}) ...
                    ' of ' who_analysis{curr_who}(1:end-1) ', Exp ' ...
                    num2str(curr_exp) ', with ' char(error_plot{m}{p, 1}{er})]);
                fig_title.FontSize = plot_font;
                fig_title.Color = "k";
                fig_title.FontWeight = "bold";

                % pre allocation
                subplots = {};

                % iterate over Samples
                for sample_idx = 1:size(numerosities, 1)
                    nexttile(tiled);

                    % sort numerosities in ascending order
                    [nums_sort, sort_idx] = sort(numerosities(sample_idx, :));
                    curr_vals = squeeze(values{p, m}(:, sample_idx, :));
                    error_down = squeeze(error_values{p, m}{er, 1}(:, :, sample_idx, :));
                    error_up = squeeze(error_values{p, m}{er, 2}(:, :, sample_idx, :));

                    % sort the values
                    for pattern = 1:length(patterns{curr_exp})
                        curr_vals(pattern, :) = curr_vals(pattern, sort_idx);
                        error_down(pattern, :) = error_down(pattern, sort_idx);
                        error_up(pattern, :) = error_up(pattern, sort_idx);
                    end

                    [ax, ~, leg_patch, leg_label] = plot_first(nums_sort, ...
                        jitter_dots, ...
                        curr_vals, error_down, error_up, ...
                        patterns, curr_exp, colours_pattern, plot_font, p);

                    % Subplot Adjustments
                    ax.YLim = error_plot{m}{p, 2};
                    ax.XTick = 2:10;
                    ax.XTickLabel = num2str((2:10)');
                    ax.XLim = [1.5 10.5];
                    xlabel(ax, 'Test Numerosity', 'FontWeight', 'bold');    % set x-axis label
                    ax.YTick = error_plot{m}{p, 6};
                    ax.YTickLabel = num2str(error_plot{m}{p, 6});
                    ax.YTickLabel = '';
                    % set Subplot Title
                    title(ax, num2str(numerosities(sample_idx, 1)), ...
                        'FontSize', plot_font, 'FontWeight', 'bold', 'Color', 'k')

                    % store subplots in cell
                    subplots{sample_idx} = ax;
                end
                subplots{1}.YTickLabel = num2str(error_plot{m}{p, 6});
                ylabel(tiled, error_plot{m}{p, 3}, 'Color', 'k', 'FontSize', plot_font, 'FontWeight', 'bold')

                % Figure Adjustments
                % Add Legend
                leg = legend(subplots{end}, leg_patch, leg_label);
                leg.Location = "bestoutside";
                leg.Box = "off";
                leg.TextColor = "k";
                leg.FontSize = plot_font;
                title(leg, 'Pattern', 'FontSize', plot_font)

                % save figure
                fig_name = ['sample_' error_plot{m}{p, 5}, '_' ...
                    error_plot{m}{p, 4} '_' ...
                    who_analysis{curr_who}(1:end - 1) '_exp' ...
                    num2str(curr_exp) '_' char(error_plot{m}{p, 1}{er}) '.' format];
                saveas(fig, [figure_path, fig_name], format)

                close
                counter = counter + 1;
                progressbar(counter, total_amount)
            end
        end
    end
end
%% Plot: Correct Trials Matches only
if to_plot{3}
    set(0, 'defaultfigurecolor', [1 1 1])  % set figure background to white

    % pre definition
    values = {mean_resp_freq(:, :, 1), median_resp_freq(:, :, 1); ...
        mean_RT_s(:, :, 1), median_RT_s(:, :, 1)};
    % cols: mean/median, rows: performance/RT
    error_values = {{error_resp_freq(1, :, :, 1), error_resp_freq(1, :, :, 1); ...
        error_resp_freq(2, :, :, 1), error_resp_freq(2, :, :, 1)}, ...
        {bootstrap_sem_resp_freq(1, :, :, 1), bootstrap_sem_resp_freq(1, :, :, 1); ...
        bootstrap_sem_resp_freq(2, :, :, 1), bootstrap_sem_resp_freq(3, :, :, 1)};
        {error_RT_s(1, :, :, 1), error_RT_s(1, :, :, 1); ...
        error_RT_s(2, :, :, 1), error_RT_s(2, :, :, 1)}, ...
        {bootstrap_sem_RT_s(1, :, :, 1), bootstrap_sem_RT_s(1, :, :, 1); ...
        bootstrap_sem_RT_s(2, :, :, 1), bootstrap_sem_RT_s(3, :, :, 1)}};
    jitter_dots = [-.2, 0, .2];

    % mean or median
    for m = 1:length(error_plot)
        % performance or response latency
        for p = 1:size(error_plot{m}, 1)
            % error type
            for er = 1:size(error_plot{m}{p, 1}, 1)
                fig = figure();

                % figure title
                fig_title = title(['MATCHES: ' error_plot{m}{p, 5} ' ' ...
                    char(error_plot{m}{p, 3}) ...
                    ' of ' who_analysis{curr_who}(1:end-1) ', Exp ' ...
                    num2str(curr_exp) ', with ' char(error_plot{m}{p, 1}{er})]);

                % create subplot
                [ax, dot_plots, leg_patch, leg_label] = plot_first(numerosities(:, 1)', ...
                    jitter_dots, ...
                    values{p, m}, ...
                    squeeze(error_values{p, m}{er, 1}), ...
                    squeeze(error_values{p, m}{er, 2}), ...
                    patterns, curr_exp, colours_pattern, plot_font, p);

                % Subplot Adjustments
                ax.YLim = error_plot{m}{p, 2};
                ax.YTick = error_plot{m}{p, 6};
                ax.YTickLabel = num2str(error_plot{m}{p, 6});
                ylabel(ax, error_plot{m}{p, 3});
                for pattern = 1:length(dot_plots)
                    dot_plots{pattern}.LineStyle = "none";
                end

                % Figure Adjustments
                [fig_pretty, fig_title_pretty] = ...
                    prettify_plot(fig, plot_pos, fig_title, plot_font, true, leg_patch, leg_label);

                % save figure
                fig_name = ['matches_' error_plot{m}{p, 5}, '_' ...
                    error_plot{m}{p, 4} ...
                    '_' who_analysis{curr_who}(1:end-1) '_exp' ...
                    num2str(curr_exp) '_' char(error_plot{m}{p, 1}{er}) '.' format];
                saveas(fig_pretty, [figure_path, fig_name], format)

                close
                counter = counter + 1;
                progressbar(counter, total_amount)
            end
        end
    end
end


%% Performance over Time

% get mean performance session-wise
time_perf = zeros(2, length(patterns{curr_exp}), size(performances, 1), size(numerosities, 1));
time_perf_err = zeros(2, length(patterns{curr_exp}), size(performances, 1), size(numerosities, 1));

% iterate over patterns
for pattern = 1:length(patterns{curr_exp})
    % iterate over sessions
    for idx = 1:size(performances, 1)
        % iterate over samples
        for sample_idx = 1:size(numerosities, 1)
            time_perf(1, pattern, idx, sample_idx) = ...
                mean(performances(idx, pattern, sample_idx, :), "all");
            time_perf(2, pattern, idx, sample_idx) = ...
                median(performances(idx, pattern, sample_idx, :), "all");
            time_perf_err(1, pattern, idx, sample_idx) = ...
                std(performances(idx, pattern, sample_idx, :), [], "all");
            time_perf_err(2, pattern, idx, sample_idx) = ...
                std(performances(idx, pattern, sample_idx, :), [], "all") / ...
                sqrt(numel(performances(idx, pattern, sample_idx, :)));
        end
    end
end

% plot

if to_plot{4}
    set(0, 'defaultfigurecolor', [1 1 1])  % set figure background to white

    % pre definition
    values = {mean_perf_s(:, :, 1), median_resp_freq(:, :, 1); ...
        mean_RT_s(:, :, 1), median_RT_s(:, :, 1)};
    % cols: mean/median, rows: performance/RT
    error_values = {{error_resp_freq(1, :, :, 1), error_resp_freq(1, :, :, 1); ...
        error_resp_freq(2, :, :, 1), error_resp_freq(2, :, :, 1)}, ...
        {bootstrap_sem_resp_freq(1, :, :, 1), bootstrap_sem_resp_freq(1, :, :, 1); ...
        bootstrap_sem_resp_freq(2, :, :, 1), bootstrap_sem_resp_freq(3, :, :, 1)};
        {error_RT_s(1, :, :, 1), error_RT_s(1, :, :, 1); ...
        error_RT_s(2, :, :, 1), error_RT_s(2, :, :, 1)}, ...
        {bootstrap_sem_RT_s(1, :, :, 1), bootstrap_sem_RT_s(1, :, :, 1); ...
        bootstrap_sem_RT_s(2, :, :, 1), bootstrap_sem_RT_s(3, :, :, 1)}};
    jitter_dots = [-.2, 0, .2];

    % mean or median
    for m = 1:length(error_plot)
        % performance or response latency
        for p = 1:size(error_plot{m}, 1)
            % error type
            for er = 1:size(error_plot{m}{p, 1}, 1)
                fig = figure();

                % figure title
                fig_title = title(['MATCHES: ' error_plot{m}{p, 5} ' ' ...
                    char(error_plot{m}{p, 3}) ...
                    ' of ' who_analysis{curr_who}(1:end-1) ', Exp ' ...
                    num2str(curr_exp) ', with ' char(error_plot{m}{p, 1}{er})]);

                % create subplot
                [ax, dot_plots, leg_patch, leg_label] = plot_first(numerosities(:, 1)', ...
                    jitter_dots, ...
                    values{p, m}, ...
                    squeeze(error_values{p, m}{er, 1}), ...
                    squeeze(error_values{p, m}{er, 2}), ...
                    patterns, curr_exp, colours_pattern, plot_font);

                % Subplot Adjustments
                ax.YLim = error_plot{m}{p, 2};
                ax.YTick = error_plot{m}{p, 6};
                ax.YTickLabel = num2str(error_plot{m}{p, 6});
                ylabel(ax, error_plot{m}{p, 3});
                for pattern = 1:length(dot_plots)
                    dot_plots{pattern}.LineStyle = "none";
                end

                % Figure Adjustments
                [fig_pretty, fig_title_pretty] = ...
                    prettify_plot(fig, plot_pos, fig_title, plot_font, true, leg_patch, leg_label);

                % save figure
                fig_name = ['matches_' error_plot{m}{p, 5}, '_' ...
                    error_plot{m}{p, 4} ...
                    '_' who_analysis{curr_who}(1:end-1) '_exp' ...
                    num2str(curr_exp) '_' char(error_plot{m}{p, 1}{er}) '.' format];
                saveas(fig_pretty, [figure_path, fig_name], format)

                close
                counter = counter + 1;
                progressbar(counter, total_amount)
            end
        end
    end
end


