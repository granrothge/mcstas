function [out1,out2,out3,out4,out5,out6,out7,out8,out9]=mcstasclassinfo(a)
%function to print info of mcstasclass structure
%modified for Mcstas1.6
%GEG 1.15.2002
if isa(a,'mcstasclass4')
    disp(a.type);        
    out1=a.type;
    out2=a.xlabel;
    out3=a.ylabel;
    out4=a.zlabel;
    out5=a.bins;
    out6=a.limits;
    out7=a.dat;
    out8=a.err;
    out9=a.title;    
else
   error('a Needs to be of type mcstasclass4');
end   