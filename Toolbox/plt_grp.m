function [handles] = plt_grp(plt_type, filename, grp, cluster, startcode, offset, duration, varargin)
% PLT_GRP(plt_type, filename, grp, cluster, startcode, offset, duration, varargin)
%       function that can plot a rasterplot OR dotraster OR psth of a cell.
%
%       plt_type - string that specifies what to plot ('psth', 'dotraster', 'rasterplot')
%       grp      - grouping file, made with create_grp()
%
%       varargin: * 'color'               - contains cell with rgb-triplets, default: color_map
%                 * 'psth_smooth_window'  - specifies window to smooth over, default: 150
%                 * 'psth_smooth_type'    - 'gauss'|'boxcar'                 default: 'gauss'
%                 * 'psth_analysis_window'- [begin end], window relative to
%                                           startcode for statistical analysis 
%                                           with kruskalwallis,              default: whole window

color_map;
psth_smooth_window=150;
psth_smooth_type='gauss';
psth_analysis_window=[offset+1 duration+offset];

if ~isempty(varargin)
    for i=1:2:size(varargin,2)
        if strcmp(varargin(i),'color')
            colors=varargin{i+1};
        elseif strcmp(varargin(i),'psth_smooth_window')
            psth_smooth_window=varargin{i+1};
        elseif strcmp(varargin(i),'psth_smooth_type')
            psth_smooth_type=varargin{i+1};
        elseif strcmp(varargin(i),'psth_analysis_window')
            psth_analysis_window=varargin{i+1};
        end
    end
end
%psth_smooth_type='boxcar'

[spk_file, resp]=load_spk(filename);

%get all trials specified in grp:
all_trials=find(isnan(grp)==0);
all_grp=grp(all_trials);
all_resp=resp(all_trials,:);
%extract spikes for all_trials:
all_spikes_3d=getspike(all_trials,cluster,startcode,offset,duration);
all_spikes(:,:)=all_spikes_3d(1,:,:);
all_spikes=double(all_spikes');
clearvars all_spikes_3d
%determine first and last trial for this cluster:
cluster_borders=[find(sum(all_spikes,2)~=0,1,'first') find(sum(all_spikes,2)~=0,1,'last')];
% grp, spiketrains and resp for this cluster:
cluster_grp=all_grp(cluster_borders(1):cluster_borders(2));
cluster_spikes=all_spikes(cluster_borders(1):cluster_borders(2),:);
cluster_resp=all_resp(cluster_borders(1):cluster_borders(2),:);

if strcmp(plt_type,'rasterplot')|strcmp(plt_type,'raster')
    %% rasterplot
    temp_raster=cluster_spikes.*repmat([1:size(cluster_spikes,1)]',1,size(cluster_spikes,2));
    handles{1}=plot([offset:offset+duration-1],temp_raster','.k','markersize',10);
    clearvars temp*
    ylim([1, size(cluster_spikes,1)-1])
    xlim([offset offset+duration])
    ylabel('Trials [#]')
    xlabel('Time [ms]')
    
elseif strcmp(plt_type,'dotraster')
    %% dotraster:
    counter=1;
    for i=unique(cluster_grp)'
        temp_spikes=cluster_spikes(cluster_grp==i,:);
        temp_dotraster=temp_spikes.*repmat([counter:counter+size(temp_spikes,1)-1]',1,size(temp_spikes,2));
        temp_dotraster(temp_dotraster==0)=nan;
        handles{i}=plot([offset:offset+duration-1],temp_dotraster','.','color',colors{i},'markersize',10);
        hold on
        counter=counter+size(temp_spikes,1);
    end
    clearvars temp*
    ylim([1, counter-1])
    xlim([offset offset+duration])
    ylabel('Trials [#]')
    xlabel('Time [ms]')
    
elseif strcmp(plt_type,'psth')
    %% PSTH
    for i=unique(cluster_grp)'
        temp_spikes=cluster_spikes(cluster_grp==i,:);
        temp_fr=mean(temp_spikes,1)*1000;
        temp_fr_smoothed=smooth_data(temp_fr,psth_smooth_window,psth_smooth_type);
        handles{i}=plot([offset:offset+duration-1],temp_fr_smoothed,...
            'LineWidth',3,...
            'Color',colors{i},...
            'DisplayName',strcat('GRP\_',num2str(i)));
        hold on
    end
    xlim([offset offset+duration])
    x=xlim;
    y=ylim;
    ylim([0 y(2)])
    ylabel('Firingrate [Hz]')
    xlabel('Time [ms]')
    
    if ~isempty(psth_analysis_window)
        %statistical analysis: kruskalwallis
        kw_fr=mean(cluster_spikes(:,psth_analysis_window(1)-offset:psth_analysis_window(2)-offset),2)*1000;
        kw_pvalue=kruskalwallis(kw_fr,cluster_grp,'off');
        if kw_pvalue<0.05
            handles{i+1}=text(x(2)*0.7,y(2)*0.1,['\bfp=',num2str(kw_pvalue)],'color','r');
        else
            handles{i+1}=text(x(2)*0.7,y(2)*0.1,['\bfp=',num2str(kw_pvalue)],'color','k');
        end
        clearvars temp* x* y* kw*
    end
    
end
