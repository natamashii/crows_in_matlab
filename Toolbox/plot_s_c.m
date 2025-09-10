function fig_pretty = ...
    plot_s_c(numerosities, ind_data_s, ind_data_c, ...
    avg_data_s, avg_data_c, err_data_s, err_data_c, what_analysis, ...
    who_analysis, calc_type, experiment, ...
    patterns, err_type, jitterwidth, ...,
    colours_S_C, mrksz, plot_font, plot_pos, ...
    linewidth, capsize, linestyle)

% function to plot behavioural data with focus on comparing standard &
% control conditions

% pre allocation
leg_patch = [];
leg_label = string();
dot_plots = {};

% pre definition
jitter_dots = [-jitterwidth, jitterwidth];
err_down_s = squeeze(err_data_s(1, :, :));
err_up_s = squeeze(err_data_s(2, :, :));
err_down_c = squeeze(err_data_c(1, :, :));
err_up_c = squeeze(err_data_c(2, :, :));
dot_alpha = 0.3;
marker_factor = 4;

% create figure
fig = figure();

tiled = tiledlayout(fig, length(patterns), 1);
tiled.TileSpacing = "compact";
tiled.Padding = "compact";
tiled.OuterPosition = [0.25 0 0.3 1];

% iterate over patterns
for pattern = 1:length(patterns)
    nexttile(tiled);
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
    set(gca, 'TickDir', 'out');
    if strcmp(what_analysis, 'Reaction Times') && strcmp(who_analysis, 'humans')
        ax.YLim = [0 800];
    elseif strcmp(what_analysis, 'Reaction Times') && ~strcmp(who_analysis, 'humans')
        ax.YLim = [0 800];
    else
        ax.YLim = [0 1];
        ax.YTick = (0:0.2:1);
    end

    if strcmp(what_analysis, 'Reaction Times')
        ylabel(ax, "Reaction Times [ms]")
    else
        ylabel(ax, what_analysis)
    end
    % subplot title
    sub_title = subtitle(patterns{pattern});
    sub_title.FontSize = plot_font;
    sub_title.Color = "k";
    sub_title.FontWeight = "bold";

    % iterate over samples
    for sample_idx = 1:size(numerosities, 1)
        % Reaction Times
        if strcmp(what_analysis, 'Reaction Times')
            % concat RTs for all test numbers & subject/sessions
            y_vals_ind_s = ...
                vertcat(ind_data_s{:, pattern, sample_idx, 1});
            y_vals_ind_c = ...
                vertcat(ind_data_c{:, pattern, sample_idx, 1});
            % Adjust x vals
            x_vals_s = (ones(size(y_vals_ind_s, 1), 1) * ...
            numerosities(sample_idx, 1)) + jitter_dots(1);
            x_vals_c = (ones(size(y_vals_ind_c, 1), 1) * ...
            numerosities(sample_idx, 1)) + jitter_dots(2);

            % Box Plot: Standard Conditions
            plot_pattern = ...
                boxchart(x_vals_s, y_vals_ind_s, ...
                'BoxFaceColor', colours_S_C{1}, ...
                'BoxEdgeColor', colours_S_C{1}, ...
                'BoxFaceAlpha', 0.2, ...
                'BoxMedianLineColor', colours_S_C{1}, ...
                'WhiskerLineColor', colours_S_C{1}, ...
                'WhiskerLineStyle', "none", ...
                'LineWidth', linewidth, ...
                'MarkerStyle', "none");
            plot_pattern.BoxWidth = plot_pattern.BoxWidth / 3;

            % Box Plot: Control Conditions
            plot_pattern = ...
                boxchart(x_vals_c, y_vals_ind_c, ...
                'BoxFaceColor', colours_S_C{2}, ...
                'BoxEdgeColor', colours_S_C{2}, ...
                'BoxFaceAlpha', 0.2, ...
                'BoxMedianLineColor', colours_S_C{2}, ...
                'WhiskerLineColor', colours_S_C{2}, ...
                'WhiskerLineStyle', "none", ...
                'LineWidth', linewidth, ...
                'MarkerStyle', "none");
            plot_pattern.BoxWidth = plot_pattern.BoxWidth / 3;

        else
            y_vals_ind_s = ind_data_s(:, pattern, sample_idx, 1);
            y_vals_ind_c = ind_data_c(:, pattern, sample_idx, 1);
        end

        % Adjust x vals
        x_vals_s = (ones(size(y_vals_ind_s, 1), 1) * ...
            numerosities(sample_idx, 1)) + jitter_dots(1);
        x_vals_c = (ones(size(y_vals_ind_c, 1), 1) * ...
            numerosities(sample_idx, 1)) + jitter_dots(2);

        % Plot: Standard Conditions
        dot_plot_s = ...
            swarmchart(x_vals_s, y_vals_ind_s, mrksz * marker_factor);
        dot_plot_s.XJitter = "randn";
        dot_plot_s.XJitterWidth = 0.5 * max(jitter_dots);
        dot_plot_s.Marker = "o";
        dot_plot_s.MarkerFaceColor = colours_S_C{1};
        dot_plot_s.MarkerEdgeColor = "none";
        dot_plot_s.MarkerFaceAlpha = dot_alpha;
        % Plot: Control Conditions
        dot_plot_c = ...
            swarmchart(x_vals_c, y_vals_ind_c, mrksz * marker_factor);
        dot_plot_c.XJitter = "randn";
        dot_plot_c.XJitterWidth = 0.5 * max(jitter_dots);
        dot_plot_c.Marker = "o";
        dot_plot_c.MarkerFaceColor = colours_S_C{2};
        dot_plot_c.MarkerEdgeColor = "none";
        dot_plot_c.MarkerFaceAlpha = dot_alpha;

    end

    if ~strcmp(what_analysis, 'Reaction Times')
        % set values
        y_vals_s = avg_data_s(pattern, :);
        y_vals_c = avg_data_c(pattern, :);

        % Adjust x vals
        x_vals_s = (ones(size(y_vals_s, 1), 1) .* ...
            numerosities(:, 1)') + ...
            jitter_dots(1);
        x_vals_c = (ones(size(y_vals_c, 1), 1) .* ...
            numerosities(:, 1)') + ...
            jitter_dots(2);

        % Mark Chance Level
        chance_colour = ax.GridAlpha;
        yline(0.5, 'LineStyle', ':', ...
            'Alpha', chance_colour * 3, ...
            'LineWidth', linewidth', 'Color', 'k')

        % Plot Error
        err_plot_s = errorbar(x_vals_s, y_vals_s, ...
            err_down_s(pattern, :)', err_up_s(pattern, :)', ...
            'LineStyle', 'none', 'Color', colours_S_C{1}, ...
            'LineWidth', linewidth, 'CapSize', capsize, ...
            'MarkerSize', mrksz);
        err_plot_c = errorbar(x_vals_c, y_vals_c, ...
            err_down_c(pattern, :)', err_up_c(pattern, :)', ...
            'LineStyle', 'none', 'Color', colours_S_C{2}, ...
            'LineWidth', linewidth, 'CapSize', capsize, ...
            'MarkerSize', mrksz);

        % Plot Mean
        plot_pattern_s = plot(x_vals_s, y_vals_s, ...
            'LineStyle', linestyle, 'LineWidth', linewidth, ...
            'Marker', 'o', 'Color', colours_S_C{1}, ...
            'MarkerFaceColor', colours_S_C{1}, ...
            'MarkerEdgeColor', 'none', 'MarkerSize', mrksz);
        plot_pattern_c = plot(x_vals_c, y_vals_c, ...
            'LineStyle', linestyle, 'LineWidth', linewidth, ...
            'Marker', 'o', 'Color', colours_S_C{2}, ...
            'MarkerFaceColor', colours_S_C{2}, ...
            'MarkerEdgeColor', 'none', 'MarkerSize', mrksz);

    end

    if pattern == 1
        ax.XTickLabel = ' ';
        xlabel(ax, ' ', 'FontWeight', 'bold');    % set x-axis label
        ylabel(ax, ' ', 'FontWeight', 'bold');    % set x-axis label
    elseif pattern == 2
        ax.XTickLabel = ' ';
        xlabel(ax, ' ', 'FontWeight', 'bold');    % set x-axis label
    elseif pattern == 3
        ylabel(ax, ' ', 'FontWeight', 'bold');    % set x-axis label
    end
end

% Plot Improvement
fig_title = title(tiled(1), [calc_type ' ' what_analysis ' of ' ...
        who_analysis ' in ' experiment ' Sample Time ']);
leg_patch(1) = plot_pattern_s;
leg_patch(2) = plot_pattern_c;
leg_label(1) = 'Standard';
leg_label(2) = 'Control';
[fig_pretty, fig_title_pretty] = ...
    prettify_plot(fig, plot_pos, fig_title, plot_font, ...
    true, leg_patch, leg_label);



end