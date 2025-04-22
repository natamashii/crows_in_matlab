function compile_groupfile(textfile)
% syntax: compile_groupfile(textfile)
%
% created Spring, 1997  --WA

directories

f = find(textfile == '\');
if isempty(f),
   textfile = strcat(dir_grp, textfile);
end

fid = fopen(textfile, 'r');

if fid < 0,
   error('************ Error opening text file ************');
   return
end

count = 0;
while feof(fid) == 0,
   count = count + 1;
   textline = fgetl(fid);
   if ~isempty(textline),
      textline = parse(textline);
      groupname = deblank(textline(1, :));
      groupnames(count, 1:length(groupname)) = groupname;
      conds_in_group = str2vec(textline(2, :));
      condgrps(count, 1:length(conds_in_group)) = conds_in_group;
   end
end

dot = find(textfile == '.');
suffix = textfile(dot:length(textfile));
outfile = strrep(textfile, suffix, '_grp.mat');
save(outfile, 'groupnames', 'condgrps');
fclose(fid);
disp(['Done creating ' outfile])