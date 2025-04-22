function chosen_directory = choose_directory(varargin)
% SYNTAX:
%
%        selected_directory = choose_directory(path)
%
% GUI routine for allowing the user to select a directory, where "path" is an
% optional argument which sets the starting point.
%
% created 7/18/98  --WA
% last modified 3/29/2001 --WA

persistent selected_directory

if isempty(findobj('tag', 'seldir')),
   
   if ~isempty(varargin),
      directory = varargin{1};
      if directory(length(directory)) ~= filesep,
         directory(length(directory)+1) = filesep;
      end
   else
      directory = pwd;
   end
   
   d = dir(directory);
   n = cat(1, {d.name}');
   isd = {d.isdir};
   isd = cat(1, isd{:});
   dirs = n(find(isd));
   bcol = [.8 .8 .8];
   
   figure
   set(gcf, 'position', [200 100 250 380], 'menubar', 'none', 'numbertitle', 'off', 'name', 'Select Directory', 'tag', 'seldir', 'closerequestfcn', 'choose_directory(0)');
   lb = uicontrol('style', 'listbox', 'position', [15 115 220 260], 'string', dirs, 'callback', 'choose_directory;', 'tag', 'seldirlistbox', 'backgroundcolor', [1 1 1]);
   dirframe = uicontrol('style', 'frame', 'position', [15 70 220 40], 'backgroundcolor', bcol);
   dirwin = uicontrol('style', 'text', 'position', [16 71 217 36], 'tag', 'dirwin', 'string', directory, 'fontsize', 10, 'backgroundcolor', bcol);
   pbselect = uicontrol('style', 'pushbutton', 'position', [15 35 220 30], 'string', 'Select', 'callback', 'choose_directory;', 'tag', 'seldirselect', 'backgroundcolor', [.65 .5 .5]);
   pbcancel = uicontrol('style', 'pushbutton', 'position', [15 10 220 20], 'string', 'Cancel', 'callback', 'choose_directory;', 'tag', 'seldircancel');
   seldirdata = struct('dirs', {dirs}, 'directory', directory);
   set(gcf, 'userdata', seldirdata);
   
else
   
   seldirdata = get(gcf, 'userdata');
   dirs = seldirdata.dirs;
   directory = seldirdata.directory;
   gtag = get(gcbo, 'tag');
   if ~isempty(varargin) & varargin{1} == 0,
      selected_directory = [];
      delete(gcf);
      return
   end
   
   if strmatch(gtag, 'seldirlistbox'),
      
      chosen_dir = dirs(get(gcbo, 'value'));
      chosen_dir = chosen_dir{:};
      if strmatch(chosen_dir, '..'),
         f = find(directory == filesep);
         directory = directory(1:f(length(f)-1));
      else
         if directory(length(directory)) ~= filesep,
            directory(length(directory)+1) = filesep;
         end
         directory = strcat(directory, chosen_dir, filesep);
      end
      
      set(findobj('tag', 'dirwin'), 'string', directory);
      
      d = dir(directory);
      n = cat(1, {d.name}');
      isd = {d.isdir};
      isd = cat(1, isd{:});
      dirs = n(find(isd));
      set(gcbo, 'value', 1, 'string', dirs);
      
      seldirdata = struct('dirs', {dirs}, 'directory', directory);
      set(gcf, 'userdata', seldirdata);
          
   elseif strmatch(gtag, 'seldirselect'),
      
      seldirdata = get(gcf, 'userdata');
      selected_directory = seldirdata.directory;
      delete(gcf);
      return
      
   elseif strmatch(gtag, 'seldircancel'),
      
      selected_directory = [];
      delete(gcf);
      return
      
   end
   
end

waitfor(findobj('tag', 'seldir')); %do not return chosen_directory until one is chosen
chosen_directory = selected_directory;