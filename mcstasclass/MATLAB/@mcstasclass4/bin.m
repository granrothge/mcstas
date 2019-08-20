function clsout=bin(cls,binwidth);

%function to bin a 1d mcstasclass
%SNS
%GEG 10.19.2001

if ~isa(cls,'mcstasclass4')
    error('must be a mcstasclass data type');
elseif ~strcmp(cls.type,'1d')
    errror('must be of a type 1d')
else
    clsout=cls;
    x=cls.mat(:,1);
    y=cls.mat(:,2);
    e=cls.mat(:,3);
    [x,st]=sort(x);
    y=y(st);
    e=e(st);
    xcombi=[];   % will store data to be combined
    ycombi=[];
    ecombi=[];
    xres=[];
    yres=[];
    eres=[];
    for i=1:length(x);
      if isempty(xcombi)
        xcombi=[x(i)];
        ycombi=[y(i)];
        ecombi=[e(i)];
      elseif (x(i)-xcombi(1)>binwidth)
         xres=[xres;sum(xcombi)/length(xcombi)];
         yres=[yres;sum(ycombi)/length(xcombi)];
         eres=[eres;sqrt(sum(ecombi.*ecombi))/length(xcombi)];
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
       yres=[yres;sum(ycombi)/length(xcombi)];
       eres=[eres;sqrt(sum(ecombi.*ecombi))/length(xcombi)];
    end 
    clsout.mat=[xres';yres';eres']';
    clsout.limits=[min(xres) max(xres)];
    clsout.title='binned'; 
    clsout=mcstasclass4(clsout);
end    
   