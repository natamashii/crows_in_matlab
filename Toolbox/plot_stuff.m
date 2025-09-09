function fig_pretty = ...
    plot_stuff(ind_data, avg_data, err_data, numerosities, patterns, ...
    calc_type, err_type, what_analysis, who_analysis, ...
    experiment, plot_font, colours, plot_pos, linewidth, ...
    linestyle, mrksz, capsize, jitterwidth, focus_type)

% Function to plot the data

% pre definition
jitter_dots = [-jitterwidth, 0, jitterwidth];

% Create Figure
fig = figure();

switch focus_type
    case 'Single'
        tiled = tiledlayout(fig, 1, size(numerosities, 1));
        tiled.TileSpacing = "compact";
        tiled.Padding = "compact";

        % Iterate over samples to plot them
        for sample_idx = 1:size(numerosities, 1)
            nexttile(tiled);

            % Plot single data points
            ax = ...
                plot_ind(numerosities, ind_data, jitter_dots, ...
                colours, patterns, mrksz, what_analysis, focus_type, sample_idx, linewidth);

            % plot the stuff
            [ax, dot_plots, leg_patch, leg_label] = ...
                plot_first(numerosities, jitter_dots, ind_data, avg_data, ...
                squeeze(err_data(1, :, :, :)), squeeze(err_data(2, :, :, :)), ...
                patterns, colours, plot_font, what_analysis, err_type, linewidth, ...
                linestyle, mrksz, capsize, focus_type, sample_idx);

            % Subplot Adjustments
            if strcmp(what_analysis, 'Reaction Times') && ...
                    strcmp(who_analysis, 'humans')
                ax.YLim = [0 800];
            elseif strcmp(what_analysis, 'Reaction Times') && ...
                    ~strcmp(who_analysis, 'humans')
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
            set(gca,'TickDir','out');
        end
    case 'Overall'
        tiled = tiledlayout(fig, 1, 1);
        tiled.TileSpacing = "compact";
        tiled.Padding = "compact";

        % Plot single data points
        ax = ...
            plot_ind(numerosities, ind_data, jitter_dots, ...
            colours, patterns, mrksz, what_analysis, focus_type, 0, linewidth);

        % plot the stuff
        [ax, dot_plots, leg_patch, leg_label] = ...
            plot_first(numerosities, jitter_dots, ind_data, avg_data, ...
            squeeze(err_data(1, :, :)), squeeze(err_data(2, :, :)), ...
            patterns, colours, plot_font, what_analysis, err_type, linewidth, ...
            linestyle, mrksz, capsize, focus_type, 0);
    case 'Matches'
        tiled = tiledlayout(fig, 1, 1);
        tiled.TileSpacing = "compact";
        tiled.Padding = "compact";

        % Plot single data points
        ax = ...
            plot_ind(numerosities, ind_data, jitter_dots, ...
            colours, patterns, mrksz, what_analysis, focus_type, 0, linewidth);

        % plot the stuff
        [ax, dot_plots, leg_patch, leg_label] = ...
            plot_first(numerosities, jitter_dots, ind_data, avg_data, ...
            squeeze(err_data(1, :, :)), squeeze(err_data(2, :, :)), ...
            patterns, colours, plot_font, what_analysis, err_type, linewidth, ...
            linestyle, mrksz, capsize, focus_type, 0);
end

% figure title
fig_title = title([calc_type ' ' what_analysis ' of ' ...
    who_analysis ' in ' experiment ' Sample Time ']);
% Plot Improvement
[fig_pretty, fig_title_pretty] = ...
    prettify_plot(fig, plot_pos, fig_title, plot_font, ...
    true, leg_patch, leg_label);

% Subplot Adjustments
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

end