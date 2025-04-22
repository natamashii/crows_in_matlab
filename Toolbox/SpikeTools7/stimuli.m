function stimuli
% This is a GUI for viewing and converting bmp and ctx images.  It requires Matlab
% version 5.2 or later and the image processing toolbox.  This routine can also be
% called from the SPK main menu under the "stimuli" pull-down option.
%
% created 7/8/98  --WA, and 32bit CTX routine by GR

directories

if isempty(gcbo),
   fork = 1;
else
   fork = str2num(get(gcbo, 'tag'));
   if isempty(fork), %non-numeric, as if called by spkmenu
      fork = 1;
   end
end

if fork == 1,
   f = findobj('name', 'Stimuli');
   if isempty(f),
      figure
   else
      figure(f);
      return;
   end
   
   h = zeros(50, 1);
   set(gcf, 'position', [200 200 350 280], 'numbertitle', 'off', 'menubar', 'none', 'resize', 'off');
   set(gcf, 'tag', 'spk', 'name', 'Stimuli');
   
   bmp_ph = imread('bmp_ph.bmp', 'bmp');
   ctx_ph = imread('ctx_ph.bmp', 'bmp');
   
   h(1) = uicontrol('style', 'frame', 'position', [15 15 320 80]);
   h(2) = uicontrol('style', 'pushbutton', 'position', [15 130 140 140], 'cdata', bmp_ph, 'tag', '2', 'callback', 'stimuli', 'tooltipstring', 'click to load new bitmap image');
   h(3) = uicontrol('style', 'pushbutton', 'position', [195 130 140 140], 'cdata', ctx_ph, 'tag', '3', 'callback', 'stimuli', 'tooltipstring', 'click to load new ctx image');
   h(4) = uicontrol('style', 'pushbutton', 'position', [158 205 34 30], 'string', '>>', 'fontsize', 14, 'tag', '4', 'callback', 'stimuli', 'enable', 'off');
   h(5) = uicontrol('style', 'pushbutton', 'position', [15 103 140 20], 'tag', '5', 'enable', 'off', 'string', '?.bmp', 'callback', 'stimuli');
   h(6) = uicontrol('style', 'pushbutton', 'position', [195 103 140 20], 'tag', '6', 'enable', 'off', 'string', '?.ctx', 'callback', 'stimuli');
   
   t1 = uicontrol('style', 'text', 'position', [280 20 40 25], 'string', 'Bits', 'fontsize', 10);
   h(7) = uicontrol('style', 'popupmenu', 'position', [240 25 45 20], 'string', strvcat('8', '24'), 'value', 2, 'callback', 'stimuli', 'tag', '7', 'enable', 'off');
   h(8) = uicontrol('style', 'pushbutton', 'position', [205 50 120 20], 'string', 'winsys.lut', 'enable', 'off', 'tag', '8', 'callback', 'stimuli');
   t2 = uicontrol('style', 'text', 'position', [200 70 130 20], 'string', 'CTX Look-Up Table:');
   h(9) = uicontrol('style', 'pushbutton', 'position', [158 155 34 30], 'string', '<<', 'fontsize', 14, 'tag', '9', 'callback', 'stimuli', 'enable', 'off');
   t3 = uicontrol('style', 'frame', 'position', [31 24 109 20]);
   t4 = uicontrol('style', 'text', 'position', [32 25 107 17], 'string', '24 bits per pixel', 'tag', 'bmpbpp', 'enable', 'off');
   t5 = uicontrol('style', 'frame', 'position', [174 20 3 70]);
   dcb = 'h = findobj(gcf, ''tag'', ''11''); v = get(gcbo, ''value'');switch(v),case 0, set(h, ''string'', ''Dither OFF''); case 1, set(h, ''string'', ''Dither ON''); end;';
   h(10) = uicontrol('style', 'radiobutton', 'position', [50 70 23 23], 'tag', '10', 'callback', dcb);
   dcb = 'h = findobj(gcf, ''tag'', ''10''); v = get(h, ''value'');switch(v),case 0, set(gcbo, ''string'', ''Dither ON''); set(h, ''value'', 1); case 1, set(gcbo, ''string'', ''Dither OFF''); set(h, ''value'', 0); end;';
   h(11) = uicontrol('style', 'text', 'position', [70 70 80 20], 'string', 'Dither OFF', 'tag', '11', 'horizontalalignment', 'left', 'callback', dcb);
   h(12) = uicontrol('style', 'pushbutton', 'position', [20 50 135 20], 'string', 'Save BMP Look-Up Table', 'tag', '12', 'enable', 'off', 'callback', 'stimuli');
   
