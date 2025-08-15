function corr_resp = respmat_corr(resp_mat, numerosities)

% Notes: might be efficienter if I rewrite this solely with logical
% indexing...

% function to correct the response matrix values

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

% add sixth & seventh column
resp_mat(:, 6) = 0;
resp_mat(:, 7) = NaN;

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

    % write sixth column
    % for match trials
    if resp_mat(trial_idx, 4) == 0
        resp_mat(trial_idx, 6) = resp_mat(trial_idx, 3); 

    % for nonmatch trials
    else 
        % for exp 2: case P4
        if resp_mat(trial_idx, 2) == 4
            if resp_mat(trial_idx, 3) == 4
                resp_mat(trial_idx, 6) = 6;
            elseif resp_mat(trial_idx, 3) == 6
                resp_mat(trial_idx, 6) = 4;
            end
        % for all other cases
        else
            % get sample number in current trial
            sample = resp_mat(trial_idx, 3);
            % identify test number for current trial in numerosities matrix
            test_nr = numerosities(numerosities(:, 1) == sample, ...
                resp_mat(trial_idx, 4) + 1);
            resp_mat(trial_idx, 6) = test_nr;
        end
    end
end

corr_resp = resp_mat;
end