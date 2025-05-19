function control = equal_distances(positions, dot_radii, density_limits)

% function to make sure that dot have equal distances among each other

% pre allocation
control = false;
dot_distances = zeros(size(positions, 1), size(positions, 1));

% iterate over each dot and get its distance to the remaining dots
if size(positions, 1) > 1
    for dot = 1:size(positions, 1)
        % iterate over other dots
        for next_dot = 1:size(positions, 1)
            % skip if it the same dot
            if next_dot == dot
                continue
            end
            % calculate distances between dots' centers
            dist = sqrt((positions(dot, 1) - positions(next_dot, 1))^2 + ...
                (positions(dot, 2) - positions(next_dot, 2))^2);
            % substract dot_radii
            dot_distances(dot, next_dot) = dist - dot_radii(dot) - dot_radii(next_dot);
        end
    end
    % remove the remaining 0's
    sort_distances = sort(dot_distances, 1, "ascend");
    dot_distances = sort_distances(2:end, :);
    % control if within density limit
    if all(dot_distances(:) >= density_limits(1)) && ...
            all(dot_distances(:) <= density_limits(2))
        control = true;
    end
else
    control = true;
end


end