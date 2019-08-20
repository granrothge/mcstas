function [clsout]=chopx(cls,xlow,xhigh)
%function to reduce the range of a 1d class file
%GEG 8.22.2001
%modified for mcstasclass2
%GEG 10.30.2001
if ~strcmp(cls.type,'1d')
    error ('needs to be the 1d version of type mcstasclass');
end    
    clsout=cls;
    xlimits=cls.limits;
    xdat=linspace(xlimits(1),xlimits(2),length(cls.dat));
   idxlow=min(find(xdat>=xlow));
   idxhigh=max(find(xdat<=xhigh));
   clsout.dat=cls.dat(idxlow:idxhigh,:);
   clsout.err=cls.err(idxlow:idxhigh,:);
   clsout.limits=[xdat(idxlow) xdat(idxhigh)];
  