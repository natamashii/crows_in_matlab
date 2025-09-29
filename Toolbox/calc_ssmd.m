function [smd, ssmd] = ...
    calc_ssmd(performances, resp_freq, rec_times, avg_data_stats, ...
    patterns, numerosities, data_type)

% function to compute strictly standardized mean of differences between
% patterns for each sample (matches only)

% pre allocation
filtered_table = cell(3, 3);
smd = NaN(length(patterns), size(numerosities, 1));
ssmd = NaN(length(patterns), size(numerosities, 1));

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
            filtered_table{pattern, 3} = avg_data_stats(:, pattern);
            what_analysis = 'Performance';

        case "Response Frequency"
            filtered_table{pattern, 2} = ...
                filtered_table{pattern, 1}.ResponseFrequency;
            filtered_table{pattern, 3} = avg_data_stats(:, pattern);
            what_analysis = 'ResponseFrequency';

        case "Reaction Times"
            filtered_table{pattern, 2} = ...
                filtered_table{pattern, 1}.RT;
            filtered_table{pattern, 3} = avg_data_stats(:, pattern);
            what_analysis = 'RT';
    end
end


%% Calculate SMD & SSMD
%  iterate over samples
for sample_idx = 1:size(numerosities, 1)
    p1 = table2array(filtered_table{1, 1}(filtered_table{1, 1}.Sample == ...
        numerosities(sample_idx, 1), what_analysis));
    p2 = table2array(filtered_table{2, 1}(filtered_table{2, 1}.Sample == ...
        numerosities(sample_idx, 1), what_analysis));
    p3 = table2array(filtered_table{3, 1}(filtered_table{3, 1}.Sample == ...
        numerosities(sample_idx, 1), what_analysis));

    % P1 vs. P2
    placeholder = ...
        meanEffectSize(p1, p2, ...
        "Effect", "meandiff", "Paired", true);
    covariance = cov(p1, p2);
    smd(1, sample_idx) = table2array(placeholder("MeanDifference", "Effect"));
    ssmd(1, sample_idx) = (mean(p1, "all") - mean(p2, "all")) / ...
        sqrt(var(p1, [], "all") + var(p2, [], "all") - ...
        (2 * covariance(1, 2)));

    % P2 vs. P3
    placeholder = ...
        meanEffectSize(p2, p3, ...
        "Effect", "meandiff", "Paired", true);
    covariance = cov(p2, p3);
    smd(2, sample_idx) = table2array(placeholder("MeanDifference", "Effect"));
    ssmd(2, sample_idx) = (mean(p2, "all") - mean(p3, "all")) / ...
        sqrt(var(p2, [], "all") + var(p3, [], "all") - ...
        (2 * covariance(1, 2)));

    % P1 vs. P3
    placeholder = ...
        meanEffectSize(p1, p3, ...
        "Effect", "meandiff", "Paired", true);
    covariance = cov(p1, p3);
    smd(3, sample_idx) = table2array(placeholder("MeanDifference", "Effect"));
    ssmd(3, sample_idx) = (mean(p1, "all") - mean(p3, "all")) / ...
        sqrt(var(p1, [], "all") + var(p3, [], "all") - ...
        (2 * covariance(1, 2)));
end

end