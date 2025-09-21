function [big_statistics, post_hoc] = ...
    pattern_statistics(performances, resp_freq, rec_times, ...
    data_type, numerosities, patterns, big_test, post_hoc_test)

% function for statistics of pattern comparison

% pre allocation
filtered_table = cell(3, 2);
big_statistics = {"Test Type", "p-Value", "Table", "Stats", ...
    "Effect Size Type", "Effect Size"};
post_hoc = {"Method for Correction", "Post-Hoc Test", "p-Value", ...
    "Effect Size Type", "Effect Size", "Misc"};
post_hoc{2, 3} = {"P1 vs. P2", NaN(1); ...
    "P2 vs. P3", NaN(1); ...
    "P1 vs. P3", NaN(1)};
post_hoc{2, 5} = {"P1 vs. P2", NaN(1); ...
    "P2 vs. P3", NaN(1); ...
    "P1 vs. P3", NaN(1)};

%% Arrange the data
% Write data as table
data_table = ...
    datatable(performances, resp_freq, rec_times, patterns, numerosities);

% iterate over patterns
for pattern = 1:length(patterns)
    % filter table to current pattern
    filtered_table{pattern, 1} = ...
        data_table(string(data_table.Pattern) == patterns{pattern}, :);

    switch data_type
        case "Performance"
            filtered_table{pattern, 2} = ...
                filtered_table{pattern, 1}.Performance;
        case "Response Frequency"
            filtered_table{pattern, 2} = ...
                filtered_table{pattern, 1}.ResponseFrequency;
        case "Reaction Times"
            filtered_table{pattern, 2} = ...
                filtered_table{pattern, 1}.RT;
    end
end

%% Statistical Test

switch big_test
    case "Kruskal-Wallis"
        % do the test
        [p_big, tbl_big, stats_big] = ...
            kruskalwallis([filtered_table{1, 2}, ...
            filtered_table{2, 2}, filtered_table{3, 2}], ...
            ["P1", "P2", "P3"], "off");
        big_statistics{2, 1} = "Kruskal-Wallis";

        % get corresponding effect size: Epsilon Squared
        H = tbl_big{2, 5};  % H-statistics/Chi squared
        eps2 = H / (size(filtered_table{1, 2}, 1) - 1);

        big_statistics{2, 5} = "Epsilon Squared";
        big_statistics{2, 6} = eps2;

    case "Friedman"
        % do the test
        [p_big, tbl_big, stats_big] = ...
            friedman([filtered_table{1, 2}, ...
            filtered_table{2, 2}, filtered_table{3, 2}], 1, "off");
        big_statistics{2, 1} = "Friedman";

        % get corresponding effect size: Kendall's W
        chi2 = tbl_big{2, 5};  % H-statistics/Chi squared
        W = chi2 / ...
            (size(filtered_table{1, 2}, 1) * (length(patterns) - 1));

        big_statistics{2, 5} = "Kendall's W";
        big_statistics{2, 6} = W;

    otherwise
        fprintf("You probably didn't write the test of choice correctly.")
end

% save it in cell
big_statistics{2, 2} = p_big;
big_statistics{2, 3} = tbl_big;
big_statistics{2, 4} = stats_big;

