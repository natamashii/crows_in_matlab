function write_lut(filename, palette)
% SYNTAX: write_lut(filename, palette)
% where palette is an 256 x 3 or 128 x 3 look-up-table matrix 
% in which each row is an entry with Red, Green, and Blue 
% pixel luminance values (0 - 255).
%
% Created Summer, 1997  --WA, last modified 3/25/98 by GR

[rows cols] = size(palette);
if (rows ~= 256 & rows~=128) | cols ~= 3,
   error('********** palette is not 256 x 3 or 128 x 3 ************');
   return
end

if rows == 128,
   p = zeros(256, 3);
   p(129:256, 1:3) = palette; % load at 128! (used to be 1:128) changed by Gregor 25.3.1998
   palette = p;
end

lut = zeros(1024, 1);
lut(1:4:1024) = palette(1:256, 1);
lut(2:4:1024) = palette(1:256, 2);
lut(3:4:1024) = palette(1:256, 3);

fid = fopen(filename, 'w');
if fid < 0,
   error('********** Error opening LUT write file **********');
   return
end

fwrite(fid, lut, 'uint16');
fclose(fid);

disp(strcat('Created ->', filename))
