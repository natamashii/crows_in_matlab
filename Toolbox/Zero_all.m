
% Anzahlen 0-4
% Mit Rundem und Quadratischem Hintergrung
% Kontrollen:
%   1. Area
%   2. Density
%   3. Luminance
%
% NAMENSGEBUNG:
%   Standard Rund: 10,11,12... 45
%   Control Rund: 100,101,102...405
%
%   Standard Quadratisch: S10,S11,S12... S45
%   Control Quadratisch: S100,S101,S102...S405


clear;
colordef none;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% rng shuffle  %for TRULY randomized output!! (09.11.2014)
% reseed rand generator. else same results return...
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% - VARIABLEN--------------------
% Fläche Kreis = pi * r²

stimuli_path = 'C:\Users\admin\Documents\Dropbox\Num Zero\Stimuli\';

bilder = [4 4 4 4] ;    %number of images per number
% bilder = [2 2 1 1] ;    %number of images per number
lowcut = 1.05;      %lowcut for density original= 1.05
highcut = 4.95;     %highcut for density; original highcut = 4.95

min_dist = 0.48;   %minimum distance between individual dots

dot_size = [0.35:0.01:0.55]; % :19 %Größe der Kreise (leicht variabel) für Standard Stimuli!


winsize_x = 140; %Größe des zu speichernden Bildes und des Figuren-Fensters
winsize_y = 140; % Original : 120

max_num =length(bilder); %bis zu welcher anzahl sollen bilder generiert werden


%mögliche dot positionen
dot_pos_min = 1;
dot_pos_max = 9;
abstand = 4.7; %abstand zum bild mittelpunkt, damit punkte im hintergrundkreis bleiben

sq_size = 0.1; % SQUARE SIZE (10-0.1)

fac = shuffle(repmat(dot_size,1,9)); %multiple gleiche dot größen und mischen


pos=[200, 200, winsize_x, winsize_y]; %wo die figur erscheint auf dem Monitor und wie groß sie ist
set(gcf,'Position',pos)

%Kreisgenerierung
t = (0:2*pi/200:2*pi);
x = sin(t);
y = cos(t);

backg = 0.5; %original: 0.4;    %background color
backg_cnt = 0.35; %background for control (lower luminance)

size1x = 1;     % breite der dots
size1y = 1;     % höhe der dots



%% STANDARD

% ZERO Standard generierung RUND
i = 99;
while(i<100)
    
    fill(x*5+5,y*5+5,[backg,backg,backg]); %umrandungswerte und RGB farb werte
    
    axis([0 10 0 10])
    axis square off
    
    %%%%%% take a snapshot
    f = getframe(gcf);
    [img, map] = frame2im(f);
    imwrite(img, strcat(stimuli_path,'00.bmp'));
    i= i+1;
end



% Delay Bild (GRÜN) RUND
i = 99;
while(i<100)
    fill(x*5+5,y*5+5,[.2,.4,0.2]); %umrandungswerte und RGB farb werte
    axis([0 10 0 10])
    axis square off
    
    %%%%%% take a snapshot
    f = getframe(gcf);
    [img, map] = frame2im(f);
    imwrite(img, strcat(stimuli_path,'G.bmp'));
    i= i+1;
end



% Generierung der PunktBilder RUND standard ---------------------------------

