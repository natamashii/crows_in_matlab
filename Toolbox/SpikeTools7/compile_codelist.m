function compile_codelist
% syntax:
% compile_codelist
% codefile must be called codes.txt and stored in the spk files 
% directory and is of the format described in list_codes
%
% created Spring, 1997  --WA

spkglobs
directories

code_file = strcat(dir_spk, 'codes.txt');
fid = fopen(code_file, 'r');
if fid < 0,
   disp('Error opening codes.txt file')
   return
end

header = fgetl(fid);

code_descrip = [];
count = 0;
while feof(fid) == 0,
   textline = fgetl(fid);
   if length(textline) > 1;
      count = count + 1;
      textline = parse(textline);
      code_number(count) = str2num(textline(1, :));
      code_descrip = strvcat(code_descrip, textline(2, :));
   end
end

spk_tools_dir = which('spk');
f = find(spk_tools_dir == '\');
spk_tools_dir = spk_tools_dir(1:f(length(f)));
savefile = strcat(spk_tools_dir, 'codes.mat');
var1 = 'code_number';
var2 = 'code_descrip';
save(savefile, var1, var2);

disp('Done creating codes.mat')