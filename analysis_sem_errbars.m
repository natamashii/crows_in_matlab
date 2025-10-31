clc
clear
close all

% Script for sorting behavioural data

% TODO
% DONE comparison patterns: linear regression, something with correlation
% DONE statistics: kruskal wallis, but which effect size???
% DONE post hoc: mann withney u with bonferroni or Conover–Iman test or dunn???
% DONE divide standard/control stuff, save it separately (incl statistic shit from that)
% DONE generalize standard/control to Jello/Uri
% DONE implement statistics
% DONE normalize pattern diff somehow!!!!!!!!!!!!!!!!!!!!
% to all plots with performance: make it in percentage & add [% correct] in ylabel
% DONE fix conover iman test
% DONE test for performance difference among patterns for each sample
% do regression for each subject
% do nieder vs veit
% DONE add error to all plot legend
% Stimuli: nearest neighbour distance
% set size effect
% maybe compare amount of variation between patterns???
% maybe build linear models or so 
% DONE rewrite analysis stuff as functions
% bootstrapping: more bootstrap statistic? some p value or such stuff?
% avg trial rate per session for everyone
% look at non matches: if previous smoler/bigger -> Lena figure 16
% look at cancellations (crow breaks off)
% Weber fractions maybe???
% for describing stimuli better: spatial clustering coefficient (Marupudi, 2025)
% test avg performance against 0.5 to make sure subject understood task?
% DONE rewrite plotting stuff as one function
% DONE rewrite correction to one resp mat with RT
% DONE rewrite sorting behaviour data as function
% DONE rewrite data extraction from behaviour data as function
% DONE rewrite avg/median + error stuff as function
% DONE rewrite bootstrapping as one function
% DONE make plots with individual dots in background (like fish graphics)
% DONE save data (individual stuff and mean stuff)
% make fig size variable (robust for each device used)
% DONE maybe time for birds
% difference plot birds: divide into exp 1 times & exp1 vs exp2
% mark p value in standard/control & jello/uri plot
% imporve single plot
% DONE regression analysis: add computing in function + plot regression curve separetly in a function
% DONE rewrite standard/control & jello/uri stuff into one case
% DONE different colours for uri & jello comparison thatn for standard & control
% comparison of birds different times exp 1
% DONE make prompt asking adaptable
% check variability in stimuli
% write one script to load all stuff to make it presentable to lena
% in stimpattern_generation.m change input to case insensitive with strcmpi();
% change ind dot colours to be a bit different than the avg data (overlays with box plots...)
% maybe combine plot_stuff with plot_sc somehow....
% DONE add error type to legend in each plot function
% for plotting: extract dot_alpha & marker factor & box alpha & boxwidth factor for all functions
% perhaps look for significant difference in P1 vs. P2/3 first
% DONE save the analysis output somewhere
% something is wrong with calling data for plot_uebersicht_detail

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

to_correct = false; % if response matrices shall be corrected
to_sort = false;     % if data must be sorted first
to_split_sc = false;    % if to compare standard & control conditions
to_split_ju = false;    % if to compare Jello's & Uri's data
to_uebersicht = true;     % if plotting pattern comparison (matches)
to_uebersicht_detail = false;   % if plotting detailed comparison
to_grouping_chunking = false;    % if plotting experiment comparison
to_grouping_chunking_birds = false;
to_stim_dist = false;

