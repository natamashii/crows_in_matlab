function [avg_data, err_data] = ...
    calc_behav(data, data_type, calc_type, err_type, patterns, numerosities, n_boot, alpha)

% Function to compute mean/avg + error of behaviour

% pre allocation
if in_detail    % divided in each test numerosity tested
    avg_data = zeros(length(patterns), size(numerosities, 1));
    err_data = zeros(2, length(patterns), size(numerosities, 1));
else
    avg_data = zeros(length(patterns), size(numerosities, 1), size(numerosities, 2));
    err_data = zeros(2, length(patterns), size(numerosities, 1, size(numerosities, 2)));
end

% iterate over patterns
for pattern = 1:length(patterns)
    % iterate over samples
    for sample_idx = 1:size(numerosities, 1)
        if in_detail    % divided in each test numerosity tested
            % iterate over test numbers
            for test_idx = 1:size(numerosities, 2)
        
        % Reaction Time
        if strcmp(data_type, 'reaction times')
            % concat RTsfor all test numbers & subject/sessions
            to_analyse = vertcat(data{:, pattern, sample_idx, :});
        
        else
            to_analyse = data(:, pattern, sample_idx);
        end

        % Calculate Mean/Median
        if strcmp(calc_type, 'mean')
            avg_data(pattern, sample_idx, :) = mean(to_analyse, "omitnan");
        elseif strcmp(calc_type, 'median')
            avg_data(pattern, sample_idx, :) = median(to_analyse, "omitnan");
        end

        % Calculate Error
        if strcmp(err_type, 'STD')
            err_data(1, pattern, sample_idx, :) = std(to_analyse, [], "omitnan");
            err_data(2, pattern, sample_idx, :) = std(to_analyse, [], "omitnan");
        elseif strcmp(err_type, 'SEM')
            err_data(1, pattern, sample_idx, :) = std(to_analyse, [], "omitnan") ...
                / sqrt(sum(~isnan(to_analyse)));
            err_data(2, pattern, sample_idx, :) = std(to_analyse, [], "omitnan") ...
                / sqrt(sum(~isnan(to_analyse)));
        elseif strcmp(err_type, 'CI')
            
            % resample n_boot times
            for b_idx = 1:n_boot
                % generate random indices
                resample_idx = randi(numel(to_analyse), numel(to_analyse), 1);
                
                % bootstrap sample
                bootstrap_sample = to_analyse(resample_idx);

                % calculate median of current bootstrap sample
                bootstrap_median(b_idx) = median(bootstrap_sample);

                % sort the median vals
                sorted_bootstrap_median = sort(bootstrap_median);

                % get CIs
                err_data(1, pattern, sample_idx)
                
            end
        end



    end
end


end