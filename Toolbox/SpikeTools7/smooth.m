function output = smooth_data(input, window, kernel_type)
% Smoothing function: 
% output = smooth_data(input, window, type)
% "Type" should be set to 'gauss' for a gaussian kernel or to 'boxcar'
% for a simple moving window average.  "Window" is the total kernel width.
% Input array must be one-dimensional.
%
% last modified November, 1999  -- WA

input_dims = ndims(input);
input_size = size(input);
if input_dims > 2 | min(input_size) > 1,
   disp('Input array is too large.');
   return
end

if window < 1 | (window ~= round(window)),
   error('********** Invalid smooth window argument **********');
   return
end

if window == 1,
   output = input;
   return
end

if kernel_type(1:3) == 'bin',
   if input_size(1) > input_size(2),
      input = input';
      toggle_dims = 1;
   else
      toggle_dims = 0;
   end
   output = bin_data(input, window);
   if toggle_dims == 1,
      output = output';
   end
   return
end

if input_size(2) > input_size(1),
   input = input';
   toggle_dims = 1;
else
   toggle_dims = 0;
end

if window/2 ~= round(window/2),
   window = window + 1;
end
halfwin = window/2;

input_length = length(input);

if kernel_type(1:5) == 'gauss',
   x = -halfwin:1:halfwin;
   kernel = exp(-x.^2/(window/2)^2);
else
   kernel = ones(window, 1);
end
kernel = kernel/sum(kernel);

mn1 = mean(input(1:halfwin));
mn2 = mean(input((input_length-halfwin):input_length));
padded(halfwin+1:input_length+halfwin) = input;
padded(1:halfwin) = ones(halfwin, 1)*mn1;
padded(length(padded)+1:length(padded)+halfwin) = ones(halfwin, 1)*mn2;

output = conv(padded, kernel);
output = output(window+1:input_length+window);

if toggle_dims == 0,
   output = output';
end

