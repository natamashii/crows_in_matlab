clc
clear
close all

% pre allocation
pre_all = cell(1, 4);
during_all = cell(1, 4);
spikes_all = cell(1, 4);
penis = cell(1, 4);
sorted_size = zeros(1, 4);
mean_trial_all = {};
error_trial_all = {};

% pre definition
drug = 'GLU\';
to_save = false;
colours = {"-10", [0, 0.447, 0.7410];
    "-20", [0.85, 0.325, 0.098];
    "-40", [0.466, 0.674, 0.188];
    "-60", [0.887, 0.574, 0.949];
    "10", [0.012, 0.262, 0.43];
    "20", [0.684, 0.426, 0.156];
    "35", [0.5, 0.555, 0.125];
    "40", [0.285, 0.512, 0.375];
    "60", [0.8, 0.508, 0.723];
    "85", [0.555, 0.184, 0.359]};

frame_rate_spikes = 1000;   % in Hz
save_path = 'E:\GP_Julia\figures\16022025\';
path = "E:\GP_Julia\recordings\analyzed\16022025\";
load_path = path + 'analyzed\' + drug;
format = 'svg';
pre_stim = 15 * frame_rate_spikes;
post_stim = 15 * frame_rate_spikes;
to_norm = 'Julia_approach';  % change to 'other_approach' for z score

% load data
files = dir(load_path + "*.mat");
file_names = {files.name};
file_names = extractBefore(file_names, ".mat");
rat_names = extractBefore(file_names, '_');
cell_names = extractBefore(extractAfter(file_names, '_'), '_');
neuron_names = extractBefore(extractAfter(extractAfter(extractAfter(file_names, '_'), cell_names), '_'), '_');
drug_names = extractBefore(extractAfter(extractAfter(extractAfter(file_names, '_'), neuron_names), '_'), '_');
current_names = extractBefore(extractAfter(extractAfter(extractAfter(extractAfter(file_names, '_'), drug_names), '_'), '_'), 'nA');

% identify uniques
rat_uniques = unique(rat_names);
cell_uniques = unique(cell_names);
neuron_uniques = unique(neuron_names);
drug_uniques = unique(drug_names);
current_uniques = unique(current_names);

% find indices of unique currents and append another cell/array with those
% inside for each current value

current_uniques{2, 1} = [];
for current = 1:size(current_uniques, 2)
    idx = find(ismember(current_names, current_uniques(1, current)));
    sorted_size(current) = numel(idx);
    current_uniques{2, current} = idx;
    % iterate over indices & extract data
    placeholder = {};
    penis_placeholder = {};
    pre_placeholder = {};
    during_placeholder = {};
    mean_placeholder = {};
    error_placeholder = {};
    for i = idx
        penis_placeholder{end + 1} = load(load_path + file_names(i) + '.mat');
        placeholder{end + 1} = penis_placeholder{end}.spike_snippets;
        mean_placeholder{end + 1} = penis_placeholder{end}.mean_trial;
        error_placeholder{end + 1} = penis_placeholder{end}.error_trial;
        pre_placeholder{end + 1} = placeholder{end}(:, 1:pre_stim);
        during_placeholder{end + 1} = placeholder{end}(:, pre_stim:end - post_stim);
    end
    penis{current} = penis_placeholder;
    spikes_all{current} = placeholder;
    pre_all{current} = pre_placeholder;
    during_all{current} = during_placeholder;
    mean_trial_all{current} = mean_placeholder;
    error_trial_all{current} = error_placeholder;
end

% get mean + error
% pre allocation
pre_mean = zeros(max(sorted_size), size(current_uniques, 2));
pre_mean(:) = NaN;
during_mean = zeros(max(sorted_size), size(current_uniques, 2));
during_mean(:) = NaN;
pre_error = zeros(4, max(sorted_size), size(current_uniques, 2));
pre_error(:) = NaN;
during_error = zeros(4, max(sorted_size), size(current_uniques, 2));
during_error(:) = NaN;
normalized = zeros(2, max(sorted_size), size(current_uniques, 2));
normalized(:) = NaN;
norm_mean = zeros(2, 4);
norm_error = zeros(4, 4);

