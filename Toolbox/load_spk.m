function [spk_file, resp] = load_spk( day )
%LOAD_SPK loads spk-file and returns resp and spk_file
%   day = string of day to load (e.g. 'W150924')
%   Returns: [spk_file resp]

% clc
spk_file = spk_read([cd, '\Data\spk\' day]);
resp = getresponsematrix(spk_file);
end

