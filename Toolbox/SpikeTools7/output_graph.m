function output_graph
% this function is called from plotprep by pressing the "output graph" button
%
% last modified 3/37/2001 --WA

PRIMAX = get(gcf, 'userdata');
all_lines = findobj(PRIMAX, 'type', 'line');
all_lines = flipud(all_lines);

count = 1;
for i = 1:length(all_lines),
   labels(i) = {get(all_lines(i), 'tag')};
   if isempty(labels(i)),
      labels(i) = {num2str(length(all_lines)-i+1)};
   end
   txd = get(all_lines(i), 'xdata');
   if length(txd) > 2,
      data(1:length(txd), count) = get(all_lines(i), 'xdata')';
      data(1:length(txd), count+1) = get(all_lines(i), 'ydata')';
      count = count + 2;
   end
end

% eliminate redundant x values
[rows cols] = size(data);
final_data(1:rows, 1) = data(:, 1);
count = 1;
for i = 2:2:cols,
   count = count + 1;
   final_data(1:rows, count) = data(:, i);
end
data = final_data;

[filename path] = uiputfile('graph_data.txt', 'Enter filename for data output');
if path==0,
   return
end

file = strcat(path, filename);

fid = fopen(file, 'w');
if fid == -1,
   error('Unable to open output file -- may be in use by another application');
   return
end

[number_of_rows number_of_columns] = size(data);

fprintf(fid, '%s\t', 'X data');
for i = 1:length(labels),
   fprintf(fid, '%s\t', labels{i});   
end
fprintf(fid, '\n');

for i=1:number_of_rows
   for j=1:number_of_columns
      fprintf(fid, '%9.3f\t', data(i,j));
   end
   fprintf(fid,'\n');
end
fclose(fid);

edit([path filename]);