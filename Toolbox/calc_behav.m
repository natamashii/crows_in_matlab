function [avg_data, avg_data_stats, err_data] = ...
    calc_behav(data, data_type, calc_type, err_type, patterns, ...
    numerosities, n_boot, alpha, focus_type, to_birds)

% Function to compute mean/avg + error of behaviour

% pre allocation
if strcmp(focus_type, 'Single')    % divided in each test numerosity tested
    avg_data = zeros(length(patterns), size(numerosities, 1), ...
        size(numerosities, 2));
    avg_data_stats = zeros(size(data, 1), length(patterns));
    err_data = zeros(2, length(patterns), size(numerosities, 1), ...
        size(numerosities, 2));
else
    avg_data = zeros(1, length(patterns));
    avg_data_stats = zeros(size(data, 1), length(patterns));
    err_data = zeros(2, length(patterns));
end

if to_birds
    avg_data =  zeros(length(patterns), size(numerosities, 1));
    avg_data_stats = zeros(size(data, 1), length(patterns));
    err_data = zeros(2, length(patterns), size(numerosities, 1));
end

%% Average across subjects/sessions for statistics (works for matches)

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

%% Average Calculation

if to_birds
    % iterate over patterns
    for pattern = 1:length(patterns)
        % Iterate over Samples
        for sample_idx = 1:size(numerosities, 1)
            % Set Data
            switch focus_type
                case 'Overall'
                    if strcmp(data_type, 'Reaction Times')
                        to_analyse = vertcat(data{:, pattern, sample_idx, :});
                    else
                        to_analyse = data(:, pattern, sample_idx, :);
                    end
                case 'Matches'
                    if strcmp(data_type, 'Reaction Times')
                        to_analyse = vertcat(data{:, pattern, sample_idx, 1});
                    else
                        to_analyse = data(:, pattern, sample_idx, 1);
                    end
            end

            % Calculate Mean/Median
            if strcmp(calc_type, 'Mean')
                avg_data(pattern, sample_idx) = ...
                    mean(to_analyse, "all", "omitnan");
            elseif strcmp(calc_type, 'Median')
                avg_data(pattern, sample_idx) = ...
                    median(to_analyse, "all", "omitnan");
            end

            % Calculate Error
            if strcmp(err_type, 'STD')
                % flat the data first
                flat_data = reshape(to_analyse, [], 1);
                % calculate error
                err_data(1, pattern, sample_idx) = ...
                    std(flat_data, [], "omitnan");
                err_data(2, pattern, sample_idx) = ...
                    std(flat_data, [], "omitnan");
            elseif strcmp(err_type, 'SEM')
                % flat the data first
                flat_data = reshape(to_analyse, [], 1);
                % calculate error
                err_data(1, pattern, sample_idx) = ...
                    std(flat_data, [], "omitnan") / ...
                    sqrt(sum(~isnan(flat_data)));
                err_data(2, pattern, sample_idx) = ...
                    std(flat_data, [], "omitnan") / ...
                    sqrt(sum(~isnan(flat_data)));
            elseif strcmp(err_type, 'CI')
                [err_data(1, pattern, sample_idx), ...
                    err_data(2, pattern, sample_idx)] = ...
                    bootstrapping(to_analyse, n_boot, alpha);
            end
        end
    end
else
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

                % Calculate Error
                err_data(1, pattern) = ...
                    std(flat_data, [], "all", "omitnan");
                err_data(2, pattern) = ...
                    std(flat_data, [], "all", "omitnan");

            elseif strcmp(err_type, 'SEM')

                % flat the data first
                flat_data = reshape(to_analyse, [], 1);

                % Calculate Error
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

        else    % Detailed Analysis

            % Iterate Over Samples
            for sample_idx = 1:size(numerosities, 1)

                % Iterate Over Test Numerals
                for test_idx = 1:size(numerosities, 2)

                    % Select Data
                    if strcmp(data_type, 'Reaction Times')
                        % concat RTs for all test numbers & subject/sessions
                        to_analyse = ...
                            vertcat(data{:, pattern, sample_idx, test_idx});

                        % Performance/Response Frequency
                    else
                        to_analyse = data(:, pattern, sample_idx, test_idx);
                    end

                    % Calculate Mean/Median
                    if strcmp(calc_type, 'Mean')
                        avg_data(pattern, sample_idx, test_idx) = ...
                            mean(to_analyse, "all", "omitnan");

                    elseif strcmp(calc_type, 'Median')
                        avg_data(pattern, sample_idx, test_idx) = ...
                            median(to_analyse, "all", "omitnan");
                    end

                    % Calculate Corresponding Error
                    if strcmp(err_type, 'STD')

                        % flat the data first
                        flat_data = reshape(to_analyse, [], 1);

                        % Calculate Error
                        err_data(1, pattern, sample_idx, test_idx) = ...
                            std(flat_data, [], "all", "omitnan");
                        err_data(2, pattern, sample_idx, test_idx) = ...
                            std(flat_data, [], "all", "omitnan");

                    elseif strcmp(err_type, 'SEM')

                        % flat the data first
                        flat_data = reshape(to_analyse, [], 1);

                        % Calculate Error
                        err_data(1, pattern, sample_idx, test_idx) = ...
                            std(flat_data, [], "all", "omitnan") ...
                            / sqrt(sum(~isnan(flat_data)));
                        err_data(2, pattern, sample_idx, test_idx) = ...
                            std(flat_data, [], "all", "omitnan") ...
                            / sqrt(sum(~isnan(flat_data)));

                    elseif strcmp(err_type, 'CI')

                        [err_data(1, pattern, sample_idx, test_idx), ...
                            err_data(2, pattern, sample_idx, test_idx)] = ...
                            bootstrapping(to_analyse, n_boot, alpha);
                    end
                end
            end
        end
    end
end

end
