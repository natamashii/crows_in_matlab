function [ output ] = unique_nan( X )
%UNIQUE_NAN same as unique, but treats NAN as not distinct
%   modifies unique output to show nan only once. Works only with one
%   dimensional vectors.

temp=unique(X);
output=temp(1:find(isnan(temp),1));
end

