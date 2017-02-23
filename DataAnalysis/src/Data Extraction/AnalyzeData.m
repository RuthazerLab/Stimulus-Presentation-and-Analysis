function varargout = AnalyzeData(varargin)
% AnalyzeData MATLAB code for AnalyzeData.fig
% 		AnalyzeData implements the extractData.m in a user-friendly GUI
% 		To use, do one of the following:
% 		(i)	Choose SINGLE FILE and select the folder that contains the 
% 			appropriate files. The data will be analyzed and the analyzed
% 			data will be stored in the selected file.
% 		(ii)Choose ENTIRE SET and select the folder containing all the
% 			folders you wish to analyze. The program will loop through
% 			each one and perform the single file analysis.
% 
% See also: extractData, RunExperiment, PlotRoiData

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

Folder = uigetdir;
handles.Folders = {};

if(handles.Option1.Value == 1)
	[a FolderName] = fileparts(Folder);
	handles.FileNames.String = FolderName;
	handles.Folders{1} = Folder;
else
	S = {};
	handles.Folders = [];
	temp = dir(Folder);
	for f = 3:length(temp)
		if(isdir(fullfile(Folder,temp(f).name)))
			S{end+1} = temp(f).name;
			handles.Folders{end+1} = fullfile(Folder,temp(f).name);
		end
	end
	if(length(S) > 7)
		S{7} = '...';
	end
	handles.FileNames.String = S;
end

guidata(hObject, handles);


% --- Executes on button press in ExecuteButton.
function ExecuteButton_Callback(hObject, eventdata, handles)
% hObject    handle to ExecuteButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)\

[FolderPath FolderName] = fileparts(handles.Folders{1});

h = waitbar(1/length(handles.Folders), FolderName, 'Name','Analyzing Data');


for i = 1:length(handles.Folders)
	Correct = 1;
	[FolderPath FolderName] = fileparts(handles.Folders{i});

	waitbar(i/length(handles.Folders),h,FolderName);


	if(~exist(fullfile(handles.Folders{i},'Episode001.h5')))
		disp([FolderName ' is missing Episode001.h5']);
		Correct = 0;
	end
	if(~exist(fullfile(handles.Folders{i},'Experiment.xml')))
		disp([FolderName ' is missing Experiment.xml']);
		Correct = 0;
	end
	if(~exist(fullfile(handles.Folders{i},'Image_0001_0001.raw')))
		disp([FolderName ' is missing Image_0001_0001.raw']);
		Correct = 0;
	end
	if(~exist(fullfile(handles.Folders{i},'StimulusConfig.txt')))
		disp([FolderName ' is missing StimulusConfig.txt']);
		Correct = 0;
	end
	if(~exist(fullfile(handles.Folders{i},'StimulusTimes.txt')))
		disp([FolderName ' is missing StimulusTimes.txt']);
		Correct = 0;
	end
	if(~exist(fullfile(handles.Folders{i},'ThorRealTimeDataSettings.xml')))
		disp([FolderName ' is missing ThorRealTimeDataSettings.xml']);
		Correct = 0;
	end
	if(Correct)
		try
			extractData(handles.Folders{i});
		catch
			disp(['An error occured while analyzing ' FolderName]);
		end
	end
end
		
delete(h);

% --- Executes on button press in HelpButton.
function HelpButton_Callback(hObject, eventdata, handles)
% hObject    handle to HelpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

HelpBox;
