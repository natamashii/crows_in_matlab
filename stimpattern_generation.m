clear
clc 
close all

% main script
% progress: random works,groupitizing is missing fixed subgroup density
% value, control condition successfully debugged
% current idea on density control: ignore density between dots, that should
% be just large enough to be identified as groups
% insteas focus on dot density, within subgroup it should just be larger
% than a threshold, and among groups with that make the mean for control

% add groupitizing function
% ideas: spatial grouping, colour grouping, temporal grouping 
% make back circle radius back to one value
% sort code bit: move hardcoded variables to top
% make scaling a two element vector to allow flexibility of screen for
% display
% maybe try to work around hardcoded variables
% after this, implement b_grey to main loop (only let it generated once)
% then make standard and control generation all at once
% make path adaptive
% maybe find a solution for winsize soft coding and why it matters on which
% PC i am letting this code run
% put controls and stuff into functions


% Pre definition
% path to save stimuli pattern
stim_path = 'D:\MasterThesis\analysis\Stimuli_creation\a_bunch_of_sets\';

% demanding specification of stimulus type to generate (case-insensitive)
prompt = 'Create set of Standard (s) or Control (c) stimuli?';
%stim_type = input(prompt, "s");
stim_type = "C";
counter = 0;    % for progressbar
amount_img = 4;     % defines how many versions of one condition should be generated

% numerosities of interest
numbers = 6;
check = false;  % boolean that toggles if every control is fulfilled
to_break = false;   % boolean that toggles in case of mistyping stimulus type

% figure specifications
set(0, "defaultfigurecolor", [0 0 0])
scaling = 1;   % factor for stretching lovely picture (to be displayed as circle in lateralization setup)
winsize = 209;  % needed for figure specificiation

% background circle specifications
rad_back = [1, 1];  % radius for x-axis (1. dim) and y-axis (2. dim) in []
rad_back(2) = rad_back(2) * scaling;    % plot actually an ellipse (will be displayed as circle in lateralization setup)
back_circ_c = [.5, .5, .5];     % grey colour
angle_steps = 360;  % fine tuning of background circle
% background circle generation
angles = 0 : (2 * pi)/(angle_steps - 1) : 2 * pi; % all angle values for full circle
x = sin(angles);    % x values for unit circle
y = cos(angles);    % y values for unit circle

% dot specifications
rad_dot_limit = [.08, .2];   % radius limitations in [] (based on control)
min_dist = .01;  % minimal intra-dot distance in []
area_limit = [.18, .2];   % limits of cumulative area of the dots
density_limit = [.92, .97; .01, 20];
subgrouprad = .1;

pattern = "grouped";

% generate fixation stimulus (b_grey)
[b_grey, x, y] = plot_backcircle(angle_steps, winsize, rad_back, back_circ_c);

saveas(b_grey, strcat(stim_path, 'B_grey.bmp'), 'bmp')  % save the figure
close