% iterate over current values
for current = 1:size(current_uniques, 2)
    mean_trial = mean_trial_all{1, current};
    error_trial = error_trial_all{1, current};
    pre = pre_all{1, current};
    during = during_all{1, current};
    for p = 1:numel(mean_trial)
        mean_rn = mean_trial{1, p};
        error_rn = error_trial{1, p};
        pre_rn = pre{1, p};
        during_rn = during{1, p};
        % get mean values
        pre_mean(p, current) = mean_rn(1);
        during_mean(p, current) = mean_rn(2);
        % calculate error directly from data
        pre_error(1, p, current) = error_rn(1, 1);
        pre_error(2, p, current) = error_rn(1, 2);
        during_error(1, p, current) = error_rn(2, 1);
        during_error(2, p, current) = error_rn(2, 2);
        % calculate error based on trial-wise mean
        pre_mean_trial = mean(pre_rn, 2) * frame_rate_spikes;
        during_mean_trial = mean(during_rn, 2) * frame_rate_spikes;
        pre_error(3, p, current) = std(pre_mean_trial, [], "all");
        pre_error(4, p, current) = std(pre_mean_trial, [], "all") / ...
            sqrt(numel(pre_mean_trial));
        during_error(3, p, current) = std(during_mean_trial, [], "all");
        during_error(4, p, current) = std(during_mean_trial, [], "all") / ...
            sqrt(numel(during_mean_trial));
        % normalize mean
        switch to_norm
            case 'Julia_approach'
                % with STD from data directly
                normalized(1, p, current) = ...
                    during_mean(p, current) - (pre_mean(p, current) / pre_error(1, p, current));
                % with STD from mean of trials
                normalized(2, p, current) = ...
                    during_mean(p, current) - (pre_mean(p, current) / pre_error(3, p, current));
            case 'other_approach'
                % with STD from data directly
                normalized(1, p, current) = ...
                    (during_mean(p, current) - pre_mean(p, current)) / pre_error(1, p, current);
                % with STD from mean of trials
                normalized(2, p, current) = ...
                    (during_mean(p, current) - pre_mean(p, current)) / pre_error(3, p, current);
        end
    end
end

% get mean & error of normalized data
norm_mean(1, :) = mean(reshape(normalized(1, :, :), 18, 4), 1, "omitnan");
norm_mean(2, :) = mean(reshape(normalized(2, :, :), 18, 4), 1, "omitnan");
norm_error(1, :) = std(reshape(normalized(1, :, :), 18, 4), [], 1, "omitnan");
norm_error(2, :) = std(reshape(normalized(1, :, :), 18, 4), [], 1, "omitnan") / ...
    sqrt(sum(~isnan(normalized(1, :, :)), "all"));
norm_error(3, :) = std(reshape(normalized(2, :, :), 18, 4), [], 1, "omitnan");
norm_error(4, :) = std(reshape(normalized(2, :, :), 18, 4), [], 1, "omitnan") / ...
    sqrt(sum(~isnan(normalized(2, :, :)), "all"));

% Perform Statistics
groups = string({current_uniques{1, :}});
inn = reshape(normalized(1, :, :), 18, 4);
[p, tbl, stats] = kruskalwallis(inn, groups, "off");
% Eta Squared
eta2 = mes1way(inn, 'eta2');

% Mann-Whitney U test
p_mann = zeros(1, 6);
p_mann(:) = NaN;
tbl_mann = zeros(1, 6);
tbl_mann(:) = NaN;
u_stats = zeros(1, 6);
u_stats(:) = NaN;
rank_bi = zeros(1, 6);
rank_bi(:) = NaN;
z_mann = zeros(1, 6);
z_mann(:) = NaN;
r_mann = zeros(1, 6);
r_mann(:) = NaN;
r2_mann = zeros(1, 6);
r2_mann(:) = NaN;



