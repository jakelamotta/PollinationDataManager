function varargout = manageData(varargin)
% MANAGEDATA MATLAB code for manageData.fig
%      MANAGEDATA, by itself, creates a new MANAGEDATA or raises the existing
%      singleton*.
%
%      H = MANAGEDATA returns the handle to a new MANAGEDATA or the handle to
%      the existing singleton*.
%
%      MANAGEDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANAGEDATA.M with the given input arguments.
%
%      MANAGEDATA('Property','Value',...) creates a new MANAGEDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before manageData_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to manageData_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help manageData

% Last Modified by GUIDE v2.5 28-Oct-2014 15:51:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @manageData_OpeningFcn, ...
                   'gui_OutputFcn',  @manageData_OutputFcn, ...
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


% --- Executes just before manageData is made visible.
function manageData_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to manageData (see VARARGIN)

% Choose default command line output for manageData
handles.output = hObject;

if ~isempty(varargin)
    obs = varargin{1};
end

matrix = obs.getMatrix();
ids = cell(1,obs.getNumRows()-1);

for i=2:obs.getNumRows()
    ids{1,i-1} = matrix{i,2};
end

set(hObject,'Name','Add a comment');
set(handles.popupmenu1,'String',ids);


% Update handles structure
guidata(hObject, handles);
userdata = struct;
userdata.save = false;
userdata.obs = obs;
set(handles.figure1,'UserData',userdata);

popupmenu1_Callback(handles.popupmenu1, eventdata, handles);
% UIWAIT makes manageData wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = manageData_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;

userdata = get(handles.figure1,'UserData');
userdata.row = get(handles.popupmenu1,'Value')+1;

if userdata.save
    varargout{1} = userdata;
else
    varargout{1} = '';
end

delete(hObject);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    userdata = get(handles.figure1,'UserData');
    userdata.save = true;
    userdata.comment = get(handles.edit1,'String');
    set(handles.figure1,'UserData',userdata);
    close();

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
    userdata = get(handles.figure1,'UserData');
    obs = userdata.obs;
    ids = get(hObject,'String');
    id = ids{get(hObject,'Value')};
    
    comment = obs.getCommentFromId(id);
    if ~isempty(comment)
        set(handles.edit1,'String',comment);
    else
        set(handles.edit1,'String','Write comment here');
    end
    
% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
    guidata(hObject,handles);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end