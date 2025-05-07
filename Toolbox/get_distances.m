function [distances, control] = get_distances(positions, min_distance)

% function to get distances between dots or groups & control if each
% distance is above minimum threshold

% INPUT
% positions: 2-D array with dim 1 being an item & dim 2 it's cartesian
% coordinates

% x coordinate distance
d_x = bsxfun(@minus, positions(:, 1)', positions(:, 1));

% y coordinate distance
d_y = bsxfun(@minus, positions(:, 2)', positions(:, 2));

% get eucledian distances
euc_distances = sqrt(d_x .^2 + d_y .^2);

% remove distance of item with itself
sort_distances = sort(euc_distances, 1, "ascend");
distances = sort_distances(2:end, :);

% control if each distance is above minimum threshold
if ~all(distances(:) >= min_distance)
    control = false;
else
    control = true;
end

end
