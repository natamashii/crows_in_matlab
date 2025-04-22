function spikes = getspikerates(trials, clusters, start_code, start_offset, duration)
% SYNTAX:
%			spikerates = getspikerates(trials, clusters, start_code, start_offset, duration)
%
%		spikerates is a matrix of firing rates, arranged (cluster, trial), in Hz
%
%	created 3/6/2001  -WA

[SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spikestat;

SpikeConfig = spiketools_config(0);
if SpikeConfig.LoadSpikes == 0,
   fid = fopen(SpikeInfo.FileName, 'r');
end

spikes = zeros(length(trials), length(clusters));
tstarts = round(1000*SpikeInfo.TrialStartTimes); %convert to milliseconds
tends = round(1000*SpikeInfo.TrialEndTimes);
tdurations = tends - tstarts;
neurons = SpikeInfo.NeuronID;
cindex = clusters;

if any(clusters > 999),
	for i = 1:length(clusters),
	   if clusters(i) > 999,
	      f = find(neurons == clusters(i));
	      if isempty(f), error('***** Error: Specified neuron does not exist *****'); return; end;
	      cindex(i) = f;
	   end
   end
end

startcodetimes = get_code_time(trials, start_code);
start_times = startcodetimes + start_offset;
f = find(start_times == 0);
if ~isempty(f),
   start_times(f) = 1;
end
end_times = start_times + duration - 1;

for clusnum = 1:length(clusters),
   neuronindx = SpikeInfo.NeuronIndex(cindex(clusnum));
   data = SpikeData{neuronindx};
   if isempty(data), %must load from disk
      fseek(fid, SpikeVarHeader(neuronindx).DataOffset, -1);
      data = fread(fid, SpikeVarHeader(neuronindx).Count, 'int32')/SpikeFileHeader.Frequency;
   end
   timestamps = round(1000*data); %convert to milliseconds
   ispikes = SpikeInfo.SpikeTable{cindex(clusnum), 1};
   nspikes = SpikeInfo.SpikeTable{cindex(clusnum), 2};
   for i = 1:length(trials),
      t = trials(i);
      trialspiketimes = timestamps(ispikes(t):ispikes(t)+nspikes(t)-1) - tstarts(t) + 1; %+1 because first bin is time 0
      spikes(i, clusnum) = 1000*sum((trialspiketimes >= start_times(i)) & (trialspiketimes < end_times(i)))/duration;
   end
end

if SpikeConfig.LoadSpikes == 0,
   fclose(fid);
end