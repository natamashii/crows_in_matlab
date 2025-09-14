function [penis] = lin_regress(ind_data, to_split, patterns)

% function to compute linear regression of all data that should be compared
% to each other

% NOTES
% include p value shit + effect size (R^2 ???)
% if to_split, then ind_data must be a 1x2 cell with ind data of cases

if to_split
    ind_data_1 = ind_data{1};
    ind_data_2 = ind_data{2};
end

% iterate over patterns
for pattern = 1:length(patterns)

end


end