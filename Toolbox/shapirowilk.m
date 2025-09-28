function [H, p, W] = ...
    shapirowilk(ind_data, patterns, numerosities)

% Function to test data for normality (Shapiro-Wilk) for each sample
% Works for matches only

% pre allocation
H = NaN(length(patterns), size(numerosities, 1));
p = NaN(length(patterns), size(numerosities, 1));
W = NaN(length(patterns), size(numerosities, 1));

% iterate over patterns
for pattern = 1:length(patterns)
    % iterate over samples
    for sample_idx = 1:size(numerosities, 1)
        [H(pattern, sample_idx), ...
            p(pattern, sample_idx), W(pattern, sample_idx)] = ...
            swtest(ind_data(:, pattern, sample_idx, 1));
    end
end

end