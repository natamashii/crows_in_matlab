function fig_pretty = ...
    plot_s_c(numerosities, ind_data_1, ind_data_2, ...
    avg_data_1, avg_data_2, err_data_1, err_data_2, what_analysis, ...
    who_analysis, calc_type, experiment, ...
    patterns, err_type, jitterwidth, ...,
    colours_split, mrksz, plot_font, plot_pos, ...
    linewidth, capsize, linestyle, factors)

% function to plot behavioural data with focus on comparing standard &
% control conditions

% pre allocation
leg_patch = [];
leg_label = string();
dot_plots = {};

% pre definition
jitter_dots = [-jitterwidth, jitterwidth];
err_down_1 = squeeze(err_data_1(1, :, :));
err_up_1 = squeeze(err_data_1(2, :, :));
err_down_2 = squeeze(err_data_2(1, :, :));
err_up_2 = squeeze(err_data_2(2, :, :));
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
        ax.YLim = [0 700];
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
        % Plot the individual dots
        if strcmp(what_analysis, 'Reaction Times')
            y_vals_ind_1 = vertcat(ind_data_1{:, pattern, sample_idx, 1});
            y_vals_ind_2 = vertcat(ind_data_2{:, pattern, sample_idx, 1});
        else
            y_vals_ind_1 = ind_data_1(:, pattern, sample_idx, 1);
            y_vals_ind_2 = ind_data_2(:, pattern, sample_idx, 1);
        end

        % adjust x vals
        x_vals_1 = (ones(size(y_vals_ind_1, 1), 1) * ...
            numerosities(sample_idx, 1)) + jitter_dots(1);
        x_vals_2 = (ones(size(y_vals_ind_2, 1), 1) * ...
            numerosities(sample_idx, 1)) + jitter_dots(2);

        % Plot individual dots 
        % Plot: Standard Conditions/Jello
        dot_plot_1 = ...
            swarmchart(x_vals_1, y_vals_ind_1, mrksz * marker_factor);
        dot_plot_1.XJitter = "randn";
        dot_plot_1.XJitterWidth = 0.5 * max(jitter_dots);
        dot_plot_1.Marker = "o";
        dot_plot_1.MarkerFaceColor = colours_split{1};
        dot_plot_1.MarkerEdgeColor = "none";
        dot_plot_1.MarkerFaceAlpha = dot_alpha;

        % Plot: Control Conditions/Uri
        dot_plot_2 = ...
            swarmchart(x_vals_2, y_vals_ind_2, mrksz * marker_factor);
        dot_plot_2.XJitter = "randn";
        dot_plot_2.XJitterWidth = 0.5 * max(jitter_dots);
        dot_plot_2.Marker = "o";
        dot_plot_2.MarkerFaceColor = colours_split{2};
        dot_plot_2.MarkerEdgeColor = "none";
        dot_plot_2.MarkerFaceAlpha = dot_alpha;

        % Box Plot for Reaction Times
        if strcmp(what_analysis, 'Reaction Times')
            % concat RTs for all test numbers & subject/sessions
            y_vals_ind_1 = ...
                vertcat(ind_data_1{:, pattern, sample_idx, 1});
            y_vals_ind_2 = ...
                vertcat(ind_data_2{:, pattern, sample_idx, 1});
            % Adjust x vals
            x_vals_1 = (ones(size(y_vals_ind_1, 1), 1) * ...
                numerosities(sample_idx, 1)) + jitter_dots(1);
            x_vals_2 = (ones(size(y_vals_ind_2, 1), 1) * ...
                numerosities(sample_idx, 1)) + jitter_dots(2);

            % Box Plot: Standard Conditions
            plot_pattern_1 = ...
                boxchart(x_vals_1, y_vals_ind_1, ...
                'BoxFaceColor', colours_split{1}, ...
                'BoxEdgeColor', colours_split{1}, ...
                'BoxFaceAlpha', 0.2, ...
                'BoxMedianLineColor', colours_split{1}, ...
                'WhiskerLineColor', colours_split{1}, ...
                'WhiskerLineStyle', "none", ...
                'LineWidth', linewidth, ...
                'MarkerStyle', "none");
            plot_pattern_1.BoxWidth = plot_pattern_1.BoxWidth / 3;

            % Box Plot: Control Conditions
            plot_pattern_2 = ...
                boxchart(x_vals_2, y_vals_ind_2, ...
                'BoxFaceColor', colours_split{2}, ...
                'BoxEdgeColor', colours_split{2}, ...
                'BoxFaceAlpha', 0.2, ...
                'BoxMedianLineColor', colours_split{2}, ...
                'WhiskerLineColor', colours_split{2}, ...
                'WhiskerLineStyle', "none", ...
                'LineWidth', linewidth, ...
                'MarkerStyle', "none");
            plot_pattern_2.BoxWidth = plot_pattern_2.BoxWidth / 3;
        end
    end

    if ~strcmp(what_analysis, 'Reaction Times')
        % set values
        y_vals_1 = avg_data_1(pattern, :);
        y_vals_2 = avg_data_2(pattern, :);

        % Adjust x vals
        x_vals_1 = (ones(size(y_vals_1, 1), 1) .* ...
            numerosities(:, 1)') + ...
            jitter_dots(1);
        x_vals_2 = (ones(size(y_vals_2, 1), 1) .* ...
            numerosities(:, 1)') + ...
            jitter_dots(2);

        % Mark Chance Level
        chance_colour = ax.GridAlpha;
        yline(0.5, 'LineStyle', ':', ...
            'Alpha', chance_colour * 3, ...
            'LineWidth', linewidth', 'Color', 'k')

        % Plot Error
        err_plot_1 = errorbar(x_vals_1, y_vals_1, ...
            err_down_1(pattern, :)', err_up_1(pattern, :)', ...
            'LineStyle', 'none', 'Color', colours_split{1}, ...
            'LineWidth', linewidth, 'CapSize', capsize, ...
            'MarkerSize', mrksz);
        err_plot_2 = errorbar(x_vals_2, y_vals_2, ...
            err_down_2(pattern, :)', err_up_2(pattern, :)', ...
            'LineStyle', 'none', 'Color', colours_split{2}, ...
            'LineWidth', linewidth, 'CapSize', capsize, ...
            'MarkerSize', mrksz);

        % Plot Mean
        plot_pattern_1 = plot(x_vals_1, y_vals_1, ...
            'LineStyle', linestyle, 'LineWidth', linewidth, ...
            'Marker', 'o', 'Color', colours_split{1}, ...
            'MarkerFaceColor', colours_split{1}, ...
            'MarkerEdgeColor', 'none', 'MarkerSize', mrksz);
        plot_pattern_2 = plot(x_vals_2, y_vals_2, ...
            'LineStyle', linestyle, 'LineWidth', linewidth, ...
            'Marker', 'o', 'Color', colours_split{2}, ...
            'MarkerFaceColor', colours_split{2}, ...
            'MarkerEdgeColor', 'none', 'MarkerSize', mrksz);

    end
    
    % Subplot Adjustments
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
leg_patch(1) = plot_pattern_1;
leg_patch(2) = plot_pattern_2;
leg_label(1) = factors{1};
leg_label(2) = factors{2};
[fig_pretty, ~] = ...
    prettify_plot(fig, plot_pos, fig_title, plot_font, ...
    true, leg_patch, leg_label);

end