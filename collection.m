clc
close all
clear

% script to run the main script and have displayed everything to better
% present it to Lena

%% Pre Definition
who_analysis = {'humans\'; 'jello\'; 'uri\'; 'birds\'};
what_analysis = {'Performance'; 'Response Frequency'; 'Reaction Times'};
calc_type = {'Mean', 'Median'};
err_type = {'STD', 'SEM', 'CI'};
focus_type = {'Overall', 'Matches', 'Single'};

% all relevant numerosities (Lena's tabular)
numerosities = [3, 4, 5, 6, 7; % sample
    2, 2, 3, 3, 3;  % test 1 numbers
    5, 6, 7, 4, 4;  % test 2 numbers
    6, 7, 8, 9, 10]';  % test 3 numbers
patterns = {'P1', 'P2', 'P3'};

% pre allocation
specs = {"Friedman"; "p-Value"; "Table"; "Stats"; ...
    "Kendall's W"; "Kruskal-Wallis"; "p-Value"; "Table"; ...
    "Stats"; "Epsilon Squared"; "Post-Hoc"; "Wilcoxon Signed Rank"; ...
    "p-Value"; "Method for Correction"; "Rank-Biserial Correlation"; ...
    "Dunn"; "p-Value"; "Method for Correction"; ...
    "Rank-Biserial Correlation"; "Conover-Iman"; "p-Value"; ...
    "Method for Correction"; "Rank-Biserial Correlation"};
rownames = {'Friedman p-Value'; 'Friedman Table'; 'Friedman Stats'; ...
    'Kendalls W'; 'Kruskal-Wallis p-Value'; 'Kruskal-Wallis Table'; ...
    'Kruskal-Wallis Stats'; 'Epsilon Squared'; 'Post Hoc Analysis'; ...
    'Wilcoxon Signed Rank p-Value'; ...
    'Wilcoxon Signed Rank Method for Correction'; ...
    'Wilcoxon Signed Rank Rank-Biserial Correlation'; 'Dunn p-Value'; ...
    'Dunn Method for Correction'; 'Dunn Rank-Biserial Correlation'; ...
    'Conover-Iman p-Value'; 'Conover-Iman Method for Correction'; ...
    'Conover-Iman Rank-Biserial Correlation'};
hum = table(cell(size(rownames, 1), 1), cell(size(rownames, 1), 1), ...
    cell(size(rownames, 1), 1), cell(size(rownames, 1), 1), ...
    cell(size(rownames, 1), 1), cell(size(rownames, 1), 1), ...
    'VariableNames', ...
    {'1 Performance', '1 Reaction Time', ...
    '2 Performance', '2 Reaction Time', ...
    '3 Performance', '3 Reaction Time'});
hum.Properties.RowNames = rownames;
pattern_comparison_big = {"Performance", "Response Frequency", ...
    "Reaction Times"; NaN(1), NaN(1), NaN(1)};
pattern_comparison_detail = {" ", "Performance", "Response Frequency", ...
    "Reaction Times"; "P1 vs. P2", NaN(1), NaN(1), NaN(1); ...
    "P1 vs. P3", NaN(1), NaN(1), NaN(1); ...
    "P2 vs. P3", NaN(1), NaN(1), NaN(1)};

humans = struct();
jello = struct();
uri = struct();
birds = struct();
standard_control = {" ", "Experiment 1 50 ms", ...
    "Experiment 2 50 ms", "Experiment 3 50 ms", " ";
    "Humans", struct(), struct(), struct(), " "; ...
    " ", "Experiment 1 300 ms", "Experiment 1 100 ms", ...
    "Experiment 1 50 ms", "Experiment 2 50 ms"; ...
    "Jello", struct(), struct(), struct(), struct(); ...
    "Uri", struct(), struct(), struct(), struct(); ...
    "Birds", struct(), struct(), struct(), struct()};

%% Standard vs. Control in all
factors_stats = {'S', 'C'};
focus_t = focus_type{2}; 
fig_name_part = '_StandCont_';
    
% Humans
who_a = who_analysis{1};
experiments = ...
    {'Experiment 1, 50 ms'; 'Experiment 2, 50 ms'; 'Experiment 3, 50 ms'};

% Path definition
base_path = 'D:\MasterThesis\analysis\data\';
figure_path = ['D:\MasterThesis\figures\progress_since_250902\' who_a '\'];
spk_folderpath = [base_path, 'spk\'];
rsp_mat_folderpath = [base_path, 'analysed\'];
stats_path = ['D:\MasterThesis\analysis\data\statistics\' who_a '\'];

filelist_spk = dir(figure_path);  % list of all data & subfolders
subfolders = filelist_spk([filelist_spk(:).isdir]); % extract subfolders
subfolders = {subfolders(3:end).name};  % list of subfolder names (experiments)

for curr_exp = 1:3
    % get data
    [performances_1, performances_2, ...
        resp_freq_1, resp_freq_2, rec_times_1, rec_times_2] = ...
        stand_cont(rsp_mat_folderpath, who_a, ...
        curr_exp, numerosities, patterns);
    % do statistics
    statistics = anova_sc(performances_1, performances_2, ...
        resp_freq_1, resp_freq_2, rec_times_1, rec_times_2, patterns, ...
        numerosities, stats_path, subfolders{curr_exp}, ...
        factors_stats, ['statistics_' fig_name_part(1:end - 1)]);
    % save data
    standard_control{2, curr_exp + 1}.statistics = statistics;
end

% Jello
who_a = who_analysis{2};
experiments = ...
    {'Experiment 1, 100 ms'; 'Experiment 1, 300 ms'; ...
    'Experiment 1, 50 ms'; 'Experiment 2, 50 ms'};

% Path definition
base_path = 'D:\MasterThesis\analysis\data\';
figure_path = ['D:\MasterThesis\figures\progress_since_250902\' who_a '\'];
spk_folderpath = [base_path, 'spk\'];
rsp_mat_folderpath = [base_path, 'analysed\'];
stats_path = ['D:\MasterThesis\analysis\data\statistics\' who_a '\'];

filelist_spk = dir(figure_path);  % list of all data & subfolders
subfolders = filelist_spk([filelist_spk(:).isdir]); % extract subfolders
subfolders = {subfolders(3:end).name};  % list of subfolder names (experiments)

for curr_exp = 1:4
    % get data
    [performances_1, performances_2, ...
        resp_freq_1, resp_freq_2, rec_times_1, rec_times_2] = ...
        stand_cont(rsp_mat_folderpath, who_a, ...
        curr_exp, numerosities, patterns);
    % do statistics
    statistics = anova_sc(performances_1, performances_2, ...
        resp_freq_1, resp_freq_2, rec_times_1, rec_times_2, patterns, ...
        numerosities, stats_path, subfolders{curr_exp}, ...
        factors_stats, ['statistics_' fig_name_part(1:end - 1)]);
    % save data
    standard_control{4, curr_exp + 1}.statistics = statistics;
end

% Uri
who_a = who_analysis{3};
experiments = ...
    {'Experiment 1, 100 ms'; 'Experiment 1, 300 ms'; ...
    'Experiment 1, 50 ms'; 'Experiment 2, 50 ms'};

% Path definition
base_path = 'D:\MasterThesis\analysis\data\';
figure_path = ['D:\MasterThesis\figures\progress_since_250902\' who_a '\'];
spk_folderpath = [base_path, 'spk\'];
rsp_mat_folderpath = [base_path, 'analysed\'];
stats_path = ['D:\MasterThesis\analysis\data\statistics\' who_a '\'];

filelist_spk = dir(figure_path);  % list of all data & subfolders
subfolders = filelist_spk([filelist_spk(:).isdir]); % extract subfolders
subfolders = {subfolders(3:end).name};  % list of subfolder names (experiments)

for curr_exp = 1:4
    % get data
    [performances_1, performances_2, ...
        resp_freq_1, resp_freq_2, rec_times_1, rec_times_2] = ...
        stand_cont(rsp_mat_folderpath, who_a, ...
        curr_exp, numerosities, patterns);
    % do statistics
    statistics = anova_sc(performances_1, performances_2, ...
        resp_freq_1, resp_freq_2, rec_times_1, rec_times_2, patterns, ...
        numerosities, stats_path, subfolders{curr_exp}, ...
        factors_stats, ['statistics_' fig_name_part(1:end - 1)]);
    % save data
    standard_control{5, curr_exp + 1}.statistics = statistics;
end

% Birds
who_a = who_analysis{4};
experiments = ...
    {'Experiment 1, 100 ms'; 'Experiment 1, 300 ms'; ...
    'Experiment 1, 50 ms'; 'Experiment 2, 50 ms'};
factors_stats = {'J', 'U'};
fig_name_part = '_JelloUri_';

% Path definition
base_path = 'D:\MasterThesis\analysis\data\';
figure_path = ['D:\MasterThesis\figures\progress_since_250902\' who_a '\'];
spk_folderpath = [base_path, 'spk\'];
rsp_mat_folderpath = [base_path, 'analysed\'];
stats_path = ['D:\MasterThesis\analysis\data\statistics\' who_a '\'];

filelist_spk = dir(figure_path);  % list of all data & subfolders
subfolders = filelist_spk([filelist_spk(:).isdir]); % extract subfolders
subfolders = {subfolders(3:end).name};  % list of subfolder names (experiments)

for curr_exp = 1:4
    % get data for Jello
    [performances_1, resp_freq_1, rec_times_1] = ...
        sort_behav(rsp_mat_folderpath, 'jello\', ...
        curr_exp, numerosities, patterns);

    % get data for Uri
    [performances_2, resp_freq_2, rec_times_2] = ...
        sort_behav(rsp_mat_folderpath, 'uri\', ...
        curr_exp, numerosities, patterns);
    
    % do statistics
    statistics = anova_sc(performances_1, performances_2, ...
        resp_freq_1, resp_freq_2, rec_times_1, rec_times_2, patterns, ...
        numerosities, stats_path, subfolders{curr_exp}, ...
        factors_stats, ['statistics_' fig_name_part(1:end - 1)]);
    % save data
    standard_control{6, curr_exp + 1}.statistics = statistics;
end

%% Sort the stuff
exp1_humans = standard_control{2, 2};
exp2_humans = standard_control{2, 3};
exp3_humans = standard_control{2, 4};
exp1_300_jello = standard_control{4, 2};
exp1_100_jello = standard_control{4, 3};
exp1_50_jello = standard_control{4, 4};
exp2_50_jello = standard_control{4, 5};
exp1_300_uri = standard_control{5, 2};
exp1_100_uri = standard_control{5, 3};
exp1_50_uri = standard_control{5, 4};
exp2_50_uri = standard_control{5, 5};
exp1_300_birds = standard_control{6, 2};
exp1_100_birds = standard_control{6, 3};
exp1_50_birds = standard_control{6, 4};
exp2_50_birds = standard_control{6, 5};

%% Pattern Comparison
    
% Humans
who_a = who_analysis{1};
experiments = ...
    {'Experiment 1, 50 ms'; 'Experiment 2, 50 ms'; 'Experiment 3, 50 ms'};
focus_t = focus_type{2};    % Matches

% Path definition
base_path = 'D:\MasterThesis\analysis\data\';
figure_path = ['D:\MasterThesis\figures\progress_since_250902\' who_a '\'];
spk_folderpath = [base_path, 'spk\'];
rsp_mat_folderpath = [base_path, 'analysed\'];
stats_path = ['D:\MasterThesis\analysis\data\statistics\' who_a '\'];

filelist_spk = dir(figure_path);  % list of all data & subfolders
subfolders = filelist_spk([filelist_spk(:).isdir]); % extract subfolders
subfolders = {subfolders(3:end).name};  % list of subfolder names (experiments)

what_a = what_analysis{1};  % Performance

% get data
[performances, resp_freq, rec_times] = ...
    sort_behav(rsp_mat_folderpath, who_a, ...
    1, numerosities, patterns);

% statistics: Performance
signifcant = false;
[big_statistics_fried, post_hoc] = ...
    pattern_statistics(performances, resp_freq, rec_times, ...
    what_a, numerosities, patterns, "Friedman", "Conover-Iman");
hum("Friedman p-Value", "1 Performance") = big_statistics_fried{2, 2};
hum("Friedman Table", "1 Performance") = big_statistics_fried{2, 3};
hum("Friedman Stats", "1 Performance") = big_statistics_fried{2, 4};
hum("Kendalls W", "1 Performance") = big_statistics_fried{2, 6};
[big_statistics_kruskal, post_hoc] = ...
    pattern_statistics(performances, resp_freq, rec_times, ...
    what_a, numerosities, patterns, "Kruskal-Wallis", "Conover-Iman");
hum("Kruskal-Wallis p-Value", "1 Performance") = big_statistics_kruskal{2, 2};
hum("Kruskal-Wallis Table", "1 Performance") = big_statistics_kruskal{2, 3};
hum("Kruskal-Wallis Stats", "1 Performance") = big_statistics_kruskal{2, 4};
hum("Epsilon Squared", "1 Performance") = big_statistics_kruskal{2, 6};
if big_statistics_fried{2, 2} <= 0.05 || big_statistics_kruskal <= 0.05
    signifcant = true;
end


% save data



% Jello
who_a = who_analysis{2};
experiments = ...
    {'Experiment 1, 100 ms'; 'Experiment 1, 300 ms'; ...
    'Experiment 1, 50 ms'; 'Experiment 2, 50 ms'};

% Path definition
base_path = 'D:\MasterThesis\analysis\data\';
figure_path = ['D:\MasterThesis\figures\progress_since_250902\' who_a '\'];
spk_folderpath = [base_path, 'spk\'];
rsp_mat_folderpath = [base_path, 'analysed\'];
stats_path = ['D:\MasterThesis\analysis\data\statistics\' who_a '\'];

filelist_spk = dir(figure_path);  % list of all data & subfolders
subfolders = filelist_spk([filelist_spk(:).isdir]); % extract subfolders
subfolders = {subfolders(3:end).name};  % list of subfolder names (experiments)

for curr_exp = 1:4
    % get data
    [performances_1, performances_2, ...
        resp_freq_1, resp_freq_2, rec_times_1, rec_times_2] = ...
        stand_cont(rsp_mat_folderpath, who_a, ...
        curr_exp, numerosities, patterns);
    % do statistics
    statistics = anova_sc(performances_1, performances_2, ...
        resp_freq_1, resp_freq_2, rec_times_1, rec_times_2, patterns, ...
        numerosities, stats_path, subfolders{curr_exp}, ...
        factors_stats, ['statistics_' fig_name_part(1:end - 1)]);
    % save data
    standard_control{4, curr_exp + 1}.statistics = statistics;
end

% Uri
who_a = who_analysis{3};
experiments = ...
    {'Experiment 1, 100 ms'; 'Experiment 1, 300 ms'; ...
    'Experiment 1, 50 ms'; 'Experiment 2, 50 ms'};

% Path definition
base_path = 'D:\MasterThesis\analysis\data\';
figure_path = ['D:\MasterThesis\figures\progress_since_250902\' who_a '\'];
spk_folderpath = [base_path, 'spk\'];
rsp_mat_folderpath = [base_path, 'analysed\'];
stats_path = ['D:\MasterThesis\analysis\data\statistics\' who_a '\'];

filelist_spk = dir(figure_path);  % list of all data & subfolders
subfolders = filelist_spk([filelist_spk(:).isdir]); % extract subfolders
subfolders = {subfolders(3:end).name};  % list of subfolder names (experiments)

for curr_exp = 1:4
    % get data
    [performances_1, performances_2, ...
        resp_freq_1, resp_freq_2, rec_times_1, rec_times_2] = ...
        stand_cont(rsp_mat_folderpath, who_a, ...
        curr_exp, numerosities, patterns);
    % do statistics
    statistics = anova_sc(performances_1, performances_2, ...
        resp_freq_1, resp_freq_2, rec_times_1, rec_times_2, patterns, ...
        numerosities, stats_path, subfolders{curr_exp}, ...
        factors_stats, ['statistics_' fig_name_part(1:end - 1)]);
    % save data
    standard_control{5, curr_exp + 1}.statistics = statistics;
end

% Birds
who_a = who_analysis{4};
experiments = ...
    {'Experiment 1, 100 ms'; 'Experiment 1, 300 ms'; ...
    'Experiment 1, 50 ms'; 'Experiment 2, 50 ms'};
factors_stats = {'J', 'U'};
fig_name_part = '_JelloUri_';

% Path definition
base_path = 'D:\MasterThesis\analysis\data\';
figure_path = ['D:\MasterThesis\figures\progress_since_250902\' who_a '\'];
spk_folderpath = [base_path, 'spk\'];
rsp_mat_folderpath = [base_path, 'analysed\'];
stats_path = ['D:\MasterThesis\analysis\data\statistics\' who_a '\'];

filelist_spk = dir(figure_path);  % list of all data & subfolders
subfolders = filelist_spk([filelist_spk(:).isdir]); % extract subfolders
subfolders = {subfolders(3:end).name};  % list of subfolder names (experiments)

for curr_exp = 1:4
    % get data for Jello
    [performances_1, resp_freq_1, rec_times_1] = ...
        sort_behav(rsp_mat_folderpath, 'jello\', ...
        curr_exp, numerosities, patterns);

    % get data for Uri
    [performances_2, resp_freq_2, rec_times_2] = ...
        sort_behav(rsp_mat_folderpath, 'uri\', ...
        curr_exp, numerosities, patterns);
    
    % do statistics
    statistics = anova_sc(performances_1, performances_2, ...
        resp_freq_1, resp_freq_2, rec_times_1, rec_times_2, patterns, ...
        numerosities, stats_path, subfolders{curr_exp}, ...
        factors_stats, ['statistics_' fig_name_part(1:end - 1)]);
    % save data
    standard_control{6, curr_exp + 1}.statistics = statistics;
end