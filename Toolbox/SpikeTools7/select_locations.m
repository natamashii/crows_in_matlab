function select_locations(varargin)
% Routine to view and select cells topographically, v3.0
%
% Note that coordinates containing fractions will be rounded to the nearest whole number for
% plotting and selecting.
%
% v1.0 December, 1998; v2.0 February, 2000
% SpikeTools 7 Version (v3.0), March, 2001  --WA

directories;
SpikeConfig = spiketools_config(0);

%set range for plotting:
mx = 20;
my = mx;
halfway = round(mx/2);
selcolor = [1 .2 .2];
regcolor = [1 1 1];

if isempty(varargin),
   sigtype = 0;
   sigstr = 'cell';
else
   sigtype = varargin{1};
   sigstr = 'LFP';
end

newfigure = 1;
if ~isempty(findobj('type', 'figure')) & ismember(gcbo, get(gcf, 'children')),
   posdata = get(gcf, 'userdata');
   allpoints = posdata.allpoints;
   selectedpoints = posdata.selectedpoints;
   fighandles = posdata.fighandles;
   h = posdata.h;
   file_ref_mat = {posdata.file_ref_mat};
   cell_ref_mat = {posdata.cell_ref_mat};
   gridlines = posdata.gridlines;
   sigstr = posdata.sigstr;
   newfigure = 0;
end

