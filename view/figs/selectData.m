function varargout = selectData(varargin)
% SELECTDATA MATLAB code for selectData.fig
%      SELECTDATA, by itself, creates a new SELECTDATA or raises the existing
%      singleton*.
%
%      H = SELECTDATA returns the handle to a new SELECTDATA or the handle to
%      the existing singleton*.
%
%      SELECTDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTDATA.M with the given input arguments.
%
%      SELECTDATA('Property','Value',...) creates a new SELECTDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before selectData_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to selectData_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help selectData

% Last Modified by GUIDE v2.5 27-Feb-2015 11:51:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @selectData_OpeningFcn, ...
                   'gui_OutputFcn',  @selectData_OutputFcn, ...
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

% --- Executes just before selectData is made visible.
function selectData_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to selectData (see VARARGIN)
obj = varargin{1};

handler = varargin{3};
%data = obj.getMatrix();
% spectro = obj.getSpectroData();
% olfactory = obj.getOlfactoryData();
id = varargin{2};
set(hObject,'Name',[id,' data']);
% Choose default command line output for selectData
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

userdata = struct;
userdata.handler = handler;
userdata.data = obj;
userdata.type = id;

if strcmp(id,'Spectro') || strcmp(id,'SpectroJaz')
    userdata.dp = handler.getDataManager().getNrOfSpectroDP();
    set(hObject,'UserData',userdata);
    
setGraph(handles,obj,id);
elseif strcmp(id,'Olfactory')
    userdata.dp = handler.getDataManager().getNrOfOlfactoryDP();
    set(hObject,'UserData',userdata);
    
setGraph(handles,obj,id);
end


set(hObject,'UserData',userdata);

set(handles.okBtn,'UserData',false);

setTable(handles,obj);

%set(handles.figure1,'UserData',data);
% UIWAIT makes selectData wait for user response (see UIRESUME)
 uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = selectData_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
out_ = struct;

if get(handles.okBtn,'UserData')
    if get(handles.checkbox1,'value')
        type = 'average';
    else
        type = 'random';
    end
    
    userdata = get(handles.figure1,'UserData');
    data = userdata.data;
        
    handler = userdata.handler;

    h = findobj('Tag','sampleedit');
    rate = get(h,'String');
    
    out_.interp = false;
    
    if strcmpi(userdata.type,'Olfactory')
        out_.interp = get(handles.cb_interp,'Value');
        handler.getDataManager().setNrOfOlfactoryDP(rate);
    elseif strcmp(userdata.type,'Spectro') || strcmp(userdata.type,'SpectroJaz')
        out_.interp = get(handles.cb_interp,'Value');
        handler.getDataManager().setNrOfSpectroDP(rate);
    end
    
    out_.data = data;
    out_.handler = handler;
else
    type = 'nofilter';
end

handler = get(hObject,'UserData');

out_.type = type;

varargout{1} = out_;

delete(handles.figure1);
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

% --- Executes on button press in okBtn.
function okBtn_Callback(hObject, eventdata, handles)
% hObject    handle to okBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    userdata = get(handles.figure1,'UserData');
    data = userdata.data;
    
    if get(handles.checkbox1,'value') || validateData(data)    
        set(hObject,'UserData',true);
        close;
    else
       errordlg('Exactly one observation/row or "Use average" must be seleced'); 
    end
end

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close;
end

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
end

function cellSelect(src,evt)
    % get indices of selected rows and make them available for other callbacks
    index = evt.Indices;
    
    if any(index)             %loop necessary to surpress unimportant errors.
        rows = index(:,1);
        set(src,'UserData',rows);
    end
end

