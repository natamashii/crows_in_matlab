function fig_pretty = ...
    plot_uebersicht(ind_data, avg_data, err_data, ...
    patterns, calc_type, err_type, what_analysis, what_idx, who_analysis, ...
    experiment, plot_font, colours_J_U, plot_pos, linewidth, ...
    mrksz, capsize, jitterwidth, focus_type, ...
    dot_alpha, marker_factor, lin_reg, add_reg, add_title, axis_colour, ...
    subfig_title)

% Function to Plot the Übersichts-Plot

% Create figure
fig = figure("Visible", "off");

if length(ind_data) > 1
    x_factor = [-jitterwidth, jitterwidth];
    marker_shape = ["o", "o"];
else
    x_factor = 0;
    marker_shape = "o";
end

for who_idx = 1:length(ind_data)
    % iterate over Patterns
    for pattern = 1:length(patterns)

        % Plot Individual Dots
        ax = ...
            plot_ind(ind_data{who_idx}, jitterwidth, dot_alpha, ...
            marker_factor, colours_J_U{who_idx}, pattern, mrksz, ...
            what_analysis, focus_type, ...
            x_factor(who_idx), marker_shape(who_idx));

        % Adjust Colors for Error & Mean Plot
        avg_colours = rgb2hsv(colours_J_U{who_idx});
        avg_colours(:, 3) = avg_colours(:, 3) * .7;
        avg_colours = hsv2rgb(avg_colours);

        % Plot the Average/Median
        [ax, leg_patch, leg_label] = ...
            plot_pattern(ind_data{who_idx}, avg_data{who_idx}, ...
            err_data{who_idx}, patterns, pattern, ...
            what_analysis, calc_type, err_type, focus_type, ...
            avg_colours, plot_font, linewidth, mrksz, capsize, ...
            x_factor(who_idx), marker_shape(who_idx), axis_colour);
    end
end

for who_idx = 1:length(ind_data)
    % Adjust Colors for Error & Mean Plot
    avg_colours = rgb2hsv(colours_J_U{who_idx});
    avg_colours(:, 3) = avg_colours(:, 3) * .7;
    avg_colours = hsv2rgb(avg_colours);

    % Plot Linear Regression Curve
    if add_reg
        plot_lin_reg(lin_reg{who_idx}, x_factor(who_idx), ...
            what_idx, "--", linewidth, avg_colours);
    end
end

% Plot Adjustments
set(gca, "TickDir", "out")
axis padded
ax.YGrid = "on";    % plot horizontal grid lines
ax.Color = [1 1 1];     % set background colour to white
ax.XColor = axis_colour;    % set colour of axis to black
ax.YColor = axis_colour;    % set colour of axis to black
ax.FontWeight = "bold";
ax.XAxis.FontSize = plot_font;  % set fontsize of ticks
ax.YAxis.FontSize = plot_font;  % set fontsize of ticks
xlabel(ax, "Pattern", "FontWeight", "bold");    % set x-axis label
ax.XTick = 1:length(patterns);
ax.XTickLabel = patterns;
ax.XTickLabelRotation = 0;
ax.XLim = [.5 length(patterns) + .5];
set(gca, "linewidth", 3)

if strcmp(what_analysis, 'Reaction Times')
    ax.YLim = [0 650];
    ylabel(ax, "Reaction Times [ms]")
elseif strcmp(what_analysis, 'Performance')
    ax.YLim = [50 100];
    ax.YTick = 50:10:100;
    ylabel(ax, "Performance [%]")
elseif strcmp(what_analysis, 'Response Frequency')
    ax.YLim = [40 100];
    ax.YTick = 40:20:100;
    ylabel(ax, "Response Frequency [%]")
end

if strcmp(who_analysis, 'birds')
    % Invisible plot for jello
    avg_colours = rgb2hsv(colours_J_U{1});
    avg_colours(:, 3) = avg_colours(:, 3) * .7;
    avg_colours = hsv2rgb(avg_colours);

    jello_plot = ...
        boxchart(zeros(13, 1), zeros(13, 1), ...
        "BoxFaceColor", colours_J_U{1}, ...
        "BoxEdgeColor", avg_colours(1, :), ...
        "BoxFaceAlpha", 0.2, ...
        "BoxMedianLineColor", avg_colours(1, :), ...
        "WhiskerLineColor", avg_colours(1, :), ...
        "WhiskerLineStyle", "none", ...
        "LineWidth", linewidth, ...
        "MarkerStyle", "none");

    % Add invisble plot for Uri
    avg_colours = rgb2hsv(colours_J_U{2});
    avg_colours(:, 3) = avg_colours(:, 3) * .7;
    avg_colours = hsv2rgb(avg_colours);

    uri_plot = ...
        boxchart(zeros(8, 1), zeros(8, 1), ...
        "BoxFaceColor", colours_J_U{2}, ...
        "BoxEdgeColor", avg_colours, ...
        "BoxFaceAlpha", 0.2, ...
        "BoxMedianLineColor", avg_colours, ...
        "WhiskerLineColor", avg_colours, ...
        "WhiskerLineStyle", "none", ...
        "LineWidth", linewidth, ...
        "MarkerStyle", "none");

    % Add to Legend
    leg_patch(end + 1) = jello_plot;
    leg_label(end + 1) = "Crow 1";
    leg_patch(end + 1) = uri_plot;
    leg_label(end + 1) = "Crow 2";

    if ~(length(leg_patch) == length(leg_label))
        leg_label = leg_label(2:end);
    end
end 

% Figure Adjustments
fig_title = title(subfig_title);
[fig_pretty, fig_title_pretty] = ...
    prettify_plot(fig, plot_pos, fig_title, plot_font, ...
    false, leg_patch, leg_label, ' ', mrksz, ax, axis_colour);

leg = legend(leg_patch, leg_label, ...
    "Box", "off", ...
    "Location", "bestoutside", ...
    "TextColor", axis_colour, ...
    "FontSize", plot_font, ...
    "FontWeight", "bold");

end