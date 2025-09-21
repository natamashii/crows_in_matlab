function [p_P1P2, p_P2P3, p_P1P3] = conoveriman(data_p1, data_p2, data_p3)

% Function to compute Conover Iman Test


% rank the data
x = [data_p1; data_p2; data_p3];
ranked_x = tiedrank(x);

% put it back into groups
rank_p1 = ranked_x(1:60);
rank_p2 = ranked_x(61:120);
rank_p3 = ranked_x(121:end);

% calculate mean ranks
mean_rank_p1 = mean(rank_p1);
mean_rank_p2 = mean(rank_p2);
mean_rank_p3 = mean(rank_p3);
ranksums = [sum(rank_p1), sum(rank_p2), sum(rank_p3)];

% Calculate total sum of squares
ss_total = sum(ranked_x .^ 2) - (sum(ranked_x) ^ 2 / size(ranked_x, 1));

% Calculate between-group sum of squares
ss_between = sum((ranksums .^ 2) / 60) - (sum(ranked_x)^2 / size(ranked_x, 1));

% Calculate within-group sum of squares
ss_within = ss_total - ss_between;

% Calculate Mean Square Within
ms_within = ss_within / (size(ranked_x, 1) - 3);

% Calculate t statistics
t_stats_P1P2 = (mean_rank_p1 - mean_rank_p2) / ...
    sqrt(ms_within * ((1 / size(rank_p1, 1)) + (1 / size(rank_p2, 1))));
t_stats_P2P3 = (mean_rank_p2 - mean_rank_p3) / ...
    sqrt(ms_within * ((1 / size(rank_p2, 1)) + (1 / size(rank_p3, 1))));
t_stats_P1P3 = (mean_rank_p1 - mean_rank_p3) / ...
    sqrt(ms_within * ((1 / size(rank_p1, 1)) + (1 / size(rank_p3, 1))));

% Calculate p Value
p_P1P2 = 2 * (1 - tcdf(abs(t_stats_P1P2), size(ranked_x, 1) - 3));
p_P2P3 = 2 * (1 - tcdf(abs(t_stats_P2P3), size(ranked_x, 1) - 3));
p_P1P3 = 2 * (1 - tcdf(abs(t_stats_P1P3), size(ranked_x, 1) - 3));

end