% Mann Whitney U + Effect Size
combinations = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4];
for run = 1:size(combinations, 1)
    % Mann Whitney U test
    [p_mann(run), tbl_mann(run), stats_mann] = ...
        ranksum(inn(:, combinations(run, 1)), inn(:, combinations(run, 2)));
    % U statistics
    n1 = sum(~isnan(inn(:, combinations(run, 1))));
    n2 = sum(~isnan(inn(:, combinations(run, 2))));
    rsum = stats_mann.ranksum;
    U = rsum - (n1 * (n1 + 1) / 2);
    u_stats(run) = U;
    % rank-biserial correlation
    rank_bi(run) = 1 - (2 * U) / (n1 * n2);
    [z_mann(run), r_mann(run), r2_mann(run)] = ...
        effect_size_mannwhitney(inn(:, combinations(run, 1)), inn(:, combinations(run, 2)));

end
% Bonferroni Correction
[corr_p, corr_h] = bonf_holm(p_mann);

% create plot
fig = figure();

fig.Units = "centimeters";
fig.PaperUnits = "centimeters";
pos = get(gcf, 'Position');
width = 20;
height = 10;
set(gcf, "PaperSize", [width height], 'PaperPosition', [0 0 width height])

tiled = tiledlayout(fig);
tiled.Padding = "compact";
hold on
leg = legend();
leg.Location = "bestoutside";
leg.Box = "off";

% define x values
x = 1:2:size(current_uniques, 2) * 2;
x_jitters = zeros(size(x));

% get all colours needed for the plot
all_colours = {colours{ismember([colours{:, 1}], current_uniques(1, :)), 2}};
% jitter x values 
jitter_width = .3;
x_low = x - jitter_width;
x_high = x + jitter_width;
jitters = {};
% iterate over all cells and plot them with a line
for c = 1:size(inn, 1)
    x_jitters = zeros(4, 1);
    for i = 1:4
        x_jitters(i) = random('Normal', x(i), jitter_width);
    end
    jitters{end + 1} = x_jitters;
    % line plot
    line = plot(x_jitters, inn(c, :));
    line.Color = [0, 0, 0, .2];
    line.LineWidth = .3;
    line.Annotation.LegendInformation.IconDisplayStyle = "off";
end
jitters = cell2mat(jitters)';
for c = 1:size(current_uniques, 2)
    % bobbels
    bobbel = scatter(jitters(:, c), inn(:, c));
    bobbel.Marker = "o";
    bobbel.SizeData = 50;
    bobbel.MarkerFaceColor = all_colours{c};
    bobbel.MarkerEdgeColor = all_colours{c};
    bobbel.DisplayName = string(current_uniques(1, c)) + " nA";
end

% plot mean
scat = plot(x, norm_mean(1, :), '-');
scat.Color = "k";
scat.Marker = "o";
scat.MarkerSize = 7;
scat.MarkerFaceColor = "k";
scat.MarkerEdgeColor = "k";
scat.LineWidth = 1.5;
scat.DisplayName = "Mean";

% Plot error
err = errorbar(x, norm_mean(1, :), norm_error(2, :));
err.Color = "k";
err.LineWidth = 1.5;
err.CapSize = 7.5;
err.DisplayName = "SEM";


% Adjust Figure
xticks(x(1, :))
xticklabels(groups);
xlim([min(jitters, [], "all") - .2 max(jitters, [], "all") + .2])

xlabel("Current [nA]")
ylh = ylabel("Normalized Firing Rate [Hz]");
ylh.Position(1) = ylh.Position(1) -.2;

fontname(fig, "Times")
fontsize(12, "points")

fig.Renderer = "painters";
fig_name = strcat(drug(1:end-1), 'population.svg');
if to_save
    saveas(fig, [save_path, fig_name], 'svg')
end

close all