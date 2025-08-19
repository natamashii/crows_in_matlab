function penis = avg_error()

% function to compute average/median, their errors & such stuff

% Get Data
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

end