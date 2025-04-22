function overlap = overlap(x1,y1,x2,y2,radius1,radius2,mindistance)

  if (sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)) < (radius1+radius2+mindistance))
      overlap = 1;
  else overlap = 0;
  end
  