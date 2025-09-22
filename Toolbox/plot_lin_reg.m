function plot_lin_reg(lin_reg_pattern, patterns, numerosities, ...
    jitterwidth, linestyle, linewidth, colours_pattern)

% function to plot linear regression curve & mark p value & effect size as
% text within damn plot

jitter_dots = [-jitterwidth, 0, jitterwidth];

% iterate over patterns
for pattern = 1:length(patterns)
    plot(numerosities(:, 1) + jitter_dots(pattern), ...
        lin_reg_pattern{pattern + 1, 7}{2}, ...
        "Color", colours_pattern{pattern}, "LineStyle", linestyle, ...
        "LineWidth", linewidth);
end

end