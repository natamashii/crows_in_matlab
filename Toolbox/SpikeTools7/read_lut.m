function palette = read_lut(file)
% Reads cortex-style LUT file
%
% created Summer, 1997  --WA

fid = fopen(file, 'r');
if fid < 0,
   error('******* Error opening LUT file *********');
   return
end
fseek(fid, 0, 1);
file_length = ftell(fid);
if file_length/8 ~= round(file_length/8),
   error('******* File length incompatable with expected LUT file data *********');
   return
end
lutsize = file_length/2;
fseek(fid, 0, -1);
lut = fread(fid, lutsize, 'uint16');
fclose(fid);

palette = zeros(lutsize/4, 3);
palette(:, 1) = lut(1:4:lutsize);
palette(:, 2) = lut(2:4:lutsize);
palette(:, 3) = lut(3:4:lutsize);

