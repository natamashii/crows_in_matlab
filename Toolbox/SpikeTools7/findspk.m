function result = findspk(varargin)
% SYNTAX:
%		result = findspk(filelist, fieldname, value)
%
%		or
%
%		result = findspk(fieldname, value)
%
% Works like MATLAB's "findobj" -- returns a structure with FileName and VarName fields specifying which SPK
% files or variables match the search criteria.  If "value" is a two-element vector, then they are assumed to
% be outer-bounds, and values within the range (inclusive) are considered matches.  If not "filelist" is 
% specified, all SPK files in the current data directory are assumed to be the search domain.  Multiple 
% fieldname-value pairs can be specified.  The "fieldname" must correspond to a field found in either the 
% SpikeFileHeader or a SpikeVarHeader, and it is case-sensitive, and must obey SpikeTools 7 structure conventions.
%
% For example,
%		result = findspk('K085.spk', 'Xpos', [3 5], 'Ypos', [0 Inf])
%
% will return a structure specifying which variables have x-positions which fall in the range 3 to 5 and 
% y-positions from 0 to infinity, such as
%
% 1x3 struct array with fields:
%		FileName
%		VarName
%
% result(1) = 
%
%		FileName: 'k085.spk'
%		VarName: 'Neuron 1201'
%
% See also: GETSPK, BATCH
%
% Created March, 2001  --WA

directories;
SpikeConfig = spiketools_config(0);

if length(varargin)/2 == round(length(varargin)/2),
      
   d = dir(dir_spk);
	count = 0;
	filelist = [];
	for i = 1:length(d),
	   n = lower(d(i).name);
	   ln = length(n);
	   if ln > 3 & strcmp(n(ln-3:ln), '.spk'),
	      count = count + 1;
	      filelist{count} = lower(d(i).name);
	   end
   end
   
   count = 0;
   for i = 1:2:length(varargin),
      count = count + 1;
      fieldnamelist(count) = varargin(i);
      valuelist(count) = varargin(i+1);
   end
   
else
   
   filelist = varargin{1};
   if ~iscell(filelist),
      for i = 1:size(filelist, 1),
         tempfilelist{i} = filelist(i, :);
      end
      filelist = tempfilelist;
   end
   for i = 1:length(filelist),
      fname = filelist{i};
      slash = find(fname == filesep);
      if ~isempty(slash),
         fname = fname(max(slash)+1:length(fname));
      end
      dot = find(fname == '.');
      if isempty(dot),
         fname = strcat(fname, '.spk');
      end
      filelist{i} = fname;
   end
   
   count = 0;
   for i = 2:2:length(varargin),
      count = count + 1;
      fieldnamelist(count) = varargin(i);
      valuelist(count) = varargin(i+1);
   end
   
end

varcount = count;
CoordNames = strvcat('Xpos', 'Ypos', 'Zpos', 'Apos');

count = 0;
result = [];
for filenum = 1:length(filelist),
   
   [SpikeFileHeader SpikeVarHeader] = spk_read_header(filelist{filenum});
      
   okvar = zeros(SpikeFileHeader.NumVars+1, varcount);
   
   for varlistpointer = 1:varcount,
      %count = 0;
      fieldname = fieldnamelist{varlistpointer};
      value = valuelist{varlistpointer};
      if ~isempty(strmatch(fieldname, fieldnames(SpikeFileHeader))),
         val = eval(['SpikeFileHeader.' fieldname]);
	      if ((isstr(value) | length(value) == 1) & (val == value)) | ((length(value) > 1) & (val >= value(1)) & (val <= value(2))),
            okvar(1:SpikeFileHeader.NumVars, varlistpointer) = 1;
         end
	   elseif ~isempty(strmatch(fieldname, fieldnames(SpikeVarHeader))),
         for varnum = 1:SpikeFileHeader.NumVars,
            val = eval(['SpikeVarHeader(varnum).' fieldname]);
	         if ~isempty(strmatch(fieldname, CoordNames)), %Special considerations for coordinates
	            if ((val ~= SpikeConfig.DefaultNoLocationCode) & (SpikeVarHeader(varnum).WireNumber > 0)) | ((value == SpikeConfig.DefaultNoLocationCode) & (length(value)) == 1 & (val == value)),
                  okvar(varnum, varlistpointer) = 1;
	            end
	         elseif (isstr(value) & isstr(val) & ~isempty(strmatch(value, val))) | ((length(value) == 1) & (val == value)) | (length(value) > 1 & ((val >= value(1)) & (val <= value(2)))),
               okvar(varnum, varlistpointer) = 1;
	      	end
	   	end %varnum
		end
   end %varlistpointer
   
   findok = find(sum(okvar, 2) == varlistpointer);
   if ~isempty(findok), %assign results
	   for ii = 1:length(findok),
         count = count + 1;
         result(count).FileName = filelist{filenum};
         result(count).VarName = SpikeVarHeader(findok(ii)).Name;
         result(count).VarNum = findok(ii);
      end
   end
   
end %filenum
