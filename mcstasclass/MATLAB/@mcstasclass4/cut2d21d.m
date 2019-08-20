function [x,y,err]=cut2d21d(cls,cutdir,cutcen,cutwidth)
%function to make a cut out of a 2d mcstasclass file
%GEG 4.2.2001
%updated for mcstas1.6
%GEG 1.15.2001
if ~strcmp(cls.type,'2d')
    disp('error data must be of 2 d type')
else  
    [xvec,yvec]=createxyvec(cls);
    err=[];
  if strcmp(cutdir,'x')
         cutmax=min(find(yvec>cutcen+cutwidth/2));
         cutmin=max(find(yvec<cutcen-cutwidth/2));
         x=xvec;
         for idx=1:length(xvec)
           y(idx)=sum(cls.dat(cutmin:cutmax,idx));
           if ~isempty(cls.err)
             err(idx)=sqrt(sum((cls.err(cutmin:cutmax,idx)).^2));
           end  
         end  
  elseif strcmp(cutdir,'y')
         cutmax=min(find(xvec>cutcen+cutwidth/2));
         cutmin=max(find(xvec<cutcen-cutwidth/2));
         x=yvec;
         for idx=1:length(yvec)
           y(idx)=sum(cls.dat(idx,cutmin:cutmax));
           if ~isempty(cls.err)
              err(idx)=sqrt(sum((cls.err(idx,cutmin:cutmax)).^2));
           end
         end         
  else 
    disp('cutdir must be either x or y')
  end    
end    