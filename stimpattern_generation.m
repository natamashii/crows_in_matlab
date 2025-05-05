clear
clc 
close all

% main script

% add groupitizing function
% ideas: spatial grouping, colour grouping, temporal grouping 

% sort code bit: move hardcoded variables to top
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
scaling = 1.2;   % factor for stretching lovely picture (to be displayed as circle in lateralization setup)
winsize = 209;  % needed for figure specificiation

% background circle specifications
rad_back = [1, 1];  % radius for x-axis (1. dim) and y-axis (2. dim) in []
rad_back(2) = rad_back(2) * scaling;    % plot actually an ellipse (will be displayed as circle in lateralization setup)
back_circ_c = [.5, .5, .5];     % grey colour
angle_steps = 360;  % fine tuning of background circle
% background circle generation
angles = 0 : (2 * pi)/(angle_steps - 1) : 2*pi; % all angle values for full circle
x = sin(angles);    % x values for unit circle
y = cos(angles);    % y values for unit circle

% dot specifications
rad_dot_limit = [.08, .2];   % radius limitations in [] (based on control)
min_dist = .01;  % minimal intra-dot distance in []
area_limit = [.18, .2];   % limits of cumulative area of the dots
density_limit = [.8, .85; .01, 20];

pattern = "grouped";

% generate fixation stimulus (b_grey)
b_grey = figure("Units", "pixels", "Position", [0 0 winsize winsize]);
hold on
axis equal off  

backcircle = fill(x * rad_back(1), y * rad_back(2), back_circ_c);
backcircle.EdgeColor = back_circ_c;

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
        dot_pos = zeros(2, curr_num);
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
                            - 2 * (dot_radii(dot) * scaling) * 1.4;
                        dot_pos(:, dot) = (2 * dot_pos_limit) * (rand(2, 1) - .5);
                    end
        
                    % validation: no overlap between dots
                    % get distance among each dot
                    d_x = bsxfun(@minus, dot_pos(1, :)', dot_pos(1, :));    % x coordinates distance
                    d_y = bsxfun(@minus, dot_pos(2, :)', dot_pos(2, :));    % y coordinates distance
                    distances = sqrt(d_x .^2 + d_y .^2);    % get euclidian distance among each dot
                    
                    % minimum distance = 2 x biggest size and bit more
                    min_dot_distance = max(dot_radii) * 2.2;    
                    % sort distances
                    sort_distances = sort(distances, 1, "ascend");
                    % remove first line (distance of a dot to itself, aka 0)
                    sort_distances = sort_distances(2:end, :);
        
        
                    if ~all(sort_distances(:) >= min_distance)
                        check = false;
                    else
        
                        % cumulative density control: mean of it
                        mean_distance = mean(sort_distances, "all");
                        if (mean_distance > density_limit_spec(1) && ...
                                mean_distance < density_limit_spec(2))
                            check = true;
                        else
                            check = false;
                        end
                    end
                case "grouped"
                    if curr_num > 1
                        % grouping
                        group_amount = 2;   % set how many groups you want (debugging)
                        dot_amounts = [3, 3];   % set how many dots in each group (debugging)
                        % groups should have equal distance to each other, so condition
                        % for >2 groups
                        group_distance = density_limit_spec(2) * 2; 
                        group_radius = group_distance / 2;
                        group_centers = zeros(2, group_amount);
                        group_center_limit = max(max(x * rad_back(1), y * rad_back(1))) ...
                                - 2 * (group_radius * scaling) * 1.4;
                        for group = 1:group_amount
                            group_centers(:, group) = (2 * group_center_limit) * (rand(2, 1) - .5);
                        end
                        % validation: equal & enough distance among group centers
                        % get distances among group centers
                        d_x_group = bsxfun(@minus, group_centers(1, :)', group_centers(1, :));
                        d_y_group = bsxfun(@minus, group_centers(2, :)', group_centers(2, :));
                        distances_group = sqrt(d_x_group .^2 + d_y_group .^2);
                        sort_distances_group = sort(distances_group, 1, "ascend");
                        sort_distances_group = sort_distances_group(2:end, :);
            
                        if ~all(sort_distances_group(:) >= group_distance)
                            check = false;
                            continue
                        end
                        % generate dot positions in each group
                        all_dot_distances = cell(1, group_amount);
                        all_dot_pos = cell(1, group_amount);
                        for group = 1:group_amount
                            group_check = false;
                            while ~group_check
                                des_dots = dot_amounts(group);
                                dot_pos = zeros(2, des_dots);
                                % generate random position within current group
                                dot_scale_limit = group_center_limit;
                                for dot = 1:des_dots
                                    dot_pos_scales = (2 * dot_scale_limit) * (rand(2, 1) - .5);
                                    dot_pos(1, dot) = group_centers(1, group) * dot_pos_scales(1);
                                    dot_pos(2, dot) = group_centers(2, group) * dot_pos_scales(2);
                                end
                                % validation: dots do not overlap
                                % get distance among each dot
                                d_x = bsxfun(@minus, dot_pos(1, :)', dot_pos(1, :));    % x coordinates distance
                                d_y = bsxfun(@minus, dot_pos(2, :)', dot_pos(2, :));    % y coordinates distance
                                distances = sqrt(d_x .^2 + d_y .^2);    % get euclidian distance among each dot
                                % minimum distance = 2 x biggest size and bit more
                                min_dot_distance = max(dot_radii) * 2.2;
                                % sort distances
                                sort_distances = sort(distances, 1, "ascend");
                                % remove first line (distance of a dot to itself, aka 0)
                                sort_distances = sort_distances(2:end, :);
                                if all(sort_distances(:) >= min_distance)
                                    group_check = true;
                                    all_dot_distances{group} = distances;
                                    all_dot_pos{group} = dot_pos;
                                end
                            end
                        end
                        % validation: overall density is fine
                        c2 = cellfun(@(x) [x{:}], all_dot_distances, 'un',0); % convert to cell array of numeric array
                        [m, tf] = padcat(c2{:}); % concatenate, pad rows with NaNs
                        all_dot_pos = vertcat(all_dot_pos{:});
                        dot_densities = density(all_dot_pos(1, :), all_dot_pos(2, :));
                        if (mean(dot_densities) >= density_limit_spec(1) && ...
                                mean(dot_densities) <= density_limit_spec(2))
                            check = true;
                        else
                            check = false;
                        end 
                    end
            end
        end
        if to_break
            break
        end
        % plot the dots
        [fig, x, y] = plot_backcircle(angle_steps, winsize, rad_back, back_circ_c);

        for dot = 1:curr_num
            fill(x * dot_radii(dot) + all_dot_pos(1, dot), ...
                y * dot_radii(dot) * scaling + all_dot_pos(2, dot), ...
                [0 0 0], "EdgeColor", [0 0 0]);
        end

        % save
        filename = strcat(stim_type, strcat(num2str(curr_num), num2str(img)), '.bmp');
        saveas(fig, strcat(stim_path, filename), 'bmp')  % save the figure
        close

        counter = counter + 1;  % for progressbar
        progressbar(counter, 40)
    end
    if to_break
        break
    end
end
