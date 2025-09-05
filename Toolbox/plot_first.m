function [ax, dot_plots, leg_patch, leg_label] = ...
    plot_first(numerosities, jitter_dots, avg_data, err_down, err_up, ...
    patterns, colours, plot_font, what_analysis, err_type, linewidth, ...
    linestyle, mrksz, capsize)

% function to create variations of the first plot

% pre allocation
leg_patch = [];
leg_label = string();
dot_plots = {};

% iterate over patterns
for pattern = 1:length(patterns)
    hold on
    ax = gca;
    axis padded

    % Subplot Adjustments
    ax.YGrid = "on";    % plot horizontal grid lines
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
    
    % Plot Performance/Response Frequency
    if strcmp(what_analysis, 'Reaction Times')
        data_plot = boxchart(x_vals, avg_data(pattern, :)'
        data_plot.BoxFaceColor = colours{pattern};
        data_plot.BoxEdgeColor = colours{pattern};
        data_plot.BoxFaceAlpha = 0.2;
        data_plot.BoxMedianLineColor = colours{pattern};
        data_plot.WhiskerLineColor = colours{pattern};
        data_plot.LineWidth = linewidth;
    else
        % mark chance level in performance
        chance_colour = ax.GridAlpha;
        yline(0.5, 'LineStyle', ':', 'Alpha', chance_colour * 3, ...
            'LineWidth', linewidth, 'Color', 'k')
            
        % plot error
        err_plot = errorbar(x_vals, avg_data(pattern, :)', ...
            err_down(pattern, :)', err_up(pattern, :)');
        err_plot.LineStyle = "none";
        err_plot.Color = colours{pattern};
        err_plot.CapSize = capsize;
        err_plot.LineWidth = linewidth;
        err_plot.MarkerSize = mrksz;
    
        % plot mean/median
        plot_pattern = plot(x_vals, avg_data(pattern, :));
        plot_pattern.LineStyle = linestyle;
        plot_pattern.LineWidth = linewidth;
        plot_pattern.Marker = "o";
        plot_pattern.Color = colours{pattern};
        plot_pattern.MarkerFaceColor = colours{pattern};
        plot_pattern.MarkerEdgeColor = "none";
        plot_pattern.MarkerSize = mrksz;
        dot_plots{end + 1} = plot_pattern;
    end

    % for legend
    leg_patch(end + 1) = plot_pattern;
    leg_label(pattern) = patterns{pattern};

end

% add error type to legend labels
leg_label(end + 1) = err_type;

end
