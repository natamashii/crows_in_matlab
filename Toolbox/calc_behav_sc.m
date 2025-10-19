function [avg_data_s, avg_data_c, err_data_s, err_data_c] = ...
    calc_behav_sc(ind_data_s, ind_data_c, what_analysis, err_type, ...
    calc_type, numerosities)

% function to compute average for Standard/Control Comparison

%% Pre Allocation
avg_data_s = NaN(1, size(numerosities, 1));
avg_data_c = NaN(1, size(numerosities, 1));
err_data_s = NaN(1, size(numerosities, 1));
err_data_c = NaN(1, size(numerosities, 1));


% iterate over samples
for sample_idx = 1:size(numerosities, 1)
    % set the data
    if strcmp(what_analysis, 'Reaction Times')
        % concat RTs for all test numbers, patterns & subjects/sessions
        to_analyse_s = vertcat(ind_data_s{:, :, sample_idx, 1});
        to_analyse_c = vertcat(ind_data_c{:, :, sample_idx, 1});

        % Performance/Response Frequency
    else
        to_analyse_s = ind_data_s(:, :, sample_idx, :);
        to_analyse_c = ind_data_c(:, :, sample_idx, :);

    end

    % Calculate Mean/Median
    if strcmp(calc_type, 'Mean')
        avg_data_s(sample_idx) = ...
            mean(to_analyse_s, "all", "omitnan");
        avg_data_c(sample_idx) = ...
            mean(to_analyse_c, "all", "omitnan");
    elseif strcmp(calc_type, 'Median')
        avg_data_s(sample_idx) = ...
            median(to_analyse_s, "all", "omitnan");
        avg_data_c(sample_idx) = ...
            median(to_analyse_c, "all", "omitnan");
    end

    % flat the array first
    flat_data_s = reshape(to_analyse_s, [], 1);
    flat_data_c = reshape(to_analyse_c, [], 1);

    % Calculate the Error
    if strcmp(err_type, 'STD')
        % Standard
        err_data_s(sample_idx) = ...
            std(flat_data_s, [], "omitnan");
        % Control
        err_data_c(sample_idx) = ...
            std(flat_data_c, [], "omitnan");

    elseif strcmp(err_type, 'SEM')
        % Standard
        err_data_s(sample_idx) = ...
            std(flat_data_s, [], "omitnan") / ...
            sqrt(sum(~isnan(flat_data_s)));
        % Control
        err_data_c(sample_idx) = ...
            std(flat_data_c, [], "omitnan") / ...
            sqrt(sum(~isnan(flat_data_c)));
    end
end


end