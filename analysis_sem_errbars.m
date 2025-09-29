clc
clear
close all

% Script for sorting behavioural data

% TODO
% comparison patterns: linear regression, something with correlation
% DONE statistics: kruskal wallis, but which effect size???
% DONE post hoc: mann withney u with bonferroni or Conover–Iman test or dunn???
% DONE divide standard/control stuff, save it separately (incl statistic shit from that)
% DONE generalize standard/control to Jello/Uri
% DONE implement statistics
% DONE fix conover iman test
% test for performance difference among patterns for each sample
% do regression for each subject
% do nieder vs veit
% set size effect
% maybe compare amount of variation between patterns???
% maybe build linear models or so 
% DONE rewrite analysis stuff as functions
% bootstrapping: more bootstrap statistic? some p value or such stuff?
% avg trial rate per session for everyone
% look at non matches: if previous smoler/bigger -> Lena figure 16
% look at cancellations (crow breaks off)
% Weber fractions maybe???
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
% mark p value in standard/control & jello/uri plot
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
% save the analysis output somewhere
% save corrected shit directly into folders, so make lists of dates that should be implemented

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
experiments = {{'Experiment 1, 50 ms'; 'Experiment 2, 50 ms'; ...
        'Experiment 3, 50 ms'}, ...
        {'Experiment 1, 100 ms'; 'Experiment 1, 300 ms'; ...
        'Experiment 1, 50 ms'; 'Experiment 2, 50 ms'}};
what_analysis = {'Performance'; 'Response Frequency'; 'Reaction Times'};
calc_type = {'Mean', 'Median'};
err_type = {'STD', 'SEM', 'CI'};
focus_type = {'Overall', 'Matches', 'Single'};

% prompt to ask what to analyse
prompt_what = ['What do you wish to analyse? '...
    '\n 1 - Performance ' ...
    '\n 2 - Response Frequency ' ...
    '\n 3 - Reaction Time '];

to_save = true; % if result shall be saved
to_correct = false; % if response matrices shall be corrected
to_split_sc = false;    % if to compare standard & control conditions
to_split_ju = false;    % if to compare Jello's & Uri's data
to_sort = false;     % if data must be sorted first
to_pattern_matches = false;     % if plotting pattern comparison (matches)
to_pattern_curves = false;  % if plotting pattern comparison (tuning curves)
to_ssmd = true;     % if plotting ssmd

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

%% Pre Allocation
p = {2, 1};
W = {2, 1};

