function [p_value] = psth_hist_grp( filename, grp, cluster, startcode, offset, duration, stepsize, varargin )
% Used bei plot_motor_tuning()!
%
%PSTH_DOTRASTER_GRP a psth grouped by GRP.
%   Cell #CLUSTER of file FILNAME is plotted. Trials are grouped
%   according to GRP (can be made with create_grp()). A timewindow of
%   duration is plotted with a OFFSET to eventcode STARTCODE. Psth is
%   smoothed with a window of PSTH_SMOOTHING.
%
%   Statistical analysis: for two groups ranksum, else kruskalwallis
%       WINDOW FOR ANALYSIS: vector in varargin (e.g. [200 800]) or preset
%                               specified in code below
%
%   psth_dotraster_grp( filename, grp, cluster, startcode, offset, duration, psth_smoothing)

[spk_file resp]=load_spk(filename);
groups=unique(grp(isnan(grp)==0));

if isempty(varargin)
    %%%%%%%%% Window for statistical analysis
    %%%%%%%%% values relativ to starcode
    analysis_window=[0 0];
else
    if size(varargin,2)==1
        analysis_window=varargin{1};
        color_map;
    else
        analysis_window=varargin{1};
        colors=varargin{2};
    end
    
end
%%%%%%%%%

all_trials=find(isnan(grp)==0);

all_spikes_3d=getspike(all_trials,cluster,startcode,offset,duration);
all_spikes(:,:)=all_spikes_3d(1,:,:);
all_spikes=double(all_spikes');

temp=nan(size(all_spikes,1),1); %determines first and last spiking trial for this cluster
for i=1:size(all_spikes,1)
    if sum(all_spikes(i,:))>0
        temp(i)=i;
    end
end
cluster_borders=[min(temp) max(temp)]; %first and last trial with unit, corresponding to grp_all_spikes
grp_all_spikes=grp(isnan(grp)==0); %new grp corresponding to all_spikes

%!!! from here on only use all_spikes, grp_all_spikes and cluster_borders!!!%
clearvars temp all_spikes_3d
%%
counter_dotraster=0;
for i=groups'
    
    
    trials=find(grp_all_spikes==i); %all trials of group i
    trials=trials(trials>=cluster_borders(1) & trials<=cluster_borders(2)); %trials of group i with cluster
    spikes=all_spikes(trials,:); %spikes of group i
    
    
    %% PSTH
    spikecount=sum(spikes);
%     hist(spikecount',size(spikecount,2)/10)
%     stepsize=50;
    summed_spikecount=[];
    counter=0;
    for m=1:stepsize:size(spikecount,2)
        counter=counter+1;
        summed_spikecount(m:m+stepsize-1)=sum(spikecount(m:m+stepsize-1));
%         summed_spikecount(counter)=sum(spikecount(m:m+stepsize-1));
    end

    handle_bar=bar(summed_spikecount,'edgecolor',colors{i},'facecolor',colors{i});
    set(handle_bar,'BarWidth',0.95)
    xlim([0 size(summed_spikecount,2)])
    xticklabel=get(gca,'xticklabel');
    for l=1:size(xticklabel,1)
        xticklabel{l}=num2str(str2num(xticklabel{l})+offset);
    end
    set(gca,'xticklabel',xticklabel)
    
    xlabel('Time [ms]')
    ylabel('Spike count [#]')
    xlim([0 duration])
    y_max(i)=max(summed_spikecount);
end
% legend('show')
ylim([0 max(y_max)+(max(y_max)*0.1)])
if offset<0 %plot startcode line for psth
    y=ylim;
    l1=line([offset*-1 offset*-1], [y(1) y(2)],'linewidth',2);
    set(l1,'Color','k');
end
set(gca,'linewidth',2,'FontWeight','bold')

% text(offset*-1+(offset*-1)*0.05, y(2)*0.1,num2str(startcode)) %prints startcode to line
%% Statistics
% window=[offset*-1+analysis_window(1) offset*-1+analysis_window(2)]; %!!! window for analysis according to analysis window in begin of function!!!%
% line([window(1) window(2)], [y(2)*0.95 y(2)*0.95], 'LineWidth',2, 'Color','k'); %pirnts line of analysis-window

% 
% anova_grp=grp_all_spikes(cluster_borders(1):cluster_borders(2));
% temp_anova_spikes=all_spikes(cluster_borders(1):cluster_borders(2),window(1):window(2));
% anova_spikes=sum(temp_anova_spikes,2)./size(temp_anova_spikes,2)*1000;
% p_anova=anova1(anova_spikes,anova_grp,'off');
% 
% text_handle=text(duration*0.8,max(y_max)*0.10,strcat('\bfp=',num2str(p_anova))); %print p-value of graph
% if p_anova<0.05
%     set(text_handle,'Color','r')
% end
end