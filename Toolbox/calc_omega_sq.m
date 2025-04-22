function [omega_sq, info] = calc_omega_sq(spikecount,groups,varargin)
%% [omega_sq, info] = calc_omega_sq(spikecount,groups,varargin)
%
%       calculates omega square value for a single group or multiple groups
%
%       for multiple factors GROUPS has to be a cell containing a
%       grouping vector for each spikecount.
%
%       varargin:
%       'balanced' - balances the number of trials for each condition in
%                    one grouping vector. A seperate one-factor-anova is
%                    calculated for each group.
%       'repeats'  - Optional: number of repeated measures for balanced
%                    omega square. Final value will be the mean over all
%                    measures. Example: "...,'balanced','repeats',25..."
%                    default: 25 repeats


balance=0;
repeats=25;
for k=1:length(varargin)
    switch varargin{k}
        case {'balanced', 'Balanced'}
            balance=1;
            for l=1:length(varargin)
                switch varargin{l}
                    case {'Repeats','repeats'}
                        repeats = varargin{l+1};
                end
            end
    end
end

if balance %balanced repeated measure mode
    
    for k=1:size(groups,2) %for each group
        for i=unique(groups{k}(~isnan(groups{k})))'
            temp(i)=sum(groups{k}==i);
            grouped_spikecounts{i}=spikecount(groups{k}==i);
        end
        minimum_trials=min(temp);
        
        for i=1:repeats
            balanced_spikecount=nan(size(grouped_spikecounts,2)*minimum_trials,1);
            balanced_groups=nan(size(grouped_spikecounts,2)*minimum_trials,1);
            for m=1:size(grouped_spikecounts,2)
                balanced_spikecount(1+(minimum_trials*(m-1)):(minimum_trials*(m-1))+minimum_trials,1)=grouped_spikecounts{m}(randperm(size(grouped_spikecounts{m},1),minimum_trials));
                balanced_groups(1+(minimum_trials*(m-1)):(minimum_trials*(m-1))+minimum_trials,1)=m;
            end
            
            [p_value, table]=anovan(balanced_spikecount,balanced_groups,...
                'model','full',...
                'display','off');
            sum_sq = [table{2:end-2,2}]';
            df = [table{2:end-2,3}]';
            sum_sq_total = table{end,2};
            mean_sq_error = table{end-1,5};
            single_omega_sq(i) = (sum_sq-(df*mean_sq_error))/(sum_sq_total+mean_sq_error);
            info = 'one-way anova each factor separately';
        end
        omega_sq(k,1)=mean(single_omega_sq);

    end
    
else %unbalanced mode for parallel calculation of multiple factors
    
    [p_value, table]=anovan(spikecount,groups,...
        'model','full',...
        'display','off');
    
    sum_sq = [table{2:end-2,2}]';
    df = [table{2:end-2,3}]';
    sum_sq_total = table{end,2};
    mean_sq_error = table{end-1,5};
    omega_sq = (sum_sq-(df*mean_sq_error))/(sum_sq_total+mean_sq_error);
    info = table(2:end-2,1);
end

