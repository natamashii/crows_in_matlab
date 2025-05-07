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
%stim_path = 'D:\MasterThesis\analysis\Stimuli_creation\a_bunch_of_sets\';
stim_path = '/home/nati/Desktop/test';

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
density_limit = [.8, .85; .01, 20];
subgrouprad = .1;

pattern = "random";

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
                    [dot_distances, check] = ...
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
                    if curr_num > 1
                        continue
                    end
                    while ~group_check
                        % grouping
                        center_distances = zeros(1, 3);
                        group_amount = 3;   % set how many groups you want (debugging)
                        dot_amounts = [2, 2, 2];   % set how many dots in each group (debugging)
                        % groups should have equal distance to each other, so condition
                        % for >2 groups
                        group_radius = .3;
                        min_group_distance = rad_back(1) * .8;
                        group_centers = zeros(group_amount, 2);
                        group_center_limit = max(max(x * rad_back(1), y * rad_back(2))) ...
                            - (group_radius * scaling) * 1;
                        for group = 1:group_amount
                            group_centers(group, :) = group_center_limit + (-group_center_limit - group_center_limit) .* rand(2, 1);
                            center_distances(group) = sqrt(group_centers(group, 1) .^2 + group_centers(group, 2) .^2);

                        end
                        % validation: group within background
                        % get eucledian distance of center that must be
                        % smoller than group_distance
                        % validation: equal & enough distance among group centers
                        % get distances among group centers
                        [group_distances, ~] = get_distances(group_centers, min_group_distance);
                        % validation: subgroup distances equal
                        if ~all(group_distances) == min_group_distance
                            group_check = false;
                        end

                    end
                    
                    % generate dots within each group
                    dot_pos = zeros(sum(dot_amounts), 2);
                    dot_id = zeros(sum(dot_amounts), 1);
                    group_wise_distances = {};
                    dot_counter = 1;

                    % iterate over each subgroup
                    for group = 1:group_amount
                        % set angle of first dot randomly
                        alpha_1 = randi(361) - 1;
                        % convert to cartesian coordinates
                        dot_pos(dot_counter, 1) = group_centers(group, 1) + sin(alpha_1);
                        dot_pos(dot_counter, 2) = group_centers(group, 2) + cos(alpha_1);

                        % add dot ID
                        dot_id(dot_counter) = dot_counter;

                        % get angles of remaining dots & convert to
                        % cartesian coordinates
                        for dot = 2:dot_amounts(group)
                            dot_counter = dot_counter + 1;
                            % get angle
                            alpha = alpha_1 - (360 / dot_amouns(group)) * (dot - 1);
                            % get distance to first dot
                            total_distance = dot_radii(dot_counter - 1) + dot_radii(dot_counter) + subgrouprad;
                            dot_pos(dot_counter, 1) = group_centers(group, 1) + sin(alpha) * total_distance;
                            dot_pos(dot_counter, 2) = group_centers(group, 2) + cos(alpha) * total_distance;
                            % add dot ID
                            dot_id(dot_counter) = dot_counter;

                            % get distance to first dot
                            [group_wise_distances{end + 1}, ~] = ...
                                get_distances(dot_pos, 0);
                        end


                        % validation: density control
                        % they all need to have the same distance

                    end







                        % d_x_group = bsxfun(@minus, group_centers(1, :)', group_centers(1, :));
                        % d_y_group = bsxfun(@minus, group_centers(2, :)', group_centers(2, :));
                        % distances_group = sqrt(d_x_group .^2 + d_y_group .^2);
                        % sort_distances_group = sort(distances_group, 1, "ascend");
                        % sort_distances_group = sort_distances_group(2:end, :);
                        % 
                        % if all(sort_distances_group(:) >= group_distance) ...
                        %         & all(center_distances(:) <= group_center_limit)
                        %     group_check = true;
                        % 
                        % end
                        % 
                        % dot_counter = 1;
                        % dot_pos = zeros(2, 6);
                        % for group = 1:group_amount
                        %     % get rad
                        %     alpha = randi(361) - 1;
                        %     total_distance = dot_radii(dot_counter) + dot_radii(dot_counter + 1) + subgrouprad;
                        %     % convert it to cartesian coordinates
                        %     dot_pos(1, dot_counter) = group_centers(1, group) + sin(alpha) * total_distance;
                        %     dot_pos(2, dot_counter) = group_centers(2, group) + cos(alpha) * total_distance;
                        %     dot_pos(1, dot_counter + 1) = group_centers(1, group) - sin(alpha) * total_distance;
                        %     dot_pos(2, dot_counter + 1) = group_centers(1, group) - cos(alpha) * total_distance;
                        %     dot_counter = dot_counter + 2;
                        % end
                        % 














                        % iterate over each subgroup & identify dot
                        % positions
                        % for group = 1:group_amount
                        % %
                        % % end
                        % fprintf("groups formed")
                        % alldots = zeros(2, 6);
                        % couter = 1;
                        % for group = 1:group_amount
                        %     dots = zeros(2, 2);
                        %     dotcheck = false;
                        %     while dotcheck == false
                        %         for dot = 1:2
                        %             dotct = group_radius + (-group_radius - group_radius) .* rand(2, 1);
                        %             dots(:, dot) = group_centers(:, group) .* dotct;
                        % 
                        %         end
                        % 
                        % 
                        %         d_x = bsxfun(@minus, dots(1, :)', dots(1, :));    % x coordinates distance
                        %         d_y = bsxfun(@minus, dots(2,:)', dots(2, :));    % y coordinates distance
                        %         distances = sqrt(d_x .^2 + d_y .^2);    % get euclidian distance among each dot
                        %         sort_distances = sort(distances, 1, "ascend");
                        %         % remove first line (distance of a dot to itself, aka 0)
                        %         sort_distances = sort_distances(2:end, :);
                        %         if all(sort_distances == (dot_radii(couter) + dot_radii(couter + 1) + subgrouprad))
                        %             alldots(:, couter) = dots(:, 1);
                        %             alldots(:, couter+1) = dots(:, 2);
                        %             dotcheck = true;
                        %         end
                        %     end
                        %     couter = couter + 2;
                        % end
                        % fprintf("dots formed")
                        % 
                        % check = true;



                    %     % generate dot positions in each group
                    %     all_dot_distances = cell(1, group_amount);
                    %     all_dot_pos = cell(1, group_amount);
                    %     for group = 1:group_amount
                    %         group_check = false;
                    %         while ~group_check
                    %             des_dots = dot_amounts(group);
                    %             dot_pos = zeros(2, des_dots);
                    %             % generate random position within current group
                    %             dot_scale_limit = group_center_limit;
                    %             for dot = 1:des_dots
                    %                 dot_pos_scales = (2 * dot_scale_limit) * (rand(2, 1) - .5);
                    %                 dot_pos(1, dot) = group_centers(1, group) * dot_pos_scales;
                    %                 dot_pos(2, dot) = group_centers(2, group) * dot_pos_scales;
                    %             end
                    %             % validation: dots do not overlap
                    %             % get distance among each dot
                    %             d_x = bsxfun(@minus, dot_pos(1, :)', dot_pos(1, :));    % x coordinates distance
                    %             d_y = bsxfun(@minus, dot_pos(2, :)', dot_pos(2, :));    % y coordinates distance
                    %             distances = sqrt(d_x .^2 + d_y .^2);    % get euclidian distance among each dot
                    %             % minimum distance = 2 x biggest size and bit more
                    %             min_dot_distance = max(dot_radii) * 2.2;
                    %             % sort distances
                    %             sort_distances = sort(distances, 1, "ascend");
                    %             % remove first line (distance of a dot to itself, aka 0)
                    %             sort_distances = sort_distances(2:end, :);
                    %             if all(sort_distances(:) >= min_dot_distance)
                    %                 group_check = true;
                    %                 all_dot_distances{group} = distances;
                    %                 all_dot_pos{group} = dot_pos;
                    %             end
                    %         end
                    %     end
                    %     % validation: overall density is fine
                    %     c2 = cellfun(@(x) x(:), all_dot_distances, 'un', 0); % convert to cell array of numeric array
                    %     [all_dot_pos, tf] = padcat(c2{:}); % concatenate, pad rows with NaNs
                    %     dot_densities = density(all_dot_pos(:, 1), all_dot_pos(:, 2));
                    %     if (mean(dot_densities) >= density_limit_spec(1) && ...
                    %             mean(dot_densities) <= density_limit_spec(2))
                    %         check = true;
                    %         plot_dot_pos = all_dot_pos;
                    %     else
                    %         check = false;
                    %     end 
                    % 
                     
            end
        end
        if to_break
            break
        end

        plot_dot_pos = alldots;
        % plot the dots
        fig = plot_stim_pattern(angle_steps, winsize, rad_back, back_circ_c, ...
            plot_dot_pos, dot_radii, scaling);

        % temporary: mark group centers
        for group = 1:size(group_centers, 2)
            plot(group_centers(1, group), group_centers(2, group), "x", "MarkerEdgeColor", "green")
            cc = fill(x * group_radius * scaling + group_centers(1, group), ...
                y * group_radius * scaling + group_centers(2, group), ...
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
