function nexcheck(varargin)

load('spk_cfg.mat');

maxgap = 60; %in seconds -- will report how often a particular event is inactive for longer than this time
checkcode = 35; %fixspot on.
numnexcodes = 0;
numctxcodes = 0;
stoptime = 0;

directories;
dir_nex = strcat(dir_m, '*.nex');

if isempty(varargin),
	[filename pathname] = uigetfile(dir_nex, '*.nex');
   nexfile = strcat(pathname, filename);
else
   nexfile = (varargin{:});
end

dot = find(nexfile == '.');
if isempty(dot),
   dot = length(nexfile)+1;
end
   
%open check file:
chkfile = nexfile;
chkfile(dot:dot+3) = '.chk';
fcheck = fopen(chkfile, 'w');
fprintf(fcheck, 'Nexcheck v1.1\r\n');
fprintf(fcheck, 'Created by Wael Asaad, September 16, 1999\r\n'); 
fprintf(fcheck, 'Last modified 2/20/2001\r\n*****************\r\n\r\n');
fprintf(fcheck, '%s\r\n\r\n', date);
fprintf(fcheck, 'Checking %s\r\n\r\n', nexfile);
fprintf(fcheck, 'Gaps longer than %i seconds are reported.\r\n\r\n', maxgap);
   
%read nexfile and sort out cluster and event names...
disp(sprintf('Reading %s...', nexfile));
[fh vh timestamps] = nex_read(nexfile);
for i = 1:fh.NumVars,
   t = vh(i).Type;
   v = vh(i).Version;
   n = vh(i).Name;
   c = vh(i).Count;
   if c > 0,
	   d = timestamps{i};
	   firstevent = d(1);
	   lastevent = d(length(d));
      numgaps = sum(diff(d) > maxgap);
      if t == 5,
         c = vh(i).NPointsWave;
         fprintf(fcheck, '#%i  Type(%i) Ver(%i) %s: %i data points (not read)\r\n', i, t, v, n, c);
      else
         fprintf(fcheck, '#%i  Type(%i) Ver(%i) %s: %i events, %5.3f to %5.3f secs; %i gaps\r\n', i, t, v, n, c, firstevent, lastevent, numgaps);      end
   end
end

fclose(fcheck);

disp(sprintf('Wrote %s', chkfile))
edit(chkfile)