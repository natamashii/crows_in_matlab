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

% Mean Performance for Each Pattern
set(0, 'defaultfigurecolor', [1 1 1])  % set figure background to white

% plot STD & SEM
for er = 1:length(error_plot)
    fig1 = figure('Name', ...
        [who_analysis{curr_who}(1:end-1) '_exp_' num2str(curr_exp)]);
    set(gcf, 'Color', [1 1 1])  % set figure background to white (again)
    % change figure size
    set(gcf, 'PaperUnits', 'points')
    set(gcf, 'PaperPosition', [plot_pos(1) plot_pos(2) plot_pos(3)/2 plot_pos(4)/2])

    % pre allocation
    leg_patch = [];
    leg_label = strings();
    % iterate over patterns/subplots
    for pattern = 1:length(patterns{curr_exp})
        hold on
        set(gca, 'Color', [1 1 1])
        set(gca, 'XColor', 'k', 'YColor', 'k');
        
        % plot error
        err_plot = errorbar(numerosities(:, 1)', mean_perf(pattern, :), ...
            squeeze(error_perf(er, pattern, :)));
        err_plot.Color = colours_pattern{pattern};
        err_plot.CapSize = 5;
        err_plot.LineWidth = 1;

        % plot avg performance
        plot_pattern = plot(numerosities(:, 1)', mean_perf(pattern, :));
        plot_pattern.LineStyle = "-";
        plot_pattern.LineWidth = 1;
        plot_pattern.Marker = "o";
        plot_pattern.Color = colours_pattern{pattern};
        plot_pattern.MarkerFaceColor = colours_pattern{pattern};
        plot_pattern.MarkerEdgeColor = "none";
        
        % for legend
        leg_patch(end + 1) = plot_pattern;
        leg_label(pattern) = patterns{curr_exp}(pattern);

        % Subfigure Adjustments
        ylim([-0.1 1.1])
        xlim([2.9 7.1])
        xticks(numerosities(:, 1))
        xticklabels(num2str(numerosities(:, 1)))
        xlabel("Sample Numerosity", "FontSize", plot_font)
        ylabel("Performance", "FontSize", plot_font)
        hold off
    end
    % Add legend
    leg = legend(leg_patch, leg_label);
    leg.Location = "bestoutside";
    leg.Box = "off";
    leg.TextColor = "k";
    leg.FontSize = plot_font;
    title(leg, 'Pattern', 'FontSize', plot_font)

    % figure title
    title(['Mean Performance of ' who_analysis{curr_who}(1:end-1) ', Exp ' num2str(curr_exp) ', with ' error_plot{er}], 'FontSize', plot_font, 'Color', 'k')

    % save figure
    fig1.Renderer = "painters";
    fig_name = ['mean_perf_' who_analysis{curr_who}(1:end-1) '_exp' num2str(curr_exp) '_' error_plot{er} '.' format];
    saveas(fig1, [figure_path, fig_name], format)
end

% Mean Response Latency for each Pattern
set(0, 'defaultfigurecolor', [1 1 1])  % set figure background to white

% plot STD & SEM
for er = 1:length(error_plot)
    fig2 = figure('Name', ...
        [who_analysis{curr_who}(1:end-1) '_exp_' num2str(curr_exp)]);
    set(gcf, 'Color', [1 1 1])  % set figure background to white (again)
    % change figure size
    set(gcf, 'PaperUnits', 'points')
    set(gcf, 'PaperPosition', [plot_pos(1) plot_pos(2) plot_pos(3)/2 plot_pos(4)/2])

    % pre allocation
    leg_patch = [];
    leg_label = strings();
    % iterate over patterns/subplots
    for pattern = 1:length(patterns{curr_exp})
        hold on
        set(gca, 'Color', [1 1 1])
        set(gca, 'XColor', 'k', 'YColor', 'k')

        % plot error

        err_plot = errorbar(numerosities(:, 1)', mean_RT(pattern, :), ...
            squeeze(error_RT(er, pattern, :)), squeeze(error_RT(er, pattern, :)));
        err_plot.Color = colours_pattern{pattern};
        err_plot.CapSize = 5;
        err_plot.LineWidth = 1;

        % plot avg RT
        plot_pattern = plot(numerosities(:, 1)', mean_RT(pattern, :));
        plot_pattern.LineStyle = "-";
        plot_pattern.LineWidth = 1;
        plot_pattern.Marker = "o";
        plot_pattern.Color = colours_pattern{pattern};
        plot_pattern.MarkerFaceColor = colours_pattern{pattern};
        plot_pattern.MarkerEdgeColor = "none";
        
        % for legend
        leg_patch(end + 1) = plot_pattern;
        leg_label(pattern) = patterns{curr_exp}(pattern);

        % Subfigure Adjustments
        ylim([200 600])
        xlim([2.9 7.1])
        xticks(numerosities(:, 1))
        xticklabels(num2str(numerosities(:, 1)))
        xlabel("Sample Numerosity", "FontSize", plot_font)
        ylabel("Response Latency [ms]", "FontSize", plot_font)
        hold off
    end
    % Add legend
    leg = legend(leg_patch, leg_label);
    leg.Location = "bestoutside";
    leg.Box = "off";
    leg.TextColor = "k";
    leg.FontSize = plot_font;
    title(leg, 'Pattern', 'FontSize', plot_font)

    % figure title
    title(['Mean Response Latency of ' who_analysis{curr_who}(1:end-1) ', Exp ' num2str(curr_exp) ', with ' error_plot{er}], 'FontSize', plot_font, 'Color', 'k')

    % save figure
    fig2.Renderer = "painters";
    fig_name = ['mean_RT_' who_analysis{curr_who}(1:end-1) '_exp' num2str(curr_exp) '_' error_plot{er} '.' format];
    saveas(fig2, [figure_path, fig_name], format)
end

% Median Response Latency with STD/ Confidence Interval
set(0, 'defaultfigurecolor', [1 1 1])  % set figure background to white

% plot STD
fig3 = figure('Name', ...
    [who_analysis{curr_who}(1:end-1) '_exp_' num2str(curr_exp)]);
set(gcf, 'Color', [1 1 1])  % set figure background to white (again)
% change figure size
set(gcf, 'PaperUnits', 'points')
set(gcf, 'PaperPosition', [plot_pos(1) plot_pos(2) plot_pos(3)/2 plot_pos(4)/2])

% pre allocation
leg_patch = [];
leg_label = strings();
% iterate over patterns/subplots
for pattern = 1:length(patterns{curr_exp})
    hold on
    set(gca, 'Color', [1 1 1])
    set(gca, 'XColor', 'k', 'YColor', 'k')

    % plot error

    err_plot = errorbar(numerosities(:, 1)', median_RT(pattern, :), ...
        squeeze(bootstrap_sem(1, pattern, :)), squeeze(bootstrap_sem(1, pattern, :)));
    err_plot.Color = colours_pattern{pattern};
    err_plot.CapSize = 5;
    err_plot.LineWidth = 1;

    % plot avg RT
    plot_pattern = plot(numerosities(:, 1)', median_RT(pattern, :));
    plot_pattern.LineStyle = "-";
    plot_pattern.LineWidth = 1;
    plot_pattern.Marker = "o";
    plot_pattern.Color = colours_pattern{pattern};
    plot_pattern.MarkerFaceColor = colours_pattern{pattern};
    plot_pattern.MarkerEdgeColor = "none";

    % for legend
    leg_patch(end + 1) = plot_pattern;
    leg_label(pattern) = patterns{curr_exp}(pattern);

    % Subfigure Adjustments
    ylim([200 600])
    xlim([2.9 7.1])
    xticks(numerosities(:, 1))
    xticklabels(num2str(numerosities(:, 1)))
    xlabel("Sample Numerosity", "FontSize", plot_font)
    ylabel("Response Latency [ms]", "FontSize", plot_font)
    hold off
end
% Add legend
leg = legend(leg_patch, leg_label);
leg.Location = "bestoutside";
leg.Box = "off";
leg.TextColor = "k";
leg.FontSize = plot_font;
title(leg, 'Pattern', 'FontSize', plot_font)

% figure title
title(['Median Response Latency of ' who_analysis{curr_who}(1:end-1) ', Exp ' num2str(curr_exp) ', with STD'], 'FontSize', plot_font, 'Color', 'k')

% save figure
fig3.Renderer = "painters";
fig_name = ['median_RT_' who_analysis{curr_who}(1:end-1) '_exp' num2str(curr_exp) '_STD.' format];
saveas(fig3, [figure_path, fig_name], format)

% plot Confidence Interval
fig4 = figure('Name', ...
    [who_analysis{curr_who}(1:end-1) '_exp_' num2str(curr_exp)]);
set(gcf, 'Color', [1 1 1])  % set figure background to white (again)
% change figure size
set(gcf, 'PaperUnits', 'points')
set(gcf, 'PaperPosition', [plot_pos(1) plot_pos(2) plot_pos(3)/2 plot_pos(4)/2])

% pre allocation
leg_patch = [];
leg_label = strings();
% iterate over patterns/subplots
for pattern = 1:length(patterns{curr_exp})
    hold on
    set(gca, 'Color', [1 1 1])
    set(gca, 'XColor', 'k', 'YColor', 'k')

    % plot error

    err_plot = errorbar(numerosities(:, 1)', median_RT(pattern, :), ...
        squeeze(bootstrap_sem(2, pattern, :)), squeeze(bootstrap_sem(3, pattern, :)));
    err_plot.Color = colours_pattern{pattern};
    err_plot.CapSize = 5;
    err_plot.LineWidth = 1;

    % plot avg RT
    plot_pattern = plot(numerosities(:, 1)', median_RT(pattern, :));
    plot_pattern.LineStyle = "-";
    plot_pattern.LineWidth = 1;
    plot_pattern.Marker = "o";
    plot_pattern.Color = colours_pattern{pattern};
    plot_pattern.MarkerFaceColor = colours_pattern{pattern};
    plot_pattern.MarkerEdgeColor = "none";

    % for legend
    leg_patch(end + 1) = plot_pattern;
    leg_label(pattern) = patterns{curr_exp}(pattern);

    % Subfigure Adjustments
    ylim([200 600])
    xlim([2.9 7.1])
    xticks(numerosities(:, 1))
    xticklabels(num2str(numerosities(:, 1)))
    xlabel("Sample Numerosity", "FontSize", plot_font)
    ylabel("Response Latency [ms]", "FontSize", plot_font)
    hold off
end
% Add legend
leg = legend(leg_patch, leg_label);
leg.Location = "bestoutside";
leg.Box = "off";
leg.TextColor = "k";
leg.FontSize = plot_font;
title(leg, 'Pattern', 'FontSize', plot_font)

% figure title
title(['Median Response Latency of ' who_analysis{curr_who}(1:end-1) ', Exp ' num2str(curr_exp) ', with 95% CI'], 'FontSize', plot_font, 'Color', 'k')

% save figure
fig4.Renderer = "painters";
fig_name = ['median_RT_' who_analysis{curr_who}(1:end-1) '_exp' num2str(curr_exp) '_CI.' format];
saveas(fig4, [figure_path, fig_name], format)



%% Plot performance/RT for each sample (individual subplot) with all
% patterns
% like the tuning curves

% Mean Performance for Each Pattern
set(0, 'defaultfigurecolor', [1 1 1])  % set figure background to white

% plot STD & SEM
for er = 1:length(error_plot)
    fig5 = figure('Name', ...
        [who_analysis{curr_who}(1:end-1) '_exp_' num2str(curr_exp)]);
    set(gcf, 'Color', [1 1 1])  % set figure background to white (again)
    % change figure size
    set(gcf, 'PaperUnits', 'points')
    set(gcf, 'PaperPosition', [plot_pos(1) plot_pos(2) plot_pos(3)*3.5 plot_pos(4)/2])

    % set subplots
    tiled = tiledlayout(1, 5, "TileSpacing", "compact");
    % pre allocation
    leg_patch = [];
    leg_label = strings();

    % iterate over samples/subplots
    for sample_idx = 1:size(numerosities, 1)
        ax = nexttile;
        % sort numerosities in ascending order 
        [nums_sort, sort_idx] = sort(numerosities(sample_idx, :));
        
        % iterate over patterns
        for pattern = 1:length(patterns{curr_exp})
            hold on
            set(gca, 'Color', [1 1 1])
            set(gca, 'XColor', 'k', 'YColor', 'k')

            % set values to plot
            values = squeeze(mean_perf_s(pattern, sample_idx, :));
            values = values(sort_idx);
            er_values = squeeze(error_perf_s(er, pattern, sample_idx, :));
            er_values = er_values(sort_idx);

            % plot error
            err_plot = errorbar(nums_sort, values, ...
                er_values, er_values);
            err_plot.Color = colours_pattern{pattern};
            err_plot.CapSize = 5;
            err_plot.LineWidth = 1;

            % plot avg RT
            plot_pattern = plot(nums_sort, values);
            plot_pattern.LineStyle = "-";
            plot_pattern.LineWidth = 1;
            plot_pattern.Marker = "o";
            plot_pattern.Color = colours_pattern{pattern};
            plot_pattern.MarkerFaceColor = colours_pattern{pattern};
            plot_pattern.MarkerEdgeColor = "none";

            % for legend
            leg_patch(end + 1) = plot_pattern;
            leg_label(pattern) = patterns{curr_exp}(pattern);

            % Subfigure Adjustments
            ylim([-0.1 1.1])
            xlim([1.9 10.1])
            xticks(min(numerosities, [], "all"):1:max(numerosities, [], "all"))
            xticklabels(num2str(min(numerosities, [], "all"):1:max(numerosities, [], "all")))
            xlabel("Sample Numerosity", "FontSize", plot_font)
            ylabel("Response Latency [ms]", "FontSize", plot_font)
            hold off
        end
    end
    % Add legend
    leg = legend(leg_patch, leg_label);
    leg.Location = "bestoutside";
    leg.Box = "off";
    leg.TextColor = "k";
    leg.FontSize = plot_font;
    title(leg, 'Pattern', 'FontSize', plot_font)

    % figure title
    title(['Mean Performance of ' who_analysis{curr_who}(1:end-1) ', Exp ' num2str(curr_exp) ', with ' error_plot{er}], 'FontSize', plot_font, 'Color', 'k')

    % save figure
    fig5.Renderer = "painters";
    fig_name = ['mean_perf_sample_' who_analysis{curr_who}(1:end-1) '_exp' num2str(curr_exp) '_CI.' format];
    saveas(fig5, [figure_path, fig_name], format)

end
