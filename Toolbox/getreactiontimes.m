function RT=getreactiontimes(spk_file,first,last,resp_grp)
% RT=getreactiontimes(spk_file,first,last,resp_grp)
%
% Calculates difference between eventcodes "last" and "last" in all Trials
% of resp_grp(X,1)==1
% 
%
% Example getreactiontimes(spk_file, 40, 41, [resp_grouping vector with 1 for correct trials, 0 for other trials]):
%        Time difference between eventcode 41 and 40 in correct trials
%
% -pr

TrialStartTimes_grp=spk_file.TrialStartTimes(resp_grp); %Start and End-Times for resp_grp
TrialEndTimes_grp=spk_file.TrialEndTimes(resp_grp);

counter=0;
for Trial=1:size(TrialEndTimes_grp, 1)
    Times = spk_file.CodeTimes(find(spk_file.CodeTimes==TrialStartTimes_grp(Trial,:)): ...
                                find(spk_file.CodeTimes==TrialEndTimes_grp(Trial,:)),:); 
                            
    Codes = spk_file.CodeNumbers(find(spk_file.CodeTimes==TrialStartTimes_grp(Trial,:)):...
                                  find(spk_file.CodeTimes==TrialEndTimes_grp(Trial,:)),:);
    
    if sum(Codes==first | Codes==last) == 2
        counter=counter+1;
        RT(counter) = Times(Codes==last)- Times(Codes==first);
    else
%         warning('###### WARNING: Trials without FRIST- and LAST-code ######') %trial is skipped
        warning('###### WARNING: Trials without FRIST- and LAST-code ######\n         ###### Skipping Trial No. %d                         ######',Trial) %trial is skipped
    end
end

if ~exist('RT','var') 
    RT = 0;
    warning('No Trials to calculate reaction time for. Set RT struct to 0')
end

