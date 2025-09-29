function fig_pretty = ...
    plot_ssmd(what_analysis, all_ssmd, who_analysis, patterns, numerosities, ...
    plot_font, colours_pattern, plot_pos, linewidth, linestyle, ...
    mrksz, jitterwidth, curr_experiments)

% function to plot strictly standardized mean difference

% pre definition
jitter_dots = [-jitterwidth, 0, jitterwidth];
leg_entries = {'P1-P2'; 'P2-P3'; 'P1-P3'};
leg_patch = [];
leg_label = string();
dot_plots = {};

if strcmp(who_analysis, 'humans')
    x_entries = {extractAfter(curr_experiments{1}, 11), ...
        extractAfter(curr_experiments{2}, 11), ...
        extractAfter(curr_experiments{3}, 11)};
    x_indices = [1, 2, 3];
    x_stop = 3;
else
    x_entries = {extractAfter(curr_experiments{2}, 11), ...
        extractAfter(curr_experiments{1}, 11), ...
        extractAfter(curr_experiments{3}, 11), ...
        extractAfter(curr_experiments{4}, 11)};
    x_indices = [2, 1, 3, 4];
    x_stop = 4;
end

% Create Figure
fig = figure("Visible", "off");
current_pos = fig.Position; % Get current figure position
fig.Position = [current_pos(1), current_pos(2), plot_pos(1) * 50, plot_pos(2) * 50];
tiled = tiledlayout(fig, 1, size(numerosities, 1));
tiled.TileSpacing = "compact";
tiled.Padding = "compact";

% plot the SSMD

% iterate over samples
for sample_idx = 1:size(numerosities, 1)
    nexttile(tiled);
    hold on
    ax = gca;
    axis padded

    % Subplot Adjustents
    ax.YGrid = "on";
    ax.Color = [1 1 1];
    ax.XColor = "k";
    ax.YColor = "k";
    ax.FontWeight = "bold";
    ax.XAxis.FontSize = plot_font;
    ax.YAxis.FontSize = plot_font;
    set(gca, "TickDir", "out");
    ax.XTickLabel = x_entries;
    ax.XTick = 1:x_stop;
    ylim([0 max(all_ssmd, [], "all")])

    if ~strcmp(what_analysis, 'Reaction Times')
        % Mark Chance Level
        chance_colour = ax.GridAlpha;
        yline(0.5, 'LineStyle', ':', ...
            'Alpha', chance_colour * 3, ...
            'LineWidth', linewidth, 'Color', 'k')
    end

    % Subplot title
    sub_title = subtitle(num2str(numerosities(sample_idx, 1)));
    sub_title.FontSize = plot_font;
    sub_title.Color = "k";
    sub_title.FontWeight = "bold";

    % iterate over patterns
    for pattern = 1:length(patterns)

        % Adjust x vals
        x_vals = (1:length(curr_experiments)) + jitter_dots(pattern);
        y_vals = abs(all_ssmd(:, pattern, sample_idx));

        % Plot the SSMD for the current pattern
        plot_pattern = plot(x_vals(x_indices), ...
            y_vals(x_indices), ...
            'LineWidth', linewidth, 'LineStyle', linestyle, ...
            'Marker', 'o', 'MarkerSize', mrksz, ...
            'Color', colours_pattern{pattern}, ...
            'MarkerEdgeColor', 'none', ...
            'MarkerFaceColor', colours_pattern{pattern});
        if sample_idx == 5
            % for legend
            dot_plots{end + 1} = plot_pattern;
            leg_patch(end + 1) = plot_pattern;
            leg_label(pattern) = leg_entries{pattern};
        end
    end

    % Specific Subplot Adjustments
    if sample_idx == 3
        xlabel(ax, "Experiment")
    elseif sample_idx == 1
        ylabel(ax, "SSMD []")
    end
end

% Figure Adjustments
fig_title = title(['Strictly Standardized Mean Difference in ' ...
    what_analysis ' of ' who_analysis]);
[fig_pretty, ~] = ...
    prettify_plot(fig, plot_pos, fig_title, plot_font, ...
    true, leg_patch, leg_label);

end