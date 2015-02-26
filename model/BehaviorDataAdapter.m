classdef BehaviorDataAdapter < DataAdapter
    %ABIOTICDATAADAPTER Class that adapts raw behavior data to a generic
    %%%observation object.
    %%%Accepeted file type is:
    %%% - xlsx-file
    %%%
    %%%Format for one row needs to be (for example):
    %%%2014-09-19_16_22_39	;	437,17;ppm	;	26,41;°C	;	39,29;%
    
    properties
        varMap;
        size_;
        cols;
    end
    
    methods (Access = public)
        
        %%BehaviorDataAdapter constructor. Execution starts here when the
        %%object is initialized.
        function this = BehaviorDataAdapter()            
            global matrixColumns;
            this.cols = matrixColumns(1,25:end);
            this.tempMatrix = this.cols;
            this.dobj = Observation();
            
            global varmap;
            this.varMap = varmap;
            [h,w] = size(this.tempMatrix);
            this.size_ = w;            
        end
        
        %%Read the a excel file and return the ouput
        function rawData = fileReader(this,path)
            try
                [~,~,rawData] = xlsread(path);
            catch
                errordlg('Incorrect path, excel file for behavior data could not be read');
            end
        end
        
        function this = addValues(this,p)
            this.tempMatrix = addValues@DataAdapter(this,p,this.tempMatrix);
        end
        
        %%Function for retrieving a Observation object with
        %%Behavior data
        %%Input - Cell of paths
        %%Output - Observation object
        function obj = getObservation(this,paths)
            [h,w] = size(paths);
            
            this.nrOfPaths = w;
            
            for i=1:w
                this.updateProgress(i);
                if strfind(paths{1,i}(end-3:end),'xls')
                    idx = strfind(paths{1,i},'\');
                    this.tempMatrix = this.tempMatrix(1,:);

                    id_ = DataAdapter.getIdFromPath(paths{1,i});
                    
                    %%If there is no prefilled behavior file the user needs
                    %%to fill it manually.
                    if strfind(paths{1,i}(idx(end):end),'template1.xlsx')
                        %Open the file in execel
                        system(['start ',paths{1,i}]);
                        
                        %Dialog that stops program flow until the user is
                        %done
                        hdg = helpdlg('Please fill in the template, close it and press OK','Information');
                        waitfor(hdg);
                        
                        %Rename template1 and continue execution as normal
                        toRemove = paths{1,i};
                        
                        [pathstr,name,ext] = fileparts(paths{1,i});
                        
                        newFileName = [id_,ext];
                        
                        paths{1,i} = fullfile(pathstr,newFileName);
                        
                        copyfile(toRemove,paths{1,i});
                        delete(toRemove);
                    end

                    path = paths{1,i};
                    
                    disp(paths{1,i});
                    
                    rawData = this.fileReader(path);
                    this = this.parse(rawData);
                    
                this = this.addValues(paths{1,i});
                
                obj = this.dobj.setObservation(this.tempMatrix,id_);
                this.tempMatrix = this.cols;
                end
                
            end
            close(this.mWaitbar);
        end        
    end
    
    methods (Access = private)        
        
        %%Extract the time of the video clip from the behavior file, will
        %%return a list if there are multiple observations in one file. 
        function time = findTotTime(this,rawData)
            totTime = rawData(2:end,15);
            totTime = totTime(~cellfun('isempty',totTime));    
            time = totTime{1};
            
            if ~isnumeric(time)
                time = str2double(time);
            end
            sec = mod(time,1);
            min_ = time-sec;
            sec = sec/.6; 
            time = min_+sec;            
        end
        
        %%Function that parse the data of the behavior file.
        %%Input: Rawdata - data from excel file
        function this = parse(this,rawData)
            nrOfRows = size(rawData);
            
            for i=1:nrOfRows(1)
                if isnan(rawData{i,6})
                    rawData{i,6} = '';
                end
                
                if isnan(rawData{i,15})
                    rawData{i,15} = '';
                end                
            end
            time = this.findTotTime(rawData);
            
            idx = strfind(rawData(:,6),'Behaviour');
            
            for i=1:length(idx)
                if ~isempty(idx{i})
                    idx{i} = i;
                end
            end
            
            idx = idx(~cellfun('isempty',idx));
            
            toAppend = cell(length(idx),this.size_);
            this.tempMatrix = [this.tempMatrix;toAppend];
            
            for i=1:length(idx)
                
                if i == length(idx)
                    obs = [rawData(idx{i}:end,6),rawData(idx{i}:end,8:9)];
                else
                    obs = [rawData(idx{i}:idx{i+1}-1,6),rawData(idx{i}:idx{i+1}-1,8:9)];
                end
                
                obsSize = size(obs);
                
                for k=2:obsSize(1)
                    if ~isempty(obs{k,1})
                        
                        var1 = this.varMap([obs{k,1},'f']);
                        var2 = this.varMap([obs{k,1},'d']);
                        
                        for j=1:this.size_
                            if strcmp(this.tempMatrix{1,j},var1)
                                this.tempMatrix{i+1,j} = obs{k,2}/time;
                            end
                            
                            if strcmp(this.tempMatrix{1,j},var2)
                                this.tempMatrix{i+1,j} = obs{k,3}/time;
                            end
                        end
                    end
                end
            end
        end
    end
end