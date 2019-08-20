function clsout=times(cls1,cls2)
clsout=cls1;
if (isa(cls1,'mcstasclass4') | isa(cls2,'mcstasclass4'))
    if ~isa(cls1,'mcstasclass4')
             clsout.dat=cls1.*cls2.dat;
             clsout.err=cls1.*cls2.err;
             clsout.xlabel=cls2.xlabel;
             clsout.type=cls2.type;
             clsout.title='multiplied';
             clsout.limits=cls2.limits
             if strcmp(clsout.type,'2d')
                 clsout.ylabel=cls2.ylabel;
             else
                 clsout.ylabel='c*I_2';
             end
     elseif ~isa(cls2,'mcstasclass4')
         
         clsout.dat=cls1.dat.*cls2;
         clsout.err=cls1.err.*cls2;
         clsout.xlabel=cls1.xlabel;
         clsout.type=cls1.type;
         clsout.title='multiplied';
         clsout.limits=cls1.limits
         if strcmp(clsout.type,'2d')
            clsout.ylabel=cls2.ylabel;
         else
            clsout.ylabel='I_1*c';
         end             
     else         
             
         if ~strcmp(cls1.type,cls2.type)
            error('error: both data sets must have the same type');
        end   
         if cls1.limits~=cls2.limits
             error('limits must match')
         end    
         if (size(cls1.dat)~=size(cls2.dat))
            disp('error data sets must be of the same length and x values must match');
         else           
           clsout.dat=cls1.dat.*cls2.dat;
           clsout.err=clsout.dat.*sqrt((cls1.err./cls1.dat).^2+(cls2.err./cls2.dat).^2);
           clsout.xlabel=cls1.xlabel;
           clsout.type=cls1.type;
           if strcmp(clsout.type,'2d')
             clsout.ylabel=cls1.ylabel;
           else
             clsout.ylabel='I_1*I_2';
           end
           clsout.title='multiplied';
           clsout.limits=cls1.limits;       
         end
      end
    clsout=mcstasclass4(clsout);
  end   
end  