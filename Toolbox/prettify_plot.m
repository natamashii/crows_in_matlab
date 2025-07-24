function ax_pretty = prettify_plot(ax, x_lim, y_lim, x_label, x_ticks, y_label, y_ticks, ax_title)

% function to make subplot prettier

% pre allocation
leg_patch = [];
leg_labels = string();

set(gca, 'Color', [1 1 1])	% set subplot background to white
set(gca, 'XColor', 'k', 'YColor', 'k');

% plot-specific adjustments
switch ax_type
    % normal line plot
    case
        ax.LineStyle = "-";
        ax.LineWidth = 1.5;
        ax.MarkerEdgeColor = "none";

        % errorbar
    case
        ax.CapSize = 10;
        ax.LineWidth = 1.5;





end

% adjust axes
xlim(x_lim)
ylim(y_lim)


xlabel(x_label)		% set subplot x axis label
ylabel(y_label)		% set subplot y axis label

xticks(x_ticks{1}, x_ticks{2})		% set subplot x axis ticks & ticklabels
yticks(y_ticks{1}, y_ticks{2})		% set subplot y axis ticks & ticklabels

title(ax_title)		% set subplot title

ax_pretty = ax;

end
