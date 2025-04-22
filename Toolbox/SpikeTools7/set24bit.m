function picture = set24bit(input, lut)
%
% This function converts an indexed image (8 bits or less) to a 24-bit true-color image
% whose pixel values range from 0 to 255.  "lut" must have values between 0 and 1.

if ndims(input) > 2,
   error('****** input image must be a 2-D bitmapped matrix ******');
   return
end

input = double(input);

[y x] = size(input);
picture = zeros(y, x, 3);

red = lut(:, 1);
green = lut(:, 2);
blue = lut(:, 3);

picture(:, :, 1) = red(input+1);
picture(:, :, 2) = green(input+1);
picture(:, :, 3) = blue(input+1);

