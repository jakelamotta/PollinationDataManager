function varargout = imageCrop(varargin)
% IMAGECROP MATLAB code for imageCrop.fig
%      IMAGECROP, by itself, creates a new IMAGECROP or raises the existing
%      singleton*.
%
%      H = IMAGECROP returns the handle to a new IMAGECROP or the handle to
%      the existing singleton*.
%
%      IMAGECROP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGECROP.M with the given input arguments.
%
%      IMAGECROP('Property','Value',...) creates a new IMAGECROP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imageCrop_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imageCrop_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imageCrop

% Last Modified by GUIDE v2.5 26-Nov-2014 12:08:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @imageCrop_OpeningFcn, ...
    'gui_OutputFcn',  @imageCrop_OutputFcn, ...
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

% --- Executes just before imageCrop is made visible.
function imageCrop_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imageCrop (see VARARGIN)

% Choose default command line output for imageCrop
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

imageList = varargin{1}(:,2:end);
p = varargin{2};
set(handles.text1,'String',p);
s = size(imageList);

set(hObject,'Name','Choose images to load');
set(handles.figure1,'UserData',imageList);
set(handles.popupmenu1,'UserData',imageList);
set(handles.popupmenu1,'String',imageList(2,:));
set(handles.okBtn,'UserData',false);
set(handles.axes1,'UserData',imageList{1,1});

setImages(handles,imageList{1,1});

% UIWAIT makes imageCrop wait for user response (see UIRESUME)
uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = imageCrop_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = '';

if get(handles.okBtn,'UserData')    
    varargout{1} = get(handles.popupmenu1,'UserData');
else
    varargout{1} = 'kill';
end

delete(hObject);

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
    close();
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)    
    cla(handles.axes2,'reset');
    showCroppedImage(handles);
    list = get(handles.popupmenu1,'UserData');
    index = get(handles.popupmenu1,'Value');
    set(handles.keepbox,'Value',true);
    list{3,index} = true;
    set(handles.popupmenu1, 'UserData',list);
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
end

function showCroppedImage(handles)
    axesCroppedHandle = handles.axes2;
    
    image_ = get(handles.axes1,'UserData');
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%SQUARE THE IMAGE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [h,w] = size(image_);
    
    if h~=w
        
        squareSize = min(h,w);
       
        center_vertical = round(h/2);
            center_horizontal = round(w/2);
            h1 = center_vertical-floor(squareSize/2)+1;
            h2 = center_vertical+floor(squareSize/2);
            w1 = center_horizontal-floor(squareSize/2)+1;
            w2 = center_horizontal+floor(squareSize/2);
            
        squaredImage = image_(h1:h2,w1:w2,:);
    end
    image_ = squaredImage;
    %%%%%%%%%%%%%%%%%%%%%%
    
    imshow(image_,'Parent',axesCroppedHandle);
    hold on;
    axis image;
end

function setImages(handles,im)

S.h = handles;
S.fH = handles.figure1;
S.aH = handles.axes1;

y_min = NaN;
y_max = NaN;
x_min = NaN;
x_max = NaN;
imageSize = size(im);

tempImage = get(handles.axes1,'UserData');

S.iH = imshow(im,'Parent',S.aH); 

set(handles.axes1,'UserData',tempImage);

axis image;

X = [];
Y = [];

