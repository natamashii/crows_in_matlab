function [fig_pretty, fig_title_pretty] = ...
    prettify_plot(fig, plot_pos, fig_title, plot_font, ...
    add_legend, leg_patch, leg_label, leg_title, mrksz, ax)

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
    h_copy = copyobj(leg_patch, ax);
    set(h_copy(1:end-1), "XData", NaN', "YData", NaN)
    h_copy(end).MarkerSize = mrksz * 20;
    leg = ...
        legend(h_copy, leg_label, ...
        "Box", "off", ...
        "Location", "bestoutside", ...
        "TextColor", "k", ...
        "FontSize", plot_font, ...
        "FontWeight", "bold");
    title(leg, leg_title, 'FontSize', plot_font)
end

fig.Renderer = "painters";

fig_pretty = fig;  % Assign the modified figure to output
fig_title_pretty = fig_title;  % Assign the modified title to output

end