function dmn_gr_plot(filename)
% e.g. filename = 'J050825'
% patterns = array with included patterns, e.g. = 4 or 1:1:3
%% Plot performance parameters of DMN task with numbers 1-6 dependent on pattern
% Pattern 1 == eq. distant
% pattern 2 == additive (chunking)
% pattern 3 == multiplictive (grouping)

disp(filename);

% Load data
[spk_data,resp_mat] = load_spk(filename);

%% Examplary performance curve for pattern 1

% Indices
P1_idx = resp_mat(:,2)==1; %pattern 1 == similar distance
P2_idx = resp_mat(:,2)==2; %pattern 2 == additive subgroups (max diff)
P3_idx = resp_mat(:,2)==3; %pattern 3 == multiplicative subgroups (min diff)
PR_idx = resp_mat(:,2) == 4; % P3 vs P3
correct_idx = resp_mat(:,5)==0; %correct trials
badpk_idx = resp_mat(:,5)==9; %badpecks
aborted_idx = resp_mat(:,5)==9 & resp_mat(:,3)~=9; %aborted trials after sample was seen
error_idx = resp_mat(:,5)~=0 & resp_mat(:,5)~=9; %error trials
standard_idx = resp_mat(:,1)==1; %standard stimuli
control_idx = resp_mat(:,1)==2; %control stimuli
match_idx = resp_mat(:,4)==0 & resp_mat(:,5)~=9; %match trials
nonmatch_idx = resp_mat(:,4)>0 & resp_mat(:,5)~=9; %nonmatch tr.

% extract condition numbers of pattern 4
condition_nrs = spk_data.ConditionNumber;
pr_idx = find(condition_nrs > 180);

% Parameters
spl_nums =  3:1:7;
test_nums = 1:1:10;
tc_col = jet(6);
window_l = 10; %for running performance
smooth_span = 60; %for running performance plot
tc_colb = jet(10);
rperf_col = [tc_colb(5,:);tc_colb(10,:);.7,.7,.7];
bin_width = 25; % for RT histogram
trial_types = {'match','nonmatch'}; % for RT histogram
sub_sets = {'P1','P2','P3','PR'}; % Stimulus subsets for tuning curve plot, could include protocol as well
lstyles = {'-','--',':','-'};
symbols = {'o','s','d', 'p'}; %{'d','o','o','s','s'};
c_pattern = {'b','r','g', 'm'};
sub_lbl = {'Average','Standard','Control'};%'Average','Standard','Control';
tr_outc = {'correct','error','badpk'};

