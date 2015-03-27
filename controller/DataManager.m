classdef DataManager < handle
    %DATAMANAGER A central class that is responsible for talking to most
    %parts of the system. Its the datamanager that is the link between the
    %GUI and all the underlying data handling. It passes any command from
    %the user to the correct class instance s
    
    %%Variables used by the DataManager class
    properties (Access = private)
        xlsWriter; %Writer for exporting
        manager; %InputManager object that is used for loading data
        observation;
        unfilteredObs;
        spectroDP; %Number of data points used for interpolation of Spectro data
        olfactoryDP; %Number of data points used for interpolation of Olfactory data
        spectroJazDP;
        handler; %GUIhandler object
        sizeLimit;        
    end
    
    %Public methods, accessible from other classes
    methods (Access=public)
        
        %%Function for importing an Observation matrix from file. Any
        %%existing data will be deleted.
        function this = importOldData(this,filename)
            [~,~,data] = xlsread(filename);
            this.observation.setMatrix(data);
            this.observation.removeNaN();
        end
        
        %Clean up function to make sure all objects are deleted after
        %exiting the program. This code is automatically called when the
        %object is no longer used (on program exit)
        function delete(this)
            delete@handle(this);
        end
        
        %%Default constructor, takes an instance of an InputManager and a
        %%an GUIHandler object respectively
        function this = DataManager(inM,inH)
            this.sizeLimit = 90000000; %This is a limit on how many elements that can be stored in the 
            %datatable. 
            this.manager = inM;
            this.handler = inH;
            this.xlsWriter = XLSWriter();
            this.unfilteredObs = Observation();
            this.observation = Observation();
            
            %Initializes to 300 and 15000 respectively, once its set after this its final to not
            %create inconcistensies between observations
            this.spectroDP = uint32(Constants.SpectroDP);
            this.spectroJazDP = uint32(Constants.SpectroJazDP);
            this.olfactoryDP = 15000;
        end
        
        %% Clears all data from the session any information that isnt saved to excel is lost
        function this = clearAll(this)
            this = this.setUnfObject(Observation());
            this = this.setObservation(Observation());
        end
        
        %%Adds a newly important Observation to the observation that is
        %%displayed
        function obj = getObs(this,id,path)
            %Get new data from the input manager.
            obj = this.manager.getObservation(id,path,this.getObservation());
        end
        
        %%Remove the HMTL encoding that was used to get differently colored rows in the
        %%intermediate data handling step
        function obj = stripFirstColumn(this,obj)
            
            for i=2:obj.getNumRows()
                tempFlower = obj.get(i,1);
                
                start = strfind(tempFlower,'<TD>');
                end_ = strfind(tempFlower,'</TD>');
                
                if ~isempty(start)
                    newFlower = tempFlower(start+4:end_-1);
                    obj.set(i,1,newFlower);
                end
            end
            
        end
        
        %%
        function this = finalize(this,type_,temp,varargin)
            current = this.getUnfObject();
            
            if ~isempty(varargin)
                interp = varargin{1};
                current.setInterp(type_,interp);
            end
            
            %temp = this.getUnfObject();
            
            tempMat = temp.getMatrix();
            
            rows = [2];
            
            [h_new,w_new] = size(tempMat);
            [h_old,w_old] = size(this.getObservation().getMatrix());
            
            diff = w_old-w_new;
