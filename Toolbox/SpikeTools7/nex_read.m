function [NexFileHeader, NexVarHeader, NexData] = nex_read(varargin)
%SYNTAX:
%			[NexFileHeader, NexVariableHeaders, NexData] = nex_read(filename, LFP)
%
% If 'filename' is omitted, you will be prompted for a file to be read.  LFP is an optional
% argument which indicates whether or not to read analog data from the NEX file (1=yes).  If 
% omitted, LFP data is not read from the nex file in order to save memory.
%
% Created 5/23/99  -WA
% last modified 10/16/2000 to read NEX file versions up to 104 and to read analog channels.  -WA

directories;
dir_nex = strcat(dir_m, '*.nex');

lfp = 0;
if isempty(varargin),
	[filename pathname] = uigetfile(dir_nex, '*.nex');
   fid = fopen([pathname filename]);
elseif length(varargin) == 1,
   nex_file = varargin{1};
   dot = find(nex_file == '.');
   if isempty(dot),
      nex_file = strcat(nex_file, '.lfp');
   end
   slash = find(nex_file == filesep);
   if isempty(slash),
      nex_file = strcat(dir_m, nex_file);
   end
   fid = fopen(nex_file);
elseif length(varargin) == 2,
   nex_file = varargin{1};
   dot = find(nex_file == '.');
   if isempty(dot),
      nex_file = strcat(nex_file, '.nex');
   end
   slash = find(nex_file == filesep);
   if isempty(slash),
      nex_file = strcat(dir_m, nex_file);
   end
   fid = fopen(nex_file);
   if varargin{2} == 1,
      lfp = 1;
   end
end

%Read File Header
NexFileHeader.MagicNumber = fread(fid, 1, 'int32');
NexFileHeader.Version = fread(fid, 1, 'int32');
NexFileHeader.Comment = fread(fid, 256, 'char');
NexFileHeader.Frequency = fread(fid, 1, 'double');
NexFileHeader.Beg = fread(fid, 1, 'int32');
NexFileHeader.End = fread(fid, 1, 'int32');
NexFileHeader.NumVars = fread(fid, 1, 'int32');
NexFileHeader.NextFileHeader = fread(fid, 1, 'int32');
NexFileHeader.Padding = fread(fid, 256, 'char');

if NexFileHeader.Version == 102,
   error('***** Error: No support for Beta NEX file version 102 *****');
   return;
end

csw = findobj('tag', 'CSW');

%Read Variable Headers
totalsteps = 2 * NexFileHeader.NumVars;
for i = 1:NexFileHeader.NumVars,
	NexVarHeader(i).Type = fread(fid, 1, 'int32'); %0 = neuron, 1 = event, 2 = interval, 3 = waveform, 4 = pop.vector 5 = LFP, 6 = marker
	NexVarHeader(i).Version = fread(fid, 1, 'int32');
	NexVarHeader(i).Name = deblank(char(fread(fid, 64, 'char')'));
   NexVarHeader(i).DataOffset = fread(fid, 1, 'int32');
   NexVarHeader(i).Count = fread(fid, 1, 'int32');
   NexVarHeader(i).WireNumber = fread(fid, 1, 'int32');
   NexVarHeader(i).UnitNumber = fread(fid, 1, 'int32');
   NexVarHeader(i).Gain = fread(fid, 1, 'int32');
   NexVarHeader(i).Filter = fread(fid, 1, 'int32');
   NexVarHeader(i).Xpos = fread(fid, 1, 'double');
   NexVarHeader(i).Ypos = fread(fid, 1, 'double');
   NexVarHeader(i).WFrequency = fread(fid, 1, 'double');
   NexVarHeader(i).ADtoMV = fread(fid, 1, 'double');
   NexVarHeader(i).NPointsWave = fread(fid, 1, 'int32');
   if NexFileHeader.Version >= 103 & NexVarHeader(i).Type == 6,
	   NexVarHeader(i).NMarkers = fread(fid, 1, 'int32');
      NexVarHeader(i).MarkerLength = fread(fid, 1, 'int32');
      NexVarHeader(i).Padding = fread(fid, 68, 'char');
   else
   	NexVarHeader(i).Padding = fread(fid, 76, 'char');
   end
   
   if ~isempty(csw),
      create_spk_window('ProgressBar', i/totalsteps);
   end
   
end

%Read Variable Data
freq = NexFileHeader.Frequency;
for i = 1:NexFileHeader.NumVars,
   numbytes = NexVarHeader(i).Count;
   dataoffset = NexVarHeader(i).DataOffset;
   type = NexVarHeader(i).Type;
   
   fstat = fseek(fid, dataoffset, -1);
   if fstat ~= 0,
      error('***** I/O error while reading NEX file *****');
      return
   end
   
   if type == 3, %need to read more data for waveforms
      data1 = fread(fid, numbytes, 'int32')/freq;
      data2 = fread(fid, numbytes, 'int16');
      data = cat(1, data1, data2);
   elseif type == 5 & lfp == 1, %Analog Data
      if numbytes > 1,
         disp('***** Warning: Nex_read does not support multiple fragments in continuous data *****');
      else
         StartTime = fread(fid, numbytes, 'int32');
         FragIndx = fread(fid, numbytes, 'int32');
         numpoints = NexVarHeader(i).NPointsWave;
         data = fread(fid, numpoints, 'int16');
         data = data*NexVarHeader(i).ADtoMV;
      end
   elseif type == 6 & NexFileHeader.Version >= 103, %need to check for marker fields
      data = fread(fid, numbytes, 'int32')/freq;
      for ii = 1:NexVarHeader(i).NMarkers,
         tempname = fread(fid, 64, 'char');
         tempname = tempname(find(tempname));
         NexVarHeader(i).MarkerName{ii} = setstr(tempname)';
         markerlength = NexVarHeader(i).MarkerLength;
			nummarkers = NexVarHeader(i).Count;
			markerchars = fread(fid, markerlength*nummarkers, 'char');
			markervalues = str2num(deblank(char(reshape(markerchars, markerlength, nummarkers)')));
         NexVarHeader(i).MarkerValues{ii} = markervalues;
      end
   else
      data = fread(fid, numbytes, 'int32')/freq;
   end
   NexData{i} = data;
   
   if ~isempty(csw),
      create_spk_window('ProgressBar', 0.5 + i/totalsteps);
   end
end

fclose(fid);