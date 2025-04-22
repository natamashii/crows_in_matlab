function handle = plotprep(varargin)
% SYNTAX:
%
%        handle = plotprep(figure_number)
%
%   Figure number is optional; if not used, a new figure will be created.  This function
%   creates an axis in the top two-thirds of a large figure window, with controls at the 
%   bottom for automatic smoothing, output-ing the plotted data to a text file (as smoothed),
%   zooming, and easily changing axes limits.  Clicking on a plotted line will increase its
%   thickness; clicking on it again will return it to normal width.
%
%   Last modified 11/19/98 --WA

directories;

fork = 0;
cb_id = [];

if ~isempty(gcbo) & ~isempty(get(gcf, 'tag')) & strmatch(get(gcf, 'tag'), 'plotprep'),
   if ~isempty(varargin) & strmatch(varargin{1}, 'smooth'),
      fork = 2;
   else
      PRIMAX = get(gcf, 'userdata');
   	if isempty(PRIMAX) | ~ishandle(PRIMAX),
   	   fork = 1;
   	else
   	   cb_id = get(gcbo, 'tag');
   	   cbtype = get(gcbo, 'type');
      end
   end
else
   fork = 1;
end

if fork == 1,

   if ~isempty(varargin),
      fig = varargin{:};
      figure(fig);
      handle = gcf;
   else
      fig = figure;
   end

   set(gcf, 'position', [80 50 700 500]);
   set(gcf, 'defaultaxesbuttondownfcn', 'plotprep'); 
   set(gcf, 'defaultlinecreatefcn', 'plotprep');
   set(gcf, 'defaultlinebuttondownfcn', 'lw = get(gcbo, ''linewidth''); if lw == 0.5, lw = 2.0; else lw = 0.5; end; tg = get(gcbo, ''tag''); f = findobj(gcf, ''tag'', tg); set(f, ''linewidth'', lw);');
   set(gcf, 'tag', 'plotprep');
   
   PRIMAX = subplot(3, 1, 1:2);
   set(gcf, 'userdata', PRIMAX);
   hold on

   h1 = uicontrol('style', 'pushbutton', 'position', [80 115 120 30], 'string', 'Output Figure Data', 'callback', 'output_graph');
   
   axframe = uicontrol('style', 'frame', 'position', [80 15 120 90], 'tag', 'axna', 'callback', 'plotprep');
   axname = uicontrol('style', 'text', 'position', [90 80 100 20], 'string', 'Axes Limits', 'fontangle', 'italic', 'fontweight', 'bold', 'fontsize', 10, 'tag', 'axna', 'buttondownfcn', 'plotprep');
   axmin = uicontrol('style', 'text', 'position', [110 65 30 15], 'string', 'Min', 'fontsize', 8);
   axmax = uicontrol('style', 'text', 'position', [157 65 30 15], 'string', 'Max', 'fontsize', 8);
   axX = uicontrol('style', 'text', 'position', [85 45 15 15], 'string', 'X', 'fontsize', 8, 'fontweight', 'bold');
   axY = uicontrol('style', 'text', 'position', [85 24 15 15], 'string', 'Y', 'fontsize', 8, 'fontweight', 'bold');
   
   axXmin = uicontrol('style', 'edit', 'position', [103 45 43 17], 'tag', 'Xmin', 'callback', 'plotprep');
   axYmin = uicontrol('style', 'edit', 'position', [151 45 43 17], 'tag', 'Ymin', 'callback', 'plotprep');
   axXmax = uicontrol('style', 'edit', 'position', [103 23 43 17], 'tag', 'Xmax', 'callback', 'plotprep');
   axYmax = uicontrol('style', 'edit', 'position', [151 23 43 17], 'tag', 'Ymax', 'callback', 'plotprep');
   
   zframe = uicontrol('style', 'frame', 'position', [215 115 110 30]);
   fbframe1 = uicontrol('style', 'frame', 'position', [215 15 110 90]);
   ztext = uicontrol('style', 'text', 'position', [245 117 70 20], 'string', 'Zoom OFF', 'tag', 'zname');
   zbut = uicontrol('style', 'pushbutton', 'position', [225 120 20 20], 'tag', 'zbut', 'callback', 'plotprep');
   
   %smoothing menu
   smooth_choices = strvcat('boxcar', 'gaussian', 'binned');
   smooth_type_handle(gcf) = uicontrol('style', 'popupmenu', 'position', [220 20 100 20], 'string', smooth_choices);
   fbtext1 = uicontrol('style', 'text', 'position', [220 50 65 20], 'string', 'Window:');
   window_handle(gcf) = uicontrol('style', 'edit', 'position', [290 50 30 20]);
   fbtext2 = uicontrol('style', 'text', 'position', [220 80 100 20], 'string', 'Smoothing', 'fontangle', 'italic', 'fontweight', 'bold', 'fontsize', 10);
   set(window_handle(gcf), 'callback', 'plotprep(''smooth'')', 'tag', 'WINDOW SIZE');
   set(smooth_type_handle(gcf), 'callback', 'plotprep(''smooth'')', 'tag', 'SMOOTH TYPE');
   
   %grouping menu
   filtermask = strcat(dir_grp, '*_grp.mat');
   saved_group_dir = dir(filtermask);
   found_groups = {saved_group_dir.name};
   found_groups = char(found_groups);
   if ~isempty(found_groups),
      for i = 1:size(found_groups, 1),
         trunc_found_groups(i, :) = strrep(found_groups(i, :), '_grp.mat', '        ');
      end
      groupstr = strvcat('All Conditions', 'Each Condition Alone', trunc_found_groups);
   else
      groupstr = strvcat('No Condition Grouping', 'Each Condition Alone');
   end
   grouphandle = uicontrol('style', 'popupmenu', 'position', [340 80 120 25], 'string', groupstr, 'tag', 'grouping', 'callback', 'plotprep');
   
