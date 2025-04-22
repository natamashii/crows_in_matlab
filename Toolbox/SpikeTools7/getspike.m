function spikes = getspike(varargin)
%SYNTAX
%	spikes = getspike(trials, clusters, start_code, start_offset, duration);
%		or
%	spikes = getspike(trials, clusters);
%		or
%	spikes = getspike(trials);
%		or
%	spikes = getspike(clusters, start_time, end_time);
%
% This function returns a binary matrix, with ones corresponding to the occurrence of a spike.  The
% first usage returns a matrix which is arranged: (clusters, time_in_milliseconds, trial), while the
% second and third usages use the default start_code, start_offset, and duration specified in the
% SpikeTools configuration menu (the third usage assumes all clusters). The last usage requires 
% "start_time" and "end_time" to be in absolute time (in seconds) into the data file and returns a 
% matrix of the form: (clusters, time_in_milliseconds).  
%
% See also: GETSPIKERATES, GETLFP, DATAVIEW
%
% SpikeTools 7 Version created 2/27/2001  --WA
% Last modified 3/26/2001 --WA

[SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spikestat;
SpikeConfig = spiketools_config(0);
neurons = SpikeInfo.NeuronID;

spikes=[]; %PR EDIT

if length(varargin) == 1, %all trials, all clusters, uses defaults in SpikeTools Configuration for triggers
   
   trials = varargin{1};
   clusters = 1:length(SpikeInfo.NeuronID);
   start_code = SpikeConfig.DefaultStartCode;
   start_offset = SpikeConfig.DefaultStartOffset;
   duration = SpikeConfig.DefaultDuration;
   
elseif length(varargin) == 2,
   
   trials = varargin{1};
   clusters = varargin{2};
   start_code = SpikeConfig.DefaultStartCode;
   start_offset = SpikeConfig.DefaultStartOffset;
   duration = SpikeConfig.DefaultDuration;
   
elseif length(varargin) == 3, %clusters, start_time, end_time -- times are in seconds
   
   clusters = varargin{1};
   start_time = 1000*varargin{2};
   end_time = 1000*varargin{3};
   cindex = convert2clusindx(clusters, neurons);
   duration = end_time - start_time;
   spikes = uint8(zeros(length(cindex), duration));
   
   if SpikeConfig.LoadSpikes == 0,
	   fid = fopen(SpikeInfo.FileName, 'r');
   end
   
   for clusnum = 1:length(cindex),
      neuronindx = SpikeInfo.NeuronIndex(cindex(clusnum));
   	data = SpikeData{neuronindx};
   	if isempty(data), %must load from disk
   	   fseek(fid, SpikeVarHeader(neuronindx).DataOffset, -1);
   	   data = fread(fid, SpikeVarHeader(neuronindx).Count, 'int32')/SpikeFileHeader.Frequency;
   	end
      timestamps = round(1000*data); %convert to milliseconds
      f = find(timestamps > start_time);
      if ~isempty(f),
         ts = timestamps(f) - start_time;
         ts = ts(find(ts <= duration));
         spikes(clusnum, ts) = 1;
      end
   end
   
	if SpikeConfig.LoadSpikes == 0,
	   fclose(fid);
	end
   
   return
   
elseif length(varargin) == 5, %trials, clusters, start_code, start_offset, duration
   
   trials = varargin{1};
   clusters = varargin{2};
   start_code = varargin{3};
   start_offset = varargin{4};
   duration = varargin{5};
   
else
   
   error('***** ERROR: Unrecognized input options *****');
   return
   
end

if SpikeConfig.LoadSpikes == 0,
   fid = fopen(SpikeInfo.FileName, 'r');
end

spikes = uint8(zeros(length(clusters), duration, length(trials)));
tstarts = round(1000*SpikeInfo.TrialStartTimes); %convert to milliseconds
tends = round(1000*SpikeInfo.TrialEndTimes);
tdurations = tends - tstarts;
neurons = SpikeInfo.NeuronID;
cindex = convert2clusindx(clusters, neurons);

startcodetimes = get_code_time(trials, start_code);
start_times = startcodetimes + start_offset;
f = find(start_times == 0);
if ~isempty(f),
   start_times(f) = 1;
end
end_times = start_times + duration - 1;
tdurations = tdurations(trials);

for clusnum = 1:length(cindex),
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
      binarytrial = zeros(tdurations(i), 1);
      binarytrial(trialspiketimes) = 1;
      if end_times(i) > tdurations(i),
         watchoff;
         error('***** ERROR: Requested epoch exceeds trial duration *****');
         return
      end
      spikes(clusnum, :, i) = binarytrial(start_times(i):end_times(i));
   end
end

if SpikeConfig.LoadSpikes == 0,
   fclose(fid);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cindex = convert2clusindx(clusters, neurons)

if any(clusters > 999),
	for i = 1:length(clusters),
	   if clusters(i) > 999,
	      f = find(neurons == clusters(i));
	      if isempty(f), error('***** Error: Specified neuron does not exist *****'); return; end;
	      cindex(i) = f;
	   end
   end
else
   cindex = clusters;
end
