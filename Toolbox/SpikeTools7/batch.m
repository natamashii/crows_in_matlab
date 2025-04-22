function output = batch(f_name, inputlist, varargin)
% SYNTAX:
%			output = batch(function_name, input_list, optional_argument)
%
% This function allows you to pass, through "input_list", a list of SPK files (directly in the form of 
% a vertically concatenated string array, as a cell array, or as a structure containing the field, "FileName", 
% or indirectly by specifying a text file which lists the data files, one per row), or a list of particular 
% signals (i.e., neurons or LFPs) by specifying either a text file in which the signal IDs (e.g., 1201) are 
% listed, tab-delimitted, on the same row as the parent file, or by passing a structure such as is returned 
% by "findspk."
%
% "function_name" is the function to which the signal IDs will be passed, and should be defined in its first
% line as:
%
% function output = f_name(signal_id)
%
% Your function will not need to call "spk_read" on each iteration, as this will be handled by "batch."  For
% instance, if you have a function called "analysis2" defined as:
%
% function result = analysis2(neuron_ID)
%
% and you want to pass it all the neurons in the datafiles K079.spk and K085.spk, you would enter:
%
% input_list = strvcat('k079', 'k085'); %or this can be a cell-array, or a structure, such as from "findspk"
% output = batch('analysis2', 'input_list');
%
% The returned output will be a cell matrix in which each row corresponds to an input iteration (here, each 
% row is a single neuron), and each column corresponds to an output of your function (if your function returns
% multiple outputs).
%
% The"optional_argument" can be either the string 'file', if your function expects to receive file names instead
% of individual neurons (in which case, spk_read will not be called by batch, and will need to be called by 
% your own function, if needed).  Or this optional third argument can be the string "lfp" to indicate that 
% LFPs (e.g., 1100) should be passed instead of neurons (This is if the input_list specifies only file names; if
% particular variables are specified, this option is over-ridden).
%
% See also: FINDSPK
%
% SpikeTools 7 Version, March, 2001 --WA

directories;
sigtype = 0;
fileflag = 0;
output = {};
numoutputs = nargout(f_name);

if numoutputs > 0,
   outstring = sprintf('output{i, %i} ', 1:numoutputs);
   totevalstring = sprintf('[%s] = eval(evalstr);', outstring);
else
   totevalstring = 'eval(evalstr)';
end

if ~isempty(varargin),
	if strmatch('file', varargin),
	   fileflag = 1;
   end
   if strmatch('lfp', varargin),
      sigtype = 5;
   end
end

if ~isstruct(inputlist),
   if ~iscell(inputlist), %convert to cell
      for i = 1:size(inputlist, 1),
         tempinputlist{i} = inputlist(i, :);
      end
      inputlist = tempinputlist;
   end
   
   n = inputlist{1};
   if isempty(find(n == filesep)),
      n = strcat(dir_spk, n);
   end
   if isempty(findstr('.spk', lower(n))) & (~isempty(find(n == '.')) | (exist(strcat(n, '.spk')) ~= 2)), %assume a text file
      count = 0;
      for i = 1:length(inputlist),
         n = inputlist{i};
         if isempty(find(n == '.')),
            n = strcat(n, '.txt');
         end
         if isempty(find(n == filesep)),
            n = strcat(dir_spk, n);
         end
         fid = fopen(n, 'r');
         while ~feof(fid),
            listline = fgetl(fid);
            elements = parse(listline);
            if size(elements, 1) > 1,
               for ii = 2:size(elements, 1),
                  count = count + 1;
                  n = elements(1, :);
                  if isempty(find(n == '.')),
                     n = strcat(n, '.spk');
                  end
                  rtot(count).FileName = n;
                  n = elements(ii, :);
                  if isempty(strmatch('Neuron', n)),
                     n = sprintf('Neuron %i', str2num(n));
                  end
                  rtot(count).VarName = n;
               end
            else
               r = findspk(elements(1, :), 'Type', sigtype);
               r = rmfield(r, 'VarNum');
               rtot(count+1:count+length(r)) = r;
               count = length(rtot);
            end
         end
         fclose(fid);
      end
      inputlist = rtot;
   else % assume spk files
      inputlist = findspk(inputlist, 'Type', sigtype);
   end
   
else %if it's an externally-provided structure, make certain it contains FileName (and VarName?) as fields
   
   if ~isfield(inputlist, 'FileName')
      error('***** Error: input structure must contain the field "FileName" *****');
      return
   end
   
   if ~isfield(inputlist, 'VarName'), %get variable names
      for i = 1:length(inputlist),
         n{i} = inputlist(i).FileName;
      end
      inputlist = findspk(n, 'Type', sigtype)
   end
   
end

oldfile = [];
for i = 1:length(inputlist),
   
   if fileflag,
      
      filename = inputlist(i).FileName;
      disp(sprintf('%s', filename))
      evalstr = sprintf('%s(''%s'')', f_name, filename);
      eval(totevalstring);
      
   else
      
   	newfile = inputlist(i).FileName;
   	if (i == 1) | isempty(strmatch(newfile, oldfile)),
   	   disp(sprintf('Reading %s...', newfile))
   	   [SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spk_read(newfile);
   	   oldfile = newfile;
   	end
   
   	n = inputlist(i).VarName;
   	sig_id = str2num(n(length(n)-3:length(n)));
   	disp(sprintf('\t%i', sig_id))
      evalstr = sprintf('%s(%i)', f_name, sig_id);
      eval(totevalstring);   
   end
   
end

disp('Done')