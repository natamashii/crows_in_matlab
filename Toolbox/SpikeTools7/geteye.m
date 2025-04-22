function [x, y, v] = geteye(trials, start_code, start_offset, duration)
% SYNTAX:
%			[x y velocity] = geteye(trials, start_code, start_offset, duration)
%
% The matrices returned are arranged (trials, time).  If the requested epoch is longer
% than the time during which eye data was collected on a given trial, NaNs are returned
% to fill the gaps.
%
% SpikeTools 7 version  March, 2001  --WA

SpikeConfig = spiketools_config(0);
[SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spikestat;

numtrials = length(trials);
xpos = SpikeInfo.EyeXPos;
ypos = SpikeInfo.EyeYPos;
indx = SpikeInfo.EyeIndex;
enum = SpikeInfo.EyeSamplesPerTrial;
freq = SpikeInfo.EyeFrequency;

starteye = get_code_time(trials, SpikeConfig.StartEyeDataCode);
starttime = get_code_time(trials, start_code) + start_offset;
dtime = starttime - starteye;
if any(dtime < 0),
   error('***** Error: requested epoch preceded start of eye data collection on one or more trials *****');
   return
end
doffset = round(freq*(dtime/1000));
numsamps = round(freq*(duration/1000));
x = zeros(numtrials, numsamps);
y = x;
v = x;

for i = 1:numtrials,
   t = trials(i);
   tindx = indx(t):(indx(t)+enum(t)-1);
   tx = xpos(tindx);
   ty = ypos(tindx);
   pindx = doffset(i):(doffset(i)+numsamps-1);
   if (max(pindx) > length(tx)), %should be interchangeable with (length(ty))
      fbreak = max(find(pindx < length(tx)));
      x(i, 1:numsamps) = NaN;
      y(i, 1:numsamps) = NaN;
      x(i, 1:fbreak) = tx(pindx(1:fbreak))';
      y(i, 1:fbreak) = ty(pindx(1:fbreak))';
   elseif isnan(pindx), %for example, start_code not found
      x(i, 1:numsamps) = NaN;
      y(i, 1:numsamps) = NaN;
   else
	   x(i, :) = tx(pindx)';
      y(i, :) = ty(pindx)';
   end
end

x = x./SpikeConfig.EyeUnitsPerDegree;
y = y./SpikeConfig.EyeUnitsPerDegree;
v(:, 1:numsamps-1) = (freq*sqrt((diff(x').^2) + (diff(y').^2))')/SpikeConfig.EyeUnitsPerDegree;
