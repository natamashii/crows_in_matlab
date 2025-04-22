function [SpikeFileHeader, SpikeVarHeader] = spk_read_header(file)
%	SYNTAX
%			[SpikeFileHeader SpikeVarHeader] = spk_read_header(file)
%
%	This function simply reads the file and variable headers in an SPK file.  It does not
%	read any data blocks, and will not extract a "SpikeInfo" structure from these headers
%	as does "spk_read."  It is therefore much quicker, but limited in use.
%
%	See also: SPK_READ
%
%	Created March, 2001  --WA

directories;
dot = find(file == '.');
if isempty(dot),
   file = strcat(file, '.spk');
end
slash = find(file == filesep);
if isempty(slash),
   file = strcat(dir_spk, file);
end

fid = fopen(file, 'r');
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
fclose(fid);
   