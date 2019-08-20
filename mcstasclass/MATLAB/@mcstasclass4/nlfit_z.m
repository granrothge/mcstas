function [pa,dpa,chisqN,CN,PQ,nit,kvg,details]=nlfit_z(cls,z,func,pa,ia,nitmax,tol,udiff,dtol)
if (isa(cls,'mcstasclass4')&strcmp(cls.type,'1d'))
    xlimits=cls.limits;
    xdat=linspace(xlimits(1),xlimits(2),length(cls.dat));
   x=xdat;y=cls.dat;s=cls.err;
   idx=find(y>max(y)/z);
   yfit=y(idx);xfit=x(idx);sfit=s(idx);
   if (nargin < 5 | isempty(ia)),ia=ones(1,length(pa)); end %default is to vary everything 
   if (nargin < 6 | isempty(nitmax)), nitmax=20; end %default limit on iterations 
   if (nargin < 7 | isempty(tol)),tol=0.001;,end %default tolerance determining convergence 
   if (nargin < 8 | isempty(udiff)),udiff=0;end %default is numerical derivatives 
   if (nargin < 9 | isempty(dtol)), dtol=1e-5;,end %default derivative tolerance 
   [pa,dpa,chisqN,CN,PQ,nit,kvg,details]=nlfit(xfit,yfit,sfit,func,pa,ia,nitmax,tol,udiff,dtol);
else
   Error('needs to be the 1d version of type mcstasclass');
end   