function [SpikeFileHeader, SpikeVarHeader] = nexcortex2spk(varargin)
%
% This function should be launched from: SpikeTools Main Menu >> File > Create SPK File
%
% This program merges a CORTEX and a NEX file directly into an SPK file, which is not
% backward compatible with earlier SPK files (pre-version 7).  CORTEX files containing
% spike data (such as those merged with Datawave files) can also be converted to SPK files
% using this routine. The new SPK file type is based very closely on Alex Kirrilov's NEX file 
% format, so that it provides a continuous record of the data (not limited to signals recorded 
% between the start- and end-trial codes).  No support is provided for multiple fragments of 
% continous data, however, and a novel marker data type ("7") is used to store header info from 
% the CORTEX file and information about where in the data stream individual trials start and end.
% CORTEX data files created with NEX2CORTEX (from previous versions of SpikeTools) can also be
% converted to new SPK files, but this is not recommended, as this data is not truly continuous;
% If available, the original NEX and CORTEX files should be merged directly with this program.
%
% Technical information about the SPK file format:
%
% The file header is:
%	SpikeFileHeader.MagicNumber 			'int32'	x 1
%	SpikeFileHeader.Version				'int32'	x 1
%	SpikeFileHeader.Comment				'char'	x 256
%	SpikeFileHeader.Frequency			'double' x 1
%	SpikeFileHeader.Beg				'int32'	x 1
%	SpikeFileHeader.End				'int32'	x 1
%	SpikeFileHeader.NumVars				'int32'	x 1
%	SpikeFileHeader.Investigator			'char'	x 64
%	SpikeFileHeader.Experiment			'char'	x 64
%	SpikeFileHeader.Subject				'char'	x 64
%	SpikeFileHeader.SessionDate			'int32'	x 3
%	SpikeFileHeader.CreationDate			'int32'	x 3
%	SpikeFileHeader.ModificationDate		'int32'	x 3
%	SpikeFileHeader.NextFileHeader			'int32'	x 1
%	SpikeFileHeader.Padding				'char'	x 256
%
% Each of the i = 1:SpikeFileHeader.NumVars variables then has a header of the form:
%	SpikeVarHeader(i).Type	 			'int32'	x 1
%	SpikeVarHeader(i).Version	 		'int32'	x 1
%	SpikeVarHeader(i).Name	 			'char'	x 64
%	SpikeVarHeader(i).DataOffset	 		'int32'	x 1
%	SpikeVarHeader(i).Count				'int32'	x 1
%	SpikeVarHeader(i).WireNumber			'int32'	x 1
%	SpikeVarHeader(i).UnitNumber			'int32'	x 1
%	SpikeVarHeader(i).Gain				'int32'	x 1
%	SpikeVarHeader(i).Filter			'int32'	x 1
%	SpikeVarHeader(i).Xpos				'double' x 1
%	SpikeVarHeader(i).Ypos				'double' x 1
%	SpikeVarHeader(i).Zpos				'double' x 1
%	SpikeVarHeader(i).Apos				'double' x 1
%	SpikeVarHeader(i).WFrequency			'double' x 1
%	SpikeVarHeader(i).ADtoMV			'double' x 1
%	SpikeVarHeader(i).NPointsWave			'int32' x 1
%	SpikeVarHeader(i).Padding			'char' x 128
%
%	The SpikeVarHeader.Type field is as in NEX (e.g., 0 for a neuron, 5 for LFP, etc.), but an additional
%	type (#7) is defined as a numerical marker field.  The DATA block of this marker variable is as follows:
%	SpikeVarHeader(i).NMarkers		'int32'	x 1
%	followed by ii = 1:SpikeVarHeader.NMarkers repeats of:
%	SpikeVarHeader(i).MarkerName{ii}	'char'	x 64
%	SpikeVarHeader(i).MarkerLength{ii}	'int32'	x 1
%	SpikeVarHeader(i).MarkerValues{ii}	'int32'	x SpikeVarHeader(i).MarkerLength{ii}
%
%	Note that there are SpikeVarHeader(i).Count repeats of this structure within each variable 7 data block.
%
%	There are up to 5 variables of type 7 in an SPK file, corresponding to
%	1)	"StrobedBehavioralCodes"	[The stream of behavioral codes in absolute time]
%	2)	"TrialInfo"			[Where each trial begins and ends in absolute time, and the index into the behavioral code vectors]
%	3)	"CortexHeaderInfo"		[Information gathered from the Cortex Headers, such as ConditionNumber and ResponseError]
%	4)	"EyePosition"			[Eye position data, if present]
%	5)	"SpikeTable"			[The index into the spike timestamps identifying where each trial begins and ends]
%
%	See also: SPK_READ, SPK_INFO, and CREATE_SPK_WINDOW
%
% created 2/8/2001  --WA
% last modified 4/2/2001  --WA

nc2s_version = '1.7';
SpikeFileVersion = 702;

SpikeConfig = spiketools_config(0);
directories;

batchmode = 0;
if isempty(varargin),
   f = findobj('type', 'figure', 'tag', 'CSW');
   if isempty(f),
      create_spk_window;
   else
      figure(f);
   end
	return
else
   chosen_file = varargin{1};
   if length(varargin) > 1,
      batchmode = varargin{2};
   end
end

if isempty(findobj('type', 'figure', 'tag', 'CSW')),
   create_spk_window;
end
if SpikeConfig.IncludeLFP == 0,
   create_spk_window('WriteLFPCheck', -1);
end

dot = max(find(chosen_file == '.'));
ext = chosen_file(dot+1:length(chosen_file));
if strmatch(lower(ext), 'nex'),
   create_spk_window('MessageBox', 'ERROR: Select a CORTEX file, not a NEX file');
   return
else
   cortex_file = chosen_file;
   nex_file = strcat(cortex_file(1:dot), 'nex');
