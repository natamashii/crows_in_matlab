clc
close all
clear

% script to run the main script and have displayed everything to better
% present it to Lena

% pre allocation
pattern_comparison_big = {"Performance", "Response Frequency", ...
    "Reaction Times"; NaN(1), NaN(1), NaN(1)};
pattern_comparison_detail = {" ", "Performance", "Response Frequency", ...
    "Reaction Times"; "P1 vs. P2", NaN(1), NaN(1), NaN(1); ...
    "P1 vs. P3", NaN(1), NaN(1), NaN(1); ...
    "P2 vs. P3", NaN(1), NaN(1), NaN(1)};

humans = struct();
jello = struct();
uri = struct();
birds = struct();


