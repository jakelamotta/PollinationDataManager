function varargout = importWindow(varargin)
% IMPORTWINDOW MATLAB code for importWindow.fig
%      IMPORTWINDOW, by itself, creates a new IMPORTWINDOW or raises the existing
%      singleton*.
%
%      H = IMPORTWINDOW returns the handle to a new IMPORTWINDOW or the handle to
%      the existing singleton*.
%
%      IMPORTWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMPORTWINDOW.M with the given input arguments.
%
%      IMPORTWINDOW('Property','Value',...) creates a new IMPORTWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before importWindow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to importWindow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help importWindow

% Last Modified by GUIDE v2.5 24-Feb-2015 15:20:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @importWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @importWindow_OutputFcn, ...
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


% --- Executes just before importWindow is made visible.
function importWindow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to importWindow (see VARARGIN)

% Choose default command line output for importWindow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(hObject,'Name','Choose data types to load');
set(handles.okBtn,'UserData',NaN);
% UIWAIT makes importWindow wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = importWindow_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;

    varargout{1} = get(handles.okBtn,'UserData');    
    delete(handles.figure1);


% --- Executes on button press in okBtn.
function okBtn_Callback(hObject, eventdata, handles)
% hObject    handle to okBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    data = cell(1,2);
    types = {'','','','','','',''};
    type = '';
    
    if get(handles.radiobutton1,'value')
        types{1} = 'Abiotic';
    end
    
    if get(handles.radiobutton2,'value')
        types{6} = 'Weather';
    end
    
    if get(handles.radiobutton3,'value')
        types{3} = 'Image';
    end
    
    if get(handles.radiobutton4,'value')
        types{5} = 'Spectro';
    end
    
    if get(handles.radiobutton5,'value')
        types{2} = 'Behavior';
    end
    
    if get(handles.radiobutton6,'value')
        types{7} = 'Olfactory';
    end
    
    if get(handles.radiobutton9,'value')
       types{4} = 'SpectroJaz'; 
    end
    
    if get(handles.loadrb,'value')
        type = 'load';
    end
  
    types = types(~cellfun('isempty',types));
    
    if ~strcmp(type,'load')
        path_ = uigetdir(Utilities.getpath(''));
    else
        types = {type};
        path_ = '';
    end
    
    data{1,1} = types;
    data{1,2} = path_;    
    
    set(hObject,'UserData',data);
    close;    
    
% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close();

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
    if get(hObject,'value')
        updateRadio(handles,hObject);
    end
    
% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
    if get(hObject,'value')
        updateRadio(handles,hObject);
    end

% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
    if get(hObject,'value')
        updateRadio(handles,hObject);
    end

% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4
    if get(hObject,'value')
        updateRadio(handles,hObject);
    end

% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton5
    if get(hObject,'value')
        updateRadio(handles,hObject);
    end
    
% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton6
    if get(hObject,'value')
        updateRadio(handles,hObject);
    end
    
 function updateRadio(handles,hObject)
    set(hObject,'value',true);
    
    
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

% --- Executes on button press in loadrb.
function loadrb_Callback(hObject, eventdata, handles)
% hObject    handle to loadrb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loadrb
    if get(hObject,'value')
        updateRadio(handles,hObject);
    end


% --- Executes on button press in radiobutton9.
function radiobutton9_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton9
