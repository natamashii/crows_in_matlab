function [group_distances, group_wise_distances, dot_pos, group_centers] = ...
    grouped_dots(dot_groups, group_radii, dot_radii, scaling, rad_back, ...
    x, y, subgrouprad)

% function to generate subgroups to project dots

% pre allocation
group_amount = size(dot_groups, 1); 
group_centers = zeros(group_amount, 2);
group_wise_distances = {};
group_distances = 0;
dot_pos = zeros(sum(dot_groups), 2);
dot_id = zeros(sum(dot_groups), 2); % dim 1: ID for dot, dim 2: ID for group
dot_counter = 0;
dot_scale = 1;  % arbitrary scaling factor that fixes 3-dot problem real quick
group_control = false;

while ~group_control
    for group = 1:group_amount
        group_pos_limit = max(max(x * rad_back, y * rad_back)) ...
            - (group_radii(group) * scaling * 1.2);
        group_centers(group, :) = (2 * group_pos_limit) * (rand(2, 1) - .5);
    end

    % validation: groups have enough distance among each other
    if group_amount == 1
        group_control = true;
    else
        [group_distances, group_control] = get_distances(group_centers, 0);
    end
    group_control = true;
end
% set dots: iterate over each subgroup
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
        % set dot position
        if dot_groups(group) > 2
            dot_scale = 1.2;
        end
        dot_pos(dot_counter, 1) = group_centers(group, 1) ...
            + (sin(alpha) * (subgrouprad + dot_radii(dot_counter)) * dot_scale);
        dot_pos(dot_counter, 2) = group_centers(group, 2) ...
            + (cos(alpha) * (subgrouprad + dot_radii(dot_counter)) * dot_scale);
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
for el = 1:size(group_wise_distances, 2)
    group_wise_distances{el} = reshape(group_wise_distances{el}.', 1, []);
end
group_wise_distances = horzcat(group_wise_distances{:});

end
