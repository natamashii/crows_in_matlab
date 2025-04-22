function SpikeConfig = spiketools_config(varargin)

spk_tools_dir = which('spk');
f = find(spk_tools_dir == '\');
spk_tools_dir = spk_tools_dir(1:max(f));
cfgfile = strcat(spk_tools_dir, 'spk_cfg.mat');

if exist(cfgfile) == 2,
   load('spk_cfg.mat');
   if ~isempty(varargin) & varargin{1} == 0, 
      return; 
   end
else % if doesn't exist, create default config file...
   SpikeConfig.Investigator = 'Unspecified';
   SpikeConfig.DefaultStartCode = 23;
   SpikeConfig.DefaultEndCode = 24;
   SpikeConfig.DefaultStartOffset = 0;
   SpikeConfig.DefaultEndOffset = 0;
   SpikeConfig.DefaultDuration = 1000;
   SpikeConfig.DefaultSmoothWindow = 50;
   SpikeConfig.StartTrialCode = 9;
   SpikeConfig.EndTrialCode = 18;
   SpikeConfig.StartCodeOccurrence = 1;
   SpikeConfig.IncludeLFP = 1;
   SpikeConfig.UseNexCodes = 1;
   SpikeConfig.LoadSpikes = 1;
   SpikeConfig.LoadLFP = 0;
   SpikeConfig.EyeUnitsPerDegree = 200;
   SpikeConfig.StartEyeDataCode = 100;
   SpikeConfig.EndEyeDataCode = 101;
   SpikeConfig.DefaultNoLocationCode = -99999;
   save(cfgfile, 'SpikeConfig');
   disp(sprintf('Created Default SpikeTools Configuration File: %s', cfgfile));
end

windowname = 'SpikeTools Configuration';

f = findobj('name', windowname);
if ~isempty(f),
   figure(f);
end

if isempty(f),
	fig = figure;
   set(gcf, 'numbertitle', 'off', 'name', windowname, 'menubar', 'none', 'position', [200 100 460 450]);
   bg = get(gcf, 'color');
   t(1) = uicontrol('style', 'text', 'position', [20 407 100 20], 'string', 'Investigator', 'backgroundcolor', bg, 'horizontalalignment', 'right');
   h(1) = uicontrol('style', 'edit', 'position', [130 410 180 20], 'backgroundcolor', [1 1 1], 'tag', 'owner_id', 'string', SpikeConfig.Investigator);
   
   %Default Display Options
   misc(1) = uicontrol('style', 'frame', 'position', [20 280 310 120]);
   fbg = get(misc(1), 'backgroundcolor');
   
   t(2) = uicontrol('style', 'text', 'position', [30 375 250 20], 'backgroundcolor', fbg, 'string', 'Default Display Options', 'fontsize', 10, 'fontweight', 'bold', 'horizontalalignment', 'left');   
   t(3) = uicontrol('style', 'text', 'position', [25 347 75 20], 'string', 'Start Code');
   t(4) = uicontrol('style', 'text', 'position', [25 317 75 20], 'string', 'Start Offset (ms)');
   t(5) = uicontrol('style', 'text', 'position', [25 287 75 20], 'string', 'Duration (ms)');
   h(2) = uicontrol('style', 'edit', 'position', [110 350 40 20], 'tag', 'start_code', 'string', SpikeConfig.DefaultStartCode);
   h(3) = uicontrol('style', 'edit', 'position', [110 320 40 20], 'tag', 'start_offset', 'string', SpikeConfig.DefaultStartOffset);
   h(4) = uicontrol('style', 'edit', 'position', [110 290 40 20], 'tag', 'duration', 'string', SpikeConfig.DefaultDuration);
   
   t(6) = uicontrol('style', 'text', 'position', [165 347 100 20], 'string', 'End Code');
   t(7) = uicontrol('style', 'text', 'position', [165 317 100 20], 'string', 'End Offset (ms)');
   t(8) = uicontrol('style', 'text', 'position', [165 287 100 20], 'string', 'Smooth Window (ms)');
   h(5) = uicontrol('style', 'edit', 'position', [275 350 40 20], 'tag', 'end_code', 'string', SpikeConfig.DefaultEndCode);
   h(6) = uicontrol('style', 'edit', 'position', [275 320 40 20], 'tag', 'end_offset', 'string', SpikeConfig.DefaultEndOffset);
   h(7) = uicontrol('style', 'edit', 'position', [275 290 40 20], 'tag', 'smooth_window', 'string', SpikeConfig.DefaultSmoothWindow);
   
   set(t(3:8), 'backgroundcolor', fbg, 'horizontalalignment', 'right');
   set(h(2:7), 'backgroundcolor', [1 1 1]);
   
   %Data Format
   misc(2) = uicontrol('style', 'frame', 'position', [20 60 230 210]);
   fbg = get(misc(2), 'backgroundcolor');
   
   t(9) = uicontrol('style', 'text', 'position', [30 245 180 20], 'backgroundcolor', fbg, 'string', 'Data Format', 'fontsize', 10, 'fontweight', 'bold', 'horizontalalignment', 'left');
   t(10) = uicontrol('style', 'text', 'position', [25 217 120 20], 'string', 'Start Trial Code');
   t(11) = uicontrol('style', 'text', 'position', [25 187 120 20], 'string', 'End Trial Code');
   t(12) = uicontrol('style', 'text', 'position', [33 155 170 20], 'string', 'Include LFP data in SPK file');
   t(13) = uicontrol('style', 'text', 'position', [33 125 170 20], 'string', 'Use Behavioral Codes from NEX file');
   h(8) = uicontrol('style', 'edit', 'position', [155 220 40 20], 'tag', 'start_trial_code', 'string', SpikeConfig.StartTrialCode);
   h(9) = uicontrol('style', 'edit', 'position', [155 190 40 20], 'tag', 'end_trial_code', 'string', SpikeConfig.EndTrialCode);
   h(10) = uicontrol('style', 'checkbox', 'position', [215 158 20 20], 'tag', 'IncludeLFP', 'value', SpikeConfig.IncludeLFP);
   h(11) = uicontrol('style', 'checkbox', 'position', [215 128 20 20], 'tag', 'UseNexCodes', 'value', SpikeConfig.UseNexCodes);
   set(t(10:13), 'backgroundcolor', fbg', 'horizontalalignment', 'right');
   set(h(8:9), 'backgroundcolor', [1 1 1]);
   
   t(20) = uicontrol('style', 'text', 'position', [30 71 140 40], 'string', 'Start Code Occurrence for merging NEX and CORTEX');
   h(16) = uicontrol('style', 'edit', 'position', [182 87 40 20], 'tag', 'start_code_occurrence', 'string', SpikeConfig.StartCodeOccurrence);
   set(t(20), 'backgroundcolor', fbg, 'horizontalalignment', 'right');
   set(h(16), 'backgroundcolor', [1 1 1]);
   
   %EOG Settings
   misc(3) = uicontrol('style', 'frame', 'position', [260 150 190 120]);
   fbg = get(misc(3), 'backgroundcolor');
   
   t(15) = uicontrol('style', 'text','position', [270 245 150 20], 'backgroundcolor', fbg, 'string', 'Eye Data Settings', 'fontsize', 10, 'fontweight', 'bold', 'horizontalalignment', 'left');
   t(16) = uicontrol('style', 'text', 'position', [270 217 120 20], 'string', 'Eye units per degree');
   t(17) = uicontrol('style', 'text', 'position', [270 187 120 20], 'string', 'Start Eye Code');
   t(18) = uicontrol('style', 'text', 'position', [270 157 120 20], 'string', 'End Eye Code');
   h(13) = uicontrol('style', 'edit', 'position', [400 220 40 20], 'tag', 'eog_units_per_degree', 'string', SpikeConfig.EyeUnitsPerDegree);
   h(14) = uicontrol('style', 'edit', 'position', [400 190 40 20], 'tag', 'start_eog_code', 'string', SpikeConfig.StartEyeDataCode);
   h(15) = uicontrol('style', 'edit', 'position', [400 160 40 20], 'tag', 'end_eog_code', 'string', SpikeConfig.EndEyeDataCode);
   
   set(t(15:18), 'backgroundcolor', fbg, 'horizontalalignment', 'right');
   set(h(13:15), 'backgroundcolor', [1 1 1]);
   
   %Reading Data Files
   misc(4) = uicontrol('style', 'frame', 'position', [260 60 190 83]);
   fbg = get(misc(4), 'backgroundcolor');
   t(23) = uicontrol('style', 'text', 'position', [280 121 150 20], 'string', 'Reading Data', 'fontsize', 10, 'fontweight', 'bold', 'horizontalalignment', 'center');
   t(24) = uicontrol('style', 'text', 'position', [285 103 140 20], 'string', 'When calling "spk_read":');
   t(25) = uicontrol('style', 'text', 'position', [268 82 140 20], 'string', 'Load all spikes into memory');
   h(18) = uicontrol('style', 'checkbox', 'position', [416 85 20 20], 'value', SpikeConfig.LoadSpikes, 'tag', 'LoadSpikes');
   t(26) = uicontrol('style', 'text', 'position', [268 62 140 20], 'string', 'Load LFP into memory');
   h(19) = uicontrol('style', 'checkbox', 'position', [416 64 20 20], 'value', SpikeConfig.LoadLFP, 'tag', 'LoadLFP');
   set(t(23:26), 'backgroundcolor', fbg);
   set(t(25:26), 'horizontalalignment', 'right');
   
   %Recording Locations
  	misc(5) = uicontrol('style', 'frame', 'position', [340 280 110 120]);
  	fbg = get(misc(5), 'backgroundcolor');
   t(21) = uicontrol('style', 'text', 'position', [350 360 90 30], 'string', 'Recording Locations', 'fontsize', 10, 'fontweight', 'bold');
   t(22) = uicontrol('style', 'text', 'position', [350 320 90 30], 'string', 'No Location-Entry Code');
   h(17) = uicontrol('style', 'edit', 'position', [370 295 50 20], 'tag', 'default_no_location_code', 'string', SpikeConfig.DefaultNoLocationCode);
   set(t(22), 'backgroundcolor', fbg);
   set(h(17), 'backgroundcolor', [1 1 1]);
   
   savebutton = uicontrol('style', 'pushbutton', 'position', [120 15 230 30], 'string', 'Save Settings', 'fontsize', 10, 'fontweight', 'bold', 'tag', 'savebutton', 'callback', 'spiketools_config;', 'backgroundcolor', [.65 .5 .5]);
   helpbutton = uicontrol('style', 'pushbutton', 'position', [340 410 110 20], 'string', 'Help', 'fontsize', 8, 'tag', 'helpbutton', 'fontangle', 'italic', 'callback', 'web http://www.mit.edu/~wfasaad/spkguide/configmenu.html');
   
elseif ismember(gcbo, get(gcf, 'children'))
   
   if get(gcbo, 'tag') == 'savebutton',
      
      SpikeConfig.Investigator = get(findobj(gcf, 'tag', 'owner_id'), 'string');
      SpikeConfig.DefaultStartCode = str2num(get(findobj(gcf, 'tag', 'start_code'), 'string'));
      SpikeConfig.DefaultEndCode = str2num(get(findobj(gcf, 'tag', 'end_code'), 'string'));
      SpikeConfig.DefaultStartOffset = str2num(get(findobj(gcf, 'tag', 'start_offset'), 'string'));
      SpikeConfig.DefaultEndOffset = str2num(get(findobj(gcf, 'tag', 'end_offset'), 'string'));
      SpikeConfig.DefaultDuration = str2num(get(findobj(gcf, 'tag', 'duration'), 'string'));
      SpikeConfig.DefaultSmoothWindow = str2num(get(findobj(gcf, 'tag', 'smooth_window'), 'string'));
      SpikeConfig.StartTrialCode = str2num(get(findobj(gcf, 'tag', 'start_trial_code'), 'string'));
      SpikeConfig.EndTrialCode = str2num(get(findobj(gcf, 'tag', 'end_trial_code'), 'string'));
      SpikeConfig.IncludeLFP = get(findobj(gcf, 'tag', 'IncludeLFP'), 'value');
      SpikeConfig.UseNexCodes = get(findobj(gcf, 'tag', 'UseNexCodes'), 'value');
      SpikeConfig.LoadSpikes = get(findobj(gcf, 'tag', 'LoadSpikes'), 'value');
      SpikeConfig.LoadLFP = get(findobj(gcf, 'tag', 'LoadLFP'), 'value');
      SpikeConfig.EyeUnitsPerDegree = str2num(get(findobj(gcf, 'tag', 'eog_units_per_degree'), 'string'));
      SpikeConfig.StartEyeDataCode = str2num(get(findobj(gcf, 'tag', 'start_eog_code'), 'string'));
      SpikeConfig.EndEyeDataCode = str2num(get(findobj(gcf, 'tag', 'end_eog_code'), 'string'));
      SpikeConfig.StartCodeOccurrence = str2num(get(findobj(gcf, 'tag', 'start_code_occurrence'), 'string'));
      SpikeConfig.DefaultNoLocationCode = str2num(get(findobj(gcf, 'tag', 'default_no_location_code'), 'string'));
      
      save(cfgfile, 'SpikeConfig');
      close(gcf);
      disp('Updated spk_cfg.mat');
      
   elseif get(gcbo, 'tag') == 'helpbutton',
      
      edit('spk_cfg.txt');
      
   end
   
end


