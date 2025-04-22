function output = read_tab_file(filename, varargin)
%SYNTAX:
%		   output = read_tab_file(filename, skip_lines)
%
%Reads a tab-delimited file, ignoring blank lines.  The variable input
%argument, "skip_lines" determines how many "header" lines at the beginning
%of the file will be ignored.  The output will be in the form of a cell matrix.
%
%created 3/30/99  --WA

if ~isempty(varargin),
   skiplines = varargin{:};
else
   skiplines = 0;
end

fid = fopen(filename, 'r');

for i = 1:skiplines,
   txt = fgetl(fid);
end

count = 0;
while ~feof(fid),
   txt = fgetl(fid);
   if ~isempty(find(txt ~= ' ')),
	   count = count + 1;
	   ptxt = parse(txt);
	   for i = 1:size(ptxt, 1),
	      element = str2num(ptxt(i, :));
	      if isempty(element),
	         element = ptxt(i, :);
	      end
	      output{count, i} = element;
	   end
	end
end

fclose(fid);