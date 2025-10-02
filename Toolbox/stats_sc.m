function statistics = stats_sc(performances_s, performances_c, ...
    resp_freq_s, resp_freq_c, rec_times_s, rec_times_c, patterns, ...
    numerosities, factors, alpha_stats)

% Function for statistics of Standard vs. Control

% Note: maybe pre process RTs: remove too quick trials & remove everything
% that is +- 3* MAD of median

% pre allocation
statistics = struct();
friedman_table = {"Performance", "Response Frequency", "Reaction Time"; ...
    [], [], []};
friedman_stats = {"Performance", "Response Frequency", "Reaction Time"; ...
    [], [], []};
wilcoxon_stats = {"Performance", "Response Frequency", "Reaction Time"; ...
    {3, 4, 5, 6, 7; [], [], [], [], []}, ...
    {3, 4, 5, 6, 7; [], [], [], [], []}, ...
    {3, 4, 5, 6, 7; [], [], [], [], []}};

stats_table = cell(4, 3);
filtered_data = cell(3, 2, size(numerosities, 1));
condition_split = cell(3, 2);

%% Sort Data into Nice Table

data_table = datatable({performances_s, performances_c}, ...
    {resp_freq_s, resp_freq_c}, {rec_times_s, rec_times_c}, ...
    patterns, numerosities, factors);

%% Split Table into Samples

% iterate over samples
for sample_idx = 1:size(numerosities, 1)
    
    filtered = ...
        data_table(data_table.Sample == ...
        numerosities(sample_idx, 1), :);

    filtered_standard = filtered(filtered.Condition == factors{1}, :);
    filtered_control = filtered(filtered.Condition == factors{2}, :);

    % Performance
    filtered_data{1, 1, sample_idx} = filtered_standard.Performance;
    filtered_data{1, 2, sample_idx} = filtered_control.Performance;

    % Response Frequency
    filtered_data{2, 1, sample_idx} = filtered_standard.ResponseFrequency;
    filtered_data{2, 2, sample_idx} = filtered_control.ResponseFrequency;

    % Reaction Time
    filtered_data{3, 1, sample_idx} = filtered_standard.RT;
    filtered_data{3, 2, sample_idx} = filtered_control.RT;
end

%% Split Data into Conditions

% iterate over conditions
for cond_idx = 1:2
    
    % Performance
    condition_split{1, cond_idx} = ...
        data_table(data_table.Condition == ...
        factors{cond_idx}, :).Performance;

    % Response Frequency
    condition_split{2, cond_idx} = ...
        data_table(data_table.Condition == ...
        factors{cond_idx}, :).ResponseFrequency;

    % Reaction Time
    condition_split{3, cond_idx} = ...
        data_table(data_table.Condition == ...
        factors{cond_idx}, :).RT;
end

%% Statistical Tests

% iterate over behavioural data
for behav_idx = 1:3
    % Friedman Test
    [stats_table{1, behav_idx}, friedman_table{2, behav_idx}, ...
        friedman_stats{2, behav_idx}] = ...
        friedman([condition_split{behav_idx, 1}, ...
        condition_split{behav_idx, 2}], 1, "off");
    
    % Effect Size: Kendall's W
    chi2 = friedman_table{2, behav_idx}{2, 5}; % Chi Squared Statistics
    stats_table{2, behav_idx} = chi2 / ...
        (size(filtered_data{behav_idx, 1}, 1) * 2);

    %% Post-Hoc Analysis
    if le(stats_table{1, behav_idx}, alpha_stats)
        % iterate over samples
        p_r_samples = NaN(2, size(numerosities, 1));
        for sample_idx = 1:size(numerosities, 1)

            % Wilcoxon Signed-Rank Test
            [p_r_samples(1, sample_idx), ~, ...
                wilcoxon_stats{2, behav_idx}{2, sample_idx}] = ...
                signrank(filtered_data{behav_idx, 1, sample_idx}, ...
                filtered_data{behav_idx, 2, sample_idx});

            % Effect Size: Rank-Biserial Correlation r
            mu_W = (size(filtered_data{behav_idx, 1, sample_idx}, 1)) * ...
                (size(filtered_data{behav_idx, 1, sample_idx}, 1) + 1) / 4;
            sigma_W = ...
                sqrt((size(filtered_data{behav_idx, 1, sample_idx}, 1) * ...
                (size(filtered_data{behav_idx, 1, sample_idx}, 1) + 1) * ...
                (2 * size(filtered_data{behav_idx, 1, sample_idx}, 1) + ...
                1)) / 24);
            wilcoxon_stats{2, behav_idx}{2, sample_idx}.zval = ...
                (wilcoxon_stats{2, behav_idx}{2, sample_idx}.signedrank - ...
                mu_W) / sigma_W;
            p_r_samples(2, sample_idx) = ...
                wilcoxon_stats{2, behav_idx}{2, sample_idx}.zval / ...
                sqrt(size(filtered_data{behav_idx, 1, sample_idx}, 1));
        end
        stats_table{3, behav_idx} = p_r_samples(1, :);
        stats_table{4, behav_idx} = p_r_samples(2, :);
    end
end


%% Rewrite the results
stats_table = cell2table(stats_table);
stats_table.Properties.VariableNames = ...
    {'Performance', 'Response Frequency', 'Reaction Time'};
stats_table.Properties.RowNames = ...
    {'Friedman p-Value', 'Kendalls W', ...
    'Wilcoxon Signed-Rank p-Value', 'Rank Biserial-Correlation r'};
statistics.Results = stats_table;
statistics.Friedman_Table = friedman_table;
statistics.Friedman_Stats = friedman_stats;
statistics.Alpha_Level = alpha_stats;

end