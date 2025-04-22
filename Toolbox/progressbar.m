function progressbar(counter,goal)
%progressbar(counter,goal) displays a progressbar in 10 percent steps according to the
%progress of counter relative to goal
%
% example: counter is the counting variable and goal is the last value of
% the counting variable possible in a for loop:
%
% for i=1:10
%       progressbar(i,10)
%       pause(1)
% end
percent_10=round(counter/goal*10); %how many 10-percent steps
clc
fprintf(strcat('\n\tProgress:\t',repmat(char(9632),1,percent_10), repmat(char(9633),1,10-percent_10),'\t-\t',num2str(round(counter/goal*100)),'%%\n\n'))
% fprintf('TEST: %d',counter)
end

%% print ascii chars table
% for i = 1:10000
%     str = [num2str(i) ' ' char(i)];
%     disp(str)
% end
