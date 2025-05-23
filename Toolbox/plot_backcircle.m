function [fig, x, y] = plot_backcircle(angle_steps, winsize, rad_back, back_circ_c)

% function to plot background circle for stimuli pattern

% circle generation
angles = 0 : (2 * pi)/(angle_steps - 1) : 2*pi; % all angle values for full circle
x = sin(angles);    % x values for unit circle
y = cos(angles);    % y values for unit circle

% set figure settings
fig = figure("Units", "pixels", "Position", [0 0 winsize winsize]);
hold on
axis equal off

% plot the circle
backcircle = fill(x * rad_back, y * rad_back, back_circ_c);
backcircle.EdgeColor = back_circ_c;
%backcircle.LineWidth = 15;

end