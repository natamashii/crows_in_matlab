clc
clear
close all

% Script for sorting behavioural data

% TODO
% divide standard/control stuff, save it separately (incl statistic shit
% from that)
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
% make fig size variable
% maybe time for birds
% imporve single plot
% regression analysis: add computing in function + plot regression curve
% separetly in a function


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

% Pre Definition

who_analysis = {'humans\'; 'jello\'; 'uri\'};
what_analysis = {'Performance'; 'Response Frequency'; 'Reaction Times'};
calc_type = {'Mean', 'Median'};
err_type = {'STD', 'SEM', 'CI'};
focus_type = {'Overall', 'Matches', 'Single'};

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

% prompt to ask for which combination to plot
prompt = ['What exactly do you wanna look at? ' ...
    ' \n 1 - Overall (Match + Non-Match) ' ...
    ' \n 2 - Matches ' ...
    ' \n 3 - Behavioural Curves '];
focus_type = focus_type{input(prompt)};

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
s_c = true;

% for Plotting
colours_pattern = ...
    {[0.8008 0.2578 0.7266]; [0.1445 0.4336 0.2070]; [0.1211 0.5195 0.6289]};
colours_numbers = {[0 0.4460 0.7410]; [0.8500 0.3250 0.0980]; ...
    [0.9290 0.6940 0.1250]; [0.3010 0.7450 0.9330]; [0.6350 0.0780 0.1840]};
colours_S_C = {[0.0660 0.4430 0.7450]; [0.5210 0.0860 0.8190]};
format = 'svg';
fig_title = '';

plot_font = 12;
plot_pos = [21 29.7];   % default PaperPosition size of figure
mrksz = 10;
linewidth = 2;
plot_font = 14;
in_detail = false;
capsize = 10;
jitterwidth = 0.25;
linestyle = "none";

n_boot = 10000;
confidence_level = 95;      % For a 95% CI
alpha = 100 - confidence_level;

% Correct Response Matrix
if to_correct
    corr_resp(rsp_mat_folderpath, spk_folderpath, who_analysis, ...
        curr_exp, numerosities);
end

% Sum Average Performance for each Pattern
if s_c
    [performances_s, performances_c, ...
        resp_freq_s, resp_freq_c, rec_times_s, rec_times_c] = ...
        stand_cont(rsp_mat_folderpath, who_analysis, ...
        curr_exp, numerosities, patterns);
else
    [performances, resp_freq, rec_times] = ...
        sort_behav(rsp_mat_folderpath, who_analysis, ...
        curr_exp, numerosities, patterns);
end

% Get data depending on what to analyse
switch what_analysis
    case 'Performance'
        if s_c
            [avg_data_s, err_data_s] = ...
                calc_behav(performances_s, what_analysis, ...
                calc_type, err_type, patterns, ...
                numerosities, n_boot, alpha, focus_type);
            [avg_data_c, err_data_c] = ...
                calc_behav(performances_c, what_analysis, ...
                calc_type, err_type, patterns, ...
                numerosities, n_boot, alpha, focus_type);
            ind_data_s = performances_s;
            ind_data_c = performances_c;
        else
            [avg_data, err_data] = ...
                calc_behav(performances, what_analysis, ...
                calc_type, err_type, patterns, ...
                numerosities, n_boot, alpha, focus_type);
            ind_data = performances;
        end
    case 'Response Frequency'
        if s_c
            [avg_data_s, err_data_s] = ...
                calc_behav(resp_freq_s, what_analysis, ...
                calc_type, err_type, patterns, ...
                numerosities, n_boot, alpha, focus_type);
            [avg_data_c, err_data_c] = ...
                calc_behav(resp_freq_c, what_analysis, ...
                calc_type, err_type, patterns, ...
                numerosities, n_boot, alpha, focus_type);
            ind_data_s = resp_freq_s;
            ind_data_c = resp_freq_c;
        else
            [avg_data, err_data] = ...
                calc_behav(resp_freq, what_analysis, ...
                calc_type, err_type, patterns, ...
                numerosities, n_boot, alpha, focus_type);
            ind_data = resp_freq;
        end
    case 'Reaction Times'
        if s_c
            [avg_data_s, err_data_s] = ...
                calc_behav(rec_times_s, what_analysis, ...
                calc_type, err_type, patterns, ...
                numerosities, n_boot, alpha, focus_type);
            [avg_data_c, err_data_c] = ...
                calc_behav(rec_times_c, what_analysis, ...
                calc_type, err_type, patterns, ...
                numerosities, n_boot, alpha, focus_type);
            ind_data_s = rec_times_s;
            ind_data_c = rec_times_c;
        else
            [avg_data, err_data] = ...
                calc_behav(rec_times, what_analysis, ...
                calc_type, err_type, patterns, ...
                numerosities, n_boot, alpha, focus_type);
            ind_data = rec_times;
        end
end
    
% Plot specificites depending on what to analyse
if strcmp(focus_type, 'Single')
    linestyle = "--";
    plot_pos = [50 29.7];
end

% Plot
if s_c
    plot_pos = [29.7 50];
    fig = plot_s_c(numerosities, ind_data_s, ind_data_c, ...
        avg_data_s, avg_data_c, err_data_s, err_data_c, what_analysis, ...
        who_analysis(1:end-1), calc_type, experiments{curr_exp}, ...
        patterns, err_type, jitterwidth, ...
        colours_S_C, mrksz, plot_font, plot_pos, ...
        linewidth, capsize, linestyle);
    fig_name = [focus_type '_StandCont_' calc_type '_' err_type '_' ...
        what_analysis '.' format];
else
    fig = plot_stuff(ind_data, avg_data, err_data, numerosities, ...
        patterns, calc_type, err_type, what_analysis, ...
        who_analysis(1:end-1), ...
        experiments{curr_exp}, plot_font, colours_pattern, plot_pos, ...
        linewidth, linestyle, mrksz, capsize, jitterwidth, focus_type);
    fig_name = [focus_type '_' calc_type '_' err_type '_' ...
        what_analysis '.' format];
end



% save figure
if to_save
    adapt_path = [figure_path '\' subfolders{curr_exp} '\'];
    saveas(fig, [adapt_path, fig_name], format)
end

