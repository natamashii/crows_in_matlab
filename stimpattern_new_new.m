clear
clc 
close all

% main script

% automatize standard & control
% make it flexible for different samples
% density control
% improve all controls together
% varying sizes in all
% control stimuli: area control, density control
% what is lowcut & highcut in lenas script?
% one for loop with switch case of stim type, otherwise = Error
% maybe add flexibility of original project: ranges


% Pre definition
% path to save stimuli pattern
stim_path = 'D:\MasterThesis\analysis\Stimuli_creation\';

% demanding specification of stimulus type to generate (case-insensitive)
prompt = 'Create set of Standard (s) or Control (c) stimuli?';
stim_type = input(prompt, "s");

% numerosities of interest
numbers = 1:10;

% figure specifications
set(0, 'defaultfigurecolor', [0 0 0])

% background circle specifications
rad_back = [5, 5];  % radius for x-axis (1. dim) and y-axis (2. dim) in []
back_circ_c = [.5, .5, .5];     % grey colour
angle_steps = 360;  % fine tuning of background circle
% background circle generation
angles = 0 : (2 * pi)/(angle_steps - 1) : 2*pi; % all angle values for full circle
x = sin(angles);    % x values for unit circle
y = cos(angles);    % y values for unit circle

% dot specifications
rad_dot = .4;   % radius in []
min_dist = .5;  % minimal intra-dot distance in []



% Pre allocation


% generate fixation stimulus (b_grey)
b_grey = figure();
hold on

backcircle = fill(x * rad_back(1), y * rad_back(2), back_circ_c);
backcircle.EdgeColor = back_circ_c;

axis off  

saveas(b_grey, strcat(stim_path, 'B_grey.bmp'), 'bmp')  % save the figure
close

% iterate over amount of desired stimuli


    % set random dot positions


    % set random dot sizes


    % validation 1: dot inside background


    % validation 2: intra-dot distances 


    % control: constant cumulative density and area


    % save the shit 