% Post-Hoc analysis if significant
if p_big < 0.05
    switch post_hoc_test
        case "Wilcoxon Signed Rank"
            % Do the test & compute effect size: Rank-biserial correlation
            post_hoc{2, 2} = post_hoc_test;
            post_hoc{2, 4} = "Rank-Biserial Correlation r";
            % P1 vs. P2
            [p_post_hoc_P1P2, ~, stats_post_hoc_P1P2] = ...
                signrank(filtered_table{1, 2}, filtered_table{2, 2});
            r_post_hoc_P1P2 = stats_post_hoc_P1P2.zval / ...
                sqrt(size(filtered_table{1, 2}, 1));
            % P2 vs. P3
            [p_post_hoc_P2P3, ~, stats_post_hoc_P2P3] = ...
                signrank(filtered_table{2, 2}, filtered_table{3, 2});
            r_post_hoc_P2P3 = stats_post_hoc_P2P3.zval / ...
                sqrt(size(filtered_table{1, 2}, 1));
            % P1 vs. P3
            [p_post_hoc_P1P3, ~, stats_post_hoc_P1P3] = ...
                signrank(filtered_table{1, 2}, filtered_table{3, 2});
            r_post_hoc_P1P3 = stats_post_hoc_P1P3.zval / ...
                sqrt(size(filtered_table{1, 2}, 1));

            % Holm-Bonferroni Correction of p-values
            [p_post_hoc_corr, ~] = ...
                bonf_holm([p_post_hoc_P1P2, p_post_hoc_P2P3, ...
                p_post_hoc_P1P3]);
            post_hoc{2, 1} = "Holm-Bonferroni";
            
            % save values
            post_hoc{2, 3}{1, 2} = p_post_hoc_corr(1);  % P1 vs. P2
            post_hoc{2, 3}{2, 2} = p_post_hoc_corr(2);  % P2 vs. P3
            post_hoc{2, 3}{3, 2} = p_post_hoc_corr(3);  % P1 vs. P3

            post_hoc{2, 5}{1, 2} = r_post_hoc_P1P2;     % P1 vs. P2
            post_hoc{2, 5}{2, 2} = r_post_hoc_P2P3;     % P2 vs. P3
            post_hoc{2, 5}{3, 2} = r_post_hoc_P1P3;     % P1 vs. P3

        case "Dunn"
            % run the test + correction after Sidák
            [c, ~, ~, ~] = ...
                multcompare(stats_big, ...
                "CriticalValueType", "dunn-sidak", ...
                "Display", "off");
            c = {"Index of Group 1", "Index of Group 2", ...
                "Lower Confidence Interval", "Estimate", ...
                "Upper Confidence Interval", "p-Value"; ...
                c(1, 1), c(1, 2), c(1, 3), c(1, 4), c(1, 5), c(1, 6); ...
                c(2, 1), c(2, 2), c(2, 3), c(2, 4), c(2, 5), c(2, 6); ...
                c(3, 1), c(3, 2), c(3, 3), c(3, 4), c(3, 5), c(3, 6)};

            % Effect Size: Rank-biserial correlation
            [~, ~, stats_P1P2] = ...
                signrank(filtered_table{1, 2}, filtered_table{2, 2});
            [~, ~, stats_P2P3] = ...
                signrank(filtered_table{2, 2}, filtered_table{3, 2});
            [~, ~, stats_P1P3] = ...
                signrank(filtered_table{1, 2}, filtered_table{3, 2});

            r_post_hoc_P1P2 = ...
                stats_P1P2.zval / sqrt(size(filtered_data, 1));
            r_post_hoc_P2P3 = ...
                stats_P2P3.zval / sqrt(size(filtered_data, 1));
            r_post_hoc_P1P3 = ...
                stats_P1P3.zval / sqrt(size(filtered_data, 1));

            % save values
            post_hoc{2, 3}{1, 2} = c(1, 6);  % P1 vs. P2
            post_hoc{2, 3}{2, 2} = c(3, 6);  % P2 vs. P3
            post_hoc{2, 3}{3, 2} = c(2, 6);  % P1 vs. P3

            post_hoc{2, 5}{1, 2} = r_post_hoc_P1P2;     % P1 vs. P2
            post_hoc{2, 5}{2, 2} = r_post_hoc_P2P3;     % P2 vs. P3
            post_hoc{2, 5}{3, 2} = r_post_hoc_P1P3;     % P1 vs. P3

        case "Conover-Iman"
            % do the test
            [p_P1P2, p_P2P3, p_P1P3] = ...
                conoveriman(filtered_table{1, 2}, ...
                filtered_table{2, 2}, filtered_table{3, 2});

            % Holm-Bonferroni Correction of p-values
            [p_post_hoc_corr, ~] = ...
                bonf_holm([p_P1P2, p_P2P3, p_P1P3]);

            % Effect Size: Rank-Biserial Correlation
            [~, ~, stats_P1P2] = ...
                signrank(filtered_table{1, 2}, filtered_table{2, 2});
            [~, ~, stats_P2P3] = ...
                signrank(filtered_table{2, 2}, filtered_table{3, 2});
            [~, ~, stats_P1P3] = ...
                signrank(filtered_table{1, 2}, filtered_table{3, 2});

            r_post_hoc_P1P2 = ...
                stats_P1P2.zval / sqrt(size(filtered_data, 1));
            r_post_hoc_P2P3 = ...
                stats_P2P3.zval / sqrt(size(filtered_data, 1));
            r_post_hoc_P1P3 = ...
                stats_P1P3.zval / sqrt(size(filtered_data, 1));

            % save values
            post_hoc{2, 3}{1, 2} = p_post_hoc_corr(1);  % P1 vs. P2
            post_hoc{2, 3}{2, 2} = p_post_hoc_corr(2);  % P2 vs. P3
            post_hoc{2, 3}{3, 2} = p_post_hoc_corr(3);  % P1 vs. P3

            post_hoc{2, 5}{1, 2} = r_post_hoc_P1P2;     % P1 vs. P2
            post_hoc{2, 5}{2, 2} = r_post_hoc_P2P3;     % P2 vs. P3
            post_hoc{2, 5}{3, 2} = r_post_hoc_P1P3;     % P1 vs. P3

        otherwise
            fprintf("You probably didn't write the test of choice correctly.")
    end
    
end


end