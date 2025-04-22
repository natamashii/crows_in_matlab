function output = group_conds(cond_no, condgrps)
% SYNTAX:
%        grouped_trials = group_conds(cond_no, condgrps)
%
% where cond_no is the vector of condition numbers for each corresponding trial and condgrps
% is a matrix where each row specifies a group, or those conditions which are to be considered
% as a single condition grouping.
%
% This (simple) function replaces (the very tangled) group_conditions.
% Created 9/1/98 --WA

output = zeros(size(cond_no));

for g = 1:size(condgrps, 1),
   f = ismember(cond_no, condgrps(g, :));
   output(find(f)) = g;
end
