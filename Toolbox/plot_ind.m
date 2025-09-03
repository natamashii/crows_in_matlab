function ax = ...
    plot_ind(numerosities, data, jitter_dots, ...
    colours, patterns, in_detail, mrksz, data_type)

% Function to plot individual data points of each subject/session

linewidth = 1;
dot_alpha = 0.3;
marker_factor = 4;

% iterate over patterns
for pattern = 1:length(patterns)
    hold on
    ax = gca;

    ax.Color = [1 1 1];     % set background colour to white
 
    % iterate over each sample
    for sample_idx = 1:size(numerosities, 1)
        % set x values for each dot
        x_vals = ones(size(data, 1), 1) * numerosities(sample_idx, 1);
        x_vals = x_vals + jitter_dots(pattern); % adjust with some jitter

        if in_detail
            for test_idx = 1:size(numerosities, 2)
                % Reaction Time
                if strcmp(data_type, 'Reaction Times')
                    % concat RTs for all test numbers & subject/sessions
                    data = vertcat(data{:, pattern, sample_idx, test_ind});
                    % adjust x vals
                    x_vals = ones(size(data, 1), 1);
                    x_vals = x_vals + jitter_dots(pattern); % adjust with some jitter
                end
                dot_plot = swarmchart(x_vals, ...
                    data(:, pattern, sample_idx, test_idx), mrksz * marker_factor);
                dot_plot.XJitter = "density";
                dot_plot.Marker = "o";
                %dot_plot.MarkerFaceColor = colours{pattern};
                dot_plot.MarkerFaceColor = "k";
                dot_plot.MarkerEdgeColor = "none";
                dot_plot.MarkerFaceAlpha = dot_alpha;
            end
        else
            % Reaction Time
            if strcmp(data_type, 'Reaction Times')
                % pre allocation
                dot_data = NaN(size(data, 1), 1);
                % iterate over subjects
                for sub_idx = 1:size(data, 1)
                    % concat RTs for all test numbers & subject/sessions
                    sub_data = vertcat(data{sub_idx, pattern, sample_idx, :});
                    dot_data(sub_idx) = mean(sub_data, "omitnan");
                end
            end
            dot_plot = swarmchart(x_vals, dot_data, mrksz * marker_factor);
            dot_plot.XJitter = "randn";
            dot_plot.XJitterWidth = 0.4 * max(jitter_dots);
            dot_plot.Marker = "o";
            %dot_plot.MarkerFaceColor = colours{pattern};
            dot_plot.MarkerFaceColor = "k";
            dot_plot.MarkerEdgeColor = "none";
            dot_plot.MarkerFaceAlpha = dot_alpha;
        end
    end
end

end