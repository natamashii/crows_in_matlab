function spk_info(varargin)
% This function allows you to view and edit data-file related information,
% such as recording locations, experiment and subject name, and comments.
% This can be launched from: SpikeTools Main Menu >> File Info button.
%
% See FINDSPK and GETSPK for information about retrieving recording locations
% and other information from data files.
%
% created 9/2/99 (SpikeTools 7 version 3/2001) --WA
% last modified 3/22/2001 --WA

directories;
SpikeConfig = spiketools_config(0);

fig = findobj('tag', 'SpikeFileInfo');
if ~isempty(varargin),
   fn = varargin{1};
   dot = find(fn == '.');
   if isempty(dot),
      fn = strcat(fn, '.spk');
   end
   slash = find(fn == filesep);
   if isempty(slash),
      fn = strcat(dir_spk, fn);
   end
   [SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spk_read(fn);
   fig = [];
elseif isempty(fig),
	[SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spikestat;
	if isempty(SpikeInfo),
	   [SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spk_read;
	end
end

cback = 0;
if ~isempty(gcbo) & ismember(get(gcbo, 'parent'), fig),
   cback = 1;
end

if ~isempty(fig) & cback == 0,
   figure(fig(1));
   return
end

if isempty(fig),
   
   probelist = cat(1, SpikeVarHeader.WireNumber);
	wn = unique(probelist);
	wn = wn(find(wn));
	number_of_probes = length(wn);
	
	slash = find(SpikeInfo.FileName == filesep);
	if isempty(slash),
	   spk_filename = SpikeInfo.FileName;
	else
	   spk_filename = SpikeInfo.FileName(max(slash)+1:length(SpikeInfo.FileName));
	end

   xsize = 470;
   ysize = 550;
   xoffset = 200;
   yoffset = 50;
   handle = zeros(100, 1);
      
   figure
   set(gcf, 'position', [xoffset yoffset xsize ysize], 'numbertitle', 'off', 'menubar', 'none', 'tag', 'SpikeFileInfo', 'resize', 'off');
   set(gcf, 'userdata', {SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData}, 'name', sprintf('%s Info', spk_filename));
   handle(1) = uicontrol('style', 'toggle', 'position', [10 ysize-70 80 25], 'string', 'Edit', 'callback', 'spk_info', 'tooltipstring', 'Enable / Disable editing', 'tag', 'EditButton', 'backgroundcolor', [.65 .5 .5]); 
   handle(2) = uicontrol('style', 'pushbutton', 'position', [10 ysize-100 80 25], 'string', 'Save Changes', 'enable', 'off', 'callback', 'spk_info', 'tag', 'SaveButton');
   handle(3) = uicontrol('style', 'frame', 'position', [100 ysize-185 xsize-110 170]);
   handle(4) = uicontrol('style', 'text', 'position', [105 ysize-40 120 20], 'string', spk_filename, 'fontsize', 12, 'fontweight', 'bold', 'fontname', 'times', 'tag', 'filename');
   handle(5) = uicontrol('style', 'text', 'position', [229 ysize-42 70 20], 'string', 'created on');
   handle(6) = uicontrol('style', 'text', 'position', [290 ysize-42 70 20], 'string', sprintf('%i/%i/%i', SpikeFileHeader.CreationDate(2),SpikeFileHeader.CreationDate(3),SpikeFileHeader.CreationDate(1)));
   handle(7) = uicontrol('style', 'text', 'position', [215 ysize-60 75 20], 'string', 'last modified on');
   handle(8) = uicontrol('style', 'text', 'position', [290 ysize-60 70 20], 'string', sprintf('%i/%i/%i', SpikeFileHeader.ModificationDate(2),SpikeFileHeader.ModificationDate(3),SpikeFileHeader.ModificationDate(1)), 'tag', 'ModificationDate');
   handle(9) = uicontrol('style', 'text', 'position', [105 ysize-90 80 20], 'string', 'Experiment:', 'fontweight', 'bold');
   handle(10) = uicontrol('style', 'edit', 'position', [185 ysize-87 220 20], 'string', SpikeFileHeader.Experiment, 'backgroundcolor', [1 1 1], 'tag', 'Experiment', 'enable', 'off');
   handle(11) = uicontrol('style', 'text', 'position', [114 ysize-120 80 20], 'string', 'Subject:', 'fontweight', 'bold');
   handle(12) = uicontrol('style', 'edit', 'position', [185 ysize-117 220 20], 'string', SpikeFileHeader.Subject, 'backgroundcolor', [1 1 1], 'tag', 'Subject', 'enable', 'off');
   handle(13) = uicontrol('style', 'text', 'position', [114 ysize-150 80 20], 'string', 'Session:', 'fontweight', 'bold');
   handle(14) = uicontrol('style', 'text', 'position', [195 ysize-150 200 20], 'string', '  M                D                Y', 'horizontalalignment', 'left');
   handle(15) = uicontrol('style', 'edit', 'position', [215 ysize-147 30 20], 'string', num2str(SpikeFileHeader.SessionDate(2)), 'tag', 'SessionMonth');
   handle(16) = uicontrol('style', 'edit', 'position', [270 ysize-147 30 20], 'string', num2str(SpikeFileHeader.SessionDate(3)), 'tag', 'SessionDay');
   handle(17) = uicontrol('style', 'edit', 'position', [325 ysize-147 60 20], 'string', num2str(SpikeFileHeader.SessionDate(1)), 'tag', 'SessionYear');
   set(handle(15:17), 'backgroundcolor', [1 1 1], 'enable', 'off', 'callback', 'spk_info');
   if strmatch(SpikeFileHeader.Investigator, 'Unspecified'),
      str = '?';
   else
      str = SpikeFileHeader.Investigator;
   end
   handle(18) = uicontrol('style', 'text', 'position', [105 ysize-180 xsize-120 20], 'string', sprintf('Data collected by %s', str), 'fontweight', 'bold', 'fontname', 'times', 'fontsize', 10, 'foregroundcolor', [1 1 1]);
      
   for i = 1:number_of_probes,
      probe = wn(i);
      f = find(probelist == probe);
      varname = SpikeVarHeader(f(1)).Name;
      probe_id(i, 1) = 100*round(str2num(char(varname(find(varname > 47 & varname < 58))))/100);
      Xcoord(i, 1) = SpikeVarHeader(f(1)).Xpos;
      Ycoord(i, 1) = SpikeVarHeader(f(1)).Ypos;
      Zcoord(i, 1) = SpikeVarHeader(f(1)).Zpos;
      Acoord(i, 1) = SpikeVarHeader(f(1)).Apos;
      for ii = 1:length(f),
         varname = SpikeVarHeader(f(ii)).Name;
         sig_id(i, ii) = str2num(char(varname(find(varname > 47 & varname < 58))));
         varnum(i, ii) = f(ii);
      end
      [sig_id(i, :) sortindx] = sort(sig_id(i, :));
      varnum(i, :) = varnum(i, sortindx);
   end
   
   SigDirectory.SignalID = sig_id;
   SigDirectory.Varnum = varnum;
   SigDirectory.Coords = [Xcoord Ycoord Zcoord Acoord];
   
   str = num2str(probe_id);
   str = '';
   for i = 1:length(probe_id),
      str = strvcat(str, sprintf('Probe %i', probe_id(i)));
   end
   
   handle(19) = uicontrol('style', 'frame', 'position', [10 ysize-385 xsize-220 190]);
   handle(20) = uicontrol('style', 'listbox', 'position', [20 ysize-370 100 125], 'backgroundcolor', [1 1 1], 'callback', 'spk_info', 'tag', 'ProbeBox', 'string', str, 'userdata', SigDirectory);
   varhere = unique(varnum(1, :));
   varhere = varhere(find(varhere));
   signames = strvcat(SpikeVarHeader(varhere).Name);
   handle(21) = uicontrol('style', 'frame', 'position', [132 ysize-268 124 68]);
   handle(22) = uicontrol('style', 'popupmenu', 'position', [140 ysize-237 110 30], 'string', signames, 'tag', 'SignalBox', 'callback', 'spk_info', 'backgroundcolor', [1 1 1], 'userdata', varhere);
   handle(23) = uicontrol('style', 'text', 'position', [140 ysize-305 45 25], 'string', 'X pos');
   handle(24) = uicontrol('style', 'text', 'position', [140 ysize-330 45 25], 'string', 'Y pos');
   handle(25) = uicontrol('style', 'text', 'position', [140 ysize-355 45 25], 'string', 'Z pos');
   handle(26) = uicontrol('style', 'text', 'position', [140 ysize-380 45 25], 'string', 'Area #');
   set(handle(23:26), 'horizontalalignment', 'right', 'fontweight', 'bold');
      
   Xc = coord2string(Xcoord(1), SpikeConfig.DefaultNoLocationCode);
   Yc = coord2string(Ycoord(1), SpikeConfig.DefaultNoLocationCode);
   Zc = coord2string(Zcoord(1), SpikeConfig.DefaultNoLocationCode);
   Ac = coord2string(Acoord(1), SpikeConfig.DefaultNoLocationCode);
   
   handle(27) = uicontrol('style', 'edit', 'position', [195 ysize-297 50 20], 'string', Xc, 'tag', 'Xcoord');
   handle(28) = uicontrol('style', 'edit', 'position', [195 ysize-322 50 20], 'string', Yc, 'tag', 'Ycoord');
   handle(29) = uicontrol('style', 'edit', 'position', [195 ysize-347 50 20], 'string', Zc, 'tag', 'Zcoord');
   handle(30) = uicontrol('style', 'edit', 'position', [195 ysize-372 50 20], 'string', Ac, 'tag', 'Acoord');
   set(handle(27:30), 'backgroundcolor', [1 1 1], 'callback', 'spk_info', 'enable', 'off', 'callback', 'spk_info');
   
   handle(31) = subplot('position', [.57 .345 .405 .299]);
   set(handle(31), 'color', get(handle(19), 'backgroundcolor'), 'xtick', [], 'ytick', [], 'box', 'on', 'handlevisibility', 'off');
   handle(32) = subplot('position', [.6 .405 .34 .223]);
   set(handle(32), 'tag', 'GraphWindow', 'layer', 'top', 'color', [1 1 1]);
   handle(33) = uicontrol('style', 'text', 'string', ' ', 'tag', 'XLabel', 'position', [300 ysize-358 130 15], 'horizontalalignment', 'center');
   handle(34) = uicontrol('style', 'text', 'string', ' ', 'tag', 'GraphAnnotation', 'position', [285 ysize-220 154 15], 'horizontalalignment', 'right', 'backgroundcolor', [1 1 1]);
   handle(35) = uicontrol('style', 'text', 'string', ' ', 'tag', 'SigNote', 'position', [134 ysize-267 120 34], 'horizontalalignment', 'center');
   handle(36) = uicontrol('style', 'text', 'position', [20 ysize-240 100 40], 'string', 'Choose probe from below, then signal from right...');
   updategraph = 1;
   
   handle(37) = uicontrol('style', 'frame', 'position', [xsize-200 10 190 172]);
   maxtime = SpikeFileHeader.End - SpikeFileHeader.Beg; %duration of file, in ticks
	maxtime = maxtime/SpikeFileHeader.Frequency; %duration of file, in seconds
	numhours = floor(maxtime/3600);
	numminutes = floor(maxtime/60) - (60*numhours);
	numseconds = maxtime - (3600*numhours) - (60*numminutes);
   str = sprintf('%i Hrs, %i minutes, and %2.1f seconds', numhours, numminutes, numseconds);
   handle(38) = uicontrol('style', 'text', 'position', [xsize-195 152 180 20], 'string', sprintf('Session duration: %i trials in', length(SpikeInfo.TrialStartTimes)));
   handle(39) = uicontrol('style', 'text', 'position', [xsize-195 137 180 20], 'string', str);
   fid = fopen(SpikeInfo.FileName, 'r');
   fseek(fid, 0, 1);
   filesize = ftell(fid)/1024000;
   fclose(fid);
   handle(40) = uicontrol('style', 'text', 'position', [xsize-195 117 180 20], 'string', sprintf('File size: %3.2f MB', filesize));
   numchannels = length(unique(wn));
   numneurons = length(SpikeInfo.NeuronIndex);
   numlfps = length(SpikeInfo.LFPIndex);
   handle(41) = uicontrol('style', 'text', 'position', [xsize-195 97 180 20], 'string', sprintf('%i channels, %i neurons, %i LFPs', numchannels, numneurons, numlfps));
   handle(42) = uicontrol('style', 'text', 'position', [xsize-195 77 180 20], 'string', sprintf('AtoD frequency: %2.2f KHz', round(SpikeFileHeader.Frequency/1000)));
   varnames = strvcat(SpikeVarHeader.Name);
   if isempty(strmatch('EyePosition', varnames)),
      str = 'No eye data collected';
   else
      str = sprintf('Eye data present @ %3.2f Hz', SpikeInfo.EyeFrequency);
   end
   handle(43) = uicontrol('style', 'text', 'position', [xsize-195 57 180 20], 'string', str);
   
   if isempty(SpikeInfo.LFPIndex),
      str = 'No LFP data collected';
   elseif ~any(cat(1, SpikeVarHeader(SpikeInfo.LFPIndex).Count)),
      str = 'LFP data not stored in this SPK file';
   else
      str = 'LFP data present in this SPK file';
   end
   handle(44) = uicontrol('style', 'text', 'position', [xsize-195 37 180 20], 'string', str);
   handle(45) = uicontrol('style', 'text', 'position', [xsize-195 17 180 20], 'string', sprintf('Spike file version %2.2f', SpikeFileHeader.Version/100));
   
   handle(46) = uicontrol('style', 'frame', 'position', [10 10 xsize-220 145]);
   handle(47) = uicontrol('style', 'edit', 'position', [25 25 xsize-251 100], 'string', sprintf(SpikeFileHeader.Comment), 'enable', 'off', 'backgroundcolor', [1 1 1], 'tag', 'CommentBox', 'fontsize', 10, 'horizontalalignment', 'left', 'max', 5);
   handle(48) = uicontrol('style', 'text', 'position', [xsize-430 125 200 20], 'string', 'Comment (<= 256 chars)', 'horizontalalignment', 'center');
   
   handle(49) = uicontrol('style', 'pushbutton', 'position', [10 365 80 80],'tag', 'Whoot', 'cdata', imread('infobg7.jpg'), 'callback', 'spk_info');
   handle(50) = uicontrol('style', 'pushbutton', 'position', [10 ysize-40 80 25], 'string', 'New File', 'callback', 'spk_info', 'tooltipstring', 'Select new SPK file', 'tag', 'NewFileButton', 'backgroundcolor', [.65 .5 .5]); 
   
elseif cback == 1,
   
   ud = get(gcf, 'userdata');
   SpikeInfo = ud{1};
   SpikeFileHeader = ud{2};
   SpikeVarHeader = ud{3};
   SpikeData = ud{4};
   
   callertag = get(gcbo, 'tag');
   updategraph = 0;
   if strmatch(callertag, 'EditButton'),
      
      if get(findobj(gcf, 'tag', 'EditButton'), 'value'),
         str = 'on';
      else
         str = 'off';
      end
      
      set(findobj(gcf, 'tag', 'Experiment'), 'enable', str);
      set(findobj(gcf, 'tag', 'Subject'), 'enable', str);
      set(findobj(gcf, 'tag', 'SessionMonth'), 'enable', str);
      set(findobj(gcf, 'tag', 'SessionDay'), 'enable', str);
      set(findobj(gcf, 'tag', 'SessionYear'), 'enable', str);
      set(findobj(gcf, 'tag', 'Xcoord'), 'enable', str);
      set(findobj(gcf, 'tag', 'Ycoord'), 'enable', str);
      set(findobj(gcf, 'tag', 'Zcoord'), 'enable', str);
      set(findobj(gcf, 'tag', 'Acoord'), 'enable', str);
      set(findobj(gcf, 'tag', 'CommentBox'), 'enable', str);
      set(findobj(gcf, 'tag', 'SaveButton'), 'enable', str);
      
   elseif strmatch(callertag, 'SaveButton'),
      
      comstring = [];
      comment = get(findobj(gcf, 'tag', 'CommentBox'), 'string');
      for i = 1:size(comment, 1),
         comstring = strcat(comstring, comment(i, :), '\n');
      end
      comment = double(comstring);
      
      if length(comment) > 255,
         comment = comment(1:256);
      else
         comment(length(comment)+1:256) = 0;
      end
      
      experiment = double(get(findobj(gcf, 'tag', 'Experiment'), 'string'));
      if length(experiment) > 63,
         experiment = experiment(1:64);
      else
         experiment(length(experiment)+1:64) = 0;
      end
      
      subject = double(get(findobj(gcf, 'tag', 'Subject'), 'string'));
      if length(subject) > 63,
         subject = subject(1:64);
      else
         subject(length(subject)+1:64) = 0;
      end
      
      sessiondate(1) = str2num(get(findobj(gcf, 'tag', 'SessionYear'), 'string'));
      sessiondate(2) = str2num(get(findobj(gcf, 'tag', 'SessionMonth'), 'string'));
      sessiondate(3) = str2num(get(findobj(gcf, 'tag', 'SessionDay'), 'string'));
      
      today = datevec(date);
      modificationdate = today(1:3);
      
      SigDirectory = get(findobj(gcf, 'tag', 'ProbeBox'), 'userdata');
      
      fid = fopen(SpikeInfo.FileName, 'r+');
      fseek(fid, 8, -1);
      fwrite(fid, comment, 'char');
      fseek(fid, 348, -1);
      fwrite(fid, experiment, 'char');
      fwrite(fid, subject, 'char');
      fwrite(fid, sessiondate, 'int32');
      fseek(fid, 12, 0);
      fwrite(fid, modificationdate, 'int32');
      for probenum = 1:size(SigDirectory.SignalID, 1),
         for signum = 1:size(SigDirectory.SignalID, 2),
            varnum = SigDirectory.Varnum(probenum, signum);
            if varnum > 0,
               fseek(fid, SpikeInfo.VarHeaderOffset(varnum)+96, -1);
               fwrite(fid, SigDirectory.Coords(probenum, :), 'double');
            end
         end
      end
      fclose(fid);
      
      [SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spk_read(SpikeInfo.FileName); %update current info.
      
      set(findobj('tag', 'ModificationDate'), 'string', sprintf('%i/%i/%i', today(2), today(3), today(1)));
      set(findobj(gcf, 'tag', 'Experiment'), 'enable', 'off');
      set(findobj(gcf, 'tag', 'Subject'), 'enable', 'off');
      set(findobj(gcf, 'tag', 'SessionMonth'), 'enable', 'off');
      set(findobj(gcf, 'tag', 'SessionDay'), 'enable', 'off');
      set(findobj(gcf, 'tag', 'SessionYear'), 'enable', 'off');
      set(findobj(gcf, 'tag', 'Xcoord'), 'enable', 'off');
      set(findobj(gcf, 'tag', 'Ycoord'), 'enable', 'off');
      set(findobj(gcf, 'tag', 'Zcoord'), 'enable', 'off');
      set(findobj(gcf, 'tag', 'Acoord'), 'enable', 'off');
      set(findobj(gcf, 'tag', 'CommentBox'), 'enable', 'off');
      set(findobj(gcf, 'tag', 'SaveButton'), 'enable', 'off');
      set(findobj(gcf,' tag', 'EditButton'), 'value', 0);
      
   elseif strmatch(callertag, 'ProbeBox'),
      
      val = get(gcbo, 'value');
      SigDirectory = get(gcbo, 'userdata');
      varhere = unique(SigDirectory.Varnum(val, :));
      varhere = varhere(find(varhere));
      signames = strvcat(SpikeVarHeader(varhere).Name);
      set(findobj(gcf, 'tag', 'SignalBox'), 'string', signames, 'userdata', varhere, 'value', 1);
      
      c = SigDirectory.Coords;
	   Xc = coord2string(c(val, 1), SpikeConfig.DefaultNoLocationCode);
	   Yc = coord2string(c(val, 2), SpikeConfig.DefaultNoLocationCode);
	   Zc = coord2string(c(val, 3), SpikeConfig.DefaultNoLocationCode);
	   Ac = coord2string(c(val, 4), SpikeConfig.DefaultNoLocationCode);
      set(findobj(gcf, 'tag', 'Xcoord'), 'string', Xc);
      set(findobj(gcf, 'tag', 'Ycoord'), 'string', Yc);
      set(findobj(gcf, 'tag', 'Zcoord'), 'string', Zc);
      set(findobj(gcf, 'tag', 'Acoord'), 'string', Ac);
      
      boxtop = get(gcbo, 'listboxtop');
      if (val - boxtop) > 7,
         set(gcbo, 'listboxtop', boxtop + 1);
      end
      
      updategraph = 1;
      
   elseif strmatch(callertag, 'SignalBox'),
      
      updategraph = 1;
      
   elseif ~isempty(strmatch(callertag, strvcat('Xcoord', 'Ycoord', 'Zcoord', 'Acoord'))),
      
      Xh = findobj(gcf, 'tag', 'Xcoord');
      Yh = findobj(gcf, 'tag', 'Ycoord');
      Zh = findobj(gcf, 'tag', 'Zcoord');
      Ah = findobj(gcf, 'tag', 'Acoord');
      Xstring = double(get(Xh, 'string'));
      Ystring = double(get(Yh, 'string'));
      Zstring = double(get(Zh, 'string'));
      Astring = double(get(Ah, 'string'));
      if isempty(Xstring),
         Xc = SpikeConfig.DefaultNoLocationCode;
         Xs = '';
      else
         Xc = eval(char(Xstring(find(Xstring > 39 & Xstring < 58))));
         Xs = num2str(Xc);
      end
      if isempty(Ystring),
         Yc = SpikeConfig.DefaultNoLocationCode;
         Ys = '';
      else
         Yc = eval(char(Ystring(find(Ystring > 39 & Ystring < 58))));
         Ys = num2str(Yc);
      end
      if isempty(Zstring),
         Zc = SpikeConfig.DefaultNoLocationCode;
         Zs = '';
      else
         Zc = eval(char(Zstring(find(Zstring > 39 & Zstring < 58))));
         Zs = num2str(Zc);
      end
      if isempty(Astring),
         Ac = SpikeConfig.DefaultNoLocationCode;
         As = '';
      else
         Ac = eval(char(Astring(find(Astring > 39 & Astring < 58))));
         As = num2str(Ac);
      end
      set(Xh, 'string', Xs);
      set(Yh, 'string', Ys);
      set(Zh, 'string', Zs);
      set(Ah, 'string', As);
      
      pbh = findobj(gcf, 'tag', 'ProbeBox');
      rowindx = get(pbh, 'value');
      SigDirectory = get(pbh, 'userdata');
      SigDirectory.Coords(rowindx, 1:4) = [Xc Yc Zc Ac];
      set(pbh, 'userdata', SigDirectory);
      
   elseif strmatch(callertag, 'SessionMonth'),
      
      mstring = str2num(get(gcbo, 'string'));
      if isempty(mstring),
         mstring = 1;
      elseif mstring > 12, 
         mstring = 12; 
      elseif mstring < 1,
         mstring = 1; 
      end
      mstring = round(mstring);
      set(gcbo, 'string', num2str(mstring));
      
   elseif strmatch(callertag, 'SessionDate'),
      
      dstring = str2num(get(gcbo, 'string'));
      if isempty(dstring),
         dstring = 1;
      elseif dstring > 12, 
         dstring = 12; 
      elseif dstring < 1,
         dstring = 1; 
      end      
      dstring = round(dstring);
      set(gcbo, 'string', num2str(dstring));
      
   elseif strmatch(callertag, 'SessionYear'),
      
      ystring = str2num(get(gcbo, 'string'));
      if isempty(ystring),
         d = datevec(date);
         ystring = d(1);
      end
      ystring = round(ystring);
      set(gcbo, 'string', ystring);
      
   elseif strmatch(callertag, 'Whoot'),
      
      try
	      [y fs nbits] = wavread('troy.wav');
         sound(y/10, fs, nbits);
      end
      
   elseif strmatch(callertag, 'NewFileButton'),
      
      delete(gcf);
   	[filename pathname] = uigetfile(strcat(dir_spk, '.spk'), 'Select Spike file...');
   	if pathname == 0, return; end;
      spk_file = [pathname filename];
      spk_info(spk_file);
   
   end
      
end

if updategraph == 1,
   histsize = 100;
	varhere = get(findobj(gcf, 'tag', 'SignalBox'), 'userdata');        
	chosenvar = varhere(get(findobj(gcf, 'tag', 'SignalBox'), 'value'));
   fid = fopen(SpikeInfo.FileName, 'r');
   fseek(fid, SpikeVarHeader(chosenvar).DataOffset, -1);
   if SpikeVarHeader(chosenvar).Type == 0,
      data = fread(fid, SpikeVarHeader(chosenvar).Count, 'int32')/SpikeFileHeader.Frequency;
      graphdata = 1000*diff(data);
      pisi = sum(graphdata < 2)/length(graphdata);
      graphdata = hist(graphdata, 0:histsize+1);
      graphdata = graphdata(1:histsize);
      ygraphdata = cat(1, 0, graphdata', 0);
      xgraphdata = cat(1, 0, (1:histsize)', histsize); 
      subplot(findobj(gcf, 'tag', 'GraphWindow'));
      phandle = fill(xgraphdata, ygraphdata, [.65 .5 .5]);
      set(phandle, 'linewidth', 2);
      set(gca, 'xlim', [0 histsize], 'ylim', [0 (1.2*max(ygraphdata))], 'tag', 'GraphWindow', 'ytick', [], 'xtick', [0:20:histsize], 'xticklabel', [0:20:histsize], 'fontsize', 8);
      set(findobj(gcf, 'tag', 'XLabel'), 'string', 'Inter-Spike-Interval (ms)');
      set(findobj(gcf, 'tag', 'GraphAnnotation'), 'string', sprintf('%2.1f%% of ISI''s < 2 ms', pisi));
      avgrate = length(data)/((SpikeFileHeader.End - SpikeFileHeader.Beg)/SpikeFileHeader.Frequency);
      set(findobj(gcf, 'tag', 'SigNote'), 'string', sprintf('%i spikes \r@ %3.1f avg. spikes/sec', length(data), avgrate));
   elseif SpikeVarHeader(chosenvar).Type == 5,
      if SpikeVarHeader(chosenvar).Count == 0,
         subplot(findobj(gcf, 'tag', 'GraphWindow'));
         delete(get(gca, 'children'));
         txt = text(0.5, 0.5, 'No LFP data in this SPK file');
         set(txt, 'horizontalalignment', 'center', 'color', [.65, .5, .5], 'fontweight', 'bold', 'fontsize', 8);
         set(gca, 'xlim', [0 1], 'ylim', [0 1], 'xtick', [], 'ytick', [], 'tag', 'GraphWindow', 'box', 'on');
         set(findobj(gcf, 'tag', 'XLabel'), 'string', 'Frequency (Hz)');
         set(findobj(gcf, 'tag', 'GraphAnnotation'), 'string', ' ');
         set(findobj(gcf, 'tag', 'SigNote'), 'string', sprintf('Recorded at %i Hz', SpikeVarHeader(chosenvar).WFrequency));
      else
         freq = SpikeVarHeader(chosenvar).WFrequency;
	      npoints = 100*freq; %read just first 100 seconds, as opposed to SpikeVarHeader(chosenvar).NPointsWave;
	      data = fread(fid, npoints, 'int16')*SpikeVarHeader(chosenvar).ADtoMV;
	      graphdata = abs(fft(data));
	      graphdata = smooth(graphdata(1:(10*freq)), round(freq/10), 'bin');
	      subplot(findobj(gcf, 'tag', 'GraphWindow'));
	      ygraphdata = cat(1, 0, graphdata, 0);
	      xgraphdata = cat(1, 0, (1:100)', 100);
	      phandle = fill(xgraphdata, ygraphdata, [.65 .5 .5]);
	      set(phandle, 'linewidth', 2);
         set(gca, 'xlim', [0 100], 'ylim', [0 (1.2*max(graphdata))], 'tag', 'GraphWindow', 'ytick', [], 'xtick', [0:20:100], 'xticklabel', [0:20:100], 'fontsize', 8);
         set(findobj(gcf, 'tag', 'XLabel'), 'string', 'Frequency (Hz)');
         set(findobj(gcf, 'tag', 'GraphAnnotation'), 'string', 'Avg. power spectrum - first 100s');
         set(findobj(gcf, 'tag', 'SigNote'), 'string', sprintf('Recorded at %i Hz', SpikeVarHeader(chosenvar).WFrequency));
      end
   end
	fclose(fid);   
end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output = coord2string(input, noloc)

if input == noloc,
   output = '';
else
   output = num2str(input);
end

