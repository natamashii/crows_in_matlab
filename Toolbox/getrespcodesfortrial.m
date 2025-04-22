function [ responsecodes ] = getrespcodesfortrial(spk_file,trial_no)
%getrespcodesfortrial(spk_file,trial_no)
%
%returns the responsecodes of trial number trial_no of
%the given spk_file.
%
%Preset: Every trial starts with [9 9 9] and ends with [18 18 18]. These
%codes are not returned in responsecodes.

startcode= 9;
endcode= 18;
respi = getresponsematrix(spk_file);

trial=0;
for i=3:size(spk_file.CodeNumbers,1)
    if sum(spk_file.CodeNumbers(i-2:i)==9)==3
        firstcode=i+1;
        trial=trial+1;
    end
    if trial==trial_no
        break
    end
end
trial=0;
for i=3:size(spk_file.CodeNumbers,1)
    if sum(spk_file.CodeNumbers(i-2:i)==18)==3
        lastcode=i-3;
        trial=trial+1;
    end
    if trial==trial_no
        break
    end
end
responsecodes=spk_file.CodeNumbers(firstcode:lastcode);
end

