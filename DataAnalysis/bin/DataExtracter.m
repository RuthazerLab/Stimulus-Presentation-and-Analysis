function varargout = DataExtracter(varargin)
% DATAEXTRACTER MATLAB code for DataExtracter.fig
%      DATAEXTRACTER, by itself, creates a new DATAEXTRACTER or raises the existing
%      singleton*.
%
%      H = DATAEXTRACTER returns the handle to a new DATAEXTRACTER or the handle to
%      the existing singleton*.
%
%      DATAEXTRACTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATAEXTRACTER.M with the given input arguments.
%
%      DATAEXTRACTER('Property','Value',...) creates a new DATAEXTRACTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataExtracter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataExtracter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataExtracter

% Last Modified by GUIDE v2.5 22-Jul-2016 12:27:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataExtracter_OpeningFcn, ...
                   'gui_OutputFcn',  @DataExtracter_OutputFcn, ...
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


% --- Executes just before DataExtracter is made visible.
function DataExtracter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataExtracter (see VARARGIN)

% Choose default command line output for DataExtracter
handles.output = hObject;

Root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(fullfile(Root,'DataAnalysis\\bin'));
addpath(fullfile(Root,'DataAnalysis\src'));
addpath(fullfile(Root,'DataAnalysis\src\Data Extraction'));
addpath(fullfile(Root,'DataAnalysis\src\ImageCorrection'));
addpath(fullfile(Root,'DataAnalysis\src\Plot'));
addpath(fullfile(Root,'DataAnalysis\ext'));
addpath(fullfile(Root,'Functions'));
cd(fullfile(Root,'Data'));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DataExtracter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DataExtracter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Folder = uigetdir('C:','Select where data is saved');

handles.pushbutton1.set('Visible','off');
handles.text2.set('Visible','off');
handles.text1.set('Visible','on');

header = extractData3(Folder);

if(strcmp(YesNo('Do you wish to plot the data?'),'Yes'))
	PlotRoiData({Folder,header.FileName});
end
