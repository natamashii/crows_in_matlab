function [ax, dot_plots, leg_patch, leg_label] = ...
    plot_first(numerosities, jitter_dots, avg_data, err_down, err_up, ...
    patterns, colours, plot_font, what_analysis, err_type)

% function to create variations of the first plot

% pre definition
capsize = 5;
linewidth = 1;

% pre allocation
leg_patch = [];
leg_label = string();
dot_plots = {};

% iterate over patterns
for pattern = 1:length(patterns)
    hold on
    ax = gca;

    % Subplot Adjustments
    ax.YGrid = "on";    % plot horizontal grid lines
    
    % mark chance level in performance
    if ~strcmp(what_analysis, 'Reaction Times')
        chance_colour = ax.GridAlpha;
        yline(0.5, 'LineStyle', ':', 'Alpha', chance_colour * 3, ...
            'LineWidth', linewidth, 'Color', 'k')
    end
    
    ax.Color = [1 1 1];     % set background colour to white
    ax.XColor = "k";    % set colour of axis to black
    ax.YColor = "k";    % set colour of axis to black
    ax.FontWeight = 'bold';
    ax.XAxis.FontSize = plot_font;  % set fontsize of ticks
    ax.YAxis.FontSize = plot_font;  % set fontsize of ticks
    xlabel(ax, 'Sample Numerosity', 'FontWeight', 'bold');    % set x-axis label
    ax.XTick = numerosities(:, 1);
    ax.XTickLabel = num2str(numerosities(:, 1));
    ax.XTickLabelRotation = 0;
    ax.XLim = [min(numerosities(:, 1)) - .5 max(numerosities(:, 1)) + .5];

    % Adjust x values with some jitter
    x_vals  = numerosities(:, 1) + jitter_dots(pattern);
    
    % plot error
    err_plot = errorbar(x_vals, avg_data(pattern, :)', err_down(pattern, :)', err_up(pattern, :)');
    err_plot.LineStyle = "none";
    err_plot.Color = colours{pattern};
    err_plot.CapSize = capsize;
    err_plot.LineWidth = linewidth;

    % plot mean/median
    plot_pattern = plot(x_vals, avg_data(pattern, :));
    plot_pattern.LineStyle = "--";
    plot_pattern.LineWidth = linewidth;
    plot_pattern.Marker = "o";
    plot_pattern.Color = colours{pattern};
    plot_pattern.MarkerFaceColor = colours{pattern};
    plot_pattern.MarkerEdgeColor = "none";
    dot_plots{end + 1} = plot_pattern;

    % for legend
    leg_patch(end + 1) = plot_pattern;
    leg_label(pattern) = patterns{pattern};

end

% add error type to legend labels
leg_label(end + 1) = err_type;

end