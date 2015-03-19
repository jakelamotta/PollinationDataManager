classdef OlfactoryDataAdapter < DataAdapter
%Class that works as an adapter between the raw Olfactory data and the
%Observation object. The data must be a csv or excel file.
    
    properties
        initMatrix;
    end
    
    methods (Access = public)
        
        function this = OlfactoryDataAdapter()
            this.dobj = Observation();
            this.initMatrix = {'/OlfX','/OlfY'};
            this.tempMatrix = this.initMatrix;
        end
        
        function this = addValues(this,p)
            this.tempMatrix = addValues@DataAdapter(this,p,this.tempMatrix);
        end
        
        %%Function for retrieving a Observation object with
        %%Spectrophotometer data
        %%Input - Cell of paths
        %%Output - Observation object
        function obj = getObservation(this,paths)
            tic;
            size_ = length(paths);
            
            this.nrOfPaths = size_;
            
            for i=1:size_
                this.updateProgress(i);
                id_ = DataAdapter.getIdFromPath(paths{1,i});

                rawData = this.fileReader(paths{1,i});
                
                if iscell(rawData)
                    x = transpose(cellfun(@str2double,rawData(:,1)));
                    y = transpose(cell2mat(rawData(:,2)));
                else
                    x = transpose(rawData(:,1));
                    y = transpose(rawData(:,2));
                end
                
                this.tempMatrix{2,1} = x;
                this.tempMatrix{2,2} = y;
                
                this.addValues(paths{1,i});
                this.dobj.setObservation(this.tempMatrix,id_);
                this.tempMatrix = this.initMatrix;
            end
            
            close(this.mWaitbar);
            obj = this.dobj;
            toc            
        end
        
        %%
        function rawData = fileReader(this,p)
            %Assuming csvread but in case file format is not compatible, a
            %few other reading methods are tried
            try
                rawData = csvread(p,3,0);
            catch e
                disp('Could not perform csvread trying other...');
                try
                    rawData = dlmread(p);
                catch e2
                    try
                        [uu1,uu2,rawData] = xlsread(p);
                    catch e3
                        errordlg('File could not be read!','Incorrect fileformat');
                    end
                end
            end
        end
    end
end

