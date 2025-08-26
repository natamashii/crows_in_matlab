function penis = avg_error(patterns, numerosities)

% function to compute average/median, their errors & such stuff

% Pre allocation

% dim 1: 1 = mean, 2 = median
% dim 2: patterns, dim 3: samples, dim 4: test nums
avg_resp = ...
    zeros(2, length(patterns), size(numerosities, 1), size(numerosities, 2));

% dim 1: 1 = std, 2 = sem, 3 = CI up, 4 = CI down
% dim 2: patterns, dim 3: samples, dim 4: test nums
err_resp = ...
    zeros(4, length(patterns),size(numerosities, 1), size(numerosities, 2));


end