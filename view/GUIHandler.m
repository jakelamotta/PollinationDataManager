classdef GUIHandler < handle
    %GUIHANDLER Class for handling the GUI. It is responsible for
    %communicating with the underlying data handling via the DataManager
    %class. It also makes sure that the correct gui file is launched at
    %when needed.
    
    properties (Access = private)
        dataManager;
        inputManager;
        organizer;
        displayData;
        showOlf;
        
        %%GUI elements
        mainWindow;
        menuBar;
        loadBtn;
        importBtn;
        manageMenuItem;
        exportBtn;
        file_;
        clear_;
        exit_;
        output;
        dataTable;
        mergeBtn;
        scrsz
        tableSize;
        sortDateBtn;
        sortIdBtn;
        metadata;
        idText;
        varText;
        settings;
        toggleOlf;
        helpBtn;
        helpTextImport;
        helpTextLoad;
        helpTextExport;
    end
    
    methods (Access = public)
        
        %%Constructor, program starts here!
        function this = GUIHandler()
            this.scrsz = get(0,'ScreenSize');
            sz = this.scrsz;
            
            this.tableSize = [sz(3)/16.4000 sz(4)/12.0 sz(3)/1.8588 sz(4)/2.6091];
            
            load('config.mat');
            
            if isfield(config,'dispOlf')
                this.showOlf = config.dispOlf;
            else
                this.showOlf = false;
            end
            
            this.inputManager = InputManager();
            this.dataManager = DataManager(this.inputManager,this);
            this.inputManager.setDataManager(this.dataManager);
            this.organizer = Organizer();
            this.initGUI();
            
            %Call this to display the column names at startup
            this.clearCallback();
        end
        
        %%Launch image cropping view. output is a list of the cropped
        %%images and which of them to keep
        function [croppedImage,keep] = getCroppedImage(this,image_,p)
            keep = true;
            croppedImage = imageCrop(image_,p);
            if ischar(croppedImage)
                keep = false;
            end
        end
        
        function manager = getDataManager(this)
            manager = this.dataManager;
        end
        
        %%Callback functin called when the user presses the "Clear data"
        %%option in the file menu
        function this = clearCallback(this,varargin)
            this.dataManager = this.dataManager.clearAll();
            this = this.notifyChange();
        end
    end
    
    methods (Access = private)
        
        %%Function that sets upp all the gui elements in the main window.
        %%Each position is relative to the screensize to make the application more flexible.
        function this = initGUI(this)
            %Define sz to be used for sizing the main window
            sz = this.scrsz;
            
            %Determine whether or not to check the option to show Olfactory
            %data
            if this.showOlf
                checked = 'on';
            else
                checked = 'off';
            end
            
            %Intialize the main window
            this.mainWindow = figure('Name','PDManager','DockControls',...
                'off','NumberTitle','off','Position',[sz(3)/8 sz(4)/8 sz(3)/1.5 sz(4)/1.5],...
                'MenuBar','None','ToolBar','None');
            
            %Assign function called when main window is closed
            set(this.mainWindow,'CloseRequestFcn',@this.onClose);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%BUTTON INITIALIZATION%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            this.importBtn = uicontrol('parent', this.mainWindow, 'style',...
                'pushbutton','units', 'normalized','position',...
                [0.14 0.8 0.1 0.1], 'string', 'Import data', 'fontunits',...
                'normalized', 'fontsize', 0.2, 'Callback',@this.loadCallback);
            
            this.loadBtn = uicontrol('parent', this.mainWindow, 'style',...
                'pushbutton', 'units', 'normalized', 'position', [0.26 0.8 0.1 0.1],...
                'string', 'Load data', 'fontunits', 'normalized',...
                'fontsize', 0.2,'Callback',@this.importCallback);
            
            this.exportBtn =  uicontrol('parent', this.mainWindow,...
                'style', 'pushbutton', 'units', 'normalized',...
                'position', [0.38 0.8 0.1 0.1], 'string', 'Export',...
                'fontunits', 'normalized', 'fontsize', 0.2,'Callback',@this.exportCallback);
            
            this.sortDateBtn = uicontrol('parent', this.mainWindow,...
                'style', 'pushbutton', 'units', 'normalized',...
                'position', [0.93 0.64 0.06 0.05], 'string', 'Sort by date',...
                'fontunits', 'normalized', 'fontsize', 0.3,'Callback',@this.mergeCallback);
            
            this.sortIdBtn = uicontrol('parent', this.mainWindow,...
                'style', 'pushbutton', 'units', 'normalized',...
                'position', [0.93 0.58 0.06 0.05], 'string', 'Sort by id',...
                'fontunits', 'normalized', 'fontsize', 0.3,'Callback',@this.sortIdCallback);
            
            this.helpBtn = uicontrol('parent',this.mainWindow,'style','pushbutton',...
                'string','Help','units','normalized','position',[.95 .95 .04 .04],...
                'Callback',@this.helpCallback);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%TEXTFIELD INITIALIZATION%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            this.idText = uicontrol('parent',this.mainWindow,'style','text',...
                'units', 'normalized','Position',[0.005 0.5 0.08 .04],'String','-');
            
            this.varText = uicontrol('parent',this.mainWindow,'style','text',...
                'units', 'normalized','String','-','Position',[0.45 .7 .1 .02]);
            
            this.helpTextImport = uicontrol('parent',this.mainWindow,'style','text',...
                'units', 'normalized','visible','off','Position',[0.14 .92 .1 .075],'String',...
                'Button for organizing raw data into a folder structure, it does not import anything into the program');
            
            this.helpTextLoad = uicontrol('parent',this.mainWindow,'style','text',...
                'units', 'normalized','visible','off','Position',[0.26 .92 .1 .075],...
                'String','Button for loading data into the program');
            
            this.helpTextExport = uicontrol('parent',this.mainWindow,'style','text',...
                'units', 'normalized',...
                'String','B','visible','off',...
                'Position',[0.38 .92 .1 .1]);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%TABLE INITIALIZATION%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            this.dataTable = uitable(this.mainWindow,'Position',this.tableSize,...
                'units','normalized','CellSelectionCallback',@this.tableCallback);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%MENU INITIALIZATION%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%FILE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            this.file_ = uimenu(this.mainWindow,'Label','File');
            this.clear_ = uimenu(this.file_,'Label','Clear data','Callback',@this.clearCallback);
            this.metadata = uimenu(this.file_,'Label','Export metadata','Callback',@this.metadataCallback);
            this.manageMenuItem = uimenu(this.file_,'Label','Add comment','Callback',@this.manageCallback );
            this.exit_ = uimenu(this.file_,'Label','Exit','Callback',@this.exitCallback);
            
            %%%%%%%%%%%%%%%%%%%%%%SETTINGS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            this.settings = uimenu(this.mainWindow,'Label', 'Settings');
            this.toggleOlf = uimenu(this.settings,'Label','Display Olfactory data','Checked',checked,...
                'Callback',@this.toggleOlfactory);
        end
        
        %%Call this whenever the underlying data is changed so that the change is also
        %%propagates into the GUI
        function this = notifyChange(this)
            obj = this.dataManager.getObservation();
            
            %600 is an arbitrary number and will show a few of the olfactory
            %columns. The point is to reduce the amount of cells in the
            %table though.
            if (obj.getWidth() > 600) && ~this.showOlf
                this.displayData = obj.getSection(1,obj.getNumRows,1,600);
            else
                this.displayData = obj.getMatrix();
            end
            
            set(this.dataTable,'Data',this.displayData);
            drawnow();
        end
        
        %%Last function to be called on program exit
        function this = onClose(this,varargin)
            if ~exist('config','var')
                load('config.mat');
            end
            
            config.dispOlf = this.showOlf;
            save('config.mat','config');
            
            delete(this.mainWindow);
        end
        
        %%Function that uses the InputManager and DataManager to load new
        %%data into the system
        function this = loadNewData(this, path_,dataType)
            this.inputManager = this.inputManager.splitPaths(path_,dataType);
            paths_ = this.inputManager.getPaths();
            cancelled = false;
            
            if isempty(paths_)
                errordlg(['There are no ', dataType,...
                    ' data files in the specified folder, please try again.'],'No such file')
            end
            
            if strcmp(dataType,'Abiotic')
                paths_ = fileChoice(paths_);
                if ischar(paths_)
                    cancelled = true;
                end                
            end
            
            if ~cancelled
                observation = this.dataManager.getObs(dataType,paths_);
                if observation.getNumRows > 1
                    if observation.hasMultiples() || strcmp(dataType,'Spectro')...
                            || strcmp(dataType,'Olfactory') || strcmp(dataType,'SpectroJaz')

                        this.launchDialogue(dataType,observation);
                    else
                        this.dataManager.finalize(dataType,observation);
                    end
                else
                    if strcmp(dataType,'Weather')
                        errordlg(['No ',dataType,' data was found'],['Error']);
                    end
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%CALLBACK FUNCTIONS%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%Callback function called when the user presses the import data
        %%button
        function this = loadCallback(this,varargin)
            this.organizer.launchGUI();
            this.inputManager.organize(this.organizer.sources,this.organizer.target);
        end
        
        %%Callback function called when the user presses the "Export"
        %%button
        function this = exportCallback(this,varargin)
            fp = exportWindow();
            
            if ~strcmp(fp(6:end),' -') && ~isnumeric(fp)
                if this.dataManager.store(fp)
                    this.dataTable = uitable(this.mainWindow,'Position',this.tableSize);
                    this.dataManager = this.dataManager.clearAll();%clearObj();
                else
                    errordlg('Exporting could not be performed, please try again','Error!');
                end
            end
        end
        
        %%Callback function called when the user presses the "Manage data"
        %%button
        function this = manageCallback(this, varargin)
            userdata = manageData(this.dataManager.getObservation());
            
            if ~strcmp('',userdata)
                this.dataManager = this.dataManager.addComment(userdata.row,userdata.comment);
            end
            
            this.notifyChange();
        end
        
        %%Callback functin called when the user presses the "Load data"
        %%button
        function this = importCallback(this,varargin)
            %Get the info regarding what types of data to import from the
            %userdialogue
            importInfo = importWindow();
            
            if iscell(importInfo) && ~isnumeric(importInfo{1,2})
                dataTypes = importInfo{1,1};
                startSearchPath = importInfo{1,2};
                
                for index=1:length(dataTypes)
                    dataType = dataTypes{index};
                    
                    if strcmp(dataType,'load')
                        [fname,pname,uu] = uigetfile('*.*');
                        this.dataManager.importOldData([pname,fname]);
                    else
                        this.loadNewData(startSearchPath,dataType);
                    end
                end
                this.notifyChange();
            end
        end
        
        %%Callback functin called when the user presses the "Sort by date"
        %%button
        function this = mergeCallback(this,varargin)
            this.dataManager.getObservation().sortByDate();
            this = this.notifyChange();
        end
        
        %%Callback functin called when the user presses the "Sort by id"
        %%button
        function this = sortIdCallback(this,varargin)
            this.dataManager.getObservation().sortById();
            this = this.notifyChange();
        end
        
        %%Callback for the "Export metadata" menu item. Starts writing the
        %%metadata to a word document.
        function this = metadataCallback(this,varargin)
            this.inputManager.writeMetaDatatoFile();
        end
        
        %%Callback for cell selection in the uitable. Displays selected row
        %%and column to the user.
        function this = tableCallback(this,varargin)
            index = varargin{2};
            try
                id = this.dataManager.getObservation().get(index.Indices(1),2);
                variable = this.dataManager.getObservation().get(1,index.Indices(2));
                set(this.idText,'String',id);
                set(this.varText,'String',variable);
                this.notifyChange();
            catch e
                set(this.idText,'String','No row selected');
                set(this.varText,'String','No column selected');
                this.notifyChange();
            end
        end
        
        %%Turns "show Olfactory" on and off.
        function this = toggleOlfactory(this,varargin)
            if strcmp(get(this.toggleOlf,'Checked'),'on')
                set(this.toggleOlf,'Checked','off');
                this.showOlf = false;
            else
                set(this.toggleOlf,'Checked','on');
                this.showOlf = true;
            end
            
            this.notifyChange(); %Update GUI
        end
        
        %%Function that provides the user with information about the user
        %%controls available.
        function this = helpCallback(this,varargin)
            if strcmp(get(this.helpBtn,'String'),'Help')
                set(this.helpTextImport,'visible','on');
                set(this.helpTextLoad,'visible','on');
                set(this.helpTextExport,'visible','on');
                set(this.helpBtn,'String','Hide help');
            else
                set(this.helpTextImport,'visible','off');
                set(this.helpTextLoad,'visible','off');
                set(this.helpTextExport,'visible','off');
                set(this.helpBtn,'String','Help');
            end
        end
        
        %%Called when "Exit" in file-menu is pressed
        function this = exitCallback(this,varargin)
            close(this.mainWindow);
        end
        
        %%Launches the select data dialogue
        function this = launchDialogue(this,id,obj)
            out_ = selectData(obj,id,this);
            this = out_.handler;
            this.getDataManager().finalize(id,obj,out_.interp);
        end
    end
end