function dot_pos = rand_dot_pos(dot_pos, dot_rad, threshold, dot_pos_limit, xbig, ybig, min_dist)

% TODO: debug with inpolygon function

% Function to make sure that generated dots are displayed within background
% circle

% iterate over each dot position
for d = 1:size(dot_pos, 2)
    all_alright = false;
    fprintf("current dot")
    disp(d)
    while ~all_alright

        within = false; % boolean that toggles when dot position is acceptible
        all_too_close = true;
        % first: control the inter-dot distances
    
        % get distances all at once to keep overview
    
    
    
        fprintf("\n check interdot distance")
        dot_distances = zeros(1, size(dot_pos, 2));
        dot_distances(d) = min_dist;
        while all_too_close
            % iterate over every dot & get distance to current dot of interest
            for dd = 1:size(dot_pos, 2)
                too_close = true;
                while too_close && d ~= dd
                    dot_distance = sqrt((dot_pos(1, d) - dot_pos(1, dd))^2 + ...
                        (dot_pos(2, d) - dot_pos(2, dd))^2);
                    % dots too close to each other
                    if dot_distance < min_dist
                        dot_pos(:, d) = dot_pos_limit * rand(2, 1);
                    else
                        too_close = false;
                        dot_distances(dd) = dot_distance;
                    end
                end
            end
            if any(dot_distances) >= min_dist
                all_too_close = false;
            end
        end
        % control all dot distances again
    
        % second: control dot is within backgorund circle
        fprintf("\n check dot vs background")
        while ~within
            dot_x = dot_pos(1, d);
            dot_y = dot_pos(2, d);
    
            % identify distance of dot to background
            distance = sqrt(abs(dot_x - xbig)^2 + abs(dot_y - ybig)^2) + 2 * dot_rad;
    
            % dot too far away from center aka not within background circle
            if distance > threshold
                dot_pos(:, d) = dot_pos_limit * rand(2, 1);
            else
                within = true;
            end
        end
        fprintf("\n penis")
        % third: control both again
        dot_x = dot_pos(1, d);
        dot_y = dot_pos(2, d);
        distance = sqrt(abs(dot_x - xbig)^2 + abs(dot_y - ybig)^2) + 2 * dot_rad;
        dot_distances = zeros(1, size(dot_pos, 2));
        dot_distances(d) = min_dist;
        for dd = 1:size(dot_pos, 2)
            if d ~= dd
                dot_distances(dd) = sqrt((dot_pos(1, d) - dot_pos(1, dd))^2 + ...
                    (dot_pos(2, d) - dot_pos(2, dd))^2);
            end
        end
        fprintf("\n Dot Background distances: \n")
        disp(distance)
        fprintf("\n Interdot distance: \n")
        disp(dot_distances)
        if distance <= threshold && any(dot_distances) >= min_dist
            all_alright = true;
        end
    end
    fprintf("\nFINAL  Dot Background distances: \n")
    disp(distance)
    fprintf("\nFINAL  Interdot distance: \n")
    disp(dot_distances)
end