% all relevant numerosities (Lena's tabular)
numerosities = [3, 4, 5, 6, 7; % sample
    2, 2, 3, 3, 3;  % test 1 numbers
    5, 6, 7, 4, 4;  % test 2 numbers
    6, 7, 8, 9, 10]';  % test 3 numbers
patterns = {'P1', 'P2', 'P3'};

% for Plotting
colours_pattern_diff = ...
    {[0.8008 0.2578 0.7266]; [0.1445 0.4336 0.2070]; ...
    [0.1211 0.5195 0.6289]};    % colours for patterns
colours_numbers = {[0.1020 0.4900 0.8510]; [0.5760 0.4040 0.9220]; ...
    [0.9220 0.4040 0.6430]; [0.9490 0.4510 0.2670]; ...
    [0.4430 0.6120 0.3250]};    % colours for samples
colour_uebersicht = [0.0000 0.3490 0.2510];
colours_S_C = ...
    {[0.770 0.586 0.289]; [0.531 0.39 0.727]};   % Standard/Control
colours_J_U = ...
    {[0.0000 0.4080 0.7410]; [0.9690 0.3650 0.8000]};   % Jello/Uri
colours_ssmd = {[0.4745 0.3451 0.4706]; [0.1333 0.4745 0.4000]; [0.4627 0.3922 0.6824]};
format = 'svg'; % figure save format
fig_title = '';

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
alpha_stats = 0.05;

% Path definition
base_path = 'G:\Meine Ablage\Master\4. Semester\MasterThesis\analysis\data\';
figure_path = 'G:\Meine Ablage\Master\4. Semester\MasterThesis\figures\progress_since_20250930\';
spk_folderpath = [base_path, 'spk\'];
analysis_path = [base_path, 'analysed\'];
data_path = [analysis_path 'sorted_statistics\'];
rsp_mat_path = [analysis_path 'response_matrices\'];

%% Correct Response Matrix
if to_correct
    progress_counter = 0;
    progress_total = length(experiments{1}) + ...
        length(experiments{2}) + length(experiments{2});
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
                [data_path who_analysis{who_idx} subfolders{exp_idx + 1} '\'];

            % correct the response matrix
            corr_resp(rsp_mat_path, spk_folderpath, who_analysis{who_idx}, ...
                exp_idx, numerosities);

            % update progress bar
            progress_counter = progress_counter + 1;  % for progressbar
            progressbar(progress_counter, progress_total)
        end
    end
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
                [data_path who_analysis{who_idx} subfolders{exp_idx + 1} '\'];

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
if to_split_sc

    % pre definition
    plot_pos = [21 100];
    alpha_stats = 0.05;
    jitterwidth = 0.15;
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
            subfolders = subfolders(2:end);
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
                    focus_idx = 1;  % Matches + Non-Matches
                    ind_data_s = performances_s;
                    ind_data_c = performances_c;

                case 2  % Response Frequency
                    calc_idx = 1;   % Mean
                    err_idx = 2;    % SEM
                    focus_idx = 1;  % Matches + Non-Matches
                    ind_data_s = resp_freq_s;
                    ind_data_c = resp_freq_c;

                case 3  % Reaction Time
                    calc_idx = 2;   % Median
                    err_idx = 1;    % STD
                    focus_idx = 2;  % Matches 
                    ind_data_s = rec_times_s;
                    ind_data_c = rec_times_c;

                otherwise
                    error("You did not enter a correct data specification.")
            end

            % Statistics: Friedman
            statistics = stats_sc(performances_s, performances_c, ...
                resp_freq_s, resp_freq_c, rec_times_s, rec_times_c, ...
                patterns, numerosities, {'S', 'C'}, alpha_stats);

            % Average Calculation
            [avg_data_s, avg_data_c, err_data_s, err_data_c] = ...
                calc_behav_sc(ind_data_s, ind_data_c, ...
                what_analysis{what_idx}, err_type{err_idx}, ...
                calc_type{calc_idx}, numerosities);

            % Plot
            fig = plot_s_c(numerosities, ind_data_s, ind_data_c, ...
                avg_data_s, avg_data_c, err_data_s, err_data_c, ...
                what_analysis{what_idx}, ...
                who_analysis{who_idx}(1:end - 1), calc_type{calc_idx}, ...
                curr_experiments{exp_idx}, err_type{err_idx}, ...
                jitterwidth, colours_S_C, mrksz, plot_font, plot_pos, ...
                linewidth, capsize, linestyle, {'Standard', 'Control'});
            
            fig_name = [focus_type{focus_idx} '_StandCont_' ...
                calc_type{calc_idx} '_' err_type{err_idx} '_' ...
                what_analysis{what_idx} '.' format];

            % Save the stuff
            save([adapt_path 'statistics_standard_control.mat'], ...
                '-struct', 'statistics')
            saveas(fig, [figure_path who_analysis{who_idx} ...
                subfolders{exp_idx} '\' what_analysis{what_idx} '\' ...
                fig_name], format)

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
    plot_pos = [21 200];
    alpha_stats = 0.05;
    jitterwidth = 0.1;
    progress_counter = 0;
    progress_total = length(experiments{2});
    curr_experiments = experiments{2};
    
    % set what to analyse further
    what_idx = input(prompt_what);
    who_idx = 4;

    % iterate over experiments
    for exp_idx = 1:length(curr_experiments)
        
        % path adjustment
        % list of all data & subfolders
        filelist = dir([data_path who_analysis{4}]);
        % extract subfolders
        subfolders = filelist([filelist(:).isdir]);
        % list of subfolder names (experiments)
        subfolders = {subfolders(3 : end).name};
        subfolders = subfolders(2:end);
        adapt_path = [data_path who_analysis{4} subfolders{exp_idx} '\'];
        jello_path = [data_path who_analysis{2} subfolders{exp_idx} '\'];
        uri_path = [data_path who_analysis{3} subfolders{exp_idx} '\'];

        % load the data
        jello_data = load([jello_path 'sorted_data.mat']);
        uri_data = load([uri_path 'sorted_data.mat']);

        performances_j = jello_data.performances;
        performances_j_s = jello_data.standard_performances;
        performances_j_c = jello_data.control_performances;
        performances_u = uri_data.performances;
        performances_u_s = uri_data.standard_performances;
        performances_u_c = uri_data.control_performances;
        resp_freq_j = jello_data.resp_freq;
        resp_freq_j_s = jello_data.standard_resp_freq;
        resp_freq_j_c = jello_data.control_resp_freq;
        resp_freq_u = uri_data.resp_freq;
        resp_freq_u_s = uri_data.standard_resp_freq;
        resp_freq_u_c = uri_data.control_resp_freq;
        rec_times_j = jello_data.rec_times;
        rec_times_j_s = jello_data.standard_rec_times;
        rec_times_j_c = jello_data.control_rec_times;
        rec_times_u = uri_data.rec_times;
        rec_times_u_s = uri_data.standard_rec_times;
        rec_times_u_c = uri_data.control_rec_times;

        switch what_idx
            case 1  % Performance
                calc_idx = 1;   % Mean
                err_idx = 2;   % SEM
                focus_idx = 1;  % Maches + Non-Matches
                ind_data_j = performances_j;
                ind_data_j_s = performances_j_s;
                ind_data_j_c = performances_j_c;
                ind_data_u = performances_u;
                ind_data_u_s = performances_u_s;
                ind_data_u_c = performances_u_c;

            case 2  % Response Frequency
                calc_idx = 1;   % Mean
                err_idx = 2;    % SEM
                focus_idx = 1;  % Maches + Non-Matches
                ind_data_j = resp_freq_j;
                ind_data_j_s = resp_freq_j_s;
                ind_data_j_c = resp_freq_j_c;
                ind_data_u = resp_freq_u;
                ind_data_u_s = resp_freq_u_s;
                ind_data_u_c = resp_freq_u_c;

            case 3  % Reaction Time
                calc_idx = 2;   % Median
                err_idx = 1;    % STD
                focus_idx = 2;  % Matches
                ind_data_j = rec_times_j;
                ind_data_j_s = rec_times_j_s;
                ind_data_j_c = rec_times_j_c;
                ind_data_u = rec_times_u;
                ind_data_u_s = rec_times_u_s;
                ind_data_u_c = rec_times_u_c;

            otherwise
                error("You did not enter a correct data specification.")
        end

        % Statistics Standard/Control: Friedman
        % Jello
        statistics_jello = stats_sc(performances_j_s, performances_j_c, ...
                resp_freq_j_s, resp_freq_j_c, ...
                rec_times_j_s, rec_times_j_c, ...
                patterns, numerosities, {'S', 'C'}, alpha_stats);
        % Uri
        statistics_uri = stats_sc(performances_u_s, performances_u_c, ...
                resp_freq_u_s, resp_freq_u_c, ...
                rec_times_u_s, rec_times_u_c, ...
                patterns, numerosities, {'S', 'C'}, alpha_stats);

        % Statistics Jello/Uri: Friedman
        statistics_birds = stats_birds(performances_j, performances_u, ...
            resp_freq_j, resp_freq_u, rec_times_j, rec_times_u, ...
            {'J', 'U'}, patterns, numerosities, alpha_stats);

        % Average Calculation
        % Jello, Standard & Control Conditions
        [avg_data_j_s, avg_data_j_c, err_data_j_s, err_data_j_c] = ...
                calc_behav_sc(ind_data_j_s, ind_data_j_c, ...
                what_analysis{what_idx}, err_type{err_idx}, ...
                calc_type{calc_idx}, numerosities);
        
        % Uri, Standard & Control Conditions
        [avg_data_u_s, avg_data_u_c, err_data_u_s, err_data_u_c] = ...
                calc_behav_sc(ind_data_u_s, ind_data_u_c, ...
                what_analysis{what_idx}, err_type{err_idx}, ...
                calc_type{calc_idx}, numerosities);

        % Plot
        fig = ...
            plot_birds(numerosities, ind_data_j_s, ind_data_j_c, ...
            ind_data_u_s, ind_data_u_c, ...
            avg_data_j_s, avg_data_j_c, avg_data_u_s, avg_data_u_c, ...
            err_data_j_s, err_data_j_c, err_data_u_s, err_data_u_c, ...
            what_analysis{what_idx}, who_analysis{who_idx}(1:end - 1), ...
            calc_type{calc_idx}, curr_experiments{exp_idx}, ...
            err_type{err_idx}, jitterwidth, colours_J_U, ...
            mrksz, plot_font, plot_pos, ...
            linewidth, capsize, linestyle, {'Jello', 'Uri'});
        fig_name = [focus_type{focus_idx} '_birds_' ...
            calc_type{calc_idx} '_' err_type{err_idx} '_' ...
            what_analysis{what_idx} '.' format];

        % Save the stuff
        save([jello_path 'statistics_jello.mat'], ...
            '-struct', 'statistics_jello')
        save([uri_path 'statistics_uri.mat'], ...
            '-struct', 'statistics_uri')
        save([adapt_path 'statistics_birds.mat'], ...
            '-struct', 'statistics_birds')
        saveas(fig, [figure_path who_analysis{4} subfolders{exp_idx} ...
            '\' what_analysis{what_idx} '\' fig_name], format)

        % update progress bar
        progress_counter = progress_counter + 1;  % for progressbar
        progressbar(progress_counter, progress_total)
    end
end

%% Übersichts-Plot: Pattern Comparison

if to_uebersicht

    % pre definition
    progress_counter = 0;
    progress_total = length(experiments{1}) + ...
        length(experiments{2}) + length(experiments{2}) + ...
        length(experiments{2});

    % set what to analyse further
    what_idx = input(prompt_what);

    % iterate over subjects
    for who_idx = 1:length(who_analysis)

        % human subjects
        if who_idx == 1
            curr_experiments = experiments{1};

        % avian subjects
        elseif who_idx == 4
            curr_experiments = experiments{2};
            jitterwidth = 0.1;
        else
            curr_experiments = experiments{2};
        end

        % iterate over experiments
        for exp_idx = 1:length(curr_experiments)
            % if both crows
            if who_idx == 4
                % Extract Jello's data 
                % path adjustment
                % list of all data & subfolders
                filelist = dir([data_path who_analysis{2}]);
                % extract subfolders
                subfolders = filelist([filelist(:).isdir]);
                % list of subfolder names (experiments)
                subfolders = {subfolders(3 : end).name};
                subfolders = subfolders(2:end);
                jello_path = ...
                    [data_path who_analysis{2} subfolders{exp_idx} '\'];

                % load the data
                sorted_data_jello = load([jello_path 'sorted_data.mat']);

                performances_j = sorted_data_jello.performances;
                resp_freq_j = sorted_data_jello.resp_freq;
                rec_times_j = sorted_data_jello.rec_times;

                % Extract Uri's Data
                % path adjustment
                % list of all data & subfolders
                filelist = dir([data_path who_analysis{3}]);
                % extract subfolders
                subfolders = filelist([filelist(:).isdir]);
                % list of subfolder names (experiments)
                subfolders = {subfolders(3 : end).name};
                subfolders = subfolders(2:end);
                uri_path = ...
                    [data_path who_analysis{3} subfolders{exp_idx} '\'];

                % load the data
                sorted_data_uri = load([uri_path 'sorted_data.mat']);

                performances_u = sorted_data_uri.performances;
                resp_freq_u = sorted_data_uri.resp_freq;
                rec_times_u = sorted_data_uri.rec_times;
            else
                % pre allocation
                statistics = struct();

                % path adjustment
                % list of all data & subfolders
                filelist = dir([data_path who_analysis{who_idx}]);
                % extract subfolders
                subfolders = filelist([filelist(:).isdir]);
                % list of subfolder names (experiments)
                subfolders = {subfolders(3 : end).name};
                subfolders = subfolders(2:end);
                adapt_path = ...
                    [data_path who_analysis{who_idx} subfolders{exp_idx} '\'];

                % load the data
                sorted_data = load([adapt_path 'sorted_data.mat']);

                performances = sorted_data.performances;
                resp_freq = sorted_data.resp_freq;
                rec_times = sorted_data.rec_times;
            end

            switch what_idx
                case 1  % Performance
                    calc_idx = 1;   % Mean
                    err_idx = 2;   % SEM
                    focus_idx = 1;  % Matches + Non-Matches
                    if who_idx == 4
                        ind_data_j = performances_j;
                        ind_data_u = performances_u;
                    else
                        ind_data = performances;
                    end
                    stats_name = 'Performance';

                case 2  % Response Frequency
                    calc_idx = 1;   % Mean
                    err_idx = 2;    % SEM
                    focus_idx = 1;  % Matches + Non-Matches
                    if who_idx == 4
                        ind_data_j = resp_freq_j;
                        ind_data_u = resp_freq_u;
                    else
                        ind_data = resp_freq;
                    end
                    stats_name = 'Response_Frequency';

                case 3  % Reaction Time
                    calc_idx = 2;   % Median
                    err_idx = 1;    % STD
                    focus_idx = 2;  % Matches
                    if who_idx == 4
                        ind_data_j = rec_times_j;
                        ind_data_u = rec_times_u;
                    else
                        ind_data = rec_times;
                    end
                    stats_name = 'Reaction_Times';

                otherwise
                    error("You did not enter a correct data specification.")
            end

            if who_idx == 4
                % Average Calculation
                % Jello
                [avg_data_j, ~, err_data_j] = ...
                    calc_behav(ind_data_j, what_analysis{what_idx}, ...
                    calc_type{calc_idx}, err_type{err_idx}, patterns, ...
                    numerosities, n_boot, alpha, ...
                    focus_type{focus_idx}, false);

                % Uri
                [avg_data_u, ~, err_data_u] = ...
                    calc_behav(ind_data_u, what_analysis{what_idx}, ...
                    calc_type{calc_idx}, err_type{err_idx}, patterns, ...
                    numerosities, n_boot, alpha, ...
                    focus_type{focus_idx}, false);

                % Linear Regression
                % Jello
                lin_reg_jello = ...
                    lin_regress(performances_j, resp_freq_j, ...
                    rec_times_j, patterns, numerosities, ...
                    n_boot, alpha_stats);

                % Uri
                lin_reg_uri = ...
                    lin_regress(performances_u, resp_freq_u, ...
                    rec_times_u, patterns, numerosities, ...
                    n_boot, alpha_stats);

                % Plot
                fig = plot_uebersicht({ind_data_j, ind_data_u}, ...
                    {avg_data_j, avg_data_u}, {err_data_j, err_data_u}, ...
                    patterns, calc_type{calc_idx}, err_type{err_idx}, ...
                    what_analysis{what_idx}, what_idx, ...
                    who_analysis{who_idx}(1:end - 1), ...
                    curr_experiments{exp_idx}, plot_font, ...
                    colours_J_U, plot_pos, linewidth, ...
                    mrksz, capsize, jitterwidth, focus_type{focus_idx}, ...
                    0.3, 4, {lin_reg_jello, lin_reg_uri}, true);
                fig_name = [focus_type{focus_idx} '_Übersicht_' ...
                    calc_type{calc_idx} '_' ...
                    err_type{err_idx} '_' what_analysis{what_idx} '.' format];
            
            else

                % Average Calculation
                [avg_data, avg_data_stats, err_data] = ...
                    calc_behav(ind_data, what_analysis{what_idx}, ...
                    calc_type{calc_idx}, err_type{err_idx}, patterns, ...
                    numerosities, n_boot, alpha, focus_type{focus_idx}, false);

                % Statistics
                [big_statistics, post_hoc] = ...
                    pattern_statistics({performances}, ...
                    {resp_freq}, {rec_times}, ...
                    what_analysis{what_idx}, numerosities, patterns, ...
                    avg_data_stats);

                % Linear Regression
                lin_reg = ...
                    lin_regress(performances, resp_freq, ...
                    rec_times, patterns, numerosities, ...
                    n_boot, alpha_stats);

                % Plot
                fig = plot_uebersicht({ind_data}, {avg_data}, {err_data}, ...
                    patterns, calc_type{calc_idx}, err_type{err_idx}, ...
                    what_analysis{what_idx}, what_idx, ...
                    who_analysis{who_idx}(1:end - 1), ...
                    curr_experiments{exp_idx}, plot_font, ...
                    {colour_uebersicht}, plot_pos, linewidth, ...
                    mrksz, capsize, jitterwidth, focus_type{focus_idx}, ...
                    0.3, 4, {lin_reg}, true);
                fig_name = [focus_type{focus_idx} '_Übersicht_' ...
                    calc_type{calc_idx} '_' ...
                    err_type{err_idx} '_' what_analysis{what_idx} '.' format];

                % Save the stuff
                statistics.big_statistics = big_statistics;
                statistics.post_hoc = post_hoc;
                statistics.lin_reg = lin_reg;
                save([adapt_path 'statistics_pattern_' stats_name '.mat'], ...
                    '-struct', 'statistics')
            end
            saveas(fig, ...
                [figure_path who_analysis{who_idx} subfolders{exp_idx} ...
                '\' what_analysis{what_idx} '\' fig_name], format)

            % update progress bar
            progress_counter = progress_counter + 1;  % for progressbar
            progressbar(progress_counter, progress_total)
        end
    end

end

%% More Detailed Überblick

if to_uebersicht_detail

    % Pre Definition
    progress_counter = 0;
    progress_total = length(experiments{1}) + ...
        length(experiments{2}) + length(experiments{2});
    plot_pos = [21, 120];

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
            % if combining Jello and Uri
            if who_idx == 4
                [performances, resp_freq, rec_times] = ...
                    bird_combination(data_path, exp_idx);
            else
                % pre allocation
                statistics = struct();

                % path adjustment
                % list of all data & subfolders
                filelist = dir([data_path who_analysis{who_idx}]);
                % extract subfolders
                subfolders = filelist([filelist(:).isdir]);
                % list of subfolder names (experiments)
                subfolders = {subfolders(3 : end).name};
                subfolders = subfolders(2:end);
                adapt_path = ...
                    [data_path who_analysis{who_idx} subfolders{exp_idx} '\'];

                % load the data
                sorted_data = load([adapt_path 'sorted_data.mat']);

                performances = sorted_data.performances;
                resp_freq = sorted_data.resp_freq;
                rec_times = sorted_data.rec_times;
            end

            switch what_idx
                case 1  % Performance
                    calc_idx = 1;   % Mean
                    err_idx = 2;   % SEM
                    focus_idx = 3;  % Matches + Non-Matches
                    ind_data = performances;
                    stats_name = 'Performance';

                case 2  % Response Frequency
                    calc_idx = 1;   % Mean
                    err_idx = 2;    % SEM
                    focus_idx = 3;  % Matches + Non-Matches
                    ind_data = resp_freq;
                    stats_name = 'Response_Frequency';

                case 3  % Reaction Time
                    calc_idx = 2;   % Median
                    err_idx = 1;    % STD
                    focus_idx = 3;  % Matches
                    ind_data = rec_times;
                    stats_name = 'Reaction_Times';

                otherwise
                    error("You did not enter a correct data specification.")
            end

            % Average Calculation
            [avg_data, avg_data_stats, err_data] = ...
                calc_behav(ind_data, what_analysis{what_idx}, ...
                calc_type{calc_idx}, err_type{err_idx}, patterns, ...
                numerosities, n_boot, alpha, focus_type{focus_idx}, false);

            % Plot
            fig = plot_uebersicht_detail(ind_data, avg_data, err_data, ...
                numerosities, ...
                patterns, calc_type{calc_idx}, err_type{err_idx}, ...
                what_analysis{what_idx}, ...
                who_analysis{who_idx}(1:end - 1), ...
                curr_experiments{exp_idx}, plot_font, ...
                colours_numbers, plot_pos, linewidth, ...
                mrksz, capsize, jitterwidth, 0.3, 4);
            fig_name = [focus_type{focus_idx} '_Übersicht_detail_' ...
                calc_type{calc_idx} '_' ...
                err_type{err_idx} '_' what_analysis{what_idx} '.' format];

            % Save the stuff
            saveas(fig, ...
                [figure_path who_analysis{who_idx} subfolders{exp_idx} ...
                '\' what_analysis{what_idx} '\' fig_name], format)

            % update progress bar
            progress_counter = progress_counter + 1;  % for progressbar
            progressbar(progress_counter, progress_total)
        end
    end
end

%% Grouping-Chunking Plot
% try both: p2-p1 p3-p1 getrennt & combined (chunking)

if to_grouping_chunking

    % Pre Definition
    alpha_stats = 0.05;
    progress_counter = 0;
    jitterwidth = 0.15;
    progress_total = size(numerosities, 1) + ...
        (length(who_analysis) - 1) * size(numerosities, 1) * 2;

    % set what to analyse further
    what_idx = input(prompt_what);

    % iterate over subjects
    for who_idx = 1:length(who_analysis)

        if who_idx == 1        % human subjects
            curr_experiments = {'Exp 1'; 'Exp 2'; 'Exp 3'};
            exp_x_vals = {[1, 2, 3]};
            fig_name_extension = {'_all_exp_'};
            colours_pattern_diff = colours_pattern_diff(2);
            plot_pos = {[21, 150]};

        else        % avian subjects
            curr_experiments = ...
                {'Exp 1 300 ms'; 'Exp 1 100 ms'; ...
                'Exp 1 50 ms'; 'Exp 2 50 ms'};
            exp_x_vals = {[3, 2, 1], [3, 4]};
            fig_name_extension = {'_diff_times_'; '_exp1_2_'};
            colours_pattern_diff = colours_J_U;
            plot_pos = {[21, 150], [21, 120]};
        end

        if who_idx == 2     % Set Colours for Jello
            colours_pattern_diff = colours_J_U(1);
        elseif who_idx == 3 % Set Colours for Uri
            colours_pattern_diff = colours_J_U(2);
        end

        % Pre Allocation
        all_performances = {cell(length(curr_experiments), 1)};
        all_resp_freq = {cell(length(curr_experiments), 1)};
        all_rec_times = {cell(length(curr_experiments), 1)};

        % iterate over experiments
        for exp_idx = 1:length(curr_experiments)
            if who_idx < 4
                % path adjustment
                % list of all data & subfolders
                filelist = dir([data_path who_analysis{who_idx}]);
                % extract subfolders
                subfolders = filelist([filelist(:).isdir]);
                % list of subfolder names (experiments)
                subfolders = {subfolders(3 : end).name};
                subfolders = subfolders(2:end);
                adapt_path = ...
                    [data_path who_analysis{who_idx} subfolders{exp_idx} '\'];

                % load the data
                sorted_data = load([adapt_path 'sorted_data.mat']);

                all_performances{1}{exp_idx} = sorted_data.performances;
                all_resp_freq{1}{exp_idx} = sorted_data.resp_freq;
                all_rec_times{1}{exp_idx} = sorted_data.rec_times;

            else    % Plot both crows
                % path adjustment
                % list of all data & subfolders
                filelist = dir([data_path who_analysis{2}]);
                % extract subfolders
                subfolders = filelist([filelist(:).isdir]);
                % list of subfolder names (experiments)
                subfolders = {subfolders(3 : end).name};
                subfolders = subfolders(2:end);
                jello_path = ...
                    [data_path who_analysis{2} subfolders{exp_idx} '\'];
                uri_path = ...
                    [data_path who_analysis{3} subfolders{exp_idx} '\'];
                adapt_path = ...
                    [data_path who_analysis{4} subfolders{exp_idx} '\'];

                % Get Jello's Data
                sorted_data = load([jello_path 'sorted_data.mat']);
                all_performances{1}{exp_idx} = sorted_data.performances;
                all_resp_freq{1}{exp_idx} = sorted_data.resp_freq;
                all_rec_times{1}{exp_idx} = sorted_data.rec_times;

                % Get Uri's Data
                sorted_data = load([uri_path 'sorted_data.mat']);
                all_performances{2}{exp_idx} = sorted_data.performances;
                all_resp_freq{2}{exp_idx} = sorted_data.resp_freq;
                all_rec_times{2}{exp_idx} = sorted_data.rec_times;
            end

            switch what_idx
                case 1  % Performance
                    calc_idx = 1;   % Mean
                    err_idx = 2;   % SEM
                    focus_idx = 1;  % Matches + Non-Matches
                    stats_name = 'Performance';

                case 2  % Response Frequency
                    calc_idx = 1;   % Mean
                    err_idx = 2;    % SEM
                    focus_idx = 1;  % Matches + Non-Matches
                    stats_name = 'Response_Frequency';

                case 3  % Reaction Time
                    calc_idx = 2;   % Median
                    err_idx = 1;    % STD
                    focus_idx = 2;  % Matches
                    stats_name = 'Reaction_Times';

                otherwise
                    error("You did not enter a correct data specification.")
            end
        end
        
        % Get Pattern Differences
        diff_data = ...
            pattern_diffs(all_performances, all_resp_freq, ...
            all_rec_times, patterns, numerosities, ...
            what_analysis{what_idx}, curr_experiments, ...
            focus_type{focus_idx}, calc_type{calc_idx}, err_type{err_idx});

        % Hodges-Lehmann Estimator
        walsh_HL = ...
            hodges_lehmann_estimator(diff_data, curr_experiments, ...
            numerosities, n_boot, alpha_stats);

        % Statistics
        if who_idx < 4
            [statistics] = ...
                stats_pattern_diff(all_performances, ...
                all_resp_freq, all_rec_times, ...
                curr_experiments, patterns, numerosities, alpha_stats);
        end

        % Iterate over versions to plot
        for ver_idx = 1:length(exp_x_vals)

            % iterate over samples
            for sample_idx = 1:size(numerosities, 1)

                % Plot: Divided Into all Patterns, Raw Data
                fig_diff = ...
                    plot_c_g(diff_data, colours_pattern_diff, ...
                    curr_experiments, what_analysis{what_idx}, ...
                    who_analysis{who_idx}(1:end-1), err_type{err_idx}, ...
                    calc_type{calc_idx}, numerosities, ...
                    sample_idx, plot_font, plot_pos{ver_idx}, ...
                    linewidth, mrksz, ...
                    capsize, jitterwidth, 0.3, 4, patterns, ...
                    exp_x_vals{ver_idx});
                % Set Figure File Names
                fig_name_diff = ['ChunkGroup_divided_' ...
                    fig_name_extension{ver_idx} focus_type{focus_idx} ...
                    '_' calc_type{calc_idx} '_' err_type{err_idx} ...
                    '_' what_analysis{what_idx} '_Sample_' ...
                    num2str(numerosities(sample_idx, 1)) '.' format];
                % Save the figure
                saveas(fig_diff, ...
                    [figure_path who_analysis{who_idx} ...
                    '\all_experiments\Sample_' ...
                    num2str(numerosities(sample_idx, 1)) '\' ...
                    what_analysis{what_idx} '\' ...
                    fig_name_diff], format)
                clear fig_diff

                % Plot: Divided Into all Patterns, Walsh-Averages
                fig_diff_walsh = ...
                    plot_c_g(walsh_HL, colours_pattern_diff, ...
                    curr_experiments, what_analysis{what_idx}, ...
                    who_analysis{who_idx}(1:end-1), 'CI', ...
                    "HL" + newline + "Estimator", numerosities, ...
                    sample_idx, plot_font, plot_pos{ver_idx}, ...
                    linewidth, mrksz, ...
                    capsize, jitterwidth, 0.3, 4, patterns, ...
                    exp_x_vals{ver_idx});
                % Set Figure File Names
                fig_name_diff_walsh = ['ChunkGroup_divided_Walsh_HL' ...
                    fig_name_extension{ver_idx} focus_type{focus_idx} ...
                    '_' calc_type{calc_idx} '_' err_type{err_idx} ...
                    '_' what_analysis{what_idx} '_Sample_' ...
                    num2str(numerosities(sample_idx, 1)) '.' format];
                % Save the figure
                saveas(fig_diff_walsh, ...
                    [figure_path who_analysis{who_idx} ...
                    '\all_experiments\Sample_' ...
                    num2str(numerosities(sample_idx, 1)) '\' ...
                    what_analysis{what_idx} '\' ...
                    fig_name_diff_walsh], format)
                clear fig_diff_walsh

                % update progress bar
                progress_counter = progress_counter + 1;  % for progressbar
                progressbar(progress_counter, progress_total)
            end
        end

        % Save the stuff
        adapt_path = [data_path who_analysis{who_idx} '\all_experiments\'];
        if who_idx < 4
            save([adapt_path 'statistics_chunking_grouping_' stats_name '.mat'], ...
                '-struct', 'statistics')
        end
    end
end

%% Grouping-Chunking Plot: Birds, divided into Experiments 1 & 2 and times 

if to_grouping_chunking_birds

    % Pre Definition
    alpha_stats = 0.05;
    progress_counter = 0;
    curr_experiments = ...
        {'Exp 1 300 ms'; 'Exp 1 100 ms'; ...
        'Exp 1 50 ms'; 'Exp 2 50 ms'};
    exp_x_vals = {[3, 2, 1], [3, 4]};
    progress_total = (length(who_analysis) - 1) * ...
        size(numerosities, 1);
    fig_name_extension = {'_diff_times_'; '_exp1_2_'};

    % set what to analyse further
    what_idx = input(prompt_what);

    % iterate over subjects
    for who_idx = 2:length(who_analysis) - 1

        % Pre Allocation
        all_performances = cell(length(curr_experiments), 1);
        all_resp_freq = cell(length(curr_experiments), 1);
        all_rec_times = cell(length(curr_experiments), 1);

        % iterate over experiments
        for exp_idx = 1:length(curr_experiments)
            % if combining Jello and Uri
            if who_idx == 4
                [performances, resp_freq, rec_times] = ...
                    bird_combination(data_path, exp_idx);
                all_performances{exp_idx} = performances;
                all_resp_freq{exp_idx} = resp_freq;
                all_rec_times{exp_idx} = rec_times;

            else
                % path adjustment
                % list of all data & subfolders
                filelist = dir([data_path who_analysis{who_idx}]);
                % extract subfolders
                subfolders = filelist([filelist(:).isdir]);
                % list of subfolder names (experiments)
                subfolders = {subfolders(3 : end).name};
                subfolders = subfolders(2:end);
                adapt_path = ...
                    [data_path who_analysis{who_idx} subfolders{exp_idx} '\'];

                % load the data
                sorted_data = load([adapt_path 'sorted_data.mat']);

                all_performances{exp_idx} = sorted_data.performances;
                all_resp_freq{exp_idx} = sorted_data.resp_freq;
                all_rec_times{exp_idx} = sorted_data.rec_times;
            end

            switch what_idx
                case 1  % Performance
                    calc_idx = 1;   % Mean
                    err_idx = 2;   % SEM
                    focus_idx = 1;  % Matches + Non-Matches
                    ind_data{exp_idx} = all_performances{exp_idx};
                    stats_name = 'Performance';

                case 2  % Response Frequency
                    calc_idx = 1;   % Mean
                    err_idx = 2;    % SEM
                    focus_idx = 1;  % Matches + Non-Matches
                    ind_data{exp_idx} = all_resp_freq{exp_idx};
                    stats_name = 'Response_Frequency';

                case 3  % Reaction Time
                    calc_idx = 2;   % Median
                    err_idx = 1;    % STD
                    focus_idx = 2;  % Matches
                    ind_data{exp_idx} = all_rec_times{exp_idx};
                    stats_name = 'Reaction_Times';

                otherwise
                    error("You did not enter a correct data specification.")
            end
        end
        
        % Get Pattern Differences
        diff_data = ...
            pattern_diffs(all_performances, all_resp_freq, ...
            all_rec_times, patterns, numerosities, ...
            what_analysis{what_idx}, curr_experiments, ...
            focus_type{focus_idx}, calc_type{calc_idx}, err_type{err_idx});

        % Hodges-Lehmann Estimator
        walsh_HL = ...
            hodges_lehmann_estimator(diff_data, curr_experiments, ...
            numerosities, n_boot, alpha_stats);

        % Statistics
        [statistics] = ...
            stats_pattern_diff(all_performances, ...
            all_resp_freq, all_rec_times, ...
            curr_experiments, patterns, numerosities, alpha_stats);

        % Iterate over both versions to plot
        for ver_idx = 1:length(exp_x_vals)

            % iterate over samples
            for sample_idx = 1:size(numerosities, 1)

                % Plot: Divided Into all Patterns, Raw Data
                fig_diff = ...
                    plot_c_g(diff_data, colours_pattern_diff, ...
                    curr_experiments, what_analysis{what_idx}, ...
                    who_analysis{who_idx}(1:end-1), err_type{err_idx}, ...
                    calc_type{calc_idx}, numerosities, sample_idx, ...
                    plot_font, plot_pos, linewidth, mrksz, ...
                    capsize, jitterwidth / 2, 0.3, 4, ...
                    false, exp_x_vals{ver_idx});

                % Plot: Divided Into all Patterns, Walsh-Averages
                fig_diff_walsh = ...
                    plot_c_g(walsh_HL, colours_pattern_diff, ...
                    curr_experiments, what_analysis{what_idx}, ...
                    who_analysis{who_idx}(1:end-1), 'CI', ...
                    'Hodges-Lehmann Estimator', numerosities, sample_idx, ...
                    plot_font, plot_pos, linewidth, mrksz, ...
                    capsize, jitterwidth / 2, 0.3, 4, ...
                    false, exp_x_vals{ver_idx});

                % Plot: Chunking/Grouping, Raw Data
                fig_no_diff = ...
                    plot_c_g(diff_data, colours_pattern_diff, ...
                    curr_experiments, what_analysis{what_idx}, ...
                    who_analysis{who_idx}(1:end-1), err_type{err_idx}, ...
                    calc_type{calc_idx}, numerosities, sample_idx, ...
                    plot_font, plot_pos, linewidth, mrksz, ...
                    capsize, jitterwidth, 0.3, 4, ...
                    true, exp_x_vals{ver_idx});

                % Plot: Chunking/Groupitizing, Walsh-Averages
                fig_no_diff_walsh = ...
                    plot_c_g(walsh_HL, colours_pattern_diff, ...
                    curr_experiments, what_analysis{what_idx}, ...
                    who_analysis{who_idx}(1:end-1), 'CI', ...
                    'Hodges-Lehmann Estimator', numerosities, sample_idx, ...
                    plot_font, plot_pos, linewidth, mrksz, ...
                    capsize, jitterwidth, 0.3, 4, ...
                    true, exp_x_vals{ver_idx});

                % Set Figure File Names
                fig_name_diff = ['ChunkGroup_divided_' ...
                    fig_name_extension{ver_idx} focus_type{focus_idx} ...
                    '_' calc_type{calc_idx} '_' err_type{err_idx} ...
                    '_' what_analysis{what_idx} '_Sample_' ...
                    num2str(numerosities(sample_idx, 1)) '.' format];
                fig_name_diff_walsh = ['ChunkGroup_divided_Walsh_HL' ...
                    fig_name_extension{ver_idx} focus_type{focus_idx} ...
                    '_' calc_type{calc_idx} '_' err_type{err_idx} ...
                    '_' what_analysis{what_idx} '_Sample_' ...
                    num2str(numerosities(sample_idx, 1)) '.' format];
                fig_name_no_diff = ['ChunkGroup_' ...
                    fig_name_extension{ver_idx} focus_type{focus_idx} ...
                    '_' calc_type{calc_idx} '_' err_type{err_idx} ...
                    '_' what_analysis{what_idx} '_Sample_' ...
                    num2str(numerosities(sample_idx, 1)) '.' format];
                fig_name_no_diff_walsh = ['ChunkGroup_Walsh_HL' ...
                    fig_name_extension{ver_idx} focus_type{focus_idx} ...
                    '_' calc_type{calc_idx} '_' err_type{err_idx} ...
                    '_' what_analysis{what_idx} '_Sample_' ...
                    num2str(numerosities(sample_idx, 1)) '.' format];

                % Save the figure
                saveas(fig_diff, ...
                    [figure_path who_analysis{who_idx} ...
                    '\all_experiments\Sample_' ...
                    num2str(numerosities(sample_idx, 1)) '\' ...
                    what_analysis{what_idx} '\' ...
                    fig_name_diff], format)
                saveas(fig_diff_walsh, ...
                    [figure_path who_analysis{who_idx} ...
                    '\all_experiments\Sample_' ...
                    num2str(numerosities(sample_idx, 1)) '\' ...
                    what_analysis{what_idx} '\' ...
                    fig_name_diff_walsh], format)
                saveas(fig_no_diff, ...
                    [figure_path who_analysis{who_idx} ...
                    '\all_experiments\Sample_' ...
                    num2str(numerosities(sample_idx, 1)) '\' ...
                    what_analysis{what_idx} '\' ...
                    fig_name_no_diff], format)
                saveas(fig_no_diff_walsh, ...
                    [figure_path who_analysis{who_idx} ...
                    '\all_experiments\Sample_' ...
                    num2str(numerosities(sample_idx, 1)) '\' ...
                    what_analysis{what_idx} '\' ...
                    fig_name_no_diff_walsh], format)

                % update progress bar
                progress_counter = progress_counter + 1;  % for progressbar
                progressbar(progress_counter, progress_total)
            end
        end

        % Save the stuff
        adapt_path = [data_path who_analysis{who_idx} '\all_experiments\'];
        save([adapt_path 'statistics_chunking_grouping_' stats_name '.mat'], ...
            '-struct', 'statistics')
    end
end

%% Stimuli Analysis
% histogram of test numerosity distribution
% sth abt variability/entropy of stim pattern variation for PR, P1, P2, P3

%% Distribution of Numerosities
% dot specifications
rad_dot_limit = [.05, .14];   % radius limitations (based on control)
area_limit = [.18, .2];   % limits of cumulative area of the dots
density_limit = [.80, .86; .69, 20];
rad_back = 1;
subgroup_rad = .12;
scaling = 1.55;   % factor for stretching lovely picture (to be displayed as circle in lateralization setup)
numbers = 2:10;
% group radii: (4=2+2, 5=3+2, 6=2+2+2, 7=3+3+1, 8=2+2+2+2, 9=3+3+3, 10=2+2+2+2+2)
gr_dots_m = {[1], [2], [3], ...
    [2; 2], [3; 2], [2; 2; 2], [3; 3; 1], [2; 2; 2; 2], [3; 3; 3], [2; 2; 2; 2; 2]};
gr_rad_m = {[subgroup_rad], [subgroup_rad], [subgroup_rad], ...
    [subgroup_rad; subgroup_rad], [subgroup_rad; subgroup_rad], ...
    [subgroup_rad; subgroup_rad; subgroup_rad], ...
    [subgroup_rad; subgroup_rad; subgroup_rad], ... 
    [subgroup_rad; subgroup_rad; subgroup_rad; subgroup_rad], ...
    [subgroup_rad; subgroup_rad; subgroup_rad], ...
    [subgroup_rad; subgroup_rad; subgroup_rad; subgroup_rad; subgroup_rad]};
% group radii: (4=3+1, 5=2+2+1, 6=3+2+1, 7=4+2+1, 8=3+2+2+1, 9=4+3+2, 10=4+4+2)
gr_dots_a = {[1], [2], [2; 1], ...
    [3; 1], [2; 2; 1], [3; 2; 1], [4; 2; 1], [3; 2; 2; 1], [4; 3; 2], [4; 4; 2]};
gr_rad_a = {[subgroup_rad], [subgroup_rad], [subgroup_rad; subgroup_rad], ...
    [subgroup_rad; subgroup_rad], ...
    [subgroup_rad; subgroup_rad; subgroup_rad], ...
    [subgroup_rad; subgroup_rad; subgroup_rad], ...
    [subgroup_rad; subgroup_rad; subgroup_rad], ...
    [subgroup_rad; subgroup_rad; subgroup_rad; subgroup_rad], ...
    [subgroup_rad; subgroup_rad; subgroup_rad], ...
    [subgroup_rad; subgroup_rad; subgroup_rad]};


if to_stim_dist
    
    % Plot Distribution of Numerosities used
    fig_num = ...
        plot_num_dist(numerosities, plot_font, plot_pos, colour, linewidth);

    % save the figure
    saveas(fig_num, [figure_path 'numerosity_distribution.svg'], format)

    % Variability
    

end
