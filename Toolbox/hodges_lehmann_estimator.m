function [walsh_HL] = ...
    hodges_lehmann_estimator(diff_data, curr_experiments, numerosities, ...
    n_boot, alpha_stats)

% Function to Calculate Hodges-Lehmann Estimator for Differences

%% Pre Allocation

walsh_HL = cell(length(curr_experiments), size(numerosities, 1));
placeholder = {"P1 vs. P2", "P1 vs. P3", "P3 vs. P2"; ...
    [], [], []; ...     % Walsh Averages
    [], [], []; ...     % Hodges-Lehmann Estimator
    [], [], []; ...     % CI Lower
    [], [], []};        % CI Upper

% Iterate over Samples
for sample_idx = 1:size(numerosities, 1)
    
    % Iterate over Experiments
    for exp_idx = 1:length(curr_experiments)

        % extract raw diff values
        diffs_P2P1 = diff_data{exp_idx, sample_idx}{2, 1};
        diffs_P3P1 = diff_data{exp_idx, sample_idx}{2, 2};
        diffs_P3P2 = diff_data{exp_idx, sample_idx}{2, 3};

        %% Compute Walsh Averages
        % Sample Size
        n = [numel(diffs_P2P1), numel(diffs_P3P1), numel(diffs_P3P2)];
        
        % Walsh Averages
        walsh_P2P1 = (diffs_P2P1 + diffs_P2P1.') / 2;
        walsh_P3P1 = (diffs_P3P1 + diffs_P3P1.') / 2;
        walsh_P3P2 = (diffs_P3P2 + diffs_P3P2.') / 2;

        % remove duplicates
        walsh_P2P1 = walsh_P2P1(triu(true(n(1))));
        walsh_P3P1 = walsh_P3P1(triu(true(n(2))));
        walsh_P3P2 = walsh_P3P2(triu(true(n(3))));
        
        %% Compute Hodges-Lehmann Estimator
        HL_P2P1 = median(walsh_P2P1, "omitnan");
        HL_P3P1 = median(walsh_P3P1, "omitnan");
        HL_P3P2 = median(walsh_P3P2, "omitnan");

        %% Confidence Interval
        [low_err_data_P2P1, up_err_data_P2P1] = ...
            bootstrapping(walsh_P2P1, n_boot, alpha_stats);
        [low_err_data_P3P1, up_err_data_P3P1] = ...
            bootstrapping(walsh_P3P1, n_boot, alpha_stats);
        [low_err_data_P3P2, up_err_data_P3P2] = ...
            bootstrapping(walsh_P3P2, n_boot, alpha_stats);

        %% Save Results
        placeholder{2, 1}= walsh_P2P1;
        placeholder{2, 2} = walsh_P3P1;
        placeholder{2, 3} = walsh_P3P2;
        placeholder{3, 1} = HL_P2P1;
        placeholder{3, 2} = HL_P3P1;
        placeholder{3, 3} = HL_P3P2;
        placeholder{4, 1} = low_err_data_P2P1;
        placeholder{4, 2} = low_err_data_P3P1;
        placeholder{4, 3} = low_err_data_P3P2;
        placeholder{5, 1} = up_err_data_P2P1;
        placeholder{5, 2} = up_err_data_P3P1;
        placeholder{5, 3} = up_err_data_P3P2;
        walsh_HL{exp_idx, sample_idx} = placeholder;

    end
end

end