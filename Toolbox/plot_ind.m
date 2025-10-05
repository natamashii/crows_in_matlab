function ax = ...
    plot_ind(ind_data, jitterwidth, dot_alpha, marker_factor, ...
    colours, pattern, mrksz, what_analysis, focus_type)

% Function to plot individual data points of each subject/session

hold on
ax = gca;

switch focus_type
    case 'Overall'
        % Iterate over patterns
        if strcmp(what_analysis, 'Reaction Times')
            % Concat RTs for All Test Numbers, Samples &
            % Subject/Sessions
            y_vals = vertcat(ind_data{:, pattern, :, :});
        else    % Performance/Response Frequency
            % Pre Allocation
            y_vals = NaN(size(ind_data, 1));
            % Iterate over Subjects/Sessions & Take Mean
            for sub_idx = 1:size(ind_data, 1)
                y_vals(sub_idx) = ...
                    mean(ind_data(sub_idx, pattern, :, :), ...
                    "all", "omitnan");
            end
        end
    case 'Matches'
        % Iterate over patterns
        if strcmp(what_analysis, 'Reaction Times')
            % Concat RTs for All Test Numbers, Samples &
            % Subject/Sessions
            y_vals = vertcat(ind_data{:, pattern, :, 1});
        else    % Performance/Response Frequency
            % Pre Allocation
            y_vals = NaN(size(ind_data, 1));
            % Iterate over Subjects/Sessions & Take Mean
            for sub_idx = 1:size(ind_data, 1)
                y_vals(sub_idx) = ...
                    mean(ind_data(sub_idx, pattern, :, 1), ...
                    "all", "omitnan");
            end
        end
end

% Adjust x vals
x_vals = ones(size(y_vals, 1), 1) * pattern;

% Plot
dot_plot = swarmchart(x_vals, y_vals, mrksz * marker_factor, ...
    "XJitter", "randn", ...
    "XJitterWidth", jitterwidth, ...
    "Marker", "o", ...
    "MarkerFaceColor", colours, ...
    "MarkerEdgeColor", "none", ...
    "MarkerFaceAlpha", dot_alpha);

end