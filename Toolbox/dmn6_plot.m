function dmn6_plot(filename)
% e.g. filename = 'J050825'
%% Plot performance parameters of DMN task with numbers 1-6 dependent on pattern
% Pattern 1 == random
% pattern 2 == additive (chunking)
% pattern 3 == multiplictive (grouping)

disp(filename);

% Load data
[spk_data,resp_mat] = load_spk(filename);

%% Examplary performance curve for pattern 1

% Indices
P1_idx = resp_mat(:,2)==1; %pattern 1 == random 
correct_idx = resp_mat(:,5)==0; %correct trials
badpk_idx = resp_mat(:,5)==9; %badpecks
aborted_idx = resp_mat(:,5)==9 & resp_mat(:,3)~=9; %aborted trials after sample was seen
error_idx = resp_mat(:,5)==1; %error trials
standard_idx = resp_mat(:,1)==1; %standard stimuli
control_idx = resp_mat(:,1)==2; %control stimuli
match_idx = resp_mat(:,3)==resp_mat(:,4) & resp_mat(:,5)~=9; %match trials
nonmatch_idx = resp_mat(:,3)~=resp_mat(:,4) & resp_mat(:,5)~=9; %nonmatch tr.

% Parameters
spl_nums =  1:1:6;
test_nums = spl_nums;
tc_col = jet(6);
window_l = 10; %for running performance
smooth_span = 60; %for running performance plot
tc_colb = jet(10);
rperf_col = [tc_colb(5,:);tc_colb(10,:);.7,.7,.7];
bin_width = 25; % for RT histogram
trial_types = {'match','nonmatch'}; % for RT histogram
sub_sets = {'P1'}; % Stimulus subsets for tuning curve plot, could include protocol as well
lstyles = {'-','--',':','--',':'};
symbols = {'o'}; %{'d','o','o','s','s'};
sub_lbl = {'Average','Standard','Control'};%'Average','Standard','Control';
tr_outc = {'correct','error','badpk'};




%% Initiate figure

figure('Color','w','visible','on','Units','normalized','OuterPosition',...
    [.2 .15 .4 .7])
drawnow
% get(groot,'default')
set(groot,{'DefaultAxesColor','DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor',...
    'DefaultTextColor','defaultAxesGridColor','defaultPatchFaceColor',...
    'defaultLineColor'},{'none','k','k','k','k','k','k','k'});

%% Plot performance curves

% Plot
axes('Position',[.1 .47 .55 .4]);

% Preallocation
perf_all = nan(length(spl_nums),length(test_nums),length(sub_sets));  % nan(length(spl_nums),length(y_nums),length(sub_sets));

% Loop over samples
for spl = 1:1:length(spl_nums)
     
    % Index all trials for current sample
    sample = spl_nums(spl);
    sample_idx = resp_mat(:,3)==sample;

    % Loop over subsets, currently only 1 pattern
    for subs = 1:1:1 
        
        % Current subset index
        curr_idx = eval(sprintf('%s_idx & sample_idx;',sub_sets{subs}));
        
        % Loop over test1 numerosities
        for test1 = 1:length(test_nums)
            %Current answer numerosity
            test1_idx = resp_mat(:,4) == test1;
            
            if sample==test1
                % Match trials
                perf_all(spl,test1,subs) = sum(curr_idx & test1_idx & correct_idx)...
                    / sum(curr_idx & test1_idx);
            else
                % Nonmatch trials
                perf_all(spl,test1,subs) = sum(curr_idx & test1_idx & error_idx)...
                    / sum(curr_idx & test1_idx);
            end
        end
        % Plot
        hold on
        if subs ~= 1
            p_idx = ~any(isnan(perf_all(spl,:,subs)),1);
            % plot values of current sample and subset
            plot(test_nums(p_idx),perf_all(spl,p_idx,subs),'Color',tc_col(spl,:),...
                'LineWidth',1,'LineStyle',lstyles{subs},...
                'Marker','none',... %symbols{subs},'MarkerSize',6,...
                'MarkerFaceColor',tc_col(spl,:),'MarkerEdgeColor','k'); %plot
        elseif subs == 1
            p_idx = ~any(isnan(perf_all(spl,:,subs)),1);
            plot(test_nums(p_idx),perf_all(spl,p_idx,subs),'Color',tc_col(spl,:),...
                'LineWidth',1.5,'LineStyle',lstyles{subs},...
                'Marker',symbols{subs},'MarkerSize',10,...
                'MarkerFaceColor',tc_col(spl,:),'MarkerEdgeColor','k'); %plot
        end
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
leg_h2 = legend('1','2','3','4','5','6','Position',[.85 .47 .02 .3],'orientation','vertical');
title(leg_h2,'Sample');
fontsize(16,"points")



%% Running performance
axes('Position',[.55, .1, .4, .25]);

% Loop over trial outcomes
for ttype = 1:length(tr_outc)
    curr_idx = eval(sprintf('%s_idx',tr_outc{ttype}));
    
    % Preallocate relative performance
    ct_rel = zeros(length(curr_idx),1);
    
    % Loop trouch index with sliding window
    for wdw = 1:length(curr_idx)-window_l
        ct_rel(wdw) = sum(curr_idx(wdw:wdw+window_l));
    end
    
    % Smooth data
    ct_relsmo = smooth(ct_rel/window_l,smooth_span,'gaussian');
    hold on
    plot(1:length(ct_relsmo),ct_relsmo,'Color', rperf_col(ttype,:),...
        'LineWidth',2)
end

% MIP
title('Running Performance')
set(gca,'Box','off','TickDir','out','XLim',[0 length(curr_idx)])
xlabel('Trial [#]')
ylabel('Proportion')



%% RT histogram

% Preallocation
hist_handles = cell(1,2);

% Initiate plot
axes('Position',[.07 .1 .4 .25]);

for ttype = 1:length(trial_types)
    curr_type = trial_types{ttype};
    if any(eval(sprintf('%s_idx',curr_type))) %only if existent
        % Get reaction times for current trial type
        RTs = getreactiontimes(spk_data,25,41,...
            eval(sprintf('%s_idx & correct_idx',curr_type)))*1000;
        % Histogram plot
        hist_handles{ttype} = histogram(RTs);
        hold on
        % Individualize and normalize
        hist_handles{ttype}.FaceColor = cmap_zero(5,3+ttype);
        hist_handles{ttype}.BinWidth = bin_width;
    end
end

% Make it pretty
set(gca,'Box','off','XLim',[0 800])
xlabel('Reaction time [ms]')
ylabel('Abs. frequency [#]')
legend(trial_types)
title('Response latency (Test 1)')


%% Title

sgtitle(sprintf('%s, %d Hits, %2.f%% correct',filename,sum(correct_idx),...
    (sum(correct_idx)/(sum(correct_idx)+sum(error_idx))*100)),'FontSize',15);


end