% iterate over amount of desired stimuli
for stimulus = 1:size(numbers, 2)
    curr_num = numbers(stimulus);
    for img = 1:amount_img
        % Pre definitions
        check = false;
        size_check = false;
        % pre allocations
        dot_pos = zeros(curr_num, 2);
        while ~check
            % Dot Sizes
            % Control Stimuli
            if stim_type == "c" || stim_type == "C"
                stim_type = "C";
                % control: constant cumulative area
                dot_radii = calc_area(area_limit(2), curr_num);
                density_limit_spec = density_limit(1, :);

            % Standard Stimuli
            elseif stim_type == "s" || stim_type == "S"
                stim_type = "S";

                % set random dot sizes within prior specified limit
                dot_radii = (rad_dot_limit(2) - rad_dot_limit(1)) ...
                    .* rand(1, curr_num) + rad_dot_limit(1);

                density_limit_spec = density_limit(2, :);
            else
                fprintf("Error. You probably mistyped the stimulus type: ")
                fprintf(stim_type)
                to_break = true;
                break
            end
            
            switch pattern
                case "random"
                    % Dot Positions
                    % validation 1: dot inside background
                    for dot = 1:curr_num
                        dot_pos_limit = max(max(x * rad_back(1), y * rad_back(1))) ...
                            - 2 * (dot_radii(dot) * scaling) * 1;
                        dot_pos(dot, :) = (2 * dot_pos_limit) * (rand(2, 1) - .5);
                    end

                    % validation: no overlap between dots
                    min_dot_distance = max(dot_radii) * 2.2;
                    [dot_distances, ~] = ...
                        get_distances(dot_pos, min_dot_distance);

                    % cumulative density control
                    mean_distance = mean(dot_distances, "all");
                    if (mean_distance > density_limit_spec(1) && ...
                            mean_distance < density_limit_spec(2))
                        check = true;
                        plot_dot_pos = dot_pos;
                    else
                        check = false;
                    end
                case "grouped"
                    group_check = false;
                    if curr_num == 1
                        continue
                    end
                    while ~group_check
                        % grouping
                        center_distances = zeros(1, 3);
                        group_amount = 2;   % set how many groups you want (debugging)
                        dot_amounts = [3, 3];   % set how many dots in each group (debugging)
                        % groups should have equal distance to each other, so condition
                        % for >2 groups
                        group_radius = .2;
                        min_group_distance = rad_back(1) * .8;
                        group_centers = zeros(group_amount, 2);
                        group_center_limit = max(max(x * rad_back(1), y * rad_back(2))) ...
                            - (group_radius * scaling) * 1.6;

                        % set first group
                        alpha_1 = 2 * pi * rand(1, 1);
                        group_centers(1, 1) = sin(alpha_1) * group_center_limit;
                        group_centers(1, 2) = cos(alpha_1) * group_center_limit;

                        for group = 2:group_amount
                            % set angle
                            alpha = alpha_1 - ((2 * pi) / group_amount) * (group - 1);
                            group_centers(group, 1) = sin(alpha) * group_center_limit;
                            group_centers(group, 2) = cos(alpha) * group_center_limit;
                            center_distances(group) = sqrt(group_centers(group, 1) .^2 + group_centers(group, 2) .^2);
                        end
                        % validation: group within background
                        % get eucledian distance of center that must be
                        % smoller than group_distance
                        % validation: equal & enough distance among group centers
                        % get distances among group centers
                        [group_distances, ~] = get_distances(group_centers, min_group_distance);
                        % validation: subgroup distances equal
                        % generate dots within each group
                        dot_pos = zeros(sum(dot_amounts), 2);
                        dot_id = zeros(sum(dot_amounts), 2);
                        dot_counter = 0;
    
                        % iterate over each subgroup
                        for group = 1:group_amount
                            dot_counter = dot_counter + 1;
                            % set angle of first dot randomly
                            alpha_1 = 2 * pi * rand(1, 1);
                            % convert to cartesian coordinates
                            dot_pos(dot_counter, 1) = group_centers(group, 1) + sin(alpha_1) * (subgrouprad + dot_radii(dot_counter));
                            dot_pos(dot_counter, 2) = group_centers(group, 2) + cos(alpha_1) * (subgrouprad + dot_radii(dot_counter));
    
                            % add dot ID
                            dot_id(dot_counter, 1) = dot_counter;
                            dot_id(dot_counter, 2) = group;
    
                            % get angles of remaining dots & convert to
                            % cartesian coordinates
                            for dot = 2:dot_amounts(group)
                                dot_counter = dot_counter + 1;
                                % get angle
                                alpha = alpha_1 - ((2 * pi) / dot_amounts(group)) * (dot - 1);
                                % get distance to first dot
                                total_distance = dot_radii(dot_counter - 1) + dot_radii(dot_counter) + subgrouprad;
                                dot_pos(dot_counter, 1) = group_centers(group, 1) + (sin(alpha) * (subgrouprad + dot_radii(dot_counter)));
                                dot_pos(dot_counter, 2) = group_centers(group, 2) + (cos(alpha) * (subgrouprad + dot_radii(dot_counter)));
                                % add dot ID
                                dot_id(dot_counter, 1) = dot_counter;
                                dot_id(dot_counter, 2) = group;                         
                            end
                        end
                        group_wise_distances = {};
    
                        % get distances between dots for each group
                        for group = 1:group_amount
                            [row, ~] = find(dot_id(:, 2) == group);
                            [dist, ~] = ...
                                get_distances(dot_pos(row, :), 0);
                            group_wise_distances{end + 1} = dist - (sum(dot_radii(row)));
                        end
    
                        % valdiation: same dot distances for each group among
                        % the dots
                        % validation: groups have the same distance
                        group_wise_distances = vertcat(group_wise_distances{:});
    
                        if all(isapprox(group_wise_distances(:), group_wise_distances(end), "verytight")) ...
                                && all(isapprox(group_distances(:), group_distances(end), "verytight"))
                            group_check = true;
                        end
                        group_check = true;
                    end
            end
            % validation: density control: control stimuli
            dot_density = density(dot_pos(:, 1), dot_pos(:, 2));
            disp(mean(dot_density))
            if mean(dot_density) <= density_limit_spec(2) && ...
                    mean(dot_density) >= density_limit_spec(1)
                check = true;
            end
            check = true;
        end
        if to_break
            break
        end

        plot_dot_pos = dot_pos;
        % plot the dots
        fig = plot_stim_pattern(angle_steps, winsize, rad_back, back_circ_c, ...
            plot_dot_pos, dot_radii, scaling);

        % temporary: mark group centers
        for group = 1:group_amount
            plot(group_centers(group, 1), group_centers(group, 2), "x", "MarkerEdgeColor", "green")
            cc = fill(x * group_radius * scaling + group_centers(group, 1), ...
                y * group_radius * scaling + group_centers(group, 2), ...
                [0 0 0], "EdgeColor", "magenta");
            cc.FaceColor = "none";
        end

        % save
        filename = strcat(stim_type, strcat(num2str(curr_num), num2str(img)), '.bmp');
        saveas(fig, strcat(stim_path, filename), 'bmp')  % save the figure
        close

        counter = counter + 1;  % for progressbar
        %progressbar(counter, 40)
    end
    if to_break
        break
    end
end
