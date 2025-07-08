function corr_resp = respmat_corr(resp_mat, numerosities)

% function to correct the response matrix values

% col 1: stimulus type (standard (1) or control (2))
% col 2: pattern type (P1, P2, P3, P4)
% col 3: sample (3-7)
% col 4: match or non-match (0 = match, 1 = test 1, 2 = test 2, 3 = test 3,
% referring to Lena's table with test 1-3)
% col 5: bird response evaluation (0 = correct, 1 = error by bird, 9 =
% abundance by bird)
% col 6: test numerosity (2-10)

% Note: 9 in all columns for one row = abundance by bird

% add sixth column
resp_mat(:, 6) = 0;

% iterating over trials
for trial_idx = 1:size(resp_mat, 1)
    % only continue if trial was not abunded
    if resp_mat(trial_idx, 1) == 9
        continue
    end
    % correction: 8 should be 3 (error by CORTEX or timing file?)
    if resp_mat(trial_idx, 3) == 8
        resp_mat(trial_idx, 3) = 3; 
    end

    % write sicth column
    % for match trials
    if resp_mat(trial_idx, 4) == 0
        resp_mat(trial_idx, 6) = resp_mat(trial_idx, 3); 

    % for nonmatch trials
    else 
        % get sample number in current trial
        sample = resp_mat(trial_idx, 3);
        sample_row = find(numerosities(:, 1) == sample);
        % get corresponding test number
        test_cl = resp_mat(trial_idx, 4);


    end
    end
end


end