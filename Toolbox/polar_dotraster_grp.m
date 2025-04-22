function polar_dotraster_grp( filename, grp, cluster, startcode, offset, duration, psth_smoothing, grp_degree, varargin )
%PSTH_DOTRASTER_GRP plots a dotrasterhistogram and a polar plot in one graph.
%   Cell  #CLUSTER of file FILNAME is plotted. Trials are grouped
%   according to GRP (can be made with create_grp()). A timewindow of
%   duration is plotted with a OFFSET to eventcode STARTCODE.
%
%   GRP_DEGREE has to consist of a vector containing a degree (not rad) for
%   each group. 0°=north, 45°=east...
%   (e.g. 4 groups: north, south, east, west -> grp_degree=[0 90 180 270])
%
%   Statistical analysis: for two groups ranksum, else kruskalwallis
%       WINDOW FOR ANALYSIS:
%           if varargin gets ONE input: varargin= window for analysis and
%                                       FR-polar calculation-window
%
%           if varargin gets TWO input: varargin{1}= analysis window
%                                       varargin{2}= polar-FR calc-window
%
%           if varargin is empty: presets specified in code
%
%   psth_dotraster_grp( filename, grp, cluster, startcode, offset, duration, psth_smoothing)

[spk_file resp]=load_spk(filename);
color_map;
groups=unique(grp(isnan(grp)==0));

if isempty(varargin)
    %%%%%%%%% Window for statistical analysis
    %%%%%%%%% values relativ to starcode
    analysis_window=[200 300];
    %%%%%%%%%
    %%%%%%%%% Window for polarplot calc
    %%%%%%%%% values relativ to starcode
    polar_window=[200 300];
    %%%%%%%%%
else
    if size(varargin,2)==1
        analysis_window=varargin{1};
        polar_window=varargin{1};
    elseif size(varargin,2)==2
        analysis_window=varargin{1};
        polar_window=varargin{2};
    else
        error('!!!VARARGIN ERROR!!!')
    end
end


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
polar_mean=[];
polar_sem=[];
for i=groups'
    
    
    trials=find(grp_all_spikes==i); %all trials of group i
    trials=trials(trials>=cluster_borders(1) & trials<=cluster_borders(2)); %trials of group i with cluster
    spikes=all_spikes(trials,:); %spikes of group i
    
    %% Dotraster
    dotraster=subplot(3,1,1);
    for n=1:size(spikes,1)
        counter_dotraster=counter_dotraster+1;
        single_trial=nan(size(spikes(n,:)));
        single_trial(spikes(n,:)==1)=counter_dotraster;
        handle_dot(i)=plot(single_trial,'.');
        hold on
        set(handle_dot(i),'Color',color{i})
    end
    ylim([0 counter_dotraster])
    ylabel('Trials [#]')
    title(strcat(filename,'\_',num2str(cluster)))
    
    if offset<0 %plot startcode line
        y=ylim;
        l1=line([offset*-1 offset*-1], [y(1) y(2)]);
        set(l1,'Color','k');
        if i==groups(1)
            text(offset*-1+(offset*-1)*0.05, y(2)*0.1,num2str(startcode)) %prints startcode to line
        end
    end
    
    xlim([0 duration])
    %% PSTH
    psth=subplot(3,1,2);
    firingrate=nan(1,size(spikes,2));
    for m=1:size(spikes,2)
        firingrate(m)=sum(spikes(:,m))/size(spikes,1)*1000;
    end
    smoothed_fr=smooth_fr(firingrate,psth_smoothing);
    handle_psth(i)=plot(smoothed_fr);
    hold on
    set(handle_psth(i),'LineWidth',1.5)
    set(handle_psth(i),'Color',color{i},'DisplayName',strcat('GRP\_',num2str(i)))
    xlabel('Time [ms]')
    ylabel('Firingrate [Hz]')
    xlim([0 duration])
    y_max(i)=max(smoothed_fr);
    %% Polar calc
    %     firingrate=nan(1,size(spikes,2));
    window=[offset*-1+polar_window(1) offset*-1+polar_window(2)];
    temp_spikes=[];
    temp_spikes=spikes(:,offset*-1+polar_window(1):offset*-1+polar_window(2));
    polar_mean(i)=mean(sum(temp_spikes,2)/size(polar_window(1):polar_window(2),2)*1000);
    polar_sem(i)=std(sum(temp_spikes,2)/size(polar_window(1):polar_window(2),2)*1000)/sqrt(size(temp_spikes,1));

