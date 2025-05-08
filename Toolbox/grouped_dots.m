function [group_distances, group_wise_distances, dot_pos] = ...
    grouped_dots(dot_groups, group_radii, dot_radii, scaling, rad_back, x, y, subgrouprad)

% function to generate subgroups to project dots

% pre allocation
group_amount = size(dot_groups, 1); 
group_centers = zeros(group_amount, 2);
group_wise_distances = {};
group_distances = 0;
dot_pos = zeros(sum(dot_groups), 2);
dot_id = zeros(sum(dot_groups), 2); % dim 1: ID for dot, dim 2: ID for group
dot_counter = 0;

% scaling factor for identifying group's center
group_center_limit = max(max(x * rad_back, y * rad_back)) ...
    - (group_radii(1) * scaling) * 1.6;

% set first group
alpha_1 = 2 * pi * rand(1, 1);
group_centers(1, 1) = sin(alpha_1) * group_center_limit;
group_centers(1, 2) = cos(alpha_1) * group_center_limit;

if group_amount > 1
    for group = 2:group_amount
        % set angle
        alpha = alpha_1 - ((2 * pi) / group_amount) * (group - 1);
        % adjust distance to center
        group_center_limit = max(max(x * rad_back, y * rad_back)) ...
            - (group_radii(group) * scaling) * 1.6;
        group_centers(group, 1) = sin(alpha) * group_center_limit;
        group_centers(group, 2) = cos(alpha) * group_center_limit;
    end
    % get distances of each group center to another
    [group_distances, ~] = get_distances(group_centers, 0);
end

% iterate over each subgroup
for group = 1:group_amount
    dot_counter = dot_counter + 1;
    % set angle of first dot randomly
    alpha_1 = 2 * pi * rand(1, 1);
    % convert to cartesian coordinates
    dot_pos(dot_counter, 1) = group_centers(group, 1) ...
        + sin(alpha_1) * (subgrouprad + dot_radii(dot_counter));
    dot_pos(dot_counter, 2) = group_centers(group, 2) ...
        + cos(alpha_1) * (subgrouprad + dot_radii(dot_counter));
    % add dot ID
    dot_id(dot_counter, 1) = dot_counter;
    dot_id(dot_counter, 2) = group;

    % get angles of remaining dots & convert to
    % cartesian coordinates
    for dot = 2:dot_groups(group)
        dot_counter = dot_counter + 1;
        % get angle
        alpha = alpha_1 - ((2 * pi) / dot_groups(group)) * (dot - 1);
        % get distance to first dot
        dot_pos(dot_counter, 1) = group_centers(group, 1) + (sin(alpha) * (subgrouprad + dot_radii(dot_counter)));
        dot_pos(dot_counter, 2) = group_centers(group, 2) + (cos(alpha) * (subgrouprad + dot_radii(dot_counter)));
        % add dot ID
        dot_id(dot_counter, 1) = dot_counter;
        dot_id(dot_counter, 2) = group;
    end
end

% get distances between dots for each group
for group = 1:group_amount
    [row, ~] = find(dot_id(:, 2) == group);
    [dist, ~] = ...
        get_distances(dot_pos(row, :), 0);
    % subtract dot's radii from resulting distance
    group_wise_distances{end + 1} = dist - (sum(dot_radii(row)));
end

% convert to array
group_wise_distances = vertcat(group_wise_distances{:});

end