classdef XLSWriter
    %XLSWRITER Class responsible for writing dataobjects to a excel-file
    
    properties
    end
    
    %Public methods, accessible from other classes
    methods (Access = public)
        
        %%Function that writes to excel
        function success = writeToXLS(this,fileName,obj)
%             f = strrep(datestr(now),' ','-');
%             f = strrep(f,':','');
            
            %Uncomment this to make the program saving mat-files with
            %aswell as exporting to excel.
            %save([f,'.mat'],'obj');
            
            try
                fullname = [fileName,'.xlsx'];
                xlswrite(fullname,obj.getMatrix());
                success = exist(fullname,'file');                
            catch e
                errordlg(e.getReport(),'Error');
            end
        end
        
        %%Function for merging an observation with an already existing
        %%excel document
        function success = appendXLS(this,fname,obj)
            toSave = obj;
            obj.sortById();
            
            try
                if exist([fname,'.xlsx'],'file');
                    [~,~,old] = xlsread(fname);

                    toAppend = obj.getMatrix();
                    
                    [toAppend,old] = Utilities.padMatrix(toAppend,old);
                    s = size(toAppend);
                    temp = [];

                    for i=2:s(1)
                        temp(end+1) = i;
                    end

                    toAppend = toAppend(temp,:);

                    toSave.setMatrix([old;toAppend]);
                end
            catch e
                errordlg(e.getReport(),'Error!');
            end
            success = this.writeToXLS(fname,toSave);            
        end        
    end    
end