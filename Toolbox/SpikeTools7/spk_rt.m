function spk_rt(varargin)
% histograms of reaction times
% can be called from the SPK main menu under "Behavior"
% note that if the SPK main menu is active, this routine will use 
% the correctness level specified there.
%
% created 7/10/98  --WA
% last modified 2/20/2001 --WA

directories;

if ~strcmp(get(gcf, 'tag'), 'spk_rt'),
   if isempty(varargin),
		[SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spk_read;
	elseif varargin{1} == 0,
	   [SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spikestat;
	else
	   [SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spk_read(varargin{1});
	end
   load('codes.mat');
   present_codes_index = find(ismember(code_number, unique(SpikeInfo.CodeNumbers)));
   for i = 1:length(present_codes_index),
      description = code_descrip(present_codes_index(i), :);
      code_matrix(i, 1:length(description)) = description;
      code_reference(i) = code_number(present_codes_index(i));
   end
   figure
   filename = SpikeInfo.FileName;
   slash = find(filename == filesep);
   if ~isempty(slash),
      filename = filename(max(slash)+1:length(filename));
   end
   t = strcat(filename, ':  RTs');
   figdata = struct('filename', filename, 'code_reference', code_reference);
   set(gcf, 'tag', 'spk_rt', 'position', [300 200 350 350], 'numbertitle', 'off', 'menubar', 'none', 'name', t, 'userdata', figdata);
   t1 = uicontrol('style', 'frame', 'position', [15 15 320 100]);
   t2 = uicontrol('style', 'text', 'position', [25 87 150 20], 'string', 'Reaction Code:');
   rth(1) = uicontrol('style', 'popupmenu', 'position', [25 70 150 20], 'string', code_matrix, 'tag', '1');
   t3 = uicontrol('style', 'text','position', [25 42 150 20], 'string', 'Relative to Code:');
   rth(2) = uicontrol('style', 'popupmenu', 'position', [25 25 150 20], 'string', code_matrix, 'tag', '2');
   t4 = uicontrol('style', 'text', 'position', [205 87 120 20], 'string', 'Number of Bins:');
   rth(3) = uicontrol('style', 'edit', 'position', [240 69 50 20], 'string', '30', 'tag', '3', 'callback', 'spk_rt');
   rth(4) = uicontrol('style', 'pushbutton', 'position', [205 24 120 30], 'string', 'Create Plot', 'callback', 'spk_rt', 'backgroundcolor', [.65 .5 .5]);
   subplot(10, 1, 1:6);
   
   if any(code_reference == 4),
      set(rth(1), 'value', find(code_reference == 4));
   elseif any(code_reference == 44),
      set(rth(1), 'value', find(code_reference == 44));
   end
   
   if any(code_reference == 25),
      set(rth(2), 'value', find(code_reference == 25));
   elseif any(code_reference == 23),
      set(rth(2), 'value', find(code_reference == 23));
   end
   
else
   
   watchon;
   f = gcf;
   figdata = get(f, 'userdata');
	[SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spikestat;   code_reference = figdata.code_reference;
   bins = str2num(get(findobj(f, 'tag', '3'), 'string'));
   if isempty(bins), 
      set(findobj(f, 'tag', '3'), 'string', '30');
      bins = 50; 
   end;
   react_code = code_reference(get(findobj(f, 'tag', '1'), 'value'));
   ref_code = code_reference(get(findobj(f, 'tag', '2'), 'value'));
   
   spkmenu = findobj('tag', 'spkmenu');
   if isempty(spkmenu),
      desired_trials = find(SpikeInfo.ResponseError == 0);
   else
      correctness = get(findobj(spkmenu, 'tag', 'correctness'), 'value');
      switch correctness,
      case 1
         desired_trials = find(SpikeInfo.ResponseError == 0);
      case 2
         desired_trials = find(SpikeInfo.ResponseError == 6);
      case 3
         desired_trials = find(SpikeInfo.ResponseError == 0 | response_error == 6);
      case 4
         desired_trials = 1:length(SpikeInfo.StartTrialTimes);
      end
   end
   
   t1 = get_code_time(desired_trials, react_code);
   t2 = get_code_time(desired_trials, ref_code);
   rt = t1 - t2;
   
   figure(f);
   subplot(10, 1, 1:6);
   hist(rt, bins);
   ax = axis;
   txt = text(mean(get(gca, 'xlim')), 1.07 * max(get(gca, 'ylim')), sprintf('Mean RT: %4.2fms', mean(rt)));
   xlabel('Latency (ms)');
   ylabel('Number of Trials');
   set(txt, 'horizontalalignment', 'center');
   watchoff;
end
