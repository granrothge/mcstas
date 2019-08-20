function [clsout]=contimes(cls,c,axis)
%[clsout]=contimes(cls,c,axis)
if ~strcmp(cls.type,'1d')
   error('data must be of 1d type')
elseif(~strcmp(axis,'x')&~strcmp(axis,'y'))
   disp('axis value must be x or y')
else
 clsout=cls;
 if strcmp(axis,'x')
     clsout.limits=clsout.limits.*c;
 else
     disp('use times')
 end
end 
