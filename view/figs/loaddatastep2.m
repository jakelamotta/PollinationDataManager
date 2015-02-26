function varargout = loaddatastep2(varargin)
% LOADDATASTEP2 MATLAB code for loaddatastep2.fig
%      LOADDATASTEP2, by itself, creates a new LOADDATASTEP2 or raises the existing
%      singleton*.
%
%      H = LOADDATASTEP2 returns the handle to a new LOADDATASTEP2 or the handle to
%      the existing singleton*.
%
%      LOADDATASTEP2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOADDATASTEP2.M with the given input arguments.
%
%      LOADDATASTEP2('Property','Value',...) creates a new LOADDATASTEP2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before loaddatastep2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to loaddatastep2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help loaddatastep2

% Last Modified by GUIDE v2.5 24-Feb-2015 15:41:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @loaddatastep2_OpeningFcn, ...
                   'gui_OutputFcn',  @loaddatastep2_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before loaddatastep2 is made visible.
function loaddatastep2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to loaddatastep2 (see VARARGIN)

% Choose default command line output for loaddatastep2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(hObject,'Name','Import data step 2/2');

tempStruct = struct;

if exist('config.mat','file')
    load('config.mat');
    if ~isfield(config,'id')
        config.id = 1;
    end
else
    config = struct;
    config.id = 1;
    save('config.mat','config');
end

if ~isfield(config,'weatherPath')
    inputManager = InputManager();
    startSearch = Utilities.getpath('');
    inputManager.splitPaths(startSearch(1:end-1),'weatherPath');
    path_ = inputManager.getPaths();
    
    if ~isempty(path_)
        
        config.weatherPath = path_;
        set(handles.weatherText,'String',path_);
        source = struct;
        size_ = size(path_);
        
        for i=1:size_(2)
            temp = path_{1,i};
            source.(['path',num2str(i)]) = temp;
        end
        
        tempStruct.Weather = source;
    end
end

strings = varargin{2};
strings = strings{1};

str_ = strings;
idx = strfind(str_,'\');
sub1 = str_(idx(1)+1:idx(1)+3);
sub2 = str_(idx(2)+1:idx(2)+1);
sub3 = str_(1:idx(1)-1);
  
id_ = mod(config.id,999); %Restart at 1

sub4 = num2str(id_);

sub4 = Utilities.padString(sub4,'0',3);

str_ = [sub1,'_',sub2,sub3,'_',sub4];
str_ = strrep(str_,'\','');
    
strings = [strings,str_,'\'];

set(handles.edit1,'String',strings);

tempStruct.targets = strings;
set(handles.output,'UserData',tempStruct);

% UIWAIT makes loaddatastep2 wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = loaddatastep2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;
if get(handles.okBtn,'UserData')    
    data = get(handles.output,'UserData');
    data.targets = get(handles.edit1,'String');
    varargout{1}.target = data.targets;
    data = rmfield(data,'targets');
    varargout{1}.sources = data;
    %varargout{1}.sources = get(handles.output,'UserData');    
else
    varargout = cell(1,1);
end

delete(handles.figure1);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    updateSource(handles,'Abiotic');

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    updateSource(handles,'Weather',Utilities.getpath('placeholder.txt'));

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    updateSource(handles,'Image');

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    updateSource(handles,'Spectro');

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    updateSource(handles,'Behavior');

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    updateSource(handles,'Olfactory');

% --- Executes on button press in okBtn.
function okBtn_Callback(hObject, eventdata, handles)
% hObject    handle to okBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    varargout{1}.sources = get(handles.output,'UserData');
    id_ = get(handles.edit1,'String');
    
    stringsExist = ~isempty(id_);

    if stringsExist%~iscell(varargout{1}.sources) && stringsExist
        set(hObject,'UserData',true);
        load('config.mat');
        config.id = config.id+1;
        save('config.mat','config');
        close;
    else
        errordlg('All fields are not entered correctly or no file is selected for loading','Error!');
    end

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close;
    
function updateSource(handles,type,varargin)

    tempStruct = get(handles.output,'UserData');
    
    if ~isempty(varargin)
        fname = varargin{1};
        
        if isfield(tempStruct,type)
            source = tempStruct.(type);
            numFieldNames = fieldnames(source);
            numFieldNames = size(numFieldNames);
            numFieldNames = numFieldNames(1);

        else
            source = struct;
            numFieldNames = 0;
        end
        
        source.(['pat',num2str(numFieldNames+1)]) = fname;
        
        tempStruct.(type) = source;
        set(handles.output,'UserData',tempStruct);
        
        [p,fname,ext] = fileparts(fname);
        fname = [fname,ext];%'template.xlsx';        
    else
        if strcmp(type,'Spectro')
            pname = uigetdir(Utilities.getpath(''));
            fname = '';
            %manager = InputManager();        
        else
            [fname,pname,~] = uigetfile('MultiSelect','on','*.*');
        end

        if isfield(tempStruct,type)
            source = tempStruct.(type);
            numFieldNames = fieldnames(source);
            numFieldNames = size(numFieldNames);
            numFieldNames = numFieldNames(1);
        else
            source = struct;
            numFieldNames = 0;
        end

        if ischar(fname)
            source.(['pat',num2str(numFieldNames+1)]) = [pname,fname];
        else
            size_ = size(fname);

            for i=1:size_(2)
                temp = fname{1,i};
                source.(['path',num2str(i+numFieldNames)]) = [pname,temp];
            end
        end

        tempStruct.(type) = source;
        set(handles.output,'UserData',tempStruct);

        fieldNames = fieldnames(source);
        numFieldNames = size(fieldNames);
        numFieldNames = numFieldNames(1);   

        fname = cell(numFieldNames,1);

        for i=1:numFieldNames
            name = source.(fieldNames{i,1});
            fname{i,1} = ['...',name(end-14:end)];
        end
    end
        
    switch type
        case 'Behavior'
            set(handles.behaveText,'String',fname);
        case 'Spectro'
            set(handles.spectroText,'String',['...',pname(end-15:end)]);
        case 'Weather'
            set(handles.weatherText,'String',fname);
        case 'Image'
            set(handles.imageText,'String',fname);
        case 'Abiotic'
            set(handles.abioText,'String',fname);
        case 'Olfactory'
            set(handles.olfText,'String',fname);
        case 'SpectroJaz'
            set(handles.text9,'String',fname);
    end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


% --- Executes on button press in templateBtn.
function templateBtn_Callback(hObject, eventdata, handles)
% hObject    handle to templateBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    updateSource(handles,'Behavior',Utilities.getpath('template.xlsx'));
    


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    updateSource(handles,'SpectroJaz');
