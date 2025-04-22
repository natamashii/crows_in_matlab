%GENERATE_PATTERNS_STANDARD

clear;
colordef none;
for color = 1:6
    winsize_x = 270;
    winsize_y = 270;
    pos = [400, 400, winsize_x, winsize_y];
    set(gcf,'Position',pos)

    % circle generation
    t = (0:2*pi/200:2*pi); %(1/8:1/4:1)'*2*pi; ( Square generation )
    x = sin(t);
    y = cos(t);

    % circle generation
    tc = (0:2*pi/200:2*pi);
    xc = sin(tc);
    yc = cos(tc);

    % background circle
    xbig = 5;                   % center
    ybig = 5;
    radiusbig = 5;              % radius
    backcolor = [0.2 0.2 0.2];  % color

    % numerosity ranges
    minnumber = 4;
    maxnumber = 5;

    % dots
    minradius = 0.35;
    maxradius = 0.53;
    % color = 1;
    % Colors - Red, Green, Blue, Yellow, Purple, Black
    dotcolor  = [0.0 0.0 0.0; 0.0 0.0 0.0; 0.0 0.0 0.0; 0.0 0.0 0.0; 0.0 0.0 0.0; 0.0 0.0 0.0];

    % distance(density) ranges
    maxDistance = 5.03; % low density
    minDistance = 5.0; % low density

    % minimum distance of dots to border of background circle
    distanceToBorder = 0.4;
    % minimum distance of dots to other dots
    mindist = 0.2;

    % number of different images per numerosity
    images = 5;

    xpos = [4.5 4.5 4.5 4.5 4.5 4.5; 2.5 6.5 2.5 2.5 2.5 2.5; 2.5 6.5 4.5 2.5 2.5 2.5;...
        2.5 6.5 2.5 6.5 2.5 2.5; 2.3 6.7 4.5 2.3 6.7 2.5; 1.5 2.5 3.5 1.5 2.5 3.5];
    ypos = [4.5 4.5 4.5 4.5 4.5 4.5; 4.5 4.5 2.5 2.5 2.5 2.5; 5.5 5.5 2.5 2.5 2.5 2.5;...
        3.5 3.5 6.5 6.5 2.5 2.5; 2.3 2.3 4.5 6.7 6.7 2.5; 1.5 1.5 1.5 3.5 3.5 3.5];


    for number = minnumber:maxnumber
        radius = zeros(number,1);
        i = 1;
        while i <= images
            % background circle
            fill(xc*radiusbig+xbig, yc*radiusbig+xbig, backcolor);
            hold on;
            axis([0 10 0 10])
            axis square off

            for j = 1:number
                % choose a random radius between minradius and maxradius
                temp(j) = minradius + (maxradius - minradius)*rand;
                %                     temp_area(j) = temp*temp;
                radius(j) = temp(j);
            end

            % draw dots
            for j=1:number
                h = fill(x*radius(j) + (xpos(number,j)+1+(0.7-2)*rand),y*radius(j) + (ypos(number,j)+1+(0.7-2)*rand), dotcolor(color,:),'EdgeColor',dotcolor(color,:));
                hold on
            end

            % capture frame and convert to indexed color
            F = getframe;
            [img, cmap] = frame2im(F);
            [img, cmap] = rgb2ind(img, 256);
            filename = strcat('p','1',num2str(color),num2str(number),num2str(i-1),'.bmp')
            % Naming rule: Std or Control (1/2), 1st digit -> Color (1 to 5)
            % 2nd digit -> Numerosity(1 to 5), 3rd digit -> Number of image(0 to 9)
            %imwrite(img, cmap, strcat('C:\Monkey\WCortex\',filename));
            i = i+1;
            hold off;


        end % while (images)
    end % for (dots)
end
