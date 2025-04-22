function spk_xcorr(crit)

watchon;
[SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spikestat;

cchalfwin = 50;

desired_trials = crit.desired_trials;
start_code = crit.start_code;
end_code = crit.end_code;
start_offset = crit.start_offset;
end_offset = crit.end_offset;
cluster1 = crit.desired_cluster;
cluster2 = cluster_ids(choose_cluster);
condgrps = crit.condgrps;
groupnames = crit.groupnames;

numgroups = size(condgrps, 1);
desconds = cond_no(desired_trials);

disp('processing correlation')

% new routine here:
start_times = get_code_time(desired_trials, start_code);
end_times = get_code_time(desired_trials, end_code);
start_times = start_times + start_offset;
end_times = end_times + end_offset;
duration = min(end_times - start_times);
h1 = zeros(duration, numgroups);
h2 = h1;
xc = zeros((2*cchalfwin)+1, numgroups);

condarray = unique(SpikeInfo.ConditionNumber);
conhists = zeros((2*cchalfwin)+1, length(condarray));
for c = 1:length(condarray),
   t = desired_trials(find(desconds == condarray(c)));
   s1 = squeeze(getspike(t, cluster1, start_code, start_offset, duration))';
   s2 = squeeze(getspike(t, cluster2, start_code, start_offset, duration))';
   numtrials(c) = 1; %for cc normalization, just divide by number of crosscorrs.
   condhists(:, c) = binxcorr(s1, s2, cchalfwin)'; %really cc, not condition histograms -- but needed for plotprep...
end

for g = 1:numgroups,
   f = find(ismember(condarray, condgrps(g, :)));
   xc(:, g) = sum(condhists(:, f), 2)./sum(numtrials(f));
end

figure(findobj('tag', 'spkmenu'));
watchoff;

plotprep;
plot(-cchalfwin:cchalfwin, xc)
linetags(groupnames);
xlabel('time (msec)')
ylabel('correlation coefficient')
set(findobj(gcf, 'tag', 'grouping'), 'value', crit.groupselect);

spike_data = struct('condhists', condhists, 'numtrials', numtrials, 'condarray', condarray, 'analysis', 'xcorr');
set(gca, 'userdata', spike_data);

set(gcf, 'numbertitle', 'off', 'name', sprintf('%s %i vs. %i', filename, cluster1, cluster2));

disp('done')
