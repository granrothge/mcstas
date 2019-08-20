function clsout=nperx(cls)
%function that determines the number of counts per unit along the x axis of
%a 1D mcstasclass file
% GEG 10.23.01
% SNS
if ~strcmp(cls.type,'1d')
   error('data must be of 1d type')
else
  xlimits=cls.limits;
  xdat=linspace(xlimits(1),xlimits(2),length(cls.dat));
  clsout=cls; 
  xstep=xdat(2)-xdat(1);
  %scale counts
  clsout.dat=clsout.dat./xstep;
  %scale dcounts
  clsout.err=clsout.err./xstep;
  clsout.ylabel=strcat('n/',clsout.xlabel);
  clsout=mcstasclass4(clsout);
end  