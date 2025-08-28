function penis = bootstrapping(data, n_boot, alpha, in_detail, patterns, numerosities)

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
            end
        end
        if ~in_detail
            bootstrap_median = zeros(n_boot, 1);
        end
    end
end



end