if newfigure,
	% Get files from which to retrieve locations
	pen_list = [];
	names = dir(fullfile (dir_spk, '*.spk'));   
	cellnames = {names.name};

	% sort cellnames
	c = cellnames';
	c = strvcat(c{:});
	c = sortrows(lower(c));
	cellnames = num2cell(c,2);
	clear c

	[selection, ok] = listdlg('name', 'Plot Locations...', 'PromptString', 'Select file(s) to include','SelectionMode', 'multiple','ListString', cellnames);
	if ok == 0,   return; end
	   
   files_selected = cellnames(selection);
   r = findspk(files_selected, 'Type', sigtype);
   coords = getspk(r, 'Xpos', 'Ypos', 'Apos', 'Zpos');
   [rows cols] = size(coords);
	coords = round(reshape(cat(1, coords{:}), rows, cols));
   coords(find(coords == SpikeConfig.DefaultNoLocationCode)) = NaN;
      
   countmat = zeros(mx, my);
   file_ref_mat = cell(mx, my);
   cell_ref_mat = cell(mx, my);
	for i = 1:size(coords, 1),
	   xloc = coords(i, 1)+halfway;
      yloc = coords(i, 2)+halfway;
      if ~isnan(xloc) & ~isnan(yloc),
	      countmat(xloc, yloc) = countmat(xloc, yloc) + 1;
	      file_ref_mat{xloc, yloc, countmat(xloc, yloc)} = r(i).FileName;
         cell_ref_mat{xloc, yloc, countmat(xloc, yloc)} = r(i).VarName;
      end
	end
	
	[xx yy] = find(countmat);
	nn = countmat(find(countmat));
   xx = xx-halfway;
   yy = yy-halfway;
   file_ref_mat = {file_ref_mat};
   cell_ref_mat = {cell_ref_mat};
   
   figure
   set(gcf, 'position', [100   100   650   480], 'color', [.6 .6 .6], 'numbertitle', 'off', 'name', 'Recording Locations');
   fighandles(1) = gca;
   axis equal;
   set(gca, 'color', [0 0 0], 'xlim', [-halfway halfway], 'ylim', [-halfway halfway]);
   lv = (.5-halfway):(halfway-.5);
   for i = 1:length(lv),
      hline(i) = line([-halfway halfway], [lv(i) lv(i)]);
      vline(i) = line([lv(i) lv(i)], [-halfway halfway]);
   end
   gridlines = cat(2, hline, vline);
   set(gridlines, 'color', [0 0 0], 'hittest', 'off');
   xlabel('(-) <-----  X  -----> (+)');
   ylabel('(-) <-----  Y  -----> (+)');

   h = [];
    for i = 1:length(nn),
	   h(i) = text(xx(i), yy(i), num2str(nn(i)));
	end
   set(h, 'color', regcolor);
      
   allpoints = [xx yy nn];
   selectedpoints = zeros(size(allpoints, 1), 1);
   
   set(gca, 'buttondownfcn', 'select_locations', 'position', [.1 .1 .7 .8], 'box', 'on');
   title('Click and Drag to select region');
   
   fighandles(2) = uicontrol('style', 'pushbutton', 'position', [515 50 110 30], 'string', 'Close', 'callback', 'delete(gcf);');
   fighandles(3) = uicontrol('style', 'pushbutton', 'position', [515 90 110 30], 'string', 'Clear Selection', 'callback', 'select_locations');
   fighandles(4) = uicontrol('style', 'pushbutton', 'position', [515 130 110 30], 'string', 'Select All', 'callback', 'select_locations');
   fs = find(selectedpoints);
   if ~isempty(fs),
       numcells = sum(allpoints(fs, 3));
   else
       numcells = 0;
   end
   numlocs = sum(selectedpoints);
   fighandles(5) = text(0, min(get(gca, 'ylim'))+1, sprintf('%d %ss selected in %d locations', numcells, sigstr, numlocs));
   set(fighandles(5), 'horizontalalignment', 'center', 'color', [1 1 1]);
   butstring = sprintf('Selected %s Names', sigstr);
   fighandles(6) = uicontrol('style', 'pushbutton', 'position', [515 330 110 30], 'string', butstring, 'callback', 'select_locations');
   set(fighandles(6), 'tooltipstring', 'Create a text file listing the selected cells');
   fighandles(7) = uicontrol('style', 'toggle', 'position', [515 170 110 30], 'string', 'Grid', 'value', 0, 'callback', 'select_locations');
   fighandles(8) = uicontrol('style', 'pushbutton', 'position', [515 370 110 30], 'string', 'Population Histogram', 'callback', 'select_locations');
   fighandles(9) = uicontrol('style', 'toggle', 'position', [515 210 110 30], 'string', 'Flip X-Axis', 'callback', 'select_locations');
   fighandles(10) = uicontrol('style', 'toggle', 'position', [515 250 110 30], 'string', 'Flip Y-Axis', 'callback', 'select_locations');
   fighandles(11) = uicontrol('style', 'toggle', 'position', [515 290 110 30], 'string', 'Circles', 'callback', 'select_locations', 'tooltipstring', 'Toggle Symbols');
   
elseif gcbo == fighandles(1), % select region
   
   p1 = get(gca, 'currentpoint');
   bounds = rbbox;
   p2 = get(gca, 'currentpoint');
   xp = [p1(1, 1) p2(1, 1)];
   yp = [p1(1, 2) p2(1, 2)];
   xmin = min(xp);
   xmax = max(xp);
   ymin = min(yp);
   ymax = max(yp);
   newselectedpoints = (allpoints(:, 1) > xmin & allpoints(:, 1) < xmax & allpoints(:, 2) > ymin & allpoints(:, 2) < ymax);
   selectedpoints = (xor(selectedpoints, newselectedpoints));
   set(h(find(selectedpoints)), 'color', selcolor);
   set(h(find(~selectedpoints)), 'color', regcolor);
   numcells = sum(allpoints(find(selectedpoints), 3));
   numlocs = sum(selectedpoints);
   set(fighandles(5), 'string', sprintf('%d %ss selected in %d locations', numcells, sigstr, numlocs));
    
elseif gcbo == fighandles(3), %clear selected regions
   
   selectedpoints = zeros(size(selectedpoints));
   set(h(find(~selectedpoints)), 'color', regcolor);
   numcells = sum(allpoints(find(selectedpoints), 3));
   numlocs = sum(selectedpoints);
   set(fighandles(5), 'string', sprintf('%d %ss selected in %d locations', numcells, sigstr, numlocs));
   
