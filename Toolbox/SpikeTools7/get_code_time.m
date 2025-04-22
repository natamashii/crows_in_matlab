function codetimes = get_code_time(trials, codenumber, varargin)
%	SYNTAX:
%			codetimes = get_code_time(trials, codenumber, occurrence)
%
%	Trials is a vector of trial numbers, codenumber is the behavioral code for which you wish the timestamp
%	(relative to the beginning of each trial), and occurrence is an optional argument which can specify the
%	which occurrence of the code to use, if multiple occurrences are present in each trial.  If a code is 
%	not present in a requested trial, NaN is returned.
%
%	SpikeTools 7 version
%	Created 2/12/2001 --WA

[SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spikestat;

if isempty(varargin),
   occurrence = 1;
else
   occurrence = varargin{1};
end

codetimes = zeros(length(trials), 1);
tstarts = round(1000*SpikeInfo.TrialStartTimes); %convert to milliseconds
ctimes = round(1000*SpikeInfo.CodeTimes);
cnumbers = SpikeInfo.CodeNumbers;

cindex = SpikeInfo.CodeIndex(trials);
cptrial = SpikeInfo.CodesPerTrial(trials);

for i = 1:length(trials),
   t = trials(i);
   firstcode = SpikeInfo.CodeIndex(t);
   chooser = firstcode:(firstcode + SpikeInfo.CodesPerTrial(t) - 1);
   trialcodetimes = ctimes(chooser) - tstarts(t);
   trialcodenumbers = cnumbers(chooser);
   f = find(trialcodenumbers == codenumber);
   if isempty(f),
      codetimes(i) = NaN;
   else
      if occurrence > length(f),
         occurrence = length(f);
         disp(sprintf('Warning: specified occurrence of code %i not found in trial %i; using latest occurrence (#%i)', codenumber, t, length(f)));
      end
      codetimes(i) = trialcodetimes(f(occurrence)); %take care of occurrence option...
   end
end
