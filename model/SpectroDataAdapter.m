classdef SpectroDataAdapter < DataAdapter
    %%%Class that works as an adapter between the raw Spectrophotometer data and the
    %%%Observation object. Raw data is accepted in two different format.
    %%%Either in a textfile which is the output of the custom Iphone
    %%%spectrophotometer.
    %%%The other option is a xlsx-file which is more straightforward.
    
    properties
        init;
        obs;
    end
    
    %Public methods, accessible from outside the class aswell.
    methods (Access = public)
        
        function this = SpectroDataAdapter()
            this.init = {'lux_flower','lux_up','/SpectroX','/SpectroY','/SpectroXUp','/SpectroYUp','/SpectroTime'};
            this.tempMatrix = this.init;
            this.obs = Observation();
        end
        
        %%See DataAdapter for implementation
        function rawData = fileReader(this,path)
            rawData = fileReader@DataAdapter(this,path);
        end

        %%Add the values extrapolated from the path to the observation
        function this = addValues(this,idx,path)
            
            matrix = this.tempMatrix;
            [h,w] = size(matrix);
            g = [{'Flower','/Date','Negative','Positive'};cell(h-1,4)];
            
            matrix = [g,matrix];
            
            date_ = path(idx(end-7):idx(end-6));
            
            flower = path(idx(end-6):idx(end-5));
            negOrPos = path(idx(end-5):idx(end-4));
            
            for i=2:h
                matrix{i,1} = flower(2:end-1);
                matrix{i,2} = date_(2:end-1);
                matrix{i,3} = double(strcmp(negOrPos(2:end-1),'negative'));
                matrix{i,4} = double(~strcmp(negOrPos(2:end-1),'negative'));
            end
            
            this.tempMatrix = matrix;
        end
        
        %%Function for retrieving a Observation object with
        %%Spectrophotometer data
        %%Input - Cell of paths
        %%Output - Observation object
        function obj = getObservation(this,paths)
            
            len = length(paths);
            this.nrOfPaths = len;
            
            for i=1:len
                this.updateProgress(i);
                this.getObsFromTxt(paths{1,i});
            end
            
            close(this.mWaitbar);
            obj = this.obs;
        end
    end
    
    %Methods accesible only within the class
    methods (Access = private)
        
        function temp = createDob(this, inRow)
            row = regexp(inRow,':','split');
            
            x = row{1};
            x = x(3:end-1);
            
            y = row{2};
            y = str2double(y(1:end-1));
            temp = {x,y};
        end
        
        %%Function for reading the SpectroPhotometer data from the custom
        %%Iphone device
        function this = getObsFromTxt(this,path_)
            if strcmp(path_(end-10:end),'rawData.txt')
                
                indices = strfind(path_,'\');
                timeStringStart = strfind(path_,'multiple');
                
                if isempty(timeStringStart)
                    timeString = '';
                else
                    timeString = path_(timeStringStart:end);
                    timeStringEnd = strfind(timeString,'\');
                    timeString = timeString(1:timeStringEnd);
                end
                
                try
                    id_ = path_(indices(end-4)+1:indices(end-3)-1);
                catch e
                    errordlg(['Incorrect path was passed to the file reader. Matlab error: ',e.message]);
                end
                
                rawData = this.fileReader(path_);
                
                wli = strfind(rawData,'spectrumPoints');
                wli = wli{1};
                
                this.tempMatrix{2,7} = timeString;
                
                %%Getting spectro data from txtfile, its a mess...
                for obs_=1:length(wli)
                    idx = strfind(rawData,'lux');
                    last = idx{1}(1+2*(obs_-1))-4;
                    
                    luxIndex = idx{1}(2+2*(obs_-1));
                    tempData = rawData{1}(luxIndex:end);
                    
                    idx = strfind(tempData,'}');
                    lastLux = idx(1);
                    
                    luxValue = str2double(tempData(6:lastLux-1));
                    this.tempMatrix{2,obs_} = luxValue;
                    
                    tempData = rawData{1}(wli(obs_):last);
                    
                    idx = strfind(tempData,'spectrumPoints');
                    first = idx+17;
                    
                    points = tempData(first:end);
                    points = regexp(points,',','split');
                    
                    temp = cellfun(@this.createDob,points,'UniformOutput',false);
                    
                    x = zeros(size(temp));
                    y = zeros(size(temp));
                    
                    len_ = length(temp);
                    
                    for k=1:len_
                        x(k) = str2double(temp{k}(1));
                        val1 = temp{k}(2);
                        y(k) = val1{1};
                    end
                    
                    this.tempMatrix{2,2*obs_+1} = x;
                    this.tempMatrix{2,2+2*obs_} = y;
                end
                
                this = this.addValues(indices,path_);
                this.obs.setObservation(this.tempMatrix,id_);
                this.tempMatrix = this.init;
            end
            
        end
        
        %         %%Called when the file is a xlsx-file.
        %         function this = getObsFromJaz(this,path_)
        %
        %             try
        %                 id_ = DataAdapter.getIdFromPath(path_);
        %             catch e
        %                 errordlg(['Incorrect path was passed to the file reader. Matlab error: ',e.message]);
        %             end
        %
        %             path = path_;
        %
        %             %Needs to be called with filetype so that the file reader know
        %             %how to read it
        %             rawData = this.fileReader(path,'jaz');
        %
        %             W = rawData(19:end,1);
        %             S = rawData(19:end,4);
        %
        %             w = cellfun(@str2double,W,'UniformOutput',false);
        %             s = cellfun(@str2double,S,'UniformOutput',false);
        %
        %             this.tempMatrix{2,3} = [w{1:end-1}];
        %             this.tempMatrix{2,4} = [s{1:end-1}];
        %
        %             this = this.addValues(NaN,path_,'jaz');
        %             this.obs.setObservation(this.tempMatrix,id_);
        %             this.tempMatrix = this.init;
        %         end
    end
end