elseif fork == 2, %bmp button
   
   [imfile pathname] = uigetfile([dir_bmp '*.bmp'], 'Select bitmap file');
   if pathname == 0,
      return
   end
   
   bppwin = findobj(gcf, 'tag', 'bmpbpp');
   set(bppwin, 'enable', 'on');
   lab_but = findobj(gcf, 'tag', '5');
   cnv_but = findobj(gcf, 'tag', '4');
   
   set(findobj(gcf, 'tag', '7'), 'enable', 'on');
   set(lab_but, 'string', imfile, 'enable', 'on');
   set(cnv_but, 'enable', 'on');
   
   [im map] = imread([pathname imfile], 'bmp');
   if ~isempty(map),
      set(findobj(gcf, 'tag', '12'), 'enable', 'on');
      map = round(map.*255);
   else
      set(findobj(gcf, 'tag', '12'), 'enable', 'off');
   end
   
   picture_data = struct('name', imfile, 'image', im, 'lut', map);
   set(gcbo, 'userdata', picture_data);
   if ~isempty(map),
      showim = ind2rgb(im, map./255);
      set(bppwin, 'string', '8 bits per pixel');
   else
      showim = im;
      set(bppwin, 'string', '24 bits per pixel');
   end
   set(gcbo, 'cdata', showim);   
     
elseif fork == 3, %ctx button
   
   [imfile pathname] = uigetfile([dir_ctx '*.ctx'], 'View Cortex (CTX) Image');
   if pathname == 0,
      return
   end
   
   file = strcat(pathname, imfile);
   fid1 = fopen(file, 'r');
   status = fseek(fid1, 0, 1);
   eof = ftell(fid1);
   status = fseek(fid1, 0, -1);
   bytes = fread(fid1, eof, 'uchar');
   fclose(fid1);
   
   bpp = bytes(11);
   ysize = bytes(13);
   xsize = bytes(15);
   picinfo = bytes(19:eof);
   if bpp < 24,
      im = reshape(picinfo, ysize, xsize)';
      lutbut = findobj('tag', '8');
      stat = get(lutbut, 'enable');
      if stat(2) == 'f',
         [lutfile lutpath] = uigetfile([dir_lut '*.lut'], 'Choose LUT file');
         if lutpath == 0, return; end
         map = read_lut([lutpath lutfile]);
         set(lutbut, 'string', lutfile, 'enable', 'on');
      else
         %use chosen look-up-table
         lutfile = get(lutbut, 'string');
         map = read_lut([dir_lut lutfile]);
      end
   else %32 bit data
      red_im = rot90(reshape(picinfo(2:4:length(picinfo)), ysize, xsize), 3);
      green_im = rot90(reshape(picinfo(3:4:length(picinfo)), ysize, xsize), 3);
      blue_im = rot90(reshape(picinfo(4:4:length(picinfo)), ysize, xsize), 3);
      im = cat(3, red_im, green_im, blue_im);
      map = [];
   end
   
   bppsel = findobj('tag', '7');
   if bpp >=24,
      set(bppsel, 'value', 2);
      set(findobj('tag', '8'), 'enable', 'off');
   else
      set(bppsel, 'value', 1);
   end
   
   set(findobj(gcf, 'tag', '7'), 'enable', 'on');
   lab_but = findobj(gcf, 'tag', '6');
   set(lab_but, 'string', imfile, 'enable', 'on');
   
   picture_data = struct('name', imfile, 'image', im, 'lut', map, 'bpp', bpp);
   set(gcbo, 'userdata', picture_data);
   if ndims(im) < 3,
      showim = ind2rgb(im, map./255);
   else
      showim = im./255;
   end
   
   set(gcbo, 'cdata', showim);
   set(findobj(gcf, 'tag', '9'), 'enable', 'on');
   
