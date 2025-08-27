function corr_resp(spk_folderpath, who_analysis, curr_exp)

% function to correct response matrices & add sixth column for test numerosity & add seventh column for reaction times

% get file names
spk_subject = [spk_folderpath, who_analysis]; % adapt path
filelist_spk = dir(spk_subject);  % list of all data & subfolders
subfolders_spk = filelist_spk([filelist_spk(:).isdir]); % extract subfolders
subfolders_spk = {subfolders_spk(3:end).name};  % list of subfolder names (experiments)

filelist_rsp = dir(fullfile([spk_subject subfolders_spk{curr_exp}], '*.spk'));  % list of all spk files
names_rsp = {filelist_rsp.name};

% iterate over files
for idx = 1:length(names_rsp)
    % load data
    curr_file_rsp = names_rsp{idx}; % current file
    curr_spk = spk_read([spk_subject, subfolders_spk{curr_exp} '\' curr_file_rsp]); % current spike data
    curr_resp = getresponsematrix(curr_spk); % current response matrix
    % correct the response matrix
    corr_resp = respmat_corr(curr_resp, numerosities);

    % get reaction times
    [rel_idx, ~] = find(corr_resp(:, 5) == 0);
    curr_react = getreactiontimes(curr_spk, 25, 41, rel_idx)'; % in s
    curr_react = curr_react * 1000; % in ms
    corr_resp(rel_idx, 7) = curr_react;

    % save the corrected response matrix
    save(fullfile([rsp_mat_folderpath, who_analysis subfolders_spk{curr_exp} '\'], ...
        [curr_file_rsp, '_resp.mat']), 'corr_resp');
end

end