function trial_number = find_trial(block, condition, occurence)
% SYNTAX:
% trial_number = find_trial(block, condition, occurence)
%
% This function returns the absolute trial number corresponding to
% the n-th occurence of the specified condition within the specified
% block.  If there is no such trial, an empty matrix is returned.
%
% created 1/15/97  --WA
% last modified 3/16/2001  --WA

SpikeInfo = spikestat;

trial_number = [];
this_block = find(SpikeInfo.BlockNumber == block);
if ~isempty(this_block),
   conds_here = SpikeInfo.ConditionNumber(this_block);
   this_cond = find(conds_here == condition);
   if ~isempty(this_cond) & (occurence <= length(this_cond)),
      trial_number = this_block(this_cond(occurence));
   end
end
