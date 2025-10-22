function fig_pretty = ...
    plot_uebersicht(ind_data, avg_data, err_data, ...
    patterns, calc_type, err_type, what_analysis, who_analysis, ...
    experiment, plot_font, colour_uebersicht, plot_pos, linewidth, ...
    mrksz, capsize, jitterwidth, focus_type, ...
    dot_alpha, marker_factor)

% Function to Plot the Übersichts-Plot

% Create figure
fig = figure("Visible", "off");

if length(ind_data) > 1
    x_factor = [-jitterwidth, jitterwidth];
else
    x_factor = 1;
end

for who_idx = 1:length(ind_data)
    % iterate over Patterns
    for pattern = 1:length(patterns)

        % Plot Individual Dots
        ax = ...
            plot_ind(ind_data{who_idx}, jitterwidth, dot_alpha, ...
            marker_factor, colour_uebersicht, pattern, mrksz, ...
            what_analysis, focus_type, x_factor(who_idx));

        % Adjust Colors for Error & Mean Plot
        avg_colours = rgb2hsv(colour_uebersicht);
        avg_colours(:, 3) = avg_colours(:, 3) * .7;
        avg_colours = hsv2rgb(avg_colours);

        % Plot the Average/Median
        [ax, leg_patch, leg_label] = ...
            plot_pattern(ind_data{who_idx}, avg_data{who_idx}, ...
            err_data{who_idx}, patterns, pattern, ...
            what_analysis, calc_type, err_type, focus_type, ...
            avg_colours, plot_font, linewidth, mrksz, capsize, x_factor);
    end
end
% Plot Adjustments
set(gca, "TickDir", "out")
axis padded
ax.YGrid = "on";    % plot horizontal grid lines
ax.Color = [1 1 1];     % set background colour to white
ax.XColor = "k";    % set colour of axis to black
ax.YColor = "k";    % set colour of axis to black
ax.FontWeight = "bold";
ax.XAxis.FontSize = plot_font;  % set fontsize of ticks
ax.YAxis.FontSize = plot_font;  % set fontsize of ticks
xlabel(ax, "Pattern", "FontWeight", "bold");    % set x-axis label
ax.XTick = 1:length(patterns);
ax.XTickLabel = patterns;
ax.XTickLabelRotation = 0;
ax.XLim = [.5 length(patterns) + .5];

if strcmp(what_analysis, 'Reaction Times')
    ax.YLim = [0 800];
    ylabel(ax, "Reaction Times [ms]")
else
    ax.YLim = [0 1];
    ax.YTick = 0:0.2:1;
    ylabel(ax, what_analysis)
end

% Invisible plots for legend


% Figure Adjustments
fig_title = title([calc_type ' ' what_analysis ' of ' ...
    who_analysis ' in ' experiment ' Sample Time ']);
[fig_pretty, fig_title_pretty] = ...
    prettify_plot(fig, plot_pos, fig_title, plot_font, ...
    false, leg_patch, leg_label);
leg = legend(leg_patch, leg_label, ...
    "Box", "off", ...
    "Location", "bestoutside", ...
    "TextColor", "k", ...
    "FontSize", plot_font, ...
    "FontWeight", "bold");

end