%             
%             if diff > 0
%                 padding = cell(h_new,diff);
%                 tempMat = [tempMat,padding];
%                 
%                 tempMat2 = this.getObservation().getMatrix();
%                 tempMat2 = tempMat2(1,:);
%                 
%                 current.setMatrix(tempMat2);
%             end
            
            newMat = [current.getMatrix();tempMat(2:h_new,:)];
            current = current.setMatrix(newMat);
            
            if (current.getWidth()*current.getNumRows()) > this.sizeLimit
                this.handler.clearCallback();
                throw(MException('DataManager:Finalize','Too many elements in the display table, could not load'));
            end
            
            this = this.setUnfObject(current);            
            obj = current;
            
            obj = this.stripFirstColumn(obj);
            
            %Interpolate and expnd the spectrum points to their own columns
            if strcmp(type_,'Spectro') || strcmp(type_,'SpectroJaz')
                obj.downSample(this.getNrOfSpectroDP(),type_);
                obj.inflateSpectrumPoints(type_);
            end
            
            if strcmp(type_,'Olfactory')
                obj.downSample(this.getNrOfOlfactoryDP(),type_);
                obj.inflateSpectrumPoints(type_);
            end
            
            %Remove the temporary columns for storing the arrays which
            %contains spectro and olfactory data
            obj.removeArrays();
            
            %If there are more than one row of an observation, calc avg.
            if obj.hasMultiples()
                obj.doAverage(8);
                this.setUnfObject(obj);
            end
            
            objID = obj.getObjectID();
            
            numberOfObs = length(objID);
            listOfIds = cell(1,1);
            index = 1;
            
            %%Find out for which IDs in the incoming observation already exist
            %%in the current one.
            for k=1:numberOfObs
                id = objID{1,k};
                
                if ~isempty(this.getObservation().getRowFromID(id))
                    listOfIds{1,index} = id;
                    index = index +1;
                end
            end
            
            %%If there are an observation that already exist, these rows
            %%need to be combined
            if ~isempty(listOfIds{1,1})
                this.getObservation().appendObservation(this.getUnfObject(),type_);
                
                for i=1:length(listOfIds)
                    id = listOfIds{1,i};
                    this.getObservation().combine(id);
                end
            else
                this.merge(type_);
            end
            
            this = this.setUnfObject(Observation());
                        
        end
        
        %%Write the observation cell to excel-file
        function success = store(this,path)
            obj = this.getObservation();
            success = this.xlsWriter.appendXLS(path,obj);
        end
        
        %%Merge to observations that have no common observation ids
        function this = merge(this,type_)
            unfObj = this.getUnfObject();
            fobj = this.getObservation();
            fobj.appendObservation(unfObj,type_);
            this.setObservation(fobj);
        end
        
        %%Adds a comment to the comment column
        function this = addComment(this,row,comment)
            obs = this.getObservation();
            
            for i=2:this.getObservation().getWidth()
                if strcmp(obs.get(1,i),'/Comment') || strcmp(obs.get(1,i),'comment')
                    obs.set(row,i,comment);
                    break;
                end
            end
            
            this.setObservation(obs);
        end
        
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%GETTERS AND SETTERS%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = getObservation(this)
            obj = this.observation;
        end
        
        function this = setObservation(this,obj)
            this.observation = obj;
        end
        
        function this = setUnfObject(this,obj)
            this.unfilteredObs = obj;
        end
        
        function obj = getUnfObject(this)
            obj = this.unfilteredObs;
        end
        
        function handler = getHandler(this)
            handler = this.handler;
        end
        
        function dp = getNrOfSpectroDP(this)
            dp = this.spectroDP;
        end
        
        function dp = getNrOfOlfactoryDP(this)
            dp = this.olfactoryDP;
        end
        
        function dp = getNrOfSpectroJazDP(this)
            dp = this.spectroJazDP;
        end
        
        function this = setNrOfOlfactoryDP(this,dp)
            %The value can only be changed once, from it's original value            
            if ischar(dp)
                dp = str2double(dp);
            end
            
            if this.olfactoryDP == 15000;
                this.olfactoryDP = dp;
            end
        end
        
        function this = setNrOfSpectroJazDP(this,dp)
            %The value can only be changed once, from it's original value            
            if ischar(dp)
                dp = str2double(dp);
            end
            
            if this.spectroJazDP == uint32(Constants.SpectroJazDP);
                this.spectroJazDP = dp;
            end
        end
        
        function this = setNrOfSpectroDP(this,dp)
            if ischar(dp)
                dp = str2double(dp);
            end
            
            if isnumeric(dp) && ~isempty(dp)
                %The value can only be changed once, from it's original value
                if this.spectroDP == uint32(Constants.SpectroDP);
                    this.spectroDP = dp;
                end
            end
        end
    end
end