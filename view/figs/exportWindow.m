function varargout = exportWindow(varargin)
% EXPORTWINDOW MATLAB code for exportWindow.fig
%      EXPORTWINDOW, by itself, creates a new EXPORTWINDOW or raises the existing
%      singleton*.
%
%      H = EXPORTWINDOW returns the handle to a new EXPORTWINDOW or the handle to
%      the existing singleton*.
%
%      EXPORTWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPORTWINDOW.M with the given input arguments.
%
%      EXPORTWINDOW('Property','Value',...) creates a new EXPORTWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before exportWindow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to exportWindow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help exportWindow

% Last Modified by GUIDE v2.5 13-Oct-2014 10:46:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @exportWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @exportWindow_OutputFcn, ...
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


% --- Executes just before exportWindow is made visible.
function exportWindow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to exportWindow (see VARARGIN)

% Choose default command line output for exportWindow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(hObject,'Name','Choose file to export to');
% UIWAIT makes exportWindow wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = exportWindow_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    %varargout{1} = handles.output;
    
    if get(handles.okBtn,'UserData')
        varargout{1} = get(handles.text1,'string');
    else
        varargout{1} = -1;
    end
    
    delete(handles.figure1);   

% --- Executes on button press in okBtn.
function okBtn_Callback(hObject, eventdata, handles)
% hObject    handle to okBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if ~strcmp(get(handles.text1,'string'),'File: -')
        set(hObject,'UserData',true);
        close;
    else
        errordlg('All fields are not entered correctly or no file is selected for loading','Error!');
    end

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
    set(handles.radiobutton2,'value',~get(hObject,'value'));

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
    set(handles.radiobutton1,'value',~get(hObject,'value'));
    
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


% --- Executes on button press in browseBtn.
function browseBtn_Callback(hObject, eventdata, handles)
% hObject    handle to browseBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%    fname = get(handles.text1,'string');
%    pname = '';
    
%    if get(handles.radiobutton1,'value')
%        [fname,pname] = uigetfile('*.xls');
%    elseif get(handles.radiobutton2,'value')
        [fname,pname] = uiputfile('*.xlsx');
%    elseif ~get(handles.radiobutton1,'value') && ~get(handles.radiobutton2,'value')
%        errordlg('You need to select one of the alternatives above!','Error!');
%    end
    fname = strrep(fname,'.xlsx','');
    if ~isnumeric(fname) && ~isnumeric(pname)
        set(handles.text1,'string',[pname,fname]);
    end
    