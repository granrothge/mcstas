function loglog(cls,symbol)
%updated for Mcstas1.6
%GEG 1.15.2002
if ~strcmp(cls.type,'1d')
   disp('data must be of 1d type')
else
    if nargin==1
        symbol='b';
    end 
    xlimits=cls.limits;
    xdat=linspace(xlimits(1),xlimits(2),length(cls.dat));
    loglog(xdat,cls.dat,symbol);
end    