function codelist = list_codes(trial_number)
% Assumes a text file called codes.mat exists in the spk files
% directory.  It is created by compile_codelist.m from a text 
% file in which the first line is assumed to be a header and 
% each line afterwards contains a code number followed by a 
% description, separated by a tab.
%
% Created Summer, 1997 --WA

directories
[SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spikestat;

load('codes.mat');
codes = SpikeInfo.CodeNumbers;
code_times = SpikeInfo.CodeTimes;
first = SpikeInfo.CodeIndex(trial_number);
last = first + SpikeInfo.CodesPerTrial(trial_number) - 1;
codes_here = SpikeInfo.CodeNumbers(first:last);
time_stamps = round(1000*(SpikeInfo.CodeTimes(first:last) - SpikeInfo.TrialStartTimes(trial_number)));

codelist = [];
for i = 1:length(codes_here),
   c = codes_here(i);
   t = time_stamps(i);
   f = find(code_number == c);
   if isempty(f),
      d = 'Code description not found';
   else
      d = code_descrip(f, :);
   end
   codeline = sprintf('%4i\t%3i\t%s', t, c, d);
   codelist = strvcat(codelist, codeline);
end