% Path definition
base_path = 'D:\MasterThesis\analysis\data\';
figure_path = 'D:\MasterThesis\figures\progress_since_250902\';
spk_folderpath = [base_path, 'spk\'];
analysis_path = [base_path, 'analysed\'];
data_path = [analysis_path 'sorted_statistics\'];
rsp_mat_path = [analysis_path 'response_matrices\'];

%% Correct Response Matrix
if to_correct
    corr_resp(analysis_path, spk_folderpath, who_analysis, ...
        curr_exp, numerosities);
end

%% Sort Data

if to_sort
    % iterate over subjects
    for who_idx = 1:length(who_analysis) - 1

        % human subjects
        if who_idx == 1
            curr_experiments = experiments{1};

            % avian subjects
        else
            curr_experiments = experiments{2};
        end

        % iterate over experiments
        for exp_idx = 1:length(curr_experiments)
            % pre allocation
            sorted_data = struct();

            % path adjustment
            % list of all data & subfolders
            filelist_spk = dir([rsp_mat_path who_analysis{who_idx}]);
            % extract subfolders
            subfolders = filelist_spk([filelist_spk(:).isdir]);
            % list of subfolder names (experiments)
            subfolders = {subfolders(3 : end).name};
            adapt_path = ...
                [data_path who_analysis{who_idx} subfolders{exp_idx} '\'];

            % sort the data
            [performances, resp_freq, rec_times] = ...
                sort_behav(rsp_mat_path, who_analysis{who_idx}, ...
                exp_idx, numerosities, patterns);
            % standard & control conditions
            [performances_s, performances_c, ...
                resp_freq_s, resp_freq_c, rec_times_s, rec_times_c] = ...
                stand_cont(rsp_mat_path, who_analysis{who_idx}, ...
                exp_idx, numerosities, patterns);

            % save the data
            sorted_data.performances = performances;
            sorted_data.standard_performances = performances_s;
            sorted_data.control_performances = performances_c;
            sorted_data.resp_freq = resp_freq;
            sorted_data.standard_resp_freq = resp_freq_s;
            sorted_data.control_resp_freq = resp_freq_c;
            sorted_data.rec_times = rec_times;
            sorted_data.standard_rec_times = rec_times_s;
            sorted_data.control_rec_times = rec_times_c;

            save([adapt_path 'sorted_data.mat'], '-struct', 'sorted_data')
        end
    end
end

%% Standard-Control Comparison
% divided into subject, experiment, pattern, sample
% currently: focus on matches only
if to_split_sc

    % pre definition
    focus_idx = 2;
    plot_pos = [21 100];
    progress_counter = 0;
    progress_total = length(experiments{1}) + ...
        length(experiments{2}) + length(experiments{2});

    % set what to analyse further
    what_idx = input(prompt_what);

    % iterate over subjects
    for who_idx = 1:length(who_analysis) - 1

        % human subjects
        if who_idx == 1
            curr_experiments = experiments{1};

            % avian subjects
        else
            curr_experiments = experiments{2};
        end

        % iterate over experiments
        for exp_idx = 1:length(curr_experiments)
            % path adjustment
            % list of all data & subfolders
            filelist = dir([data_path who_analysis{who_idx}]);
            % extract subfolders
            subfolders = filelist([filelist(:).isdir]);
            % list of subfolder names (experiments)
            subfolders = {subfolders(3 : end).name};
            adapt_path = ...
                [data_path who_analysis{who_idx} subfolders{exp_idx} '\'];

            % load the data
            sorted_data = load([adapt_path 'sorted_data.mat']);

            performances_s = sorted_data.standard_performances;
            performances_c = sorted_data.control_performances;
            resp_freq_s = sorted_data.standard_resp_freq;
            resp_freq_c = sorted_data.control_resp_freq;
            rec_times_s = sorted_data.standard_rec_times;
            rec_times_c = sorted_data.control_rec_times;

            switch what_idx
                case 1  % Performance
                    calc_idx = 1;   % Mean
                    err_idx = 2;   % SEM
                    ind_data_s = performances_s;
                    ind_data_c = performances_c;

                case 2  % Response Frequency
                    calc_idx = 1;   % Mean
                    err_idx = 2;    % SEM
                    ind_data_s = resp_freq_s;
                    ind_data_c = resp_freq_c;

                case 3  % Reaction Time
                    calc_idx = 2;   % Median
                    err_idx = 1;    % STD
                    ind_data_s = rec_times_s;
                    ind_data_c = rec_times_c;

                otherwise
                    error("You did not enter a correct data specification.")
            end

            % Statistics: Repeated Measure 2-Way ANOVA
            statistics = anova_sc(performances_s, performances_c, ...
                resp_freq_s, resp_freq_c, rec_times_s, rec_times_c, ...
                patterns, numerosities, {'S', 'C'});

            % Average Calculation
            % Standard Conditions
            [avg_data_s, ~, err_data_s] = ...
                calc_behav(ind_data_s, what_analysis{what_idx}, ...
                calc_type{calc_idx}, err_type{err_idx}, patterns, ...
                numerosities, n_boot, alpha, focus_type{focus_idx});

            % Control Conditions
            [avg_data_c, ~, err_data_c] = ...
                calc_behav(ind_data_c, what_analysis{what_idx}, ...
                calc_type{calc_idx}, err_type{err_idx}, patterns, ...
                numerosities, n_boot, alpha, focus_type{focus_idx});

            % Plot
            fig = plot_s_c(numerosities, ind_data_s, ind_data_c, ...
                avg_data_s, avg_data_c, err_data_s, err_data_c, ...
                what_analysis{what_idx}, ...
                who_analysis{who_idx}(1 : end - 1), calc_type{calc_idx}, ...
                curr_experiments{exp_idx}, patterns, err_type{err_idx}, ...
                jitterwidth, colours_S_C, mrksz, plot_font, plot_pos, ...
                linewidth, capsize, linestyle, {'Standard', 'Control'});
            fig_name = [focus_type{focus_idx} '_StandCont_' ...
                calc_type{calc_idx} '_' err_type{err_idx} '_' ...
                what_analysis{what_idx} '.' format];

            % Save the stuff
            save([adapt_path 'statistics_standard_control.mat'], ...
                '-struct', 'statistics')
            saveas(fig, [figure_path who_analysis{who_idx} ...
                subfolders{exp_idx} '\' fig_name], ...
                format)

            % update progress bar
            progress_counter = progress_counter + 1;  % for progressbar
            progressbar(progress_counter, progress_total)
        end
    end
end

%% Jello-Uri Comparison
% divided into experiment, pattern, sample
% currently: focus on matches only
if to_split_ju

    % pre definition
    focus_idx = 2;
    plot_pos = [21 100];
    progress_counter = 0;
    progress_total = length(experiments{2}) + length(experiments{2});
    curr_experiments = experiments{2};
    

    % set what to analyse further
    what_idx = input(prompt_what);

    % iterate over experiments
    for exp_idx = 1:length(curr_experiments)
        
        % path adjustment
        % list of all data & subfolders
        filelist = dir([data_path who_analysis{4}]);
        % extract subfolders
        subfolders = filelist([filelist(:).isdir]);
        % list of subfolder names (experiments)
        subfolders = {subfolders(3 : end).name};
        adapt_path = [data_path who_analysis{4} subfolders{exp_idx} '\'];
        jello_path = [data_path who_analysis{2} subfolders{exp_idx} '\'];
        uri_path = [data_path who_analysis{3} subfolders{exp_idx} '\'];

        % load the data
        jello_data = load([jello_path 'sorted_data.mat']);
        uri_data = load([uri_path 'sorted_data.mat']);

        performances_j = jello_data.performances;
        performances_c = uri_data.performances;
        resp_freq_j = jello_data.resp_freq;
        resp_freq_c = uri_data.resp_freq;
        rec_times_j = jello_data.rec_times;
        rec_times_c = uri_data.rec_times;

        switch what_idx
            case 1  % Performance
                calc_idx = 1;   % Mean
                err_idx = 2;   % SEM
                ind_data_j = performances_j;
                ind_data_u = performances_u;

            case 2  % Response Frequency
                calc_idx = 1;   % Mean
                err_idx = 2;    % SEM
                ind_data_j = resp_freq_j;
                ind_data_u = resp_freq_u;

            case 3  % Reaction Time
                calc_idx = 2;   % Median
                err_idx = 1;    % STD
                ind_data_j = rec_times_j;
                ind_data_u = rec_times_u;

            otherwise
                error("You did not enter a correct data specification.")
        end

        % Statistics: Repeated Measure 2-Way ANOVA
        statistics = anova_sc(performances_j, performances_u, ...
            resp_freq_j, resp_freq_u, rec_times_j, rec_times_u, ...
            patterns, numerosities, {'J', 'U'});

        % Average Calculation
        % Jello
        [avg_data_j, ~, err_data_j] = ...
            calc_behav(ind_data_j, what_analysis{what_idx}, ...
            calc_type{calc_idx}, err_type{err_idx}, patterns, ...
            numerosities, n_boot, alpha, focus_type{focus_idx});

        % Uri
        [avg_data_u, ~, err_data_u] = ...
            calc_behav(ind_data_u, what_analysis{what_idx}, ...
            calc_type{calc_idx}, err_type{err_idx}, patterns, ...
            numerosities, n_boot, alpha, focus_type{focus_idx});

        % Plot
        fig = plot_s_c(numerosities, ind_data_j, ind_data_u, ...
            avg_data_j, avg_data_u, err_data_j, err_data_u, ...
            what_analysis{what_idx}, ...
            who_analysis{4}(1 : end - 1), calc_type{calc_idx}, ...
            curr_experiments{exp_idx}, patterns, err_type{err_idx}, ...
            jitterwidth, colours_J_U, mrksz, plot_font, plot_pos, ...
            linewidth, capsize, linestyle, {'Jello', 'Uri'});
        fig_name = [focus_type{focus_idx} '_birds_' ...
            calc_type{calc_idx} '_' err_type{err_idx} '_' ...
            what_analysis{what_idx} '.' format];

        % Save the stuff
        save([adapt_path 'statistics_jello_uri.mat'], ...
            '-struct', 'statistics')
        saveas(fig, [figure_path who_analysis{4} subfolders{exp_idx} ...
            '\' fig_name], format)

        % update progress bar
        progress_counter = progress_counter + 1;  % for progressbar
        progressbar(progress_counter, progress_total)
    end
end

%% Pattern Comparison: Matches Only

if to_pattern_matches

    % pre definition
    focus_idx = 2;
    progress_counter = 0;
    progress_total = length(experiments{1}) + ...
        length(experiments{2}) + length(experiments{2});
    % set what to analyse further
    what_idx = input(prompt_what);

    % iterate over subjects
    for who_idx = 1:length(who_analysis) - 1

        % human subjects
        if who_idx == 1
            curr_experiments = experiments{1};

            % avian subjects
        else
            curr_experiments = experiments{2};
        end

        % iterate over experiments
        for exp_idx = 1:length(curr_experiments)
            % pre allocation
            statistics = struct();

            % path adjustment
            % list of all data & subfolders
            filelist = dir([data_path who_analysis{who_idx}]);
            % extract subfolders
            subfolders = filelist([filelist(:).isdir]);
            % list of subfolder names (experiments)
            subfolders = {subfolders(3 : end).name};
            adapt_path = ...
                [data_path who_analysis{who_idx} subfolders{exp_idx} '\'];

            % load the data
            sorted_data = load([adapt_path 'sorted_data.mat']);

            performances = sorted_data.performances;
            resp_freq = sorted_data.resp_freq;
            rec_times = sorted_data.rec_times;

            switch what_idx
                case 1  % Performance
                    calc_idx = 1;   % Mean
                    err_idx = 2;   % SEM
                    ind_data = performances;
                    stats_name = 'Performance';

                case 2  % Response Frequency
                    calc_idx = 1;   % Mean
                    err_idx = 2;    % SEM
                    ind_data = resp_freq;
                    stats_name = 'Response_Frequency';

                case 3  % Reaction Time
                    calc_idx = 2;   % Median
                    err_idx = 1;    % STD
                    ind_data = rec_times;
                    stats_name = 'Reaction_Times';

                otherwise
                    error("You did not enter a correct data specification.")
            end

            % Average Calculation
            [avg_data, avg_data_stats, err_data] = ...
                calc_behav(ind_data, what_analysis{what_idx}, ...
                calc_type{calc_idx}, err_type{err_idx}, patterns, ...
                numerosities, n_boot, alpha, focus_type{focus_idx});

            % Statistics
            [big_statistics, post_hoc] = ...
                pattern_statistics(performances, resp_freq, rec_times, ...
                what_analysis{what_idx}, numerosities, patterns, ...
                avg_data_stats);

            % Linear Regression
            lin_reg_pattern = ...
                lin_regress(performances, resp_freq, rec_times, ...
                patterns, numerosities, what_analysis{what_idx}, avg_data);

            % Plot
            fig = plot_stuff(ind_data, avg_data, err_data, numerosities, ...
                patterns, calc_type{calc_idx}, err_type{err_idx}, ...
                what_analysis{what_idx}, who_analysis{who_idx}(1 : end - 1), ...
                curr_experiments{exp_idx}, plot_font, colours_pattern, ...
                plot_pos, linewidth, linestyle, mrksz, ...
                capsize, jitterwidth, focus_type{focus_idx});
            fig_name = [focus_type{focus_idx} '_' calc_type{calc_idx} '_' ...
                err_type{err_idx} '_' what_analysis{what_idx} '.' format];

            % Save the stuff
            statistics.big_statistics = big_statistics;
            statistics.post_hoc = post_hoc;
            statistics.linear_regression = lin_reg_pattern;
            save([adapt_path 'statistics_pattern_' stats_name '.mat'], ...
                '-struct', 'statistics')
            saveas(fig, ...
                [figure_path who_analysis{who_idx} subfolders{exp_idx} ...
                '\' fig_name], format)

            % update progress bar
            progress_counter = progress_counter + 1;  % for progressbar
            progressbar(progress_counter, progress_total)
        end
    end

end




%% Pattern Comparison: Individual Numbers

if to_pattern_curves

    % Pre Definition
    focus_idx = 3;
    progress_counter = 0;
    progress_total = length(experiments{1}) + ...
        length(experiments{2}) + length(experiments{2});
    % set what to analyse further
    what_idx = input(prompt_what);

    % iterate over subjects
    for who_idx = 1:length(who_analysis) - 1

        % human subjects
        if who_idx == 1
            curr_experiments = experiments{1};

            % avian subjects
        else
            curr_experiments = experiments{2};
        end

        % iterate over experiments
        for exp_idx = 1:length(curr_experiments)

            % path adjustment
            % list of all data & subfolders
            filelist = dir([data_path who_analysis{who_idx}]);
            % extract subfolders
            subfolders = filelist([filelist(:).isdir]);
            % list of subfolder names (experiments)
            subfolders = {subfolders(3 : end).name};
            adapt_path = ...
                [data_path who_analysis{who_idx} subfolders{exp_idx} '\'];

            % load the data
            sorted_data = load([adapt_path 'sorted_data.mat']);

            performances = sorted_data.performances;
            resp_freq = sorted_data.resp_freq;
            rec_times = sorted_data.rec_times;

            switch what_idx
                case 1  % Performance
                    calc_idx = 1;   % Mean
                    err_idx = 2;   % SEM
                    ind_data = performances;

                case 2  % Response Frequency
                    calc_idx = 1;   % Mean
                    err_idx = 2;    % SEM
                    ind_data = resp_freq;

                case 3  % Reaction Time
                    calc_idx = 2;   % Median
                    err_idx = 1;    % STD
                    ind_data = rec_times;

                otherwise
                    error("You did not enter a correct data specification.")
            end

            % Average Calculation
            [avg_data, ~, err_data] = ...
                calc_behav(ind_data, what_analysis{what_idx}, ...
                calc_type{calc_idx}, err_type{err_idx}, patterns, ...
                numerosities, n_boot, alpha, focus_type{focus_idx});

            % Plot
            fig = plot_stuff(ind_data, avg_data, err_data, numerosities, ...
                patterns, calc_type{calc_idx}, err_type{err_idx}, ...
                what_analysis{what_idx}, who_analysis{who_idx}(1 : end - 1), ...
                curr_experiments{exp_idx}, plot_font, colours_pattern, ...
                plot_pos, linewidth, linestyle, mrksz, ...
                capsize, jitterwidth, focus_type{focus_idx});
            fig_name = [focus_type{focus_idx} '_' calc_type{calc_idx} '_' ...
                err_type{err_idx} '_' what_analysis{what_idx} '.' format];

            % Save the stuff
            saveas(fig, ...
                [figure_path who_analysis{who_idx} subfolders{exp_idx} ...
                '\' fig_name], format)

            % update progress bar
            progress_counter = progress_counter + 1;  % for progressbar
            progressbar(progress_counter, progress_total)
        end
    end

end
%% Strictly Standardized Mean Difference

if to_ssmd

    % Pre Definition
    focus_idx = 3;
    progress_counter = 0;
    progress_total = length(experiments{1}) + ...
        length(experiments{2}) + length(experiments{2});
    % set what to analyse further
    what_idx = input(prompt_what);

    % iterate over subjects
    for who_idx = 1:length(who_analysis) - 1

        % human subjects
        if who_idx == 1
            curr_experiments = experiments{1};

            % avian subjects
        else
            curr_experiments = experiments{2};
        end

        % Pre Allocation
        all_smd = NaN(length(curr_experiments), length(patterns), ...
            size(numerosities, 1));
        all_ssmd = NaN(length(curr_experiments), length(patterns), ...
            size(numerosities, 1));

        % iterate over experiments
        for exp_idx = 1:length(curr_experiments)

            % path adjustment
            % list of all data & subfolders
            filelist = dir([data_path who_analysis{who_idx}]);
            % extract subfolders
            subfolders = filelist([filelist(:).isdir]);
            % list of subfolder names (experiments)
            subfolders = {subfolders(3 : end).name};
            adapt_path = ...
                [data_path who_analysis{who_idx} subfolders{exp_idx} '\'];

            % load the data
            sorted_data = load([adapt_path 'sorted_data.mat']);

            performances = sorted_data.performances;
            resp_freq = sorted_data.resp_freq;
            rec_times = sorted_data.rec_times;

            switch what_idx
                case 1  % Performance
                    calc_idx = 1;   % Mean
                    err_idx = 2;   % SEM
                    ind_data = performances;

                case 2  % Response Frequency
                    calc_idx = 1;   % Mean
                    err_idx = 2;    % SEM
                    ind_data = resp_freq;

                case 3  % Reaction Time
                    calc_idx = 2;   % Median
                    err_idx = 1;    % STD
                    ind_data = rec_times;

                otherwise
                    error("You did not enter a correct data specification.")
            end

            performances = sorted_data.performances;
            resp_freq = sorted_data.resp_freq;
            rec_times = sorted_data.rec_times;

            % Average Calculation
            [avg_data, avg_data_stats, err_data] = ...
                calc_behav(ind_data, what_analysis{what_idx}, ...
                calc_type{calc_idx}, err_type{err_idx}, patterns, ...
                numerosities, n_boot, alpha, focus_type{focus_idx});

            % Strictly Standarized Mean Difference
            [all_smd(exp_idx, :, :), all_ssmd(exp_idx, :, :)] = ...
                calc_ssmd(performances, resp_freq, rec_times, ...
                avg_data_stats, patterns, numerosities, ...
                what_analysis{what_idx});

            % update progress bar
            progress_counter = progress_counter + 1;  % for progressbar
            progressbar(progress_counter, progress_total)
        end

        % Plot the SSMD
        fig = plot_ssmd(what_analysis{what_idx}, all_ssmd, ...
            who_analysis{who_idx}(1:end-1), patterns, numerosities, ...
            plot_font, colours_pattern, plot_pos, linewidth, linestyle, ...
            mrksz, jitterwidth, curr_experiments);
        fig_name = ['SSMD_' what_analysis{what_idx} '.' format];

        % Save the stuff
        saveas(fig, ...
            [figure_path who_analysis{who_idx} subfolders{exp_idx} ...
            '\' fig_name], format)
    end
end








