function crit = select_criteria;

SpikeConfig = spiketools_config(0);
fig = figure;
set(fig, 'position', [350 260 170 195], 'numbertitle', 'off', 'name', 'Select Trigger Criteria', 'tag', 'spkcrit', 'menubar', 'none', 'resize', 'off');
h0 = uicontrol('style', 'frame', 'position', [10 18 150 165]);
handles(1) = uicontrol('style','text', 'position', [20 150 60 25], 'string', 'Start Code');
handles(2) = uicontrol('style','text', 'position', [20 115 60 25], 'string', 'Start Offset');
handles(3) = uicontrol('style', 'text', 'position', [20 80 60 25], 'string', 'Duration');
handles(4) = uicontrol('style', 'edit', 'position', [90 155 50 20], 'string', num2str(SpikeConfig.DefaultStartCode), 'tag', 'sc');
handles(5) = uicontrol('style', 'edit', 'position', [90 120 50 20], 'string', num2str(SpikeConfig.DefaultStartOffset), 'tag', 'so');
handles(6) = uicontrol('style', 'edit', 'position', [90 85 50 20], 'string', num2str(SpikeConfig.DefaultDuration), 'tag', 'd');
handles(7) = uicontrol('style', 'pushbutton', 'position', [60 35 50 25], 'string', 'Ok', 'callback', 'uiresume');
uiwait
if ishandle(fig),
	crit.start_code = str2num(get(findobj(gcf, 'tag', 'sc'), 'string'));
	crit.start_offset = str2num(get(findobj(gcf, 'tag', 'so'), 'string'));
	crit.duration = str2num(get(findobj(gcf, 'tag', 'd'), 'string'));
   delete(fig);
else
   crit = [];
end
