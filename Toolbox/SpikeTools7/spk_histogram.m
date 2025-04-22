function spk_histogram(crit)
% Spike Histograms
% Called from the analysis menu in the SPK main menu.
%
% last modified (from histo.m) 3/23/98  --WA

load('spk_cfg.mat');
[SpikeInfo, SpikeFileHeader, SpikeVarHeader, SpikeData] = spikestat;

watchon;

desired_trials = crit.desired_trials;
start_code = crit.start_code;
end_code = crit.end_code;
start_offset = crit.start_offset;
end_offset = crit.end_offset;
desired_cluster = crit.desired_cluster;
condgrps = crit.condgrps;
groupnames = crit.groupnames;

numgroups = size(condgrps, 1);
desconds = SpikeInfo.ConditionNumber(desired_trials);

disp('processing histogram')

% new routine here:
start_times = get_code_time(desired_trials, start_code);
end_times = get_code_time(desired_trials, end_code);
start_times = start_times + start_offset;
end_times = end_times + end_offset;
duration = min(end_times - start_times);
h = zeros(duration, numgroups);

condarray = unique(SpikeInfo.ConditionNumber(desired_trials));
condhists = zeros(duration, length(condarray));
for c = 1:length(condarray),
   t = desired_trials(find(desconds == condarray(c)));
   numtrials(c) = length(t);
   s = squeeze(getspike(t, desired_cluster, start_code, start_offset, duration));
   if length(desired_cluster) > 1,
      s = sum(s, 1) > 0;
   end 
   if numtrials(c) == 1,
      s = s';
   end
   condhists(:, c) = (sum(squeeze(s), 2)*1000);
end

for g = 1:numgroups,
   f = find(ismember(condarray, condgrps(g, :)));
   h(:, g) = sum(condhists(:, f), 2)./sum(numtrials(f));
end
watchoff;

plotprep;
plot(h)
set(findobj(gcf, 'tag', 'WINDOW SIZE'), 'string', num2str(SpikeConfig.DefaultSmoothWindow));
plotprep('smooth');

if desired_cluster > 999,
   clusnum = int2str(desired_cluster);
else
   clusnum = int2str(SpikeInfo.NeuronID(desired_cluster));
end
file = SpikeInfo.FileName;
last_slash = max(find(file == '\'));
filestring = file(last_slash+1:length(file));
ttlstring = cat(2, filestring, ' ', clusnum);
title(ttlstring);

linetags(groupnames);
xlabel('time (msec)')
ylabel('spike rate (Hz)')
set(findobj(gcf, 'tag', 'grouping'), 'value', crit.groupselect);

spike_data = struct('condhists', condhists, 'numtrials', numtrials, 'condarray', condarray, 'analysis', 'histogram');
set(gca, 'userdata', spike_data);

file = SpikeInfo.FileName;
slash = find(file == filesep);
if ~isempty(slash),
   filename = file(max(slash)+1:length(file));
else
   filename = file;
end
%[ML AP] = get_location(filename, desired_cluster);
%if ~isempty(ML),
%   coords_string = strcat('X(', num2str(AP), ')   Y (', num2str(ML), ')');
%   f = uicontrol('style', 'frame', 'position', [340 15 120 60]);
%   d1 = uicontrol('style', 'text', 'position', [342 35 116 30], 'string', 'Coordinates', 'fontweight', 'bold');
%   d2 = uicontrol('style', 'text', 'position', [342 20 116 20], 'string', coords_string);
%end

lf = length(filename);
ct = filename;
ct(lf-3:lf) = num2str(desired_cluster);
set(gcf, 'numbertitle', 'off', 'name', ct);

disp('done')
