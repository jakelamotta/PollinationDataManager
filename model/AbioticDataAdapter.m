classdef AbioticDataAdapter < DataAdapter
    %ABIOTICDATAADAPTER Class that adapts raw Abiotic data to a generic
    %%%observation object.
    %%%Accepeted file type is:
    %%% - txt-file
    %%%
    %%%Format for one row needs to be (for example):
    %%%2014-09-19_16_22_39	;	437,17;ppm	;	26,41;°C	;	39,29;%
    
    properties
        initMatrix
    end
    
    methods (Access = public)
        
        function this = AbioticDataAdapter()
            this.dobj = Observation();
            this.initMatrix = {'/AbioTime','Ab_CO2','Ab_temp','Ab_humid'};
            this.tempMatrix = this.initMatrix;
        end
        
        function this = addValues(this,p)
            this.tempMatrix = addValues@DataAdapter(this,p,this.tempMatrix);
        end
         
        %%Function that takes a list of file paths and retrieve a data
        %%object with data from these files
        function obj = getObservation(this,paths)
            len = length(paths);
            
            this.nrOfPaths = len;
            
            %For
            for i=1:len
                this.updateProgress(i); %Updates the waitbar
                
                path_ = paths{1,i};
                
                id_ = DataAdapter.getIdFromPath(path_);%Retrieves observation id from path         
                
                rawData = this.fileReader(path_); %Retrieve raw data from the file
                
                temp = cellfun(@this.createObs,rawData,'UniformOutput',false);
                
                for k=1:length(temp)
                   [h,w] = size(temp{1,k});
                   
                   %Only perform row operations if the length is 4, the
                   %last line of the file will sometimes be an empty line
                   %which otherwise will make the program to crash
                   if w == 4
                       row = temp{1,k};
                       
                       %The dash at the end is added to let excel know it
                       %should be treated as a string. the rest are removed
                       %for functional purposes
                       row{1} = [strrep(strrep(row{1},'-',''),'_',''),'_'];
                       this.tempMatrix = [this.tempMatrix;row];
                   end
                end
                
                this = this.addValues(path_);
                this.dobj = this.dobj.setObservation(this.tempMatrix,id_);                    
                this.tempMatrix = this.initMatrix;
            end
            close(this.mWaitbar);
            obj = this.dobj;
        end
        
        %%For each cell element, parse data
        function temp = createObs(this, inRow)
            %Split around " ; ".
            row = regexp(inRow,[char(9),';',char(9)],'split');            
            temp = cellfun(@AbioticDataAdapter.handleRow,row,'UniformOutput',false);
        end
        
        %%Filereader that uses the parent class filereader, for debugging
        %%this look in DataAdapter class
        function rawData = fileReader(this, path)
            rawData = fileReader@DataAdapter(this,path);
        end        
    end
    
    methods (Static)
        function elem = handleRow(elem)
            idx = strfind(elem,';');
            
            if ~isempty(idx)
                temp = elem(1:idx-1);
                temp = strrep(temp,',','.');
                elem = str2double(temp);
            end
        end
    end
end

