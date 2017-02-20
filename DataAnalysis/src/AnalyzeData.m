function varargout = AnalyzeData(varargin)
% ANALYZEDATA MATLAB code for AnalyzeData.fig
%      ANALYZEDATA, by itself, creates a new ANALYZEDATA or raises the existing
%      singleton*.
%
%      H = ANALYZEDATA returns the handle to a new ANALYZEDATA or the handle to
%      the existing singleton*.
%
%      ANALYZEDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALYZEDATA.M with the given input arguments.
%
%      ANALYZEDATA('Property','Value',...) creates a new ANALYZEDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AnalyzeData_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AnalyzeData_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AnalyzeData

% Last Modified by GUIDE v2.5 20-Feb-2017 11:48:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AnalyzeData_OpeningFcn, ...
                   'gui_OutputFcn',  @AnalyzeData_OutputFcn, ...
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


% --- Executes just before AnalyzeData is made visible.
function AnalyzeData_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AnalyzeData (see VARARGIN)

% Choose default command line output for AnalyzeData
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AnalyzeData wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AnalyzeData_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in FileButton.
function FileButton_Callback(hObject, eventdata, handles)
% hObject    handle to FileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Folder = uigetdir;

if(handles.Option1.Value == 1)
	[a Folder] = fileparts(handles.Folder);
	handles.FileNames.String = Folder;
else
	S = {};
	handles.SubFolders = [];
	temp = dir(handles.Folder);
	for f = 3:length(temp)
		if(isdir(temp(f).name))
			S{end+1} = temp(f).name;
			handles.SubFolders(end+1) = temp(f);
		end
	end
	handles.FileNames.String = S;
end

guidata(hObject, handles);


% --- Executes on button press in ExecuteButton.
function ExecuteButton_Callback(hObject, eventdata, handles)
% hObject    handle to ExecuteButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(handles.option1.Value == 1)
	extractData(handles.Folder.name)
else
	for i = 1:length(handles.SubFolders)
		extractData(handles.SubFolders(i).name)
end

% --- Executes on button press in HelpButton.
function HelpButton_Callback(hObject, eventdata, handles)
% hObject    handle to HelpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

HelpBox;
