function varargout = fileChoice(varargin)
% FILECHOICE MATLAB code for fileChoice.fig
%      FILECHOICE, by itself, creates a new FILECHOICE or raises the existing
%      singleton*.
%
%      H = FILECHOICE returns the handle to a new FILECHOICE or the handle to
%      the existing singleton*.
%
%      FILECHOICE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FILECHOICE.M with the given input arguments.
%
%      FILECHOICE('Property','Value',...) creates a new FILECHOICE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fileChoice_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fileChoice_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fileChoice

% Last Modified by GUIDE v2.5 27-Jan-2015 16:16:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fileChoice_OpeningFcn, ...
                   'gui_OutputFcn',  @fileChoice_OutputFcn, ...
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
end

% --- Executes just before fileChoice is made visible.
function fileChoice_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fileChoice (see VARARGIN)

% Choose default command line output for fileChoice
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
paths = varargin{1};

if length(paths) > 1
    [noMultiFiles, hasMultiFiles] = findDuplicates(paths);
else
    noMultiFiles = paths;
    hasMultiFiles = {};
end

set(hObject,'Name','Abiotic data');
set(hObject,'UserData',noMultiFiles);
set(handles.lbFiles,'String',hasMultiFiles);
set(handles.okBtn,'UserData',false);

% UIWAIT makes fileChoice wait for user response (see UIRESUME)
 uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = fileChoice_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    if get(handles.okBtn,'UserData')
        varargout{1} = [get(handles.figure1,'UserData'),transpose(get(handles.lbFiles,'String'))];
    else
        varargout{1} = '';
    end
    delete(hObject);
end
% --- Executes on selection change in lbFiles.
function lbFiles_Callback(hObject, eventdata, handles)
% hObject    handle to lbFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lbFiles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lbFiles
end

% --- Executes during object creation, after setting all properties.
function lbFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in okBtn.
function okBtn_Callback(hObject, eventdata, handles)
% hObject    handle to okBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(hObject,'UserData',true);
    close();
end
% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(handles.figure1);
end

% --- Executes on button press in delBtn.
function delBtn_Callback(hObject, eventdata, handles)
% hObject    handle to delBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    lbStrings = get(handles.lbFiles,'String');
    index = get(handles.lbFiles,'Value');
    for i=1:length(index)
        lbStrings{index(i)} = []; 
    end
    
    lbStrings = lbStrings(~cellfun('isempty',lbStrings));
    set(handles.lbFiles,'Value',1);
    set(handles.lbFiles,'String',lbStrings);
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
end

function [noM, hasM] = findDuplicates(paths)
    noM = {};
    hasM = {};
    
    [pathstr_current,NAME,EXT] = fileparts(paths{1});
    [pathstr_next,NAME,EXT] = fileparts(paths{2});
    
    if ~strcmp(pathstr_current,pathstr_next)
        noM{1} = paths{1};
    else
        hasM{1} = paths{1};
    end
    
    for i=2:length(paths)-1;            
        [pathstr_current,NAME,EXT] = fileparts(paths{i});
        [pathstr_prev,NAME,EXT] = fileparts(paths{i-1});
        [pathstr_next,NAME,EXT] = fileparts(paths{i+1});
        
        if ~strcmp(pathstr_current,pathstr_prev) && ~strcmp(pathstr_current,pathstr_next)
            noM{end+1} = paths{i};
        else
            hasM{end+1} = paths{i};
        end
    end
    
    [pathstr_current,NAME,EXT] = fileparts(paths{end});
    [pathstr_prev,NAME,EXT] = fileparts(paths{end-1});
    
    if ~strcmp(pathstr_current,pathstr_prev)
        noM{end+1} = paths{end};
    else
        hasM{end+1} = paths{end};
    end
end