% response matrix
% col 1: stimulus type (standard (1) or control (2))
% col 2: pattern type (P1, P2, P3, P4)
% col 3: sample 
% col 4: match or non-match (referring to Lena's table with test 1-3)
% col 5: bird response evaluation
% col 6: test numerosity

% 0 = correct
% 1 = error by bird
% 9 = abundance by bird

% Find test numerosity and write in 6th column
resp_mat(:,6)=0;
% iterating over trials
for trial_idx = 1:1:size(resp_mat,1)
    % correction: 8 should be 3
    if resp_mat(trial_idx,3) == 8
        resp_mat(trial_idx,3) = 3; % sample 3 nicht 8 (correction for timing file)
    end
    % match trials
    if resp_mat(trial_idx,4)==0
        resp_mat(trial_idx,6)=resp_mat(trial_idx,3) ; 
    % nonmatch trials
    else 
        % for P1, P2 and P3:
        if resp_mat(trial_idx, 2) ~= 4
            % if test was test 1
            if resp_mat(trial_idx,4) == 1
                if resp_mat(trial_idx,3)==4 % sample == 4
                    resp_mat(trial_idx,6) = 2;
                elseif resp_mat(trial_idx,3)==5
                    resp_mat(trial_idx,6) = 3;
                elseif resp_mat(trial_idx,3)==6
                    resp_mat(trial_idx,6) = 3; %4;
                elseif resp_mat(trial_idx,3)==7
                    resp_mat(trial_idx,6) = 3; %4;
                elseif resp_mat(trial_idx,3)==3 %
                    resp_mat(trial_idx,6) = 2;
                end
                % if test was test 2
            elseif resp_mat(trial_idx,4) == 2
                if resp_mat(trial_idx,3)==4 % sample == 4
                    resp_mat(trial_idx,6) = 6;
                elseif resp_mat(trial_idx,3)==5
                    resp_mat(trial_idx,6) = 7;
                elseif resp_mat(trial_idx,3)==6
                    resp_mat(trial_idx,6) = 4;
                elseif resp_mat(trial_idx,3)==7
                    resp_mat(trial_idx,6) = 4; %5;
                elseif resp_mat(trial_idx,3)==3
                    resp_mat(trial_idx,6) = 5;
                end
                % if test was test 3
            elseif resp_mat(trial_idx,4) == 3
                if resp_mat(trial_idx,3)==4 % sample == 4
                    resp_mat(trial_idx,6) = 7;
                elseif resp_mat(trial_idx,3)==5
                    resp_mat(trial_idx,6) = 8;
                elseif resp_mat(trial_idx,3)==6
                    resp_mat(trial_idx,6) = 9;
                elseif resp_mat(trial_idx,3)==7
                    resp_mat(trial_idx,6) = 10;
                elseif resp_mat(trial_idx,3)==3 % sample 3
                    resp_mat(trial_idx,6) = 6;
                end
            end
        % for P4
        else
            % if test was 4
            if resp_mat(trial_idx, 4) ~= 1
                if resp_mat(trial_idx, 3) == 4
                    resp_mat(trial_idx, 6) = 6;
                elseif resp_mat(trial_idx, 3) == 6
                    resp_mat(trial_idx, 6) = 4;
                end
            end
        end
    end
end


%% Initiate figure

figure('Color','w','visible','on','Units','normalized','OuterPosition',...
    [.2 .7 .7 3])
drawnow
% get(groot,'default')
set(groot,{'DefaultAxesColor','DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor',...
    'DefaultTextColor','defaultAxesGridColor','defaultPatchFaceColor',...
    'defaultLineColor'},{'none','k','k','k','k','k','k','k'});

average_all = nan(length(spl_nums),3);

%% Legend

axes('Position',[.0 .0 .0 .0]); % initiate axis
for spl = 1:1:length(spl_nums) 
    plot(0,0,'-o','Color',tc_col(spl,:),'LineStyle','-',...
        'MarkerFaceColor',tc_col(spl,:),'Markersize',10,...
        'LineWidth',1.5)
    hold on
end
% plot(0,0,'LineStyle','--','LineWidth',1.5 ...
%     ,'Color','k')
leg_h2 = legend('3','4','5','6','7','Position',[.75 .85 .05 .01],'orientation','horizontal');
leg_h2.Color ="none";
leg_h2.TextColor = "k";
title(leg_h2,'Sample');
fontsize(16,"points")


%% Plot performance curves P1

% Plot
axes('Position',[.13 .8 .4 .18]);

% Preallocation
perf_all = nan(length(spl_nums),length(test_nums),length(sub_sets));  % nan(length(spl_nums),length(y_nums),length(sub_sets));

% Loop over samples
for spl = 1:1:length(spl_nums) %idx
     
    % Index all trials for current sample
    sample = spl_nums(spl);
    sample_idx = resp_mat(:,3)==sample;

    % Loop over subsets/ patterns, currently only P1
    for subs = 1 %1:1:3 %4 %1:1:1 
        
        % Current subset index
        curr_idx = eval(sprintf('%s_idx & sample_idx;',sub_sets{subs}));
        
        % Loop over test1 numerosities
        for test1 = 1:length(test_nums)
            %Current answer numerosity
            test1_idx = resp_mat(:,6) == test1;
            
            if sample==test1
                % Match trials
                perf_all(spl,test1,subs) = sum(curr_idx & test1_idx & correct_idx)...
                    / ( sum(curr_idx & test1_idx & correct_idx)+sum(curr_idx & test1_idx & error_idx) );
            else
                % Nonmatch trials
                perf_all(spl,test1,subs) = sum(curr_idx & test1_idx & error_idx)...
                    / ( sum(curr_idx & test1_idx & correct_idx)+sum(curr_idx & test1_idx & error_idx) );
            end
        end
        % Plot
        hold on
        if subs ~= 4
            p_idx = ~any(isnan(perf_all(spl,:,subs)),1);
            % plot values of current sample and subset
            plot(test_nums(p_idx),perf_all(spl,p_idx,subs),'Color',tc_col(spl,:),...
                'LineWidth',1,'LineStyle',lstyles{subs},...
                'Marker',symbols{subs},'MarkerSize',8,...
                'MarkerFaceColor',tc_col(spl,:),'MarkerEdgeColor',tc_col(spl,:)); %plot
        elseif subs == 1
            p_idx = ~any(isnan(perf_all(spl,:,subs)),1);
            plot(test_nums(p_idx),perf_all(spl,p_idx,subs),'Color',tc_col(spl,:),...
                'LineWidth',1.5,'LineStyle',lstyles{subs},...
                'Marker',symbols{1},'MarkerSize',10,...
                'MarkerFaceColor',tc_col(spl,:),'MarkerEdgeColor','k'); %plot
        end
        % save average
        av_perf = sum(correct_idx & curr_idx) / ( sum(curr_idx & error_idx ) + sum(curr_idx & correct_idx) );
        % plot([sample],[av_perf],'p','MarkerFaceColor','k','MarkerSize',12);
        average_all(spl,subs) = av_perf;
    end
end
% Percent correct (for title)
perc_corr = sum(correct_idx)/sum(correct_idx | error_idx)*100;

% MIP

%set(gca,'xscale','log'); %set log axes at end for all 
set(gca,'Box','off','TickDir','out','YGrid','on','YTick',.2:.2:1,...
    'YLim',[0 1],'XLim',[min(test_nums)-.25 ,max(test_nums)+.25],...
    'XTick',test_nums,'XTickLabel',sprintfc('%d',test_nums))
xlabel('Test 1')
ylabel('Response frequency')
title('Pattern 1 (no subgroups)')





%% Plot performance curves P2 (additiv)

% Plot
axes('Position',[.13 .55 .4 .18]);

% Preallocation
perf_all = nan(length(spl_nums),length(test_nums),length(sub_sets));  % nan(length(spl_nums),length(y_nums),length(sub_sets));

% Loop over samples
for spl = 1:1:length(spl_nums) %idx
     
    % Index all trials for current sample
    sample = spl_nums(spl);
    sample_idx = resp_mat(:,3)==sample;

    % Loop over subsets/ patterns, currently only P1
    for subs = 2 %1:1:3 %4 %1:1:1 
        
        % Current subset index
        curr_idx = eval(sprintf('%s_idx & sample_idx;',sub_sets{subs}));
        
        % Loop over test1 numerosities
        for test1 = 1:length(test_nums)
            %Current answer numerosity
            test1_idx = resp_mat(:,6) == test1;
            
            if sample==test1
                % Match trials
                perf_all(spl,test1,subs) = sum(curr_idx & test1_idx & correct_idx)...
                    / ( sum(curr_idx & test1_idx & correct_idx)+sum(curr_idx & test1_idx & error_idx) );
            else
                % Nonmatch trials
                perf_all(spl,test1,subs) = sum(curr_idx & test1_idx & error_idx)...
                    / ( sum(curr_idx & test1_idx & correct_idx)+sum(curr_idx & test1_idx & error_idx) );
            end
        end
        % Plot
        hold on
        if subs ~= 4
            p_idx = ~any(isnan(perf_all(spl,:,subs)),1);
            % plot values of current sample and subset
            plot(test_nums(p_idx),perf_all(spl,p_idx,subs),'Color',tc_col(spl,:),...
                'LineWidth',1,'LineStyle',lstyles{subs},...
                'Marker',symbols{subs},'MarkerSize',8,...
                'MarkerFaceColor',tc_col(spl,:),'MarkerEdgeColor',tc_col(spl,:)); %plot
        elseif subs == 4
            p_idx = ~any(isnan(perf_all(spl,:,subs)),1);
            plot(test_nums(p_idx),perf_all(spl,p_idx,subs),'Color',tc_col(spl,:),...
                'LineWidth',1.5,'LineStyle',lstyles{subs},...
                'Marker',symbols{1},'MarkerSize',10,...
                'MarkerFaceColor',tc_col(spl,:),'MarkerEdgeColor','k'); %plot
        end
        % plot average
        av_perf = sum(correct_idx & curr_idx) / ( sum(curr_idx & error_idx ) + sum(curr_idx & correct_idx) );
        % plot([sample],[av_perf],'p','MarkerFaceColor','k','MarkerSize',12);
        average_all(spl,subs) = av_perf;
    end
end
% Percent correct (for title)
perc_corr = sum(correct_idx)/sum(correct_idx | error_idx)*100;

% MIP

%set(gca,'xscale','log'); %set log axes at end for all 
set(gca,'Box','off','TickDir','out','YGrid','on','YTick',.2:.2:1,...
    'YLim',[0 1],'XLim',[min(test_nums)-.25 ,max(test_nums)+.25],...
    'XTick',test_nums,'XTickLabel',sprintfc('%d',test_nums))
xlabel('Test 1')
ylabel('Response frequency')
title('Pattern 2 (additiv)')
fontsize(16,"points")


%% Plot performance curves P3 (multiplikativ)

% Plot
axes('Position',[.13 .3 .4 .18]);

% Preallocation
perf_all = nan(length(spl_nums),length(test_nums),length(sub_sets));  % nan(length(spl_nums),length(y_nums),length(sub_sets));

% Loop over samples
for spl = 1:1:length(spl_nums) %idx
     
    % Index all trials for current sample
    sample = spl_nums(spl);
    sample_idx = resp_mat(:,3)==sample;

    % Loop over subsets/ patterns, currently only P1
    for subs = 3 %1:1:3 %4 %1:1:1 
        
        % Current subset index
        curr_idx = eval(sprintf('%s_idx & sample_idx;',sub_sets{subs}));
        
        % Loop over test1 numerosities
        for test1 = 1:length(test_nums)
            %Current answer numerosity
            test1_idx = resp_mat(:,6) == test1;
            
            if sample==test1
                % Match trials
                perf_all(spl,test1,subs) = sum(curr_idx & test1_idx & correct_idx)...
                    / ( sum(curr_idx & test1_idx & correct_idx)+sum(curr_idx & test1_idx & error_idx) );
            else
                % Nonmatch trials
                perf_all(spl,test1,subs) = sum(curr_idx & test1_idx & error_idx)...
                    / ( sum(curr_idx & test1_idx & correct_idx)+sum(curr_idx & test1_idx & error_idx) );
            end
        end
        % Plot
        hold on
        if subs ~= 4
            p_idx = ~any(isnan(perf_all(spl,:,subs)),1);
            % plot values of current sample and subset
            plot(test_nums(p_idx),perf_all(spl,p_idx,subs),'Color',tc_col(spl,:),...
                'LineWidth',1,'LineStyle',lstyles{subs},...
                'Marker',symbols{subs},'MarkerSize',8,...
                'MarkerFaceColor',tc_col(spl,:),'MarkerEdgeColor',tc_col(spl,:)); %plot
        elseif subs == 4
            p_idx = ~any(isnan(perf_all(spl,:,subs)),1);
            plot(test_nums(p_idx),perf_all(spl,p_idx,subs),'Color',tc_col(spl,:),...
                'LineWidth',1.5,'LineStyle',lstyles{subs},...
                'Marker',symbols{1},'MarkerSize',10,...
                'MarkerFaceColor',tc_col(spl,:),'MarkerEdgeColor','k'); %plot
        end
        % plot average
        av_perf = sum(correct_idx & curr_idx) / ( sum(curr_idx & error_idx ) + sum(curr_idx & correct_idx) );
        % plot([sample],[av_perf],'p','MarkerFaceColor','k','MarkerSize',12);
        average_all(spl,subs) = av_perf;
    end
end
% Percent correct (for title)
perc_corr = sum(correct_idx)/sum(correct_idx | error_idx)*100;

% MIP

%set(gca,'xscale','log'); %set log axes at end for all 
set(gca,'Box','off','TickDir','out','YGrid','on','YTick',.2:.2:1,...
    'YLim',[0 1],'XLim',[min(test_nums)-.25 ,max(test_nums)+.25],...
    'XTick',test_nums,'XTickLabel',sprintfc('%d',test_nums))
xlabel('Test 1')
ylabel('Response frequency')
title('Pattern 3 (multiplikativ)')
fontsize(16,"points")

%% Plot performance curves P4 (grouped vs. grouped)

% Plot
axes('Position',[.13 .05 .4 .18]);

% Preallocation
perf_all = nan(length(spl_nums),length(test_nums),length(sub_sets));  % nan(length(spl_nums),length(y_nums),length(sub_sets));

% Loop over samples
for spl = 1:1:length(spl_nums) %idx
     
    % Index all trials for current sample
    sample = spl_nums(spl);
    sample_idx = resp_mat(:,3)==sample;

    % Loop over subsets/ patterns, currently only P1
    for subs = 4 %1:1:3 %4 %1:1:1 
        
        % Current subset index
        curr_idx = eval(sprintf('%s_idx & sample_idx;',sub_sets{subs}));
        
        % Loop over test1 numerosities
        for test1 = 1:length(test_nums)
            %Current answer numerosity
            test1_idx = resp_mat(:,6) == test1;
            
            if sample==test1
                % Match trials
                perf_all(spl,test1,subs) = sum(curr_idx & test1_idx & correct_idx)...
                    / ( sum(curr_idx & test1_idx & correct_idx)+sum(curr_idx & test1_idx & error_idx) );
            else
                % Nonmatch trials
                perf_all(spl,test1,subs) = sum(curr_idx & test1_idx & error_idx)...
                    / ( sum(curr_idx & test1_idx & correct_idx)+sum(curr_idx & test1_idx & error_idx) );
            end
        end
        % Plot
        hold on
        p_idx = ~any(isnan(perf_all(spl,:,subs)),1);
        % plot values of current sample and subset
        plot(test_nums(p_idx),perf_all(spl,p_idx,subs),'Color',tc_col(spl,:),...
            'LineWidth',1,'LineStyle',lstyles{subs},...
            'Marker',symbols{subs},'MarkerSize',8,...
            'MarkerFaceColor',tc_col(spl,:),'MarkerEdgeColor',tc_col(spl,:)); %plot

        % plot average
        av_perf = sum(correct_idx & curr_idx) / ( sum(curr_idx & error_idx ) + sum(curr_idx & correct_idx) );
        % plot([sample],[av_perf],'p','MarkerFaceColor','k','MarkerSize',12);
        average_all(spl,subs) = av_perf;
    end
end
% Percent correct (for title)
perc_corr = sum(correct_idx)/sum(correct_idx | error_idx)*100;

% MIP

%set(gca,'xscale','log'); %set log axes at end for all 
set(gca,'Box','off','TickDir','out','YGrid','on','YTick',.2:.2:1,...
    'YLim',[0 1],'XLim',[min(test_nums)-.25 ,max(test_nums)+.25],...
    'XTick',test_nums,'XTickLabel',sprintfc('%d',test_nums))
xlabel('Test 1')
ylabel('Response frequency')
title('Pattern 4 (grouped vs. grouped)')
fontsize(16,"points")


%% Plot average

axes('Position',[.68 .43 .25 .18]);
hold on
for subs = 1:1:4
    plot(spl_nums, average_all(:,subs).', 'color', c_pattern{subs}, 'Marker',symbols{subs},...
        'MarkerSize',10,'LineStyle',lstyles{subs},'LineWidth',1);
end
hold off

% MIP
set(gca,'Box','off','TickDir','out','YGrid','on','YTick',.2:.2:1,...
    'YLim',[0 1],'XLim',[min(spl_nums)-.25 ,max(spl_nums)+.25],...
    'XTick',spl_nums,'XTickLabel',sprintfc('%d',spl_nums))
xlabel('Sample')
ylabel('Performance')
title('Average performance')
fontsize(16,"points")

%% Legend

axes('Position',[.0 .0 .0 .0]); % initiate axis
for subs = 1:1:4
    plot(0,0, 'color', c_pattern{subs}, 'Marker',symbols{subs},...
        'MarkerSize',10,'LineStyle',lstyles{subs},'LineWidth',1);
    hold on
end
% plot(0,0,'LineStyle','--','LineWidth',1.5 ...
%     ,'Color','k')
leg_h2 = legend('P1','P2','P3', 'P4','Position',[.75 .67 .1 .02],'orientation','horizontal');
leg_h2.Color ="none";
leg_h2.TextColor = "k";

title(leg_h2,'Pattern');
fontsize(16,"points")




% 
% %% Running performance
% axes('Position',[.55, .1, .4, .25]);
% 
% % Loop over trial outcomes
% for ttype = 1:length(tr_outc)
%     curr_idx = eval(sprintf('%s_idx',tr_outc{ttype}));
% 
%     % Preallocate relative performance
%     ct_rel = zeros(length(curr_idx),1);
% 
%     % Loop trouch index with sliding window
%     for wdw = 1:length(curr_idx)-window_l
%         ct_rel(wdw) = sum(curr_idx(wdw:wdw+window_l));
%     end
% 
%     % Smooth data
%     ct_relsmo = smooth(ct_rel/window_l,smooth_span,'gaussian');
%     hold on
%     plot(1:length(ct_relsmo),ct_relsmo,'Color', rperf_col(ttype,:),...
%         'LineWidth',2)
% end
% 
% % MIP
% title('Running Performance')
% set(gca,'Box','off','TickDir','out','XLim',[0 length(curr_idx)])
% xlabel('Trial [#]')
% ylabel('Proportion')
% 
% 
% 
%% RT histogram



% Initiate plot
axes('Position',[.68 .1 .25 .18]);
hold on

%% Plot match trials versus nonmatch trials
% Preallocation
% hist_handles = cell(1,2);
% for ttype = 1:length(trial_types)
%     curr_type = trial_types{ttype};
%     if any(eval(sprintf('%s_idx',curr_type))) %only if existent
%         % Get reaction times for current trial type
%         RTs = getreactiontimes(spk_data,25,41,...
%             eval(sprintf('%s_idx & correct_idx',curr_type)))*1000;
%         % Histogram plot
%         hist_handles{ttype} = histogram(RTs);
%         % Individualize and normalize
%         hist_handles{ttype}.FaceColor = cmap_zero(5,3+ttype);
%         hist_handles{ttype}.BinWidth = bin_width;
%     end
% end
% hold off

% % Make it pretty
% set(gca,'Box','off','XLim',[0 800])
% xlabel('Reaction time [ms]')
% ylabel('Abs. frequency [#]')
% legend(trial_types)
% title('Response latency')
% fontsize(16,"points")

%% Plot RT per sample (match trials only)
RT_median = nan(length(spl_nums),4);

for spl = 1:1:length(spl_nums) % Loop over samples
    sample = spl_nums(spl);
    sample_idx = resp_mat(:,3)==sample; %idx of current sample
    for subs = 1:1:4 % loop over patterns
        % index of trials of interest
        curr_idx = eval(sprintf('%s_idx & sample_idx & match_idx;',sub_sets{subs}));
        RTs = getreactiontimes(spk_data,25,41,...
             eval(sprintf('curr_idx & correct_idx')))*1000;
        RT_median(spl,subs) = median(RTs);
    end
end

for subs = 1:1:4
    plot(spl_nums + (subs-0.2)*0.1, RT_median(:,subs).', 'color', c_pattern{subs}, 'Marker',symbols{subs},...
        'MarkerSize',10,'LineStyle','none','LineWidth',1);
end
hold off

% MIP
set(gca,'Box','off','YLim',[150 600],'XLim',[min(spl_nums)-.25 ,max(spl_nums)+.5],...
    'XTick',spl_nums,'XTickLabel',sprintfc('%d',spl_nums))
ylabel('Reaction time [ms]')
xlabel('Sample')
title('Response latency')
fontsize(16,"points")



%% Title

sgtitle(sprintf('%s, %d Hits, %2.f%% correct',filename,sum(correct_idx),...
    (sum(correct_idx)/(sum(correct_idx)+sum(error_idx))*100)),'FontSize',15);

%% Export figure
base_path = regexp(cd,'\MATLAB','split');
save_path = ['D:\MasterThesis\figures\general_daily\',...
    filename,'_Behavior'];
% print('-dpng','-painters','-r200',save_path);
saveas(gca, save_path, 'jpg');
fprintf('Saved plot. \n',filename);


end