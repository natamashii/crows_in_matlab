clear
clc
close all

% TODO: range 1-10 for testing, I guess factors can be ignored??
% bigger dots: take care of smaller pixelic resolution
% Lena density control: mean of all inter-dot distances (might be more
% computationally efficient)

% path to save stimuli pattern
stim_path = 'D:\MasterThesis\analysis\Stimuli_creation\ver_23042025\dot_size_0p25\'; 

samples = {1:10, 4:13, 5:14, 6:15, 7:16, 8:17}; % potential samples to use
%factors = [0.316, 0.56, 1, 1.77, 3.16]; % factors to generate nonmatches
factors = [1, 1, 1, 1, 1];
n_match = 4;
n_nonmatch = 1;

samples_to_use = 1; % set value to decide which sample to use for stimuli generation 

% Pre allocation
all_values = zeros(size(samples, 1), 10, size(factors, 1));

for s = 1:size(samples, 2)
    current_sample = samples{s};
    for fact = 1:size(factors, 2)
        current_factor = factors(fact);
        nonmatch = current_sample * current_factor;
        all_values(s, :, fact) = round(nonmatch);
    end
end

% Plot distribution of number frequency of values
to_plot = false;
if to_plot
    fig = figure(1);
    hold on
    for s = 1:size(samples, 2)
        subplot(size(samples, 2), 1, s)
        % identify bin counts
        nbins = size(unique(all_values(s, :, :)), 1);
        histogram(all_values(s, :, :), nbins)
        xlim([0 55])
        ylim([0 12])
    end
    hold off
end

%% Create Stimuli 
% specify window
winsize_x = 267;
winsize_y = 356;

% specify Dots
dot_rad = .25;
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
        % set figure stuff
        %set(groot);
        pos = [0, 0, winsize_x/2, winsize_y/2];
        set(gcf, "Position", pos, "Units", "pixels");

        % background circle
        hold on
        backcircle = fill(x * rbig + xbig, y * rbig + ybig, backcolour);
        backcircle.EdgeColor = "none";
        % toggle axis off 
        axis square off
        
        % get random dot position in [0, 1], rescaled within background
        % circle
        dot_pos_limit = max(max(x * rbig + xbig, y * rbig + ybig)) - 2 * dot_rad;

        dot_pos = dot_pos_limit * rand(2, curr_num); 

        % control of dots truly lying within background circle
        % set threshold here already cuz I guess this needs to be
        % hardcoded...
        threshold = rbig - 2 * dot_rad;
        % do the control
        dot_pos = rand_dot_pos(dot_pos, dot_rad, threshold, dot_pos_limit, xbig, ybig, min_dist);
        
        % Control for density
        %dot_pos = density_control(dot_pos, min_dist);

        % plotting
        % Lena Approach
        % iterate over each dot
        for dot = 1:curr_num
            fill(x * dot_rad + dot_pos(1, dot), ...
                y * dot_rad + dot_pos(2, dot), ...
                [0 0 0], "EdgeColor", [0 0 0]);
        end
        % My approach of avoiding another for loop :(

        % Take a snapshot HELLO HELLO PLS DEBUG 
        f = getframe(gcf);
        [image, ~] = frame2im(f);

        % save the stimulus pattern
        filename = strcat('S', strcat(num2str(curr_num), num2str(img)), '.bmp');
        imwrite(image, strcat(stim_path, filename));
        %reset(groot)
        close all
    end
    %progressbar(d, size(nums, 2))
    
end
