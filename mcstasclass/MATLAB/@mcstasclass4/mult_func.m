function [clsout]=mult_func(cls,func,p)
if ~strcmp(cls.type,'1d')
    error('must be of type 1d');
end
xlimits=cls.limits;
xdat=linspace(xlimits(1),xlimits(2),length(cls.dat)); 
indat=cls.dat;
indat=indat(:);
xdat=xdat(:);
fmult=feval(func,xdat,p);
clsout=cls;
clsout.dat=indat.*fmult;
clsout.err=clsout.err.*fmult';
clsout=mcstasclass4(clsout);
