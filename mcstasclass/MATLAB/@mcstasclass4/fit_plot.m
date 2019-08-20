function fit_plot(cls,func,p,symbol)
% function to plot fit according to x in mcstasclass2 file
if ~strcmp(cls.type,'1d')
    Error('cls must be of type 1d')
end
if nargin==3
        symbol='b';
end 
xlimits=cls.limits;
xdat=linspace(xlimits(1),xlimits(2),length(cls.dat)*2);
ydat=feval(func,xdat,p);
plot(xdat,ydat,symbol);