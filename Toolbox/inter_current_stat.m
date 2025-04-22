function [corr_p, corr_h, rbcorr, p_friedman, W] = ...
    inter_current_stat(spikes, repetitions, frame_rate_spikes, current, pre_stim, post_stim)

% pre allocation
data = zeros(max(repetitions), numel(current));
data(:) = NaN;
trial_counter = 1;
current_types = numel(current);

% get firing rate of each trial during stimulus interval
during = mean(spikes(:, pre_stim:end - post_stim), 2, "omitnan");
during = during * frame_rate_spikes;

% split into groups of currents
for c = 1:numel(current)
    data(1:repetitions(c), c) = during(trial_counter:trial_counter + repetitions(c) - 1);
    trial_counter = trial_counter + repetitions(c);
end

% control that only data with all values are chosen
if sum(isnan(data), "all")
    [row, ~] = find(isnan(data));
    data(row, :) = [];
end

% post-hoc analysis: Wilcoxon Test
switch current_types
    case 1
        p_friedman = NaN;
        W = NaN;
        p_wilcoxon = NaN;
        rbcorr = NaN;
        corr_p = NaN;
        corr_h = NaN;
    case 2
        p_friedman = friedman(data);
        W = KendallCoef(data);
        [p_wilcoxon, ~, ~] = signrank(data(:, 1), data(:, 2));
        [corr_p, corr_h] = bonf_holm(p_wilcoxon);
        % rank-biserial correlation coefficient
        rbcorr = mes(data(:, 1), data(:, 2), 'rbcorr');
    case 3
        p_friedman = friedman(data);
        W = KendallCoef(data);

        p_wilcoxon = zeros(1, 3);
        rbcorr = zeros(1, 3);
        
        p_wilcoxon(1) = signrank(data(:, 1), data(:, 2));
        p_wilcoxon(2) = signrank(data(:, 1), data(:, 3));
        p_wilcoxon(3) = signrank(data(:, 2), data(:, 3));
        [corr_p, corr_h] = bonf_holm(p_wilcoxon);
        % rank-biserial correlation coefficient
        res = mes(data(:, 1), data(:, 2), 'rbcorr');
        rbcorr(1) = res.rbcorr;
        res = mes(data(:, 1), data(:, 3), 'rbcorr');
        rbcorr(2) = res.rbcorr;
        res = mes(data(:, 2), data(:, 3), 'rbcorr');
        rbcorr(3) = res.rbcorr;
    case 4
        p_friedman = friedman(data);
        W = KendallCoef(data);

        p_wilcoxon = zeros(1, 6);
        rbcorr = zeros(1, 6);
        
        p_wilcoxon(1) = signrank(data(:, 1), data(:, 2));
        p_wilcoxon(2) = signrank(data(:, 1), data(:, 3));
        p_wilcoxon(3) = signrank(data(:, 1), data(:, 4));
        p_wilcoxon(4) = signrank(data(:, 2), data(:, 3));
        p_wilcoxon(5) = signrank(data(:, 2), data(:, 4));
        p_wilcoxon(6) = signrank(data(:, 3), data(:, 4));
        [corr_p, corr_h] = bonf_holm(p_wilcoxon);
        % rank-biserial correlation coefficient
        res = mes(data(:, 1), data(:, 2), 'rbcorr');
        rbcorr(1) = res.rbcorr;
        res = mes(data(:, 1), data(:, 3), 'rbcorr');
        rbcorr(2) = res.rbcorr;
        res = mes(data(:, 2), data(:, 3), 'rbcorr');
        rbcorr(3) = res.rbcorr;
        res = mes(data(:, 2), data(:, 3), 'rbcorr');
        rbcorr(4) = res.rbcorr;
        res = mes(data(:, 2), data(:, 4), 'rbcorr');
        rbcorr(5) = res.rbcorr;
        res = mes(data(:, 3), data(:, 4), 'rbcorr');
        rbcorr(6) = res.rbcorr;
end

end