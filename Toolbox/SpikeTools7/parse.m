function output = parse(input, varargin)
% separates tab-delimited info, the optional argument 'space' will use
% spaces instead of the default use of tabs.
%
% created Spring, 1997  --WA

sepchar = 9;

if ~isempty(varargin),
   sp = varargin{:};
   if sp == 'space',
      sepchar = 32;
   else
      disp('unknown option');
      return
   end
end

input = double(input);
tabs = find(input == sepchar);
if isempty(tabs),
   output = deblank(setstr(input));
   return
end

while min(tabs == 1),
   input = input(2:length(input));
   tabs = find(input == sepchar);
end
% frame input with tabs:
il = length(input);
new_input = zeros(il+2, 1);
new_input(2:il+1) = input;
input = new_input;
input(1) = sepchar;
input(il+2) = sepchar;
tabs = find(input == sepchar);
input = setstr(input);
output = zeros(length(tabs)-1, max(diff(tabs)));
output = output + 32;
output = setstr(output);

item_counter = 0;
tab_counter = 1;

while tab_counter < length(tabs),
   if (tabs(tab_counter+1) - tabs(tab_counter)) > 1,
      item = input(tabs(tab_counter)+1:tabs(tab_counter+1)-1);
      item_counter = item_counter + 1;
      output(item_counter, 1:length(item)) = item;
   end
   tab_counter = tab_counter + 1;
end

output = output(1:item_counter, :);
output = deblank(output);