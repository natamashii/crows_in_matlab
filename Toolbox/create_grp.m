function [grp] = create_grp( varargin )
%CREATE_GRP(varargin) Creates grp for psth_grp from variable number of [0/1] inputs
%   Input: variable number of grp vectors containing 1 and 0.
%   Output: One grouping-file GRP, that has a 1 for frist input vecctor a 2
%           for the second,... 
%
%   Not specified Trials stay NAN

% checkoverlap of groupingvectors
for i=1:size(varargin,2)
    tocheck=1:size(varargin,2);
    tocheck(i)=[];
    for m=tocheck
        overlap=intersect(find(varargin{i}==1),find(varargin{m}==1));
        if sum(overlap)~=0
            error('ERROR: Overlapping Groups')
        end
    end
end

% create grp-file output. first input gets "1", second "2". not described
% trials stay nan
grp=nan(size(varargin{1}));
for i=1:size(varargin,2)
    grp(varargin{i})=i;
end
end

