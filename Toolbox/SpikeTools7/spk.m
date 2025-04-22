function spk
% SpikeTools 7.0
%
% MATLAB routines for single-unit analysis by
% Wael Asaad, Gregor Rainer, and Mark Histed
% in the Lab of Earl K. Miller, Ph.D.
% Dept. of Brain and Cognitive Sciences
% and the Center for Learning and Memory
% M.I.T.
%
% see www.mit.edu/~wfasaad/spkguide for SpikeTools user's manual
%
% SpikeTools Main Menu GUI created by WA, 1996-2001
% last modified 3/23/2001 --WA

v = version;
dot = find(v == '.');
Mversion = str2num(v(1:dot(2)-1));
if Mversion < 5.2, 
   disp('MATLAB version 5.2 or better is recommended for full functionality');   
end

directories;
cfg_file = 'spk_cfg.mat';
if exist(cfg_file) ~= 2,
   spiketools_config;
end
load('spk_cfg.mat');
[SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spikestat;

values = [];
filename = [];
code_reference = [];

fig = findobj('tag', 'spkmenu');

if ishandle(fig), %extract pre-created variables:
   spk_variables = get(fig, 'userdata');
   handles = spk_variables.handles;
   menuhandles = spk_variables.menuhandles;
   analysis_callbacks = spk_variables.analysis_callbacks;
   values = spk_variables.values;
   filename = spk_variables.filename;
   code_reference = spk_variables.code_reference;
end

selectstring = 'Select SPK File...';
if ~isempty(gcbo), %make sure selected file in menu is same as current file in spikestat
   filename = get(handles(1), 'string');
   if isempty(strmatch(filename, selectstring)),
      [SpikeInfo, SpikeFileHeader, SpikeVarHeader, SpikeData] = spikestat;
      if ~isempty(SpikeInfo),
         menufile = strcat(dir_spk, filename);
         statfile = SpikeInfo.FileName;
         slash = find(statfile == filesep);
         if isempty(strmatch(lower(statfile), lower(menufile))),
            spk_read(menufile);
         end
      end
   else
      SpikeInfo = [];
   end
end

handles(256) = 0;
if isempty(gcbo),

   fig = findobj('tag', 'spkmenu');
   if ~isempty(fig),
      figure(fig);
      return
   end
   fig = figure;
   set(fig, 'position', [150 60 645 195], 'numbertitle', 'off', 'name', 'SpikeTools Main Menu', 'tag', 'spkmenu', 'menubar', 'none', 'resize', 'off');
   quit_spk = 'delete(gcf); delete(findobj(''tag'', ''spk''))';
   set(fig, 'closerequestfcn', quit_spk);
   handles(1) = uicontrol('style','pushbutton', 'position', [15 150 115 35], 'string', selectstring, 'callback', 'spk', 'tag', 'SELECTEDFILE', 'tooltipstring', 'Load data file');
   handles(2) = uicontrol('style','listbox', 'position', [141 20 100 165], 'enable', 'off', 'max', 100, 'callback', 'spk', 'tooltipstring', 'Choose a cluster');
   h0 = uicontrol('style', 'frame', 'position', [250 18 230 165]);
   handles(3) = uicontrol('style','popupmenu', 'position', [260 130 120 25], 'string', 'Start Code', 'enable', 'off');
   handles(4) = uicontrol('style','popupmenu', 'position', [260 80 120 25], 'string', 'End Code', 'enable', 'off');
   h3 = uicontrol('style', 'text', 'position', [260 160 100 15], 'string', 'From:');
   h4 = uicontrol('style', 'text', 'position', [260 110 100 15], 'string', 'To:');
   handles(5) = uicontrol('style', 'edit', 'position', [395 135 50 20], 'string', num2str(SpikeConfig.DefaultStartOffset), 'enable', 'off');
   handles(6) = uicontrol('style', 'edit', 'position', [395 85 50 20], 'string', num2str(SpikeConfig.DefaultEndOffset), 'enable', 'off');
   h5 = uicontrol('style', 'text', 'position', [370 160 100 15], 'string', 'Start Offset');
   h6 = uicontrol('style', 'text', 'position', [370 110 100 15], 'string', 'End Offset');
   handles(7) = uicontrol('style', 'edit', 'position', [260 25 100 20], 'string', 'All', 'enable', 'off', 'callback', 'spk');
   h7 = uicontrol('style', 'text', 'position', [260 50 100 15], 'string', 'Selected Blocks');
   handles(8) = uicontrol('style', 'edit', 'position', [370 25 100 20], 'string', 'All', 'enable', 'off', 'callback', 'spk');
   h8 = uicontrol('style', 'text', 'position', [370 50 100 15], 'string', 'Selected Trials');
   
   %%%%%%%%%%%%%% Menu Bar %%%%%%%%%%%%%%%
   % Changes in order of menu objects must be reflected in "menuhandles" references
   % both in this script (for compile_groups and behavioral routines, below) and in sort_conditions.
   filemenu = strvcat('&File', '>Create SPK file(s)', '>SPK file summary', '>Directories', '>Recording Statistics', '>-', '>Compile Codes file', '>-', '>Configuration');
   filecb = strvcat(' ', 'create_spk_window;', 'spkcheck', 'directory_manager', 'recording_stats', ' ', 'compile_codelist', ' ', 'spiketools_config;');
   groupmenu = strvcat('&Groups', '>Sort CONditions file', '>-', '>Compile group text file');
   groupcb = strvcat(' ', 'sort_conditions', ' ', 'spk');
   locmenu = strvcat('&Locations', '>View and Select Neuron Locations', '>-', '>View and Select LFP Locations');
   loccb = strvcat(' ', 'select_locations', ' ', 'select_locations(5)');
   behavmenu = strvcat('&Behavior', '>Response Summary', '>Reaction Times', '>-', '>Plot behavior across trials...', '>>% Correct Over-all', '>>% Correct attempts');
   behavcb = strvcat(' ', 'spk', 'spk_rt(0)', ' ', ' ', 'spk', 'spk');
   if Mversion(1) >= 5.2 & exist('rgb2ind') == 2, %make certain using MATLAB v.5.2 or better and Image processing toolbox is installed
      stimulusmenu = strvcat('&Stimuli', '>View/Convert Stimuli');
      stimuluscb = strvcat(' ', 'stimuli');
   else
      stimulusmenu = strvcat('&Stimuli', '>Convert BMP to CTX', '>Extract LUT', '>-', '>View CTX image', '>View BMP image');
      stimuluscb = strvcat(' ', 'bmp2ctx', 'extract_lut', ' ', 'view_ctx', 'view_bmp');
   end
   eyemenu = strvcat('&Eye', '>View Eye Traces');
   eyecb = strvcat(' ', 'view_eyetrace');
   helpmenu = strvcat('&Help', '>Online Help');
   helpcb = strvcat(' ', 'web(''http://www.mit.edu/~wfasaad/spkguide/'');');
   spkmenu = strvcat(filemenu, groupmenu, locmenu, behavmenu, stimulusmenu, eyemenu, helpmenu);
   spkcb = strvcat(filecb, groupcb, loccb, behavcb, stimuluscb, eyecb, helpcb);
   menuhandles = makemenu(fig, spkmenu, spkcb);
   
   correct_str = strvcat('Use Corrects Only', 'Only Incorrect Attempts', 'All Attempts', 'All Trials');
   handles(9) = uicontrol('style', 'popupmenu', 'position', [490 155 140 25], 'string', correct_str, 'tag', 'correctness', 'tooltipstring', 'Trials to include');
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
   handles(10) = uicontrol('style', 'popupmenu', 'position', [490 125 140 25], 'string', groupstr, 'tooltipstring', 'Condition groupings');
   handles(15) = uicontrol('style', 'pushbutton', 'position', [490 95 140 25], 'string', 'Behavioral Codes', 'callback', 'spk', 'enable', 'off', 'tooltipstring', 'Trial-by-trial code chronology');
   handles(19) = uicontrol('style', 'pushbutton', 'position', [490 20 140 35], 'callback', 'spk', 'tooltipstring', 'About...');
   if Mversion(1) >= 5.2 & exist('rgb2ind') == 2, 
      set(handles(19), 'cdata', imread('spk_ph.jpg'));
   else
      set(handles(19), 'string', 'SpikeTools 7');
   end
   handles(23) = uicontrol('style', 'pushbutton', 'position', [490 62 140 25], 'string', 'Data Raster', 'callback', 'dataview', 'enable', 'off');
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%% Analysis functions Menu: %%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   analysis_functions = strvcat('Histogram', 'Raster', 'X-Corr'); %These are the labels for the spk menu
   analysis_callbacks = strvcat('spk_histogram', 'spk_raster', 'spk_xcorr'); %These are the names of the actual scripts to be invoked
   
   h10 = uicontrol('style', 'frame', 'position', [10 20 125 100]);
   h11 = uicontrol('style', 'text', 'position', [15 88 115 25], 'string', 'Analysis', 'fontsize', 10);
   handles(20) = uicontrol('style', 'popupmenu', 'position', [15 59 115 30], 'string', analysis_functions, 'fontsize', 10, 'enable', 'off');
   handles(21) = uicontrol('style', 'pushbutton', 'position', [15 24 115 30], 'string', 'Execute', 'callback', 'spk', 'enable', 'off', 'backgroundcolor', [.65 .5 .5]);
   handles(22) = uicontrol('style', 'pushbutton', 'position', [15 125 115 20], 'string', 'File Info', 'callback', 'spk_info', 'tooltipstring', 'View and edit experiment info');
   spk_variables = struct('handles', handles, 'menuhandles', menuhandles, 'analysis_callbacks', analysis_callbacks, 'values', values, 'filename', filename, 'code_reference', code_reference, 'found_groups', found_groups');
   
   set(gcf, 'userdata', spk_variables);
   
elseif gcbo == handles(1), % Select SPK file
   
   filtermask = strcat(dir_spk, '*.spk');
   [filename pathname] = uigetfile(filtermask, 'Select SPK file...');
   if pathname == 0,
      return
   end
   
   watchon;
   [SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spk_read([pathname filename]);
   cluster_ids = SpikeInfo.NeuronID;
   codes = SpikeInfo.CodeNumbers;
   if isempty(cluster_ids),
      disp('********** No clusters found in selected file. **********')
   end
   set(handles(1), 'string', filename);
   set(handles(2), 'enable', 'on', 'value', 1, 'string', num2str(cluster_ids));
   load('codes.mat');
   present_codes_index = find(ismember(code_number, unique(codes)));
   valstart = get(handles(3), 'value');
   valend = get(handles(4), 'value');
   prev_start_code = 0;
   if ~isempty(code_reference),
      prev_start_code = code_number(code_reference(valstart));
   end
   prev_end_code = 0;
   if ~isempty(code_reference),
      prev_end_code = code_number(code_reference(valend));
   end
   clear code_matrix code_reference
   for i = 1:length(present_codes_index),
      description = code_descrip(present_codes_index(i), :);
      code_matrix(i, 1:length(description)) = description;
      code_reference(i) = code_number(present_codes_index(i));
   end
   set(handles(3), 'enable', 'on', 'string', code_matrix);
   set(handles(4), 'enable', 'on', 'string', code_matrix);
   set(handles(7), 'enable', 'on', 'string', strcat('1:', num2str(max(SpikeInfo.BlockNumber))));
   set(handles(8), 'enable', 'on', 'string', strcat('1:', num2str(length(SpikeInfo.TrialStartTimes))));
   set(handles(15), 'enable', 'on');
   set(handles(20), 'enable', 'on');
   set(handles(21), 'enable', 'on');
   set(handles(23), 'enable', 'on');
   
   if prev_start_code > 0,
      valstart = find(code_reference == prev_start_code);
      set(handles(3), 'value', valstart);
   else
      fc = find(code_reference == SpikeConfig.DefaultStartCode);
      if ~isempty(fc),
         set(handles(3), 'value', fc);
      end
   end
   if prev_end_code > 0,
      valend = find(code_reference == prev_end_code);
      set(handles(4), 'value', valend);
   else
      fc = find(code_reference == SpikeConfig.DefaultEndCode);
      if ~isempty(fc),
         set(handles(4), 'value', fc);
      end
   end
   set(handles(5), 'enable', 'on');
   set(handles(6), 'enable', 'on');
   cstring = sprintf('spk_info(''%s'')', SpikeInfo.FileName);
   set(handles(22), 'callback', cstring);
   
   watchoff;
   
elseif gcbo == handles(2), % select cluster(s)
   
   clusindex = get(gcbo, 'value');
   boxtop = get(gcbo, 'listboxtop');
   if (max(clusindex) - boxtop) > 10,
      set(gcbo, 'listboxtop', boxtop + 1);
   end
   
   if length(clusindex) == 1,
      return
   end
   
   cluster_ids = SpikeInfo.NeuronID;
   clusters = cluster_ids(clusindex);
   base_clusters_present = round(cluster_ids./100)*100;
   base_clusters_selected = round(clusters./100)*100;
   if length(base_clusters_selected) > 1,
      fbc = find(base_clusters_present == base_clusters_selected(1));
      set(gcbo, 'value', fbc);
   end
      
elseif gcbo == handles(7), % select blocks
   
   str = get(handles(7), 'string');
   selected_blocks = str2vec(str);
   maxblock = max(SpikeInfo.BlockNumber);
   if max(selected_blocks) > maxblock,
      str = strcat('1:', num2str(maxblock));
      set(handles(7), 'string', str);
   end
   
elseif gcbo == handles(8), %select trials
   
   str = get(handles(8), 'string');
   selected_trials = str2vec(str);
   total_trials = length(SpikeInfo.TrialStartTimes);
   if max(selected_trials) > total_trials,
      str = strcat('1:', num2str(total_trials));
      set(handles(8), 'string', str);
   end
   
elseif gcbo == menuhandles(10), % compile group file
   
   filtermask = strcat(dir_grp, '*.txt');
   [grouptextfile pathname] = uigetfile(filtermask, 'Select Text file containing Group info');
   if pathname == 0,
      return
   end
   compile_groupfile([pathname grouptextfile]);
   filtermask = strcat(dir_grp, '*_grp.mat');
   saved_group_dir = dir(filtermask);
   found_groups = {saved_group_dir.name};
   found_groups = char(found_groups);
   for i = 1:size(found_groups, 1),
      trunc_found_groups(i, :) = strrep(found_groups(i, :), '_grp.mat', '        ');
   end
   groupstr = strvcat('All Conditions', 'Each Condition Alone', trunc_found_groups);
   set(handles(10), 'string', groupstr);
   
elseif gcbo == menuhandles(15), % Over-all Behavior: Pie-Chart and Bar Graph
   
   clear c groupc
   if isempty(SpikeInfo),
      [SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spk_read;
   end
   
   errorcodes = strvcat('Correct', 'No Response', 'Late', 'Broke Fixation', 'No Fixation', 'Early', 'Incorrect', 'Before First Test', 'No Bar Down');
   for i = 1:9,
      c(i) = sum(SpikeInfo.ResponseError == (i-1));
   end
   f = find(c);
   c = c(f);
   ec = errorcodes(f, :);
   
   figure
   fname = strcat(filename, ': Behavior');
   set(gcf, 'tag', 'spk', 'menubar', 'none');
   set(gcf, 'position', [100 50 500 520], 'numbertitle', 'off', 'name', fname);
   subplot(3, 3, [1:2 4:5]);
   pie(c)
   legh = legend(ec);
   set(legh, 'position', [.63 .55 .33 .2]);
   title('Over-All Performance');
   
   filtermask = strcat(dir_grp, '*_grp.mat');
   saved_group_dir = dir(filtermask);
   found_groups = {saved_group_dir.name};
   found_groups = char(found_groups);

   groupselect = get(handles(10), 'value');
   if groupselect > 1,
      if groupselect > 2,
         groupfile = deblank(found_groups(groupselect-2, :));
         load([dir_grp groupfile]);
      elseif groupselect == 2,
         cp = unique(cond_no);
         condgrps = cp;
         groupnames = num2str(cp);
      end
      t = group_conds(condgrps, 4);
      
      for i = 1:size(condgrps, 1),
         tot = sum(t == i);
         cfrac = sum(t == i & response_error == 0);
         groupc(i) = cfrac/tot;
      end
   
      subplot(3, 1, 3)
      bh = bar(groupc);
      title('Fraction Correct by Condition Grouping');
      ax = axis;
      axis([ax(1) ax(2) 0 1])
      for i = 1:size(condgrps, 1),
         h = text(i, 0.05, groupnames(i, :));
         set(h, 'rotation', 90, 'color', [1 1 1], 'fontweight', 'bold');
      end
      set(gca, 'xticklabel', ' ');
      
   else
      h = uicontrol('style', 'frame', 'position', [75 100 350 50]);
      h = uicontrol('style', 'text', 'position', [76 101 348 35], 'string', 'No Condition Grouping Selected for Break-Down', 'fontsize', 12);
   end
   
   
elseif gcbo == menuhandles(18) | gcbo == menuhandles(19), % plot behavior across trials
   
   clear c
   if isempty(SpikeInfo),
      [SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spk_read;
   end
   
   filtermask = strcat(dir_grp, '*_grp.mat');
   saved_group_dir = dir(filtermask);
   found_groups = {saved_group_dir.name};
   found_groups = char(found_groups);

   groupselect = get(handles(10), 'value');
   if groupselect > 2,
      groupfile = deblank(found_groups(groupselect-2, :));
      load([dir_grp groupfile]);
   elseif groupselect == 1,
      cp = unique(SpikeInfo.ConditionNumber);
      condgrps = cp';
      groupnames = 'All Conditions';
   elseif groupselect == 2,
      cp = unique(SpikeInfo.ConditionNumber);
      condgrps = cp;
      groupnames = num2str(cp);
   end
   
   t = group_conds(SpikeInfo.ConditionNumber, condgrps);
   
   if gcbo == menuhandles(18),
      for i = 1:size(condgrps, 1),
         f = find(t == i);
         if ~isempty(f),
            re = SpikeInfo.ResponseError(f);
            c(1:length(f), i) = (re == 0);
         end
      end
   else
      for i = 1:size(condgrps, 1),
         f = find(t == i);
         if ~isempty(f),
            re = SpikeInfo.ResponseError(f);
            f2 = find(re == 0 | re == 6);
            re = re(f2);
            c(1:length(f2), i) = (re == 0);
         end
      end     
   end
   
   fn = SpikeInfo.FileName;
   slash = find(fn == filesep);
   if ~isempty(slash),
      fn = fn(max(slash)+1:length(fn));
   end
   
   plotprep;
   lineh = plot(c);
   set(lineh, 'linewidth', 1.5, 'color', [.5 .3 .3]);
   set(gca, 'xlim', [0 length(c)], 'box', 'on');
   if gcbo == menuhandles(18),
      xlabel('Trial #');
   else
      xlabel('Trial Index');
   end
   ylabel('Fraction Correct');
   title(strcat(fn, ': Behavioral Performance'));
   set(findobj(gcf, 'tag', 'WINDOW SIZE'), 'string', '50');
   plotprep('smooth');
   legh = legend(groupnames);
   legpos = get(legh, 'position');
   set(legh, 'position', [.7 .05 legpos(3) legpos(4)]);
      
   
elseif gcbo == handles(15) | gcbo == handles(100), % view codes
   
   flow = 0;
   
   if gcbo == handles(15), % Create view codes window
      if isempty(SpikeInfo), % no file selected
         return
      end
      
      f = findobj('name', 'Behavioral Codes');
      if ~isempty(f),
         figure(f);
         return
      end
      
      figure;
      set(gcf, 'tag', 'spk');
      set(gcf, 'position', [300 100 300 400], 'numbertitle', 'off', 'name', 'Behavioral Codes', 'resize', 'off', 'menubar', 'none');
      h0 = uicontrol('style', 'frame', 'position', [70 328 160 65], 'backgroundcolor', [.65 .5 .5]);
      h1 = uicontrol('style', 'pushbutton', 'position', [100 10 100 25], 'string', 'Close', 'callback', 'delete(gcf)');
      h2 = uicontrol('style', 'frame', 'position', [20 45 260 280]);
      h3 = uicontrol('style', 'text', 'position', [73 370 95 15], 'string', 'Trial Number:', 'foregroundcolor', [1 1 1], 'backgroundcolor', [.65 .5 .5]);
      h4 = uicontrol('style', 'frame', 'position', [89 332 122 31]); 
      handles(100) = uicontrol('style', 'edit', 'position', [170 368 40 20], 'callback', 'spk', 'string', '1');
      handles(101) = uicontrol('style', 'listbox', 'position', [21 46 258 278]);
      flow = 1;
   end
   
   if gcbo == handles(100) | flow == 1, % update view codes window
      trialnum = str2num(get(handles(100), 'string'));
      
      total_trials = length(SpikeInfo.TrialStartTimes);
      if trialnum > total_trials,
         trialnum = total_trials;
         set(handles(100), 'string', num2str(trialnum));
      elseif trialnum < 1,
         trialnum = 1;
         set(handles(100), 'string', '1');
      end
      
      errorcodes = strvcat('Correct', 'No Response', 'Late', 'Broke Fixation', 'No Fixation', 'Early', 'Incorrect', 'Before First Test', 'No Bar Down');     
      cstring = errorcodes(SpikeInfo.ResponseError(trialnum)+1, :);
      
      condstring = strcat('Condition #', num2str(SpikeInfo.ConditionNumber(trialnum)));
      h1 = uicontrol('style', 'text', 'position', [90 347 120 15], 'string', condstring);
      h2 = uicontrol('style', 'text', 'position', [90 333 120 15], 'string', cstring);
      
      lc = list_codes(trialnum);
      for i = 1:size(lc, 1),
         temptext = lc(i, :);
         txt{i} = strrep(temptext, sprintf('\t'), '         ');
      end
      set(handles(101), 'horizontalalignment', 'left', 'string', txt);
   end
   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%% Analysis Functions Jump-off: %%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif gcbo == handles(21),    
   
   if isempty(SpikeInfo), % no file selected
      return
   end
   
   clusindex = get(handles(2), 'value');
   if length(clusindex) > 1,
      crit.desired_cluster = round(SpikeInfo.NeuronID(clusindex(1))./100)*100;
   else
      crit.desired_cluster = SpikeInfo.NeuronID(clusindex);
   end
   crit.start_code = code_reference(get(handles(3), 'value'));
   crit.end_code = code_reference(get(handles(4), 'value'));
   crit.start_offset = str2num(get(handles(5), 'string'));
   crit.end_offset = str2num(get(handles(6), 'string'));
   if crit.start_code == crit.end_code & crit.start_offset == crit.end_offset,
      error('****** No valid epoch selected ******');
      return
   end
   
   desired_blocks = str2vec(get(handles(7), 'string'));
   trials_in_sel_blocks = find(ismember(SpikeInfo.BlockNumber, desired_blocks));
   desired_trials = str2vec(get(handles(8), 'string'));
   desired_trials = intersect(desired_trials', trials_in_sel_blocks);
   total_trials = length(SpikeInfo.TrialStartTimes);
   if max(desired_trials) > total_trials,
   	desired_trials = desired_trials(find(desired_trials <= length(total_trials)));
	end
   correctness = get(handles(9), 'value');
   switch correctness,
	case 1,
   	desired_corrects = 0; % corrects only
	case 2,
   	desired_corrects = 6; % incorrect responses only
	case 3,
   	desired_corrects = [0 6]; % attempts -- correct and incorrect
	case 4,
   	desired_corrects = 0:6; % all response_errors
   end
   crit.desired_trials = intersect(find(ismember(SpikeInfo.ResponseError, desired_corrects)), desired_trials);
   crit.correctness = correctness;
   
   filtermask = strcat(dir_grp, '*_grp.mat');
   saved_group_dir = dir(filtermask);
   found_groups = {saved_group_dir.name};
   found_groups = char(found_groups);

   groupselect = get(handles(10), 'value');
   if groupselect > 2,
      groupfile = deblank(found_groups(groupselect-2, :));
      load([dir_grp groupfile]);
   elseif groupselect == 1,
      cp = unique(SpikeInfo.ConditionNumber);
      condgrps = cp';
      groupnames = 'All Conditions';
   elseif groupselect == 2,
      cp = unique(SpikeInfo.ConditionNumber);
      condgrps = cp;
      groupnames = num2str(cp);
   end
   crit.condgrps = condgrps;
   crit.groupnames = groupnames;
   crit.groupselect = groupselect;
   
   chosen_analysis = get(handles(20), 'value');
   chosen_analysis = analysis_callbacks(chosen_analysis, :);
   chosen_analysis = strcat(chosen_analysis, '(crit)');
   eval(chosen_analysis);
   return
   
elseif gcbo == handles(19),
   
   f = findobj('name', 'SPK info');
   if ~isempty(f),
      figure(f);
      return
   end
   if isempty(findobj('name', 'About SpikeTools')),
	   figure;
	   set(gcf, 'position', [300 80 240 450], 'numbertitle', 'off', 'menubar', 'none', 'resize', 'off', 'name', 'About SpikeTools');
	   ll2 = '     Last modified March, 2001';
	   l1 = '              Contacts:';
	   l2 = ' ';
	   l3a = '            Wael Asaad';
	   l3A = '          wfasaad@mit.edu';
	   l3b = '            Mark Histed';
	   l3B = '          histed@mit.edu';
	   l3c = '           Gregor Rainer';
	   l3C = '          grainer@mit.edu';
	   l3d = '          (617) 252-1469';
	   l4 = '     in the lab of Earl K. Miller';
      l5 = 'Dept. of Brain and Cognitive Sciences';
      l5a = ' &  Center for Learning and Memory';
	   l6 = '               M.I.T.';
	   txt = strvcat(ll2, l2, l1, l2, l3a, l3A, l2, l3b, l3B, l2, l3c, l3C, l2, l3d, l2, l4, l2, l5, l5a, l6);
	   h = uicontrol('style', 'frame', 'position', [10 110 220 280], 'backgroundcolor', [0 0 0]);
      hh = uicontrol('style', 'text', 'position', [10 110 220 270], 'string', txt, 'buttondownfcn', 'delete(gcf)', 'foregroundcolor', [1 1 1], 'backgroundcolor', [0 0 0]);
      hhh = subplot('position', [.038 .04 .915 .24]);
      image(imread('3monkeys.jpg'));
      axis off;
      hhhh = subplot('position', [.038 .85 .915 .13]);
      image(imread('aboutheader.jpg'));
      axis off;
   end
   try
	   load('bartwav.mat');
      sound(double(wav.y)/1000, wav.fs, wav.bits);
   end
end

if ~isempty(filename) & isempty(find(filename == filesep)),
   filename = strcat(dir_spk, filename);
end
spk_variables = struct('handles', handles, 'menuhandles', menuhandles, 'analysis_callbacks', analysis_callbacks, 'values', values, 'filename', filename, 'code_reference', code_reference);
fig = findobj('tag', 'spkmenu');
set(fig, 'userdata', spk_variables);
