function nexcheck(varargin)

load('spk_cfg.mat');

maxgap = 60; %in seconds -- will report how often a particular event is inactive for longer than this time
checkcode = 35; %fixspot on.
numspkcodes = 0;
numctxcodes = 0;
stoptime = 0;

directories;

if isempty(varargin),
   [filename pathname] = uigetfile(strcat(dir_spk, '*.spk'), 'Select SPK file...');
   if pathname == 0, return; end;
   spkfile = strcat(pathname, filename);
else
   spkfile = (varargin{:});
end

dot = find(spkfile == '.');
if isempty(dot),
   dot = length(spkfile)+1;
end
   
%open check file:
chkfile = spkfile;
chkfile(dot:dot+3) = '.chk';
fcheck = fopen(chkfile, 'w');
fprintf(fcheck, 'SPKcheck v1.0\r\n');
fprintf(fcheck, 'Created by Wael Asaad, February 20, 2001\r\n*****************\r\n\r\n');   
fprintf(fcheck, '%s\r\n\r\n', date);
fprintf(fcheck, 'Checking %s\r\n\r\n', spkfile);
fprintf(fcheck, 'Gaps longer than %i seconds are reported.\r\n\r\n', maxgap);
   
%read nexfile and sort out cluster and event names...
disp(sprintf('Reading %s...', spkfile));
[SpikeInfo fh vh timestamps] = spk_read(spkfile);
for i = 1:fh.NumVars,
   t = vh(i).Type;
   v = vh(i).Version;
   n = vh(i).Name;
   c = vh(i).Count;
   if c > 0,
      d = timestamps{i};
      if ~isempty(d) & t ~= 5 & t ~= 7,
         firstevent = d(1);
         if length(d) > 1,
		   	lastevent = d(length(d));
         	numgaps = sum(diff(d) > maxgap);
            fprintf(fcheck, '#%i  Type(%i) Ver(%i) %s: %i events, %5.3f to %5.3f secs; %i gaps\r\n', i, t, v, n, c, firstevent, lastevent, numgaps);
         else
            fprintf(fcheck, '#%i  Type(%i) Ver(%i) %s: %i event at %5.3f seconds\r\n', i, t, v, n, c, firstevent);
         end
      elseif t == 5,
         c = vh(i).NPointsWave;
         fprintf(fcheck, '#%i  Type(%i) Ver(%i) %s: %i data points (not read)\r\n', i, t, v, n, c);
      elseif t == 7,
         if c == 1,
            blkstring = 'block';
         else
            blkstring = 'blocks';
         end
         fprintf(fcheck, '#%i  Type(%i) Ver(%i) %s: %i marker variable data %s\r\n', i, t, v, n, c, blkstring);
      end
   end
end

fclose(fcheck);

disp(sprintf('Wrote %s', chkfile))
edit(chkfile)