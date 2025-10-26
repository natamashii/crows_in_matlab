function plot_lin_reg(lin_reg, x_factor, what_idx, ...
    linestyle, linewidth, colour)

% function to plot linear regression curve 

% set y vals
y_vals = lin_reg{what_idx + 1, 2};

% set x vals
x_vals = (1:length(y_vals)) + x_factor;

% Plot the linear regression curve
plot(x_vals, y_vals, ...
    "LineStyle", linestyle, ...
    "LineWidth", linewidth, ...
    "Color", colour);

end