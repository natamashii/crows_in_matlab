clc
clear
close all

% Script for sorting behavioural data

% TODO
% comparison patterns: linear regression, something with correlation
% statistics: kruskal wallis, but which effect size???
% post hoc: mann withney u with bonferroni or Conover–Iman test or dunn???
% DONE divide standard/control stuff, save it separately (incl statistic shit from that)
% DONE generalize standard/control to Jello/Uri
% implement statistics
% DONE rewrite analysis stuff as functions
% bootstrapping: more bootstrap statistic? some p value or such stuff?
% DONE rewrite plotting stuff as one function
% DONE rewrite correction to one resp mat with RT
% DONE rewrite sorting behaviour data as function
% DONE rewrite data extraction from behaviour data as function
% DONE rewrite avg/median + error stuff as function
% DONE rewrite bootstrapping as one function
% DONE make plots with individual dots in background (like fish graphics)
% save data (individual stuff and mean stuff)
% make fig size variable (robust for each device used)
% maybe time for birds
% imporve single plot
% regression analysis: add computing in function + plot regression curve separetly in a function
% DONE rewrite standard/control & jello/uri stuff into one case
% DONE different colours for uri & jello comparison thatn for standard & control
% comparison of birds different times exp 1
% DONE make prompt asking adaptable
% write one script to load all stuff to make it presentable to lena
% in stimpattern_generation.m change input to case insensitive with strcmpi();
% change ind dot colours to be a bit different than the avg data (overlays with box plots...)
% maybe combine plot_stuff with plot_sc somehow....
% add error type to legend in each plot function
% for plotting: extract dot_alpha & marker factor & box alpha & boxwidth factor for all functions
% Anova S/C and J/U: maybe pre process RTs: remove too quick trials & remove everything that is +- 3* MAD of median
% perhaps look for significant difference in P1 vs. P2/3 first

% Note
% so far, condition & standard stimuli trials thrown together (must be checked beforehand!!)
% save the analysis output somewhere
% save corrected shit directly into folders, so make lists of dates that
% should be implemented

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

