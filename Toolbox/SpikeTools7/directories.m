% This script loads the directory structure for SPK
% Use "directory_manager" to set and/or chnage the directories.

spk_tools_dir = which('spk');
[spk_tools_dir sname sext] = fileparts(spk_tools_dir);
dirfile = fullfile (spk_tools_dir, 'directories.mat');
if exist(dirfile) == 2,
   load(dirfile);
else
   mask_m = '*.*';
   base_dir = spk_tools_dir;
   dir_m = spk_tools_dir;
   dir_spk = spk_tools_dir;
   dir_grp = spk_tools_dir;
   dir_output = spk_tools_dir;
   dir_cortex = spk_tools_dir;
   dir_bmp = spk_tools_dir;
   dir_ctx = spk_tools_dir;
   dir_lut = spk_tools_dir;
   disp('******** directories.mat not found **********')
   save(dirfile, 'mask_m', 'base_dir', 'dir_m', 'dir_spk', 'dir_grp', 'dir_cortex', 'dir_output', 'dir_bmp', 'dir_ctx', 'dir_lut');
   disp('******** Default directories.mat created *********')
end


