function [ax, dot_plots, leg_patch, leg_label] = plot_first(numbers, jitter_dots, values, err_down, err_up, patterns, curr_exp, colours, plot_font)

% function to create variations of the first plot

% pre allocation
leg_patch = [];
leg_label = string();
dot_plots = {};

% iterate over patterns
for pattern = 1:length(patterns{curr_exp})
    hold on
    ax = gca;

    % Subplot Adjustments
    ax.Color = [1 1 1];     % set background colour to white
    ax.XColor = "k";    % set colour of axis to black
    ax.YColor = "k";    % set colour of axis to black
    ax.FontWeight = 'bold';
    ax.XAxis.FontSize = plot_font;  % set fontsize of ticks
    ax.YAxis.FontSize = plot_font;  % set fontsize of ticks
    xlabel(ax, 'Sample Numerosity', 'FontWeight', 'bold');    % set x-axis label
    ax.XTick = numbers';
    ax.XTickLabel = num2str(numbers');
    ax.XTickLabelRotation = 0;
    ax.XLim = [min(numbers) - .5 max(numbers) + .5];

    % Adjust x values with some jitter
    x_vals  = numbers + jitter_dots(pattern);
    
    % plot error
    err_plot = errorbar(x_vals, values(pattern, :), err_down(pattern, :), err_up(pattern, :));
    err_plot.LineStyle = "none";
    err_plot.Color = colours{pattern};
    err_plot.CapSize = 5;
    err_plot.LineWidth = 1;

    % plot mean/median
    plot_pattern = plot(x_vals, values(pattern, :));
    plot_pattern.LineStyle = "--";
    plot_pattern.LineWidth = 1;
    plot_pattern.Marker = "o";
    plot_pattern.Color = colours{pattern};
    plot_pattern.MarkerFaceColor = colours{pattern};
    plot_pattern.MarkerEdgeColor = "none";
    dot_plots{end + 1} = plot_pattern;

    % for legend
    leg_patch(end + 1) = plot_pattern;
    leg_label(pattern) = patterns{curr_exp}(pattern);

end

end