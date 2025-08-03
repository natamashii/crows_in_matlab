function [ax, leg_patch, leg_label] = plot_first(numbers, values, err_down, err_up, patterns, curr_exp, colours, plot_font)

% function to create variations of the first plot

% pre allocation
leg_patch = [];
leg_label = string();

% iterate over patterns
for pattern = 1:length(patterns{curr_exp})
    hold on
    ax = gca;
    ax.Color = [1 1 1];     % set background colour to white
    ax.XColor = "k";    % set colour of axis to black
    ax.YColor = "k";    % set colour of axis to black
    ax.FontWeight = 'bold';
    ax.XAxis.FontSize = plot_font;  % set fontsize of ticks
    ax.YAxis.FontSize = plot_font;  % set fontsize of ticks
    xlabel(ax, 'Sample Numerosity', 'FontWeight', 'bold');    % set x-axis label
    ax.XTick = numbers';
    ax.XTickLabel = num2str(numbers');
    ax.XLim = [min(numbers) - .5 max(numbers) + .5];
    
    % plot error
    err_plot = errorbar(numbers, values(pattern, :), err_down(pattern, :), err_up(pattern, :));
    err_plot.Color = colours{pattern};
    err_plot.CapSize = 5;
    err_plot.LineWidth = 1;

    % plot mean/median
    plot_pattern = plot(numbers, values(pattern, :));
    plot_pattern.LineStyle = "-";
    plot_pattern.LineWidth = 1;
    plot_pattern.Marker = "o";
    plot_pattern.Color = colours{pattern};
    plot_pattern.MarkerFaceColor = colours{pattern};
    plot_pattern.MarkerEdgeColor = "none";

    % for legend
    leg_patch(end + 1) = plot_pattern;
    leg_label(pattern) = patterns{curr_exp}(pattern);

end

end