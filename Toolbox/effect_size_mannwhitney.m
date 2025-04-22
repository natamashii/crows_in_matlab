function [z, r, R2] = effect_size_mannwhitney(data1, data2)

% get n
n1 = sum(~isnan(data1));
n2 = sum(~isnan(data2));
n = n1 + n1;

% remnove nan values from input
data1 = data1(~isnan(data1));
data2 = data2(~isnan(data2));

% get ranks
rank1 = tiedrank(data1);
rank2 = tiedrank(data2);

% get ranksums
t1 = sum(rank1);
t2 = sum(rank2);

% get U statistics
U1 = (n1 * n2) + ((n1 * (n1 + 1)) / 2) - t1;
U2 = (n1 * n2) + ((n2 * (n2 + 1)) / 2) - t2;
U = min([U1, U2]);

% identify how many values share same rank
data = vertcat(data1, data2);
[B, ~] = groupcounts(data);
counts = B(B > 1);

% tied rank correction
if isempty(counts)
    counts_div = zeros(size(counts));
    for c = 1:numel(counts_div)
        counts_div = ((counts(c)^3) - counts(c)) / 12;
    end
    tied_corrected = sum(counts_div);
    mean_u = (n1 * n2) / 2;
    sem_u = sqrt((n1 * n2) / (n * (n - 1))) * sqrt((((n^3) - n) / 12) - tied_corrected);
else
    mean_u = mean([n1, n2]);
    sem_u = std([n1, n2]) / sqrt(n);
end

% z statistic
z = abs((U - mean_u) / sem_u);

% r
r = z / sqrt(n);

% R2
R2 = (z^2) / n;

end