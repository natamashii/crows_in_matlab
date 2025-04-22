function pot=perf_over_time(resp,window)
% Creates a vector showing performance over time.
% Window: Size of averaging window to calculate performance over.
% Output: pot - vector with performance over "#window" trials

correrr=resp(resp(:,5)==1|resp(:,5)==0,5);%only corr & err trials

pot=nan(size(correrr,1)-window+1,1);
for i=window:size(correrr,1)
    temp_resp=correrr(i-window+1:i);
    corr=sum(temp_resp==1);
    err=sum(temp_resp==0);
    perf=corr/(corr+err);
    pot(i-window+1,1)=perf;
end

end