function [items, item_names, header] = itm2mat2(item_file)

directories
if isempty(find(item_file == '\')),
   item_file = strcat(dir_cortex, item_file);
end

fid = fopen(item_file, 'r');

header = fgetl(fid);
numfields = size(parse(header, 'space'), 1);
isch = (header ~= ' ');
isch(length(isch) + 1) = 0;

while isch(1) == 0,
   isch = isch(2:length(isch));
end

linecounter = 0;
while ~feof(fid),
   itmline = fgetl(fid);
   if length(itmline) < length(isch)-1,
      itmline(length(itmline)+1:length(isch)) = ' ';
   end
   pmin = 1;
   linecounter = linecounter + 1;
   for f = 1:numfields,
      pmax = pmin + min(find(isch((pmin+1):length(isch)) == 0)) - 1;
      i = itmline(pmin:pmax);
      if (f == numfields),
         %must be item name
         item_names(linecounter, 1:(pmax-pmin+1)) = i;
      end
      if any(i ~= ' '),
         i = str2num(i);
         if isempty(i),
            i = -999;
         end
         if length(i) > 1,
            error('****** This routine cannot yet handle multiple items per TEST screen... ******');
            return
         end
      else
         i = -999;
      end
      items(linecounter, f) = i;
      pmin = pmax + min(find(isch(pmax+1:length(isch)) == 1));
   end
end

item_names = deblank(char(item_names));

fclose(fid);   