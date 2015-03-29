classdef SpectroJazDataAdapter < DataAdapter
    %SPECTROJAZADAPTER Summary of this class goes here
    %Detailed explanation goes here
    
    properties
        init;
    end
    
    methods (Access = public)
        
        function this = SpectroJazDataAdapter()
            
            this.init = {'lux_flower','lux_up','/SpectroX','/SpectroY','/SpectroXUp','/SpectroYUp'};
            this.tempMatrix = this.init;
        end
        
        function matrix = addValues(this,path)
            matrix = addValues@DataAdapter(this,path,this.tempMatrix);
        end
        
        function rawData = fileReader(this,path,type)
            if strcmp(type,'lux')
                rawData = fileReader@DataAdapter(this,path);
                rawData = rawData{1};
            else
                try
                    rawData = importdata(path);
                    rawData = rawData.data;
                catch e
                    errordlg('File could not be read!','Incorrect fileformat');
                end
            end
        end
        
        function obs = getObservation(this,paths)
            
            len = length(paths);
            this.nrOfPaths = len;
            obs = Observation();
            id_ = '';
            
            for i=1:len
                this.updateProgress(i);
                path_ = paths{i};
                
                parts = regexp(path_,'\', 'split');
                fname = parts{end};
                prefix = fname(1);
                
                try
                    if ~strcmp(id_,DataAdapter.getIdFromPath(path_))
                        id_ = DataAdapter.getIdFromPath(path_);
                    end
                catch e
                    errordlg(['Incorrect path was passed to the file reader. Matlab error: ',e.message]);
                end
                
                switch (prefix)
                    case 'F'
                        %Needs to be called with filetype so that the file reader know
                        %how to read it
                        rawData = this.fileReader(path_,'');

                        this.tempMatrix{2,3} = rawData(:,1);
                        this.tempMatrix{2,4} = rawData(:,4);
                    case 'U'
                        %Needs to be called with filetype so that the file reader know
                        %how to read it
                        rawData = this.fileReader(path_,'');

                        w = rawData(:,1);
                        s = rawData(:,4);
                        this.tempMatrix{2,5} = w;
                        this.tempMatrix{2,6} = s;
                    case 'l'
                        rawData = this.fileReader(path_,'lux');
                        luxValues = regexp(rawData,'-','split');
                        %luxValues = luxValues{1};
                        this.tempMatrix{2,1} = str2double(luxValues{1});
                        this.tempMatrix{2,2} = str2double(luxValues{2});
                end
                
                if i == length(paths)
                    this.tempMatrix = this.addValues(path_);
                    obs.setObservation(this.tempMatrix,id_);
                    this.tempMatrix = this.init;
                else
                    if ~strcmp(id_,DataAdapter.getIdFromPath(paths{i+1}))
                        this.tempMatrix = this.addValues(path_);
                        obs.setObservation(this.tempMatrix,id_);
                        this.tempMatrix = this.init;
                    end
                end
            end
            
            close(this.mWaitbar);
        end
        
    end
    
end

