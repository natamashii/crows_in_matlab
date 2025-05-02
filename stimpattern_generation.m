clear
clc 
close all

% main script

% sort code bit: move hardcoded variables to top
% maybe try to work around hardcoded variables
% find a way to make things faster: dot position is slowing things down
% ask lena again about density range
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
stim_type = input(prompt, "s");
counter = 0;    % for progressbar
amount_img = 4;     % defines how many versions of one condition should be generated

% numerosities of interest
numbers = 1:10;
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

% Pre allocation


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

            % Dot Positions
            % validation 1: dot inside background
            for dot = 1:curr_num
                dot_pos_limit = max(max(x * rad_back(1), y * rad_back(1))) ...
                    - 2 * (dot_radii(dot) * scaling) * 1.4;
                dot_pos(:, dot) = (2 * dot_pos_limit) * (rand(2, 1) - .5);
            end
            % validation 2: intra-dot distances
            % get distance among each dot
            d_x = bsxfun(@minus, dot_pos(1, :)', dot_pos(1, :));    % x coordinates distance
            d_y = bsxfun(@minus, dot_pos(2, :)', dot_pos(2, :));    % y coordinates distance
            distances = sqrt(d_x .^2 + d_y .^2);    % get euclidian distance among each dot
            all_distances{img, stimulus} = distances;
            % identify minimum distance as two times the biggest size 
            if curr_num > 1
                biggest_size = max(dot_radii) * 2.2;
                min_distance = biggest_size; % minimum distance threshold
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
            else
                check = true;
            end
            
        end
        if to_break
            break
        end
        % plot the dots
        [fig, x, y] = plot_backcircle(angle_steps, winsize, rad_back, back_circ_c);

        for dot = 1:curr_num
            fill(x * dot_radii(dot) + dot_pos(1, dot), ...
                y * dot_radii(dot) * scaling + dot_pos(2, dot), ...
                [0 0 0], "EdgeColor", [0 0 0]);
        end

        % save the shit
        filename = strcat(stim_type, strcat(num2str(curr_num), num2str(img)), '.bmp');
        saveas(fig, strcat(stim_path, filename), 'bmp')  % save the figure
        close

        counter = counter + 1;
        progressbar(counter, 40)
    end
    if to_break
        break
    end
end
