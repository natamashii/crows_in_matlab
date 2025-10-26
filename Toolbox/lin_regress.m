function [lin_reg] = ...
    lin_regress(performances, resp_freq, rec_times, ...
    patterns, numerosities, n_boot, alpha_stats)

% Function to get data of a linear regression

%% Pre allocation

lin_reg = {" ", "y", "delta", "R2", "coefficients", "Structure", "mu"; ...
    "Performance", NaN, NaN, NaN, NaN, NaN, NaN; ...
    "Response Frequency", NaN, NaN, NaN, NaN, NaN, NaN; ...
    "Reaction Times", NaN, NaN, NaN, NaN, NaN, NaN};

%% Get average data
[avg_data_performance, ~, ~] = ...
    calc_behav(performances, 'Performance', 'Mean', 'SEM', ...
    patterns, numerosities, n_boot, alpha_stats, 'Overall', false);
[avg_data_resp_freq, ~, ~] = ...
    calc_behav(resp_freq, 'Response Frequency', 'Mean', 'SEM', ...
    patterns, numerosities, n_boot, alpha_stats, 'Overall', false);
[avg_data_rec_times, ~, ~] = ...
    calc_behav(rec_times, 'Reaction Times', 'Median', 'STD', ...
    patterns, numerosities, n_boot, alpha_stats, 'Matches', false);


%% Get Regression Values

[p_performance, S_performance, mu_performance] = ...
    polyfit([1, 2, 3], avg_data_performance, 1);
[p_resp_freq, S_resp_freq, mu_resp_freq] = ...
    polyfit([1, 2, 3], avg_data_resp_freq, 1);
[p_rec_times, S_rec_times, mu_rec_times] = ...
    polyfit([1, 2, 3], avg_data_rec_times, 1);

[y_performance, delta_performance] = ...
    polyval(p_performance, [1, 2, 3], S_performance, mu_performance);
[y_resp_freq, delta_resp_freq] = ...
    polyval(p_resp_freq, [1, 2, 3], S_resp_freq, mu_resp_freq);
[y_rec_times, delta_rec_times] = ...
    polyval(p_rec_times, [1, 2, 3], S_rec_times, mu_rec_times);

%% Store the Data

% fitted y values
lin_reg{2, 2} = y_performance;
lin_reg{3, 2} = y_resp_freq;
lin_reg{4, 2} = y_rec_times;

% 2 * STD (Delta)#
lin_reg{2, 3} = delta_performance;
lin_reg{3, 3} = delta_resp_freq;
lin_reg{4, 3} = delta_rec_times;

% R^2
lin_reg{2, 4} = S_performance.rsquared;
lin_reg{3, 4} = S_resp_freq.rsquared;
lin_reg{4, 4} = S_rec_times.rsquared;

% coefficients (p)
lin_reg{2, 5} = p_performance;
lin_reg{3, 5} = p_resp_freq;
lin_reg{4, 5} = p_rec_times;

% Structure (S)
lin_reg{2, 6} = S_performance;
lin_reg{3, 6} = S_resp_freq;
lin_reg{4, 6} = S_rec_times;

% mu
lin_reg{2, 7} = mu_performance;
lin_reg{3, 7} = mu_resp_freq;
lin_reg{4, 7} = mu_rec_times;

end