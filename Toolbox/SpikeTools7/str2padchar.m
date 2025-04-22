function outputstring = str2padchar(inputstring, sz)

if length(inputstring) > (sz-1),
   outputstring = double(inputstring(1:sz));
else
   [isize d] = max(size(inputstring));
   padding = zeros((sz - isize), 1);
   if d == 2,
      padding = padding';
   end
   outputstring = cat(d, double(inputstring), padding);
end
