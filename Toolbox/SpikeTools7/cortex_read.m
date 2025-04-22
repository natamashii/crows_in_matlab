function cortex_data = cortex_read(varargin)
%	SYNTAX:
%			cortex_data = cortex_read(infile)
%
%  This routine reads a Cortex data file and returns this information as a structure.  If the
%  input file is omitted, the user will be prompted for a file to select.
%
%	Created Summer, 1998 --WA
%  Last modified 2/6/2001 --WA

directories;
SpikeConfig = spiketools_config(0);

if isempty(varargin),
	[filename pathname] = uigetfile(dir_m, mask_m);
   file = [pathname filename];
else
   file = varargin{:};
end

eyedata = {};
eppdata = {};

fid1 = fopen(file, 'r');
fseek(fid1, 0, 1);
endfile = ftell(fid1);
fseek(fid1, 0, -1);

number_of_codes = 0;

csw = findobj('tag', 'CSW');

trial = 0;
keepgoing = 1;
if isempty(csw),
   wbh = waitbar(0, 'Reading Cortex Data...');
end

atleastonespike = 0;
while keepgoing,
   trial = trial + 1;
   if isempty(csw) & trial/10 == round(trial/10),
      waitbar(ftell(fid1)/endfile, wbh);
   elseif trial/20 == round(trial/20),
      create_spk_window('ProgressBar', ftell(fid1)/endfile);
   end
   
   header = fread(fid1, 9, 'uint16');
   header(10:11) = fread(fid1, 2, 'uint8');
   header(12:14) = fread(fid1, 3, 'uint16');
   lngth = header(1);
   cond_no(trial) = header(2);
   repeat_no(trial) = header(3);
   block_no(trial) = header(4);
   trial_no(trial) = header(5);
   isi_size(trial) = header(6);
   code_size(trial) = header(7);
   eog_size(trial) = header(8);
   epp_size(trial) = header(9);
   eye_storage_ticks(trial) = header(10);
   khz_resolution(trial) = header(11);
   expected_response(trial) = header(12);
   response(trial) = header(13);
   response_error(trial) = header(14);
   h{trial} = header;
   
   if ~isempty(csw) & ((isi_size(trial) == 0) | (code_size(trial) == 0)), 
      create_spk_window('MessageBox', 'ERROR: Cannot convert to SPK file because');
      create_spk_window('MessageBox', '       some trials do not have any behavioral codes.');
      error('*** At least one trial missing all behavioral codes ***');
      return
   end
   % Each time-stamp in ctxtimes() is paired with a code in ctxcodes()
   % read in time-stamps:
   if khz_resolution(trial) == 0, khz_resolution(trial) = 1; end;
   timestamps = round(fread(fid1, isi_size(trial)/4, 'int32')/khz_resolution(trial));
   codevalues = fread(fid1, code_size(trial)/2, 'uint16');
   
   %%%DEBUG:
   f = find(codevalues == 18);
   if min(timestamps) < 0,
      disp(sprintf('Trial %i, ResponseError %i', trial, response_error(trial)))
      %keyboard
   end
   
   db(trial).codeend = ftell(fid1);
   
   behaviorindx = find(codevalues < 1000);
   ctxtimes{trial} = timestamps(behaviorindx);
   ctxcodes{trial} = codevalues(behaviorindx);
   tvec = ctxtimes{trial};
   t1 = find(ctxcodes{trial} == SpikeConfig.StartTrialCode);
   if isempty(t1) | length(t1) < SpikeConfig.StartCodeOccurrence,
      t1 = NaN;
   else
      t1 = tvec(t1(SpikeConfig.StartCodeOccurrence));
   end
   t2 = find(ctxcodes{trial} == SpikeConfig.EndTrialCode);
   if isempty(t2),
      t2 = NaN;
   else
      t2 = tvec(t2(length(t2)));
   end
   trial_duration(trial) = t2 - t1 + 1;
   number_of_codes = number_of_codes + length(ctxcodes{trial});
   
   neuronindx = find(codevalues > 999);
   if ~isempty(neuronindx),
      cluster_ids = unique(codevalues(neuronindx));
      neurons{trial} = cluster_ids;
      for ii = 1:length(cluster_ids),
         tempspiketimes{ii} = timestamps(find(codevalues == cluster_ids(ii)));
      end
      spiketimes{trial} = tempspiketimes;
      atleastonespike = 1;
   else
      neurons{trial} = [];
      spiketimes{trial} = [];
   end
      
   % read eog data
   if eog_size(trial) > 0,
      eyexy = fread(fid1, eog_size(trial)/2, 'int16');
      eyex = eyexy(1:2:length(eyexy));
      eyey = eyexy(2:2:length(eyexy));
      eyedata{trial} = [eyex eyey];
   end
      
   if epp_size(trial) > 0,
      eppdata{trial} = fread(fid1, epp_size(trial)/2, 'int16');
   end
   
   db(trial).trialend = ftell(fid1);
   testbyte = fread(fid1, 1, 'uint8');
   if isempty(testbyte),
      keepgoing = 0;
   else
      fseek(fid1, -1, 0);
   end
end

fclose(fid1);
if isempty(csw),
   close(wbh);
else
   create_spk_window('ProgressBar', 1);
end

if ~atleastonespike,
   neurons = [];
   spiketimes = [];
end

cortex_data.header = h;
cortex_data.codetimes = ctxtimes;
cortex_data.codes = ctxcodes;
cortex_data.neurons = neurons;
cortex_data.spiketimes = spiketimes;
cortex_data.eog = eyedata;
cortex_data.epp = eppdata;
cortex_data.trial_duration = trial_duration;
cortex_data.number_of_codes = number_of_codes;
