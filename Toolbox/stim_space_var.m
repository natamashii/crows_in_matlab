function [penis] = ...
    stim_space_var(numerosities, patterns, stim_type, density_limit, ...
    area_limit, rad_dot_limit, scaling, rad_back, amount_stim, ...
    gr_rad_a, gr_dots_a, gr_rad_m, gr_dots_m)

% Function to Compute Stimulus Space Variability

% Pre allocation
stimuli = cell(length(patterns), length(numerosities), amount_stim);

% Extract all relevant numerosities
used_nums = unique(numerosities);

% Set eucledian values
angles = 0 : (2 * pi) / (360 - 1) : 2 * pi; % all angle values for full circle
x = sin(angles);    % x values for unit circle
y = cos(angles);    % y values for unit circle

%% Generate Stimulus
for m = 1:amount_stim

    % iterate over patterns
    for pattern = 1:length(patterns)

        % Set Minimal Dot Distance
        switch pattern
            case 1  % PR
                min_dot_distance = 2 * subgroup_rad;
            case 2  % P1
                min_dot_distance = 2.7 * subgroup_rad;
        end

        % Iterate over Numerosities
        for num_idx = 1:length(used_nums)

            % pre allocations
            dot_pos = zeros(used_nums(num_idx), 2);
            dot_check = false;
            check = false;

            % Set Dot Sizes
            switch stim_type
                case 'Control'
                    dot_radii = calc_area(area_limit(2), used_nums(num_idx));

                    % set density limit control
                    density_limit_spec = density_limit(1, :);

                case 'Standard'
                    dot_radii = (rad_dot_limit(2) - rad_dot_limit(1)) ...
                        .* rand(1, curr_num) + rad_dot_limit(1);
                    dot_radii = dot_radii.';

                    % set density limit control
                    density_limit_spec = density_limit(2, :);
            end

            % Set Dot Positions, depending on pattern type
            switch pattern
                case 1 || 2 % PR or P1
                    group_check = true;
                    while ~dot_check

                        % Iterate over Each Dot
                        for dot = 1:used_nums(num_idx)
                            % Validation 1: Dot inside B_grey
                            % Set Spatial Limit of current dot
                            dot_pos_limit = ...
                                max(max(x * rad_back, y * rad_back)) ...
                                - (2 * dot_radii(dot)) * scaling;

                            % Set Dot Positions
                            dot_pos(dot, :) = ...
                                (2 * dot_pos_limit) * (rand(2, 1) - .5);
                        end

                        % Validation 2: No Overlap Between Dots
                        [dot_distances, overlap_check] = ...
                                get_distances(dot_pos, min_dot_distance);

                        
                    end

                case 3  % P2
                    group_check = false;

                    % Set Subgroup Parameters
                    group_radii = gr_rad_a{num_idx};    % Radius of each subgroup
                    dot_groups = gr_dots_a{num_idx};    % Amount of Dots in Each Subgroup

                    % change density control interval if only one subgroup
                    if size(dot_groups, 1) == 1
                        density_limit_spec = density_limit_spec(:) - .51;
                    end

                case 4  % P3
                    group_check = false;

                    % Set Subgroup Parameters
                    group_radii = gr_rad_m{num_idx};    % Radius of each subgroup
                    dot_groups = gr_rad_m{num_idx};     % Amount of Dots in Each Subgroup

                    % change density control interval if only one subgroup
                    if size(dot_groups, 1) == 1
                        density_limit_spec = density_limit(2, :);
                        density_limit_spec(1) = density_limit_spec(1) - 1;
                    end
            end

            % Set Subgroups
            while ~group_check
                
                % Generate Grouped Dots
                [group_distances, group_wise_distances, ...
                    dot_pos, group_centers] = ...
                    grouped_dots(dot_groups, group_radii, dot_radii, ...
                    scaling, rad_back, x, y);

                group_check = true;
            end
            
            % Validation 3: Cumulative Density
            dot_density = density(dot_pos(:, 1), dot_pos(:, 2));
            switch pattern
                case 1  % PR
                    if mean(dot_density) >= density_limit_spec(1) && ...
                            mean(dot_density) <= density_limit_spec(2)
                        check = true;
                    end
                otherwise
                    if (mean(dot_density) - mean(dot_radii)) >= ...
                            density_limit_spec(1) && ...
                            (mean(dot_density) - mean(dot_radii)) <= ...
                            density_limit_spec(2)
                        check = true;
                    end
            end
        
        % Store generated dots into big cell
        stimuli{pattern, num_idx, m} = dot_pos;
        end
    end
end

%% Statistics


end