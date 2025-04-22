% recording_stats
%
% called from the SPK main menu under "file."
%
% created Fall, 1997  --WA
% last modified 10/16/2000 --WA

directories;
%SpikeConfig = spiketools_config(0);

% Get files from which to retrieve locations
names = dir (fullfile (dir_spk, '*.spk'));   
cellnames = {names.name};

% sort cellnames
c = cellnames';
c = strvcat(c{:});
c = sortrows(lower(c));
cellnames = num2cell(c,2);

[selection, ok] = listdlg('name', 'Cell Stats...', 'PromptString', 'Select file(s) to include','SelectionMode', 'multiple','ListString', cellnames);
if ok == 0,   return; end

files_selected = {cellnames{selection}};
[nrows ncols] = size(files_selected);
numfiles = length(files_selected);

%  get stats
numcells = 0;
numlfp = 0;
numelectrodes = 0;
for i = 1:length(files_selected),
	neurons = findspk(files_selected{i}, 'Type', 0);
	lfp = findspk(files_selected{i}, 'Type', 5);
	numcells = numcells + length(neurons);
   numlfp = numlfp + length(lfp);
   wneurons = getspk(neurons, 'WireNumber');
   wlfp = getspk(lfp, 'WireNumber');
   numelectrodes = numelectrodes + length(unique(cat(1, wneurons{:}, wlfp{:})));
end

cells_per_electrode = numcells/numelectrodes;
cells_per_file = numcells/numfiles;
electrodes_per_file = numelectrodes/numfiles;

figure;
set(gcf, 'numbertitle', 'off', 'menubar', 'none', 'resize', 'off', 'name', 'Recording Statistics');
xwin = 250;
ywin = 150;
set(gcf, 'position', [200 250 xwin ywin]);
h(1) = uicontrol('style', 'frame', 'position', [10 10 xwin-20 ywin-20], 'backgroundcolor', [0 0 0]);
h(2) = uicontrol('style', 'text', 'position', [15 13 xwin-30 ywin-30]);
t1 = sprintf('   Total Neurons:\t\t%i', numcells);
t2 = sprintf('   Total LFP channels:\t%i', numlfp);
t3 = sprintf('   Total Electrodes:\t\t%i',numelectrodes);
t4 = sprintf('   Total Files:\t\t%i', numfiles);
t5 = sprintf('   Cells per Electrode:\t%3.1f', cells_per_electrode);
t6 = sprintf('   Cells per File:\t\t%3.1f', cells_per_file);
t7 = sprintf('   Electrodes per File:\t%3.1f', electrodes_per_file);
summary = strvcat(t1, t2, t3, t4, t5, t6, t7);
set(h, 'string', summary, 'fontsize', 12, 'horizontalalignment', 'left', 'foregroundcolor', [1 1 1], 'backgroundcolor', [0 0 0]);
