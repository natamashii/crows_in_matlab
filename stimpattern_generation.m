clear
clc 
close all

% main script
% nums 1-3 in groups also as groups???
% curr_num = 1 will always be the same so I can simply just put it before
% the switch case thing

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
stim_path = 'D:\MasterThesis\analysis\Stimuli_creation\';

% demanding specification of stimulus type to generate (case-insensitive)
prompt = 'Create set of Standard (s) or Control (c) stimuli? ';
stim_type = input(prompt, "s");
prompt = 'Which Pattern to create? 1 - random, 2 - additive, 3 - multiplicative ';
pattern_type = "P" + input(prompt, "s");
counter = 0;    % for progressbar
amount_img = 3;     % defines how many versions of one condition should be generated

% numerosities of interest
numbers = 2:15;
check = false;  % boolean that toggles if every control is fulfilled
to_break = false;   % boolean that toggles in case of mistyping stimulus type

% figure specifications
set(0, "defaultfigurecolor", [0 0 0])
scaling = 1.55;   % factor for stretching lovely picture (to be displayed as circle in lateralization setup)
winsize = 170;  % needed for figure specificiation: 136 for home PC, 170 for work PC

% background circle specifications
rad_back = 1;  % radius for x-axis (1. dim) and y-axis (2. dim)
back_circ_c = [.5, .5, .5];     % grey colours
angle_steps = 360;  % fine tuning of background circle

% dot specifications
rad_dot_limit = [.05, .11];   % radius limitations (based on control)
area_limit = [.18, .2];   % limits of cumulative area of the dots
density_limit = [.77, .83; .69, 20];

% group radii: (1=1, 2=2, 3=3, 4=2*2, 5=2+3, 6=3*2)
gr_dots_m = {[1], [2], [3], [2; 2], [2; 3], [2; 2; 2]};
gr_rad_m = {[.14], [.14], [.14], [.14; .14], [.14; .14], [.14; .14; .14]};
% group radii: (1=1, 2=2, 3=2+1, 4=3+1, 5=2+2+1, 6=3+2+1)
gr_dots_a = {[1], [2], [2; 1], [3; 1], [2; 2; 1], [3; 2; 1]};
gr_rad_a = {[.14], [.14], [.14; .14], [.14; .14], [.14; .14; .14], [.14; .14; .14]};

% generate fixation stimulus (b_grey)
[b_grey, x, y] = plot_backcircle(angle_steps, winsize, rad_back, back_circ_c);
filename = 'B_grey.bmp';

f = getframe(gcf);
[img, ~] = frame2im(f);
imwrite(img, strcat(stim_path,filename));  % save the figure
close

