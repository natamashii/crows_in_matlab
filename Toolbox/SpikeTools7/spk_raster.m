function spk_raster(crit)
% Spike Rasters
%
% this function is called from the SPK main menu under "analysis."
%
% last modified Spring, 1998  --WA

watchon;
load('spk_cfg.mat');
[SpikeInfo, SpikeFileHeader, SpikeVarHeader, SpikeData] = spikestat;

desired_trials = crit.desired_trials;
start_code = crit.start_code;
end_code = crit.end_code;
start_offset = crit.start_offset;
end_offset = crit.end_offset;
desired_cluster = crit.desired_cluster;
condgrps = crit.condgrps;
groupnames = crit.groupnames;
correctness = crit.correctness;

trials = group_conds(SpikeInfo.ConditionNumber, condgrps);
t = zeros(size(trials));
t(desired_trials) = trials(desired_trials);
trials = t;
numgroups = max(trials);

ft = find(trials);
blocks = SpikeInfo.BlockNumber(ft);
dblocks = diff(blocks);
block_transitions = find(dblocks)+1;
%block_transitions = ft(find(dblocks)) + 1;

disp('processing raster')

% new routine here:
start_times = get_code_time(find(trials), start_code);
end_times = get_code_time(find(trials), end_code);
start_times = start_times + start_offset;
end_times = end_times + end_offset;
duration = min(end_times - start_times);
h = zeros(duration, numgroups);
for g = 1:numgroups,
   t = find(trials == g);
   rast = getspike(t, desired_cluster, start_code, start_offset, duration);
   rast = sum(rast, 1) > 0; %if more than one cluster selected, treat as one.
   rast = rot90(squeeze(rast));
   [fy fx] = find(rast);
   y(g) = {fy};
   x(g) = {fx};
end
watchoff;
figure;
for g = 1:numgroups,
   subplot(numgroups, 1, g);
   pix = plot(x{g}, y{g}, 'k.');
   set(pix, 'markersize', 3);
   axis off
end
if numgroups == 1,
   hold on;
   xlim = get(gca, 'xlim');
   ylim = get(gca, 'ylim');
   bt = length(ft) - block_transitions;
   for i = 1:length(block_transitions),
      l(i) = line(xlim, [bt(i) bt(i)]);
   end
   set(l, 'color', [.7 .7 .7]);
end
set(gcf, 'color', [1 1 1]);
disp('done')
