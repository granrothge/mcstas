function [xvec,yvec]=createxyvec(cls)
%function for creating x and y vectors from a 2d mcstasclass file
%GEG 4.2.2001
%updated for mcstas1.6
%GEG 1.15.2001
if ~strcmp(cls.type,'2d')
    disp('error data must be of 2 d type')
else
  xlimits=cls.limits(1:2);
  ylimits=cls.limits(3:4);
  [y,x]=size(cls.dat);
  xvec=linspace(xlimits(1),xlimits(2),x);
  yvec=linspace(ylimits(1),ylimits(2),y);
end    