end
leg=legend('show');
set(leg,'Units','normalized')
set(leg,'Position',[0.15 0.1    0.1707    0.2182]);
ylim([0 max(y_max)+(max(y_max)*0.1)])
if offset<0 %plot startcode line for psth
    y=ylim;
    l1=line([offset*-1 offset*-1], [y(1) y(2)]);
    set(l1,'Color','k');
end
text(offset*-1+(offset*-1)*0.05, y(2)*0.1,num2str(startcode)) %prints startcode to line

%% polar average

X_average=sin(degtorad(grp_degree(:))).*polar_mean(:); %average X-values for each direction
Y_average=cos(degtorad(grp_degree(:))).*polar_mean(:);

average_angle=atan2(sum(X_average),sum(Y_average));
average_FR=sqrt((sum(X_average)^2)+(sum(Y_average)^2));

%% polar plotting
position=degtorad([grp_degree grp_degree(1)]); %Postitions clockwise starting with 'oben-rechts'
polar_handle=mmpolar([average_angle;0]',[average_FR;0]','k',...
                        position,[polar_mean polar_mean(1)],'k',...
                        position,[polar_mean+polar_sem polar_mean(1)+polar_sem(1)],':k',...
                        position,[polar_mean-polar_sem polar_mean(1)-polar_sem(1)],':k');

set(polar_handle,'LineWidth',3)
set(polar_handle(1),'LineWidth',4,'Color',[0.5 0.5 0.5])
mmpolar('Style','compass')
mmpolar('RGridVisible','on')
mmpolar('RLimit',[0 max([polar_mean+polar_sem])+max([polar_mean+polar_sem])*0.2])
set(h,'LineWidth',2)
mmpolar('TTickValue',grp_degree)
mmpolar('TGridVisible','off')

%% Statistics
psth=subplot(3,1,2);
window=[offset*-1+analysis_window(1) offset*-1+analysis_window(2)]; %!!! window for analysis according to analysis window in begin of function!!!%
line([window(1) window(2)], [y(2)*0.9 y(2)*0.9], 'LineWidth',2, 'Color','k'); %pirnts line of analysis-window


if size(groups,1)==2 %if two groups --> ranksum
    for i=groups'
        trials=find(grp_all_spikes==i); %all trials of group i
        trials=trials(trials>=cluster_borders(1) & trials<=cluster_borders(2)); %trials of group i with cluster
        spikes=all_spikes(trials,:); %spikes of group i
        
        temp_spikes=spikes(:,window(1):window(2));%only spikes in window
        spikecount{i}=sum(temp_spikes,2); %cell with two matrices containing a spikecount for each trial of a group
    end
    p_value=ranksum(spikecount{1},spikecount{2});
else %if more than two groups --> kruskalwallis
    temp_spikes=all_spikes(:,window(1):window(2));
    temp_spikes=temp_spikes(cluster_borders(1):cluster_borders(2),:);
    temp_grp_all_spikes=grp_all_spikes(cluster_borders(1):cluster_borders(2),:);
    spikecount=sum(temp_spikes,2);
    
    p_value=kruskalwallis(spikecount,temp_grp_all_spikes,'off');
end
text_handle=text(duration*0.8,max(y_max)*0.10,strcat('\bfp=',num2str(p_value))); %print p-value of graph
if p_value<0.05
    set(text_handle,'Color','r')
end

set(gcf,'Units','normalized','Position',[0.3 0 0.5 1])
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [.5 .5 26.0 24]); %abstand linke seite, abstand oben, BREITE X HÖHE
end