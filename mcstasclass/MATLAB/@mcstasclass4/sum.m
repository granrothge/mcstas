function [out]=sum(varargin)
%[out]=sum(cls,dim)
%GEG 1.16.2001
%fixed to work correctly with 3D files
%GEG 7.11.2007
if nargin<1
    error('needs at least one argument');
end
cls=varargin{1};
if nargin<2
    dim=1;
else
    dim=varargin{2};
end
if dim>3
    error('can not have more than a 3d file');
end
if strcmp(cls.type,'1d')
    cls.dat=cls.dat(:);
    cls.err=cls.err(:);
end
%moved to load routine
%if strcmp(cls.type,'3d')
%    [cls.dat,cls.err]=trid23array(cls);
%end
dat=squeeze(sum(cls.dat,dim));
err=sqrt(squeeze(sum((cls.err.^2),dim)));
if strcmp(cls.type,'1d')
    out.dat=dat;
    out.err=err;
else
    out=cls;
    if strcmp(cls.type,'2d')
        out.type='1d';
    else
        out.type='2d';
    end
    [out.bins]=[];
    [out.bins(2) out.bins(1)]=size(dat);
    out.dat=dat';
    out.err=err';
    out.limits([dim*2-1:dim*2])=[];    
    if dim==1
      out.xlabel=cls.ylabel;
      out.ylabel=cls.zlabel;
    elseif dim ==2
      out.ylabel=cls.zlabel;
    end
    out=mcstasclass4(out);
end



    