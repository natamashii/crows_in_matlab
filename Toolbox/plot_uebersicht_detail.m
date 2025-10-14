function fig_pretty = ...
    plot_uebersicht_detail(ind_data, avg_data, err_data, numerosities, ...
    patterns, calc_type, err_type, what_analysis, who_analysis, ...
    experiment, plot_font, colours_numbers, plot_pos, linewidth, ...
    mrksz, capsize, jitterwidth, dot_alpha, marker_factor)

% Function to Plot the Übersichts-Plot (but detailed)

% pre allocation
leg_patch = [];
leg_label = string();

% Create Figure
fig = figure("Visible", "off");
tiled = tiledlayout(1, length(patterns));
tiled.Padding = "compact";

% Adjust Colors for Error & Mean Plot
avg_colours = cell2mat(colours_numbers);
avg_colours = rgb2hsv(avg_colours);
avg_colours(:, 3) = avg_colours(:, 3) * .7;
avg_colours = hsv2rgb(avg_colours);

% Iterate over Patterns
for pattern = 1:length(patterns)
    
    % set current subplot
    nexttile(tiled)
    ax = gca;
    hold on

    % Subplot Refinement
    set(gca, "TickDir", "out")
    axis padded
    ax.YGrid = "on";    % plot horizontal grid lines
    ax.Color = [1 1 1];     % set background colour to white
    ax.XColor = "k";    % set colour of axis to black
    ax.YColor = "k";    % set colour of axis to black
    ax.FontWeight = "bold";
    ax.XAxis.FontSize = plot_font;  % set fontsize of ticks
    ax.YAxis.FontSize = plot_font;  % set fontsize of ticks
    ax.XTick = min(numerosities, [], "all"):max(numerosities, [], "all");
    ax.XTickLabel = ...
        string(min(numerosities, [], "all"):max(numerosities, [], "all"));
    ax.XTickLabelRotation = 0;
    ax.XLim = [min(numerosities, [], "all") - .5 ...
        max(numerosities, [], "all") + .5];

    if pattern == 1
        if strcmp(what_analysis, 'Reaction Times')
            ylabel(ax, "Reaction Times [ms]", "FontWeight", "bold")
        else
            ylabel(ax, what_analysis)
        end
    elseif pattern == 2
        xlabel(ax, "Test Numerosity", "FontWeight", "bold")
        ylabel(ax, " ")
    else
        ylabel(ax, " ")
    end

    if strcmp(what_analysis, 'Reaction Times')
        ax.YLim = [0 800];
    else
        ax.YLim = [0 1];
        ax.YTick = 0:0.2:1;
    end

    % Mark Chance Level
    chance_colour = ax.GridAlpha;
    yline(0.5, ...
        "LineStyle", ":", ...
        "Alpha", chance_colour * 3, ...
        "LineWidth", linewidth, ...
        "Color", "k")

    % Iterate Over Samples
    for sample_idx = 1:size(numerosities, 1)
        
        % Iterate over Test Numerals
        for test_idx = 1:size(numerosities, 2)
            
            %% Plot Individual Dots
            if strcmp(what_analysis, 'Reaction Times')

                % Concat RTs for all subjects/sessions
                y_vals = vertcat(ind_data{:, pattern, sample_idx, test_idx});

            else        % Performance/Response Frequency
                y_vals = squeeze(ind_data(:, pattern, sample_idx, test_idx));
            end

            % Adjust x vals
            x_vals = ...
                ones(size(y_vals, 1), 1) * numerosities(sample_idx, test_idx);

            % Plot
            dot_plot = swarmchart(x_vals, y_vals, mrksz * marker_factor, ...
                "XJitter", "randn", ...
                "XJitterWidth", jitterwidth, ...
                "Marker", "o", ...
                "MarkerFaceColor", colours_numbers{sample_idx}, ...
                "MarkerEdgeColor", "none", ...
                "MarkerFaceAlpha", dot_alpha);
        end

        %% Plot Averages
        % Adjust values
        x_vals = numerosities(sample_idx, :);
        y_vals = squeeze(avg_data(pattern, sample_idx, :));
        err_low = squeeze(err_data(1, pattern, sample_idx, :));
        err_up = squeeze(err_data(2, pattern, sample_idx, :));

        % Get Indices for Ascending Order
        [~, sort_idx] = sort(numerosities(sample_idx, :));

        % Plot
        plot_pattern = plot(x_vals(sort_idx), y_vals(sort_idx), ...
            "Marker", "o", ...
            "MarkerSize", mrksz, ...
            "MarkerFaceColor", avg_colours(sample_idx, :), ...
            "MarkerEdgeColor", avg_colours(sample_idx, :), ...
            "Color", avg_colours(sample_idx, :), ...
            "LineStyle", "-", ...
            "LineWidth", linewidth);

        % Plot Corresponding Error
        err_plot = errorbar(x_vals(sort_idx), y_vals(sort_idx), ...
            err_low(sort_idx), err_up(sort_idx), ...
            "LineStyle", "none", ...
            "Color", avg_colours(sample_idx, :), ...
            "LineWidth", linewidth, ...
            "CapSize", capsize, ...
            "MarkerSize", mrksz);

        % For Legend
        leg_patch(sample_idx) = plot_pattern;
        leg_label(sample_idx) = num2str(numerosities(sample_idx, 1));
    end

    % Plot Invisible Error Plot for Legend
    leg_err = errorbar(0, 1, 5, 5, ...
        "LineStyle", "none", ...
        "Color", "k", ...
        "LineWidth", linewidth, ...
        "CapSize", capsize, ...
        "MarkerSize", mrksz);
end

leg_patch(end + 1) = leg_err;
leg_label(end + 1) = err_type;

% Figure Adjustments
fig_title = title([calc_type ' ' what_analysis ' of ' ...
    who_analysis ' in ' experiment ' Sample Time ']);
[fig_pretty, fig_title_pretty] = ...
    prettify_plot(fig, plot_pos, fig_title, plot_font, ...
    false, leg_patch, leg_label, ax);

leg = ...
    legend(leg_patch, leg_label, ...
    "Box", "off", ...
    "Location", "bestoutside", ...
    "TextColor", "k", ...
    "FontSize", plot_font, ...
    "FontWeight", "bold");
title(leg, "Sample", "FontSize", plot_font)

end