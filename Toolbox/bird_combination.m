function [performances, resp_freq, rec_times] = ...
    bird_combination(data_path, exp_idx)

% Function to Load and Combine Data of Jello & Uri

%% Jello
% path adjustment
% list of all data & subfolders
filelist = dir([data_path 'jello\']);
% extract subfolders
subfolders = filelist([filelist(:).isdir]);
% list of subfolder names (experiments)
subfolders = {subfolders(3 : end).name};
adapt_path = ...
    [data_path 'jello\' subfolders{exp_idx + 1} '\'];

% load the data
sorted_data = load([adapt_path 'sorted_data.mat']);

performances_j = sorted_data.performances;
resp_freq_j = sorted_data.resp_freq;
rec_times_j = sorted_data.rec_times;

%% Uri
% path adjustment
% list of all data & subfolders
filelist = dir([data_path 'uri\']);
% extract subfolders
subfolders = filelist([filelist(:).isdir]);
% list of subfolder names (experiments)
subfolders = {subfolders(3 : end).name};
adapt_path = ...
    [data_path 'uri\' subfolders{exp_idx + 1} '\'];

% load the data
sorted_data = load([adapt_path 'sorted_data.mat']);

performances_u = sorted_data.performances;
resp_freq_u = sorted_data.resp_freq;
rec_times_u = sorted_data.rec_times;

%% Combine Jello and Uri

performances = vertcat(performances_j, performances_u);
resp_freq = vertcat(resp_freq_j, resp_freq_u);
rec_times = vertcat(rec_times_j, rec_times_u);

end