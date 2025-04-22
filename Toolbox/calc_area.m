function r_sizes = calc_area(total_area, number_of_dots)
% SYNTAX:
%        r_sizes = calc_area(total_area, number_of_dots)
% total_area = Value with the area that all the dots should add up to
% number_of_dots = integer with on how many dots the total area is distributed to 
%
% This function returns a vektor with radius' for dot sizes that add up to a specific
% area.
%
% Area = r² * pi
% r = sqrt ( area / pi)
%
% Created Mai 2014  -- HD

% total_area = 4;
% number_of_dots = 30;

% rng shuffle %reseed rand generator. else over and over same results
r_sizes = zeros(number_of_dots,1);    
r = sqrt( (total_area/number_of_dots) / pi) ;
dot_min = r - r/(number_of_dots * 1.5 ); %% MK, 20.5.19; Original: *2



for i=1:number_of_dots

    if i<number_of_dots
        rest=[]; % shuffle the possible radius'  :

        rest = [dot_min*dot_min*pi  : 0.000001 : (total_area - sum(r_sizes(:) .* r_sizes(:) *pi) - (number_of_dots -i)*(dot_min * dot_min * pi) )]; % caluclate the area for the dot
        
        if isempty(rest) ==1
             r_sizes(i) = dot_min;
        else 
        rest = shuffle([dot_min*dot_min*pi  : 0.001 : (total_area - sum(r_sizes(:) .* r_sizes(:) *pi) - (number_of_dots -i)*(dot_min * dot_min * pi) )]); % caluclate the area for the dot

        zuf=round(rand(1)*10);
        for i1=1:zuf
            rest = shuffle(rest);
        end
        clear i1 zuf;

        r_sizes(i) = sqrt( rest(1) / pi ); %calculate r from area
        end

    else r_sizes(i) = sqrt((total_area - sum((r_sizes(:) .* r_sizes(:) *pi)))/ pi) ;
    end
    
end

end
