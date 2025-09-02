clc
clear
close all

% Script for sorting behavioural data

% TODO
% rewrite analysis stuff as functions
% bootstrapping: more bootstrap statistic? some p value or such stuff?
% rewrite plotting stuff as one function
% DONE rewrite correction to one resp mat with RT
% DONE rewrite sorting behaviour data as function
% DONE rewrite data extraction from behaviour data as function
% rewrite avg/median + error stuff as function
% rewrite bootstrapping as one function
% make plots with individual dots in background (like fish graphics)
% save data (individual stuff and mean stuff)
% make fig size variable


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
what_analysis = {'Performance'; 'Response Frequency'; 'Reaction Times'};
calc_type = {'Mean', 'Median'};
err_type = {'STD', 'SEM', 'CI'};

% crows: 1 = exp 1 100ms, 2 = exp 1 300ms, 3 = exp 1 50ms, 4 = exp 2 50ms
% humans: 1 = exp 1 50ms, 2 = exp 2 50ms, 3 = exp 3 50ms

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

% prompt to ask for experiment
if strcmp(who_analysis, 'humans\')
    prompt = ['Which experiment do you wish to plot? ' ...
        ' \n 1 - Experiment 1, 50 ms sample time ' ...
        ' \n 2 - Experiment 2, 50 ms sample time ' ...
        ' \n 3 - Experiment 3, 50 ms sample time '];
    experiments = {'Experiment 1, 50 ms'; 'Experiment 2, 50 ms'; ...
        'Experiment 3, 50 ms'};
else
    prompt = ['Which experiment do you wish to plot? ' ...
        ' \n 1 - Experiment 1, 100 ms sample time ' ...
        ' \n 2 - Experiment 1, 300 ms sample time ' ...
        ' \n 3 - Experiment 1, 50 ms sample time ' ...
        ' \n 4 - Experiment 2, 50 ms sample time '];
    experiments = {'Experiment 1, 100 ms'; 'Experiment 1, 300 ms'; ...
        'Experiment 1, 50 ms'; 'Experiment 2, 50 ms'};
end
curr_exp = input(prompt);

% prompt to ask what to analyse
prompt = ['What do you wish to analyse? '...
    '\n 1 - Performance ' ...
    '\n 2 - Response Frequency ' ...
    '\n 3 - Reaction Time '];
what_analysis = what_analysis{str2double(input(prompt, "s"))};

% prompt to ask what to analyse & to plot
prompt = ['What do you wish to plot? ' ...
    ' \n 1 - Mean ' ...
    ' \n 2 - Median '];
calc_type = calc_type{input(prompt)};

% prompt to ask for error type to plot
prompt = ['With what type of error? ' ...
    ' \n 1 - STD ' ...
    ' \n 2 - SEM ' ...
    ' \n 3 - CI '];
err_type = err_type{input(prompt)};

% Path definition
base_path = 'D:\MasterThesis\analysis\data\';
figure_path = ['D:\MasterThesis\figures\progress_since_250902\' who_analysis '\'];
spk_folderpath = [base_path, 'spk\'];
rsp_mat_folderpath = [base_path, 'analysed\'];

filelist_spk = dir(figure_path);  % list of all data & subfolders
subfolders = filelist_spk([filelist_spk(:).isdir]); % extract subfolders
subfolders = {subfolders(3:end).name};  % list of subfolder names (experiments)

to_save = true; % if result shall be saved
to_correct = false; % if response matrices shall be corrected
to_plot = {true, true, true, false};
in_detail = false;

% for Plotting
colours_pattern = ...
    {[0.8008 0.2578 0.7266]; [0.1445 0.4336 0.2070]; [0.1211 0.5195 0.6289]};
colours_numbers = {[0 0.4460 0.7410]; [0.8500 0.3250 0.0980]; ...
    [0.9290 0.6940 0.1250]; [0.3010 0.7450 0.9330]; [0.6350 0.0780 0.1840]};
format = 'svg';
fig_title = '';

plot_font = 12;
plot_pos = [451, 259, 1146, 690];   % default PaperPosition size of figure

n_boot = 10000;
confidence_level = 0.95;      % For a 95% CI
alpha = 1 - confidence_level;
lower_percentile = alpha / 2;
upper_percentile = (1 - alpha / 2);

counter = 0;    % counter for progress bar
total_amount = 84;

% Correct Response Matrix
if to_correct
    corr_resp(rsp_mat_folderpath, spk_folderpath, who_analysis, curr_exp, numerosities);
end

% Sum Average Performance for each Pattern
[performances, resp_freq, rec_times] = ...
    sort_behav(rsp_mat_folderpath, who_analysis, curr_exp, numerosities, patterns);

% Mean
[avg_data, err_data] = ...
    calc_behav(performances, what_analysis, 'Mean', err_type, patterns, ...
    numerosities, n_boot, alpha, in_detail);

% Median


% Get individual data

% Plot: Overall
mrksz = 10;
linewidth = 2;
plot_font = 14;
in_detail = false;
capsize = 10;
jitterwidth = 0.25;

fig = plot_stuff(performances, avg_data, err_data, numerosities, ...
    patterns, calc_type, err_type, what_analysis, who_analysis, ...
    experiments{curr_exp}, plot_font, colours_pattern, plot_pos, ...
    in_detail, linewidth, "none", mrksz, capsize, jitterwidth);

% save figure
if to_save
    fig_name = ['Overall_' calc_type '_' err_type '_' what_analysis '.' format];
    adapt_path = [figure_path '\' subfolders{curr_exp} '\'];
    saveas(fig, [adapt_path, fig_name], format)
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


