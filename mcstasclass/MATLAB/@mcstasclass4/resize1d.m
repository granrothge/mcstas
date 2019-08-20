function clsout=resize1d(cls,dim,limits)
% function that resizes along a dimension dim within
% limits limits
% clsout=resize1d(cls,dim,limits)
% GEG 7.12.2007
if dim>length(size(cls))
    error('dim exceeds data dimension');
end
clsout=cls;
lims=(cls.limits((dim*2-1):(dim*2)));
lens=cls.bins(dim);
xdat=linspace(lims(1),lims(2),lens);
xidx=find(xdat>limits(1)&xdat<limits(2));
clsout.limits(dim*2-1)=min(xdat(xidx));
clsout.limits(dim*2)=max(xdat(xidx));
clsout.bins(dim)=length(xidx);
datidx={':',':',':'};
datidx{dim}=strcat('[',num2str(xidx),']');
clsout.dat=eval(strcat('cls.dat(',datidx{1},',',datidx{2},',',datidx{3},')'));
clsout.err=eval(strcat('cls.err(',datidx{1},',',datidx{2},',',datidx{3},')'));
clsout=mcstasclass4(clsout);