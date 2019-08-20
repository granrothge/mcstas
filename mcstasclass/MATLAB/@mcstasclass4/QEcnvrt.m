function [qmat,Emat,Imat]=QEcnvrt(a,L1,E0,lf,phoff)
%function to convert theta vs tof to Etrans vsQ
%GEG 1.5.2001
if isa(a,'mcstasclass4')
    xlimits=a.limits(1:2);
    ylimits=a.limits(3:4);
    [y,x]=size(a.dat);
    xmat=repmat(linspace(xlimits(1),xlimits(2),x),y,1);
    ymat=repmat(linspace(ylimits(1),ylimits(2),y)',1,x);
    v0=sqrt(E0/5.227)*1000; %in m/s
    t1=L1/v0; % in s
    phmat=xmat;
    Efmat=5.227.*(sqrt(lf^2)/1000./(ymat-t1)).^2;
    qmat=sqrt(Efmat./2.072).*sin((phmat+phoff)*pi/180);
    Emat=E0-Efmat;
    Imat=a.dat;
else
  error('must be a mcstasclass4 file');
end  