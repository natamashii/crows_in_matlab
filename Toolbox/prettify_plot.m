function [fig_pretty, fig_title_pretty] = ...
    prettify_plot(fig, plot_pos, fig_title, plot_font, ...
    add_legend, leg_patch, leg_label)

% function to improve overall figure

set(gcf, 'Color', [1 1 1])  % set figure background to white

% change figure size
set(gcf, 'PaperUnits', 'points')
set(gcf, 'PaperSize', [plot_pos(1) plot_pos(2)])

% figure title
fig_title.FontSize = plot_font;
fig_title.Color = "k";
fig_title.FontWeight = "bold";

% Add legend if desired
if add_legend
    leg = legend(leg_patch, leg_label);
    leg.Location = "bestoutside";
    leg.Box = "off";
    leg.TextColor = "k";
    leg.FontSize = plot_font;
    title(leg, 'Pattern', 'FontSize', plot_font)
end

fig.Renderer = "painters";

fig_pretty = fig;  % Assign the modified figure to output
fig_title_pretty = fig_title;  % Assign the modified title to output

end