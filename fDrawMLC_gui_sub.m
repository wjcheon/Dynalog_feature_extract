function varargout = fDrawMLC_gui(varargin)
% FDRAWMLC_GUI MATLAB code for fDrawMLC_gui.fig
%      FDRAWMLC_GUI, by itself, creates a new FDRAWMLC_GUI or raises the existing
%      singleton*.
%
%      H = FDRAWMLC_GUI returns the handle to a new FDRAWMLC_GUI or the handle to
%      the existing singleton*.
%
%      FDRAWMLC_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FDRAWMLC_GUI.M with the given input arguments.
%
%      FDRAWMLC_GUI('Property','Value',...) creates a new FDRAWMLC_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fDrawMLC_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fDrawMLC_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fDrawMLC_gui

% Last Modified by GUIDE v2.5 03-Jul-2017 10:04:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fDrawMLC_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @fDrawMLC_gui_OutputFcn, ...
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


% --- Executes just before fDrawMLC_gui is made visible.
function fDrawMLC_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fDrawMLC_gui (see VARARGIN)

% Choose default command line output for fDrawMLC_gui
handles.output = hObject;
%
%
if(size(varargin,2)==2)
    handles.bankA_pos = varargin{1};
    handles.bankB_pos = varargin{2};
    set(handles.edit1,'string','Successully loaded')
elseif(size(varargin,2)==3)
    handles.bankA_pos = varargin{1};
    handles.bankB_pos = varargin{2};
    handles.filename_loaded = varargin{3};
    set(handles.edit1,'string',handles.filename_loaded)
end
%
% generate name list
for iter1 = 1: size(handles.bankB_pos,1)
    new_line{iter1} = num2str(iter1,'%04i');
end
%
initial_name=cellstr(get(handles.listbox1,'String'));
new_name = [initial_name  new_line];
new_name = [new_line];
set(handles.listbox1,'String',new_name);
a=0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fDrawMLC_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fDrawMLC_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
% a=0;
full_list = cellstr(get(handles.listbox1,'String'));
sel_val=get(handles.listbox1,'value');
sel_item=full_list(sel_val);
sel_item_index = str2num(sel_item{1});
fDrawMLC(handles.bankA_pos, handles.bankB_pos, sel_item_index, handles);


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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