function setTable(handles,obs)
    %h = figure('Position',[600 400 402 100],'numbertitle','off','MenuBar','none');
    data = obs.getMatrix();
    h = handles.figure1;
    defaultData = [data(:,1:uint32(Constants.SpectroXPos)-1),data(:,uint32(Constants.OlfYPos)+1:end)];

    %defaultData = data;
    t = uitable(h,'Units','normalized','Position',[.15 .55, .8 .25],'Data', defaultData,'Tag','myTable',...
        'ColumnName', [],'RowName',[],...
        'CellSelectionCallback',@cellSelect);
    set(t,'Rowname','numbered');
    set(t,'Columnname','numbered');
    
    colors = {'#FFFFCC','#99CCFF'};
    choice = 1;
    
    %Color generating function
    colorgen = @(color,text) ['<html><table border=0 width=400 bgcolor=',color,'><TR><TD>',text,'</TD></TR> </table></html>'];
    obs.set(2,1,colorgen(colors{choice},obs.get(2,1)));
    
    %Function to switch between colors when id changes
    for i=3:obs.getNumRows()
        if ~strcmp(obs.getIdAtRow(i),obs.getIdAtRow(i-1))
            choice = mod(choice,2)+1; %Flipping between 1 and 2
        end
        
        obs.set(i,1,colorgen(colors{choice},obs.get(i,1)));
    end
    

    data = obs.getMatrix();
    
    set(t,'Data',[data(:,1:uint32(Constants.SpectroXPos)-1),data(:,uint32(Constants.OlfYPos)+1:end)]);
    
    % create pushbutton to delete selected rows
    uicontrol(h,'Style','pushbutton','Position',[20,400,60,20],'String','Delete','Callback',{@deleteRow,handles});
end

function setGraph(h,obs,type)
    handle = h.figure1;
    
    global colors;
    t = axes('units','normalized','Position',[.15 .25, .8 .25]);

    index = 1;
    
    %data = obs.getMatrix();
    height = obs.getNumRows();
    
    if strcmp(type,'Spectro') || strcmp(type,'SpectroJaz')

        legendList = cell(1,(height-1)*2);    

        for i=2:height
            plot(t,[obs.get(i,uint32(Constants.SpectroXPos))],[obs.get(i,uint32(Constants.SpectroYPos))],colors{1,mod(i,length(colors))+1});

            hold on;

            plot(t,[obs.get(i,uint32(Constants.SpectroXUpPos))],[obs.get(i,uint32(Constants.SpectroYUpPos))],colors{1,mod(i,length(colors))+1});

            legendList{index+1} = [obs.get(i,2),'up'];
            legendList{index} = obs.get(i,2);
            index = index + 2;
        end

    elseif strcmp(type,'Olfactory')
        legendList = cell(1,(height-1));

        for i=2:height
            plot(t,obs.get(i,uint32(Constants.OlfXPos)),obs.get(i,uint32(Constants.OlfYPos)),colors{1,mod(i,length(colors))+1});
            
            hold on;
            legendList{index} = obs.get(i,2);

            index = index + 1;
        end
    end

    legend(legendList);

    toSend = obs;

    userdata = get(handle,'UserData');
    handler = userdata.handler;

    if strcmp(userdata.type,'Spectro') 
        dp = handler.getDataManager().getNrOfSpectroDP();
    elseif strcmp(userdata.type,'SpectroJaz')
        dp = handler.getDataManager().getNrOfSpectroJazDP();
    else
        dp = handler.getDataManager().getNrOfOlfactoryDP();
    end

    edit_ = uicontrol(handle,'Style','edit','Tag','sampleedit','String',dp,'Position',[20 240 40 20]);
    uicontrol(handle,'Style','text','String','Nr of datapoints used','Position',[65 240 110 20]);
    
    if ischar(dp)
        dp = str2double(dp);
    end
    
    if dp ~= uint32(Constants.SpectroJazDP) && strcmp(userdata.type,'SpectroJaz')
        set(edit_,'Enable','off');
    end

    if dp ~= uint32(Constants.SpectroDP) && strcmp(userdata.type,'Spectro')
        set(edit_,'Enable','off');
    end
    
    if dp ~= 15000 && strcmp(userdata.type,'Olfactory')
        set(edit_,'Enable','off');
    end

    button = uicontrol(handle,'Style','pushbutton','Position',[20 190 100 20],'String','Preview interpolation','Callback',{@downSample,toSend,t,handle,type,h});
end

