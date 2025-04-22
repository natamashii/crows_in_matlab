function view_bmp
%
% created Summer, 1997  --WA

directories
filterpath = strcat(dir_bmp, '*.bmp');
[filename, pathname] = uigetfile(filterpath, 'View Bitmap (BMP) Image');

if pathname == 0,
   return
end

file = strcat(pathname, filename);
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

%bmp_offset = bmp_offset + image_width + 2;
status = fseek(fid1, bmp_offset, -1);
%status = fseek(fid1, 1074, -1);

image_size = image_width*image_height;
picture_data = fread(fid1, image_size, 'char');
picture = reshape(picture_data, image_width, image_height);
picture = picture';
picture = flipud(picture);
real_width = image_width - padding;
picture = picture(:, 1:real_width);

   figure(freefig);
   set(gcf, 'tag', 'spk');
   colormap(palette./255);
   image(picture+1);
   axis off
   set(gcf, 'position', [100 100 150 150], 'NumberTitle', 'off', 'menubar', 'none', 'Name', filename);
   fclose(fid1);

