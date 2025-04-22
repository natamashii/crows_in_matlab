function output = shuffle(input)
% SYNTAX:
%        output = shuffle(input)
%
% This function randomly re-orders the elements of the input vector.
%
% Created 06/17/98  -- WA



 
if ndims(input) > 2 | min(size(input)) > 1,
   error('input argument must be a vector');
   return
end

t = 0;
if size(input, 1) > size(input, 2),
   input = input';
   t = 1;
end

l = length(input);

for i = 1:l,
   newl = l + 1 - i;
   r = ceil(rand(1)*newl);
   output(1, i) = input(r);
   input = cat(2, input(1:r-1), input(r+1:newl));
end

if t == 1,
   % output = output';
end
