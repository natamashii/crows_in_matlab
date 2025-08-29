function err_data = ...
    bootstrapping(data, n_boot, alpha, in_detail, patterns, numerosities)

% Function to calculate bootstrapping stuff

% pre allocation
if in_detail    % divided in each test numerosity tested
    err_data = zeros(2, length(patterns), size(numerosities, 1));
else
    err_data = zeros(2, length(patterns), size(numerosities, 1), size(numerosities, 2));
end

% pre definition
lower_percentile = alpha / 2;
upper_percentile = (1- alpha) / 2;

% iterate over patterns
for pattern = 1:length(patterns)
    % iterate over samples
    for sample_idx = 1:size(numerosities, 1)
        % iterate over test numerosities
        for test_idx = 1:size(numerosities, 2)
            if in_detail
                bootstrap_median = zeros(n_boot, 1);
                % resample n_boot times
                for b_idx = 1:n_boot
                    % generate random indices
                    resample_idx = ...
                        randi(numel(data(:, pattern, sample_idx, test_idx)), ...
                        numel(data(:, pattern, sample_idx, test_idx)), 1);

                    % bootstrap sample
                    bootstrap_sample = data(resample_idx);

                    % calculate median of current bootstrap sample
                    bootstrap_median(b_idx) = median(bootstrap_sample);

                    % sort the median vals
                    sorted_bootstrap_median = sort(bootstrap_median);

                    % get CIs
                    err_data(1, pattern, sample_idx, test_idx) = ...
                        prctile(sorted_bootstrap_median, lower_percentile);
                    err_data(2, pattern, sample_idx, test_idx) = ...
                        prctile(sorted_bootstrap_median, upper_percentile);
                end
            end
        end
        if ~in_detail
            bootstrap_median = zeros(n_boot, 1);
            % resample n_boot times
            for b_idx = 1:n_boot
                % generate random indices
                resample_idx = ...
                    randi(numel(data(:, pattern, sample_idx, :)), ...
                    numel(data(:, pattern, sample_idx, :)), 1);

                % bootstrap sample
                bootstrap_sample = data(resample_idx);

                % calculate median of current bootstrap sample
                bootstrap_median(b_idx) = median(bootstrap_sample);

                % sort the median vals
                sorted_bootstrap_median = sort(bootstrap_median);

                % get CIs
                err_data(1, pattern, sample_idx) = ...
                    prctile(sorted_bootstrap_median, lower_percentile);
                err_data(2, pattern, sample_idx) = ...
                    prctile(sorted_bootstrap_median, upper_percentile);
            end
        end
    end
end



end