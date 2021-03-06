function clsout=slice3d22d(cls,dim,range)
% function to cut a 2c slice out of 3d data
%clsout=slice3d22d(cls,dim,range)
%dim is which dimesnion to choose 1..3
%range is the range to integrate the chosen dimension
%GEG 7.12.2007
         if ~strcmp(cls.type,'3d')
             error('error data must be of 3 d type')
         end 
         if dim > 3 
             error('there are no more than 3 dimenions in the data')
         end
         clstmp=resize1d(cls,dim,range);
         clsout=sum(clstmp,dim);