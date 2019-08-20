function [clsout]=cut2d21dcls(varargin)
%[clsout]=cut2d21dcls(cls,cutdir,cutcen,cutwidth,xlims)
%function to make a cut out of a 2d mcstasclass3 file and turn it into a 1d mcstasclass3 file
%GEG 1.16.2001
if nargin<4
    error('Must have at least 4 inputs')
else
    cls=varargin{1};
    cutdir=varargin{2};
    cutcen=varargin{3};
    cutwidth=varargin{4};
    if nargin>4
        xlims=varargin{5};
    end
end
if ~strcmp(cls.type,'2d')
    error('error data must be of 2 d type')
end  
    [xvec,yvec]=createxyvec(cls);
    clsout=cls;
    clsout.dat=[];
    clsout.err=[];
    clsout.ylabel='I';
    clsout.type='1d';
  if strcmp(cutdir,'x')
         cutmax=min(find(yvec>cutcen+cutwidth/2));
         cutmin=max(find(yvec<cutcen-cutwidth/2));
         x=xvec;
         if nargin<5
             xidx=[1:length(x)];
         else
             xidx=find(xvec>=xlims(1)&xvec<=xlims(2));
         end
         for idx=1:length(xidx)
           clsout.dat(idx)=sum(cls.dat(cutmin:cutmax,xidx(idx)));
           if ~isempty(cls.err)
             clsout.err(idx)=sqrt(sum((cls.err(cutmin:cutmax,xidx(idx))).^2));
           end  
         end
         clsout.xlabel=cls.xlabel;
         clsout.title=strcat(num2str(cutwidth),' wide cut about',num2str(cutcen),'in',cls.ylabel);
  elseif strcmp(cutdir,'y')
         cutmax=min(find(xvec>cutcen+cutwidth/2));
         cutmin=max(find(xvec<cutcen-cutwidth/2));
         x=yvec;
         if nargin<5
            xidx=[1:length(x)];
         else
            xidx=find(yvec>=xlims(1)&yvec<=xlims(2));
         end
         for idx=1:length(xidx)
           clsout.dat(idx)=sum(cls.dat(xidx(idx),cutmin:cutmax));
           if ~isempty(cls.err)
              clsout.err(idx)=sqrt(sum((cls.err(xidx(idx),cutmin:cutmax)).^2));
           end
         end 
         clsout.xlabel=cls.ylabel;         
         clsout.title=strcat(num2str(cutwidth),' wide cut about',num2str(cutcen),'in',cls.xlabel);         
  else    
    error('cutdir must be either x or y')
  end
 clsout.limits=[min(x(xidx)) max(x(xidx))];
 clsout.bins=length(clsout.dat);
 clsout=mcstasclass4(clsout); 