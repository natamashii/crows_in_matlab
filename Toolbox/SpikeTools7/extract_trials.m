function [start_indx, end_indx, start_times, end_times] = extract_trials(codes, codetimes, fcheck)
% This function is used by NexCortex2SPK to determine the absolute times at which individual
% trials start and end.
%
% Created February, 2001 --WA
% Last modified, 3/22/2001 --WA

load('spk_cfg.mat');

if prod(size(codes)) > length(codes) | prod(size(codetimes)) > length(codetimes),
   error('***** Inputs to extract_trials.m must be vectors *****');
   return;
end

if size(codes, 2) > size(codes, 1), codes = codes'; end;
if size(codetimes, 2) > size(codetimes, 1), codetimes = codetimes'; end;
if isempty(find(codes == SpikeConfig.StartTrialCode)) | isempty(find(codes == SpikeConfig.EndTrialCode)),
   msg = 'Error: Start and/or End Trial codes missing!!!!';
   create_spk_window('MessageBox', msg);
   error(msg);
   return
end

fcodes = find(codes == SpikeConfig.StartTrialCode | codes == SpikeConfig.EndTrialCode);
tcodes = codes(fcodes);
tcodetimes = codetimes(fcodes);
tcodes(find(tcodes == SpikeConfig.StartTrialCode)) = 1;
tcodes(find(tcodes == SpikeConfig.EndTrialCode)) = 2;
dcodes = cat(1, diff(tcodes), 0);
end_indx = find(dcodes == -1);
start_indx = end_indx + 1;
start_indx = start_indx(find(start_indx <= length(tcodes)));

if min(find(tcodes == 1)) < min(start_indx),
   start_indx = cat(1, min(find(tcodes == 1)), start_indx);
else %end trial code precedes first start trial code
   end_indx = end_indx(2:length(end_indx));
   msg = 'Warning: Data begins mid-trial; Using only complete trials';
   create_spk_window('MessageBox', msg);
end

if max(find(tcodes == 2)) > max(end_indx),
   end_indx = cat(1, end_indx, max(find(tcodes == 2)));
else %last start trial code follows last end trial code
   start_indx = start_indx(1:length(start_indx)-1);
   msg = 'Warning: Data ends mid-trial; Truncating to include only complete trials';
   create_spk_window('MessageBox', msg);
end

if SpikeConfig.StartCodeOccurrence > 1,
   for trial = 1:length(start_indx),
      this_trial = start_indx(trial):end_indx(trial);
      start_codes = find(tcodes(this_trial) == 1);
      if length(start_codes) < SpikeConfig.StartCodeOccurrence,
         msg = sprintf('Warning: Specified instance of Start Trial Code not found in trial %i', trial);
         create_spk_window('MessageBox', msg);
         msg = sprintf('      ...Will use latest occurrence (#%i)', max(start_codes));
         create_spk_window('MessageBox', msg);
         start_indx(trial) = start_indx(trial) + max(start_codes) - 1;
      else
         start_indx(trial) = start_indx(trial) + start_codes(SpikeConfig.StartCodeOccurrence) - 1;
      end
   end
end

start_times = tcodetimes(start_indx);
end_times = tcodetimes(end_indx);

start_indx = fcodes(start_indx);
end_indx = fcodes(end_indx);

tdurations = end_times - start_times;
f = find(tdurations <= 0);
if ~isempty(f),
   msg = sprintf('Warning: %i/%i trials have zero duration -- trial #''s in log file', length(f), length(start_times));
   create_spk_window('MessageBox', msg);
   fprintf(fcheck, 'Warning: These trials have zero duration:\r\n');
   fprintf(fcheck, sprintf('%i ', f));
   fprintf(fcheck, sprintf('\r\n\r\n'));
end

   