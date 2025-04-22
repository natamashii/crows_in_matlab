function plot_preedit
% Function that changes some cosmetic aspects of the current figure (gcf)
% MK, 27.11.18


% Font size
font_size = 12;

% Find all sorts of objects in figure
txt_obj = findall(gcf,'Type','text');
leg_obj = findall(gcf,'Type','legend');
ax_obj = findall(gcf,'Type','axes');

% Set most things in the axes
set(ax_obj,...
    'Box','off',...
    'TickDir','out',...
    'XColor','k','YColor','k',...
    'LineWidth', 1,...
    'FontSize',font_size);

% Change font size text and legend objects
set(txt_obj,'FontSize',font_size)
set(leg_obj,'FontSize',font_size)

% Change dots in raster plot
% dot_obj = findall(ax_obj(4),'Type','Line');
% set(dot_obj,'MarkerSize',5)
% 
% % Change dots in Tuning curve
% dot_obj = findall(ax_obj(2),'Type','Line');
% set(dot_obj,'MarkerSize',5)

end