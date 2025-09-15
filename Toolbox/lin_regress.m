function [penis] = ...
    lin_regress(performances, resp_freq, rec_times, to_split, patterns, numerosities)

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

% make columns categorical
data_table.Pattern = categorical(cellstr(data_table.Pattern));
data_table.Sample = categorical(data_table.Sample);
data_table.Subject = categorical(data_table.Subject);

% make repeated measures model
lme_model_performance = ...
    fitlme(data_table, 'Performance ~ Pattern + (1|Subject)');
lme_model_resp_freq = ...
    fitlme(data_table, 'ResponseFrequency ~ Sample * Pattern + (1|Subject)');
lme_model_rec_times = ...
    fitlme(data_table, 'RT ~ Sample * Pattern + (1|Subject)');

anova_tab_performance = anova(lme_model_performance);
anova_tab_resp_freq = anova(lme_model_resp_freq);
anova_tab_rec_times = anova(lme_model_rec_times);

stats_performance = ...
    rm_anova2(data_table.Performance, ...
    data_table.Subject, data_table.Sample, data_table.Pattern, ...
    {'Sample', 'Pattern'});
stats_resp_freq = ...
    rm_anova2(data_table.ResponseFrequency, ...
    data_table.Subject, data_table.Sample, data_table.Pattern, ...
    {'Sample', 'Pattern'});
stats_rec_times = ...
    rm_anova2(data_table.RT, ...
    data_table.Subject, data_table.Sample, data_table.Pattern, ...
    {'Sample', 'Pattern'});

end