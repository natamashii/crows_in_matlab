function [statistics] = ...
    stats_pattern_diff(all_performances, all_resp_freq, all_rec_times, ...
    curr_experiments, patterns, numerosities, alpha_stats)

% Function to Compute Statistics of Pattern Differences

%% Pre Allocation

statistics = struct();
statistics.Wilcoxon_Performance = ...
    cell(length(curr_experiments), size(numerosities, 1));
statistics.Wilcoxon_ResponseFrequency = ...
    cell(length(curr_experiments), size(numerosities, 1));
statistics.Wilcoxon_ReactionTimes = ...
    cell(length(curr_experiments), size(numerosities, 1));
statistics.Significance = ...
    zeros(3, length(curr_experiments), size(numerosities, 1));

% Get Difference Data for All Behavioural Data
diff_data_performance = ...
    pattern_diffs(all_performances, all_resp_freq, all_rec_times, ...
    patterns, numerosities, 'Performance', curr_experiments, ...
    'Overall', 'Mean', 'SEM');
diff_data_resp_freq = ...
    pattern_diffs(all_performances, all_resp_freq, all_rec_times, ...
    patterns, numerosities, 'Response Frequency', curr_experiments, ...
    'Overall', 'Mean', 'SEM');
diff_data_rec_times = ...
    pattern_diffs(all_performances, all_resp_freq, all_rec_times, ...
    patterns, numerosities, 'Reaction Times', curr_experiments, ...
    'Matches', 'Median', 'STD');

% Iterate over Experiments
for exp_idx = 1:length(curr_experiments)

    % Iterate Over Samples
    for sample_idx = 1:size(numerosities, 1)
        placeholder_performance = {" ", "P2 - P1", "P3 - P1", "P3 - P2"; ...
            "p-Value", [], [], []; "Effect Size", [], [], []};
        placeholder_resp_freq = {" ", "P2 - P1", "P3 - P1", "P3 - P2"; ...
            "p-Value", [], [], []; "Effect Size", [], [], []};
        placeholder_rec_times = {" ", "P2 - P1", "P3 - P1", "P3 - P2"; ...
            "p-Value", [], [], []; "Effect Size", [], [], []};

        % Iterate over Pattern Combinations
        for pattern = 1:length(patterns)
            %% Performance
            curr_data = diff_data_performance{exp_idx, sample_idx};
            % Wilcoxon Signed-Rank
            [placeholder_performance{2, pattern + 1}, ~, stats] = ...
                signrank(curr_data{2, pattern});

            % Effect Size: Rank Biserial Correlation r
            mu_W = (size(curr_data{2, pattern}, 1) * ...
                (size(curr_data{2, pattern}, 1) + 1)) / 4;
            sigma_W = sqrt((size(curr_data{2, pattern}, 1) * ...
                (size(curr_data{2, pattern}, 1) + 1) *...
                ((2 * size(curr_data{2, pattern}, 1)) + 1)) / 24);
            zval = (stats.signedrank - mu_W) / sigma_W;
            placeholder_performance{3, pattern + 1} = zval / ...
                sqrt(size(curr_data{2, pattern}, 1));

            %% Response Frequency
            curr_data = diff_data_resp_freq{exp_idx, sample_idx};
            % Wilcoxon Signed-Rank
            [placeholder_resp_freq{2, pattern + 1}, ~, stats] = ...
                signrank(curr_data{2, pattern});

            % Effect Size: Rank Biserial Correlation r
            mu_W = (size(curr_data{2, pattern}, 1) * ...
                (size(curr_data{2, pattern}, 1) + 1)) / 4;
            sigma_W = sqrt((size(curr_data{2, pattern}, 1) * ...
                (size(curr_data{2, pattern}, 1) + 1) *...
                ((2 * size(curr_data{2, pattern}, 1)) + 1)) / 24);
            zval = (stats.signedrank - mu_W) / sigma_W;
            placeholder_resp_freq{3, pattern + 1} = zval / ...
                sqrt(size(curr_data{2, pattern}, 1));

            %% Reaction Times
            curr_data = diff_data_rec_times{exp_idx, sample_idx};
            % Wilcoxon Signed-Rank
            [placeholder_rec_times{2, pattern + 1}, ~, stats] = ...
                signrank(curr_data{2, pattern});

            % Effect Size: Rank Biserial Correlation r
            mu_W = (size(curr_data{2, pattern}, 1) * ...
                (size(curr_data{2, pattern}, 1) + 1)) / 4;
            sigma_W = sqrt((size(curr_data{2, pattern}, 1) * ...
                (size(curr_data{2, pattern}, 1) + 1) *...
                ((2 * size(curr_data{2, pattern}, 1)) + 1)) / 24);
            zval = (stats.signedrank - mu_W) / sigma_W;
            placeholder_rec_times{3, pattern + 1} = zval / ...
                sqrt(size(curr_data{2, pattern}, 1));
        end

        %% Mark Significant Values
        % Performance
        if le([placeholder_performance{2, 2:end}], alpha_stats)
            statistics.Significance(1, exp_idx, sample_idx) = 1;
        end

        % Response Frequency
        if le([placeholder_resp_freq{2, 2:end}], alpha_stats)
            statistics.Significance(2, exp_idx, sample_idx) = 1;
        end

        % Reaction Times
        if le([placeholder_rec_times{2, 2:end}], alpha_stats)
            statistics.Significance(3, exp_idx, sample_idx) = 1;
        end

        %% sort the values
        statistics.Wilcoxon_Performance{exp_idx, sample_idx} = placeholder_performance;
        statistics.Wilcoxon_ResponseFrequency{exp_idx, sample_idx} = placeholder_resp_freq;
        statistics.Wilcoxon_ReactionTimes{exp_idx, sample_idx} = placeholder_rec_times;
    end
end

end