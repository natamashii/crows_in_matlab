function selection = choose_cluster(varargin);
% SYNTAX:
%         cluster_indices = choose_cluster(mode)
%
% 'mode' is an optional input argument which specifies whether multiple
% selections are permitted (1 = yes, 0 = no).  The default is 0.
% 
% Created 1998 --WA
% last modified 2/20/2001 -- WA

[SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spikestat;

ms = 'single';
if ~isempty(varargin),
   m = varargin{:};
   if max(size(m)) > 1 | m > 1 | m < 0,
      error('******* unrecognized input option ********');
      return
   end
   if m == 1,
      ms = 'multiple';
   end
end

file = SpikeInfo.FileName;
slash = find(file == filesep);
if ~isempty(slash),
   file = file(max(slash)+1:length(file));
end

n = strvcat('Select cluster(s) from', file, ' ');

clusters = num2str(SpikeInfo.NeuronID);

[selection, ok] = listdlg('name', 'Cluster Picker', 'PromptString', n,'SelectionMode', ms, 'ListString', clusters, 'listsize', [110 180]);

if ok == 0,
   error('********** No cluster(s) chosen ***********');
   return
end

disp(num2str(SpikeInfo.NeuronID(selection)))

