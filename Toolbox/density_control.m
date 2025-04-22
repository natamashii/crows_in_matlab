function dot_pos_updt = density_control(dot_pos, min_dist)

% Function to control density of any two dots

% get distances between dots
distances = zeros(size(dot_pos, 2));

% iterate over each dot
for d = 1:size(dot_pos, 2)
    for dd = 1:size(dot_pos, 2)
        too_close = true;   % boolean that toggles when density is alright
        distances(d, dd) = sqrt((dot_pos(1, d) - dot_pos(1, dd))^2 + ...
            (dot_pos(2, d) - dot_pos(2, dd))^2);
        if distances(d, dd) < min_dist
            too_close = true;
        end
        
    end
end


end