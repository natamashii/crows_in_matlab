function fig = ...
    plot_c_g(diff_data, colours_pattern_diff, curr_experiments, ...
    what_analysis, who_analysis, err_type, calc_type, numerosities, ...
    sample_idx, plot_font, plot_pos, linewidth, mrksz, capsize, ...
    jitterwidth, dot_alpha, marker_factor, comb_chunk, exp_x_vals)

% Function to Plot Chunking/Groupitizing Plot for Each Subject, Sample,
% Data Type

% Pre Allocation
leg_patch = [];
leg_label = string();

% Pre Definition
if comb_chunk
    labelings = {'Chunking'; 'Groupitizing'};
    jitter_dots = [-jitterwidth jitterwidth];
else
    labelings = {'P2 - P1'; 'P3 - P1'; 'P3 - P2'};
    jitter_dots = [-jitterwidth 0 jitterwidth];
end
% Adjust Colors for Error & Mean Plot
avg_colours = cell2mat(colours_pattern_diff);
avg_colours = rgb2hsv(avg_colours);
avg_colours(:, 3) = avg_colours(:, 3) * .7;
avg_colours = hsv2rgb(avg_colours);
dot_alpha = 0.3;

% Create Figure
fig = figure("Visible", "off");

% Mark 0 Line
ax0 = axes(fig);
hold on
ax0.Color = [1 1 1];     % set background colour to white
chance_colour = ax0.GridAlpha;
yl = yline(ax0, 0, ...
    "LineStyle", ":", ...
    "Alpha", chance_colour * 3, ...
    "LineWidth", linewidth, ...
    "Color", "k");
ax0.YGrid = "on";
ax0.Box = "off";

% Axis Adjustments
ax = axes(fig, "Position", ax0.Position);
hold on

linkaxes([ax0,ax],'xy');
set(gca, "TickDir", "out")
axis padded
ax.YGrid = "on";    % plot horizontal grid lines
ax.Color = "none";     % set background colour to white
ax.XColor = "k";    % set colour of axis to black
ax.YColor = "k";    % set colour of axis to black
ax.FontWeight = "bold";
ax.XAxis.FontSize = plot_font;  % set fontsize of ticks
ax.YAxis.FontSize = plot_font;  % set fontsize of ticks
xlabel(ax, "Experiment", "FontWeight", "bold");    % set x-axis label
ax.XTick = 1:length(curr_experiments);
ax.XTickLabel = curr_experiments;
ax.XTickLabelRotation = 0;
ax.XLim = [.5 length(curr_experiments) + .5];
ylabel(ax, ['Difference in ' what_analysis], "FontWeight", "bold")



% Set ylim depending on what_analysis
if strcmp(what_analysis, 'Reaction Times')
    ax.YLim = [-50 50];
else
    ax.YLim = [-0.5 0.5];

% Iterate over Experiments
for exp_idx = exp_x_vals

    % set data
    curr_data = diff_data{exp_idx, sample_idx};
    ind_data = [curr_data{2, :}];
    avg_data = [curr_data{3, :}];
    err_data_low = [curr_data{4, :}];
    err_data_up = [curr_data{5, :}];

    % iterate over amount of differences to be displayed
    for pattern = 1:length(labelings)
        
        %% Plot individual Dots
        % set y vals
        y_vals = ind_data(:, pattern);
        % set x vals
        x_vals = ...
            (ones(size(y_vals, 1), 1) * exp_idx) + jitter_dots(pattern);

        % Plot
        dot_plot = swarmchart(x_vals, y_vals, mrksz * marker_factor, ...
            "XJitter", "randn", ...
            "XJitterWidth", jitterwidth, ...
            "Marker", "o", ...
            "MarkerFaceColor", colours_pattern_diff{pattern}, ...
            "MarkerEdgeColor", "none", ...
            "MarkerFaceAlpha", dot_alpha);

        %% Plot Average
        plot_pattern = ...
            plot(exp_idx + jitter_dots(pattern), avg_data(pattern), ...
            "LineStyle", "none", ...
            "LineWidth", linewidth, ...
            "Marker", "o", ...
            "Color", avg_colours(pattern, :), ...
            "MarkerFaceColor", avg_colours(pattern, :), ...
            "MarkerEdgeColor", "none", ...
            "MarkerSize", mrksz);

        %% Plot Error
        err_plot = ...
            errorbar(exp_idx + jitter_dots(pattern), ...
            avg_data(pattern), err_data_low(pattern), err_data_up(pattern), ...
            "LineStyle", "none", ...
            "Color", avg_colours(pattern, :), ...
            "LineWidth", linewidth, ...
            "CapSize", capsize, ...
            "MarkerSize", mrksz);

        %% Legend Adjustments
        leg_patch(pattern) = plot_pattern;
        leg_label(pattern) = labelings{pattern};
    end
end

%% More Legend Adjustments
% plot invisible error plot
errr_plot = errorbar(0, 1, 5, 1, ...
    "LineStyle", "none", ...
    "Color", "k", ...
    "LineWidth", linewidth, ...
    "CapSize", capsize, ...
    "MarkerSize", mrksz, ...
    "Marker", "o", ...
    "MarkerEdgeColor", "none", ...
    "MarkerFaceColor", "k");

leg_patch(end + 1) = errr_plot;
leg_label(end + 1) = err_type;

%% Figure Adjustments
fig_title = title([calc_type ' Difference in ' what_analysis ' of ' ...
    who_analysis ' for Sample #' num2str(numerosities(sample_idx, 1))]); 
[fig_pretty, ~] = ...
    prettify_plot(fig, plot_pos, fig_title, plot_font, ...
    true, leg_patch, leg_label, ' ', mrksz, ax);

ax0.XAxis.Visible = "off";
ax0.YAxis.Visible = "off";

end