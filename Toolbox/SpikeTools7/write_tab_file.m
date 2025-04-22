function write_tab_file(m, filename, varargin)
%writes a cell matrix into a tab-delimited text file.  Numbers must be integers.


fid = fopen(filename, 'w');

[rows cols] = size(m);

if ~isempty(varargin),
   for i = 1:size(varargin),
      fprintf(fid, '%s\r\n', varargin{i});
   end
end

for i = 1:rows,
   for j = 1:cols,
      clear fmt
      element = m{i, j};
      if isstr(element),
         if j == 1,
            fmt = '%s';
         else
            fmt = '\t%s';
         end
      else
         if j == 1,
            fmt = '%i';
         else
            fmt = '\t%i';
         end
      end
      fprintf(fid, fmt, element);
   end
   fprintf(fid, '\r\n');
end

fclose(fid);      
