function [fig] = plot_stim_pattern(angle_steps, winsize, rad_back, back_circ_c, dot_pos, dot_radii, scaling)

% function to generate stimulus with dots

% create figure with background circle
[fig, x, y] = plot_backcircle(angle_steps, winsize, rad_back, back_circ_c);

% iterate over each dot to display
for dot = 1:size(dot_radii, 1)
    if size(dot_radii, 1) == 1
        fill(x * dot_radii(dot) * scaling + dot_pos(1), ...
        y * dot_radii(dot) * scaling + dot_pos(2), ...
        [0 0 0], "EdgeColor", [0 0 0]);
    else
        fill(x * dot_radii(dot) * scaling + dot_pos(dot, 1), ...
            y * dot_radii(dot) * scaling + dot_pos(dot, 2), ...
            [0 0 0], "EdgeColor", [0 0 0]);
    end
end

end