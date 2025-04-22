function create_spk_window(varargin)
%
% This is the GUI control routine for NEXCORTEX2SPK. It can be launched from:
%
%	SpikeTools Main Menu >> File > Create SPK File
%
% Created March, 2001 --WA
% Last modified 4/2/2001 --WA

directories;
SpikeConfig = spiketools_config(0);

csw = findobj('tag', 'CSW');
if ~isempty(csw),
   figure(csw);
end

if isempty(varargin) & isempty(csw), %create new window
   
   proghandles(1) = figure;
   set(gcf, 'position', [300 100 400 500], 'numbertitle', 'off', 'resize', 'off', 'name', 'Create SPK File', 'menubar', 'none', 'doublebuffer', 'on', 'tag', 'CSW');
   handles(1) = uicontrol('style', 'frame', 'position', [10 355 380 138]);
   handles(2) = uicontrol('style', 'pushbutton', 'position', [18 450 107 35], 'string', 'Select Cortex File(s)');
   handles(3) = uicontrol('style', 'listbox', 'position', [132 449 250 38], 'string', strcat(dir_m, '???'), 'backgroundcolor', [1 1 1], 'horizontalalignment', 'left');
   handles(4) = uicontrol('style', 'pushbutton', 'position', [18 400 107 42], 'string', 'Create SPK File(s)', 'backgroundcolor', [.65 .5 .5], 'enable', 'off');
   handles(5) = uicontrol('style', 'edit', 'position', [220 420 30 22], 'string', num2str(SpikeConfig.StartTrialCode), 'backgroundcolor', [1 1 1]);
   handles(6) = uicontrol('style', 'text', 'position', [130 419 80 20], 'string', 'Trial Start Code', 'horizontalalignment', 'right');
   handles(7) = uicontrol('style', 'edit', 'position', [350 420 30 22], 'string', num2str(SpikeConfig.EndTrialCode), 'backgroundcolor', [1 1 1]);
   handles(8) = uicontrol('style', 'text', 'position', [260 419 80 20], 'string', 'Trial End Code', 'horizontalalignment', 'right');
   handles(9) = uicontrol('style', 'edit', 'position', [350 390 30 22], 'string', num2str(SpikeConfig.StartCodeOccurrence), 'backgroundcolor', [1 1 1]);
   handles(10) = uicontrol('style', 'text', 'position', [150 389 200 20], 'string', 'Merge files using start code occurrence #');
   handles(11) = uicontrol('style', 'checkbox', 'position', [20 360 30 30], 'value', SpikeConfig.IncludeLFP);
   handles(12) = uicontrol('style', 'text', 'position', [40 360 90 22], 'string', 'Include LFP data', 'horizontalalignment', 'left');
   handles(13) = uicontrol('style', 'checkbox', 'position', [150 360 30 30], 'value', SpikeConfig.UseNexCodes);
   handles(14) = uicontrol('style', 'text', 'position', [170 360 200 22], 'string', 'Use behavioral codes from NEX file', 'horizontalalignment', 'left');
   set(handles(2), 'tag', 'SelectCortexFile', 'callback', 'create_spk_window;');
   set(handles(3), 'tag', 'CortexFileName', 'callback', 'create_spk_window;');
   set(handles(4), 'tag', 'GoButton', 'callback', 'create_spk_window;');
   set(handles(5), 'tag', 'StartTrialCode');
   set(handles(7), 'tag', 'EndTrialCode');
   set(handles(9), 'tag', 'StartCodeOccurrence');
   set(handles(11), 'tag', 'IncludeLFP', 'callback', 'create_spk_window;');
   set(handles(13), 'tag', 'UseNexCodes');
   
   handles(15) = uicontrol('style', 'frame', 'position', [10 10 380 305]);
   handles(16) = uicontrol('style', 'text', 'position', [20 290 360 23], 'string', 'Conversion Status: Idle', 'fontsize', 11, 'fontweight', 'bold', 'foregroundcolor', [.5 0 0]);
   handles(17) = uicontrol('style', 'text', 'position', [20 160 360 20], 'string', 'Messages', 'fontsize', 10, 'foregroundcolor', [.5 0 0]);
   handles(18) = uicontrol('style', 'listbox', 'position', [20 50 360 110], 'backgroundcolor', [1 1 1]);
   handles(33) = subplot('position', [.052 .65 .898 .028]);
   set(handles(33), 'layer', 'bottom', 'color', [0 0 0], 'handlevisibility', 'off', 'linewidth', 3, 'xtick', [], 'ytick', []);
   handles(19) = subplot('position', [.05 .65 .9 .03]);
   set(handles(19), 'layer', 'top', 'box', 'on', 'color', [1 1 1], 'xtick', [], 'ytick', [], 'xlim', [0 1], 'ylim', [0 1]);
   handles(20) = patch([0 0 0 0], [0 0 0 0], [1 0 0]);
   set(handles(16), 'tag', 'StatusText');
   set(handles(18), 'tag', 'MessageBox');
   set(handles(20), 'tag', 'ProgressBar', 'erasemode', 'background');
   
   handles(21) = uicontrol('style', 'checkbox', 'position', [30 265 20 20], 'enable', 'inactive', 'tag', 'CortexCheck');
   handles(22) = uicontrol('style', 'checkbox', 'position', [30 240 20 20], 'enable', 'inactive', 'tag', 'NexCheck');
   handles(23) = uicontrol('style', 'checkbox', 'position', [30 215 20 20], 'enable', 'inactive', 'tag', 'TrialCheck');
   handles(24) = uicontrol('style', 'checkbox', 'position', [30 190 20 20], 'enable', 'inactive', 'tag', 'AssignCheck');
   
   handles(25) = uicontrol('style', 'checkbox', 'position', [210 265 20 20], 'enable', 'inactive', 'tag', 'WriteHeaderCheck');
   handles(26) = uicontrol('style', 'checkbox', 'position', [210 240 20 20], 'enable', 'inactive', 'tag', 'WriteEyeCheck');
   handles(27) = uicontrol('style', 'checkbox', 'position', [210 215 20 20], 'enable', 'inactive', 'tag', 'WriteSpikeCheck');
   if SpikeConfig.IncludeLFP == 1,
      propstat = 'inactive';
   else
      propstat = 'off';
   end
   handles(28) = uicontrol('style', 'checkbox', 'position', [210 190 20 20], 'enable', propstat, 'tag', 'WriteLFPCheck');
   
   handles(29) = uicontrol('style', 'text', 'position', [50 263 140 20], 'string', 'Load CORTEX data', 'horizontalalignment', 'left');
   handles(29) = uicontrol('style', 'text', 'position', [50 238 140 20], 'string', 'Load NEX data', 'horizontalalignment', 'left');
   handles(30) = uicontrol('style', 'text', 'position', [50 213 140 20], 'string', 'Determine trial boundaries', 'horizontalalignment', 'left');
   handles(31) = uicontrol('style', 'text', 'position', [50 188 140 20], 'string', 'Assign spikes to trials', 'horizontalalignment', 'left');
   
   handles(29) = uicontrol('style', 'text', 'position', [230 263 140 20], 'string', 'Write CORTEX header info', 'horizontalalignment', 'left');
   handles(29) = uicontrol('style', 'text', 'position', [230 238 140 20], 'string', 'Write eye data', 'horizontalalignment', 'left');
   handles(30) = uicontrol('style', 'text', 'position', [230 213 140 20], 'string', 'Write spike data', 'horizontalalignment', 'left');
   handles(31) = uicontrol('style', 'text', 'position', [230 188 140 20], 'string', 'Write LFP data', 'horizontalalignment', 'left');
      
   handles(32) = uicontrol('style', 'pushbutton', 'position', [130 18 140 25], 'string', 'View Log File', 'enable', 'off', 'tag', 'ViewLog');
   
   set(gcf, 'userdata', handles);
   
