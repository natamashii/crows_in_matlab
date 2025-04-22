function [blockstart, blockend]=block_resp(respi,blocksize,collumn,block_by1,varargin)
% [blockstart, blockend]=block_resp(respi,blocksize,collumn,block_by1,varargin(block_by2))
%
% Calculates block borders for a resp-matrix.
% Blocks contain the number of BLOCKSIZE trials that have a code of
% block_by1 (and block_by2/varargin) in the collumn COLLUMN of the
% resp-matrix.
% 
%Returs a vektor with blockstarts and blockends, where blockstart(i)
%corresponds to blockend(i)
%
if isempty(varargin)~=1
    block_by2=varargin{1};
end

if isempty(varargin)~=1
    cumcorr=cumsum(respi(:,collumn)==block_by1|respi(:,collumn)==block_by2);
else
    cumcorr=cumsum(respi(:,collumn)==block_by1);
end
blockstart=[1];
for i=blocksize+1:blocksize:cumcorr(end)
    blockstart=[blockstart find(cumcorr==i,1)];
end
blockend=[blockstart(2:end)-1 size(respi,1)];
end