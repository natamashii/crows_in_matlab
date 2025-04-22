function output = dataview(varargin)
% SYNTAX:
%		output = dataview(start_time, end_time);
%
% This function plots spike rasters and LFP signals (if present) for the selected time
% range, "start_time" to "end_time" (in seconds).
%
% created 2/15/2001  --WA
% last modified 3/24/2001 --WA

[SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spikestat;
if isempty(SpikeInfo),
   [SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spk_read;
end

axisXpos = 0.1;
axisXsize = 0.87;

if isempty(varargin),
   start_time = 0;
   end_time = 10;
elseif isstr(varargin{1}),
   callstring = varargin{1};
   if strmatch(callstring, 'slide'),
      axpos = get(gca, 'position');
      xtimes = str2num(get(gca, 'xticklabel'));
      xlim = [min(xtimes) max(xtimes)];
      duration = diff(xlim);
      xshift = -(duration*((axpos(1) - axisXpos)/axisXsize));
      oldstart = xlim(1);
      oldend = xlim(2);
      start_time = oldstart + xshift;
      end_time = oldend + xshift;
      if start_time < 0,
         start_time = 0;
         end_time = start_time + duration;
      end
      start_time = round(10*start_time)/10;
      end_time = round(10*end_time)/10;
      set(findobj(gcf, 'tag', 'StartTime'), 'string', num2str(start_time));
      set(findobj(gcf, 'tag', 'EndTime'), 'string', num2str(end_time));
   else
      startbox = findobj(gcf, 'tag', 'StartTime');
	   endbox = findobj(gcf, 'tag', 'EndTime');
	   oldstart = str2num(get(startbox, 'string'));
	   oldend = str2num(get(endbox, 'string'));
	   duration = oldend - oldstart;
	   if isempty(strmatch(callstring, 'redraw')),
		   if strmatch(callstring, 'up'),
			   start_time = oldend;
		      end_time = start_time + duration;
		   elseif strmatch(callstring, 'down'),
		      end_time = oldstart;
		      start_time = end_time - duration;
		      if start_time < 0,
		         start_time = 0;
		         end_time = start_time + duration;
		      end
		   end
		   set(startbox, 'string', num2str(start_time));
	      set(endbox, 'string', num2str(end_time));
	      return
	   else
	      start_time = oldstart;
	      end_time = oldend;
	   end
   end
else
   start_time = varargin{1};
   end_time = varargin{2};
end

if end_time <= start_time,
   error('***** End Time must follow Start Time ******');
   return;
end

datatypes = cat(1, SpikeVarHeader.Type);
neuron_indx = find(datatypes == 0);
lfp_indx = find(datatypes == 5);

neurons = SpikeInfo.NeuronID;
lfpchannels = SpikeInfo.LFPID;

cmap = hsv(64);

neuroelectrodes = 100*floor(neurons/100);
minelectrode = min([min(lfpchannels) min(neuroelectrodes)]);
maxelectrode = max([max(lfpchannels) max(neuroelectrodes)]);
freq = SpikeFileHeader.Frequency;
sigcount = 0;
duration = round(1000*(end_time - start_time)) + 1;
totsignals = length(neuron_indx) + length(lfp_indx);
spikematrix = zeros(totsignals, duration);
lfpmatrix = zeros(totsignals, duration);
type_indx = zeros(totsignals, 1);
wfreq = [];
lfp = [];

fid = fopen(SpikeInfo.FileName, 'r');
for i = minelectrode:100:maxelectrode,
   fl = find(lfpchannels == i);
   if ~isempty(fl),
      for ii = 1:length(fl),
         varnum = lfp_indx(fl(ii));
         if SpikeVarHeader(varnum).Count > 0,
         	sigcount = sigcount + 1;
         	fseek(fid, SpikeVarHeader(varnum).DataOffset, -1);
         	wfreq = SpikeVarHeader(varnum).WFrequency;
         	doffset = round(wfreq * start_time);
         	fseek(fid, doffset, 0);
         	lfp = fread(fid, duration*wfreq/1000, 'int16')*SpikeVarHeader(varnum).ADtoMV;
         	lfpmatrix(sigcount, 1:length(lfp)) = lfp';
            type_indx(sigcount) = 2;
         else
            totsignals = totsignals - 1;
         end
      end
   end
   fn = find(neuroelectrodes == i);
   if ~isempty(fn),
      for ii = 1:length(fn),
         sigcount = sigcount + 1;
         varnum = neuron_indx(fn(ii));
         fseek(fid, SpikeVarHeader(varnum).DataOffset, -1);
         spiketimes = fread(fid, SpikeVarHeader(varnum).Count, 'int32')/freq;
         spikes = round(1000*(spiketimes(find(spiketimes >= start_time & spiketimes < end_time)) - start_time)) + 1;
         spikematrix(sigcount, spikes) = 1;
         type_indx(sigcount) = 1;
      end
   end   
end
fclose(fid);

%get behavioral codes
f = find(SpikeInfo.CodeTimes >= start_time & SpikeInfo.CodeTimes < end_time);
if ~isempty(f),
   codetimes = round(1000*(SpikeInfo.CodeTimes(f) - start_time)) + 1;
   codenumbers = SpikeInfo.CodeNumbers(f);
else
   codetimes = [];
   codenumbers = [];
end


%Plotting:
if ~isempty(varargin) & isstr(varargin{1}) & (~isempty(strmatch(varargin{1}, 'redraw')) | ~isempty(strmatch(varargin{1}, 'slide'))),
   delete(gca);
else
   figure;
	fname = SpikeInfo.FileName;
	f = find(fname == filesep);
	if ~isempty(f),
	   fname = fname(max(f)+1:length(fname));
   end
   fname = sprintf('Dataview %s', fname);
	set(gcf, 'position', [50 50 900 600], 'color', [.7 .65 .65], 'numbertitle', 'off', 'menubar', 'none', 'name', fname);
end
subplot('position', [axisXpos .25 axisXsize .7]);
labeloffset = -.01;
[sy sx] = find(spikematrix);
pspikes = plot(sx, sy, 'ko');
set(pspikes, 'markersize', 1.7, 'markerfacecolor', [.5 .5 .5]);
hold on;
f = find(type_indx == 1);
for i = 1:length(f),
   pspiketext(i) = text((labeloffset*duration), f(i),SpikeVarHeader(neuron_indx(i)).Name);
end
set(pspiketext, 'fontsize', 10, 'horizontalalignment', 'right');

if ~isempty(wfreq),
	f = find(type_indx == 2);
	sample_interval = 1000/wfreq; %use last instance of wfreq because all should be the same...
	xtime = 1:sample_interval:(duration+1-sample_interval);

	for i = 1:length(f),
	   onelfp = lfpmatrix(f(i), :);
	   if max(onelfp) > 0,
		   onelfp = (onelfp/max(onelfp)) + f(i);
	      plfp(i) = plot(xtime, onelfp, 'k');
	   end
	   plfptext(i) = text((labeloffset*duration), f(i), SpikeVarHeader(lfp_indx(i)).Name);
	end
	set(plfptext, 'fontsize', 10, 'horizontalalignment', 'right');
end
   
if ~isempty(codetimes),
	for i = 1:length(codetimes),
      pcode(i) = line([codetimes(i) codetimes(i)], [0 (totsignals + 1)]);
      pcodepos(i) = codetimes(i);
      if (i > 1) & ((pcodepos(i) - pcodepos(i-1)) < (.015*duration)),
         pcodepos(i) = pcodepos(i-1) + (.015*duration);
      end
      pcodetext(i) = text(pcodepos(i), -(totsignals/100), num2str(codenumbers(i)));
      col = cmap(2*rem(codenumbers(i), 32)+1, :);
      set(pcode(i), 'color', col);
      set(pcodetext(i), 'color', col);
   end
   set(pcodetext, 'fontsize', 8, 'rotation', 90);
   set(pcode, 'buttondownfcn', 'selectmoveresize; watchon; dataview(''slide'')');
end
set(gca, 'xlim', [0 duration], 'ylim', [0 (totsignals + 1)], 'ydir', 'reverse', 'ytick', []);
xtick = get(gca, 'xtick');
xtick = (xtick/1000) + start_time;
set(gca, 'xticklabel', xtick);
xlab = xlabel('Time (seconds)');

%Trial Marker
trial = find(SpikeInfo.TrialStartTimes > start_time & SpikeInfo.TrialStartTimes < end_time);
if ~isempty(trial),
   for i = 1:length(trial),
		ts = SpikeInfo.TrialStartTimes(trial(i));
	   xpos = round(1000*(ts - start_time))+1;
	   ypos = 1.025*diff(get(gca, 'ylim'));
      hh(i) = text(xpos, ypos, sprintf('%i', trial(i)));
   end
   set(hh, 'color', [1 0 0], 'fontsize', 16, 'fontweight', 'bold', 'horizontalalignment', 'center');
end

%uicontrols
if ~isempty(varargin) & isstr(varargin{1}) & (~isempty(strmatch(varargin{1}, 'redraw')) | ~isempty(strmatch(varargin{1}, 'slide'))),
   set(findobj(gcf, 'tag', 'StartTime'), 'string', num2str(start_time));
   set(findobj(gcf, 'tag', 'EndTime'), 'string', num2str(end_time));
   watchoff;
else
	h(1) = uicontrol('style', 'frame', 'position', [300 10 300 90], 'backgroundcolor', [1 1 1]);
	h(2) = uicontrol('style', 'pushbutton', 'position', [400 25 100 30], 'string', 'Update Graph', 'backgroundcolor', [.65 .5 .5], 'callback', 'watchon; dataview(''redraw'');');
	h(3) = uicontrol('style', 'edit', 'position', [385 65 55 22], 'string', num2str(start_time), 'backgroundcolor', [0 0 0], 'foregroundcolor', [1 1 1], 'tag', 'StartTime');
	h(4) = uicontrol('style', 'edit', 'position', [465 65 55 22], 'string', num2str(end_time), 'backgroundcolor', [0 0 0], 'foregroundcolor', [1 1 1], 'tag', 'EndTime');
	h(5) = uicontrol('style', 'text', 'position', [345 65 35 20], 'string', 'From', 'backgroundcolor', [1 1 1]);
	h(6) = uicontrol('style', 'text', 'position', [438 65 25 20], 'string', 'to', 'backgroundcolor', [1 1 1]);
	h(7) = uicontrol('style', 'text', 'position', [525 65 40 20], 'string', 'seconds', 'backgroundcolor', [1 1 1]);
	h(8) = uicontrol('style', 'pushbutton', 'position', [510 25 50 30], 'string', '>>', 'backgroundcolor', [.65 .5 .5], 'callback', 'dataview(''up'')');
   h(9) = uicontrol('style', 'pushbutton', 'position', [340 25 50 30], 'string', '<<', 'backgroundcolor', [.65 .5 .5], 'callback', 'dataview(''down'')');
end

