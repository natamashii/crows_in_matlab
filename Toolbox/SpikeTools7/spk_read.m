function [SpikeInfo, SpikeFileHeader, SpikeVarHeader, SpikeData] = spk_read(varargin)
%	SYNTAX
%		[SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spk_read(filename)
%
%	This function reads in data from an SPK file and makes that file the currently active file
%	which is acted upon by functions such as GETSPIKE and GETLFP.  The first structure returned,
%	SpikeInfo, contains information gathered from the raw data file structures, SpikeFileHeader
%	and SpikeVarHeader, but in a more easily accessible format (e.g., SpikeInfo.ResponseError and
%	SpikeInfo.ConditionNumber).  SpikeData will contain spike timestamps and / or LFP data,
%	depending on the configuration settings (SpikeTools Main Menu >> File > Configuration).
%
%	See also: SPK_READ_HEADER, GETSPIKE, GETLFP, GET_CODE_TIME
%
%	SpikeTools 7 version Created 2/11/2001 --WA
%	Last modified 3/22/2001 --WA

directories;
SpikeConfig = spiketools_config(0);

if isempty(varargin),
   [filename pathname] = uigetfile(strcat(dir_spk, '.spk'), 'Select Spike file...');
   if pathname == 0, return; end;
   spk_file = [pathname filename];
else
   spk_file = varargin{:};
   slash = find(spk_file == filesep);
   if isempty(slash),
      spk_file = strcat(dir_spk, spk_file);
   end
   dot = find(spk_file == '.');
   if isempty(dot),
      spk_file = strcat(spk_file, '.spk');
   end
end

fid = fopen(spk_file, 'r');
if fid < 0, error('***** Error opening Spike file *****'); return; end;

%%%%% Read File Header %%%%%
SpikeFileHeader.MagicNumber = fread(fid, 1, 'int32');
if SpikeFileHeader.MagicNumber ~= 559417104, fclose(fid); error('***** Not a valid SPK file of version 7 or greater *****'); return; end;
SpikeFileHeader.Version = fread(fid, 1, 'int32');
SpikeFileHeader.Comment = deblank(char(fread(fid, 256, 'char'))');
SpikeFileHeader.Frequency = fread(fid, 1, 'double');
SpikeFileHeader.Beg = fread(fid, 1, 'int32');
SpikeFileHeader.End = fread(fid, 1, 'int32');
SpikeFileHeader.NumVars = fread(fid, 1, 'int32');
SpikeFileHeader.Investigator = deblank(char(fread(fid, 64, 'char'))');
SpikeFileHeader.Experiment = deblank(char(fread(fid, 64, 'char'))');
SpikeFileHeader.Subject = deblank(char(fread(fid, 64, 'char'))');
SpikeFileHeader.SessionDate = fread(fid, 3, 'int32')';
SpikeFileHeader.CreationDate = fread(fid, 3, 'int32')';
SpikeFileHeader.ModificationDate = fread(fid, 3, 'int32')';
SpikeFileHeader.NextFileHeader = fread(fid, 1, 'int32');
SpikeFileHeader.Padding = fread(fid, 256, 'char');

for i = 1:SpikeFileHeader.NumVars, %%%%% Read Variable Headers %%%%%
   VarOffset(i) = ftell(fid);
   SpikeVarHeader(i).Type = fread(fid, 1, 'int32');
   SpikeVarHeader(i).Version = fread(fid, 1, 'int32');
   SpikeVarHeader(i).Name = deblank(char(fread(fid, 64, 'char'))');
   SpikeVarHeader(i).DataOffset = fread(fid, 1, 'int32');
   SpikeVarHeader(i).Count = fread(fid, 1, 'int32');
   SpikeVarHeader(i).WireNumber = fread(fid, 1, 'int32');
   SpikeVarHeader(i).UnitNumber = fread(fid, 1, 'int32');
   SpikeVarHeader(i).Gain = fread(fid, 1, 'int32');
   SpikeVarHeader(i).Filter = fread(fid, 1, 'int32');
   SpikeVarHeader(i).Xpos = fread(fid, 1, 'double');
   SpikeVarHeader(i).Ypos = fread(fid, 1, 'double');
   SpikeVarHeader(i).Zpos = fread(fid, 1, 'double');
   SpikeVarHeader(i).Apos = fread(fid, 1, 'double');
   SpikeVarHeader(i).WFrequency = fread(fid, 1, 'double');
   SpikeVarHeader(i).ADtoMV = fread(fid, 1, 'double');
   SpikeVarHeader(i).NPointsWave = fread(fid, 1, 'int32');
   SpikeVarHeader(i).Padding = fread(fid, 128, 'char');
end

for i = 1:SpikeFileHeader.NumVars, %%%%%% Read Data Blocks %%%%%
   datamark(i) = ftell(fid);
   if SpikeVarHeader(i).Type == 3, %waveform
      d1 = fread(fid, SpikeVarHeader(i).Count, 'int32')/SpikeFileHeader.Frequency;
      d2 = fread(fid, SpikeVarHeader(i).Count, 'int16');
      data = cat(2, d1, d2);
   elseif SpikeVarHeader(i).Type == 5, %LFP
      if SpikeConfig.LoadLFP == 1,
         data = fread(fid, SpikeVarHeader(i).NPointsWave, '*int16');
      else
         fseek(fid, 2*SpikeVarHeader(i).NPointsWave, 0);
         data = [];
      end
   elseif SpikeVarHeader(i).Type == 7, %numerical marker
      for ii = 1:SpikeVarHeader(i).Count,
         SpikeVarHeader(i).NMarkers{ii} = fread(fid, 1, 'int32');
         markername = '';
         markerlength = [];
         markervalues = [];
         for iii = 1:SpikeVarHeader(i).NMarkers{ii},
            markername = strvcat(markername, deblank(char(fread(fid, 64, 'char'))'));
            markerlength = cat(2, markerlength, fread(fid, 1, 'int32'));
            markervalues{iii} = fread(fid, markerlength(iii), 'int32');
         end
         SpikeVarHeader(i).MarkerName{ii} = markername;
         SpikeVarHeader(i).MarkerLength{ii} = markerlength;
         SpikeVarHeader(i).MarkerValues{ii} = markervalues;
      end
      data = [];
   elseif SpikeVarHeader(i).Type == 0, %neuron
      if SpikeConfig.LoadSpikes == 1,
         data = fread(fid, SpikeVarHeader(i).Count, 'int32')/SpikeFileHeader.Frequency;
      else
         fseek(fid, 4*SpikeVarHeader(i).Count, 0);
         data = [];
      end
   else %all other data types,
      data = fread(fid, SpikeVarHeader(i).Count, 'int32')/SpikeFileHeader.Frequency;
   end
   SpikeData{i} = data;
end

SpikeInfo.FileName = spk_file;

%%%%%% Sort out Marker data %%%%%%
foundeye = 0;
datatypes = cat(1, SpikeVarHeader.Type);
f = find(datatypes == 7);
for i = 1:length(f),
   varnum = f(i);
   if strmatch(SpikeVarHeader(varnum).Name, 'StrobedBehavioralCodes'),
      markervalues = SpikeVarHeader(varnum).MarkerValues{1};
      SpikeInfo.CodeNumbers = markervalues{1};
      SpikeInfo.CodeTimes = markervalues{2}/SpikeFileHeader.Frequency;
   elseif strmatch(SpikeVarHeader(varnum).Name, 'TrialInfo'),
      markervalues = SpikeVarHeader(varnum).MarkerValues{1};
      SpikeInfo.TrialStartTimes = markervalues{1}/SpikeFileHeader.Frequency;
      SpikeInfo.TrialEndTimes = markervalues{2}/SpikeFileHeader.Frequency;
      SpikeInfo.CodeIndex = markervalues{3};
      SpikeInfo.CodesPerTrial = markervalues{4};
   elseif strmatch(SpikeVarHeader(varnum).Name, 'CortexHeaderInfo'),
      markervalues = SpikeVarHeader(varnum).MarkerValues{1};
      SpikeInfo.ConditionNumber = markervalues{1};
      SpikeInfo.RepeatNumber = markervalues{2};
      SpikeInfo.BlockNumber = markervalues{3};
      SpikeInfo.TrialNumber = markervalues{4};
      SpikeInfo.ExpectedResponse = markervalues{5};
      SpikeInfo.Response = markervalues{6};
      SpikeInfo.ResponseError = markervalues{7};
   elseif strmatch(SpikeVarHeader(varnum).Name, 'EyePosition'),
      foundeye = 1;
      markervalues = SpikeVarHeader(varnum).MarkerValues{1};
      SpikeInfo.EyeXPos = markervalues{1};
      SpikeInfo.EyeYPos = markervalues{2};
      SpikeInfo.EyeIndex = markervalues{3};
      SpikeInfo.EyeSamplesPerTrial = markervalues{4};
      SpikeInfo.EyeFrequency = SpikeVarHeader(varnum).WFrequency;
   elseif strmatch(SpikeVarHeader(varnum).Name, 'SpikeTable'),
      SpikeInfo.SpikeTable = cat(1, SpikeVarHeader(varnum).MarkerValues{:}); 
      %first column is index to first spike in each trial (in actual timestamp data vector),
      %while second column is number of spikes for that trial.
      %number of cells (in vertical direction) corresponds to number of neurons.
   end
end

if ~foundeye,
   SpikeInfo.EyeXPos = [];
   SpikeInfo.EyeYPos = [];
   SpikeInfo.EyeIndex = [];
   SpikeInfo.EyeSamplesPerTrials = [];
   SpikeInfo.EyeFrequency = [];
end

%%%%%% Sort out Spike and LFP Data %%%%%%
f = find(datatypes == 0);
SpikeInfo.NeuronID = [];
SpikeInfo.NeuronIndex = [];

for i = 1:length(f),
	varnum = f(i);
	nname = SpikeVarHeader(varnum).Name;
	SpikeInfo.NeuronID(i, 1) = str2num(nname(find(nname > 46 & nname < 58)));
	SpikeInfo.NeuronIndex(i, 1) = varnum;
end

f = find(datatypes == 5);
SpikeInfo.LFPID = [];
SpikeInfo.LFPIndex = [];
for i = 1:length(f),
   varnum = f(i);
   nname = SpikeVarHeader(varnum).Name;
   SpikeInfo.LFPID(i, 1) = str2num(nname(find(nname > 46 & nname < 58)));
   SpikeInfo.LFPIndex(i, 1) = varnum;
end
SpikeInfo.VarHeaderOffset = VarOffset;

SPIKEVARS{1} = SpikeInfo;
SPIKEVARS{2} = SpikeFileHeader;
SPIKEVARS{3} = SpikeVarHeader;
SPIKEVARS{4} = SpikeData;
spikestat(SPIKEVARS);
