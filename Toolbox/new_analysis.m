clc
clear
close all

% hardcoded variables
% Pre Processing
preprocess = false;
plot_drh_bar = true;
path = "E:\GP_Julia\recordings\analyzed\16022025\";
load_path = path + 'analyzed\';
pre_stim = 15;   % in s
post_stim = 15;    % in s
current_thr = 16;   % in nA, set threshold to detect ejection periods

% PSTH
window = 4001;  % in ms
stepsize = 1;    % in spike frames
error_type = 'sem';     % toggle to change error type (STD, SEM)
stimulus_threshold = 65000; % maximum allowed stimulus (with pre & post) size
frame_rate_current = 1; % in Hz
frame_rate_spikes = 1000;   % in Hz

% convert pre stimulus period to indices
pre_stim = pre_stim * frame_rate_spikes;
post_stim = post_stim * frame_rate_spikes;

% Identify Files
% find all MAT files & extract names
files = dir(path + "*.mat");
file_names = {files.name};

rat_names = extractBefore( ...
    extractBetween(file_names, "GP24_", "_sorted.nex.mat"), 3);
cell_names = extractBetween( ...
    extractBetween(file_names, "GP24_", "_sorted.nex.mat"), 4, 5);
drug_names = extractAfter( ...
    extractBetween(file_names, "GP24_", "_sorted.nex.mat"), cell_names);
drug_names = regexp(drug_names, '_', 'split');
current_values = ...
    str2double(string(cellfun(@(x)x(end), drug_names, "UniformOutput", false)));
drug_names = cellfun(@(x)x(2:end-1), drug_names, "UniformOutput", false);
% adjust current values depending on used drug
current_values(:) = -current_values(:);
current_values(find([drug_names{:}] == "GABA")) = ...
    -current_values(find([drug_names{:}] == "GABA"));

