function extract_lut
% Extracts the color look-up-table from a bitmap file for use in Cortex as a LUT file.
%
% created Fall, 1997  -WA

directories
[filename pathname] = uigetfile(strcat(dir_bmp, '*.bmp'), 'Extract LUT from which BMP file?');
if pathname == 0,
   return
end

file = strcat(pathname, filename);
%%%% Read BMP file:
fid1 = fopen(file, 'r');
status = fseek(fid1, 0, -1);
% first 14 bytes are file header
file_type = fread(fid1, 1, 'ushort');
file_size = fread(fid1, 1, 'ulong');
reserved = fread(fid1, 2, 'ushort');
bmp_offset = fread(fid1, 1, 'ulong');
% bmp_offset is starting position of image data in bytes

% next 40 bytes are bitmap header
bmp_header_size = fread(fid1, 1, 'ulong');
image_width = fread(fid1, 1, 'long'); % in pixels
padding = 4-rem(image_width, 4);
if padding == 4,
   padding = 0;
end

image_width = image_width + padding;
image_height = fread(fid1, 1, 'long'); % in pixels
color_planes = fread(fid1, 1, 'ushort'); % always 1 for MS BMP
bpp = fread(fid1, 1, 'ushort'); % bits per pixel
compression = fread(fid1, 1, 'long');
junk = fread(fid1, 20, 'uchar');

% next comes the color palette
palette = zeros(256, 3);
for i = 1:256,
   colors = fread(fid1, 4, 'uchar');   
   palette(i, 1:3) = colors(1:3)';
end
palette = fliplr(palette);
matpal = palette./256;
fclose(fid1);

lutfile = strrep(filename, '.bmp', '.lut');
lutfile = strrep(filename, '.BMP', '.lut');
[lutfile pathname] = uiputfile(strcat(dir_lut, lutfile), 'Save LUT as...');
if pathname == 0,
   return
end

write_lut(strcat(pathname, lutfile), palette);
