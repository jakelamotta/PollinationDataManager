classdef InputManager < handle
    %INPUTMANAGER class deals with input and some organzing of data. It
    %creates the correct DataAdapter using the AdapterFactory-class. 
    
    %%Variables used by the InputManager class
    properties (Access = private)
        adapterFactory;
        paths;
        dataManager;
        adapter;
    end
    
    %Methods that are not accessible from outside this class (file)
    methods (Access = private)
        
        %%A recursive folder search function, takes a path to a folder as
        %%an input and search for all occurences of the "type" in the
        %%subfolders
        function this = recSearch(this,path,type)
            if strcmp(type,'Spectro')
                type = 'metadata';
            end
            
            temp = dir(path);
            pathParts = regexp(path,'\','split');
            last = pathParts{end};
            
            [h,w] = size(temp);
            
            for i=3:h
                if strcmp(pathParts{end},type)
                    typeDir = dir(path);
                    numFiles = size(typeDir);                    
                    this.paths{1,end+1} = fullfile(path,'\',typeDir(i).name);
                else
                    this = this.recSearch(fullfile(path,'\',temp(i).name),type);
                end
            end
        end        
        
        %%This is the function that copies files from one location to
        %another location.
        %Input: - sourcePath: the path to what is to be copied as a string
        %       - targetPath: the path to the target folder
        function success = saveToDir(this,sourcePath, targetPath)
            success = true; %Function returns true if the saving was successfull
            
            path_ = Utilities.getpath(targetPath);
            
            if ~exist(path_,'dir')
                [success,uu1,uu2] = mkdir(path_);
            end
            
            if isdir(sourcePath)
                indices = strfind(sourcePath,'\');
                index = indices(end);
                path_ = [path_,'\',sourcePath(index+1:end)];
            end
            
            copyfile(sourcePath,path_);
        end        
    end
    
    %Public methods, accessible from other classes
    methods (Access = public)
        
        %%Default constructor, can take an instance of a DataManager as an argument
        function this = InputManager(varargin)
            this.adapterFactory = AdapterFactory();
            this.paths = {};
                        
            if ~isempty(varargin)
                this.dataManager = varargin{1};
            else
                this.dataManager = NaN;
            end
        end
        
        %%Function that creates a dataadapter and retrieves an object
        %%accordingly. The adapterId is the type of adapter to be created
        function obj = getObservation(this,adapterId,paths,inObj)
            
            %Create the correct adapter given the type of data needed
            this.adapter = this.adapterFactory.createAdapter(adapterId);
            
            %If a string is returned something went wrong
            if ischar(this.adapter)
                errordlg('The data adapter could not be created, the adapterfactory did not return a valid object');
            else
                if strcmp(adapterId,'Weather') || strcmp(adapterId,'Image')
                    obj = this.adapter.getObservation(paths,inObj,this);
                else
                    obj = this.adapter.getObservation(paths);
                end
            end
        end
        
        %%Takes a path as an input and finds all folders of the input type
        %%that are located in a subfolder of the input path
        function this = splitPaths(this,p,type)
            this.paths = {};
            this = this.recSearch(p,type);
        end
        
        %%Function for organizing data into folders
        function success = organize(this,sources,target)
            %Function returns true or false depending on if the operation
            %was successfull or not
            success = true;
            dataTypes = fieldnames(sources);
            
            for i=1:numel(dataTypes)
                dataType = char(dataTypes(i));
                
                noExcelFile = true;
                
                if ~ischar(sources.(dataType))
                    
                    files = fieldnames(sources.(dataType));
                    
                    for j=1:numel(files)
                        file = char(files(j));
                        
                        if strcmp(dataType,'Behavior')
                            behaviorFile = sources.(dataType).(file);
                            if strcmp(behaviorFile(end-3:end),'xlsx')
                                noExcelFile = false;
                            end
                        end
                        
                        success = this.saveToDir(sources.(dataType).(file),[target,dataType]);
                    end
                else
                    success = this.saveToDir(sources.(dataType),[target,dataType]);
                end
                
                if strcmp(dataType,'Behavior') && noExcelFile
                    this.saveToDir(Utilities.getpath('template.xlsx'),[target,dataType]);
                end
            end
        end
        
        %%Function that writes metadata to a word document
        function writeMetaDatatoFile(this)
            node = FolderTree('data');
            path_ = uigetdir(Utilities.getpath(''));
            
            if ischar(path_)
                this.getMetaData(path_,node);
                WriteToWordFromMatlab(Utilities.getpath('metadata.doc'),node);
            end
        end
        
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%GETTERS AND SETTERS%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function this = setDataManager(this,dm)
            this.dataManager = dm;
        end
        
        function dm = getDataManager(this)
            dm = this.dataManager;
        end
        
        function ps = getPaths(this)
            ps = this.paths;
        end
        
        %%Function that recursively builds a FolderTree object collection
        function getMetaData(this,path,tree)
            temp = dir(path);
            [h,w] = size(temp);
            
            for i=3:h
                %%Creates a new FolderTree child with input FolderTree as parent
                child = FolderTree(temp(i).name,tree);
                
                if temp(i).isdir
                    this.getMetaData([path,'\',temp(i).name],child);
                end
            end
        end
    end
end