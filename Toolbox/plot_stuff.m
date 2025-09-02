function fig_pretty = ...
    plot_stuff(ind_data, avg_data, err_data, numerosities, patterns, ...
    calc_type, err_type, what_analysis, who_analysis, ...
    experiment, plot_font, colours, plot_pos, in_detail)

% Function to plot the data

% pre definition
jitter_dots = [-0.2, 0, 0.2];

% Create Figure
fig = figure();
% figure title
fig_title = title([calc_type ' ' what_analysis ' of ' ...
    who_analysis(1:end-1) ' in ' experiment ' Sample Time ']);

% Plot single data points
ax = plot_ind(numerosities, ind_data, jitter_dots, colours, patterns, in_detail);


% plot the stuff
[ax, dot_plots, leg_patch, leg_label] = ...
    plot_first(numerosities, jitter_dots, avg_data, ...
    squeeze(err_data(1, :, :)), squeeze(err_data(2, :, :)), ...
    patterns, colours, plot_font, what_analysis, err_type);

% Plot Improvement
[fig_pretty, fig_title_pretty] = ...
    prettify_plot(fig, plot_pos, fig_title, plot_font, ...
    true, leg_patch, leg_label);

% Subplot Adjustments
if strcmp(what_analysis, 'Reaction Times') && strcmp(who_analysis, 'humans')
    ax.YLim = [200 600];
elseif strcmp(what_analysis, 'Reaction Times') && ~strcmp(who_analysis, 'humans')
    ax.YLim = [100 350];
else
    ax.YLim = [0 1.1];
    ax.YTick = (0:0.2:1);
end

if strcmp(what_analysis, 'Reaction Times')
    ylabel(ax, "Reaction Times [ms]")
else
    ylabel(ax, what_analysis)
end

end