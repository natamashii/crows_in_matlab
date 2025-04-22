function [shape_handle]=errorshape(mean_data, error_data, shape_color, shape_transparency, varargin)
%errorshape(mean_data, error_data, shape_color, shape_transparency, varargin) plots a shape in the range
%       of ERROR_DATA around a data-vector MEAN_DATA.
%
%       Works with single data or multiple datasets in cell.
%
%   MEAN_DATA   - vector around which the error data will be plotted
%   ERRROR_DATA - vector with e.g. sem values corresponding to each value
%                 in MEAN_DATA
%   SHAPE_COLOR - [R G B]; for details see patch()
%   SHAPE_TRANSPARENCY - value from 0 to 1. 1-opaque
%
%   VARARGIN    - offset value / x-value starting point for data e.g. [-400] / vector with x-values for each datapoint
%
%   uses patch()
%
%   -pr
if iscell(mean_data)
    if ~iscell(error_data) & ~iscell(shape_color)
        error('ERROR: mean_data, error_data, shape_color must have the same format!')
    end
else
    mean_data={mean_data};
    error_data={error_data};
end

if isempty(varargin)
    x_start=0;
else
    x_start=varargin{1};
end

if ~iscell(shape_color)
    shape_color={shape_color};
end

for i=1:size(mean_data,find(max(size(mean_data))))
    %upper boundary of shape
    y1=mean_data{i}+error_data{i};
    if max(size(x_start))==1
        x1=[1:size(y1,2)]+x_start;
    else
        x1=x_start;
    end
    x1=x1(isnan(y1)==0);
    y1=y1(isnan(y1)==0);
    
    %lower boundary of shape
    y2=mean_data{i}-error_data{i};
    if max(size(x_start))==1
        x2=[1:size(y2,2)]+x_start;
    else
        x2=x_start;
    end
    x2=x2(isnan(y2)==0);
    y2=y2(isnan(y2)==0);
    
    shape_handle(i)=patch([x1 fliplr(x2)], [y1 fliplr(y2)], shape_color{i});
    set(shape_handle(i),'EdgeColor',shape_color{i})
    set(shape_handle(i),'FaceAlpha',shape_transparency,'EdgeAlpha',shape_transparency)
end