elseif gcbo == fighandles(4), %select all
   
   selectedpoints = ones(size(selectedpoints));
   set(h(find(selectedpoints)), 'color', selcolor);
   numcells = sum(allpoints(find(selectedpoints), 3));
   numlocs = sum(selectedpoints);
   set(fighandles(5), 'string', sprintf('%d %ss selected in %d locations', numcells, sigstr, numlocs));
   
elseif gcbo == fighandles(6) | gcbo == fighandles(8), %cell names or population histogram
   
   f = find(selectedpoints);
   if isempty(f), return; end;
   frm = file_ref_mat{:};
   crm = cell_ref_mat{:};
   for i = 1:length(f),
      x = allpoints(f(i), 1);
      y = allpoints(f(i), 2);
      file_list(i) = {strvcat(frm{x+halfway, y+halfway, :})};
      cell_list(i) = {strvcat(crm{x+halfway, y+halfway, :})};
   end
   file_list = strvcat(file_list{:});
   cell_list = strvcat(cell_list{:});
   for i = 1:size(file_list, 1),
      f = find(file_list(i, :) == filesep);
      if ~isempty(f),
         temp_list(i) = {file_list(i, max(f)+1:size(file_list, 2))};
      else
         temp_list(i) = {file_list(i, :)};
      end
   end
   file_list = strvcat(temp_list{:});
   if gcbo == fighandles(6),
      text_file = [dir_spk 'topographic_cell_list.txt'];
   else
      text_file = [dir_spk 'temp_cell_list.txt'];
   end
   fid = fopen(text_file, 'w');
   for i = 1:size(file_list, 1),
      fprintf(fid, '%s\t\t%s\n', file_list(i, :), cell_list(i, :));
   end
   fclose(fid);
   
   if gcbo == fighandles(6),
      edit(text_file);
   else
   	crit = select_criteria;
   	spk_pophist(text_file, crit);
   	delete(text_file);
   end
   return
   
elseif gcbo == fighandles(7), %show/hide gridlines
   
   if get(fighandles(7), 'value'),
      set(gridlines, 'color', [.3 .3 .3]);
   else
      set(gridlines, 'color', [0 0 0]);
   end
   
elseif gcbo == fighandles(9), %Flip X-Axis
   
   if get(fighandles(9), 'value'),
      set(gca, 'xdir', 'reverse');
      xlabel('(+) <-----  X  -----> (-)');
   else
      set(gca, 'xdir', 'normal');
      xlabel('(-) <-----  X  -----> (+)');
   end
   
elseif gcbo == fighandles(10), %Flip Y-Axis
   
   if get(fighandles(10), 'value'),
      set(gca, 'ydir', 'reverse');
      ylabel('(+) <-----  Y  -----> (-)');
      set(fighandles(5), 'position', [0 halfway-1 0]);
   else
      set(gca, 'ydir', 'normal');
      ylabel('(-) <-----  Y  -----> (+)');
      set(fighandles(5), 'position', [0 -halfway+1 0]);
   end
   
elseif gcbo == fighandles(11), %Switch between circles and numbers
   
   if get(fighandles(11), 'value'),
      for i = 1:length(h),
         set(h(i), 'string', 'o', 'fontsize', allpoints(i, 3)+2);
      end
   else
      for i = 1:length(h),
         set(h(i), 'string', num2str(allpoints(i, 3)), 'fontsize', 10);
      end
   end
   
end

posdata = struct('allpoints', allpoints, 'selectedpoints', selectedpoints, 'fighandles', fighandles, 'h', h, 'file_ref_mat', file_ref_mat, 'cell_ref_mat', cell_ref_mat, 'gridlines', gridlines, 'sigstr', sigstr);
set(gcf, 'userdata', posdata);
