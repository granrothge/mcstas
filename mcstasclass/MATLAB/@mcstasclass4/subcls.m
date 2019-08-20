function [clsout]=subcls(cls,limits)
%function to extract part of a mcstasclass2 object and make a new mcstasclass2 object
%GEG 1.16.2001
if (strcmp(cls.type,'1d')&length(limits)~=2)
    error('for 1d class one upper and one lower limit must be given')
end
if (strcmp(cls.type,'2d')&length(limits)~=4)
    error('for 2d class an upper and lower limit must be given for each dimension')
end
clsout=cls;
if strcmp(cls.type,'1d')    
  xlimits=cls.limits;
  xdat=linspace(xlimits(1),xlimits(2),length(cls.dat));
  clsout.dat=cls.dat(find (xdat>limits(1)&xdat<limits(2)));
  clsout.err=cls.err(find (xdat>limits(1)&xdat<limits(2)));
  clsout.limits=[min(xdat(find (xdat>limits(1)&xdat<limits(2)))) max(xdat(find (xdat>limits(1)&xdat<limits(2))))];
  clsout.bins=length(cls.dat);
end 
clsout=mcstasclass4(clsout);


