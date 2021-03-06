function plot(cls,varargin)
%updated for Mcstas1.6
%GEG 1.15.2002
%added varargin
%GEG 6.10.2008
if ~strcmp(cls.type,'1d')
   disp('data must be of 1d type')
else
    if nargin==1
        varargin={'b'};
    end 
    xlimits=cls.limits;
    npts=length(cls.dat);
    if ~isempty(findstr('log',cls.xlabel))
        start=(log10(xlimits(2))-log10(xlimits(1)))/(npts*2)+log10(xlimits(1));
        stop=log10(xlimits(2))-(log10(xlimits(2))-log10(xlimits(1)))/(npts*2);
        xdat=logspace(start,stop,npts);
    else
        xdat=linspace(xlimits(1),xlimits(2),length(cls.dat));
    end   
    plot(xdat,cls.dat,varargin{:});
    jk=double(cls.xlabel);
    jkidx=find(jk>13);
    xlabel(char(jk(jkidx)));
    jk=double(cls.ylabel);
    jkidx=find(jk>13);
    ylabel(char(jk(jkidx)));
end    