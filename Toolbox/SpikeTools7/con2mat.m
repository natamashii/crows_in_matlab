function [allconditions, headerline] = con2mat (infile)
% reads the cortex conditions file into a matlab matrix, allconditions
% empty fields in the con file are denoted by -999 in the matrix
% headerline contains the entire con file first line
% Only numbers that fall completely within the columns specified by the header line are read correctly.
% These columns are specified by the width of the label in the header.  ie. if header is 'TEST0 TEST1 ...'
% only numbers which fall within the five-char wide columns under the labels are read.  Nothing that is below
% a space in the header line is read.
%
% created Summer, 1997  --MH

% 7/10/98 - "header line ending in newline" bug fixed (line 39)

% this should read the items file directly also, by changing the filename.

directories;
%infile = cortex_con_file;
% specified in directories.m

[fid, message] = fopen(infile,'rt');
if fid == -1,
   error(message);
end

%read header line
readingchars = 0;
field = 1;
headerfields = zeros(64,2);
% headerfields: rows correspond to fields, column one is start pos, two is first space after start pos
%   first column in con file is numbered 1

buf = fgetl(fid);
headerline = buf;
if buf == -1,
   error('Error reading file!');
end

% add a space to the end of buf to ensure it doesn't end in a newline
buf(length(buf)+1) = ' ';

[rows cols] = size(buf);

for character = 1:cols, 
   if readingchars == 0,
      if buf(character) == ' ',
         % read next character
      else
         % we've got a char!
         readingchars = 1;
         headerfields (field, 1) = character;
      end
   else
      if buf(character) == ' ',
         readingchars = 0;
         headerfields (field, 2) = character;
         field = field + 1;
      else
         %read next char
      end
   end % if readingchars
end  % for

rows = find (headerfields(:,1)~=0);
headerfields = headerfields (rows, :);
output = headerfields;

% read each line and insert in conditions matrix

[hrows, hcols] = size(headerfields);
hend = headerfields (hrows,2);
linec = 0;
allconditions = ones (1024, hrows) * -999;

while 1,
   buf = fgetl(fid);
   linec = linec + 1;
   if ~ischar(buf),
      % trim out all unused lines
      allconditions = allconditions (1:(linec-1),1:hrows);
      break
   end
   [ brows, bcols ] = size (buf);
   buf(1, bcols+1:hend) = zeros (1, hend - bcols);
   for i=1:hrows,
      temp = sscanf (buf(1,headerfields(i,1):headerfields(i,2)), ' %d ', 1);
      %temp = str2num (buf(1,headerfields(i,1):headerfields(i,2)));
      
      if ~isempty(temp)
         allconditions(linec,i) = temp;
      end
   end
end
fclose(fid);