% Perform Analysis
% iterate over all recordings
if preprocess
    for rec = 1:numel(files) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %for rec = 1:1   % debug
        % load data
        current_rec = load(path + file_names(rec), "RecData").RecData();
        drugs = string(current_rec.Electrodes.DrugName());
        spikes = current_rec.SpikeData();
        barrelcurrents = current_rec.Electrodes.BarrelCurrent();
        time_stamps = current_rec.Electrodes.ADTimeStamps();
        neuron_name = string(current_rec.NeuronName());

        % iterate over identified units
        for neuron = 1:numel(spikes)
            % differentiate between used channels
            for channel = 1:numel(barrelcurrents)
                % pre allocation
                file_info = struct;

                % specify the data
                current_trace = cell2mat(barrelcurrents(channel));
                spike_trace = cell2mat(spikes(neuron));
                time_current = cell2mat(time_stamps(channel));
                current_drug = drugs(channel);
                current_value = current_values(rec);

                % snippling
                [spike_snippets, stimulus_length] = ...
                    snippling(pre_stim, post_stim, ...
                    frame_rate_spikes, spike_trace, ...
                    current_trace, time_current, current_thr, current_value);

                % continue if this is senseful
                if ~isempty(spike_snippets)

                    % PSTH
                    [psth, error, psth_error] = ...
                        comp_psth(spike_snippets, window, stepsize, frame_rate_spikes);

                    % mean + error in period
                    [mean_trial, error_trial, mean_error_trial] = ...
                        avg_period(spike_snippets, pre_stim, post_stim, frame_rate_spikes);

                    % statistical testing of pre-during-post
                    [p_kruskal, eta2, corr_p, corr_h, rbcorr, p_friedman, W] = ...
                        single_cell_statistics(spike_snippets, pre_stim, post_stim);

                    % save the data
                    file_info.rat = rat_names{rec};
                    file_info.cell = cell_names{rec};
                    file_info.current_value = current_value;
                    file_info.drug = drugs(channel);
                    file_info.channel = channel;
                    file_info.stimulus_length = stimulus_length;
                    file_info.spike_snippets = spike_snippets;
                    file_info.psth = psth;
                    file_info.error = error;
                    file_info.psth_error = psth_error;
                    file_info.mean_trial = mean_trial;
                    file_info.error_trial = error_trial;
                    file_info.mean_error_trial = mean_error_trial;
                    file_info.p_kruskal = p_kruskal;
                    file_info.eta2 = eta2;
                    file_info.corr_p = corr_p;
                    file_info.corr_h = corr_h;
                    file_info.rbcorr = rbcorr;
                    file_info.p_friedman = p_friedman;
                    file_info.W = W;

                    save(strcat(char(path + 'analyzed\'), ...
                        char(rat_names{rec}), '_', char(cell_names{rec}), ...
                        '_', neuron_name{neuron}, '_', drugs(channel), '_', ...
                        num2str(channel), '_', num2str(current_value), 'nA', '.mat'), '-struct', 'file_info')
                    close all
                end
            end
        end
    end
end

% Plotting
% pre allocation
sorting = {};

% pre definition
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

save_path = 'E:\GP_Julia\figures\16022025\';
format = 'svg';
pre_stim = 15;
post_stim = 15;

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

% group to identify which files belong together
% iterate over rats
for rat = 1:numel(rat_uniques)
    % iterate over cells
    for cel = 1:numel(cell_uniques)
        % iterate over neurons
        for neuron = 1:numel(neuron_uniques)
            % iterate over drugs
            for drug = 1:numel(drug_uniques)
                name = {rat_uniques{rat}, cell_uniques{cel}, neuron_uniques{neuron}, drug_uniques{drug}};
                name = strjoin(name, '_');
                % find recordings with this combination
                rec_idx = find(~cellfun(@isempty, strfind(file_names, name)));
                % sort those together
                if sum(rec_idx) > 0
                    current = string({current_names{rec_idx}});
                    sorting{end + 1} = {name, rec_idx, current, drug_uniques{drug}};
                end
            end
        end
    end
end

% plotting
if plot_drh_bar
    for p = 1:numel(sorting)
    %for p = 1:1     % for debugging
        % pre allocation
        penis = {};
        spikes = {};
        psth = {};
        error = {};
        psth_error = {};
        stimulus_lengths = {};
        mean_error_trial = {};
        mean_trial = {};
        error_trial = {};
        y_counter = 1;    % counter variable to assign y values for DRH
        current_counter = 1;    % counter variable to assign legend entry for DRH

        s = sorting{1, p};
        rec_idx = s{1, 2};
        name = s{1, 1};
        current = s{1, 3};
        drug = s{1, 4};

        % load the data
        for rec = 1:numel(rec_idx)
            penis{end + 1} = load(load_path + file_names{rec_idx(rec)} + '.mat');
            spikes{end + 1} = penis{rec}.spike_snippets;
            psth{end + 1} = penis{rec}.psth;
            error{end + 1} = penis{rec}.error;
            psth_error{end + 1} = penis{rec}.psth_error;
            stimulus_lengths{end + 1} = penis{rec}.stimulus_length;
            mean_error_trial{end + 1} = penis{rec}.mean_error_trial;
            mean_trial{end + 1} = penis{rec}.mean_trial;
            error_trial{end + 1} = penis{rec}.error_trial;
        end

        % extract amount of trials for each ejection current tested
        sizes = cell2mat(cellfun(@size, spikes, 'uni', false));
        repetitions = sizes(1:2:end);

        % stack each cell to 2D array
        spikes = cell_convert(spikes);
        psth = cell_convert(psth);
        error = cell_convert(error);
        psth_error = cell_convert(psth_error);
        mean_trial = cell_convert(mean_trial);
        error_trial = cell_convert(error_trial);
        mean_error_trial = cell_convert(mean_error_trial);
        stimulus_lengths = [stimulus_lengths{:}];
        stimulus_lengths = cat(2, stimulus_lengths{:});

        % cut off if too long
        if size(spikes, 2) > stimulus_threshold
            spikes = spikes(:, 1:stimulus_threshold);
            psth = psth(:, 1:stimulus_threshold);
            error = error(:, 1:stimulus_threshold);
            psth_error = psth_error(:, 1:stimulus_threshold);
        end

        % Statistics between currents
        ppre_stim = 15 * frame_rate_spikes;
        ppost_stim = 15 * frame_rate_spikes;
        [corr_p, corr_h, rbcorr, p_friedman, W] = ...
            inter_current_stat(spikes, repetitions, frame_rate_spikes, current, ppre_stim, ppost_stim);

        % save statistical data
        stats_current = struct;
        stats_current.corr_p = corr_p;
        stats_current.corr_h = corr_h;
        stats_current.rbcorr = rbcorr;
        stats_current.p_friedman = p_friedman;
        stats_current.W = W;
        save(strcat(char(load_path + 'inter_current_test\'), name, '.mat'), ...
            '-struct', 'stats_current')
        close all

        % set time axis in s
        time = linspace(-pre_stim, max(stimulus_lengths) + post_stim, size(spikes, 2));
        % set y axis for DRH
        y_drh = zeros(1, sum(repetitions, "all"));
        c_drh = cell(1, sum(repetitions, "all"));
        leg_drh = zeros(1, sum(repetitions, "all"));
        for y = 1:numel(repetitions)
            % assign y values
            y_drh(y_counter:y_counter + repetitions(y)) = ...
                y_counter:1:y_counter + repetitions(y);
            % assign colour values
            for c_idx = y_counter:y_counter + repetitions(y)
                c_drh{c_idx} = colours{ismember([colours{:, 1}], current(y)), 2};
            end
            % set true to current current (needed for legend)
            leg_drh(y_counter) = 1;
            % update counter
            y_counter = y_counter + repetitions(y);
        end

        % Plotting
        set(0,'DefaultFigureVisible','off');
        fig_drh = figure(p);
        fig_drh.Units = "centimeters";
        fig_drh.PaperUnits = "centimeters";
        pos = get(gcf, 'Position');
        width = 40;
        height = 50;
        set(gcf, "PaperSize", [width height], 'PaperPosition', [0 0 width height])

        tiled = tiledlayout(fig_drh, 9, 1);
        tiled.TileSpacing = "loose";
        tiled.Padding = "compact";



        % Dot Raster Histogram
        ax1 = nexttile(tiled, [2 1]);
        hold on

        % create legend
        leg = legend();
        leg.Location = "bestoutside";
        leg.Box = "off";

        % mark stimulus interval
        interval = area([0, max(stimulus_lengths)], ...
            [size(spikes, 1) + .5, size(spikes, 1) + .5]);
        interval.FaceColor = "k";
        interval.FaceAlpha = .15;
        interval.EdgeColor = "none";
        interval.DisplayName = "Ejection";

        % plot trial-wise DRH
        for trial = 1:size(spikes, 1)
            leg.AutoUpdate = "off";
            % extract relevant x values
            x = time(spikes(trial, :) > 0);
            % create y array
            y = zeros(1, size(x, 2));
            y(:) = y_drh(trial);
            % plot
            drh = scatter(x, y, 80, "|");
            drh.LineWidth = 1;
            drh.MarkerFaceColor = c_drh{trial};
            drh.MarkerEdgeColor = c_drh{trial};
            %drh.DisplayName = current(current_counter) + " nA";
            if leg_drh(trial)
                leg.AutoUpdate = "on";
                h = plot(nan, nan, "|");
                h.MarkerSize = 20;
                h.LineWidth = 3;
                h.MarkerFaceColor = c_drh{trial};
                h.MarkerEdgeColor = c_drh{trial};
                h.DisplayName = current(current_counter) + " nA";
                current_counter = current_counter + 1;
            end
        end
        % adjust the plot
        ylim([0 size(y_drh, 2)])
        yticks([])
        xlim([time(1) - .2 time(end)])
        %set(findobj(leg, 'type', 'Scatter'), 'Size', 200)

        % PSTH

        % extract mean+sem
        error_up = psth_error(3:4:end, :);
        error_down = psth_error(4:4:end, :);
        % convert NaNs to 0
        error_up(isnan(error_up)) = 0;
        error_down(isnan(error_down)) = 0;

        ax2 = nexttile(tiled, [2 1]);
        hold on

        % create legend
        leg = legend();
        leg.Location = "bestoutside";
        leg.Box = "off";
        leg.NumColumns = 2;

        % mark stimulus interval
        interval = area([0,  max(stimulus_lengths)], ...
            [max(psth(:)) + 0.2 * max(psth(:)), max(psth(:)) + 0.2 * max(psth(:))]);
        interval.FaceColor = "k";
        interval.FaceAlpha = .15;
        interval.EdgeColor = "none";
        interval.DisplayName = "Ejection";

        % add SEM shading
        sem_patch = [];
        sem_label = strings();
        for trial = 1:size(psth, 1)
            % extract colour
            c_plot = colours{ismember([colours{:, 1}], current(trial)), 2};
            error_shade = fill([time, fliplr(time)], ...
                [error_down(trial, :), fliplr(error_up(trial, :))], c_plot);
            error_shade.EdgeColor = "none";
            error_shade.FaceAlpha = .3;
            error_shade.DisplayName = "SEM";
            sem_patch(end + 1) = error_shade;
            sem_label(trial) = error_shade.DisplayName;
        end

        % plot PSTH curve
        psth_patch = [];
        psth_label = strings();
        for trial = 1:size(psth, 1)
            % extract colour
            c_plot = colours{ismember([colours{:, 1}], current(trial)), 2};
            psth_curve = plot(time, psth(trial, :));
            psth_curve.LineWidth = 2;
            psth_curve.Color = c_plot;
            psth_curve.LineStyle = "-";
            psth_curve.DisplayName = current(trial) + " nA";
            psth_patch(end + 1) = psth_curve;
            psth_label(trial) = psth_curve.DisplayName;
        end
        legend_handles = [flip(psth_patch), interval, flip(sem_patch)];
        legend_entries = [flip(psth_label), interval.DisplayName, flip(sem_label)];

        % adjust the plot
        ylh2 = ylabel(ax2, "Firing Rate [$\frac{Spikes}{s}$]");
        ylh2.Interpreter = "latex";
        xlim([time(1) time(end)])
        ylim([0 max(psth(:)) + 0.2 * max(psth(:))])
        % adapt order of legend
        leg = legend(legend_handles, legend_entries);

        % Ideal Current Curves
        current = str2double(current(:));

        % create ideal current curve
        ideal_current = zeros(size(current, 1), size(time, 2));
        if drug == "GABA"
            ideal_current(:) = -7;
            stim_lim = [-10, 90];
        else
            ideal_current(:) = 7;
            stim_lim = [10, -70];
        end

        ax3 = nexttile(tiled, [2 1]);
        hold on

        leg = legend();
        leg.Location = "bestoutside";
        leg.Box = "off";

        % mark stimulus interval
        interval = fill([0, max(stimulus_lengths), max(stimulus_lengths), 0], ...
            [stim_lim(1), stim_lim(1), stim_lim(2), stim_lim(2)], "k");
        interval.FaceColor = "k";
        interval.FaceAlpha = .15;
        interval.EdgeColor = "none";
        interval.DisplayName = "Ejection";
        % or make it drug depend in a new function...

        for trial = 1:size(current, 1)
            % adapt values of ideal current curve
            [~, start_idx] = min(abs(time - 0));
            [~, stop_idx] = min(abs(time - max(stimulus_lengths)));
            ideal_current(trial, start_idx:stop_idx) = current(trial);
            % extract colour
            c_plot = colours{ismember([colours{:, 1}], num2str(current(trial))), 2};
            % plot ideal current
            current_plot = plot(time, ideal_current(trial, :));
            current_plot.LineStyle = "-";
            current_plot.LineWidth = 2;
            current_plot.Color = c_plot;
            current_plot.DisplayName = num2str(current(trial)) + " nA";
        end

        % adjust the plot

        ylh3 = ylabel(ax3, "Current [nA]");
        xlabel(ax3, "Time [s]")
        xlim([time(1) time(end)])
        x_label = get(ax3, 'XLabel');
        x_labelpos = get(x_label, 'position');
        x_labelpos(1) = 17;
        x_labelpos(2) = -80;
        x_labelpos(3) = 1;
        set(x_label, 'position', x_labelpos)

        if drug == "GABA"
            ylim([-10 90])
            ytick_labels = vertcat([-10, 0, 10:20:90]);
        else
            ylim([-70 10])
            ytick_labels = vertcat([-70:20:-10, 0, 10]);
        end
        yticks(sort(ytick_labels))
        leg.Direction = "reverse";





        % Barplot
        bar_width = 0.8;
        groupwidth = min(bar_width, 3 / (3 + 1.5));

        % define x axis
        x = [1, 2, 3, 4];
        x_err = zeros(4, 3);
        y_err = zeros(4, 3);
        x_err(:, 1) = x - groupwidth / 2 + (2 * 1 - 1) * groupwidth / (2 * 3);
        x_err(:, 2) = x;
        x_err(:, 3) = x - groupwidth / 2 + (2 * 3 - 1) * groupwidth / (2 * 3);

        % array for bar plotting
        mean_bar = zeros(4, 3);


        % adapt x ticks based on drug
        if numel(current) < 4
            switch drug
                case "GLU"
                    % define mean_bar at corresponding positions
                    placeholder = [-10, -20, -40, -60];
                    [~, indices] = ismember(current, placeholder);
                    for i = 1:numel(indices)
                        mean_bar(indices(i), :) = mean_trial(i, :);
                        y_err(indices(i), :) = error_trial(i * 2, :);
                    end
                case "NaCl"
                    placeholder = [-10, -20, -40, -60];
                    [~, indices] = ismember(current, placeholder);
                    for i = 1:numel(indices)
                        mean_bar(indices(i), :) = mean_trial(i, :);
                        y_err(indices(i), :) = error_trial(i * 2, :);
                    end
                case "GABA"
                    if sum(ismember(name, 'C4')) > 1
                        placeholder = [10, 20, 40, 60];
                        [~, indices] = ismember(current, placeholder);
                        for i = 1:numel(indices)
                            mean_bar(indices(i), :) = mean_trial(i, :);
                            y_err(indices(i), :) = error_trial(i * 2, :);
                        end
                    else
                        placeholder = [10, 35, 60, 85];
                        [~, indices] = ismember(current, placeholder);
                        for i = 1:numel(indices)
                            mean_bar(indices(i), :) = mean_trial(i, :);
                            y_err(indices(i), :) = error_trial(i * 2, :);
                        end
                    end
            end
        else
            placeholder = current;
            for c = 1:size(mean_trial, 1)
                mean_bar(c, :) = mean_trial(c, :);
                y_err(c, :) = error_trial(c * 2, :);

            end
        end

        ax4 = nexttile(tiled, [3 1]);
        hold on

        % define legend
        leg_bar = legend();
        leg_bar.Location = "bestoutside";
        leg_bar.Box = "off";

        % iterate over used current values
        for c = 1:size(mean_bar, 1)
            % extract colour
            c_plot = colours{ismember([colours{:, 1}], num2str(placeholder(c))), 2};

            % Bar plot
            cell_bar = bar(x(c), mean_bar(c, :), "FaceColor", "flat");
            cell_bar(1).CData = c_plot;
            cell_bar(2).CData = c_plot;
            cell_bar(3).CData = c_plot;
            cell_bar(1).DisplayName = "Pre Stimulus (15 s)";
            cell_bar(2).DisplayName = "Stimulus (30 s)";
            cell_bar(3).DisplayName = "Post Stimulus (15 s)";

            % add error
            berr = errorbar(x_err(c, :), mean_bar(c, :), y_err(c, :));
            berr(1).Color = "k";
            berr(1).LineWidth = 1.5;
            berr.LineStyle = "none";
            berr(1).DisplayName = "SEM";
            leg_bar.AutoUpdate = "off";

            hatch_pre = hatchfill2(cell_bar(1), 'single', 'HatchAngle', 0, 'hatchcolor', [0.9 0.9 0.9], 'HatchDensity', 50, 'HatchLineWidth', 1);
            hatch_during = hatchfill2(cell_bar(2), 'cross', 'HatchAngle', 45, 'hatchcolor', [0.9 0.9 0.9], 'HatchDensity', 50, 'HatchLineWidth', 1);
            hatch_post = hatchfill2(cell_bar(3), 'single', 'HatchAngle', 90, 'hatchcolor', [0.9 0.9 0.9], 'HatchDensity', 80, 'HatchLineWidth', 1);

        end
        % adjust plot
        xticks(x)
        xticklabels(placeholder)
        xlabel(ax4, "Ejection Current [nA]")
        ylh2 = ylabel(ax4, "Firing Rate [$\frac{Spikes}{s}$]");
        ylh2.Interpreter = "latex";
        ylim([0 max(mean_trial, [], "all") * 1.2])


        % adjust entire fucking figure
        fontname(fig_drh, "Times")
        fontsize(20, "points")

        % labelpad


        y_label_current = get(ax3, 'YLabel');
        y_labelpos = get(y_label_current, 'position');
        y_labelpos(1) = -19;
        y_labelpos(3) = 0;
        set(y_label_current, 'position', y_labelpos)

        y_label_psth = get(ax2, 'YLabel');
        y_labelpos_psth = get(y_label_psth, 'position');
        y_labelpos_psth(1) = -19;
        y_labelpos_psth(3) = 0;
        set(y_label_psth, 'position', y_labelpos_psth)

        y_label_bar = get(ax4, 'YLabel');
        y_labelpos_bar = get(y_label_bar, 'position');
        y_labelpos_bar(1) = .3;
        y_labelpos_bar(2) = 5;
        y_labelpos_bar(3) = 0;
        set(y_label_bar, 'position', y_labelpos_bar)

        % save figures
        %fig_name = strcat(name, '_all.pdf');
        %saveas(fig_drh, [save_path, fig_name], 'pdf')
        fig_drh.Renderer = "painters";
        fig_name = strcat(name, '_all.svg');
        saveas(fig_drh, [save_path, fig_name], 'svg')
        close all

    end
end
