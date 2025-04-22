function output = getspk(s, varargin)
% SYNTAX:
%			output = getspk(s, fieldname)
%
% The argument, "s" is a structure containing the fields "FileName" and "VarName", such as is returned 
% by "findspk" and fieldname is the case-sensitive name of the field in either the SpikeFileHeader or
% a SpikeVarHeader for which values are desired.  Multiple fieldnames can be entered (separated by commas).
%
% For example:
%
% s = findspk(file_list, 'Type', 0);
% coords = getspk(s, 'Xpos', 'Ypos', 'Zpos', 'Apos');
%
% The output, "coords" in this example, will be a cell-matrix with the number of rows equal to the number 
% of neurons (as chosen by searching for variables of "Type" 0), and with four columns corresponding to the 
% four variables specified in this example.
%
% See also: FINDSPK
%
% Created March, 2001 --WA

output = [];
count = 0;
for i = 1:length(s),
   
   count = count + 1;
   if (i == 1) | ((i > 1) & isempty(strmatch(s(i-1).FileName, s(i).FileName))),
      [SpikeFileHeader SpikeVarHeader] = spk_read_header(s(i).FileName);
   end
   
   for ii = 1:length(varargin),
      fieldname = varargin{ii};
      if ~isempty(strmatch(fieldname, fieldnames(SpikeFileHeader))),
         output{count, ii} = eval(['SpikeFileHeader.' fieldname]);
      elseif ~isempty(strmatch(fieldname, fieldnames(SpikeVarHeader))),
         for varnum = 1:SpikeFileHeader.NumVars,
            if ~isempty(strmatch(s(i).VarName, SpikeVarHeader(varnum).Name)),
               output{count, ii} = eval(['SpikeVarHeader(varnum).' fieldname]);
            end
         end
      end
      
   end
   
end
