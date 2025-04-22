function [SpikeInfo, SpikeFileHeader, SpikeVarHeader, SpikeData] = spikestat(varargin)
% SYNTAX:
%		[SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spikestat;
%	or
%		spikestat({[SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData]});
%
% The first usage is for retrieving information about the currently active file, whereas the
% second usage if for setting information about a new active file.  The data is stored in
% the graphical "0" object's "userdata" field (this object corresponds to the entire display
% screen, and is considered by MATLAB to be the parent of any figure windows).
%
% SPK_READ always calls this function to automatically set the currently active file.
%
% calling:
%	spikestat('clear');
% will clear the "0" object's "userdata" field and will leave no SPK files active.
%
% Created March, 2001  --WA

if isempty(varargin), %return Spike structures
   SPIKEVARS = get(0, 'userdata');
   if isempty(SPIKEVARS),
      SpikeInfo = [];
      SpikeFileHeader = [];
      SpikeVarHeader = [];
      SpikeData = [];
   else
      SPIKEVARS = SPIKEVARS{1};
      SpikeInfo = SPIKEVARS{1};
      SpikeFileHeader = SPIKEVARS{2};
      SpikeVarHeader = SPIKEVARS{3};
      SpikeData = SPIKEVARS{4};
   end
elseif isstr(varargin{1}) & strmatch(varargin{1}, 'clear'),
   set(0, 'userdata', []);
else
  	%update Spike structures
   SPIKEVARS = varargin;
   set(0, 'userdata', SPIKEVARS);
end
