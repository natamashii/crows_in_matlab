function view_eyetrace(varargin)
% View eye and eye-velocity traces
% This function can be called from the SPK main menu under "Eye"
%
% created Spring, 1998  --WA
% SpikeTools 7 Version, March, 2001  -WA

SpikeConfig = spiketools_config(0);
[SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spikestat;
total_trials = length(SpikeInfo.TrialStartTimes);

if ~isempty(varargin) & varargin{1} == 1,
   updatefigs;
   return
elseif ~isempty(varargin) & varargin{1} == 2,
   animate;
   return
end

if isempty(findobj('type', 'figure')) | ~strcmp(get(gcf, 'tag'), 'spk_eog') | isempty(gcbo),
   
   if isempty(SpikeInfo.EyeXPos),
      disp('No EOG data found in selected file');
      return
   end
   
   fn = SpikeInfo.FileName;
   slash = find(fn == filesep);
   if ~isempty(slash),
      fn = fn(max(slash)+1:length(fn));
   end
   
   figure;
   set(gcf, 'position', [100 100 600 360], 'numbertitle', 'off', 'menubar', 'none', 'name', sprintf('%s Eye Traces', fn), 'tag', 'spk_eog', 'userdata', SpikeInfo.FileName, 'doublebuffer', 'on');
   if exist('imread') == 2,
	   backgrnd = subplot('position', [0 0 1 1]);
		eyepic = imread('eyes.jpg');
		image(eyepic);
      set(backgrnd, 'handlevisibility', 'off');
   end

   hframe(1) = uicontrol('style', 'frame', 'position', [355 15 180 75], 'backgroundcolor', [0 0 0]);
   h(1) = uicontrol('style', 'edit', 'tag', 'TRIALBOX', 'position', [420 55 50 25], 'string', '1', 'callback', 'view_eyetrace');
   h(2) = uicontrol('style', 'pushbutton', 'tag', 'LEFT', 'position', [370 55 40 25], 'string', '<<', 'callback', 'view_eyetrace');
   h(3) = uicontrol('style', 'pushbutton', 'tag', 'RIGHT', 'position', [480 55 40 25], 'string', '>>', 'callback', 'view_eyetrace');
   h(4) = uicontrol('style', 'slider', 'tag', 'SLIDE', 'position', [370 25 150 20], 'min', 1, 'max', total_trials, 'value', 1, 'callback', 'view_eyetrace');
   hframe(2) = uicontrol('style', 'frame', 'position', [100 20 160 92], 'backgroundcolor', [0 0 0]);
   htext = uicontrol('style', 'text', 'position', [100 28 75 20], 'string', 'Duration:', 'foregroundcolor', [1 1 1], 'backgroundcolor', [0 0 0], 'horizontalalignment', 'right');
   h(5) = uicontrol('style', 'edit', 'position', [195 30 50 20], 'string', num2str(SpikeConfig.DefaultDuration), 'tag', 'DURATION', 'callback', 'view_eyetrace(1)');
   htext = uicontrol('style', 'text', 'position', [100 53 75 20], 'string', 'Offset:', 'foregroundcolor', [1 1 1], 'backgroundcolor', [0 0 0], 'horizontalalignment', 'right');
   h(7) = uicontrol('style', 'edit', 'position', [195 55 50 20], 'string', num2str(SpikeConfig.DefaultStartOffset), 'tag', 'OFFSET', 'callback', 'view_eyetrace(1)');
   htext = uicontrol('style', 'text', 'position', [100 78 75 20], 'string', 'Start Code:', 'foregroundcolor', [1 1 1], 'backgroundcolor', [0 0 0], 'horizontalalignment', 'right');
   h(8) = uicontrol('style', 'edit', 'position', [195 80 50 20], 'string', num2str(SpikeConfig.DefaultStartCode), 'tag', 'START_CODE', 'callback', 'view_eyetrace(1)');
   hframe(3) = uicontrol('style', 'frame', 'position', [355 93 180 27], 'backgroundcolor', [0 0 0]);
   htext = uicontrol('style', 'text', 'position', [370 95 80 18], 'string', 'Axes bounds', 'foregroundcolor', [1 1 1], 'backgroundcolor', [0 0 0], 'horizontalalignment', 'right');
   h(9) = uicontrol('style', 'edit', 'position', [460 97 50 18], 'string', '20', 'tag', 'axesbounds', 'callback', 'view_eyetrace(1)');
   
   subplot(3, 2, [1 3]);
   XY = plot(1:100, 1:100, 'w');
   set(XY, 'tag', 'XY', 'hittest', 'off');
   axis equal;
   title ('Click to Animate');
   set(gca, 'color', [0 0 0], 'tag', 'XYplot', 'buttondownfcn', 'view_eyetrace(2);');
   htext = text(0, 0, 'No Data');
   set(htext, 'color', [0 0 0], 'horizontalalignment', 'center', 'fontsize', 10, 'tag', 'nodatatext'); 
   
   subplot(3, 2, 2);
   X = plot(1:100, 'g');
   set(X, 'tag', 'X');
   hold on
   Y = plot(1:100, 'r');
   set(Y, 'tag', 'Y');
   set(gca, 'color', [0 0 0], 'tag', 'XYcomp');
   ylim = get(gca, 'ylim');
   xlim = get(gca, 'xlim');
   htext = text(mean(xlim), (max(ylim) - 0.1*range(ylim)), 'X (green) and Y (red) components');
   hold off;
   set(htext, 'color', [1 1 1], 'horizontalalignment', 'center', 'fontsize', 8, 'tag', 'component_title');
   subplot(3, 2, 4);
   V = plot(1:100, 'w');
   set(V, 'tag', 'V');
   set(gca, 'color', [0 0 0], 'tag', 'velocity');
   ylim = get(gca, 'ylim');
   xlim = get(gca, 'xlim');
   htext = text(mean(xlim), (max(ylim) - 0.1*range(ylim)), 'Velocity');
   set(htext, 'color', [1 1 1], 'horizontalalignment', 'center', 'fontsize', 8, 'tag', 'velocity_title');
   set(findobj(gcf, 'type', 'axes'), 'xcolor', [1 1 1], 'ycolor', [1 1 1]);
   
   updatefigs;
   
else
   
   filename = get(gcf, 'userdata');
   callback = get(gcbo, 'tag');
   tb = findobj(gcf, 'tag', 'TRIALBOX');
   trial = str2num(get(tb, 'string'));
   sl = findobj(gcf, 'tag', 'SLIDE');
   slidepos = get(sl, 'value');
   
   start_eog = -1;
   
   while start_eog == -1,
      if callback(1:4) == 'RIGH',
         trial = trial + 1;
      end
      
      if callback(1:4) == 'LEFT',
         trial = trial - 1;
      end
      
      if callback(1:4) == 'SLID',
         trial = round(slidepos);
      end
   
      if isempty(trial),
         set(tb, 'string', '');
         return
      end
   
      if trial < 1,
         trial = 1;
      end
   
      if trial > total_trials,
         trial = total_trials;
      end
      
      start_eog = get_code_time(trial, SpikeConfig.StartEyeDataCode);
      if start_eog == -1 & trial == 1,
         trial == total_trials;
      elseif start_eog == -1 & trial == total_trials,
         trial == 1;
      end
   end
      
   set(tb, 'string', num2str(trial));
   set(sl, 'value', trial);
   
   updatefigs;
    
end

function updatefigs

[SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spikestat;
esr = 1000/SpikeInfo.EyeFrequency;

nodataflag = 0;

tb = findobj(gcf, 'tag', 'TRIALBOX');
trial = str2num(get(tb, 'string'));
if isempty(trial),
   set(tb, 'string', '');
   return
end

startbox = findobj(gcf, 'tag', 'START_CODE');
start_code = str2num(get(startbox, 'string'));
if isempty(start_code) | isnan(get_code_time(trial, start_code)),
   nodataflag = 1;
end

offsetbox = findobj(gcf, 'tag', 'OFFSET');
start_offset = str2num(get(offsetbox, 'string'));
if isempty(start_offset),
   nodataflag = 1;
end

durationbox = findobj(gcf, 'tag', 'DURATION');
duration = str2num(get(durationbox, 'string'));
if isempty(duration) | duration < 2*esr,
   nodataflag = 1;
end

if nodataflag == 1,
   x = zeros(100, 1);
   y = x;
   velocity = x;
else
   [x y velocity] = geteye(trial, start_code, start_offset, duration);
end

axesboundbox = findobj(gcf, 'tag', 'axesbounds');
maxbound = str2num(get(axesboundbox, 'string'));
if isempty(maxbound) | maxbound <= 0,
   maxbound = 20;
end
ylim = [-maxbound maxbound];

XY = findobj(gcf, 'tag', 'XY');
XYplot = get(XY, 'parent');
set(XY, 'ydata', y, 'xdata', x);
XYplot = get(XY, 'parent');

set(XYplot, 'xlim', [-maxbound maxbound], 'ylim', [-maxbound maxbound]);

X = findobj(gcf, 'tag', 'X');
Y = findobj(gcf, 'tag', 'Y');
Cplot = get(X, 'parent');
set(X, 'ydata', x, 'xdata', 1:esr:length(x)*esr);
set(Y, 'ydata', y, 'xdata', 1:esr:length(y)*esr);
set(Cplot, 'xlim', [1 (esr*length(x))], 'ylim', ylim);
set(findobj(gcf, 'tag', 'component_title'), 'position', [mean(get(Cplot, 'xlim')) (max(get(Cplot, 'ylim'))-(0.1*range(get(Cplot, 'ylim')))) 0]);

V = findobj(gcf, 'tag', 'V');
Vplot = get(V, 'parent');
set(V, 'ydata', velocity, 'xdata', 1:esr:length(velocity)*esr);
set(Vplot, 'xlim', [1 (esr*length(x))], 'ylim', [0 (2*maxbound)]);
set(findobj(gcf, 'tag', 'velocity_title'), 'position', [mean(get(Vplot, 'xlim')) (max(get(Vplot, 'ylim'))-(0.1*range(get(Vplot, 'ylim')))) 0]);

if nodataflag == 1,
   set(findobj(gcf, 'tag', 'nodatatext'), 'color', [1 1 1]);
else
   set(findobj(gcf, 'tag', 'nodatatext'), 'color', [0 0 0]);
end

function animate

XY = findobj(gcf, 'tag', 'XY');
X = findobj(gcf, 'tag', 'X');
Y = findobj(gcf, 'tag', 'Y');
V = findobj(gcf, 'tag', 'V');

x = get(XY, 'xdata');
y = get(XY, 'ydata');
xcx = get(X, 'xdata');
xcy = get(X, 'ydata');
ycx = get(Y, 'xdata');
ycy = get(Y, 'ydata');
vx = get(V, 'xdata');
vy = get(V, 'ydata');

for i = 2:10:length(x),
   set(XY, 'xdata', x(1:i), 'ydata', y(1:i));
   set(X, 'xdata', xcx(1:i), 'ydata', xcy(1:i));
   set(Y, 'xdata', ycx(1:i), 'ydata', ycy(1:i));
   set(V, 'xdata', vx(1:i), 'ydata', vy(1:i));
   drawnow;
end
