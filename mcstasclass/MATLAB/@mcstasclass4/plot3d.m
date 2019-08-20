function plot3d(cls,swap_axes)
%3dplot routine for mcstasclass4
%GEG 12.28.2000
%updated
%GEG 3.31.2001
%updated for mcstas 1.6
%GEG 1.15.2002
%added shading flat view(90,0) at end
%GEG 6.14.2007
%added title line
%GEG 1.20.2009
if ~strcmp(cls.type,'2d')
    disp('error data must be of 2 d type')
else
  if nargin==1
      swap_axes=0;
  end
  xlimits=cls.limits(1:2);
  ylimits=cls.limits(3:4);
  [y,x]=size(cls.dat);
  xstart=xlimits(1)-(xlimits(2)-xlimits(1))/(2*x);
  xstop=xlimits(2)+(xlimits(2)-xlimits(1))/(2*x);
  ystart=ylimits(1)-(ylimits(2)-ylimits(1))/(2*x);
  ystop=ylimits(2)+(ylimits(2)-ylimits(1))/(2*x);
  xvec=linspace(xstart,xstop,x);
  yvec=linspace(ystart,ystop,y);
  jk=double(cls.xlabel);
    jkidx=find(jk>13);
    cls.xlabel=char(jk(jkidx));    
    jk=double(cls.ylabel);
    jkidx=find(jk>13);
    cls.ylabel=char(jk(jkidx));
  if swap_axes==1
     surf(yvec,xvec,cls.dat');
    ylabel(cls.xlabel);
    xlabel(cls.ylabel);    
  else
    surf(xvec,yvec,cls.dat);
    xlabel(cls.xlabel);
    ylabel(cls.ylabel);
  end  
end 
title(cls.title,'Interpreter','none');
shading flat; view(0,90);