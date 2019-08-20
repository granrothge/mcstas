function  cls=mcstasload4(filename)
%function to load a mcstas file into a mcstasclass4 class
%cls=mcstasload4(filename)
%GEG
%ORNL
%July 11 2007
%added ability to use system file browser
%October 31 2008
dat.type=[];
if nargin <1
   [filename]=uigetfile();
end
fid=fopen(filename,'r');
if (fid<0)
   error('File not found');
end
 lline=fgets(fid);
 while ~isempty(findstr('#',lline))     
     % determine if the file is a 1d file or a 2d file
     if ~isempty(findstr('type',lline))
       [junk1,junk2]=strtok(lline,':');
       if ~isempty(findstr('array_1d',junk2))
           dat.type='1d';
           [junk1,junk2]=strtok(junk2,'(');
           dat.bins=eval(strrep(strrep(junk2,'(','['),')',']'));
       elseif ~isempty(findstr('array_2d',junk2))
           dat.type='2d';
           [junk1,junk2]=strtok(junk2,'(');
           dat.bins=eval(strrep(strrep(junk2,'(','['),')',']'));
       elseif ~isempty(findstr('array_3d',junk2))
           dat.type='3d';
           [junk1,junk2]=strtok(junk2,'(');
           dat.bins=eval(strrep(strrep(junk2,'(','['),')',']'));
       else
         disp('error unsupported mcstas file type')
       end
     end 
     %determine title, x, and y labels
     if ~isempty(findstr('title',lline))
        [junk1,junk2]=strtok(lline,':');
        dat.title=strrep(junk2,':','');    
     end
     if ~isempty(findstr('xlabel',lline))
         [junk1,junk2]=strtok(lline,':');
         dat.xlabel=strrep(junk2,':','');
     end     
     if ~isempty(findstr('ylabel',lline))
         [junk1,junk2]=strtok(lline,':');
         dat.ylabel=strrep(junk2,':','');
     end
     if ~isempty(findstr('zlabel',lline))
         [junk1,junk2]=strtok(lline,':');
         dat.zlabel=strrep(junk2,':','');
     else
         dat.zlabel='None';
     end
     %if ii is a 1d file
     if ~isempty(dat.type)
       if (dat.type=='1d')
           if ~isempty(findstr('xlimits',lline))
             [junk1,junk2]=strtok(lline,':');
             junk2=strrep(junk2,':','');
             dat.limits=sscanf(junk2,'%f');
           end
       end
       if (dat.type=='2d'|dat.type=='3d')
         if ~isempty(findstr('xylimits',lline))
             [junk1,junk2]=strtok(lline,':');
             junk2=strrep(junk2,':','');
             dat.limits=sscanf(junk2,'%f');
         end
       end
     end  
     lline=fgets(fid);  
 end
 idx=0;
 mat=[];
 while (lline>0&isempty(findstr('#',lline)))
    lline=str2num(lline);
    mat=[mat;lline];
    lline=fgets(fid);
    idx=idx+1;
    if rem(idx,50)==0
        idx
    end    
 end
 if (dat.type=='1d')
     dat.dat=mat(:,2);
     dat.err=mat(:,3);    
 end
 if(dat.type=='2d'|dat.type=='3d')
     dat.dat=mat;
     if ~isempty(findstr('#',lline))
         lline=fgets(fid);
         if (dat.type=='2d')
            %lline=fgets(fid);  Old files have extra blank line???
         end   
         idx=0;
         mat=[];
         while (lline>0&isempty(findstr('#',lline)))
            lline=str2num(lline);
            mat=[mat;lline];
            lline=fgets(fid);
            idx=idx+1;
            if rem(idx,50)==0
              idx
            end    
        end
        dat.err=mat;    
    else
     dat.err=[]; 
    end 
 end
 fclose(fid);
 dat.title=filename;
 cls=mcstasclass4(dat);
 if (dat.type=='3d')
     cls=trid23array(cls);
 end
 