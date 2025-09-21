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

% note: do this again but for the avg_data cuz the shit looks weird rn...

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
    filtered_data_cell{pattern} = filtered_data;
end

end