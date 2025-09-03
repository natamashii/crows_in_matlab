function [low_err_data, up_err_data] = ...
    bootstrapping(data, n_boot, alpha)

% Function to calculate bootstrapping stuff

% pre allocation
bootstrap_median = zeros(n_boot, 1);

% pre definition
lower_percentile = alpha / 2;
upper_percentile = 100 - (alpha / 2);

% Median of data
med_data = median(data, "omitnan");

% resample n_boot times
for b_idx = 1:n_boot
    % generate random indices
    resample_idx = randi(numel(data), numel(data), 1);

    % bootstrap sample
    bootstrap_sample = data(resample_idx);

    % calculate median of current bootstrap sample
    bootstrap_median(b_idx) = median(bootstrap_sample);

    % sort the median vals
    sorted_bootstrap_median = sort(bootstrap_median);

    % get CIs
    low_err_data = med_data - ...
        prctile(sorted_bootstrap_median, lower_percentile);
    up_err_data = prctile(sorted_bootstrap_median, upper_percentile) - ...
        med_data;

end

end