for dots=1:max_num
    
    i = dots*10;
    
    while(i < (dots*10 + bilder(dots)))
        fac = shuffle(fac);	%groesse der Kreise
        
        %dot positionen
        position = dot_pos_min  + (dot_pos_max-dot_pos_min)*rand(2,dots); % x und y position in einem geben lassen für alle punkte
        
        %prüfen ob dots innerhalb des hintergrunds liegen: (taking dot size
        %into account
        for j=1:dots
            check = false;
            while ~check
                distance = sqrt(abs(position(1,j)-5)^2 + abs(position(2,j)-5)^2);
                if distance + fac(j) > abstand
                    position(:,j) = dot_pos_min  + (dot_pos_max-dot_pos_min)*rand(2,1);
                else
                    check=true;
                end
            end
        end
        
        pos=[200, 200, winsize_x, winsize_y]; %wo die figur erscheint auf dem Monitor und wie groß sie ist
        set(gcf,'Position',pos)
        
        fill(x*5+5,y*5+5,[backg,backg,backg]); hold on
        axis([0 10 0 10])
        
        h=zeros(dots,1); xx=zeros(dots,2);
        if dots>1
            s = sort(fac(1:dots), 'descend');
            min_dist = s(1) + s(2) + 0.05; %0.02
        end
        
        for j=1:dots
            h(j)=fill(x*size1x*fac(j)+position(1,j) ,y*size1y*fac(j)+position(2,j),[0.0,0.0,0.0]);
            xx(j,:)= [position(1,j) position(2,j)];
            set(h(j),'EdgeColor','None')
        end
        axis square off
        hold off
        
        %%%%%% take a snapshot
        f = getframe(gcf);
        [img, map] = frame2im(f);
        filename=strcat (num2str(i),'.bmp');
        imwrite(img, strcat(stimuli_path,filename));
        
        if dots >1
            dens = density(xx(:,1),xx(:,2));
            if (mean(dens) > lowcut && mean(dens) < highcut ) && (min(dens) > min_dist)
                i= i+1;
            end
        else i=i+1;
        end
        clear h xx dens place
    end
    
end

% Generierung der PunktBilder SQUARE Standard ---------------------------------

% Hintergrundbild generierung SQUARE
i = 99;
while(i<100)
    
    %     fill(x*5+5,y*5+5,[backg,backg,backg]); %umrandungswerte und RGB farb werte
    fill([sq_size 10-sq_size 10-sq_size sq_size],[sq_size sq_size 10-sq_size 10-sq_size],[backg,backg,backg]); %umrandungswerte und RGB farb werte
    axis([0 10 0 10])
    axis square off
    
    %%%%%% take a snapshot
    f = getframe(gcf);
    [img, map] = frame2im(f);
    imwrite(img, strcat(stimuli_path,'S00.bmp'));
    i= i+1;
end



% Delay Bild (GRÜN) SQUARE
i = 99;
while(i<100)
    fill([sq_size 10-sq_size 10-sq_size sq_size],[sq_size sq_size 10-sq_size 10-sq_size],[.2,.4,0.2]); %umrandungswerte und RGB farb werte
    
    %     fill(x*5+5,y*5+5,[.2,.4,0.2]); %umrandungswerte und RGB farb werte
    axis([0 10 0 10])
    axis square off
    
    %%%%%% take a snapshot
    f = getframe(gcf);
    [img, map] = frame2im(f);
    imwrite(img, strcat(stimuli_path,'SG.bmp'));
    i= i+1;
end

% STANDARD sQUARE
for dots=1:max_num
    
    i = dots*10;
    
    while(i < (dots*10 + bilder(dots)))
        fac = shuffle(fac);	%groesse der Kreise
        
        %dot positionen
        position = dot_pos_min  + (dot_pos_max-dot_pos_min)*rand(2,dots); % x und y position in einem geben lassen für alle punkte
        
        %prüfen ob dots innerhalb des hintergrunds liegen: (taking dot size
        %into account
        for j=1:dots
            check = false;
            while ~check
                distance = sqrt(abs(position(1,j)-5)^2 + abs(position(2,j)-5)^2);
                if distance + fac(j) > abstand
                    position(:,j) = dot_pos_min  + (dot_pos_max-dot_pos_min)*rand(2,1);
                else
                    check=true;
                end
            end
        end
        
        pos=[200, 200, winsize_x, winsize_y]; %wo die figur erscheint auf dem Monitor und wie groß sie ist
        set(gcf,'Position',pos)
        
        fill([sq_size 10-sq_size 10-sq_size sq_size],[sq_size sq_size 10-sq_size 10-sq_size],[backg,backg,backg]); %umrandungswerte und RGB farb werte
        hold on
        axis([0 10 0 10])
        
        h=zeros(dots,1); xx=zeros(dots,2);
        if dots>1
            s = sort(fac(1:dots), 'descend');
            min_dist = s(1) + s(2) + 0.05; %0.02
        end
        
        for j=1:dots
            h(j)=fill(x*size1x*fac(j)+position(1,j) ,y*size1y*fac(j)+position(2,j),[0.0,0.0,0.0]);
            xx(j,:)= [position(1,j) position(2,j)];
            set(h(j),'EdgeColor','None')
        end
        axis square off
        hold off
        
        %%%%%% take a snapshot
        f = getframe(gcf);
        [img, map] = frame2im(f);
        filename=strcat ('S',num2str(i),'.bmp');
        imwrite(img, strcat(stimuli_path ,filename));
        
        if dots >1
            dens = density(xx(:,1),xx(:,2));
            if (mean(dens) > lowcut && mean(dens) < highcut ) && (min(dens) > min_dist)
                i= i+1;
            end
        else i=i+1;
        end
        clear h xx dens place
    end
    
end


%% Generierung der PunktBilder KONTROLLE : AREA + DENS + LUMINANCE ---------
total_area = 1.8;

lowcut = 2.4;    % Dichte der Punkte
highcut = 2.472; % mit 3% abweichung


%ZERO Controlle RUND
i = 99;
while(i<100)
    
    fill(x*5+5,y*5+5,[backg_cnt,backg_cnt,backg_cnt]); %umrandungswerte und RGB farb werte
    
    axis([0 10 0 10])
    axis square off
    
    %%%%%% take a snapshot
    f = getframe(gcf);
    [img, map] = frame2im(f);
    imwrite(img, strcat(stimuli_path,'000.bmp'));
    i= i+1;
end

% ZERO Controlle SQUARE
i = 99;
while(i<100)
    
    %     fill(x*5+5,y*5+5,[backg,backg,backg]); %umrandungswerte und RGB farb werte
    fill([sq_size 10-sq_size 10-sq_size sq_size],[sq_size sq_size 10-sq_size 10-sq_size],[backg_cnt,backg_cnt,backg_cnt]); %umrandungswerte und RGB farb werte
    axis([0 10 0 10])
    axis square off
    
    %%%%%% take a snapshot
    f = getframe(gcf);
    [img, map] = frame2im(f);
    imwrite(img, strcat(stimuli_path,'S000.bmp'));
    i= i+1;
end

% CONTROLLE RUND
for dots=1:max_num
    i = dots*100;
    
    while(i < (dots*100 + bilder(dots)))
        
        % radius = sqrt( (total_area/dots) / pi);
        % min_dist = ( radius + (radius/(dots)) ) * 2 + 0.02 % radius + (radius/dots)*2 + 0.007
        
        sizes = calc_area(total_area,dots); %get the dot sizes (radius) for equal area althogether
        
        %dot positionen
        position = dot_pos_min  + (dot_pos_max-dot_pos_min)*rand(2,dots); % x und y position in einem geben lassen für alle punkte
        
        %prüfen ob dots innerhalb des hintergrunds liegen: (taking dot size
        %into account
        for j=1:dots
            check = false;
            
            while ~check
                distance = sqrt(abs(position(1,j)-5)^2 + abs(position(2,j)-5)^2);
                if distance + sizes(j) > abstand
                    position(:,j) = dot_pos_min  + (dot_pos_max-dot_pos_min)*rand(2,1);
                else
                    check=true;
                end
                
            end
            
        end
        
        
        pos=[200, 200, winsize_x, winsize_y]; %wo die figur erscheint auf dem Monitor und wie groß sie ist
        set(gcf,'Position',pos)
        
        fill(x*5+5,y*5+5,[backg_cnt,backg_cnt,backg_cnt])
        hold on
        axis([0 10 0 10])
        
        h=zeros(dots,1); xx=zeros(dots,2);
        
        if dots > 1
            s = sort(sizes, 'descend');
            min_dist = s(1) + s(2) + 0.01;
        end
        
        for j=1:dots
            h(j)=fill(x*size1x*sizes(j)+position(1,j) ,y*size1y*sizes(j)+position(2,j),[0.0,0.0,0.0]);
            xx(j,:)= [position(1,j) position(2,j)];
            set(h(j),'EdgeColor','None')
        end
        axis square off
        hold off
        
        %%%%%% take a snapshot
        f = getframe(gcf);
        [img, map] = frame2im(f);
        filename=strcat (num2str(i),'.bmp');
        imwrite(img, strcat(stimuli_path,filename));
        
        
        if dots >1
            dens = density(xx(:,1),xx(:,2));
            if (mean(dens) > lowcut && mean(dens) < highcut ) && (min(dens) > min_dist)
                i= i+1;
                %         densities(dots,i/10)=mean(dens);
            end
        else i=i+1;
        end
        clear h xx dens place sizes
    end
    
end



% CONTROLLE SQUARE
% Generierung der PunktBilder KONTROLLE : AREA + DENS + Luminance ---------------------
for dots=1:max_num
    i = dots*100;

    while(i < (dots*100 + bilder(dots)))

        % radius = sqrt( (total_area/dots) / pi);
        % min_dist = ( radius + (radius/(dots)) ) * 2 + 0.02 % radius + (radius/dots)*2 + 0.007

        sizes = calc_area(total_area,dots); %get the dot sizes (radius) for equal area althogether

        %dot positionen
        position = dot_pos_min  + (dot_pos_max-dot_pos_min)*rand(2,dots); % x und y position in einem geben lassen für alle punkte

        %prüfen ob dots innerhalb des hintergrunds liegen: (taking dot size
        %into account
        for j=1:dots
            check = false;

            while ~check
                distance = sqrt(abs(position(1,j)-5)^2 + abs(position(2,j)-5)^2);
                if distance + sizes(j) > abstand
                    position(:,j) = dot_pos_min  + (dot_pos_max-dot_pos_min)*rand(2,1);
                else
                    check=true;
                end

            end

        end


        pos=[200, 200, winsize_x, winsize_y]; %wo die figur erscheint auf dem Monitor und wie groß sie ist
        set(gcf,'Position',pos)

        fill([sq_size 10-sq_size 10-sq_size sq_size],[sq_size sq_size 10-sq_size 10-sq_size],[backg_cnt,backg_cnt,backg_cnt]); %umrandungswerte und RGB farb werte
        hold on
        axis([0 10 0 10])

        h=zeros(dots,1); xx=zeros(dots,2);

        if dots > 1
            s = sort(sizes, 'descend');
            min_dist = s(1) + s(2) + 0.01;
        end

        for j=1:dots
            h(j)=fill(x*size1x*sizes(j)+position(1,j) ,y*size1y*sizes(j)+position(2,j),[0.0,0.0,0.0]);
            xx(j,:)= [position(1,j) position(2,j)];
            set(h(j),'EdgeColor','None')
        end
        axis square off
        hold off

        %%%%%% take a snapshot
        f = getframe(gcf);
        [img, map] = frame2im(f);
        filename=strcat ('S',num2str(i),'.bmp');
        imwrite(img, strcat(stimuli_path,filename));


        if dots >1
            dens = density(xx(:,1),xx(:,2));
            if (mean(dens) > lowcut && mean(dens) < highcut ) && (min(dens) > min_dist)
                i= i+1;
                %         densities(dots,i/10)=mean(dens);
            end
        else i=i+1;
        end
        clear h xx dens place sizes
    end

end

close all



%% play sound when done
f=400;
ts=1/15000;
T=.3;
t=0:ts:T;
y=sin(2*pi*f*t);
soundsc(y)

