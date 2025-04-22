function view_ctx
%
% created Summer, 1997  --WA

directories
filterpath = strcat(dir_ctx, '*.ctx');
[filename pathname] = uigetfile(filterpath, 'View Cortex (CTX) Image');
if pathname == 0,
   return
end

file = strcat(pathname, filename);
fid1 = fopen(file, 'r');
status = fseek(fid1, 0, 1);
eof = ftell(fid1);
status = fseek(fid1, 0, -1);
bytes = fread(fid1, eof, 'uchar');
fclose(fid1);
ysize = bytes(13);
xsize = bytes(15);
picinfo = bytes(19:eof);
picture = reshape(picinfo, ysize, xsize);
picture = picture';
lutmask = strcat(dir_lut, '*.lut');
[lutfile lutpath] = uigetfile(lutmask, 'Choose LUT file');
if lutpath == 0,
   return
end
lutfile = strcat(lutpath, lutfile);
palette = read_lut(lutfile);

figure;
set(gcf, 'tag', 'spk');
colormap(palette./255);
image(picture+1);
axis off
set(gcf, 'position', [250 400 150 150], 'NumberTitle', 'off', 'menubar', 'none', 'Name', filename)


