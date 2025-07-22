clear
close all
clc

%% Pre definition
% Path definition
base_path = 'D:\MasterThesis\analysis\data\';
figure_path = 'D:\MasterThesis\figures\';
spk_folderpath = [base_path, 'spk\'];
rsp_mat_folderpath = [base_path, 'response_matrices\'];

who_analysis = {'humans\'; 'jello\'; 'uri\'};
current_who = 1;    % set who to analyze
current_exp = 2;    % set which experiment to analyze

% all numerosities relevant
numerosities = [3, 4, 5, 6, 7; % sample
    2, 2, 3, 3, 3;  % test 1 numbers
    5, 6, 7, 4, 4;  % test 2 numbers 
    6, 7, 8, 9, 10]';  % test 3 numbers
patterns = {{'P1', 'P2', 'P3', 'PR'}, {'P1', 'P2', 'P3'}};


to_save = true; % if result shall be saved
to_correct = false; % if response matrices shall be corrected

% pre allocation
all_resp_mat = {};
all_resp_mat_patterns = {};
all_resp_mat_nums_correct = {};
all_resp_mat_nums_total = {};
all_resp_mat_nums_perc = {};
sum_behaviour = cell(3, length(patterns{current_exp}));
perc_behaviour = cell(3, length(patterns{current_exp}));

% add 2D-array to each cell entry
for entry = 1:numel(sum_behaviour)
    sum_behaviour{entry} = zeros(size(numerosities, 1), size(numerosities, 2));
    perc_behaviour{entry} = zeros(size(numerosities, 1), size(numerosities, 2));
end

%sum_behaviour = zeros(3, 3, size(numerosities, 1), size(numerosities, 2));
% dim 1 = version to compute (1 = sum of perc, 2 = sums of correct, 3 = sums of total)
% dim 2 = pattern (1 = P1, 2 = P2, 3 = P3)
% dim 3 = sample (3-7)
% dim 4 = corresponding test (1 = match, 2 = test 1, 3 = test 2, 4 = test
% 3)
%perc_behaviour = zeros(3, 3, size(numerosities, 1), size(numerosities, 2));

placeholder = zeros(6, 3, size(numerosities, 1), size(numerosities, 2));
mean_perf = zeros(3, size(numerosities, 1), size(numerosities, 2));
std_perf = zeros(3, 3, size(numerosities, 1), size(numerosities, 2));
conf_perf = zeros(3, 3, size(numerosities, 1), size(numerosities, 2));
sem_perf = zeros(3, 3, size(numerosities, 1), size(numerosities, 2));

o_mean_perf = zeros(6, length(patterns{current_exp}), size(numerosities, 1));
o_std_perf = zeros(6, length(patterns{current_exp}), size(numerosities, 1));
o_sem_perf = zeros(6, length(patterns{current_exp}), size(numerosities, 1));
o_conf_perf = zeros(6, length(patterns{current_exp}), size(numerosities, 1));

avg_mean_perf = zeros(length(patterns{current_exp}), size(numerosities, 1));
avg_std_perf = zeros(3, length(patterns{current_exp}), size(numerosities, 1));
avg_sem_perf = zeros(3, length(patterns{current_exp}), size(numerosities, 1));
avg_conf_perf = zeros(3, length(patterns{current_exp}), size(numerosities, 1));

%% Correct Response Matrix
if to_correct
    % get file names
    path = [spk_folderpath, who_analysis{current_who}]; % adapt path
    filelist = dir(fullfile(path, '*.spk'));  % list of all spk files
    names = {filelist.name};

    % iterate over files
    for idx = 1:length(names)
        %for idx = 1:1   %placeholder for debugging
        placeholder_name = 'U250708';   %placeholder for debugging
        % load data
        curr_file = names{idx}; % current file
        %curr_file = placeholder_name;
        curr_spk = spk_read([path curr_file]); % current spike data
        curr_resp = getresponsematrix(curr_spk); % current response matrix
        % correct the response matrix
        corr_resp = respmat_corr(curr_resp, numerosities);

        % save the corrected response matrix
        if to_save
            save(fullfile(rsp_mat_folderpath, [curr_file, '_resp.mat']), 'corr_resp');
        end
    end
end

%% Sum Average Performance for each Pattern in Humans
% for now: just ignore division into standard & control lol

% Get Data
path = [rsp_mat_folderpath, who_analysis{current_who}]; % adapt path
filelist = dir(path);  % list of all data & subfolders
subfolders = filelist([filelist(:).isdir]); % extract subfolders
subfolders = {subfolders(3:end).name};  % list of subfolder names (experiments)

exp_path = [path, subfolders{current_exp}, '\'];

filelist = dir(fullfile(exp_path, '*.mat'));  % list of all response matrices
names = {filelist.name};

% iterate over all files
for idx = 1:length(names)
    % load data
    curr_file = names{idx};
    curr_resp = load([exp_path, curr_file]).corr_resp;
    % store in resp mat cell
    all_resp_mat{idx} = curr_resp;

    % divide into Patterns
    amount_patterns = unique(curr_resp(:, 2));
    amount_patterns = amount_patterns(1:end - 1);   % remove abunded trials for now
    
    for pattern = 1:length(amount_patterns)
        resp_mat_pat = curr_resp(curr_resp(:, 2) == pattern, :);
        all_resp_mat_patterns{idx, pattern} = resp_mat_pat;
        % extract it into each num
        % pre allocation
        number_table_correct = zeros(size(numerosities));
        number_table_total = zeros(size(numerosities));
        number_table_perc = zeros(size(numerosities));
        % iterate over sample numbers
        for sample_idx = 1:size(numerosities, 1)
            sample = numerosities(sample_idx, 1);   % curr sample
            resp_mat_samp = resp_mat_pat(resp_mat_pat(:, 3) == sample, :);
            rel_nums = numerosities(sample_idx, :);
            for num = 1:size(rel_nums, 2)
                % get relevant rows
                relevant_rows = resp_mat_samp(resp_mat_samp(:, 6) == rel_nums(num), :);
                % identify how many correct ones there are
                correct_trials = relevant_rows(relevant_rows(:, 5) == 0, :);
                performance = size(correct_trials, 1) / size(relevant_rows, 1);
                placeholder(idx, pattern, sample_idx, num) = performance;

                number_table_correct(sample_idx, num) = size(correct_trials, 1);
                number_table_total(sample_idx, num) = size(relevant_rows, 1);
                number_table_perc(sample_idx, num) = size(correct_trials, 1) / size(relevant_rows, 1);
                % add to overview arrays
                sum_behaviour{1, pattern}(sample_idx, num) = ...
                    sum_behaviour{1, pattern}(sample_idx, num) + ...
                    number_table_perc(sample_idx, num);
                sum_behaviour{2, pattern}(sample_idx, num) = ...
                    sum_behaviour{2, pattern}(sample_idx, num) + ...
                    number_table_correct(sample_idx, num);
                sum_behaviour{3, pattern}(sample_idx, num) = ...
                    sum_behaviour{3, pattern}(sample_idx, num) + ...
                    number_table_correct(sample_idx, num);
            end
            % take average of all test numbers for current sample
            o_mean_perf(idx, pattern, sample_idx) = ...
                mean(number_table_perc(sample_idx, :));
            o_std_perf(idx, pattern, sample_idx) = ...
                std(number_table_perc(sample_idx, :));
            o_sem_perf(idx, pattern, sample_idx) = ...
                std(number_table_perc(sample_idx, :)) / sqrt(size(number_table_perc, 2));
        end
        all_resp_mat_nums_correct{idx, pattern} = number_table_correct; % store the number table for current file
        all_resp_mat_nums_total{idx, pattern} = number_table_total; % store the number table for current file
        all_resp_mat_nums_perc{idx, pattern} = number_table_perc; % store the number table for current file
    end
end



% conf interval
% 68–95–99.7 rule: 95% ~ 2* std
% this for normal distribution
% for t distribution: 95% confidence interval and degrees of freedpn (n -
% 1) t = 2.015


% iterate over patterns
for pattern = 1:size(all_resp_mat_patterns, 2)
    % iterate over samples
    for sample_idx = 1:size(numerosities, 1)
        % iterate over sample-tests
        for num = 1:size(numerosities, 2)
            % Average computation
            mean_perf(pattern, sample_idx, num) = ...
                mean(placeholder(:, pattern, sample_idx, num));
            std_perf(1, pattern, sample_idx, num) = ...
                std(placeholder(:, pattern, sample_idx, num));
            std_perf(2, pattern, sample_idx, num) = ...
                mean(placeholder(:, pattern, sample_idx, num)) + ...
                std(placeholder(:, pattern, sample_idx, num));
            std_perf(3, pattern, sample_idx, num) = ...
                mean(placeholder(:, pattern, sample_idx, num)) - ...
                std(placeholder(:, pattern, sample_idx, num));
            sem_perf(1, pattern, sample_idx, num) = ...
                std(placeholder(:, pattern, sample_idx, num)) / ...
                sqrt(size(placeholder, 1));
            sem_perf(2, pattern, sample_idx, num) = ...
                mean(placeholder(:, pattern, sample_idx, num)) + ...
                (std(placeholder(:, pattern, sample_idx, num)) / ...
                sqrt(size(placeholder, 1)));
            sem_perf(3, pattern, sample_idx, num) = ...
                mean(placeholder(:, pattern, sample_idx, num)) - ...
                (std(placeholder(:, pattern, sample_idx, num)) / ...
                sqrt(size(placeholder, 1)));
        end
        % overall performance for each sample
        avg_mean_perf(pattern, sample_idx) = ...
            mean(o_mean_perf(:, pattern, sample_idx));
        avg_std_perf(1, pattern, sample_idx) = ...
            std(o_mean_perf(:, pattern, sample_idx));
        avg_std_perf(2, pattern, sample_idx) = ...
            mean(o_mean_perf(:, pattern, sample_idx)) + ...
            std(o_mean_perf(:, pattern, sample_idx));
        avg_std_perf(3, pattern, sample_idx) = ...
            mean(o_mean_perf(:, pattern, sample_idx)) - ...
            std(o_mean_perf(:, pattern, sample_idx));
        % NOTE: should I take std/sem of mean performances per person or
        % std/sem of each performance dot of each person?
        avg_sem_perf(1, pattern, sample_idx) = ...
            std(o_mean_perf(:, pattern, sample_idx)) / sqrt(size(o_mean_perf, 1));
        avg_sem_perf(1, pattern, sample_idx) = ...
            mean(o_mean_perf(:, pattern, sample_idx)) + ...
            (std(o_mean_perf(:, pattern, sample_idx)) / sqrt(size(o_mean_perf, 1)));
        avg_sem_perf(1, pattern, sample_idx) = ...
            mean(o_mean_perf(:, pattern, sample_idx)) - ...
            (std(o_mean_perf(:, pattern, sample_idx)) / sqrt(size(o_mean_perf, 1)));
    end
end







% Plot
% as all in one plot? or three next to each other?
format = 'svg';
colours_pattern = {[1 0 1]; [0 1 0]; [0 0 1]};
colours_numbers = {[0 0.4460 0.7410]; [0.8500 0.3250 0.0980]; ...
    [0.9290 0.6940 0.1250]; [0.3010 0.7450 0.9330]; [0.6350 0.0780 0.1840]};

% 3 different plots, each with avg match non-match
set(0,'defaultfigurecolor',[1 1 1])

fig = figure();
set(gcf,'Color',[1 1 1])

tiled = tiledlayout(fig, 1, 3);
tiled.TileSpacing = "loose";
tiled.Padding = "compact";



% iterate over patterns
for pattern = 1:size(all_resp_mat_patterns, 2)
    ax_pattern = nexttile(tiled);
    hold on
    leg_patch = [];
    leg_label = strings();
    % iterate over samples and plot each
    for sample_idx = 1:size(mean_perf, 2)
        % sort numerosities in ascending order
        [nums_sort, sort_idx] = sort(numerosities(sample_idx, :));
        error_up = squeeze(std_perf(2, pattern, sample_idx, :));
        error_down = squeeze(std_perf(3, pattern, sample_idx, :));
        values = squeeze(mean_perf(pattern, sample_idx, :));
        % Plot Error shading
        error_shade = fill([nums_sort, ...
            fliplr(nums_sort)], ...
            [error_down(sort_idx)', ...
            fliplr(error_up(sort_idx)')], ...
            colours_numbers{sample_idx});
        error_shade.FaceAlpha = .3;
        error_shade.EdgeColor = "none";
        error_shade.DisplayName = "none";
    end
    for sample_idx = 1:size(mean_perf, 2)
        % sort numerosities in ascending order
        [nums_sort, sort_idx] = sort(numerosities(sample_idx, :));
        error_up = squeeze(std_perf(2, pattern, sample_idx, :));
        error_down = squeeze(std_perf(3, pattern, sample_idx, :));
        values = squeeze(mean_perf(pattern, sample_idx, :));
        % plot mean line
        plot_pattern = plot(nums_sort, ...
            values(sort_idx));
        plot_pattern.Color = colours_numbers{sample_idx};
        plot_pattern.LineStyle = "-";
        plot_pattern.LineWidth = 2;
        plot_pattern.Marker = "o";
        plot_pattern.MarkerFaceColor = colours_numbers{sample_idx};
        plot_pattern.MarkerEdgeColor = "none";
        plot_pattern.DisplayName = num2str(numerosities(sample_idx, 1));
        % for legend
        leg_patch(end + 1) = plot_pattern;
        leg_label(sample_idx) = num2str(numerosities(sample_idx, 1));
    end
    ylim([-0.1 1.1])
    xlim([1.9 10.1])
    hold off
end

% create legend
leg = legend(leg_patch, leg_label);
leg.Location = "bestoutside";
leg.Box = "off";


% Save figure
fig.Renderer = "painters";
fig_name = 'Mean_STD_humans_all_patterns.png';
saveas(fig, [figure_path, fig_name], 'png')

shg




%% Figure: each subplot with 1 sample, all patterns
set(0,'defaultfigurecolor',[1 1 1])

fig2 = figure();
set(gcf,'Color',[1 1 1])

tiled = tiledlayout(fig2, 1, 5);
tiled.TileSpacing = "loose";
tiled.Padding = "compact";

% iterate over samples
for sample_idx = 1:size(mean_perf, 2)
    ax_pattern = nexttile(tiled);
    hold on
    leg_patch = [];
    leg_label = strings();
    % iterate over patterns & plot error shade
    for pattern = 1:size(all_resp_mat_patterns, 2)
        % sort numerosities in ascending order
        [nums_sort, sort_idx] = sort(numerosities(sample_idx, :));
        error_up = squeeze(std_perf(2, pattern, sample_idx, :));
        error_down = squeeze(std_perf(3, pattern, sample_idx, :));
        values = squeeze(mean_perf(pattern, sample_idx, :));
        % Plot Error shading
        error_shade = fill([nums_sort, ...
            fliplr(nums_sort)], ...
            [error_down(sort_idx)', ...
            fliplr(error_up(sort_idx)')], ...
            colours_pattern{pattern});
        error_shade.FaceAlpha = .3;
        error_shade.EdgeColor = "none";
        error_shade.DisplayName = "none";
    end
    for pattern = 1:size(all_resp_mat_patterns, 2)
        % sort numerosities in ascending order
        [nums_sort, sort_idx] = sort(numerosities(sample_idx, :));
        error_up = squeeze(std_perf(2, pattern, sample_idx, :));
        error_down = squeeze(std_perf(3, pattern, sample_idx, :));
        values = squeeze(mean_perf(pattern, sample_idx, :));
        % plot mean line
        plot_pattern = plot(nums_sort, ...
            values(sort_idx));
        plot_pattern.Color = colours_pattern{pattern};
        plot_pattern.LineStyle = "-";
        plot_pattern.LineWidth = 2;
        plot_pattern.Marker = "o";
        plot_pattern.MarkerFaceColor = colours_pattern{pattern};
        plot_pattern.MarkerEdgeColor = "none";
        plot_pattern.DisplayName = string(patterns{current_exp}{pattern});
        % for legend
        leg_patch(end + 1) = plot_pattern;
        leg_label(pattern) = string(patterns{current_exp}{pattern});
    end
    ylim([-0.1 1.1])
    xlim([1.9 10.1])
    hold off

end

% create legend
leg = legend(leg_patch, leg_label);
leg.Location = "bestoutside";
leg.Box = "off";


% Save figure
fig2.Renderer = "painters";
fig_name = 'Mean_STD_humans_all_patterns_each_num.png';
saveas(fig2, [figure_path, fig_name], 'png')

shg


%% Figure: Mean performances for each Sample & Pattern
set(0,'defaultfigurecolor',[1 1 1])

fig3 = figure();
set(gcf,'Color',[1 1 1])
hold on

leg_patch = [];
leg_label = strings();

% Plot Error Shade
error_down = squeeze(avg_std_perf(3, :, :));
error_up = squeeze(avg_std_perf(2, :, :));
% iterate over patterns
for pattern = 1:size(all_resp_mat_patterns, 2)
    error_shade = fill([numerosities(:, 1)', ...
            fliplr(numerosities(:, 1)')], ...
            [error_down(pattern, :), ...
            fliplr(error_up(pattern, :))], ...
            colours_pattern{pattern});
        error_shade.FaceAlpha = .3;
        error_shade.EdgeColor = "none";
        error_shade.DisplayName = "none";
end

% Plot Mean Performance
% iterate over patterns
for pattern = 1:size(all_resp_mat_patterns, 2)
    plot_pattern = plot(numerosities(:, 1), avg_mean_perf(pattern, :));
    plot_pattern.Color = colours_pattern{pattern};
    plot_pattern.LineStyle = "-";
    plot_pattern.LineWidth = 2;
    plot_pattern.Marker = "o";
    plot_pattern.MarkerFaceColor = colours_pattern{pattern};
    plot_pattern.MarkerEdgeColor = "none";
    plot_pattern.DisplayName = string(patterns{current_exp}{pattern});
    % for legend
    leg_patch(end + 1) = plot_pattern;
    leg_label(pattern) = string(patterns{current_exp}{pattern});
end


% create legend
leg = legend(leg_patch, leg_label);
leg.Location = "bestoutside";
leg.Box = "off";
ylim([-0.1 1.1])
xlim([3 7])
hold off

% Save figure
fig3.Renderer = "painters";
fig_name = 'Mean_STD_humans_avg_performance.png';
saveas(fig3, [figure_path, fig_name], 'png')

shg


%% repeat all of this shit but make it with error balken statt shade