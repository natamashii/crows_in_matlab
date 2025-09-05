function [avg_data, err_data] = ...
    calc_behav(data, data_type, calc_type, err_type, patterns, ...
    numerosities, n_boot, alpha, focus_type)

% Function to compute mean/avg + error of behaviour

% pre allocation
if strcmp(focus_type, 'Single')    % divided in each test numerosity tested
    avg_data = zeros(length(patterns), size(numerosities, 1), size(numerosities, 2));
    err_data = zeros(2, length(patterns), size(numerosities, 1, size(numerosities, 2)));
else
    avg_data = zeros(length(patterns), size(numerosities, 1));
    err_data = zeros(2, length(patterns), size(numerosities, 1));
end

% iterate over patterns
for pattern = 1:length(patterns)
    % iterate over samples
    for sample_idx = 1:size(numerosities, 1)
        switch focus_type
            case 'Single'
                % iterate over test numbers
                for test_idx = 1:size(numerosities, 2)
                    % Reaction Time
                    if strcmp(data_type, 'Reaction Times')
                        % concat RTs for all test numbers & subject/sessions
                        to_analyse = vertcat(data{:, pattern, sample_idx, test_idx});
                        % Performance
                    else
                        to_analyse = data(:, pattern, sample_idx, test_idx);
                    end

                    % Calculate Mean/Median
                    if strcmp(calc_type, 'Mean')
                        avg_data(pattern, sample_idx, test_idx) = ...
                            mean(to_analyse, "omitnan");
                    elseif strcmp(calc_type, 'Median')
                        avg_data(pattern, sample_idx, test_idx) = ...
                            median(to_analyse, "omitnan");
                    end

                    % Calculate Error
                    switch err_type
                        case 'STD'
                            err_data(1, pattern, sample_idx, test_idx) = ...
                                std(to_analyse, [], "omitnan");
                            err_data(2, pattern, sample_idx, test_idx) = ...
                                std(to_analyse, [], "omitnan");
                        case 'SEM'
                            err_data(1, pattern, sample_idx, test_idx) = ...
                                std(to_analyse, [], "omitnan") / ...
                                sqrt(sum(~isnan(to_analyse)));
                            err_data(2, pattern, sample_idx, test_idx) = ...
                                std(to_analyse, [], "omitnan") / ...
                                sqrt(sum(~isnan(to_analyse)));
                        case 'CI'
                            [err_data(1, pattern, sample_idx, test_idx), ...
                                err_data(2, pattern, sample_idx, test_idx)] = ...
                                bootstrapping(to_analyse, n_bot, alpha);
                    end
                end

            case 'Overall'
                % Reaction Time
                if strcmp(data_type, 'Reaction Times')
                    % concat RTs for all test numbers & subject/sessions
                    to_analyse = vertcat(data{:, pattern, sample_idx, :});

                % Performance
                else
                    to_analyse = data(:, pattern, sample_idx, :);
                end

            case 'Matches'
                % Reaction Time
                if strcmp(data_type, 'Reaction Times')
                    % concat RTs for all test numbers & subject/sessions
                    to_analyse = vertcat(data{:, pattern, sample_idx, 1});

                % Performance
                else
                    to_analyse = data(:, pattern, sample_idx, 1);
                end
        end
        
        if ~strcmp(focus_type, 'Single')
            % Calculate Mean/Median
            if strcmp(calc_type, 'Mean')
                avg_data(pattern, sample_idx) = mean(to_analyse, "all", "omitnan");
            elseif strcmp(calc_type, 'Median')
                avg_data(pattern, sample_idx) = median(to_analyse, "all", "omitnan");
            end

            % Calculate Error
            if strcmp(err_type, 'STD')
                % flat the data first
                flat_data = reshape(to_analyse, [], 1);
                err_data(1, pattern, sample_idx) = ...
                    std(flat_data, [], "omitnan");
                err_data(2, pattern, sample_idx) = ...
                    std(flat_data, [], "omitnan");
            elseif strcmp(err_type, 'SEM')
                flat_data = reshape(to_analyse, [], 1);
                err_data(1, pattern, sample_idx) = std(flat_data, [], "omitnan") ...
                    / sqrt(sum(~isnan(flat_data)));
                err_data(2, pattern, sample_idx) = std(flat_data, [], "omitnan") ...
                    / sqrt(sum(~isnan(flat_data)));
            elseif strcmp(err_type, 'CI')
                [err_data(1, pattern, sample_idx), ...
                    err_data(2, pattern, sample_idx)] = ...
                    bootstrapping(to_analyse, n_boot, alpha);
            end
        end
    end
end

end
