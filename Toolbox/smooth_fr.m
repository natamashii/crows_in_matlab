function [ smoothed_fr ] = smooth_fr( firingrate, window )
%SMOOTH_FR(FIRINGRATE,WINDOW) smoothes vector FIRINGRATE containing firingrates with a smoothing-window of WINDOW
%   Vector becomes shorter during smooting. In case of an even window the
%   average fr is calculated to floor(window/2)

smoothed_fr=nan(size(firingrate));

for i=ceil(window/2):size(firingrate,2)-(ceil(window/2))+mod(window,2)

    smoothed_fr(1,i)=mean(firingrate(i-(round(window/2)-1):i+(round(window/2))-mod(window,2)));
    
end
end