% iterate over amount of desired stimuli
for stimulus = 1:size(numbers, 2)
    curr_num = numbers(stimulus);
    for img = 1:amount_img
        % Pre definitions
        check = false;
        size_check = false;
        dot_check = false;
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
                dot_radii = dot_radii.';
                density_limit_spec = density_limit(2, :);
            else
                fprintf("Error. You probably mistyped the stimulus type: ")
                fprintf(stim_type)
                to_break = true;
                break
            end

            % Dot Positions
            if curr_num == 1
                % validation 1: dot inside background circle
                dot_pos_limit = max(max(x * rad_back, y * rad_back)) ...
                    - (2 * dot_radii) * scaling;
                dot_pos = (2 * dot_pos_limit) * (rand(2, 1) - .5);
                break
            end
            switch pattern_type
                case {"Pr", "PR"}     % randomized
                    while ~dot_check
                        % Dot Positions
                        % validation 1: dot inside background circle
                        for dot = 1:curr_num
                            dot_pos_limit = max(max(x * rad_back, y * rad_back)) ...
                                - (2 * dot_radii(dot)) * scaling;
                            dot_pos(dot, :) = (2 * dot_pos_limit) * (rand(2, 1) - .5);
                        end

                        if curr_num > 1
                            % validation 2: no overlap between dots
                            min_dot_distance = max(dot_radii) * 2.5;
                            [dot_distances, overlap_check] = ...
                                get_distances(dot_pos, min_dot_distance);

                            % cumulative density control
                            mean_distance = mean(dot_distances, "all");
                            if (mean_distance >= density_limit_spec(1) && ...
                                    mean_distance <= density_limit_spec(2) ...
                                    && overlap_check)
                                dot_check = true;
                                plot_dot_pos = dot_pos;
                            else
                                dot_check = false;
                            end
                        else
                            dot_check = true;
                        end
                    end
                    group_check = true;
                    pattern_type = "PR";
                case "P1"   % equal distances
                    while ~dot_check
                        % Dot Positions
                        % validation 1: dot inside background circle
                        for dot = 1:curr_num
                            dot_pos_limit = max(max(x * rad_back, y * rad_back)) ...
                                - (2 * dot_radii(dot)) * scaling;
                            dot_pos(dot, :) = (2 * dot_pos_limit) * (rand(2, 1) - .5);
                        end

                        if curr_num > 1
                            % validation 2: no overlap between dots
                            min_dot_distance = max(dot_radii) * 2.5;
                            [dot_distances, overlap_check] = ...
                                get_distances(dot_pos, min_dot_distance);

                            % validation: equal distances among each dot
                            equv_control = equal_distances(dot_pos, dot_radii, density_limit_spec);
                            if equv_control && overlap_check
                                dot_check = true;
                                plot_dot_pos = dot_pos;
                            else
                                dot_check = false;
                            end
                        else
                            dot_check = true;
                        end
                    end
                    group_check = true;
                case "P2"   % additive
                    group_check = false;
                    % set grouping way & how dots should be grouped
                    group_radii = gr_rad_a{curr_num};
                    dot_groups = gr_dots_a{curr_num};
                    % change density interval when only one group
                    if size(dot_groups, 1) == 1
                        density_limit_spec = density_limit_spec(:) - .51;
                    end
                case "P3"   % multiplicative
                    group_check = false;
                    % set grouping way & how dots should be grouped
                    group_radii = gr_rad_m{curr_num};
                    dot_groups = gr_dots_m{curr_num};
                    % change density interval when only one group
                    if size(dot_groups, 1) == 1
                        density_limit_spec = density_limit_spec(:) - .51;
                    end
                otherwise
                    fprintf("Error. This is not a valid pattern type: ")
                    fprintf(pattern_type)
                    to_break = true;
                    break
            end
            while ~group_check
                % generate grouped dots
                [group_distances, group_wise_distances, dot_pos, group_centers] = ...
                    grouped_dots(dot_groups, group_radii, dot_radii, scaling, rad_back, x, y);
    
                % validation: groups have approximately same distance to one
                % another
                if all(isapprox(group_distances(:), group_distances(end), RelativeTolerance=1e-2))
                    group_check = true;
                end
            end

            % validation: density control: control stimuli
            dot_density = density(dot_pos(:, 1), dot_pos(:, 2));
            if (mean(dot_density) - mean(dot_radii)) >= density_limit_spec(1) && ...
                    (mean(dot_density) - mean(dot_radii)) <= density_limit_spec(2)
                check = true;
            elseif curr_num == 1

            elseif pattern_type == "P1"
                check = true;
            end
            if pattern_type == "PR"
                if mean(dot_density) >= density_limit_spec(1) && ...
                    mean(dot_density) <= density_limit_spec(2)
                    check = true;
                elseif curr_num == 1
                    check = true;
                end
            end
            %check = true;
        end
        if to_break
            break
        end

        % plot the dots
        fig = plot_stim_pattern(angle_steps, winsize, rad_back, back_circ_c, ...
            dot_pos, dot_radii);

        % debugging: plot generated groups
        % if curr_num > 1
        %     for group = 1:size(dot_groups, 1)
        %         group_plot = plot(group_centers(group, 1), group_centers(group, 2), "x");
        %         group_plot.MarkerEdgeColor = "green";
        %         group_circle = fill(group_centers(group, 1) + (group_radii(group) * x), ...
        %             group_centers(group, 2) + (group_radii(group) * y), [0 0 0]);
        %         group_circle.FaceColor = "none";
        %         group_circle.EdgeColor = "magenta";
        %     end
        % end

        % save

        filename = strcat(stim_type, '_', pattern_type, '_', strcat(num2str(curr_num), num2str(img - 1)), '.bmp');
        f = getframe(gcf);
        [img, ~] = frame2im(f);
        imwrite(img, strcat(stim_path,filename));   % save figure

        close

        counter = counter + 1;  % for progressbar
        progressbar(counter, 42)
    end
    if to_break
        break
    end
end