set(S.aH,'ButtonDownFcn',@startDragFcn)
set(S.iH,'ButtonDownFcn',@startDragFcn)
set(S.fH, 'WindowButtonUpFcn', @stopDragFcn);

    function startDragFcn(varargin)
        set( S.fH, 'WindowButtonMotionFcn', @draggingFcn );
        pt = get(S.aH, 'CurrentPoint');
        x = pt(1,1);
        y = pt(1,2);
        X = x;
        Y = y;
    end

    function draggingFcn(varargin)
        S.iH = imshow( im ); hold on
        
        set(S.aH,'ButtonDownFcn',@startDragFcn);
        set(S.iH,'ButtonDownFcn',@startDragFcn);
        set(S.fH, 'WindowButtonUpFcn', @stopDragFcn);
        
        pt = get(S.aH, 'CurrentPoint');
        x = pt(1,1);
        y = pt(1,2);        
        
        if x <= imageSize(2) && y <= imageSize(1)
        
            X = [X x];
            Y = [Y y];

            size(im);
            if isnan(x_min)
                x_min = x;
                x_max = x;
                y_min = y;
                y_max = y;
            end

            avgX = (x_min+x_max)/2;
            avgY = (y_min+y_max)/2;


            y_min = min(Y);
            x_min = min(X);
            x_max = max(X);
            y_max = max(Y);

            if x < avgX && y < avgY
                x_min = max(x,x_min);
                y_min = max(y,y_min);
            elseif x > avgX && y < avgY
                x_max = min(x,x_max);
                y_min = max(y,y_min);
            elseif x < avgX && y > avgY
                x_min = max(x,x_min);
                y_max = min(y,y_max);
            elseif x > avgX && y > avgY
                x_max = min(x,x_max);
                y_max = min(y,y_max);
            end

            plot([x_min,x_max],[y_min,y_min]);
            plot([x_min,x_max],[y_max,y_max]);
            plot([x_min,x_min],[y_min,y_max]);
            plot([x_max,x_max],[y_min,y_max]);
            
            tempImage = squarify(im,y_min,y_max,x_min,x_max);
            
            if ndims(tempImage) == 3
                set(S.aH,'UserData',rgb2gray(tempImage));
            else
                set(S.aH,'UserData',tempImage);
            end
            
            images = get(S.h.popupmenu1,'UserData');
            
            if ndims(tempImage) == 3
                images{1,get(S.h.popupmenu1,'Value')} = rgb2gray(tempImage); 
            else
                images{1,get(S.h.popupmenu1,'Value')} = tempImage; 
            end
            
            set(S.h.popupmenu1,'UserData',images);
        end
        
        hold off
    end

    function stopDragFcn(varargin)
        set(S.fH, 'WindowButtonMotionFcn', '');  %eliminate fcn on release
    end
end

function squaredImage = squarify(image_,varargin)
    if ~isempty(varargin)
        y_min = varargin{1};
        y_max = varargin{2};
        x_min = varargin{3};
        x_max = varargin{4};
        
        [h,w] = size(image_);
        
        squaredImage = image_(max(floor(y_min),1):min(floor(y_max),h),...
            max(floor(x_min),1):min(floor(x_max),w),:);
        %squaredImage = image_(floor(x_min):floor(x_max),floor(y_min):floor(y_max),:);
    end
%     [h,w,s] = size(squaredImage);
%     
%     if h~=w
%         
%         squareSize = min(h,w);
% %         avg = round((h+w)/2);
% %         
% %         if avg+floor(y_min) > h
% %             avg = h;
% %         end
% % 
% %         if avg+floor(x_min) > w
% %             avg = w;
% %         end
%         
%             center_vertical = round((y_max-y_min)/2);
%             center_horizontal = round((x_max-x_min)/2);
%             h1 = center_vertical-floor(squareSize/2);
%             h2 = center_vertical+floor(squareSize/2);
%             w1 = center_horizontal-floor(squareSize/2);
%             w2 = center_horizontal+floor(squareSize/2);
%             
%             disp('size');
%             disp(size(image_));
%             disp('-');
%             disp(h1);
%             disp(h2);
%             disp(w1);
%             disp(w2);
%             disp('******************');
%             
% %         end
% %         h1 = floor(y_min);
% %         h2 = floor(y_min)+floor(avg);
% %         w1 = floor(x_min);
% %         w2 = floor(x_min)+floor(avg);
% 
%         %squaredImage = image_(floor(x_min):floor(x_min)+floor(avg),floor(y_min):floor(y_min)+floor(avg),:);
%         squaredImage = image_(max(h1,1):max(h2,1),w1:w2,:);
%     end
end

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
    cla(handles.axes2,'reset');
    cla(handles.axes1,'reset');
    index = get(hObject,'Value');
    imageList = get(handles.figure1,'UserData');
    list = get(handles.popupmenu1,'UserData');
    
    imshow(imageList{1,index},'Parent',handles.axes1);
    setImages(handles,imageList{1,index})
    
    set(handles.axes1,'UserData',imageList{1,index});
    
    set(handles.keepbox,'Value',list{3,index});    
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
end

% --- Executes on button press in keepbox.
function keepbox_Callback(hObject, eventdata, handles)
% hObject    handle to keepbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of keepbox
    list = get(handles.popupmenu1,'UserData');
    index = get(handles.popupmenu1,'Value');
    list{3,index} = get(hObject,'Value');
    set(handles.popupmenu1, 'UserData',list);
end