% function for initial try at a mcstas 2d class for creating a class structure
% to work with mcstas data
% GEG 12.28.2000
% updated for mcstas 1.6
% GEG 1.15.2002
% updated for 3d type
% GEG 8.29.2003
function cls=mcstasclass4(a)
if nargin==0
    cls.xlabel='';
    cls.ylabel='';
    cls.zlabel='';
    cls.title='';
    cls.type='';
    cls.dat=[];
    cls.err=[];
    cls.limits=[];
    cls.bins=[];
elseif isa(a,'mcstasclass4')
    cls=a;
else    
  cls.xlabel=a.xlabel;
  cls.ylabel=a.ylabel;
  cls.zlabel=a.zlabel;
  cls.title=a.title;
  cls.type=a.type;
  cls.dat=a.dat;
  cls.err=a.err;
  cls.limits=a.limits;
  cls.bins=a.bins;
  cls=class(cls,'mcstasclass4');
end  