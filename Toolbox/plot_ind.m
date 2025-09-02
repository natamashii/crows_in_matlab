function ax = ...
    plot_ind(numerosities, data, jitter_dots, colours, patterns, in_detail)

% Function to plot individual data points of each subject/session

linewidth = 1;
dot_alpha = 0.5;

% iterate over patterns
for pattern = 1:length(patterns)
    hold on
    ax = gca;

    ax.Color = [1 1 1];     % set background colour to white

    % iterate over each sample
    for sample_idx = 1:size(numerosities, 1)
        x_vals = ones(size(data, 1), 1) * numerosities(sample_idx, 1);

        if in_detail
            % iterate over test numbers
            for test_idx = 1:size(numerosities, 2)
                dot_plot = scatter(x_vals, data(:, pattern, sample_idx, test_idx));
                dot_plot.Marker = "o";
                dot_plot.Color = dot_colour;
                dot_plot.MarkerFaceColor = dot_colour;
                dot_plot.MarkerEdgeColor = "none";
            end
        else
            dot_data = mean(squeeze(data(:, pattern, sample_idx, :)), 2, "omitnan");
            dot_plot = plot(x_vals, dot_data);
            dot_plot.Marker = "o";
            dot_plot.Color = dot_colour;
            dot_plot.MarkerFaceColor = dot_colour;
            dot_plot.MarkerEdgeColor = "none";
        end
    end
end

end