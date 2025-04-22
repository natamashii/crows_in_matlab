function [p_value] = dotraster_grp( filename, grp, cluster, startcode, offset, duration, varargin )
%PSTH_DOTRASTER_GRP plots a dotrasterhistogram.
%   Cell #CLUSTER of file FILNAME is plotted. Trials are grouped
%   according to GRP (can be made with create_grp()). A timewindow of
%   duration is plotted with a OFFSET to eventcode STARTCODE.
%
%
%   dotraster_grp( filename, grp, cluster, startcode, offset, duration, varargin)

[spk_file resp]=load_spk(filename);
groups=unique(grp(isnan(grp)==0));

if isempty(varargin)
    %%%%%%%%% Window for statistical analysis
    %%%%%%%%% values relativ to starcode
    analysis_window=[200 300];
    color_map;
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
    if isempty(spikes)
        continue
    end
    %% Dotraster
    for n=1:size(spikes,1)
        counter_dotraster=counter_dotraster+1;
        single_trial=nan(size(spikes(n,:)));
        single_trial(spikes(n,:)==1)=counter_dotraster;
        handle_dot(i)=plot(single_trial,'.','markersize',10);
        hold on
        set(handle_dot(i),'Color',colors{i})
    end
    ylim([0 counter_dotraster])
    ylabel('\bfTrials [#]')
    title(strcat(filename,'\_',num2str(cluster)))  
end
if offset<0 %plot startcode line
    y=ylim;
    l1=line([offset*-1 offset*-1], [y(1) y(2)],'linewidth',2);
    set(l1,'Color','k');
    text(offset*-1+(offset*-1)*0.05, y(2)*0.1,num2str(startcode)) %prints startcode to line
end
xlim([0 duration])
xlabel('\bfTime [ms]')
set(gca,'linewidth',2,'FontWeight','bold')

if ~isempty(analysis_window)
window2=[offset*-1+analysis_window(1) offset*-1+analysis_window(2)]; %!!! window for analysis according to analysis window in begin of function!!!%
handle_analysis_shade=patch([window2(1) window2(2) window2(2) window2(1)], [y(1) y(1) y(2) y(2)], [0.95 0.95 0.95],'EdgeColor','none');
end
% legend('show')
% ylim([0 max(y_max)+(max(y_max)*0.1)])
% if offset<0 %plot startcode line for psth
%     y=ylim;
%     l1=line([offset*-1 offset*-1], [y(1) y(2)]);
%     set(l1,'Color','k');
% end
% text(offset*-1+(offset*-1)*0.05, y(2)*0.1,num2str(startcode)) %prints startcode to line
end