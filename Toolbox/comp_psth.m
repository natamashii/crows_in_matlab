function [psth, error, psth_error] = ...
    comp_psth(spike_snippets, window, stepsize, frame_rate_spikes)

% pre allocation
psth = NaN(1, size(spike_snippets, 2));
error = NaN(2, size(spike_snippets, 2));
psth_error = NaN(4, size(spike_snippets, 2));

% pad NaNs to spike snippets
nan_spikes = NaN(size(spike_snippets, 1), size(spike_snippets, 2) + window);
time_1 = floor(window/2);
time_end = size(spike_snippets, 2) + floor(window/2);
nan_spikes(:, time_1 + 1:time_end) = spike_snippets(:, :);

for time = time_1 + 1:stepsize:time_end
    % average
    psth(time - time_1) = ...
        mean(nan_spikes(:, time - time_1 : time + time_1), "all", "omitnan");
    % STD
    error(1, time - time_1) = ...
        std(nan_spikes(:, time - time_1 : time + time_1), [], "all", "omitnan");
    % SEM
    error(2, time - time_1) = ...
        std(nan_spikes(:, time - time_1 : time + time_1), [], "all", "omitnan") ...
        /sqrt(sum(~isnan(nan_spikes(:, time - time_1 : time + time_1)), "all"));
end

% add/subtract error: STD
psth_error(1, :) = psth + error(1, :);
psth_error(2, :) = psth - error(1, :);

% add/subtract error: SEM
psth_error(3, :) = psth + error(2, :);
psth_error(4, :) = psth - error(2, :);

% adjust frame rate
psth = psth * frame_rate_spikes;
psth_error = psth_error * frame_rate_spikes;

end