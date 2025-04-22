function vector = str2vec(string)
% SYNTAX:
%        vector = str2vec(string)
%
% This function takes a string input and returns the corresponding vector,
% for instance: '1:2:7 10 15:18' will return [1 3 5 7 10 15 16 17 18].
%
% created Spring, 1997  --WA

newstring(2:length(string)+1) = string;
newstring(1) = '[';
newstring(length(newstring)+1) = ']';
vector = eval(newstring);