else
   
   if ismember(gcbo, get(gcf, 'children')) & isempty(varargin),
      callertag = get(gcbo, 'tag');
      if strmatch(callertag, 'SelectCortexFile'),
         
         set(findobj(gcf, 'tag', 'MessageBox'), 'string', '');
         d = dir(dir_m);
         [fnames{1:length(d)}] = deal(d.name);
         fnames = sort(fnames');
			[selection, ok] = listdlg('name', 'Create SPK file(s)', 'PromptString', 'Select CORTEX file(s)','SelectionMode', 'multiple','ListString', fnames);
			if ok == 0,   return; end
         files_selected = strcat(dir_m, fnames(selection));
         files_selected = verify_cortex(files_selected);
         if isempty(files_selected),
            set(findobj(gcf, 'tag', 'GoButton'), 'enable', 'off');
            set(findobj(gcf, 'tag', 'CortexFileName'), 'string', strcat(dir_m, '???'));
            return;
         end
         set(findobj(gcf, 'tag', 'CortexFileName'), 'string', files_selected, 'value', 1);
         set(findobj(gcf, 'tag', 'GoButton'), 'enable', 'on');
         create_spk_window('MessageBox', sprintf('<<+>>  %i CORTEX file(s) selected  <<+>>', length(files_selected)));
         
      elseif strmatch(callertag, 'IncludeLFP'),
         
         val = get(findobj(gcf, 'tag', callertag), 'value');
         targetobj = findobj(gcf, 'tag', 'WriteLFPCheck');
         if val == 1,
            set(targetobj, 'enable', 'inactive');
         else
            set(targetobj, 'value', 0, 'enable', 'off');
         end
         
      elseif strmatch(callertag, 'GoButton'),
         
         %update conversion parameters
         SpikeConfig.StartTrialCode = str2num(get(findobj(gcf, 'tag', 'StartTrialCode'), 'string'));
         SpikeConfig.EndTrialCode = str2num(get(findobj(gcf, 'tag', 'EndTrialCode'), 'string'));
         SpikeConfig.StartCodeOccurrence = str2num(get(findobj(gcf, 'tag', 'StartCodeOccurrence'), 'string'));
         SpikeConfig.IncludeLFP = get(findobj(gcf, 'tag', 'IncludeLFP'), 'value');
         SpikeConfig.UseNexCodes = get(findobj(gcf, 'tag', 'UseNexCodes'), 'value');
         spk_tools_dir = which('spk');
			f = find(spk_tools_dir == '\');
			spk_tools_dir = spk_tools_dir(1:max(f));
         cfgfile = strcat(spk_tools_dir, 'spk_cfg.mat');
         save(cfgfile, 'SpikeConfig');
         
         handles = get(gcf, 'userdata');
         set(handles(18), 'string', '');
         
         %%%start file conversion
         CFN = findobj(gcf, 'tag', 'CortexFileName');
         cortex_files = get(CFN, 'string');
         numfiles = length(cortex_files);
         for i = 1:numfiles,
            set(handles(21:31), 'value', 0);
         	set(handles(21:28), 'enable', 'inactive');
         	if SpikeConfig.IncludeLFP == 0,
            	set(handles(28), 'enable', 'off');
         	end
         	set(handles(32), 'enable', 'off');
            batchmode = (i < numfiles);
            set(CFN, 'value', i);
            fname = cortex_files{i};
            slash = find(fname == filesep);
            if isempty(slash),
               abrname = fname;
            else
               abrname = fname(max(slash)+1:length(fname));
            end
            create_spk_window('MessageBox', sprintf('File %i of %i:  %s', i, numfiles, abrname));
            nexcortex2spk(fname, batchmode);
         end
         
      end
   elseif ~isempty(varargin), %update a progress indicator
      
      callertag = varargin{1};
      callerval = varargin{2};
      obj = findobj(gcf, 'tag', callertag);
      
      if strmatch(get(obj, 'type'), 'patch'),
         
         xpos = callerval;
         set(obj, 'xdata', [0 0 xpos xpos], 'ydata', [1 0 0 1]);
         
     	elseif strmatch(get(obj, 'type'), 'uicontrol'),
      	if strmatch(get(obj, 'style'), 'checkbox'),
            
            if callerval == -1,
               set(obj, 'enable', 'off', 'value', 0);
            else
            	set(obj, 'value', callerval);
         	end
         
      	elseif strmatch(get(obj, 'style'), 'text'),
         
         	set(obj, 'string', callerval);
         
      	elseif strmatch(get(obj, 'style'), 'listbox'),
            
            newstring = strvcat(get(obj, 'string'), callerval);
            set(obj, 'string', newstring, 'value', size(newstring, 1));
            
         elseif strmatch(get(obj, 'style'), 'pushbutton'),
            
            set(obj, 'enable', 'on', 'callback', sprintf('edit %s', callerval));
            
      	end
   	end
   
      drawnow;
      
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outfiles = verify_cortex(infiles)

outfiles = [];
fcount = 0;
for i = 1:length(infiles),
   f = infiles{i};
   [fid msg] = fopen(f, 'r');
   slash = find(f == filesep);
   if isempty(slash),
      fname = f;
   else
      fname = f(max(slash)+1:length(f));
   end
   
   if fid == -1,
      create_spk_window('MessageBox', sprintf('%s: %s', fname, msg));
   else
      [bytes count] = fread(fid, 9, 'uint16');
      if (count < 9) | (bytes(1) ~= 26) | any(bytes(2:4) > 10000), %unlikely to be a valid CORTEX file
         create_spk_window('MessageBox', sprintf('%s: Not recognized as a CORTEX file', fname));
      else
         %try to read next trial:
         skip_length = bytes(1) + bytes(6) + bytes(7) + bytes(8) + bytes(9);
         status = fseek(fid, skip_length, -1);
         if status == -1,
            create_spk_window('MessageBox', sprintf('%s: Not recognized as a CORTEX file', fname));
         else
            [bytes count] = fread(fid, 9, 'uint16');
            if (count < 9) | (bytes(1) ~= 26) | any(bytes(2:4) > 10000), %unlikely to be a valid CORTEX file
         		create_spk_window('MessageBox', sprintf('%s: Not recognized as a CORTEX file', fname));
            else
               fcount = fcount + 1;
         		outfiles{fcount} = f;
            end
         end
      end
      fclose(fid);
   end
end
