function ax = ...
    plot_ind(numerosities, ind_data, jitter_dots, ...
    colours, patterns, mrksz, what_analysis, focus_type, sample_idx, linewidth)

% Function to plot individual data points of each subject/session

dot_alpha = 0.3;
marker_factor = 4;

% iterate over patterns
for pattern = 1:length(patterns)
    hold on
    ax = gca;

    ax.Color = [1 1 1];     % set background colour to white

    switch focus_type
        case 'Single'
            % iterate over test numbers
            for test_idx = 1:size(numerosities, 2)
                % Reaction Times
                if strcmp(what_analysis, 'Reaction Times')
                    % concat RTs for all test numbers & subject/sessions
                    y_vals = ...
                        vertcat(ind_data{:, pattern, sample_idx, test_idx});

                    % adjust x vals
                    x_vals = ones(size(y_vals, 1), 1);
                    x_vals = ...
                        (x_vals * numerosities(sample_idx, test_idx)) + ...
                        jitter_dots(pattern);

                    % Plot
                    dot_plot = ...
                        swarmchart(x_vals, y_vals, mrksz * marker_factor);
                    dot_plot.XJitter = "randn";
                    dot_plot.XJitterWidth = 0.4 * max(jitter_dots);
                    dot_plot.Marker = "o";
                    dot_plot.MarkerFaceColor = colours{pattern};
                    dot_plot.MarkerEdgeColor = "none";
                    dot_plot.MarkerFaceAlpha = dot_alpha;

                else
                    % set values
                    y_vals = ind_data(:, pattern, sample_idx, test_idx);
                    x_vals = ones(size(y_vals, 1), 1);
                    x_vals = ...
                        (x_vals * numerosities(sample_idx, test_idx)) + ...
                        jitter_dots(pattern);

                    % Mark Chance Level
                    chance_colour = ax.GridAlpha;
                    yline(0.5, 'LineStyle', ':', ...
                        'Alpha', chance_colour * 3, ...
                        'LineWidth', linewidth, 'Color', 'k')

                    % Plot
                    dot_plot = ...
                        swarmchart(x_vals, y_vals, mrksz * marker_factor);
                    dot_plot.XJitter = "randn";
                    dot_plot.XJitterWidth = 0.4 * max(jitter_dots);
                    dot_plot.Marker = "o";
                    dot_plot.MarkerFaceColor = colours{pattern};
                    dot_plot.MarkerEdgeColor = "none";
                    dot_plot.MarkerFaceAlpha = dot_alpha;

                end
            end
        case 'Overall'
            % Iterate over samples
            for sample_idx = 1:size(numerosities, 1)
                % Reaction Times
                if strcmp(what_analysis, 'Reaction Times')
                    % concat RTs for all test numbers & subject/sessions
                    y_vals = ...
                        vertcat(ind_data{:, pattern, sample_idx, :});
                else
                    % Pre allocation
                    y_vals = NaN(size(ind_data, 1), 1);
                    % take mean for match + non-match
                    for sub = 1:size(ind_data, 1)
                        y_vals(sub) = ...
                            mean(ind_data(sub, pattern, sample_idx, :));
                    end
                end
                
                % Adjust x vals
                x_vals = (ones(size(y_vals, 1), 1) * ...
                    numerosities(sample_idx, 1)) + jitter_dots(pattern);

                % Plot
                dot_plot = ...
                    swarmchart(x_vals, y_vals, mrksz * marker_factor);
                dot_plot.XJitter = "randn";
                dot_plot.XJitterWidth = 0.4 * max(jitter_dots);
                dot_plot.Marker = "o";
                dot_plot.MarkerFaceColor = colours{pattern};
                dot_plot.MarkerEdgeColor = "none";
                dot_plot.MarkerFaceAlpha = dot_alpha;
            end

        case 'Matches'
            % Iterate over samples
            for sample_idx = 1:size(numerosities, 1)
                % Reaction Times
                if strcmp(what_analysis, 'Reaction Times')
                    % concat RTs for all test numbers & subject/sessions
                    y_vals = ...
                        vertcat(ind_data{:, pattern, sample_idx, 1});
                else
                    y_vals = ind_data(:, pattern, sample_idx, 1);
                end

                % Adjust x vals
                x_vals = (ones(size(y_vals, 1), 1) * ...
                    numerosities(sample_idx, 1)) + jitter_dots(pattern);

                % Plot
                dot_plot = ...
                    swarmchart(x_vals, y_vals, mrksz * marker_factor);
                dot_plot.XJitter = "randn";
                dot_plot.XJitterWidth = 0.4 * max(jitter_dots);
                dot_plot.Marker = "o";
                dot_plot.MarkerFaceColor = colours{pattern};
                dot_plot.MarkerEdgeColor = "none";
                dot_plot.MarkerFaceAlpha = dot_alpha;
            end
    end
end

end