elseif fork == 4, %convert bmp2ctx
   
   bmpbut = findobj(gcf, 'tag', '2');
   if isempty(get(bmpbut, 'userdata')),
      return
   end
   
   ctxbut = findobj(gcf, 'tag', '3');
   bmplab = findobj(gcf, 'tag', '5');
   ctxlab = findobj(gcf, 'tag', '6');
   
   picture_data = get(bmpbut, 'userdata');
   imfile = picture_data.name;
   imfile = strrep(lower(imfile), '.bmp', '.ctx');
   picture_data.name = imfile;
   im = picture_data.image;
   map = picture_data.lut;
   
   dval = get(findobj('tag', '10'), 'value');
   switch dval,
   case 0
      dithertext = 'nodither';
   case 1
      dithertext = 'dither';
   end
   
   bppval = get(findobj(gcf, 'tag', '7'), 'value');
   
   if isempty(map) & bppval == 1, %24 bit bmp -> 8 bit ctx
      lutfile = get(findobj(gcf, 'tag', '8'), 'string');
      map = read_lut([dir_lut lutfile]);
      im = rgb2ind(im, map./255, dithertext);
      showim = ind2rgb(im, map./255);
   elseif isempty(map) & bppval == 2, %24 bit bmp -> 24 bit ctx
      map = [];
      showim = im;
   elseif ~isempty(map) & bppval == 1, %8 bit bmp -> 8 bit ctx,
      lutfile = get(findobj(gcf, 'tag', '8'), 'string');
      newmap = read_lut([dir_lut lutfile]);
      im = imapprox(im, map./255, newmap./255, dithertext);
      map = newmap;
      showim = ind2rgb(im, map./255);
   elseif ~isempty(map) & bppval == 2, %8 bit bmp -> 24 bit ctx,
      im = ind2rgb(im, map./255);
      showim = im;
      map = [];
   end
       
   picture_data.image = im;
   picture_data.lut = map;
   
   set(ctxbut, 'userdata', picture_data);
   set(ctxbut, 'cdata', showim);
   set(ctxlab, 'string', imfile, 'enable', 'on');
   set(findobj(gcf, 'tag', '9'), 'enable', 'on');
   
elseif fork == 5, %save bmp
   
   bmpbut = findobj(gcf, 'tag', '2');
   picture_data = get(bmpbut, 'userdata');
   wfile = picture_data.name;
   im = picture_data.image;
   map = picture_data.lut;
   
   [filename pathname] =  uiputfile([dir_bmp wfile], 'Save BMP file:');
   if pathname == 0, return; end;
   set(findobj('tag', '5'), 'string', filename);
   wfile = strcat(pathname, filename);
   if isempty(map), %24 bit image
      imwrite(im, wfile, 'bmp');
   else
      imwrite(im, map./255, wfile, 'bmp');
   end
   
   disp('Created:')
   disp(wfile)
   
