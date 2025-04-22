function con = sort_experiment(con_file, itm_file);
% SYNTAX:
%        cond = sort_experiment(cond_file, items_file)
%
% Creates a structure for each condition in which the TEST items are described.
% For instance, to observe TEST1 in the 50th condition:
%
% >> cond(50).TEST1
%
% ans =
%
%       item: 18
%       name: 'itemB.ctx'
%    centerx: 0
%    centery: 0
%      xsize: 0
%      ysize: 0
%      angle: 0
%      inner: []
%      outer: []
%        rgb: [0 0 0]
%     filled: 0
%
% The output, "cond", is itself a struct array of length equal to the total number of conditions.
% Created 1/15/99  --WA

directories
f = find(con_file == '\');
if isempty(f),
   con_file = strcat(dir_cortex, con_file);
end
f = find(itm_file == '\');
if isempty(f),
   itm_file = strcat(dir_cortex, itm_file);
end

[cond_matrix cond_header] = con2mat(con_file);
[item_matrix item_names item_header] = itm2mat(itm_file);

conds = cond_matrix(:, 1);

for condnumber = 1:max(conds),
   for tnumber = 1:10,
      item_number = cond_matrix(condnumber, tnumber+1);
      if item_number ~= -999,
         rownum = find(item_matrix(:, 1) == item_number);
         item_row = item_matrix(rownum, :);
         name = deblank(item_names(rownum, :));
         x = item_row(10);
         y = item_row(11);
         width = item_row(4);
         height = item_row(3);
         angle = item_row(5);
         inner = item_row(6);
         outer = item_row(7);
         if width == -999,
            width = [];
         end
         if height == -999,
            height = [];
         end
         if angle == -999,
            angle = [];
         end
         if inner == -999,
            inner = [];
         end
         if outer == -999,
            outer = [];
         end
         rgb = [item_row(12) item_row(13) item_row(14)];
         filled = item_row(9);
         TEST = struct('item', item_number, 'name', name, 'centerx', x, 'centery', y, 'xsize', width, 'ysize', height, 'angle', angle, 'inner', inner, 'outer', outer, 'rgb', rgb, 'filled', filled);
      else
         TEST = [];
      end
      command = strcat('con(', num2str(condnumber), ').TEST', num2str(tnumber-1), ' = TEST;');
      eval(command);
   end
   con(condnumber).BACKGROUND = cond_matrix(condnumber, 12);
   con(condnumber).TIMING = cond_matrix(condnumber, 13);
   con(condnumber).TRIAL_TYPE = cond_matrix(condnumber, 14);
   con(condnumber).FIX_ID = cond_matrix(condnumber, 15);
end
