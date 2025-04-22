function [mean_trial, error_trial, mean_error_trial] = ...
    avg_period(spike_snippets, pre_stim, post_stim, frame_rate_spikes)

% pre allocation
mean_trial = NaN(1, 3);
error_trial = NaN(2, 3);
mean_error_trial = NaN(4, 3);

% calculate for pre stimulus
mean_trial(1) = mean(spike_snippets(:, 1:pre_stim), "all");
error_trial(1, 1) = std(spike_snippets(:, 1:pre_stim), [], "all");
error_trial(2, 1) = std(spike_snippets(:, 1:pre_stim), [], "all") / ...
    sqrt(numel(spike_snippets(:, 1:pre_stim)));

% calculate for during stimulus
mean_trial(2) = mean(spike_snippets(:, pre_stim:end - post_stim), "all");
error_trial(1, 2) = std(spike_snippets(:, pre_stim:end - post_stim), [], "all");
error_trial(2, 2) = std(spike_snippets(:, pre_stim:end - post_stim), [], "all") / ...
    sqrt(numel(spike_snippets(:, pre_stim:end - post_stim)));

% calculate for post stimulus
mean_trial(3) = mean(spike_snippets(:, end - post_stim:end), "all");
error_trial(1, 3) = std(spike_snippets(:, end - post_stim:end), [], "all");
error_trial(2, 3) = std(spike_snippets(:, end - post_stim:end), [], "all") / ...
    sqrt(numel(spike_snippets(:, end - post_stim:end)));

% add/subtract error: STD
mean_error_trial(1, 1) = mean(1) + error_trial(1, 1);
mean_error_trial(1, 2) = mean(2) + error_trial(1, 2);
mean_error_trial(1, 3) = mean(3) + error_trial(1, 3);

mean_error_trial(2, 1) = mean(1) - error_trial(1, 1);
mean_error_trial(2, 2) = mean(2) - error_trial(1, 2);
mean_error_trial(2, 3) = mean(3) - error_trial(1, 3);

% add/subtract error: SEM
mean_error_trial(3, 1) = mean(1) + error_trial(2, 1);
mean_error_trial(3, 2) = mean(2) + error_trial(2, 2);
mean_error_trial(3, 3) = mean(3) + error_trial(2, 3);

mean_error_trial(4, 1) = mean(1) - error_trial(2, 1);
mean_error_trial(4, 2) = mean(2) - error_trial(2, 2);
mean_error_trial(4, 3) = mean(3) - error_trial(2, 3);

% adjust with frame rates
mean_trial = mean_trial * frame_rate_spikes;
error_trial = error_trial * frame_rate_spikes;
mean_error_trial = mean_error_trial * frame_rate_spikes;

end