elseif fork == 6, %save ctx
   
   ctxbut = findobj(gcf, 'tag', '3');
   picture_data = get(ctxbut, 'userdata');
   if isempty(picture_data), return; end;
 
   im = picture_data.image;
   wfile = strcat(dir_ctx, picture_data.name);
   map = picture_data.lut;
   
   [filename pathname] = uiputfile(wfile, 'Save CTX file:');
   if pathname == 0,
      return;
   end
   wfile = strcat(pathname, filename);
   set(findobj('tag', '6'), 'string', filename);
     
   if ndims(im) == 3,
      bpp = 32;
      %begin write32bitctx:
      rgb(:,:,1)=(im(:,:,1))';
      rgb(:,:,2)=(im(:,:,2))';
      rgb(:,:,3)=(im(:,:,3))';
      
      x_size=size(rgb,1);
      y_size=size(rgb,2);
      
      picture=zeros(x_size,y_size,4);
      picture(1:x_size,1:y_size,2:4)=rgb;
      
      temp=reshape(picture,1,prod(size(picture)));
      temp=reshape(temp,x_size*y_size,4);
      im=reshape(temp',prod(size(picture)),1);
   else
      bpp = 8;
      [y_size x_size] = size(im);
      im = shiftdim(im, 1);
      im = reshape(im, 1, (y_size * x_size));
   end
   
	ctx_length = length(picture_data) + 18;
	ctx_image = zeros(1, ctx_length);
	ctx_image(11) = bpp; % bpp
	ctx_image(13) = x_size; % width
	ctx_image(15) = y_size; % height
	ctx_image(17) = 1; % #frames
   ctx_image(19:18+length(im)) = im;
   fid1 = fopen(wfile, 'w');
	fwrite(fid1, ctx_image, 'uint8');
	fclose(fid1);
   
   disp('Created:')
   disp(wfile)
   
elseif fork == 7, % bit-depth
   
   ctxbut = findobj('tag', '3');
   picture_data = get(ctxbut, 'userdata');
   
   if isempty(picture_data), 
      if get(gcbo, 'value') == 1,
         set(findobj('tag', '8'), 'enable', 'on');
      end
      return
   end

   im = picture_data.image;
   map = picture_data.lut;
   
   dval = get(findobj('tag', '10'), 'value');
   switch dval,
   case 0
      dithertext = 'nodither';
   case 1
      dithertext = 'dither';
   end
   
   if get(gcbo, 'value') == 1, %set to 8 bit
      set(findobj(gcf, 'tag', '8'), 'enable', 'on');
      if ~isempty(map),
         return
      end
      lutfile = get(findobj('tag', '8'), 'string');
      map = read_lut([dir_lut lutfile]);
      im = rgb2ind(im, map./255, dithertext);
      picture_data.image = im;
      picture_data.lut = map;
      showim = ind2rgb(im, map./255);
      
   else % set to 24 (really 32) bit
      set(findobj(gcf, 'tag', '8'), 'enable', 'off');
      if isempty(map),
         return
      end
      im = ind2rgb(im, map./255);
      picture_data.image = im;
      picture_data.lut = [];
      showim = im;
   end
   set(ctxbut, 'userdata', picture_data);
   set(ctxbut, 'cdata', showim);
   
elseif fork == 8, % choose look-up-table
   
   [lutfile pathname] = uigetfile([dir_lut '*.lut'], 'Choose Look-Up Table:');
   if pathname == 0,
      return
   end
   
   map = read_lut([dir_lut lutfile]);
   ctxbut = findobj('tag', '3');
   picture_data = get(ctxbut, 'userdata');
   im = get(ctxbut, 'cdata');
   im = rgb2ind(im, map./255);
   picture_data.lut = map;
   picture_data.image = im;
   set(ctxbut, 'cdata', ind2rgb(im, map./255));
   set(ctxbut,  'userdata', picture_data);
   set(gcbo, 'string', lutfile);
      
elseif fork == 9, % ctx2bmp
   
   ctxbut = findobj(gcf, 'tag', '3');
   if isempty(get(ctxbut, 'userdata')),
      return
   end
   
   bmpbut = findobj(gcf, 'tag', '2');
   bmplab = findobj(gcf, 'tag', '5');
   ctxlab = findobj(gcf, 'tag', '6');
   
   picture_data = get(ctxbut, 'userdata');
   imfile = picture_data.name;
   imfile = strrep(lower(imfile), '.ctx', '.bmp');
   im = picture_data.image;
   map = picture_data.lut;
   
   bmpbpp = findobj('tag', 'bmpbpp');
   if isempty(map),
      set(bmpbpp, 'string', '24 bits per pixel');
   else
      set(bmpbpp, 'string', '8 bits per pixel');
      set(findobj('tag', '12'), 'enable', 'on');
   end;
   
   picture_data.name = imfile;
   picture_data.image = im;
   picture_data.lut = map;
   
   set(bmpbut, 'userdata', picture_data);
   set(bmpbut, 'cdata', get(ctxbut, 'cdata'));
   set(bmplab, 'string', imfile, 'enable', 'on');
   
elseif fork == 12 % save bitmap LUT
      
   bmpbut = findobj(gcf, 'tag', '2');
   picture_data = get(bmpbut, 'userdata');
   map = picture_data.lut;
   lutfile = strrep(lower(picture_data.name), '.bmp', '.lut');
   
   [lutfile lutpath] = uiputfile([dir_lut lutfile], 'Save Look-Up Table:');
   if lutpath == 0, return; end;

   write_lut([lutpath lutfile], map);
   
end

   