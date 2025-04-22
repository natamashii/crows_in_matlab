function sort_conditions
%
% This function is called from the SPK main menu (under "groups").
% 
% created Summer, 1997, --WA
% last modified 7/20/98 


directories

spkmenu = findobj('tag', 'spkmenu');
spk_variables = get(spkmenu, 'userdata');

menuhandles = spk_variables.menuhandles;
cbo = gcbo;

if isempty(cbo) | cbo == menuhandles(9),
   
   fig = findobj('tag', 'sorter');
   if ~isempty(fig),
      delete(fig);
   end
   figure;
   set(gcf, 'tag', 'spk');
   set(gcf, 'position', [450 250 170 260], 'numbertitle', 'off', 'name', 'Sort Conditions', 'resize', 'off', 'menubar', 'none', 'tag', 'sorter');
   sort_handle(1) = uicontrol('style', 'pushbutton', 'position', [35 225 100 25], 'string', 'Select CON file', 'callback', 'sort_conditions');
   sort_handle(2) = uicontrol('style', 'popupmenu', 'position', [35 160 100 25], 'string', 'no selection', 'enable', 'off');
   h2 = uicontrol('style', 'text', 'position', [35 190 100 15], 'string', 'Sort by');
   sort_handle(3) = uicontrol('style', 'popupmenu', 'position', [35 110 100 25], 'string', 'no selection', 'enable', 'off');
   h3 = uicontrol('style', 'text', 'position', [35 140 100 15], 'string', 'And');
   sort_handle(4) = uicontrol('style', 'popupmenu', 'position', [35 60 100 25], 'string', 'no selection', 'enable', 'off');
   h4 = uicontrol('style', 'text', 'position', [35 90 100 15], 'string', 'And');
   sort_handle(5) = uicontrol('style', 'pushbutton', 'position', [35 15 100 25], 'string', 'Sort...', 'callback', 'sort_conditions', 'enable', 'off');
   
   sc_vars = struct('sort_handle', sort_handle, 'conpath', [], 'confile', []);
   set(gcf, 'userdata', sc_vars);
   
else
   sc_vars = get(gcf, 'userdata');
   sort_handle = sc_vars.sort_handle;
   
   if cbo == sort_handle(1),
      
      filtermask = strcat(dir_cortex, '*.con');
      [confile conpath] = uigetfile(filtermask, 'Select Conditions file...');
      if conpath == 0,
         return
      end
      watchon;
      [condition_matrix header] = con2mat([conpath confile]);
      header = strrep(header, ' ', '\t');
      header = parse(sprintf(header));
      choices = strvcat('no selection ', header);
      set(sort_handle(1), 'string', confile);
      set(sort_handle(2), 'enable', 'on', 'string', choices);
      set(sort_handle(3), 'enable', 'on', 'string', choices);
      set(sort_handle(4), 'enable', 'on', 'string', choices);
      set(sort_handle(5), 'enable', 'on');
      watchoff;
      
      sc_vars.conpath = conpath;
      sc_vars.confile = confile;
      set(gcf, 'userdata', sc_vars);
      
   elseif cbo == sort_handle(5),
      
      conpath = sc_vars.conpath;
      confile = sc_vars.confile;
      
      watchon;
      clear cm header compmat
      [cm header] = con2mat([conpath confile]);
      header = strrep(header, ' ', '\t');
      header = parse(sprintf(header));
      choices = strvcat('no selection ', header);
      
      condition_numbers = cm(:, 1);
      
      sortselect(1) = get(sort_handle(2), 'value');
      sortselect(2) = get(sort_handle(3), 'value');
      sortselect(3) = get(sort_handle(4), 'value');
      sortselect = sortselect - 1;
      [rows cols] = size(cm);
      for i = 1:3,
         if sortselect(i) > 0,
            compmat(1:rows, i) = cm(:, sortselect(i));
         else
            compmat(1:rows, i) = 0;
         end
      end
      
      uniq_compmat = unique(compmat, 'rows');
      [tot_comps cols] = size(uniq_compmat);
      clear grouping
      for i = 1:tot_comps,
         comp_row = uniq_compmat(i, :);
         this_group = find(compmat(:, 1) == comp_row(1) & compmat(:, 2) == comp_row(2) & compmat(:, 3) == comp_row(3));
         grouping(i, 1:length(this_group)) = this_group';
      end
      
      outfile = [dir_grp confile];
      outfile = strrep(outfile, '.con', '.txt');
      fid = fopen(outfile, 'w');
      [number_of_rows,number_of_columns] = size(grouping);
      
      for i=1:number_of_rows
         if i<10,
            grouplabel = strcat('Group  #', num2str(i));
         elseif i>9 & i<100,
            grouplabel = strcat('Group #', num2str(i));
         else
            grouplabel = strcat('Group#', num2str(i));
         end
         comprow = num2str(uniq_compmat(i, find(sortselect)));
         comprow = strrep(comprow, '-999', ' .');
         grouplabel = strcat(grouplabel, ' [', comprow,']\t\t');
         fprintf(fid, grouplabel);
         for j=1:number_of_columns
            g = grouping(i, j);
            if g ~= 0,
               fprintf(fid, '%i ', grouping(i,j));
            end
         end
         fprintf(fid,'\r\n');
      end
      fclose(fid);
      watchoff;
      disp(['Created ' outfile])
      delete(gcf)
      edit(outfile)
   end
   
end
