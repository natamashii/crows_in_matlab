function [lin_reg] = ...
    lin_regress(performances, resp_freq, rec_times, ...
    patterns, numerosities, data_type, avg_data)

% function to compute linear regression of all data that should be compared
% to each other

% pre allocation
lin_reg = {"polyfit", "R", "df", "normr", "rsquared", ...
    "mu", "y", "delta"};
filtered_data_cell = {};

data_table = ...
    datatable(performances, resp_freq, rec_times, patterns, numerosities);


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
        polyval(p, filtered_data.Sample, S, mu);

    % do the same for avg_data
    [p_avg, S_avg, mu_avg] = ...
        polyfit(numerosities(:, 1), avg_data(pattern, :), 1);
    [y_avg, delta_avg] = polyval(p_avg, numerosities(:, 1), S_avg, mu_avg);

    % sort data
    lin_reg{pattern + 1, 1} = {p; p_avg};
    lin_reg{pattern + 1, 2} = {S.R; S_avg.R};
    lin_reg{pattern + 1, 3} = {S.df; S_avg.df};
    lin_reg{pattern + 1, 4} = {S.normr; S_avg.normr};
    lin_reg{pattern + 1, 5} = {S.rsquared; S_avg.rsquared};
    lin_reg{pattern + 1, 6} = {mu; mu_avg};
    lin_reg{pattern + 1, 7} = {y; y_avg};
    lin_reg{pattern + 1, 8} = {delta; delta_avg};
    filtered_data_cell{pattern} = filtered_data;
end

end