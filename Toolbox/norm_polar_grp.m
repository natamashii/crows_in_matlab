function norm_polar_grp( filename, grp, cluster, startcode, offset, duration, grp_degree, varargin )
%PSTH_DOTRASTER_GRP plots a polar plot grouped by grp.
%   Cell  #CLUSTER of file FILNAME is plotted. Trials are grouped
%   according to GRP (can be made with create_grp()). A timewindow of
%   duration is plotted with a OFFSET to eventcode STARTCODE.
%
%   GRP_DEGREE has to consist of a vector containing a degree (not rad) for
%   each group. 0°=north, 45°=east...
%   (e.g. 4 groups: north, south, east, west -> grp_degree=[0 90 180 270])
%
%   Statistical analysis: for two groups ranksum, else kruskalwallis
%       WINDOW FOR Polar-Calc:
%                             varargin= polar-FR calc-window
%
%           if varargin is empty: presets specified in code
%
%   psth_dotraster_grp( filename, grp, cluster, startcode, offset, duration, window)

[spk_file resp]=load_spk(filename);
color_map;
groups=unique(grp(isnan(grp)==0));

if isempty(varargin)

    %%%%%%%%% Window for polarplot calc
    %%%%%%%%% values relativ to starcode
    polar_window=[200 300];
    %%%%%%%%%
else
    polar_window=varargin{1};
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


%% Normalization
norm_startcode=23;
norm_offset=-300;
norm_duration=300;
normwindow_3d=getspike(all_trials,cluster,norm_startcode,norm_offset,norm_duration);
normwindow(:,:)=normwindow_3d(1,:,:);
normwindow=double(normwindow');
normwindow=normwindow(cluster_borders(1):cluster_borders(2),:); %only trials with cluster
norm_spikecount=sum(normwindow,2); % get spikecount per trial
norm_FR=norm_spikecount./norm_duration*1000; % transfer to firing rate

NORM_mean=mean(norm_FR); 
NORM_std=std(norm_FR);
%%

%!!! from here on only use all_spikes, grp_all_spikes and cluster_borders!!!%
clearvars temp all_spikes_3d
%%
polar_mean=[];
polar_sem=[];
for i=groups'
    
    trials=find(grp_all_spikes==i); %all trials of group i
    trials=trials(trials>=cluster_borders(1) & trials<=cluster_borders(2)); %trials of group i with cluster
    spikes=all_spikes(trials,:); %spikes of group i
    
    %% Polar calc
    window=[offset*-1+polar_window(1) offset*-1+polar_window(2)];
    temp_spikes=[];
    temp_spikes=spikes(:,offset*-1+polar_window(1):offset*-1+polar_window(2));
    temp_fr=sum(temp_spikes,2)/size(polar_window(1):polar_window(2),2)*1000;
    % normalization
    temp_fr=(temp_fr-NORM_mean)/NORM_std;
    %
    polar_mean(i)=mean(temp_fr);
    polar_sem(i)=std(temp_fr)/sqrt(size(temp_fr,1));

end
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
mmpolar('RGridColor',[0.7 0.7 0.7])
mmpolar('RLimit',[0 max([polar_mean+polar_sem average_FR])+max([polar_mean+polar_sem average_FR])*0.2])
% set(h,'LineWidth',3)
mmpolar('TTickValue',grp_degree)
mmpolar('TGridVisible','off')



end