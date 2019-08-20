function errorbar(cls,symbol)
%updated for mcstas 1.6
%GEG 1.15.2002
if ~strcmp(cls.type,'1d')
   disp('data must be of 1d type')
else
    if nargin==1
        symbol='bo';
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
    errorbar(xdat,cls.dat,cls.err,cls.err,symbol);
    cls.xlabel=strrep(cls.xlabel,'\gm','\mu');
    cls.ylabel=strrep(cls.ylabel,'\gm','\mu');
    jk=double(cls.xlabel);
    jkidx=find(jk>13);
    cls.xlabel=char(jk(jkidx));    
    xlabel(cls.xlabel);
    jk=double(cls.ylabel);
    jkidx=find(jk>13);
    cls.ylabel=char(jk(jkidx));
    ylabel(cls.ylabel);
    title(cls.title,'Interpreter','none');
end    