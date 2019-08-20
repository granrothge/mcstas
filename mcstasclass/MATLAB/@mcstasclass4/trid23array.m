function [clsout]=trid23array(cls);
 if ~strcmp(cls.type,'3d')
     error('function only meaningful for 3d data types');
 end
 clsout=cls;
 for idx=1:cls.bins(3)
     dat(:,:,idx)=cls.dat((idx-1).*cls.bins(2)+([1:cls.bins(2)]),1:cls.bins(1))';
     %dat(:,:,idx)=cls.dat(1:cls.bins(1),(idx-1).*cls.bins(2)+([1:cls.bins(2)]));
     err(:,:,idx)=cls.err((idx-1).*cls.bins(2)+([1:cls.bins(2)]),1:cls.bins(1))';
     %err(:,:,idx)=cls.err(1:cls.bins(1),(idx-1).*cls.bins(2)+([1:cls.bins(2)]));
 end
 clsout.dat=dat;
 clsout.err=err;
 clsout=mcstasclass4(clsout);