function bmp2ctx
% Bitmap (BMP) to Cortex (CTX) file conversion utility

directories
names = dir (fullfile (dir_bmp, '*.bmp'));   
cellnames = {names.name};

% sort cellnames
c = cellnames';
c = strvcat(c{:});
c = sortrows(c);
cellnames = num2cell(c,2);
clear c

[selection, ok] = listdlg('name', 'BMP >> CTX', 'PromptString', 'Select file(s) to convert','SelectionMode', 'multiple','ListString', cellnames);
if ok == 0, return; end

files_selected = {cellnames{selection}};
[nrows ncols] = size(files_selected);

for i=1:ncols,
   files_selected{i}= deblank([dir_bmp files_selected{i}]);
end

for ii = 1:ncols,
   file = files_selected{ii};
   slash = max(find(file == '\'));
   filename = file(slash+1:length(file));   
   disp(filename);
   
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
   status = fseek(fid1, bmp_offset, -1);
   
   image_size = image_width*image_height;
   picture_data = fread(fid1, image_size, 'char');
   picture = reshape(picture_data, image_width, image_height);
   picture = picture';
   picture = flipud(picture);
   real_width = image_width - padding;
   picture = picture(:, 1:real_width);
   picture_data = fliplr(picture);
   picture_data = rot90(picture_data);
   image_size = real_width*image_height;
   picture_data = reshape(picture_data, 1, image_size);
   
   picarray = reshape(picture, image_size, 1);
   maxlum = image_size * 256 * 3;
   lumsum = 0;
   for i = 1:image_size,
      lumsum = lumsum + sum(palette(picarray(i)+1, :));
   end
   luminance = lumsum / maxlum;
   msg = 'relative luminance is ';
   lum = int2str(luminance*100);
   ll = length(lum);
   msg(23:23+ll-1) = lum;
   msg(23+ll) = '%';
   
   fclose(fid1);
   
   %%%%%%% Write CTX file

   wfilename = strrep(filename, '.bmp', '.ctx');
   wfile = strcat(dir_ctx, wfilename);
   fid2 = fopen(wfile, 'w');
   ctx_length = length(picture_data) + 18;
   ctx_image = zeros(1, ctx_length);
   ctx_image(13) = real_width;
   ctx_image(15) = image_height;
   ctx_image(19:ctx_length) = picture_data+ones(size(picture_data)).*128; % used to be +picture_data; changed 28.3.1998 
   fwrite(fid2, ctx_image, 'uint8');
   fclose(fid2);
   
   figure(freefig);
   set(gcf, 'tag', 'spk');
   colormap(palette./255);
   image(picture+1);
   axis off
   set(gcf, 'position', [250 400 150 150], 'NumberTitle', 'off', 'menubar', 'none', 'Name', wfilename)
   
   cmsg = 'converted to ';
   cmsg(14:14+length(wfile)-1) = wfile;
   disp(cmsg)
   disp(msg)
   disp(' ')
   
end
