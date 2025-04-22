function linetags(varargin);
% SYNTAX:
%        linetags('label1', 'label2', 'label3'....)
%            OR
%        linetags(labelstringmatrix)
%
% This function creates a legend for plots drawn in "plotprep" windows.
% The number of labels must correspond to the number of lines in the main
% figure window.
%
% last modified 10/13/99  --WA

if size(varargin{1}, 1) > 1 & length(varargin) == 1,
   labels = varargin{:};
else
   labels = [];
   for i = 1:length(varargin),
      labels = strvcat(labels, varargin{i});
   end
end

[rows cols] = size(labels);
line_handles = findobj(gca, 'type', 'line');

if rows ~= length(line_handles),
   error('******* number of labels must correspond to the number of lines in the current plot *******');
   return
end

for i = 1:rows,
   l = line_handles(i);
   set(l, 'tag', labels(rows+1-i, :));
   color(i, 1:3) = get(l, 'color');
   lw(i) = get(l, 'linewidth');
   tls = get(l, 'linestyle');
   ls(i, 1:length(tls)) = tls;
   %marker(i) = get(l, 'marker');
   %markersize(i) = get(l, 'markersize');
end

%create legend
legheight = .04*rows;
if legheight > .27, legheight = .27; end
legwidth = .07;
leg = subplot(3, 9, 26);
set(leg, 'position', [.7, .02, legwidth, legheight], 'tag', 'legend');
pts = meshgrid(1:rows);
leglines = line(pts', fliplr(pts));
for i = 1:rows,
   set(leglines((rows+1)-i), 'tag', labels(i, :));
end
axes(leg);
text(pts(:, rows)+1, pts(1, :), flipud(labels));
axis off
pos = get(gca, 'position');
pos(2) = 0.05;
set(gca, 'position', pos);
PRIMAX = get(gcf, 'userdata');
axes(PRIMAX);



