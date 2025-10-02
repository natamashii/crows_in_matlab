function [data_table] = ...
    datatable(performances, resp_freq, rec_times, ...
    patterns, numerosities, factors)

% function to rewrite data as table (useful for statistics)

% pre allocation
data_table = table();

%% write data as table
% iterate over patterns
for pattern = 1:length(patterns)
    % pre allocation
    subjects = (1:size(performances{1}, 1))';    % session/subject col

    % iterate over samples
    for sample_idx = 1:size(numerosities, 1)

        % iterate over conditions
        for cond_idx = 1:length(factors)
            % sample col
            numerosity_col = repmat(numerosities(sample_idx, 1), ...
                size(subjects, 1), 1);
            % Condition col
            condition_col = repmat(factors{cond_idx}, ...
                size(subjects, 1), 1);
            % Pattern Col
            pattern_col = repmat(patterns{pattern}, ...
                size(subjects, 1), 1);

            % Data cols
            curr_performance = performances{cond_idx};
            curr_resp_freq = resp_freq{cond_idx};
            curr_rec_times = rec_times{cond_idx};

            performance_col = ...
                mean(curr_performance(:, pattern, sample_idx, :), ...
                4, "omitnan");
            resp_freq_col = ...
                mean(curr_resp_freq(:, pattern, sample_idx, :), ...
                4, "omitnan");
            % Reaction Time: Take Median for Each Subject/Session
            rec_times_col = zeros(size(curr_rec_times, 1), 1);
            % iterate over subjects/sessions
            for sub_idx = 1:size(curr_rec_times, 1)
                rec_times_col(sub_idx) = ...
                    median(vertcat(curr_rec_times{sub_idx, pattern, ...
                    sample_idx, 1}), "all", "omitnan");
            end

            % store as table
            temp_table = ...
                table(subjects, ...
                pattern_col, numerosity_col, condition_col, ...
                performance_col, resp_freq_col, rec_times_col, ...
                'VariableNames', ...
                {'Subject', 'Pattern', 'Sample', 'Condition', ...
                'Performance', 'ResponseFrequency', 'RT'});
            data_table = [data_table; temp_table];  % append vertically
        end
    end
end

end