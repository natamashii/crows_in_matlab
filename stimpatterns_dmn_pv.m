%GENERATE_PATTERNS_STANDARD_AND_CONTROL

clear;
close all
%colordef none; %#ok<COLORDEF>
set(groot);

%% Parameters

stim_pathes = {"D:/MasterThesis/Stimuli_creation/"};

%PV = false; %true; 

for foldernum = 1:length(stim_pathes)
    %colordef none; 
    set(groot);
    disp(foldernum);
    stim_path = stim_pathes{foldernum};
    % Picture specs
    %winsize_x = 220; %
    %winsize_y = 220; %
    %pos = [220, 220, winsize_x/2, winsize_y/2]; %half for mac for getframe to get correct size
    winsize_x = 210; %
    winsize_y = 210; %
    pos = [210, 210, winsize_x/2, winsize_y/2];
    set(gcf,'Position',pos,'Units','pixels');
    
     % Numerosity specs
    %nums = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,18,19,22,25,28,32];  % match 4-fach [1,2,3,4,5,6,7,8,9,10], non match [11,12,13,14,16,18,19,22,25,28,32] 1-fach
    nums = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 18, 19, 21, 22, 23, 25, 27, 28, 32, 35, 38, 41, 44, 47];
    imagesii = [1, 1, 1, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
    %imagesii = [4,4,4,4,4,4,4,4,4,4,1,1,1,1,1,1,1,1,1,1,1]; % Number of different images per numerosity and condition, 4 match, 1 non-match
    
    
    % Dots
    dot_rad = [.18];    % Radius - other: [.23, .235]
    min_dist = 0.2;        %minimum distance between dots [a.U.], 0.2 (takes forever for 32 but possible)
    lowcut = 0.01;         %lowcut for density; original = 1.05
    highcut = 20;           %highcut for density; for sample <8 = 4.95, for higher 
    
    % Same for controls
    total_area = 2;     %2;
    mindist_cnt = 0.2;  %0.2   % minimum distance between dots [a.U.] 
    lowcut_cnt = 4;        % Dichte der Punkte: 4-4.2 lower value --> higher density
    highcut_cnt = 4.2;     % mit 5% abweichung
    
    % Background circle
    xbig = 5.5;                   % center, 5,5 original
    ybig = 5.5;
    radiusbig = 5;              % radius
    backcolor = [0.5 0.5 0.5];  % color
    edgecolor2 = [0 0.5 0.5]; %PV
     
    %edgecolor = backcolor;
    % if PV == true
    %     edgecolor = edgecolor2;
    % end
    
    % Circle generation
    t = (0:2*pi/200:2*pi);
    x = sin(t);
    y = cos(t);
    
    
    %% Generate dot stimuli
   
    % Loop over numbers to generate
    for idx = 1:1:length(nums)
        number = nums(idx);
        if number == 32 | number == 28
            disp(number);
        end
        images = imagesii(idx);

        %% Standard stimuli
        i = 0;
        while i <= images-1 % while not enough images
            % if PV == true
            %     fill(x*(radiusbig+0.3)+xbig, y*(radiusbig+0.3)+ybig, edgecolor); 
            %     % edge around circle
            %     hold on 
            % end
            fill(x * radiusbig + xbig, y * radiusbig + xbig, backcolor); % Draw ackground circle
            hold on
            axis([0 12 0 12]);
            axis square off

            % Dot specs
            %radius = shuffle(dot_rad(1):0.00001:dot_rad(2)); %lab intern function
            radius = zeros(number, 1) + dot_rad(1); % same radius for all

            %Random dot positions
            dpos = 1 + 8 * rand(2, number);

            %Check whether dots lie within background circle (taking dot size
            %into account)
            for d=1:number %loop over dots
                check = false;
                while ~check
                    distance = sqrt(abs(dpos(1,d)-xbig)^2 + abs(dpos(2,d)-ybig)^2);
                    if distance + 2 * radius(d) > 4.97 %4.6 %new values if outside
                        dpos(:, d) = 1 + 8 * rand(2, 1);
                    else
                        check=true;
                    end
                end
            end

            % Get minimum distance between two biggest points
            if number > 1
                s = sort(radius(1:number), 'descend');
                dist_min = s(1) + s(2) + min_dist;
            end

            % Check that density of any two dots lay within density range
            print_pic = false;
            if number > 1
                dens = density(dpos(1, 1:number), dpos(2, 1:number));
                % disp(min(dens)-dist_min); %Lena minimal distance is not met
                if (mean(dens) > lowcut && mean(dens) < highcut ) &&...
                        (min(dens) > dist_min)
                    print_pic = true;
                end
            else
                print_pic = true;
            end

            % Plot dot array if density criteria are fulfilled
            if print_pic

                % Loop over dots
                for d2 = 1:number
                    % Draw dots
                    fill(x * radius(d2) + dpos(1, d2), y * radius(d2) + dpos(2, d2),...
                        [0 0 0],'EdgeColor',[0 0 0]);
                end

                % Take a snapshot
                f = getframe(gcf);
                [img, ~] = frame2im(f);

                % Optionally mirror/flip/rotate image before saving
                % img = rot90(img,2);

                % if PV == false
                %     filename = strcat('S',strcat(num2str(number),...
                %         num2str(i)),'.bmp'); 
                % else
                %     filename = strcat('S',strcat(num2str(number),...
                %         num2str(i)),'_PV.bmp'); 
                % end

                % First save normal image
                filename = strcat('S', strcat(num2str(number),...
                        num2str(i)), '.bmp');
                %imwrite(img, strcat(stim_path,filename));
                hold off

                % save the same img with colored ring
                % edgecolor = edgecolor2;
                %colordef none; 
                set(groot);
                set(gcf, 'Position', pos, 'Units', 'pixels');
                % fill(x*(radiusbig+0.3)+xbig, y*(radiusbig+0.3)+ybig,
                % edgecolor2); % draws colored ring
                % hold on 
                fill(x * radiusbig + xbig, y * radiusbig + xbig, backcolor); % Draw ackground circle
                hold on
                axis([0 12 0 12]);
                axis square off
                % Loop over dots
                for d2 = 1:number
                    % Draw dots
                    fill(x * radius(d2) + dpos(1, d2), y * radius(d2) + dpos(2, d2),...
                        [0 0 0], 'EdgeColor', [0 0 0]);
                end
                f = getframe(gcf);
                [img, ~] = frame2im(f);

                filename = strcat('S', strcat(num2str(number),...
                        num2str(i)), '_PV.bmp'); 
                %imwrite(img, strcat(stim_path,filename));
                hold off
                i = i + 1;
            end % if (print_pic)
        end % while (images)

        %% Control stimuli (area + density)
        i = 0; 
        %disp(number); 
        while i <= images-1 % while not enough images
            fill(x * radiusbig + xbig, y * radiusbig + xbig, backcolor); % Draw ackground circle
            hold on
            axis([0 12 0 12]);
            axis square off

            % Dot specs
            sizes = calc_area(total_area, number); %get the dot sizes (radius) for equal area althogether

            %Random dot positions
            dpos = 1 + 8 * rand(2, number);

            %Check whether dots lie within background circle (taking dot size
            %into account)
            for d=1:number %loop over dots
                check = false;
                while ~check
                    distance = sqrt(abs(dpos(1, d)- xbig)^2 + abs(dpos(2, d) - ybig)^2);
                    if distance + 2 * sizes(d) > 4.97  % wieso 4.6? sollte gesamt Durchmesser nicht überschreiten --> 4.8
                        dpos(:, d) = 1 + 8 * rand(2, 1);
                    else
                        check=true;
                    end
                end
            end

            % Get minimum distance between two biggest points
            if number > 1
                s = sort(sizes(1:number), 'descend');
                dist_min = s(1) + s(2) + mindist_cnt;
            end

            % Check that density of any two dots lay within density range
            print_pic = false;
            if number > 1
                dens = density(dpos(1, 1:number),dpos(2, 1:number));

                % % print density if min criteria is fullfilled:
                % if (min(dens) > dist_min)
                %     disp([num2str(number),' mean dens:',num2str(mean(dens)),' dist_min:', num2str(min(dens)), 'cut off',num2str(dist_min)]);
                % end

                if (mean(dens) > lowcut_cnt && mean(dens) < highcut_cnt ) ...
                       && (min(dens) > dist_min)
                    print_pic = true;
                end
            else
                print_pic = true;
            end

            % Plot dot array if density criteria are fulfilled
            if print_pic

                % Loop over dots
                for d2 = 1:number
                    % Draw dots
                    fill(x * sizes(d2) + dpos(1, d2), y * sizes(d2) + dpos(2, d2),...
                        [0 0 0], 'EdgeColor', [0 0 0]);
                end

                % Take a snapshot
                f = getframe(gcf);
                [img, ~] = frame2im(f);
                filename = strcat('C', strcat(num2str(number),...
                        num2str(i)), '.bmp'); 


                imwrite(img, strcat(stim_path,filename));
                hold off


                % save the same img with colored ring
                %colordef none; 
                set(groot);
                set(gcf, 'Position', pos, 'Units', 'pixels');
                % fill(x * (radiusbig + 0.3) + xbig, y * (radiusbig + 0.3) + ybig, edgecolor2); 
                hold on 
                fill(x * radiusbig + xbig, y * radiusbig + xbig, backcolor); % Draw ackground circle
                axis([0 12 0 12]);
                axis square off
                % Loop over dots
                for d2 = 1:number
                    % Draw dots
                    fill(x * sizes(d2) + dpos(1, d2), y * sizes(d2) + dpos(2, d2),...
                        [0 0 0], 'EdgeColor', [0 0 0]);
                end
                f = getframe(gcf);
                [img, ~] = frame2im(f);

                filename = strcat('C', strcat(num2str(number),...
                        num2str(i)), '_PV.bmp'); 
                %imwrite(img, strcat(stim_path,filename));
                hold off


                i = i + 1;
            end % if (print_pic)
        end % while (images)
    end % for (number)
    
    reset(groot);
    close all
    
end % for stim path folders

%% play sound when done
f = 400;
ts = 1 / 15000;
T = .3;
t = 0:ts:T;
y = sin(2 * pi * f * t);
soundsc(y)