end

create_spk_window('MessageBox', sprintf('Running NexCortex2SPK version %s', nc2s_version));
create_spk_window('MessageBox', sprintf('Will write SPK file version %2.2f', SpikeFileVersion/100));

f = find(cortex_file == filesep);
if isempty(f),
   cortex_filename = cortex_file;
else
   cortex_filename = cortex_file(max(f)+1:length(cortex_file));
end
f = find(nex_file == filesep);
if isempty(f),
   nex_filename = nex_file;
else
   nex_filename = nex_file(max(f)+1:length(nex_file));
end

spk_file = strrep(nex_file, '.nex', '.spk');
slash = find(spk_file == filesep);
if isempty(slash), 
   spk_filename = spk_file;
   spk_file = cat(dir_spk, spk_file);
else
   slash = max(slash);
   spk_filename = spk_file(slash+1:length(spk_file));
   spk_file = strcat(dir_spk, spk_filename);
end
create_spk_window('StatusText', sprintf('Initializing %s...', spk_filename));
fid = fopen(spk_file, 'w');
if fid < 0,
   msg = '*** ERROR: Unable to open SPK file ***';
   create_spk_window('MessageBox', msg);
   error(msg);
   return; 
end

create_spk_window('StatusText', sprintf('Reading %s...', cortex_filename));
ctx = cortex_read(cortex_file);
create_spk_window('CortexCheck', 1);
ctx_numtrials = length(ctx.header);
create_spk_window('MessageBox', sprintf('Found %i trials in CORTEX file', ctx_numtrials));
no_eye_data = 0;
if isempty(ctx.eog),
   no_eye_data = 1;
   create_spk_window('MessageBox', sprintf('No eye data found in %s', cortex_filename));
   create_spk_window('WriteEyeCheck', -1);
end

if exist(nex_file) ~= 2,
   create_spk_window('MessageBox', sprintf('Warning: Cannot find %s', nex_file));
   create_spk_window('MessageBox', 'Will create a SPK file using only the CORTEX data');
   create_spk_window('StatusText', 'Formatting CORTEX data...');
   create_spk_window('NexCheck', -1);
   timeinsert = 100; %add 100ms between trials to generate a pseudocontinuous record
   [NexFileHeader NexVarHeader NexData] = ctx2pseudonex(ctx, timeinsert);
   yesnex = 0;
else
   if ~isempty(ctx.neurons),
      create_spk_window('MessageBox', 'Warning: Neuronal data found in CORTEX file...');
      create_spk_window('MessageBox', '...but will use only NEX neuronal data');
   end
   create_spk_window('StatusText', sprintf('Reading %s...', nex_filename));
	[NexFileHeader NexVarHeader NexData] = nex_read(nex_file);
   create_spk_window('NexCheck', 1);
   yesnex = 1;
end

log_file = strcat(cortex_file(1:dot), 'log');
fcheck = fopen(log_file, 'w');
fprintf(fcheck, sprintf('nexcortex2spk v%s\r\n', nc2s_version));
fprintf(fcheck, 'Created by Wael Asaad, February 8, 2001\r\nlast modified March 22, 2001\r\n\r\n');
fprintf(fcheck, 'SPK file generated will be version %2.2f\r\n', SpikeFileVersion/100);
fprintf(fcheck, '%s\r\n\r\n', date);

varnames = strvcat(NexVarHeader.Name);
if NexFileHeader.Version < 103, %Behavioral codes stored differently in older NEX files
   create_spk_window('MessageBox', 'Extracting Behavioral codes from old-format NEX file');
   create_spk_window('MessageBox', 'Warning: will not include Type 1 Nex variables');
   count = 0;
   firstcode = 0;
   for i = 1:NexFileHeader.NumVars,
      if findstr(NexVarHeader(i).Name, 'SEvent'),
         oldnexcodes(i) = str2num(NexVarHeader(i).Name(7:11));
         oldnextimes(i) = NexData(i);
         if firstcode == 0, 
            firstcode = 1; 
            count = count + 1;
            goodvar(count) = i;
            varindex_codes = i;
            NexVarHeader(i).Name = 'Strobed';
         end
      elseif NexVarHeader(i).Type ~= 1,
         count = count + 1;
         goodvar(count) = i;
      end
   end
   findcodes = find(oldnexcodes);
   for i = 1:length(findcodes),
      cindx = findcodes(i);
      codenums{i} = ones(size(NexData{cindx})).*oldnexcodes(cindx);
      codetims(i) = oldnextimes(cindx);
   end
   [nex_codetimes sortindx] = sort(cat(1, codetims{:}));
   codenums = cat(1, codenums{:});
   nex_codes = codenums(sortindx);
   %now chop out all the unneeded, old-style marker variables (except one, to be replaced below)
   NexVarHeader = NexVarHeader(goodvar);
   NexData = NexData(goodvar);
   NexFileHeader.NumVars = length(goodvar);
   varnames = strvcat(NexVarHeader.Name);
else
	varindex_codes = strmatch('Strobed', varnames);
	if isempty(varindex_codes),
	   varindex_codes = strmatch('Marker', varnames);
	   if isempty(varindex_codes),
	   	msg = 'ERROR: Behavioral Codes not detected in NEX file';
	      create_spk_window('MessageBox', msg);
	      error(msg);
	      return
	   else
	      nex_codes = NexVarHeader(varindex_codes).MarkerValues{2};
	      create_spk_window('MessageBox', 'Extracted codes from non-Plexon-native NEX file');
	      if SpikeConfig.UseNexCodes == 1,
	         msg = 'Warning: CORTEX codes in NEX file via DataWave are unreliable';
	         create_spk_window('MessageBox', msg);
         end
         NexVarHeader(varindex_codes).Name = 'Strobed';
	   end
	else
	   nex_codes = NexVarHeader(varindex_codes).MarkerValues{:};
   end
   nex_codetimes = NexData{varindex_codes};
