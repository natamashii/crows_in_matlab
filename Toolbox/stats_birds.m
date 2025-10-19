function statistics = ...
    stats_birds(performances_j, performances_u, ...
    resp_freq_j, resp_freq_u, rec_times_j, rec_times_u, ...
    factors, patterns, numerosities, alpha_stats)

% function for bird statistics: Comparison just among Uri & Jello

%% Pre Allocation

statistics = struct();
friedman_table = {"Performance", "Response Frequency", "Reaction Time"; ...
    [], [], []};
friedman_stats = {"Performance", "Response Frequency", "Reaction Time"; ...
    [], [], []};

stats_table = cell(2, 3);
crow_split = cell(3, 2);

%% Sort Data into Nice Table
data_table = datatable({performances_j, performances_u}, ...
    {resp_freq_j, resp_freq_u}, {rec_times_j, rec_times_u}, ...
    patterns, numerosities, factors);

%% Split Data into Crows

% iterate over crows
for crow_idx = 1:2
    
    % Performance
    crow_split{1, crow_idx} = ...
        data_table(data_table.Condition == ...
        factors{crow_idx}, :).Performance;

    % Response Frequency
    crow_split{2, crow_idx} = ...
        data_table(data_table.Condition == ...
        factors{crow_idx}, :).ResponseFrequency;

    % Reaction Time
    crow_split{3, crow_idx} = ...
        data_table(data_table.Condition == ...
        factors{crow_idx}, :).RT;
end

%% Statistical Tests: Jello vs. Uri

% iterate over behavioural data
for behav_idx = 1:3
    % Friedman Test
    [stats_table{1, behav_idx}, friedman_table{2, behav_idx}, ...
        friedman_stats{2, behav_idx}] = ...
        friedman([crow_split{behav_idx, 1}, ...
        crow_split{behav_idx, 2}], 1, "off");

    % Effect Size: Kendall's W
    chi2 = friedman_table{2, behav_idx}{2, 5};  % Chi Squared Statistics
    stats_table{2, behav_idx} = chi2 / ...
        (size(crow_split{behav_idx, 1}, 1) * 2);
end

%% Rewrite the results
stats_table = cell2table(stats_table);
stats_table.Properties.VariableNames = ...
    {'Performance', 'Response Frequency', 'Reaction Time'};
stats_table.Properties.RowNames = ...
    {'Friedman p-Value', 'Kendalls W'};

statistics.Results = stats_table;
statistics.Friedman_Table = friedman_table;
statistics.Friedman_Stats = friedman_stats;
statistics.Alpha_Level = alpha_stats;

end