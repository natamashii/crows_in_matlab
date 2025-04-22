function resp = getresponsematrix(spk_file)
%Get response matrix from spk_file

raw = spk_file.Response;
raw = char(num2str(raw)); %converts to char-array
for i=find(raw(:,1)==' ')' % !!! Esc-trials ('    0') are converted to '99999'
    raw(i,:)='99999';
end
resp_raw = nan(size(raw)); 
for z=1:size(raw,1)
    for s=1:size(raw,2)
        resp_raw(z,s)=str2num(raw(z,s));
    end
end
resp = resp_raw;
