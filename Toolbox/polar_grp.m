function polar_grp( filename, grp, cluster, startcode, offset, duration, grp_degree, varargin )
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

%!!! from here on only use all_spikes, grp_all_spikes and cluster_borders!!!%
clearvars temp all_spikes_3d
%%
polar_mean=[];
polar_sem=[];
for i=groups'
    trials=[];
    trials=find(grp_all_spikes==i); %all trials of group i
    trials=trials(trials>=cluster_borders(1) & trials<=cluster_borders(2)); %trials of group i with cluster
    spikes=all_spikes(trials,:); %spikes of group i
    
    %% Polar calc
    window=[offset*-1+polar_window(1) offset*-1+polar_window(2)];
    temp_spikes=[];
    temp_spikes=spikes(:,offset*-1+polar_window(1):offset*-1+polar_window(2));
    polar_mean(i)=mean(sum(temp_spikes,2)/size(polar_window(1):polar_window(2),2)*1000);
    polar_sem(i)=std(sum(temp_spikes,2)/size(polar_window(1):polar_window(2),2)*1000)/sqrt(size(temp_spikes,1));

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

% set(polar_handle,'LineWidth',3)
% set(polar_handle(1),'LineWidth',4,'Color',[0.5 0.5 0.5])
% mmpolar('RLimit',[0 max([polar_mean+polar_sem average_FR])+max([polar_mean+polar_sem average_FR])*0.2])
% % set(h,'LineWidth',3)
% mmpolar('TTickValue',grp_degree)
% mmpolar('TGridVisible','off')
%%
ymax=max([polar_mean+polar_sem average_FR]); %calc ymax from all FR inputs to mmpolar
ymax=ymax*1.1;
if     (ymax < 5)  abs=1;
elseif (ymax < 20) abs=5;
elseif (ymax < 40) abs=10;
else               abs=20;
end
% title([strcat('\bf',filename,'\_',num2str(cluster))])
set(polar_handle,'LineWidth',3)
set(polar_handle(1),'LineWidth',4,'Color',[0.5 0.5 0.5])
mmpolar('Style','compass')
mmpolar('Border','off')
mmpolar('TTickValue',grp_degree)
mmpolar('RGridVisible','on')
mmpolar('RLimit',[0 ymax])
%     mmpolar('RTickValue',[0:abs:ymax])
mmpolar('RTickUnits',' Hz')
mmpolar('RTickOffset',0.1)
mmpolar('TTickOffset',0.1)
mmpolar('TTickLabel',{'\bf1', '\bf2','\bf3','\bf4','\bf5','\bf6','\bf7','\bf8'})



end