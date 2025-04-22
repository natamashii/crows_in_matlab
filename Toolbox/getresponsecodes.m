function responsecodes=getresponsecodes(varargin)
% [responsecodes]=getresponsecodes(filename) 
%                
%       extracts responsecode for all trials and outputs a cell array with
%       a cell for each trial.
%       Popup for manual choosing of file when no input.
%   
%       Example: responsecode=getresponsecodes('V161103')
%                or
%                responsecode=getresponsecodes for manual input
%
%       -pr2016

if ~isempty(varargin)
    filename=varargin{1};
else
    cd('H:\_Dropbox\Dropbox\MATLAB\data')
    [filename, ~] = uigetfile( ...
        {'*.1', 'Training File (*.1)';...
        '*.1', 'Training File (*.1)';...
        '*.0', 'Recording File (*.0)';...
        '*.*',  'All Files (*.*)'}, ...
        'Select Recording file', 'MultiSelect', 'off');
    cd('H:\_Dropbox\Dropbox\MATLAB')
    filename=filename(1:end-2);
end

[spk_file, resp]=load_spk(filename);

idx=1:size(spk_file.CodeNumbers,1); %true code number position
idx=idx(spk_file.CodeNumbers~=116)'; %index vector with true code number positions without 116 codes
Codes=spk_file.CodeNumbers(spk_file.CodeNumbers~=116); %Codes without 116 corresponding to idx as position

last9=nan(size(resp,1),1);%preallocation
counter=1;
for i=3:size(Codes,1) %extract position of last 9 of  999-triplet
    if sum(Codes(i-2:i)==9)==3
        last9(counter,1)= idx(i); %take code number position
        counter=counter+1;
    end
end


first18=nan(size(resp,1),1); %preallocation
counter=1;
for i=1:size(Codes,1)-2 %extract position of first 18 of  181818-triplet
    if sum(Codes(i:i+2)==18)==3
        first18(counter,1)=idx(i);
        counter=counter+1;
    end
end
responsecodes=cell(size(resp,1),1); %preallocation
for i=1:size(last9,1)
    if first18(i)-last9(i)>1 
    responsecodes{i}=spk_file.CodeNumbers(last9(i)+1:first18(i)-1);
    else %empty cell for trials with no response code
        warning('Trial %d without any responsecodes!',i)
        continue
    end
end