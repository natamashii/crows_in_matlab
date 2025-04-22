function [p_kruskal, eta2, corr_p, corr_h, rbcorr, p_friedman, W] = ...
    single_cell_statistics(spikes, pre_stim, post_stim)

% pre allocation
p_wilcoxon = zeros(1, 3);
rbcorr = zeros(1, 3);
    
% divide into three time intervals
pre = mean(spikes(:, 1:pre_stim), 2);
during = mean(spikes(:, pre_stim:end - post_stim), 2);
post = mean(spikes(:, end - post_stim:end), 2);

% Perform Kruskal-Wallis Test & get eta squared
p_kruskal = kruskalwallis([pre, during, post]);
eta2 = mes1way([pre, during, post], 'eta2');

% Perform Friedman test & get kendalls coefficient of concordance (W)
p_friedman = friedman([pre, during, post]);
W = KendallCoef([pre, during, post]);

% post-hoc analysis: Wilcoxon Test
% pre vs. during
[p, ~, ~] = signrank(pre, during);
p_wilcoxon(1) = p;
% pre vs. post
[p, ~, ~] = signrank(pre, post);
p_wilcoxon(2) = p;
% during vs. post
[p, ~, ~] = signrank(during, post);
p_wilcoxon(3) = p;

% Bonferroni Correction
[corr_p, corr_h] = bonf_holm(p_wilcoxon);
% rank biserial correlation coefficient
res = mes(pre, during, 'rbcorr');
rbcorr(1) = res.rbcorr;
res = mes(pre, post, 'rbcorr');
rbcorr(2) = res.rbcorr;
res = mes(during, post, 'rbcorr');
rbcorr(3) = res.rbcorr;


end