%%Function for interpolating Spectro and Olfactory data
function downSample(varargin)
    handles = varargin{7};
    set(handles.cb_interp,'Value',true);
    
    obs = varargin{3};

    t = varargin{4};
    hfig = varargin{5};
    type = varargin{6};
    
    height = obs.getNumRows();
    h = findobj('Tag','sampleedit');
    rate = get(h,'String');
    dsrate = str2double(rate);
    
    obs.setInterp(type,true);
    
    %%Interpolating Spectro data 
    if strcmp(type,'Spectro')
        for i=2:height
            y1 = obs.get(i,uint32(Constants.SpectroYPos));
            x1 = obs.get(i,uint32(Constants.SpectroXPos));
            
            try
                y2 = obs.get(i,uint32(Constants.SpectroYUpPos));
                x2 = obs.get(i,uint32(Constants.SpectroXUpPos));
            catch e
            end
            
            x1new = round(linspace(380,600,dsrate));
            
            try
                x2new = round(linspace(380,600,dsrate));
            catch e
            end
            
            y1 = interp1(x1,y1,x1new);
            
            try
                y2 = interp1(x2,y2,x2new);
            catch e
            end
            
            plot(t,x1,obs.get(i,uint32(Constants.SpectroYPos)),'g');
            hold on
            plot(t,x1new,y1,'r');
            
            try
                plot(t,x2,obs.get(i,uint32(Constants.SpectroYUpPos)),'g');
                plot(t,x2new,y2,'b');
            catch e
            end
        end
       
    elseif  strcmp(type,'SpectroJaz')
        for i=2:height
            y1 = obs.get(i,uint32(Constants.SpectroYPos));
            x1 = obs.get(i,uint32(Constants.SpectroXPos));
            
            %try
                y2 = obs.get(i,uint32(Constants.SpectroYUpPos));
                x2 = obs.get(i,uint32(Constants.SpectroXUpPos));
            %catch e
            %end
            
            x1new = round(linspace(200,800,dsrate));
            
            %try
                x2new = round(linspace(200,800,dsrate));
            %catch e
            %end
            
            y1 = interp1(x1,y1,x1new);
            
            %try
                y2 = interp1(x2,y2,x2new);
            %catch e
            %end
            
            plot(t,x1,obs.get(i,uint32(Constants.SpectroYPos)),'g');
            hold on
            plot(t,x1new,y1,'r');
            
            %try
                plot(t,x2,obs.get(i,uint32(Constants.SpectroYUpPos)),'g');
                plot(t,x2new,y2,'b');
            %catch e
            %end
        end
        
    %%Interpolating Olfactory data 
    else
        for i=2:height
            x1 = obs.get(i,uint32(Constants.OlfXPos));%matrix{i,uint32(Constants.OlfXPos)};
            y1 = obs.get(i,uint32(Constants.OlfYPos));%matrix{i,uint32(Constants.OlfYPos)};

            x1new = linspace(min(x1),max(x1),dsrate);
            y1 = interp1(x1,y1,x1new);
            plot(t,x1,obs.get(i,uint32(Constants.OlfYPos)),'g');%matrix{i,uint32(Constants.OlfYPos)},'g');
            hold on
            plot(t,x1new,y1,'r');
        end
    end
    
    userdata = get(hfig,'UserData');    
    mHandler = userdata.handler;
    
    %mHandler.getDataManager().setNrOfSpectroDP(userdata.dp); 
        
    userdata.handler = mHandler;
    userdata.dp = dsrate;
        
    set(hfig,'UserData',userdata);
 end

function deleteRow(varargin)
    handle = varargin{3};
    th = findobj('Tag','myTable');
    
    %get current data
    data = get(th,'Data');
    
    %get indices of selected rows
    rows = get(th,'UserData');
    
    %create mask containing rows to keep
    mask = (1:size(data,1))';
    mask(rows) = [];
    
    %delete selected rows and re-write data
    data = data(mask,:);
    set(th,'Data',data);
    userdata = get(handle.figure1,'UserData');
    
    obs = userdata.data;
    actualData = obs.getMatrix();
    
    actualData(rows,:) = [];
    
    obs.setMatrix(actualData);
    userdata.data = obs;
    
    userdata.rows = rows;
    set(handle.figure1,'UserData',userdata);
end

%%Function for validating the output of selectdata. The Observation cell is
%%valid if no observation occurs more than one time.
function out_ = validateData(obs)
    out_ = true;
    temp = obs.get(2,2);
    height = obs.getNumRows();
    
    for i=3:height
        if strcmp(temp,obs.get(i,2))
            out_ = false;
            break;
        end
        temp = obs.get(i,2);
    end
end


% --- Executes on button press in cb_interp.
function cb_interp_Callback(hObject, eventdata, handles)
% hObject    handle to cb_interp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_interp
end