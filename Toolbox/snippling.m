function [spike_snippets, stimulus_length] = snippling(pre_stim, post_stim, ...
    frame_rate_spikes, spike_trace, ...
    current_trace, time_current, current_thr, current_value)

% pre allocation
ejection_on = [];
ejection_off = [];
spike_snippets = [];
stimulus_length = {};
rec_struct = ["ret", "ret"];

to_skip = false;    % toggles if current channel doesnt make sense
% binaray array for spike detection, time is length of current recording
spikes = zeros(1, round(size(time_current, 2) * frame_rate_spikes));
spikes(round(spike_trace * frame_rate_spikes)) = 1;

% identify time points of current application
ejection = find(ischange(current_trace, "Threshold", current_thr)); % in s

% continue analysis if current channel makes sense
if size(ejection, 2) ~= 0
    % identify how recording started 
    if abs(round(current_trace(1))) < abs(current_value)   % start with ret
        ejection_on = ejection(1:2:end);    % in s
        ejection_off = ejection(2:2:end);   % in s
    else   % start with eject
        ejection_on = [0, ejection(2:2:end)];    % in s
        ejection_off = ejection(1:2:end);   % in s
        rec_struct(1) = "eject";
    end
    % identify how recording ended
    if not (abs(round(current_trace(end))) < abs(current_value))% stopped with eject
        ejection_off(end+1) = size(current_trace, 2);
        rec_struct(2) = "eject";
    end
    % identify how many trials there were
    num_trials = numel(ejection_on);

    % flatten rec_struct
    rec_struct = strjoin(rec_struct, "_");
    stimulus_length{end + 1} = ejection_off - ejection_on;
    
    % convert ejection time points to spike train indices
    ejection_on = round(ejection_on * frame_rate_spikes);
    ejection_off = round(ejection_off * frame_rate_spikes);

    % split spike train into snippets of pre-during-post
    switch rec_struct
        case "ret_ret"  % start & stop with retention current
            % iterate over all trials
            for stim = 1:num_trials
                spike_snippets{stim} = ...
                    spikes(ejection_on(stim) - pre_stim : ...
                    ejection_off(stim) + post_stim);
            end
        case "eject_ret"    % start with ejection & stopped with retention
            spike_snippets{1} = ...
                [zeros(1, pre_stim), spikes(ejection_on(1) : ...
                ejection_off(1) + post_stim)];
            % iterate over remaining trials
            for stim = 2:num_trials
                spike_snippets{stim} = ...
                    spikes(ejection_on(stim) - pre_stim : ...
                    ejection_off(stim) + post_stim);
            end
        case "ret_eject"    % start with retention & stopped with ejection
            % iterate over remaining trials
            for stim = 1:num_trials - 1
                spike_snippets{1, stim} = ...
                    spikes(ejection_on(stim) - pre_stim : ...
                    ejection_off(stim) + post_stim);
            end
            spike_snippets{end + 1} = ...
                [spikes(ejection_on(end) - pre_stim : ...
                ejection_off(end)), zeros(1, post_stim)];
        case "eject_eject"  % start & stop with ejection current
            spike_snippets{1} = ...
                [zeros(1, pre_stim), spikes(ejection_on(1) : ...
                ejection_off(1) + post_stim)];
            % iterate over remaining trials
            for stim = 2:num_trials - 1
                spike_snippets{stim} = ...
                    spikes(ejection_on(stim) - pre_stim : ...
                    ejection_off(stim) + post_stim);
            end
            spike_snippets{end + 1} = ...
                [spikes(ejection_on(end) - pre_stim : ...
                ejection_off(end)), zeros(1, post_stim)];
    end
    % control of same length for all snippets
    spikes_sizes = cell2mat(cellfun(@numel, spike_snippets, 'uni', false));
    [~, max_idx] = max(spikes_sizes);
    % adjust lengths of snippets to longest if unequal
    if ~all(spikes_sizes == spikes_sizes(max_idx))
        for stim = 1:numel(spike_snippets)
            spike_snippets{stim} = ...
                [spike_snippets{stim}, ...
                zeros(1, spikes_sizes(max_idx) - numel(spike_snippets{stim}))];
        end
    end
    spike_snippets = vertcat(spike_snippets{:});
end