function [data_table] = ...
    datatable(performances, resp_freq, rec_times, patterns, numerosities)

% function to rewrite data as table (useful for statistics)

% pre allocation
data_table = table();

% iterate over patterns
for pattern = 1:length(patterns)

    % iterate over samples
    for sample_idx = 1:size(numerosities, 1)

        % write data as table
        subjects_col = (1:size(performances, 1))';
        pattern_col = repmat(patterns{pattern}, size(subjects_col, 1), 1);
        sample_col = ...
            repmat(numerosities(sample_idx, 1), size(subjects_col, 1), 1);
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

end