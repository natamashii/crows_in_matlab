function directory_manager
% GUI for setting the directories used by SPK tools
% This routine can be called from the SPK main menu, under "file"
%
% created 7/18/98  --WA
% last modified 3/16/2001  --MH

% figure userdata contains the current base dir.
% $Header$

dm_version = 'v3.0';
directories

windowname = sprintf('SpikeTools Directory Manager %s', dm_version);

f = findobj('name', windowname);
if ~isempty(f),
   figure(f);
end

if isempty(f),
        % called from menu
   figure
   
   set(gcf, 'position', [200 50 400 550], ...
            'menubar', 'none', ...
            'numbertitle', 'off', ...
            'name', windowname, ...
            'resize', 'off');
   f = uicontrol('style', 'frame', ...
                 'position', [10 40 380 500]);
   setbut = uicontrol('style', 'pushbutton', ...
                      'position', [80 10 240 25], ...
                      'string', 'Set Directories', ...
                      'fontsize', 10, ...
                      'fontweight', 'bold', ...
                      'tag', 'select', ...
                      'callback', 'directory_manager', ...
                      'backgroundcolor', [.65 .5 .5]);

   numdirs = 9;
   for i = 1:numdirs,
      switch i,
      case 1,
         dtext = 'Cortex color look-up table (LUT) files are stored in';
         dir_which = dir_lut;
      case 2,
         dtext = 'Cortex graphics (CTX) files are stored in';
         dir_which = dir_ctx;
      case 3,
         dtext = 'Bitmap graphics (BMP) files are stored in';
         dir_which = dir_bmp;
      case 4,
         dtext = 'Spike rate text output is to be stored in';
         dir_which = dir_output;
      case 5,
         dtext = 'Cortex run-time files (e.g., ".CON") files are stored in';
         dir_which = dir_cortex;
      case 6,
         dtext = 'Condition grouping files are to be stored in';
         dir_which = dir_grp;
      case 7,
         dtext = 'SPK data files are to be stored in';
         dir_which = dir_spk;
      case 8,
         dtext = 'Cortex and NEX data files are stored in';
         dir_which = dir_m;
      case 9,
         dtext = 'Base Directory:';
         dir_which = base_dir;
      end
      if i == 8,
         dirbox(i) = uicontrol('style', 'edit', ...
                               'position', [15 435 240 20], ...
                               'horizontalalignment', 'left', ...
                               'backgroundcolor', [1 1 1]);
         dirlabel(i) = uicontrol('style', 'text', ...
                                 'position', [15 455 240 20], ...
                                 'string', dtext);
         suffixbox = uicontrol('style', 'edit', ...
                               'position', [260 435 55 20], ...
                               'string', mask_m, ...
                               'horizontalalignment', 'left', ...
                               'backgroundcolor', [1 1 1], ...
                               'tag', 'suffix', ...
                               'tooltipstring', 'Naming convention for Cortex data files');
      else
         dirbox(i) = uicontrol('style', 'edit', ...
                               'position', [15 50+55*(i-1) 300 20], ...
                               'horizontalalignment', 'left', ...
                               'backgroundcolor', [1 1 1]);
         dirlabel(i) = uicontrol('style', 'text', ...
                                 'position', [15 70+55*(i-1) 300 20], ...
                                 'string', dtext);
      end
      tag1 = strcat('dirbox', num2str(i));
      set(dirbox(i), 'tag', tag1, ...
                     'string', dir_which, ...
                     'callback', 'directory_manager', ...
                     'userdata', dir_which);
      browsebut(i) = uicontrol('style', 'pushbutton', ...
                               'position', [325 50+55*(i-1) 60 20], ...
                               'string', 'Find', ...
                               'callback', 'directory_manager');
      tag2 = strcat('browsebut', num2str(i));
      set(browsebut(i), 'tag', tag2);
      dirlabel(i) = uicontrol('style', 'text', ...
                              'position', [15 70+55*(i-1) 300 20], ...
                              'string', dtext);
      tag3 = strcat('dir_label', num2str(i));
      set(dirlabel(i), 'tag', tag3);
      suffixlabel = uicontrol('style', 'text', ...
                              'position', [260 455 55 20], ...
                              'string', 'file mask');
   end
