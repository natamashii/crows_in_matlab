function output = bin_data(vector, binwidth)
% Syntax: output = bin_data(vector, binwidth)
%
% takes a horizontal vector and rebins it in binwidth size bins
% note: if number of original data point does not divide evenly by 
% binwidth, leftover points will be discarded.
% E.G. 102 points in 20 point bins, only first 100 points will be used
%
% created Summer, 1997  --EKM

[x,number_of_points] = size(vector);
number_of_bins = floor(number_of_points/binwidth);
vector = vector(:,1:number_of_bins*binwidth);
pre_bin_matrix = reshape(vector,binwidth,number_of_bins);
output = mean(pre_bin_matrix);