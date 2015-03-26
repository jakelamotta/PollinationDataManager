classdef SpectroJazDataAdapter < DataAdapter
    %SPECTROJAZADAPTER Summary of this class goes here
    %Detailed explanation goes here
    
    properties
        init;
    end
    
    methods (Access = public)
        
        function this = SpectroJazDataAdapter()
           this.init = {'lux_flower','lux_up','SpectroX','SpectroY','SpectroXUp','SpectroYUp'};
           this.tempMatrix = this.init;
        end
        
        function matrix = addValues(this,path)
            matrix = addValues@DataAdapter(this,path,this.tempMatrix);
        end 
        
        function rawData = fileReader(this,path)
            try
                %[a,b,rawData] = xlsread(path);
                rawData = importdata(path);
                rawData = rawData.data;
            catch e
                errordlg('File could not be read!','Incorrect fileformat');
            end
        end
        
        function obs = getObservation(this,paths)
            
            len = length(paths);
            this.nrOfPaths = len;
            obs = Observation();
            
            for i=1:len
                this.updateProgress(i);
                path_ = paths{i};
                
                try
                    id_ = DataAdapter.getIdFromPath(path_);
                catch e
                    errordlg(['Incorrect path was passed to the file reader. Matlab error: ',e.message]);
                end

                path = path_;

                %Needs to be called with filetype so that the file reader know
                %how to read it
                rawData = this.fileReader(path);

                w = rawData(:,1);
                s = rawData(:,4);

                %w = cellfun(@str2double,W,'UniformOutput',false);
                %s = cellfun(@str2double,S,'UniformOutput',false);

                this.tempMatrix{2,1} = w;%%[w{1:end-1}];
                this.tempMatrix{2,2} = s;%%[s{1:end-1}];

                this.tempMatrix = this.addValues(path_);
                obs.setObservation(this.tempMatrix,id_);
                this.tempMatrix = this.init;
            end
            
            close(this.mWaitbar);
        end
        
    end
    
end