who_analysis = {'humans\'; 'jello\'; 'uri\'; 'birds\'};
what_analysis = {'Performance'; 'Response Frequency'; 'Reaction Times'};
calc_type = {'Mean', 'Median'};
err_type = {'STD', 'SEM', 'CI'};
focus_type = {'Overall', 'Matches', 'Single'};

to_save = true; % if result shall be saved
to_correct = false; % if response matrices shall be corrected
to_split_sc = false;    % if to compare standard & control conditions
to_split_ju = false;    % if to compare Jello's & Uri's data

% all relevant numerosities (Lena's tabular)
numerosities = [3, 4, 5, 6, 7; % sample
    2, 2, 3, 3, 3;  % test 1 numbers
    5, 6, 7, 4, 4;  % test 2 numbers
    6, 7, 8, 9, 10]';  % test 3 numbers
patterns = {'P1', 'P2', 'P3'};

% for Plotting
colours_pattern = ...
    {[0.8008 0.2578 0.7266]; [0.1445 0.4336 0.2070]; ...
    [0.1211 0.5195 0.6289]};    % colours for patterns
colours_numbers = {[0 0.4460 0.7410]; [0.8500 0.3250 0.0980]; ...
    [0.9290 0.6940 0.1250]; [0.3010 0.7450 0.9330]; ...
    [0.6350 0.0780 0.1840]};    % colours for samples
colours_S_C = ...
    {[0.0660 0.4430 0.7450]; [0.5210 0.0860 0.8190]};   % Standard/Control
colours_J_U = ...
    {[0.0000 0.4080 0.7410]; [0.9690 0.3650 0.8000]};   % Jello/Uri
format = 'svg'; % figure save format
fig_title = '';

plot_font = 12;
plot_pos = [21 29.7];   % default PaperPosition size of figure
mrksz = 10;
linewidth = 2;
plot_font = 14;
capsize = 10;
jitterwidth = 0.25;
linestyle = "none";

% values for computing confidence interval
n_boot = 10000;
confidence_level = 95;      % For a 95% CI
alpha = 100 - confidence_level;

%% Set specifics
% prompt to ask who to analyse
prompt = ['Who do you wish to plot? ' ...
    ' \n 1 - humans ' ...
    ' \n 2 - Jello ' ...
    ' \n 3 - Uri ' ...
    ' \n 4 - Crows (Jello + Uri) '];
who_analysis = who_analysis{str2double(input(prompt, "s"))};

% If Jello and Uri shall be compared
if strcmp(who_analysis, 'birds\')
    to_split_ju = true;
    % Prompt to ask if division into Standard & Control Conditions
else
    prompt = 'Split data into Standard & Control? (y/n) ';
    if strcmpi(input(prompt, "s"), 'y')
        to_split_sc = true;
    end
end

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

% Path definition
base_path = 'D:\MasterThesis\analysis\data\';
figure_path = ['D:\MasterThesis\figures\progress_since_250902\' who_analysis '\'];
spk_folderpath = [base_path, 'spk\'];
rsp_mat_folderpath = [base_path, 'analysed\'];
stats_path = ['D:\MasterThesis\analysis\data\statistics\' who_analysis '\'];

filelist_spk = dir(figure_path);  % list of all data & subfolders
subfolders = filelist_spk([filelist_spk(:).isdir]); % extract subfolders
subfolders = {subfolders(3:end).name};  % list of subfolder names (experiments)

%% Correct Response Matrix
if to_correct
    corr_resp(rsp_mat_folderpath, spk_folderpath, who_analysis, ...
        curr_exp, numerosities);
end

%% Extract Data
% Comparison of Jello & Uri
if to_split_ju
    % get data for Jello
    [performances_1, resp_freq_1, rec_times_1] = ...
        sort_behav(rsp_mat_folderpath, 'jello\', ...
        curr_exp, numerosities, patterns);

    % get data for Uri
    [performances_2, resp_freq_2, rec_times_2] = ...
        sort_behav(rsp_mat_folderpath, 'uri\', ...
        curr_exp, numerosities, patterns);

    % set some variables for later plotting
    factors_plot = {'Jello', 'Uri'};
    factors_stats = {'J', 'U'};
    fig_name_part = '_JelloUri_';
    colours_split = colours_J_U;

    % set focus type to 'Matches'
    focus_type = focus_type{2};

    % Comparison of Standard % Control Conditions
elseif to_split_sc
    % get data for standard & control conditions
    [performances_1, performances_2, ...
        resp_freq_1, resp_freq_2, rec_times_1, rec_times_2] = ...
        stand_cont(rsp_mat_folderpath, who_analysis, ...
        curr_exp, numerosities, patterns);

    % set some variables for later plotting
    factors_plot = {'Standard', 'Control'};
    factors_stats = {'S', 'C'};
    fig_name_part = '_StandCont_';
    colours_split = colours_S_C;

    % set focus type to 'Matches'
    focus_type = focus_type{2};

    % No explicit comparison
else
    % prompt to ask for which combination to plot
    prompt = ['What exactly do you wanna look at? ' ...
        ' \n 1 - Overall (Match + Non-Match) ' ...
        ' \n 2 - Matches ' ...
        ' \n 3 - Behavioural Curves '];
    focus_type = focus_type{input(prompt)};

    % get data
    [performances, resp_freq, rec_times] = ...
        sort_behav(rsp_mat_folderpath, who_analysis, ...
        curr_exp, numerosities, patterns);
end

%% Get data depending on what to analyse
switch what_analysis
    case 'Performance'
        calc_type = calc_type{1};   % Mean
        err_type = err_type{2};     % SEM
        if to_split_ju | to_split_sc
            % Standard/Jello
            [avg_data_1, ~, err_data_1] = ...
                calc_behav(performances_1, what_analysis, ...
                calc_type, err_type, patterns, ...
                numerosities, n_boot, alpha, focus_type);
            ind_data_1 = performances_1;
            % Control/Uri
            [avg_data_2, ~, err_data_2] = ...
                calc_behav(performances_2, what_analysis, ...
                calc_type, err_type, patterns, ...
                numerosities, n_boot, alpha, focus_type);
            ind_data_2 = performances_2;
        else
            [avg_data, avg_data_stats, err_data] = ...
                calc_behav(performances, what_analysis, ...
                calc_type, err_type, patterns, ...
                numerosities, n_boot, alpha, focus_type);
            ind_data = performances;
        end

    case 'Response Frequency'
        calc_type = calc_type{1};   % Mean
        err_type = err_type{2};     % SEM
        if to_split_ju | to_split_sc
            % Standard/Jello
            [avg_data_1, ~, err_data_1] = ...
                calc_behav(resp_freq_1, what_analysis, ...
                calc_type, err_type, patterns, ...
                numerosities, n_boot, alpha, focus_type);
            ind_data_1 = resp_freq_1;
            % Control/Uri
            [avg_data_2, ~, err_data_2] = ...
                calc_behav(resp_freq_2, what_analysis, ...
                calc_type, err_type, patterns, ...
                numerosities, n_boot, alpha, focus_type);
            ind_data_2 = resp_freq_2;
        else
            [avg_data, avg_data_stats, err_data] = ...
                calc_behav(resp_freq, what_analysis, ...
                calc_type, err_type, patterns, ...
                numerosities, n_boot, alpha, focus_type);
            ind_data = resp_freq;
        end

    case 'Reaction Times'
        calc_type = calc_type{2};   % Median
        err_type = err_type{1};     % STD, although not necessary (boxplot)
        if to_split_ju | to_split_sc
            % Standard/Jello
            [avg_data_1, ~, err_data_1] = ...
                calc_behav(rec_times_1, what_analysis, ...
                calc_type, err_type, patterns, ...
                numerosities, n_boot, alpha, focus_type);
            ind_data_1 = rec_times_1;
            % Control/Uri
            [avg_data_2, ~, err_data_2] = ...
                calc_behav(rec_times_2, what_analysis, ...
                calc_type, err_type, patterns, ...
                numerosities, n_boot, alpha, focus_type);
            ind_data_2 = rec_times_2;
        else
            [avg_data, avg_data_stats, err_data] = ...
                calc_behav(rec_times, what_analysis, ...
                calc_type, err_type, patterns, ...
                numerosities, n_boot, alpha, focus_type);
            ind_data = rec_times;
        end
end

%% Statistics
if to_split_ju | to_split_sc
    statistics = anova_sc(performances_1, performances_2, ...
        resp_freq_1, resp_freq_2, rec_times_1, rec_times_2, patterns, ...
        numerosities, stats_path, subfolders{curr_exp}, ...
        factors_stats, ['statistics_' fig_name_part(1:end - 1)]);
end

% Linear Regression: Compare patterns
if ~(to_split_ju | to_split_sc) & ~strcmp(focus_type, 'Single')

    % Linear Regression
    lin_reg_pattern = ...
        lin_regress(performances, resp_freq, rec_times, ...
        patterns, numerosities, what_analysis, avg_data);

    % Statistics
    [big_statistics, post_hoc] = ...
        pattern_statistics(performances, resp_freq, rec_times, ...
        what_analysis, numerosities, patterns, focus_type, ...
        'Friedman', 'Conover_Iman', stats_path, subfolders{curr_exp}, ...
        avg_data_stats);
    [big_statistics, post_hoc] = ...
        pattern_statistics(performances, resp_freq, rec_times, ...
        what_analysis, numerosities, patterns, focus_type, ...
        'Kruskal_Wallis', 'Conover_Iman', stats_path, subfolders{curr_exp}, ...
        avg_data_stats);
    [big_statistics, post_hoc] = ...
        pattern_statistics(performances, resp_freq, rec_times, ...
        what_analysis, numerosities, patterns, focus_type, ...
        'Friedman', 'Dunn', stats_path, subfolders{curr_exp}, ...
        avg_data_stats);
    [big_statistics, post_hoc] = ...
        pattern_statistics(performances, resp_freq, rec_times, ...
        what_analysis, numerosities, patterns, focus_type, ...
        'Kruskal_Wallis', 'Dunn', stats_path, subfolders{curr_exp}, ...
        avg_data_stats);
    [big_statistics, post_hoc] = ...
        pattern_statistics(performances, resp_freq, rec_times, ...
        what_analysis, numerosities, patterns, focus_type, ...
        'Kruskal_Wallis', 'Wilcoxon_Signed_Rank', stats_path, subfolders{curr_exp}, ...
        avg_data_stats);
    [big_statistics, post_hoc] = ...
        pattern_statistics(performances, resp_freq, rec_times, ...
        what_analysis, numerosities, patterns, focus_type, ...
        'Friedman', 'Wilcoxon_Signed_Rank', stats_path, subfolders{curr_exp}, ...
        avg_data_stats);
end


%% Plotting
% Plot specificites depending on what to analyse
if strcmp(focus_type, 'Single')
    linestyle = "--";
    plot_pos = [50 29.7];
end

% if comparison wished
if to_split_ju | to_split_sc
    plot_pos = [29.7 50];
    fig = plot_s_c(numerosities, ind_data_1, ind_data_2, ...
        avg_data_1, avg_data_2, err_data_1, err_data_2, what_analysis, ...
        who_analysis(1:end - 1), calc_type, experiments{curr_exp}, ...
        patterns, err_type, jitterwidth, ...
        colours_split, mrksz, plot_font, plot_pos, ...
        linewidth, capsize, linestyle, factors_plot);

    % set figure file name
    fig_name = [focus_type fig_name_part calc_type '_' err_type '_' ...
        what_analysis '.' format];
else
    fig = plot_stuff(ind_data, avg_data, err_data, numerosities, ...
        patterns, calc_type, err_type, what_analysis, ...
        who_analysis(1:end - 1), ...
        experiments{curr_exp}, plot_font, colours_pattern, plot_pos, ...
        linewidth, linestyle, mrksz, capsize, jitterwidth, focus_type);

    % add linear regression lines
    %plot_lin_reg(lin_reg_pattern, patterns, numerosities, ...
    %    jitterwidth, "--", linewidth, colours_pattern)

    % set figure file name
    fig_name = [focus_type '_' calc_type '_' err_type '_' ...
        what_analysis '.' format];
end




%% save figure
if to_save
    adapt_path = [figure_path '\' subfolders{curr_exp} '\'];
    saveas(fig, [adapt_path, fig_name], format)
end



