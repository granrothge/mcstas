function [clsout]=conminus(cls,c,axis)
%[clsout]=conminus(cls,c,axis)
% subtract a constant from the x of y value of a mcstasclass 1d object
%GEG 8 28 2003
%TODO
% error checking
clsout=cls;
xlimits=cls.limits(1:2);
if ~strcmp(cls.type,'1d')
    ylimits=cls.limits(3:4);
end    
if(~strcmp(axis,'x')&~strcmp(axis,'y')&~strcmp(axis,'z'))
   error('axis value must be x,y, or z');
end
if strcmp(axis,'x')
    clsout.limits(1:2)=xlimits-c;
else
    if strcmp(cls.type,'2d')
        if strcmp(axis,'y')
             clsout.limits(3:4)=ylimits-c;
        else
           clsout.dat=clsout.dat-c;    
        end
    else
        clsout.dat=clsout.dat-c;
    end
end

