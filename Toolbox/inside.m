function inside = inside(x,y,xbig,ybig,radius,radiusbig,mindistance)

  if (sqrt((x-xbig)*(x-xbig)+(y-ybig)*(y-ybig)) < radiusbig-radius-mindistance)
      inside = 1;
  else inside = 0;
  end
