function [ X_sorted ] = resort_to_max( X )
% RESORT_TO_MAX resorts a vector of variable length so that the maximum
%                   value lies in the center of the new sorted vector. 
% 
%   In vectors with even length the value with highest distance is doubled
%   to have a real center!
%
%   Example:
%   
%   X = [2 5 1 2 4 3]
%   becomes
%   X_sorted = [4 3 2 5 1 2 4]
%               x           x -> Value doubled to have a uneven length

%get indices of vector
ind=1:size(X,2);
max_ind=size(X,2);

%find preferred position
pref_pos=find(X==max(X));
if size(pref_pos,2)>1
    warning('#### WARNING: 2 or more positions with same FR! ####')
    warning('#### Taking first position...                   ####')
    pref_pos=pref_pos(1);
end
% pref_pos=2;

%resort to pref pos in center
shift=ceil(max_ind/2)-pref_pos;
new_ind=ind+shift;
new_ind(new_ind>max_ind)=new_ind(new_ind>max_ind)-max_ind;
new_ind(new_ind<1)=new_ind(new_ind<1)+max_ind;

%sort vector according to new_ind
[temp, new_ind_sortorder] = sort(new_ind);
X_sorted=X(new_ind_sortorder);

%adding last value to begin to have a center in vectors with even length
if mod(max_ind,2)==0 
    X_sorted=[X_sorted(end) X_sorted];
end
