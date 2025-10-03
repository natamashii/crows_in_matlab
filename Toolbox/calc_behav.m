function [avg_data, avg_data_stats, err_data] = ...
    calc_behav(data, data_type, calc_type, err_type, patterns, ...
    numerosities, n_boot, alpha, focus_type)

% Function to compute mean/avg + error of behaviour

% pre allocation
if strcmp(focus_type, 'Single')    % divided in each test numerosity tested
    avg_data = zeros(length(patterns), size(numerosities, 1), size(numerosities, 2));
    avg_data_stats = zeros(size(data, 1), length(patterns));
    err_data = zeros(2, length(patterns), size(numerosities, 1), size(numerosities, 2));
else
    avg_data = zeros(1, length(patterns));
    avg_data_stats = zeros(size(data, 1), length(patterns));
    err_data = zeros(2, length(patterns));
end

% iterate over patterns
for pattern = 1:length(patterns)
    switch focus_type
        case 'Overall'
            % Reaction Time
            if strcmp(data_type, 'Reaction Times')
                % concat RTs for all test numbers & subject/sessions
                to_analyse = vertcat(data{:, pattern, :, :});

                % Performance/Response Frequency
            else
                to_analyse = data(:, pattern, :, :);
            end

        case 'Matches'
            % Reaction Time
            if strcmp(data_type, 'Reaction Times')
                % concat RTs for all test numbers & subject/sessions
                to_analyse = vertcat(data{:, pattern, :, 1});

                % Performance/Response Frequency
            else
                to_analyse = data(:, pattern, :, 1);
            end
    end

    if ~strcmp(focus_type, 'Single')
        % Calculate Mean/Median
        if strcmp(calc_type, 'Mean')
            avg_data(pattern) = mean(to_analyse, "all", "omitnan");
        elseif strcmp(calc_type, 'Median')
            avg_data(pattern) = median(to_analyse, "all", "omitnan");
        end

        % Calculate Error
        if strcmp(err_type, 'STD')
            % flat the data first
            flat_data = reshape(to_analyse, [], 1);
            err_data(1, pattern) = ...
                std(flat_data, [], "all", "omitnan");
            err_data(2, pattern) = ...
                std(flat_data, [], "all", "omitnan");
        elseif strcmp(err_type, 'SEM')
            flat_data = reshape(to_analyse, [], 1);
            err_data(1, pattern) = ...
                std(flat_data, [], "all", "omitnan") ...
                / sqrt(sum(~isnan(flat_data)));
            err_data(2, pattern) = ...
                std(flat_data, [], "all", "omitnan") ...
                / sqrt(sum(~isnan(flat_data)));
        elseif strcmp(err_type, 'CI')
            [err_data(1, pattern), ...
                err_data(2, pattern)] = ...
                bootstrapping(to_analyse, n_boot, alpha);
        end
    end
end

% Average across subjects/sessions for statistics (works for matches)

% iterate over patterns
for pattern = 1:length(patterns)

    % iterate over subjects/sessions
    for sub = 1:size(data, 1)

        % Reaction Time
        if strcmp(data_type, 'Reaction Times')
            % concat RTs for all test numbers & subject/sessions
            to_analyse = vertcat(data{sub, pattern, :, 1});
            avg_data_stats(sub, pattern) = ...
                median(to_analyse, "all", "omitnan");
        else
            avg_data_stats(sub, pattern) = ...
                mean(data(sub, pattern, :, 1), "all", "omitnan");
        end
    end
end

end
