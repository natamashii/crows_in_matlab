function lfp = getlfp(varargin)
% SYNTAX:
%	lfp = getlfp(trials, channels, start_code, start_offset, duration);
%		or
%	lfp = getlfp(trials, channels);
%		or
%	lfp = getlfp(trials);
%		or
%	lfp = getlfp(channels, start_time, end_time);
%
% The first usage returns a matrix which is arranged: (clusters, time_in_milliseconds, trial), while
% the second and third usages use the default start_code, start_offset, and duration specified in
% the SpikeTools configuration menu (the third usage assumes all channels). The last usage requires 
% "start_time" and "end_time" to be in absolute time (in seconds) into the data file and returns a 
% matrix of the form: (channels, time_in_milliseconds).  
%
% See also: GETSPIKE, DATAVIEW
%
% Created 3/1/2001  --WA
% Last modified 4/10/2001 --WA

SpikeConfig = spiketools_config(0);
[SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spikestat;

if isempty(find(cat(1, SpikeVarHeader.Type) == 5)),
   error('***** LFP data not collected in this SPK file *****');
   return
elseif any(cat(1, SpikeVarHeader(SpikeInfo.LFPIndex).Count) == 0),
   warning('***** LFP data not present in this SPK file *****');
   lfp = [];
   return
end

channels = SpikeInfo.LFPID;

if length(varargin) == 1,
   
   trials = varargin{1};
   electrodes = 1:length(SpikeInfo.NeuronID);
   start_code = SpikeConfig.DefaultStartCode;
   start_offset = SpikeConfig.DefaultStartOffset;
   duration = SpikeConfig.DefaultDuration;
   
elseif length(varargin) == 2,
   
   trials = varargin{1};
   electrodes = varargin{2};
   start_code = SpikeConfig.DefaultStartCode;
   start_offset = SpikeConfig.DefaultStartOffset;
   duration = SpikeConfig.DefaultDuration;
   
elseif length(varargin) == 3,
   
   electrodes = varargin{1};
   start_time = varargin{2};
   end_time = varargin{3};
   cindex = convert2chanindx(electrodes, channels);
   duration = end_time - start_time;
   lfp = zeros(length(cindex), round(1000*duration));
   
   if SpikeConfig.LoadLFP == 0,
		fid = fopen(SpikeInfo.FileName, 'r');
		if fid < 0, error('***** Error opening SPK file *****'); return; end;
	end
   
   for elecnum = 1:length(cindex),
   	varnum = SpikeInfo.LFPIndex(cindex(elecnum));
   	freq = SpikeVarHeader(varnum).WFrequency;
   	numpoints = round(duration*freq);
   	jumpoffset = round(freq*start_time);
   	seekdist = SpikeVarHeader(varnum).DataOffset + (2*jumpoffset);
   	if SpikeConfig.LoadLFP == 0,
   	   fseek(fid, seekdist, -1);
   	   data = SpikeVarHeader(varnum).ADtoMV*fread(fid, numpoints, 'int16');
   	else
   	   data = SpikeData{varnum};
   	   data = data(jumpoffset+1:jumpoffset+numpoints);
      end
   	lfp(elecnum, :) = data';
  	end
   
   if SpikeConfig.LoadLFP == 0,
	   fclose(fid);
	end
   return
   
elseif length(varargin) == 5,
   
   trials = varargin{1};
   electrodes = varargin{2};
   start_code = varargin{3};
   start_offset = varargin{4};
   duration = varargin{5};
   
else
   
	error('***** ERROR: Unrecognized input options *****');
   return
      
end

lfp = zeros(length(electrodes), duration, length(trials));
tstarts = round(1000*SpikeInfo.TrialStartTimes); %convert to milliseconds
tends = round(1000*SpikeInfo.TrialEndTimes);
tdurations = tends - tstarts;
cindex = convert2chanindx(electrodes, channels);

if SpikeConfig.LoadLFP == 0,
	fid = fopen(SpikeInfo.FileName, 'r');
	if fid < 0, error('***** Error opening SPK file *****'); return; end;
end
   
for elecnum = 1:length(cindex),
   varnum = SpikeInfo.LFPIndex(cindex(elecnum));
   freq = SpikeVarHeader(varnum).WFrequency;
   numpoints = round(duration * (freq/1000));
   for i = 1:length(trials),
      t = trials(i);
      trialoffset = SpikeInfo.TrialStartTimes(t);
      startoffset = (get_code_time(t, start_code) + start_offset)/1000; %in seconds
      jumpoffset = round(freq*(trialoffset + startoffset));
      seekdist = SpikeVarHeader(varnum).DataOffset + (2*jumpoffset);
      if SpikeConfig.LoadLFP == 0,
      	fseek(fid, seekdist, -1);
         data = SpikeVarHeader(varnum).ADtoMV*fread(fid, numpoints, 'int16');
      else
         data = SpikeData{varnum};
         data = data(jumpoffset+1:jumpoffset+numpoints);
      end
      lfp(elecnum, :, i) = data;
   end
end

if SpikeConfig.LoadLFP == 0,
   fclose(fid);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cindex = convert2chanindx(electrodes, channels)

if any(electrodes > 999),
	for i = 1:length(electrodes),
      if electrodes(i) > 999,
         electrodes(i) = 100*floor(electrodes(i)/100);
	      f = find(channels == electrodes(i));
	      if isempty(f), error('***** Error: Specified LFP channel does not exist *****'); return; end;
	      cindex(i) = f;
	   end
   end
else
   cindex = electrodes;
end