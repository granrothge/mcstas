function [out]=peakstats(cls)
%function [out]=peakstats(cls)
if (strcmp(cls.type,'1d'))
    xlimits=cls.limits;
    xdat=linspace(xlimits(1),xlimits(2),length(cls.dat)); 
    indat=cls.dat;
    indat=indat(:);
    xdat=xdat(:);
out.area=sum(indat);
out.mean=sum(indat.*xdat)/sum(indat);
out.chsq=sum(indat.*(xdat-out.mean).^2)/sum(indat);
maxval=max(indat);
out.peak=maxval;

    
    
else
   error('needs to be the 1d version of type mcstasclass4');
end    