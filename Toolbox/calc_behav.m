function [avg_data, err_data] = ...
    calc_behav(data, data_type, calc_type, err_type, patterns, ...
    numerosities, n_boot, alpha, in_detail)

% Function to compute mean/avg + error of behaviour

% pre allocation
if in_detail    % divided in each test numerosity tested
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
        if in_detail    % divided in each test numerosity tested
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
                else
                    error("Invalid calculation type specified. Use 'Mean' or 'Median', please.");
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
                            std(to_analyse, [], "omitnan") / sqrt(sum(~isnan(to_analyse)));
                        err_data(2, pattern, sample_idx, test_idx) = ...
                            std(to_analyse, [], "omitnan") / sqrt(sum(~isnan(to_analyse)));
                    case 'CI'
                        err_data = ...
                            bootstrapping(to_analyse, n_bot, alpha, in_detail, patterns, numerosities);
                end
            end
        else

            % Reaction Time
            if strcmp(data_type, 'Reaction Times')
                % concat RTs for all test numbers & subject/sessions
                to_analyse = vertcat(data{:, pattern, sample_idx, :});
                % Performance
            else
                to_analyse = data(:, pattern, sample_idx);
            end

            % Calculate Mean/Median
            if strcmp(calc_type, 'Mean')
                avg_data(pattern, sample_idx, :) = mean(to_analyse, "omitnan");
            elseif strcmp(calc_type, 'Median')
                avg_data(pattern, sample_idx, :) = median(to_analyse, "omitnan");
            else
                error("Invalid calculation type specified. Use 'Mean' or 'Median', please.");
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
                err_data = ...
                    bootstrapping(to_analyse, n_boot, alpha, in_detail, patterns, numerosities);
            end
        end
    end
end


end