elseif fork == 2, %smooth figure
   
   domain = get(gcf, 'userdata'); %handle to main axis stored here

	window_handle = findobj(gcf, 'tag', 'WINDOW SIZE');
	type_handle = findobj(gcf, 'tag', 'SMOOTH TYPE');

	window = str2num(get(window_handle, 'string'));
	if isempty(window), %not numeric
	   set(window_handle, 'string', '');
	   return
	end
	if window > 999,
	   window = 999;
	   set(window_handle, 'string', '999');
	end

	tp = get(type_handle, 'value');
	if tp == 1,
	   smooth_type = 'boxcar';
	elseif tp == 2,
	   smooth_type = 'gauss';
	elseif tp == 3,
	   smooth_type = 'bin';
	end

	h = findobj(domain, 'type', 'line');
	count = 0;
	for i = 1:length(h);
	   if length(get(h(i), 'xdata'))>2,
	      ud = get(h(i), 'userdata');
	      if length(ud) == 0,
	         udx = get(h(i), 'xdata');
	         udy = get(h(i), 'ydata');
	         ud = cat(1, udx, udy);
	         set(h(i), 'userdata', ud);
	      else
	         udx = ud(1, :);
	         udy = ud(2, :);
  	    	end
  	    	if window == 1,
       	  smoothy = udy;
      	else
      	   smoothy = smooth(udy, window, smooth_type);
      	end
      	set(h(i), 'ydata', smoothy);
      	if tp == 3 & window > 1, %binned data requires fewer x points
      	   newx = 1:window:length(udx);
      	   if length(newx)>length(smoothy),
      	      newx = newx(1:length(smoothy));
      	   end
      	   set(h(i), 'xdata', newx);
      	else
      	   set(h(i), 'xdata', udx);
      	end
   	end
	end

   axXmin = findobj(gcf, 'tag', 'Xmin');
   axXmax = findobj(gcf, 'tag', 'Xmax');
   axYmin = findobj(gcf, 'tag', 'Ymin');
   axYmax = findobj(gcf, 'tag', 'Ymax');
   
   PRIMAX = get(gcf, 'userdata');
   axes(PRIMAX);
   axvals = axis;
   set(axXmin, 'string', axvals(1));
   set(axXmax, 'string', axvals(3));
   set(axYmin, 'string', axvals(2));
   set(axYmax, 'string', axvals(4));
   
