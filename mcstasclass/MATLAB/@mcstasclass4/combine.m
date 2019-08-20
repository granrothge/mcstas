function clsout=combine(binwidth,varargin)
%function clsout=combine(binwidth,cls1,cls2,cls3...clsn)
% function to combine mcstas class files
% only works for files that are in n/x format
% GEG 11.1.01


x=[];y=[];e=[];
for i=1:length(varargin)

   if ~isa(varargin{i},'mcstasclass4')
      error('Append error: all objects must be of type mcstasclass4')      
   end
   if ~strcmp(varargin{i}.type,'1d')
       error('must be of type 1d');
   end
   xlimits=varargin{i}.limits;
   x=[x; linspace(xlimits(1),xlimits(2),length(varargin{i}.dat))]; 
   y=[y; varargin{i}.dat];
   e=[e; varargin{i}.err];
end
   [x,st]=sort(x);
    y=y(st);
    e=e(st);
    xcombi=[];   % will store data to be combined
    ycombi=[];
    ecombi=[];
    xres=[];
    yres=[];
    eres=[];
    clsout=varargin{1};
for i=1:length(x);
      if isempty(xcombi)
        xcombi=[x(i)];
        ycombi=[y(i)];
        ecombi=[e(i)];
      elseif (x(i)-xcombi(1)>binwidth)
         xres=[xres;sum(xcombi)/length(xcombi)];
         yres=[yres;sum(ycombi./(ecombi.^2))/sum(1./(ecombi.^2))];
         eres=[eres;sqrt(1/sum(1./(ecombi.^2)))];
         xcombi=[x(i)];
         ycombi=[y(i)];
         ecombi=[e(i)];
      else
         xcombi=[xcombi;x(i)];
         ycombi=[ycombi;y(i)];
         ecombi=[ecombi;e(i)];
     end
 end
    if ~isempty(xcombi)
         xres=[xres;sum(xcombi)/length(xcombi)];
         yres=[yres;sum(ycombi.*ecombi)/sum(1./(ecombi.^2))];
         eres=[eres;sqrt(1/sum(1./(ecombi.^2)))];
    end
    clsout.dat=yres(:);
    clsout.err=eres(:);
    clsout.limits=[min(xres) max(xres)];
    clsout.title=strcat('combined',num2str(length(varargin))); 
    clsout=mcstasclass4(clsout);