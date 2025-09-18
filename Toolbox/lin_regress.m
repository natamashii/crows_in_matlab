function [lin_reg] = ...
    lin_regress(performances, resp_freq, rec_times, ...
    patterns, numerosities, data_type)

% function to compute linear regression of all data that should be compared
% to each other

% NOTES
% include p value shit + effect size (R^2 ???)
% if to_split, then ind_data must be a 1x2 cell with ind data of cases
% sth abt fixed effect, beta & random effect, eta
% this works for matches only

% pre allocation
data_table = table();
lin_reg = {"polyfit", "R", "df", "normr", "rsquared", ...
    "mu", "y", "delta"};

% iterate over patterns
for pattern = 1:length(patterns)

    % iterate over samples
    for sample_idx = 1:size(numerosities, 1)

        % write data as table
        subjects_col = (1:size(performances, 1))';
        pattern_col = repmat(patterns{pattern}, size(subjects_col, 1), 1);
        sample_col = repmat(numerosities(sample_idx, 1), size(subjects_col, 1), 1);
        performance_col = performances(:, pattern, sample_idx, 1);
        resp_freq_col = resp_freq(:, pattern, sample_idx, 1);

        % Reaction Time: take median for each subject/session
        rec_times_col = zeros(size(subjects_col, 1), 1);
        % iterate over subejcts/sessions
        for sub_idx = 1:size(subjects_col, 1)
            rec_times_col(sub_idx) = ...
                median(vertcat(rec_times{sub_idx, pattern, ...
                sample_idx, 1}), "omitnan");
        end

        % store as table
        temp_table = ...
            table(subjects_col, sample_col, pattern_col, ...
            performance_col, resp_freq_col, rec_times_col, ...
            'VariableNames', ...
            {'Subject', 'Sample', 'Pattern', ...
            'Performance', 'ResponseFrequency', 'RT'});

        data_table = [data_table; temp_table];  % append vertically

    end
end


% iterate over patterns
for pattern = 1:length(patterns)

    % filter data
    filtered_data = ...
        data_table(string(data_table.Pattern) == patterns{pattern}, :);

    % linear regression
    switch data_type
        case "Performance"
            [p, S, mu] = ...
                polyfit(filtered_data.Sample, ...
                filtered_data.Performance, 1);
        case "Response Frequency"
            [p, S, mu] = ...
                polyfit(filtered_data.Sample, ...
                filtered_data.ResponseFrequency, 1);
        case "Reaction Times"
            [p, S, mu] = ...
                polyfit(filtered_data.Sample, ...
                filtered_data.RT, 1);
        otherwise
            fprintf("Error: Mistyped Data Type :( ")
    end
    [y, delta] = ...
        polyval(p, filtered_data.Sample, S);

    % sort data
    lin_reg{pattern + 1, 1} = p;
    lin_reg{pattern + 1, 2} = S.R;
    lin_reg{pattern + 1, 3} = S.df;
    lin_reg{pattern + 1, 4} = S.normr;
    lin_reg{pattern + 1, 5} = S.rsquared;
    lin_reg{pattern + 1, 6} = mu;
    lin_reg{pattern + 1, 7} = y;
    lin_reg{pattern + 1, 8} = delta;
end

end