function fig_pretty = ...
    plot_num_dist(numerosities, plot_font, plot_pos, colour, linewidth)

% Function to Plot Distribution of used Numerosities

% get all numerosities used & their frequency
[freq_nums, used_nums] = groupcounts(reshape(numerosities, [], 1));

% Create Figure
fig = figure("Visible", "off");

ax = gca;
hold on

% Make Colour bit Darker for Edge
edge_colour = rgb2hsv(colour);
edge_colour(:, 3) = edge_colour(:, 3) * .7;
edge_colour = hsv2rgb(edge_colour);

% Plot Frequency of Numerosities
num_hist = histogram(reshape(numerosities, [], 1), "BinMethod", "integers");
num_hist.FaceColor = colour;
num_hist.EdgeColor = edge_colour;
num_hist.LineWidth = linewidth;

% Plot Improvements
axis padded
ax.Color = [1 1 1];     % set bakcground colour to white
ax.XColor = "k";    % set y-axis colour to black
ax.YColor = "k";    % set x-axis colour to black
ax.FontWeight = "bold";
ax.XAxis.FontSize = plot_font;  % set fontsize of x ticks
ax.YAxis.FontSize = plot_font;  % set fontsize of y ticks
ax.XTick = used_nums;
ax.XTickLabel = num2str(used_nums);
ax.XTickLabelRotation = 0;
ax.XLim = [min(used_nums) - .5 max(used_nums) + .5];
ax.YLim = [0 max(freq_nums) + .5];
ax.YTick = 0:max(freq_nums);
xlabel(ax, "Numerosity", "FontWeight", "bold");
ylabel(ax, "Numerosity Frequency [#]", "FontWeight", "bold")
set(gca, "TickDir", "out")
set(ax, "linewidth", 2)

% Figure Adjustments
fig_title = title('Distribution of Numerosities');
[fig_pretty, ~] = ...
    prettify_plot(fig, plot_pos, fig_title, plot_font, ...
    false, [], []);

end