elseif cbtype(1:4) == 'axes' | cbtype(1:4) == 'line',
      
   axXmin = findobj(gcf, 'tag', 'Xmin');
   axXmax = findobj(gcf, 'tag', 'Xmax');
   axYmin = findobj(gcf, 'tag', 'Ymin');
   axYmax = findobj(gcf, 'tag', 'Ymax');
   
   axes(PRIMAX);
   axvals = axis;
   set(axXmin, 'string', axvals(1));
   set(axXmax, 'string', axvals(3));
   set(axYmin, 'string', axvals(2));
   set(axYmax, 'string', axvals(4));
      
else
   
   cb_id = cb_id(1:4);
  
   if cb_id == 'zbut',
      
      zstringh = findobj(gcf, 'tag', 'zname');
      zstring = get(zstringh, 'string');
      zbuth = findobj(gcf, 'tag', 'zbut');
      if zstring(1:7) == 'Zoom OF',
         zoom on
         set(zstringh, 'string', 'Zoom ON');
         set(zbuth, 'string', 'X');
      else
         zoom off
         set(zstringh, 'string', 'Zoom OFF');
         set(zbuth, 'string', '');
      end
         
   elseif cb_id == 'Xmin' | cb_id == 'Xmax' | cb_id == 'Ymin' | cb_id == 'Ymax',
          
       axXmin = findobj(gcf, 'tag', 'Xmin');
       axXmax = findobj(gcf, 'tag', 'Xmax');
       axYmin = findobj(gcf, 'tag', 'Ymin');
       axYmax = findobj(gcf, 'tag', 'Ymax');
         
       Xmin = str2num(get(axXmin, 'string'));
       Xmax = str2num(get(axXmax, 'string'));
       Ymin = str2num(get(axYmin, 'string'));
       Ymax = str2num(get(axYmax, 'string'));
          
       if isempty(Xmin) | isempty(Xmax) | isempty(Ymin) | isempty(Ymax),
          axes(PRIMAX);
          axvals = axis;
          set(axXmin, 'string', axvals(1));
          set(axXmax, 'string', axvals(3));
          set(axYmin, 'string', axvals(2));
          set(axYmax, 'string', axvals(4));
       else
          axes(PRIMAX);
          axis([Xmin Ymin Xmax Ymax]);
       end
       
    elseif cb_id == 'grou',
       
      spike_data = get(PRIMAX, 'userdata');
      condhists = spike_data.condhists;
      numtrials = spike_data.numtrials;
      condarray = spike_data.condarray;
      chosen_analysis = spike_data.analysis;
      
      filtermask = strcat(dir_grp, '*_grp.mat');
      saved_group_dir = dir(filtermask);
  		found_groups = {saved_group_dir.name};
   	found_groups = char(found_groups);

      groupselect = get(gcbo, 'value');
      if groupselect > 2,
	      groupfile = deblank(found_groups(groupselect-2, :));
   	   load([dir_grp groupfile]);
   	elseif groupselect == 1,
      	cp = condarray;
      	condgrps = cp';
      	groupnames = 'All Conditions';
   	elseif groupselect == 2,
      	cp = condarray;
      	condgrps = cp;
      	groupnames = num2str(cp);
      end
            
      for g = 1:size(condgrps, 1),
		   f = find(ismember(condarray, condgrps(g, :)));
   		h(:, g) = sum(condhists(:, f), 2)./sum(numtrials(f));
      end
      cla;
      if strmatch(chosen_analysis, 'xcorr'),
         cchalfwin = (size(h, 1)-1)/2;
         plot(-cchalfwin:cchalfwin, h);
      else
	      plot(h);
      end
      plotprep('smooth');
      delete(findobj(gcf, 'tag', 'legend'));
      linetags(groupnames);
      
   end
   
end
