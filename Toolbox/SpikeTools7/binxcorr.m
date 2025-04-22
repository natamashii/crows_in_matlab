function correlogram = binxcorr(inputA, inputB, halfwin)
%cross correlation for binary arrays:
%cc = xcorr(A, B, window)
%peak shifted to right = first input leads
%each input can be a matrix of multiple spike trains, arranged trials x time
%
%created 3/3/97  --GR & WA
%last modified 8/26/99 --WA

if any(size(inputA) ~= size(inputB)),
   error('***** Both inputs must be the same size *****');
   return
end

if ndims(inputA) == 2 & min(size(inputA)) == 1 & size(inputA, 1) > size(inputA, 2),
   inputA = inputA';
   inputB = inputB';
end

window = 2*halfwin + 1;

[numtrialsA lnA] = size(inputA);
[numtrialsB lnB] = size(inputB);

zero_pad = zeros(numtrialsA, halfwin);
inputA = cat(2, zero_pad, inputA, zero_pad);
inputB = cat(2, zero_pad, inputB, zero_pad);
lnA = lnA + (2*halfwin);
lnB = lnB + (2*halfwin);
A = inputA(:, halfwin+1:lnA-halfwin);

for i = 1:window,
   B = inputB(:, i:lnB-window+i);
   ABcor(i) = sum(sum(A&B));
end

norm_factor = sqrt(sum(sum(inputA)) * sum(sum(inputB)));
if norm_factor > 0,
   correlogram = ABcor./norm_factor;
else
   correlogram = zeros(1, window);
end

