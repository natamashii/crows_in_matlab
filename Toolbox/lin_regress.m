function [penis] = ...
    lin_regress(performances, resp_freq, rec_times, patterns, numerosities)

% function to compute linear regression of all data that should be compared
% to each other

% NOTES
% include p value shit + effect size (R^2 ???)
% if to_split, then ind_data must be a 1x2 cell with ind data of cases
% sth abt fixed effect, beta & random effect, eta
% this works for matches only

% pre allocation
data_table = table();


% iterate over patterns
for pattern = 1:length(patterns)

    % iterate over samples
    for sample_idx = 1:size(numerosities, 1)

        % write data as table
        subjects_col = (1:size(performances, 1))';
        pattern_col = repmat(patterns{pattern}, size(subjects_col, 1), 1);
        sample_col = repmat(numerosities(sample_idx, 1), size(subjects_col, 1), 1);
        performance_col = performances(:, pattern, sample_idx, 1);
        resp_freq_col = resp_freq(:, pattern, sample_idx, 1);
        % Reaction Time: take median for each subject/session
        rec_times_col = zeros(size(subjects_col, 1), 1);
        % iterate over subejcts/sessions
        for sub_idx = 1:size(subjects_col, 1)
            rec_times_col(sub_idx) = ...
                median(vertcat(rec_times{sub_idx, pattern, ...
                sample_idx, 1}), "omitnan");
        end

        % store as table
        temp_table = ...
            table(subjects_col, sample_col, pattern_col, ...
            performance_col, resp_freq_col, rec_times_col, ...
            'VariableNames', ...
            {'Subject', 'Sample', 'Pattern', ...
            'Performance', 'ResponseFrequency', 'RT'});
        data_table = [data_table; temp_table];  % append vertically

    end
end

% poly fit stuff
% iterate over patterns
% too tired now, so here the notes: google how to filter table
% filter it to each pattern, then apply it in polyfit(sample, performance,
% 1)
% dont forget to do the '
filtered_data = data_table(data_table.Pattern == patterns{pattern}, :);
pipi(pattern, :) = polyfit(filtered_data.Sample, filtered_data.Performance, 1);
for pattern = 1:length(patterns)
    pipi = polyfit(data_table.)
end

% make columns categorical
data_table.Pattern = categorical(cellstr(data_table.Pattern));
data_table.Sample = categorical(data_table.Sample);
data_table.Subject = categorical(data_table.Subject);

% make repeated measures model
lme_model_performance = ...
    fitlme(data_table, 'Performance ~ Pattern + (1|Subject)');
lme_model_resp_freq = ...
    fitlme(data_table, 'ResponseFrequency ~ Pattern + (1|Subject)');
lme_model_rec_times = ...
    fitlme(data_table, 'RT ~ Pattern + (1|Subject)');

anova_performance = anova(lme_model_performance);
anova_resp_freq = anova(lme_model_resp_freq);
anova_rec_times = anova(lme_model_rec_times);

pipi = corrcoef();
pipi = polyfit(performances(:, 1, :, 1))

end