elseif ismember(gcbo, get(gcf, 'children')),
   % callback
   tag = get(gcbo, 'tag');
   tagnum = tag(length(tag));
   dirbox = findobj(gcf, 'tag', strcat('dirbox', tagnum));
   if strmatch(tag, 'select'),
      for i = 1:9,
         dirbox = findobj('tag', strcat('dirbox', num2str(i)));
         set_dir = get(dirbox, 'string');
         switch i,
         case 1,
            dir_lut = set_dir;
         case 2,
            dir_ctx = set_dir;
         case 3,
            dir_bmp = set_dir;
         case 4,
            dir_output = set_dir;
         case 5,
            dir_cortex = set_dir;
         case 6,
            dir_grp = set_dir;
         case 7,
            dir_spk = set_dir;
         case 8,
            dir_m = set_dir;
         case 9,
            base_dir = set_dir;
         end
      end
      mask_m = get(findobj('tag', 'suffix'), 'string');

      spk_tools_dir = which('spk');
      [spk_tools_dir sname sext] = fileparts (spk_tools_dir);
      dirfile = fullfile (spk_tools_dir, 'directories.mat');
      save(dirfile, 'mask_m', 'base_dir', 'dir_m', 'dir_spk', 'dir_grp', 'dir_cortex', 'dir_output', 'dir_bmp', 'dir_ctx', 'dir_lut');
      delete(gcf)
      
      %update grouping menu on spk main menu, if it exists
      fig = findobj('tag', 'spkmenu');
      if ~isempty(fig),
         u = get(fig, 'userdata');
         filtermask = fullfile (dir_grp, '*_grp.mat');
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
         set(u.handles(10), 'value', 1, 'string', groupstr);
      end

      return
   elseif strmatch(tag(1:length(tag)-1), 'browsebut'),
      pathname = deblank(get(dirbox, 'string'));
      if pathname(length(pathname)) ~= filesep,
         pathname(length(pathname)+1) = filesep;
      end
      f = find(pathname == filesep);
      if length(f) > 1,
         pathname = pathname(1:f(length(f)-1));
      end
      directory = choose_directory(pathname);
      if ~isempty(directory),
         set(dirbox, 'string', directory);
      end
   elseif strmatch(tag(1:length(tag)-1), 'dirbox'),
      %  some dir was changed.

      set_dir = get(gcbo, 'string');

      %%% check for valid input
      if isempty(set_dir)
         if tagnum ~= '9' 
            % set to base dir
            set(gcbo, 'string', get(gcbo, 'userdata'));
         end
         return
      end

      % handle both unix and win32 names
      if set_dir(3) ~= '\' & set_dir(1) ~= '/'
         error('***** Must include full path... *****');
      end
      
      set_dir = ensuretrailslash (set_dir);
      set(gcbo, 'string', set_dir);

      if exist(set_dir) ~= 7, % not a valid directory
         created = create_dir_with_check (set_dir);
         if created == 0
           % set to default base dir
           set(gcbo, 'string', get(gcbo, 'userdata'));
           return
         end
      end
   end
   if tagnum == '9', % changed base directory successfully

      old_base_dir = detrailslash(deblank(get(dirbox, 'userdata')));
      new_base_dir = detrailslash(deblank(get(dirbox, 'string')));
      for i = 1:8,
         boxcheck = findobj(gcf, 'tag', strcat('dirbox', num2str(i)));
         olddir = detrailslash(deblank(get(boxcheck, 'string')));
         if isempty(olddir)
            set(boxcheck, 'string', ensuretrailslash(new_base_dir));
         else            
            newdir = strrep(olddir, old_base_dir, new_base_dir);
            % only try to change this dir if it was a child of old_base_dir
            % to begin with. 
            if ~strcmp(newdir, olddir)
               % fix any remaining slashes
               newdir = strrep (newdir, '/', filesep);
               newdir = strrep (newdir, '\', filesep);

               if exist(newdir) == 7   % already exists
                  set(boxcheck, 'string', ensuretrailslash(newdir)); ...
               else                     
                  created = create_dir_with_check(newdir);
                  if created
                  else
                     % restore previous default.
                     set(boxcheck, 'string', ensuretrailslash(olddir));
                  end
               end
            end
         end
      end
   set(dirbox, 'userdata', ensuretrailslash(deblank(get(dirbox, 'string'))));
   end
end

function outstr = detrailslash (instr)
if instr(end) == '/' | instr(end) == '\'
        outstr = instr(1:(end-1));
else
        outstr = instr;
end
return


function outstr = ensuretrailslash (instr)
outstr = detrailslash(instr);
outstr(end+1) = filesep;
return


function status = mkdir_fullpath (fullpath)
fullpath = detrailslash(deblank(fullpath));
slashi = find(fullpath == filesep);
           
slash = slashi(end-1);
parentdir = fullpath(1:(slash-1));
newdir = fullpath(slash+1:end);

status = mkdir(parentdir, newdir);
return


function created = create_dir_with_check (inpath)
% this creates a directory with confirmation and error checking.
% created is 1 if successfully created, 0 otherwise
huh = questdlg(strcat('Create: ', inpath, ' now?'));
switch (huh)
 case 'Yes'
           status = mkdir_fullpath(inpath);

           if status == 0,
              error(strcat('******* Error creating:', inpath, '******'));
           elseif status == 1,
              disp(strcat('Created directory: ', inpath));
              created = 1;
           elseif status == 2,
              warning ('Directory already exists.');
              created = 0;
           end
 otherwise
  created = 0;
end
return

   % mask_m     ** cortex data file suffix
   % base_dir
   % dir_m      ** cortex data files
   % dir_spk    ** spk data files
   % dir_grp    ** condition grouping information
   % dir_cortex ** cortex run-time files
   % dir_output ** spike-rate text files
   % dir_bmp    ** bitmap graphics files
   % dir_ctx    ** cortex graphics files
   % dir_lut    ** cortex color look-up table files
   
