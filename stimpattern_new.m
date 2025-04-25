clear
clc
close all

% TODO: range 1-10 for testing, I guess factors can be ignored??
% bigger dots: take care of smaller pixelic resolution
% Lena density control: mean of all inter-dot distances (might be more
% computationally efficient)

% path to save stimuli pattern
stim_path = 'D:\MasterThesis\analysis\Stimuli_creation\ver_25042025\'; 

samples = {1:10, 4:13, 5:14, 6:15, 7:16, 8:17}; % potential samples to use
%factors = [0.316, 0.56, 1, 1.77, 3.16]; % factors to generate nonmatches
factors = [1, 1, 1, 1, 1];
n_match = 4;
n_nonmatch = 1;
stim_type = 'C';     % toggle to either generate standard or control stimuli

samples_to_use = 1; % set value to decide which sample to use for stimuli generation 

% Create Stimuli 
% specify window
winsize_x = 418;
winsize_y = 418;

% specify Dots
dot_rad = .4;
min_dist = .5;
lowcut = .01;
highcut = 20;

% specify control
total_area = 2;
min_dist_control = .2;
lowcut_control = 4;
highcut_control = 4.2;

% Specify background
xbig = 5.5;
ybig = 5.5;
rbig = 5;
backcolour = [.5, .5, .5];
edgecolour = [.5 .5 .5];

% Circle generation 
t = (0:2 * pi / 200:2 * pi);
x = sin(t);
y = cos(t);

% get the sample
current_sample = samples{samples_to_use};
nums = unique(current_sample);

% make B_grey.bmp
b_grey = figure();
hold on
pos = [0, 0, winsize_x/2, winsize_y/2];

b_grey.Position = pos;
set(gcf, 'Color', [0 0 0]);

backcircle = fill(x * rbig + xbig, y * rbig*1.3 + ybig, backcolour);
backcircle.EdgeColor = "none";  % disable white edge around circle
axis equal off

% Take a snapshot HELLO HELLO PLS DEBUG 
f = getframe(gcf);
[image, ~] = frame2im(f);

% save the stimulus pattern
filename = strcat('B_grey.bmp');
imwrite(image, strcat(stim_path, filename));
close all
%%
% iterate over each number to be visualized as stimulus pattern
for d = 1:size(nums, 2)
    curr_num = nums(d);
    % define how many variations to generate
    if ismember(curr_num, current_sample)
        amount_img = n_match;
    else
        amount_img = n_nonmatch;
    end
    % create the stimulus
    for img = 1:amount_img
        fig = figure();
        hold on
        pos = [0, 0, winsize_x/2, winsize_y/2];

        fig.Position = pos;
        set(gcf, 'Color', [0 0 0]);
        % background circle
        hold on
        backcircle = fill(x * rbig + xbig, (y * rbig*1.3 + ybig), backcolour);
        backcircle.EdgeColor = "none";  % disable white edge around circle
        % toggle axis off 
        axis equal off
        
        % get random dot position in [0, 1], rescaled within background
        % circle
        dot_pos_limit = max(max(x * rbig + xbig, y * rbig + ybig)) - 2 * dot_rad;

        dot_pos = dot_pos_limit * rand(2, curr_num);

        % control of dots truly lying within background circle
        % set threshold here already cuz I guess this needs to be
        % hardcoded...
        threshold = rbig - 1 * dot_rad;
        % do the control
        dot_pos = rand_dot_pos(dot_pos, dot_rad, threshold, dot_pos_limit, xbig, ybig, min_dist);
        aa.Units = "pixels";
        % identify individual dot sizes
        if stim_type == 'C'
            sizes = calc_area(total_area, curr_num);
            % copied from Lena, gotta generalize rand_dot_pos first
            for dot = 1:curr_num
                check = false;
                while ~check
                    distance = sqrt(abs(dot_pos(1, dot) - xbig)^2 + ...
                        abs(dot_pos(2, dot) - ybig)^2);
                    distance = distance + 2 * sizes(dot);
                    if distance < min_dist
                        dot_pos(:, dot) = dot_pos_limit * rand(2, 1);
                    else
                        check = true;
                    end
                end
            end
        elseif stim_type == 'S'
            sizes = ones(curr_num, 1) * dot_rad;
        end

        % density control
        if curr_num > 1
            dense = density(dot_pos(1, 1:curr_num), dot_pos(2, 1:curr_num));
            if not (mean(dense) > lowcut && mean(dense) < highcut) && ...
                (min(dense) > min_dist)
                continue
            end
        end

        


        % plotting
        % Lena Approach
        % iterate over each dot
        for dot = 1:curr_num
            fill(x * sizes(dot) + dot_pos(1, dot), ...
                y * sizes(dot) + dot_pos(2, dot), ...
                [0 0 0], "EdgeColor", [0 0 0]);
        end
        % My approach of avoiding another for loop :(

        % Take a snapshot HELLO HELLO PLS DEBUG 
        f = getframe(gcf);
        [image, ~] = frame2im(f);

        % save the stimulus pattern
        filename = strcat(stim_type, strcat(num2str(curr_num), num2str(img)), '.bmp');
        imwrite(image, strcat(stim_path, filename));
        close all
    end
    %progressbar(d, size(nums, 2))
    
end