end
vartypes = cat(1, NexVarHeader.Type);
varindex_neurons = find(vartypes == 0);
neuroncount = 0;
varindex_lfp = find(vartypes == 5);

if yesnex,
	create_spk_window('MessageBox', sprintf('%i codes in CORTEX and %i codes in NEX', ctx.number_of_codes, length(nex_codes)));
	fprintf(fcheck, '*** Merging %s with %s ***\r\n\r\n', cortex_file, nex_file);
	fprintf(fcheck, '(NEX file version: %i)\r\n\r\n', NexFileHeader.Version');
   fprintf(fcheck, 'Found %i Units in %s\r\n', length(varindex_neurons), nex_file);   
else
   create_spk_window('MessageBox', sprintf('%i codes in CORTEX', ctx.number_of_codes));
end

if ~isempty(varindex_neurons),
	for i = 1:length(varindex_neurons),
	   fprintf(fcheck, '\t%i spikes of unit %s\r\n', NexVarHeader(varindex_neurons(i)).Count, NexVarHeader(varindex_neurons(i)).Name);
   end
else
   create_spk_window('MessageBox', 'No Spikes detected');
   create_spk_window('WriteSpikeCheck', -1);
end
if isempty(varindex_lfp),
   create_spk_window('MessageBox', 'No LFP data detected');
   create_spk_window('WriteLFPCheck', -1);
end

if yesnex,
   create_spk_window('StatusText', 'Extracting trials from NEX file...');
else
   create_spk_window('StatusText', 'Re-extracting trial information...');
end
[start_indx, end_indx, start_times, end_times] = extract_trials(nex_codes, nex_codetimes, fcheck);
nex_numtrials = length(start_indx);
betweentrials = mean(start_times(2:nex_numtrials) - end_times(1:nex_numtrials-1));
if yesnex,
   create_spk_window('MessageBox', sprintf('Found %i trials in NEX file', nex_numtrials));
   create_spk_window('MessageBox', sprintf('Average time between trials: %2.2f seconds', betweentrials));
else
   create_spk_window('MessageBox', 'Created a pseudo-continous data stream from CORTEX');
end

if nex_numtrials > ctx_numtrials,
   msg = 'Warning: more NEX than CORTEX trials; truncating NEX data';
   create_spk_window('MessageBox', msg);
   numtrials = ctx_numtrials;
elseif ctx_numtrials > nex_numtrials,
   msg = 'Warning: more CORTEX than NEX trials; truncating CORTEX data';
   create_spk_window('MessageBox', msg);
   numtrials = nex_numtrials;
else
   numtrials = ctx_numtrials;
end

start_indx = start_indx(1:numtrials);
end_indx = end_indx(1:numtrials);
start_times = start_times(1:numtrials);
end_times = end_times(1:numtrials);

if SpikeConfig.UseNexCodes == 0, %calculate timestamp of CORTEX codes relative to Start Trial Codes in NEX file
   numcodes = 0;
   for i = 1:numtrials,
      ct = ctx.codetimes{i};
      cn = ctx.codes{i};
      f = find(cn == SpikeConfig.StartTrialCode);
      if isempty(f),
         msg = sprintf('ERROR: Start Trial Code missing from trial %i', i);
         create_spk_window('MessageBox', msg);
         error(msg);
         return
      elseif length(f) < SpikeConfig.StartCodeOccurrence,
         msg = sprintf('Warning: Specified occurrence of Start Trial Code missing from trial %i', i);
         create_spk_window('MessageBox', msg);
         f = max(f);
      else
         f = f(SpikeConfig.StartCodeOccurrence);
      end
      ct = start_times(i) + ((ct - ct(f))/1000);
      ct_indx = (numcodes+1):(numcodes+length(ct));
      ctx_codetimes(ct_indx) = ct;
      ctx_codes(ct_indx) = cn;
      numcodes = numcodes + length(ct);      
   end
   nex_codes = ctx_codes';
   nex_codetimes = ctx_codetimes';
   %now re-evaluate indices
   [start_indx, end_indx, start_times, end_times] = extract_trials(nex_codes, nex_codetimes, fcheck);
end

create_spk_window('TrialCheck', 1);

maxtime = NexFileHeader.End - NexFileHeader.Beg; %duration of file, in ticks
maxtime = maxtime/NexFileHeader.Frequency; %duration of file, in seconds
numhours = floor(maxtime/3600);
numminutes = floor(maxtime/60) - (60*numhours);
numseconds = maxtime - (3600*numhours) - (60*numminutes);
if yesnex,
   msg = sprintf('Recording Duration: %i hour(s), %i minutes, and %2.2f seconds', numhours, numminutes, numseconds);
else
   msg = sprintf('Summed Trial Durations: %i hour(s), %i minutes, %2.2f seconds', numhours, numminutes, numseconds);
end
create_spk_window('MessageBox', msg);
create_spk_window('MessageBox', sprintf('Found %i neurons and %i LFP channels', length(varindex_neurons), length(varindex_lfp)));

fprintf(fcheck, 'Found %i trials over %i hours, %i minutes, and %2.2f seconds.\r\n\r\n', numtrials, numhours, numminutes, numseconds);
fprintf(fcheck, '%i channels of LFP data detected\r\n\r\n', length(varindex_lfp));
fprintf(fcheck, '%s\r\n\r\n', msg);

ctx_codes = cat(1, ctx.codes{:});
uctxcodes = unique(ctx_codes);
unexcodes = unique(nex_codes);
extractxcodes = find(~ismember(uctxcodes, unexcodes));
if ~isempty(extractxcodes),
   msg = sprintf('Warning: Missing code #''s from NEX file: %s', num2str(extractxcodes));
   create_spk_window('MessageBox', msg);
   fprintf(fcheck, strcat(msg, '\r\n\r\n'));
end
extranexcodes = find(~ismember(unexcodes, uctxcodes));
if ~isempty(extranexcodes),
   msg = sprintf('Warning: Extra code #''s in NEX file: %s', num2str(extranexcodes));
   create_spk_window('MessageBox', msg);
   fprintf(fcheck, strcat(msg, '\r\n\r\n'));
end

create_spk_window('StatusText', 'Assigning spikes to trials...');
create_spk_window('ProgressBar', 0);
for i = 1:length(varindex_neurons),
   [spike_index{i} numspikes{i}] = assign_trials(NexData{varindex_neurons(i)}, start_times, end_times);
   create_spk_window('ProgressBar', i/length(varindex_neurons));
end
create_spk_window('AssignCheck', 1);

CortexHeader = cat(2, ctx.header{:})';
cond_no = CortexHeader(:, 2) + 1; %CORTEX is zero-based
repeat_no = CortexHeader(:, 3);
block_no = CortexHeader(:, 4) + 1;
trial_no = CortexHeader(:, 5);
isi_size = CortexHeader(:, 6); %used to read codes, then will be discarded (not used in SPK file)
code_size = CortexHeader(:, 7); %will be discarded
eog_size = CortexHeader(:, 8); %will be discarded
epp_size = CortexHeader(:, 9); %will be discarded
eye_storage_ticks = CortexHeader(:, 10); %used to calculate eye_storage rate, then discarded
khz_resolution = CortexHeader(:, 11); %used to calculate eye_storage rate, then discarded
expected_response = CortexHeader(:, 12);
response = CortexHeader(:, 13);
response_error = CortexHeader(:, 14);

cond_no = cond_no(1:numtrials);
repeat_no = repeat_no(1:numtrials);
block_no = block_no(1:numtrials);
trial_no = trial_no(1:numtrials);
expected_response = expected_response(1:numtrials);
response = response(1:numtrials);
response_error = response_error(1:numtrials);

khz_resolution(find(~khz_resolution)) = 1;
if ~no_eye_data,
	eye_storage_rate = 1000*khz_resolution(1)/eye_storage_ticks(1); %in Hz (assumes values for khz_resolution and eye_stoarge ticks are constant throughout a file)
else
   eye_storage_rate = 0;
end

if isempty(find(repeat_no)), %older versions of CORTEX don't calculate this correctly (or at all)...
   for blockloop = 1:max(block_no),
      conds = unique(cond_no(find(block_no == blockloop)));
      for condloop = 1:length(conds),
         condnum = conds(condloop);
         f = find(cond_no == condnum & block_no == blockloop);
         repeat_no(f) = 0:(length(f)-1);
      end
   end
end
numnewvars = 2;
numnewvars = numnewvars + ~no_eye_data + ~isempty(varindex_neurons);
%code indx / code info / Eye data / spike trial indx

SpikeFileHeader = NexFileHeader;
SpikeFileHeader.MagicNumber = 559417104;
SpikeFileHeader.Version = SpikeFileVersion;
SpikeFileHeader.NumVars = SpikeFileHeader.NumVars + numnewvars;

SpikeFileHeader.Investigator = str2padchar(SpikeConfig.Investigator, 64);
SpikeFileHeader.Experiment = str2padchar('Unspecified', 64);
SpikeFileHeader.Subject = str2padchar('Unspecified', 64);
CreationDate = datevec(date);
SpikeFileHeader.SessionDate = CreationDate(1:3);
SpikeFileHeader.CreationDate = CreationDate(1:3);
SpikeFileHeader.ModificationDate = CreationDate(1:3);

if ~isempty(varindex_neurons),
   breakpoint = min(varindex_neurons) - 1;
elseif ~isempty(varindex_lfp),
   breakpoint = min(varindex_lfp) - 1;
else
   breakpoint = NexFileHeader.NumVars;
end
numoldvars = NexFileHeader.NumVars;
SpikeVarHeader(1:breakpoint) = NexVarHeader(1:breakpoint);
SpikeVarHeader(breakpoint+numnewvars+1:numoldvars+numnewvars) = NexVarHeader(breakpoint+1:numoldvars);
OrigNexVarNum(1:breakpoint) = 1:breakpoint;
OrigNexVarNum(breakpoint+numnewvars+1:numoldvars+numnewvars) = (breakpoint+1):numoldvars;

if length(SpikeFileHeader.Comment) < 256,
   SpikeFileHeader.Comment(length(SpikeFileHeader.Comment)+1:256) = 0;
end

%%%%%%%%%%%%%%%%% Write File Header %%%%%%%%%%%%%%%%%%%%%
fwrite(fid, SpikeFileHeader.MagicNumber, 'int32');
fwrite(fid, SpikeFileHeader.Version, 'int32');
fwrite(fid, SpikeFileHeader.Comment, 'char');
fwrite(fid, SpikeFileHeader.Frequency, 'double');
fwrite(fid, SpikeFileHeader.Beg, 'int32');
fwrite(fid, SpikeFileHeader.End, 'int32');
fwrite(fid, SpikeFileHeader.NumVars, 'int32');
fwrite(fid, SpikeFileHeader.Investigator, 'char');
fwrite(fid, SpikeFileHeader.Experiment, 'char');
fwrite(fid, SpikeFileHeader.Subject, 'char');
fwrite(fid, SpikeFileHeader.SessionDate, 'int32');
fwrite(fid, SpikeFileHeader.CreationDate, 'int32');
fwrite(fid, SpikeFileHeader.ModificationDate, 'int32');
fwrite(fid, SpikeFileHeader.NextFileHeader, 'int32');
fwrite(fid, SpikeFileHeader.Padding, 'char');

create_spk_window('StatusText', sprintf('Writing %s', spk_filename));
create_spk_window('ProgressBar', 0);
for i = 1:SpikeFileHeader.NumVars, %%%%%%%%%%% Write Variable Headers %%%%%%%%%%%%
   
   SpikeVarHeader(i).DataOffset = 0; %temporary until true offset is determined
   if ~isempty(SpikeVarHeader(i).Type) & (SpikeVarHeader(i).Type == 0 | SpikeVarHeader(i).Type == 5),
      writeloc = SpikeConfig.DefaultNoLocationCode;
   else
      writeloc = 0;
   end

	SpikeVarHeader(i).Xpos = writeloc;
	SpikeVarHeader(i).Ypos = writeloc;
	SpikeVarHeader(i).Zpos = writeloc;
	SpikeVarHeader(i).Apos = writeloc;
   SpikeVarHeader(i).Padding = zeros(1, 128);
   padding = zeros(1, 64);
   varname = SpikeVarHeader(i).Name;
   if (length(varname) == 7) & (varname == 'Strobed'),
      varpointer = 0.5;
   else
      varpointer = i - breakpoint;
   end
   
   if varpointer > 0 & varpointer <= numnewvars, %create new numerical marker fields (not like char marker type 6)
      SpikeVarHeader(i).Type = 7; %new type (not in NEX): simplified marker field using int32 data type
      SpikeVarHeader(i).Version = 100;
      SpikeVarHeader(i).DataOffset = 0;
   	SpikeVarHeader(i).WireNumber = 0;
   	SpikeVarHeader(i).UnitNumber = 0;
   	SpikeVarHeader(i).Gain = 0;
   	SpikeVarHeader(i).Filter = 0;
   	SpikeVarHeader(i).Xpos = 0;
   	SpikeVarHeader(i).Ypos = 0;
   	SpikeVarHeader(i).Zpos = 0;
   	SpikeVarHeader(i).Apos = 0;
      SpikeVarHeader(i).WFrequency = 0;
      SpikeVarHeader(i).ADtoMV = 0;
      SpikeVarHeader(i).NPointsWave = 0;
      if varpointer == 0.5, %reformat strobed data into type 7
         SpikeVarHeader(i).Count = 1;
         NMarkers = 2;
         SpikeVarHeader(i).Name = 'StrobedBehavioralCodes';
         %to be placed in Data fields:
         SpikeVarHeader(i).NMarkers = ones(1, SpikeVarHeader(i).Count)*NMarkers;
         SpikeVarHeader(i).MarkerName = {strvcat('Code numbers', 'Code times')};
         SpikeVarHeader(i).MarkerLength = {ones(1, NMarkers)*length(nex_codes)};
         SpikeVarHeader(i).MarkerValues = {cat(1, nex_codes, round(SpikeFileHeader.Frequency*nex_codetimes))};
      elseif varpointer == 1, %code index & numcodes per trial
         SpikeVarHeader(i).Count = 1;
         NMarkers = 4;
         SpikeVarHeader(i).Name = 'TrialInfo';
         %to be placed in Data fields:
         SpikeVarHeader(i).NMarkers = ones(1, SpikeVarHeader(i).Count)*NMarkers;
         SpikeVarHeader(i).MarkerName = {strvcat('Trial start times', 'Trial end times', 'Behavioral code index', 'Codes per trial')};
         SpikeVarHeader(i).MarkerLength = {ones(1, NMarkers)*numtrials};
         codes_per_trial = end_indx - start_indx + 1;
         SpikeVarHeader(i).MarkerValues = {cat(1, round(SpikeFileHeader.Frequency*start_times), round(SpikeFileHeader.Frequency*end_times), start_indx, codes_per_trial)};
      elseif varpointer == 2, %cortex header info (cond_no, response_error, etc.)
         SpikeVarHeader(i).Count = 1;
         NMarkers = 7;
         SpikeVarHeader(i).Name = 'CortexHeaderInfo';
         %to be placed in Data fields:
         SpikeVarHeader(i).NMarkers = ones(1, SpikeVarHeader(i).Count)*NMarkers;
         SpikeVarHeader(i).MarkerName = {strvcat('cond_no', 'repeat_no', 'block_no', 'trial_no', 'expected_response', 'response', 'response_error')};
         SpikeVarHeader(i).MarkerLength = {ones(1, NMarkers)*numtrials};
         SpikeVarHeader(i).MarkerValues = {cat(1, cond_no, repeat_no, block_no, trial_no, expected_response, response, response_error)};
         create_spk_window('WriteHeaderCheck', 1);
      elseif varpointer == 3 & ~no_eye_data, %eye movement data
         %Because CORTEX can only acquire eye data within a trial and is over-all discontinuous, must store 
         %eye position in a trial-based format different from other analog data (e.g., LFPs)
         SpikeVarHeader(i).WFrequency = eye_storage_rate;
         SpikeVarHeader(i).Count = 1;
         NMarkers = 4;
         SpikeVarHeader(i).Name = 'EyePosition';
         SpikeVarHeader(i).ADtoMV = SpikeConfig.EyeUnitsPerDegree;
         %to be placed in Data fields:
         SpikeVarHeader(i).NMarkers = ones(1, SpikeVarHeader(i).Count)*NMarkers;
         SpikeVarHeader(i).MarkerName = {strvcat('X coordinate', 'Y coordinate', 'Eye Index', 'samples per trial')};
         EyeData = cat(1, ctx.eog{:});
         EyeX = EyeData(:, 1);
         EyeY = EyeData(:, 2);
         for ii = 1:numtrials,
            samples_per_trial(ii) = size(ctx.eog{ii}, 1);
         end
         samples_per_trial = samples_per_trial';
         EyeIndex = 1 + cat(1, 0, cumsum(samples_per_trial));
         EyeIndex = EyeIndex(1:length(EyeIndex)-1);
         SpikeVarHeader(i).MarkerLength = {[length(EyeX) length(EyeY) numtrials numtrials]};
         SpikeVarHeader(i).MarkerValues = {cat(1, EyeX, EyeY, EyeIndex, samples_per_trial)};
         create_spk_window('WriteEyeCheck', 1);      
      elseif (varpointer == 4) | ((varpointer == 3) & no_eye_data), %spike directory
         create_spk_window('StatusText', 'Writing spike directory...');
         SpikeVarHeader(i).Count = length(varindex_neurons);
         NMarkers = 2;
         SpikeVarHeader(i).Name = 'SpikeTable';
         %to be placed in Data fields:
         SpikeVarHeader(i).NMarkers = ones(1, SpikeVarHeader(i).Count)*NMarkers;
         SpikeVarHeader(i).MarkerName = {strvcat('Spike index', 'spikes per trial')};
         SpikeVarHeader(i).MarkerLength = {ones(1, NMarkers)*numtrials};
         for ii = 1:SpikeVarHeader(i).Count,
            if ii == 1, %re-assign data type to "cell" on first pass
               SpikeVarHeader(i).MarkerValues = {cat(1, spike_index{ii}', numspikes{ii}')};
            else
               SpikeVarHeader(i).MarkerValues{ii} = cat(1, spike_index{ii}', numspikes{ii}'); 
            end
         end
      end
   end
   
   if SpikeVarHeader(i).Type == 0, %neuron
      if strmatch('sig', SpikeVarHeader(i).Name),
         elecnumindx = 4:6;
         unitnumindx = 7;
      elseif strmatch('Probe', SpikeVarHeader(i).Name),
         elecnumindx = 7:8;
         unitnumindx = 9;
      else
         msg = 'ERROR: Unrecognized neuron naming scheme in NEX file';
         create_spk_window('MessageBox', msg);
         error(msg);
         return;
      end
      neuroncount = neuroncount + 1;
	   electrode = str2num(varname(elecnumindx));
		unit = find('abcdefgh' == varname(unitnumindx));
      neuron_id(neuroncount) = (900 + (100*electrode)) + unit;
      SpikeVarHeader(i).WireNumber = electrode;
      SpikeVarHeader(i).UnitNumber = unit;
      SpikeVarHeader(i).Name = padding;
      SpikeVarHeader(i).Name(1:11) = double(sprintf('Neuron %i', (neuron_id(neuroncount))));
   elseif SpikeVarHeader(i).Type == 5; %LFP
      varname = SpikeVarHeader(i).Name;
      fs = find(double(varname) > 47 & double(varname) < 58);
      electrode = str2num(varname(fs));
      SpikeVarHeader(i).WireNumber = electrode;
      SpikeVarHeader(i).Name = padding;
      SpikeVarHeader(i).Name(1:8) = double(sprintf('LFP %i', (900 + (100*electrode))));
      if SpikeConfig.IncludeLFP == 0,
         SpikeVarHeader(i).Count = 0;
      end
   else
      varname = SpikeVarHeader(i).Name;
      SpikeVarHeader(i).Name = padding;
      SpikeVarHeader(i).Name(1:length(varname)) = double(varname);
   end
   
   fwrite(fid, SpikeVarHeader(i).Type, 'int32');
   fwrite(fid, SpikeVarHeader(i).Version, 'int32');
   fwrite(fid, SpikeVarHeader(i).Name, 'char');
   DataOffsetLocation(i) = ftell(fid);
   fwrite(fid, SpikeVarHeader(i).DataOffset, 'int32');
   fwrite(fid, SpikeVarHeader(i).Count, 'int32');
   fwrite(fid, SpikeVarHeader(i).WireNumber, 'int32');
   fwrite(fid, SpikeVarHeader(i).UnitNumber, 'int32');
   fwrite(fid, SpikeVarHeader(i).Gain, 'int32');
   fwrite(fid, SpikeVarHeader(i).Filter, 'int32');
   fwrite(fid, SpikeVarHeader(i).Xpos, 'double');
   fwrite(fid, SpikeVarHeader(i).Ypos, 'double');
   fwrite(fid, SpikeVarHeader(i).Zpos, 'double');
   fwrite(fid, SpikeVarHeader(i).Apos, 'double');
   fwrite(fid, SpikeVarHeader(i).WFrequency, 'double');
   fwrite(fid, SpikeVarHeader(i).ADtoMV, 'double');
   fwrite(fid, SpikeVarHeader(i).NPointsWave, 'int32');
   fwrite(fid, SpikeVarHeader(i).Padding, 'char');
   
   create_spk_window('ProgressBar', i/SpikeFileHeader.NumVars);
end

if yesnex,
   fidnex = fopen(nex_file, 'r');
end
neuroncount = 0;
lfpcount = 0;
for i = 1:SpikeFileHeader.NumVars, %%%%%%%%%%%% Write Data blocks %%%%%%%%%%%%%
   DataOffsetValue(i) = ftell(fid);
   vartype = SpikeVarHeader(i).Type;
         
   if vartype == 3, %waveform
      
      d = NexData{i};
      hdl = length(d)/2;
      d1 = d(1:dl);
      d2 = d(dl+1:2*dl);
      fwrite(fid, round(SpikeFileHeader.Frequency*d1), 'int32');
      fwrite(fid, d2, 'int16');
      
   elseif vartype == 5, % LFP
      
      if SpikeConfig.IncludeLFP == 1,
         create_spk_window('StatusText', sprintf('Copying LFP data to %s', spk_filename'));
         if lfpcount == 0,
            create_spk_window('ProgressBar', 0);
         end
         lfpcount = lfpcount + 1;
	      nexvarnum = OrigNexVarNum(i);
	      fseek(fidnex, NexVarHeader(nexvarnum).DataOffset, -1);
	      numpoints = NexVarHeader(nexvarnum).NPointsWave;
	      numfrags = NexVarHeader(nexvarnum).Count;
	      LFP_StartTime = fread(fidnex, numfrags, 'int32'); %will not write these variables because
	      LFP_FragIndex = fread(fidnex, numfrags, 'int32'); %multiple fragments not supported...
	      chunk = 1000000;
	      for ii = 1:chunk:numpoints,
	         if (ii+chunk) > numpoints,
	            readlength = numpoints - ii + 1;
	         else
	            readlength = chunk;
	         end
	         datachunk = fread(fidnex, readlength, '*int16');
	         fwrite(fid, datachunk, 'int16');
         end
         create_spk_window('ProgressBar', lfpcount/length(varindex_lfp));
	      if lfpcount == length(varindex_lfp),
	         create_spk_window('WriteLFPCheck', 1);
         end
      end
      
   elseif vartype == 7, % numerical marker
      for ii = 1:SpikeVarHeader(i).Count,
                  
         NMarkers = SpikeVarHeader(i).NMarkers(ii);
         fwrite(fid, NMarkers, 'int32');
         
         if length(SpikeVarHeader(i).MarkerName) > 1, nindex = ii; else, nindex = 1; end;
         markernames = SpikeVarHeader(i).MarkerName{nindex};
         if length(SpikeVarHeader(i).MarkerLength) > 1, nindex = ii; else, nindex = 1; end;
         markerlengths = SpikeVarHeader(i).MarkerLength{nindex};
         if length(SpikeVarHeader(i).MarkerValues) > 1, nindex = ii; else, nindex = 1; end;
         markervalues = SpikeVarHeader(i).MarkerValues{nindex};
         
         for iii = 1:NMarkers,
            tempname = deblank(markernames(iii, :));
            mname = zeros(1, 64);
            mname(1:length(tempname)) = tempname;
            fwrite(fid, mname, 'char');
            fwrite(fid, markerlengths(iii), 'int32');
            dataindex_end = sum(markerlengths(1:iii));
            dataindex_start = dataindex_end - markerlengths(iii) + 1;
            fwrite(fid, markervalues(dataindex_start:dataindex_end), 'int32');
         end
                  
      end
      
   else %for all other data types:
      
      
      fwrite(fid, round(SpikeFileHeader.Frequency*NexData{OrigNexVarNum(i)}), 'int32');
      
      if vartype == 0, %neuron
         if neuroncount == 0,
            create_spk_window('StatusText', 'Writing spike data...');
         end
       	create_spk_window('ProgressBar', neuroncount/length(varindex_neurons));
         neuroncount = neuroncount + 1;
	      if neuroncount == length(varindex_neurons),
	         create_spk_window('WriteSpikeCheck', 1);
         end
      end
      
   end
   
end

spk_filesize = ftell(fid)/1024000;
create_spk_window('MessageBox', sprintf('SPK file size: %4.2f MB', spk_filesize));

for i = 1:SpikeFileHeader.NumVars %%% update DataOffset fields ***
   fseek(fid, DataOffsetLocation(i), -1);
   fwrite(fid, DataOffsetValue(i), 'int32');
end

if yesnex,
	for i = 1:numtrials,
	   nex_trial_length = round(1000*(end_times(i) - start_times(i))) + 1;
	   ctx_trial_length = ctx.trial_duration(i);
	   mismatch(i) = ctx_trial_length - nex_trial_length;
	   fprintf(fcheck, 'Trial %i; Cond %i; ResponseError %i; >> %ims in Nex, %ims in Cortex, mismatch = %ims\r\n', i, cond_no(i), response_error(i), nex_trial_length, ctx_trial_length, mismatch(i));
	end
	fprintf(fcheck, '\r\nMismatch  Mean: %3.2fms  Standard Deviation: %3.2fms\r\n', mean(mismatch), std(mismatch));
	dropped_codes = ctx.number_of_codes - length(nex_codes);
	fprintf(fcheck, '\r\n%i (%3.2f%%) of %i behavioral codes dropped from Cortex to Nex.\r\n', dropped_codes, 100*(dropped_codes/length(nex_codes)), length(nex_codes));
	create_spk_window('MessageBox', sprintf('Mean temporal mismatch between CORTEX and NEX = %2.1fms', mean(mismatch)));
   fclose(fidnex);   
end

fprintf(fcheck, '\r\nSuccessfully created %s\r\n', spk_file);
create_spk_window('ViewLog', log_file);

fclose(fid);
fclose(fcheck);

create_spk_window('StatusText', sprintf('Done creating %s', spk_filename));
create_spk_window('MessageBox', '*******************');
create_spk_window('ProgressBar', 0);
if yesnex & ~batchmode,
   spk_info(spk_filename);
end

try
	f1 = 1.0;
	f2 = 2.0;
   sdur = 700;
	xvec = sin(0:f1:(f1*sdur)) + sin(0:f2:(f2*sdur));
	svec = cat(2, xvec, zeros(size(xvec)), xvec, zeros(size(xvec)), xvec);
   sound(svec/10);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [trial_index, numevents] = assign_trials(timestamps, start_times, end_times)

skip_factor = 1000;
sparse_times = timestamps(1:skip_factor:length(timestamps));
for trial = 1:length(start_times),
   tstart = start_times(trial);
   tend = end_times(trial);
   minf = find(sparse_times < tstart);
   if isempty(minf),
      minindex = 1;
   else
      minindex = (max(minf)*skip_factor)-skip_factor+1;
   end
   maxf = find(sparse_times > tend);
   if isempty(maxf),
      maxindex = length(timestamps);
   else
      maxindex = min(maxf)*skip_factor;
      if maxindex > length(timestamps),
         maxindex = length(timestamps);
      end
   end
   ts = timestamps(minindex:maxindex);
   mf = find(ts > tstart);
   if isempty(mf) | (tend - tstart <= 0),
      if trial > 1,
         trial_index(trial) = trial_index(trial-1);
      else
         trial_index(trial) = 1;
      end
   else
      trial_index(trial) = min(mf) + minindex - 1;
   end
end

numevents = diff(trial_index);
numevents(trial + 1) = sum(timestamps > tstart & timestamps < tend);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [NexFileHeader, NexVarHeader, NexData] = ctx2pseudonex(ctx, timeinsert)

create_spk_window('ProgressBar', 0);

CortexHeader = cat(2, ctx.header{:})';
khz_resolution = CortexHeader(:, 11); %used to calculate eye_storage rate, then discarded
khz_resolution(find(~khz_resolution)) = 1;

numvars = 1;
if ~isempty(ctx.spiketimes),
   allneurons = unique(cat(1, ctx.neurons{:}));
   numneurons = length(allneurons);
   numvars = numvars + numneurons;
else
   create_spk_window('WriteSpikeCheck', -1);
end

comment = zeros(1, 256);
comment(1:75) = double('Pseudo-continuous SPK file generated from a CORTEX file alone (no NEX file)');

NexFileHeader.MagicNumber = 827868494;
NexFileHeader.Version = 104;
NexFileHeader.Comment = comment;
NexFileHeader.Frequency = 1000*khz_resolution(1);
NexFileHeader.Beg = 0;
NexFileHeader.End = sum(ctx.trial_duration);
NexFileHeader.NumVars = numvars;
NexFileHeader.NextFileHeader = 0;
NexFileHeader.Padding = zeros(256, 1);

%Create "Strobed" variable:
codes = cat(1, ctx.codes{:});
tdurations = (ctx.trial_duration + timeinsert)'; %insert 100ms between trials
create_spk_window('MessageBox', sprintf('Inserting %ims between trials', timeinsert));
trialoffsets = cat(1, 0, cumsum(tdurations));
for trial = 1:length(ctx.codetimes),
   ctx.codetimes{trial} = ctx.codetimes{trial} + trialoffsets(trial);
end
codetimes = cat(1, ctx.codetimes{:});

varcount = 1;
NexVarHeader(varcount).Type = 6;
NexVarHeader(varcount).Version = 100;
NexVarHeader(varcount).Name = 'Strobed';
NexVarHeader(varcount).DataOffset = 0;
NexVarHeader(varcount).Count = length(codes);
NexVarHeader(varcount).WireNumber = 0;
NexVarHeader(varcount).UnitNumber = 0;
NexVarHeader(varcount).Gain = 0;
NexVarHeader(varcount).Filter = 0;
NexVarHeader(varcount).Xpos = 0;
NexVarHeader(varcount).Ypos = 0;
NexVarHeader(varcount).WFreqency = 0;
NexVarHeader(varcount).ADtoMV = 0;
NexVarHeader(varcount).NPointsWave = 0;
NexVarHeader(varcount).Padding = zeros(68, 1);
NexVarHeader(varcount).NMarkers = 1;
NexVarHeader(varcount).MarkerLength = 0;
NexVarHeader(varcount).MarkerName = {'DIO'};
NexVarHeader(varcount).MarkerValues = {codes};
NexData{varcount} = codetimes/NexFileHeader.Frequency;
create_spk_window('ProgressBar', 1/numvars);

if ~isempty(ctx.spiketimes),
   for i = 1:numneurons,
      
      n = allneurons(i);
      wirenumber = round(n/100) - 9;
      ulets = 'abcdefghij';
      unitletter = mod(n, 100);
      if unitletter > 0,
         if unitletter > 10,
            msg = 'ERROR: Neuron number out-of-bounds. Corrupt file?';
            create_spk_window('MessageBox', msg);
            error(msg);
            return
         end
         unitletter = ulets(unitletter);
         varcount = varcount + 1;
         nname = num2str(wirenumber/1000);
	      dot = find(nname == '.');
	      nname = strcat('sig', nname(dot+1:length(nname)), unitletter);
	      
	      spiketimes = [];
	      for trial = 1:length(ctx.header),
            f = find(ctx.neurons{trial} == n);           
	         if ~isempty(f),
	            trialspikes = ctx.spiketimes{trial};
	            trialspikes = trialspikes{f} + trialoffsets(trial);
               spiketimes = cat(1, spiketimes, trialspikes);
	         end
	      end
	      
	      NexVarHeader(varcount).Type = 0;
	      NexVarHeader(varcount).Version = 100;
	      NexVarHeader(varcount).Name = nname;
	      NexVarHeader(varcount).DataOffset = 0;
	      NexVarHeader(varcount).Count = length(spiketimes);
	      NexVarHeader(varcount).WireNumber = 0;
	      NexVarHeader(varcount).UnitNumber = 0;
	      NexVarHeader(varcount).Gain = 0;
	      NexVarHeader(varcount).Filter = 0;
	      NexVarHeader(varcount).Xpos = 0;
	      NexVarHeader(varcount).Ypos = 0;
	      NexVarHeader(varcount).WFrequency = 0;
	      NexVarHeader(varcount).ADtoMV = 0;
	      NexVarHeader(varcount).NPointsWave = 0;
	      NexVarHeader(varcount).Padding = zeros(76, 1);
	      NexVarHeader(varcount).NMarkers = [];
	      NexVarHeader(varcount).MarkerLength = [];
	      NexVarHeader(varcount).MarkerName = [];
	      NexVarHeader(varcount).MarkerValues = [];
         NexData{varcount} = spiketimes/NexFileHeader.Frequency;         
      else
         create_spk_window('MessageBox', sprintf('Warning: uncut events in cluster %i will be discarded', n));
         SpikeFileHeader.NumVars = SpikeFileHeader.NumVars - 1;
      end
      create_spk_window('ProgressBar', i/numneurons);
	end
end
