function diff_plot(cls,func,p,constr)
    if nargin <4
        constr='b';
    end 
    if ~strcmp(cls.type,'1d')
      error('data must be of 1d type')
    end
    xlimits=cls.limits;
    xdat=linspace(xlimits(1),xlimits(2),length(cls.dat));
    yerr_z=zeros(size(xdat));
    ydat=feval(func,xdat,p);
    diff=(cls.dat(:)-ydat(:));
    plot(xdat,diff(:),constr);
    hold on;
    errorbar(xdat,yerr_z,cls.err(:),'c');
    hold off;
    cls.xlabel=strrep(cls.xlabel,'\gm','\mu');
    xlabel(cls.xlabel);
    ylabel('diff');