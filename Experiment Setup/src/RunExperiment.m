function varargout = RunExperiment(varargin)
%RUNEXPERIMENT MATLAB code file for RunExperiment.fig
%      User interface to present a visual stimulus chosen
%      from a list. Also outputs a 5V trigger to an attached
%      National Instrument Dev1, through ao1 to ThorSync.
%      Creates the following files:
%         StimulusData.txt
%         StimulusConfig.txt
%
% See also: ANALYZEDATA, PLOTROIDATA

% Edit the above text to modify the response to help RunExperiment

% Last Modified by GUIDE v2.5 02-Feb-2017 12:11:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
 'gui_Singleton',  gui_Singleton, ...
 'gui_OpeningFcn', @RunExperiment_OpeningFcn, ...
 'gui_OutputFcn',  @RunExperiment_OutputFcn, ...
 'gui_LayoutFcn',  [], ...
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

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');

end

%% ---- Opening Function ---- %%


% --- Executes just before RunExperiment is made visible.
function RunExperiment_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Initializes variables
handles.output = hObject;
handles.folder = '.';
handles.text9.String = ['Save to: ' handles.folder '\'];
handles.edit10.String = '0';
handles.typ = 0;
handles.ssiz = str2num(handles.edit11.String);

% Names of the different stimulus options
handles.listbox1.String = {'Calibrate Setup'; 'Random Squares'; 'RF Bars';
'Brightness Levels'; 'Spatial Frequency'; 'Direction'; 'Orientation'; 'Radii'; 'Looming';'Moving Frequency'};
handles.text1.set('Visible','off'); handles.edit1.set('Visible','off');
handles.text2.set('Visible','off'); handles.edit2.set('Visible','off');
handles.text3.set('Visible','off'); handles.edit3.set('Visible','off');


% Turn off warnings
warning('off','images:initSize:adjustingMag');

guidata(hObject, handles);



%% ---- Image Capture ---- %%

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Sets the options for the stimulus type selected.

typ = get(handles.listbox1,'value') - 1;
F = {};

handles.text15.set('String', 'Stim Length'); 
handles.edit12.set('String','0.2');

switch typ

case 0  % Align

  handles.text1.set('Visible','off'); handles.edit1.set('Visible','off');
  handles.text2.set('Visible','off'); handles.edit2.set('Visible','off');
  handles.text3.set('Visible','off'); handles.edit3.set('Visible','off');
  handles.text4.set('String','Run Time: Inf');

case 1  % Random Squares

  handles.edit2.set('Value',1);
  handles.edit2.set('style','popupmenu');
  handles.edit2.Position(3) = 7.5;

  % Number of squares are any factor of ssiz, to ensure the number of
  % squares fit evenly in the field
  factors = compFact(handles.ssiz);
  for i = 1:min(length(factors),10)
    F{i} = factors(i);
  end

  handles.text1.set('Visible','on'); handles.edit1.set('Visible','on');
  handles.text1.set('String', 'Repititions'); handles.edit1.set('String','1');
  handles.text2.set('Visible','on'); handles.edit2.set('Visible','on');
  handles.text2.set('String', 'Num Squares:'); handles.edit2.set('String',F);
  handles.text3.set('Visible','off'); handles.edit3.set('Visible','off');

case 2 % RF Bars

  handles.edit2.set('Value',1);
  handles.edit2.set('style','popupmenu');
  handles.edit2.Position(3) = 7.5;

  % Number of squares are any factor of ssiz, to ensure the number of
  % squares fit evenly in the field
  factors = compFact(handles.ssiz);
  for i = 1:min(length(factors),10)
    F{i} = factors(i);
  end

  handles.text1.set('Visible','on'); handles.edit1.set('Visible','on');
  handles.text1.set('String', 'Repititions'); handles.edit1.set('String','1');
  handles.text2.set('Visible','on'); handles.edit2.set('Visible','on');
  handles.text2.set('String', 'Num Squares:'); handles.edit2.set('String',F);
  handles.text3.set('Visible','off'); handles.edit3.set('Visible','off');


case 3  % Brightness Levels

  handles.edit2.set('style','edit');
  handles.edit2.Position(3) = 7.5;

  handles.text1.set('Visible','on'); handles.edit1.set('Visible','on');
  handles.text1.set('String', 'Repititions:'); handles.edit1.set('String','10');
  handles.text2.set('Visible','on'); handles.edit2.set('Visible','on');
  handles.text2.set('String','Levels'); handles.edit2.set('String','10');
  handles.text3.set('Visible','off'); handles.edit3.set('Visible','off');


case 4  % Spatial Frequency

  handles.edit2.set('style','edit');
  handles.edit2.Position(3) = 7.5;

  handles.text1.set('Visible','on'); handles.edit1.set('Visible','on');
  handles.text1.set('String', 'Repititions:'); handles.edit1.set('String','10');
  handles.text2.set('Visible','on'); handles.edit2.set('Visible','on');
  handles.text2.set('Visible', 'off'); handles.edit2.set('Visible','off');
  handles.text3.set('Visible','off'); handles.edit3.set('Visible','off');


case 5  % Direction

  handles.edit2.set('Value',1);
  handles.edit2.set('style','popupmenu');
  handles.edit2.Position(3) = 7.5;

  F = {5,10,15,20,30,45,60,90};

  handles.text1.set('Visible','on'); handles.edit1.set('Visible','on');
  handles.text1.set('String', 'Repititions'); handles.edit1.set('String','1');
  handles.text2.set('Visible','on'); handles.edit2.set('Visible','on');
  handles.text2.set('String', 'Angles:'); handles.edit2.set('String',F);
  handles.text3.set('Visible','off'); handles.edit3.set('Visible','off');
  handles.edit12.set('String','1');

case 6 % Orientation

  handles.edit2.set('Value',1);
  handles.edit2.set('style','popupmenu');
  handles.edit2.Position(3) = 7.5;

  F = {5,10,15,20,30,45,60,90};

  handles.text1.set('Visible','on'); handles.edit1.set('Visible','on');
  handles.text1.set('String', 'Repititions'); handles.edit1.set('String','1');
  handles.text2.set('Visible','on'); handles.edit2.set('Visible','on');
  handles.text2.set('String', 'Angles:'); handles.edit2.set('String',F);
  handles.text3.set('Visible','off'); handles.edit3.set('Visible','off');

case 7 % Radii

  handles.edit2.set('style','edit');
  handles.edit2.Position(3) = 7.5;

  handles.text1.set('Visible','on'); handles.edit1.set('Visible','on');
  handles.text1.set('String', 'Repititions:'); handles.edit1.set('String','10');
  handles.text2.set('Visible','on'); handles.edit2.set('Visible','on');
  handles.text2.set('String','Levels'); handles.edit2.set('String','10');
  handles.text3.set('Visible','off'); handles.edit3.set('Visible','off');

case 8 % Looming

  handles.edit2.set('style','edit');
  handles.edit2.Position(3) = 7.5;

  handles.text1.set('Visible','on'); handles.edit1.set('Visible','on');
  handles.text1.set('String', 'Repititions:'); handles.edit1.set('String','10');
  handles.text2.set('Visible','on'); handles.edit2.set('Visible','on');
  handles.text2.set('String','Min obj size (pixels)'); handles.edit2.set('String','10');
  handles.text3.set('Visible','on'); handles.edit3.set('Visible','on');
  handles.text3.set('String','radius/velocity (s)'); handles.edit3.set('String','2');

case 9 % Moving Spatial Frequency

  handles.edit2.set('style','edit');
  handles.edit2.Position(3) = 7.5;

  handles.text1.set('Visible','on'); handles.edit1.set('Visible','on');
  handles.text1.set('String', 'Repititions:'); handles.edit1.set('String','10');
  handles.text2.set('Visible','on'); handles.edit2.set('Visible','on');
  handles.text2.set('Visible', 'off'); handles.edit2.set('Visible','off');
  handles.text3.set('Visible','off'); handles.edit3.set('Visible','off');
  handles.edit12.set('String','5');
  handles.edit13.set('String','2.5');
end



handles.factors = F;
handles.typ = typ;
handles = updateTime(hObject, eventdata, handles);
guidata(hObject,handles);




%% ---- Execution Buttons ---- %%

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close();

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles.folder = uigetdir();
if(handles.folder == 0)
  return;
end
handles.text9.set('String', ['Save to: ...' handles.folder(max(end-50,1):end)]);
guidata(hObject, handles);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.height = str2num(handles.edit8.String);   % Height of images
handles.width  = str2num(handles.edit9.String);   % Width of images
handles.buffer = str2num(handles.edit10.String);  % Offset from bottom
handles.ssiz   = str2num(handles.edit11.String);  % Size of display area
handles.lag1   = str2num(handles.edit12.String);  % Length of stimulus
handles.lag2   = str2num(handles.edit13.String);  % Length of pause
handles.Background = str2num(handles.edit15.String); % Background greyness
handles.Contrast   = str2num(handles.edit16.String); % Intesnity of stimulus wrt background

typ = handles.typ;
num = 1;
handles.circleRadius = 0;   % Initializes cricle radius to zero for all stimuli

switch typ

case 0    % Align

  Background = handles.Background;

  if(Background < 0.5)
    Sign = 1;
  else
    Sign = -1;
  end
%   try
%     s = daq.createSession('ni');
%     addAnalogOutputChannel(s,'Dev1','ao1','Voltage');
%   catch Last_Error
%     disp(getReport(Last_Error));
%   end
  figure('NumberTitle','off','MenuBar','none','toolbar','none','color',[Background, Background, Background],'DockControls','off');
  imshow(square({1, handles.ssiz, 1, handles.height, handles.width, handles.buffer,Sign,Background,handles.Contrast}),'border','tight','parent',gca);
  uiwait();
  return;

case 1    % Random Squares

  num = handles.factors{handles.edit2.Value};
  fois = str2num(handles.edit1.String);
  variables = [fois typ num];

case 2     % RF Bars

  num = handles.factors{handles.edit2.Value};
  fois = str2num(handles.edit1.String);
  variables = [fois typ num];

case 3    % Brightness Levels

  num = str2num(handles.edit2.String);
  fois = str2num(handles.edit1.String);
  variables = [fois typ num];

case 4    % Spatial Frequency

  num = length(compFact(str2num(handles.edit9.String)))-2;
  fois = str2num(handles.edit1.String);
  variables = [fois typ num];

case 5    % Direction

  num = handles.factors{handles.edit2.Value};
  fois = str2num(handles.edit1.String);
  variables = [fois typ num];

case 6    % Orientation

  num = handles.factors{handles.edit2.Value};
  fois = str2num(handles.edit1.String);
  variables = [fois typ num];

case 7    % Radii

  num = str2num(handles.edit2.String);
  fois = str2num(handles.edit1.String);
  variables = [fois typ num];

case 8    % looming

  num = str2num(handles.edit2.String);
  fois = str2num(handles.edit1.String);
  dv = str2num(handles.edit3.String);
  variables = [fois typ num dv];

case 9    % Spatial Frequency

  num = length(compFact(str2num(handles.edit9.String)))-2;
  fois = str2num(handles.edit1.String);
  variables = [fois typ num];

end
  
guidata(hObject,handles);

% Present stimuli
[data shade] = showStimuli(hObject, variables, handles);

%% ---- Edit callback function ---- %%

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


updateTime(hObject, eventdata, handles);
guidata(hObject,handles);


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if(handles.typ == 2 && str2num(handles.edit2.String) > floor(handles.ssiz/2))
%   handles.edit2.String = floor(handles.ssiz/2);
% end

updateTime(hObject, eventdata, handles);
guidata(hObject,handles);

function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.height = str2num(handles.edit8.String);
guidata(hObject,handles);

function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.width = str2num(handles.edit9.String);
guidata(hObject,handles);

function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.buffer = str2num(handles.edit10.String);
guidata(hObject,handles);

function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ssiz = str2num(handles.edit11.String);
guidata(hObject);
listbox1_Callback(hObject, eventdata, handles);

function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.lag1 = str2num(handles.edit12.String);

updateTime(hObject, eventdata, handles);
guidata(hObject,handles);

function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.lag2 = str2num(handles.edit13.String);

updateTime(hObject, eventdata, handles);
guidata(hObject,handles);



%% ---- Output Function ---- %%

% --- Outputs from this function are returned to the command line.
function varargout = RunExperiment_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function handles = updateTime(hObject, eventdata, handles)

  typ = handles.typ;

  if(typ == 0)
    return;
  end

  L = str2num(handles.edit1.String) * (str2num(handles.edit13.String) + str2num(handles.edit12.String));

  switch typ
  case 1
    L = L * (str2num(handles.edit2.String{handles.edit2.Value})^2+1);
  case 2
    L = L * (str2num(handles.edit2.String{handles.edit2.Value})*2+1);
  case {3,7}
    L = L * (str2num(handles.edit2.String)+1);  
  case 4
     L = L * length(compFact(str2num(handles.edit9.String)));
  case {5,6}
    L = L * (360/str2num(handles.edit2.String{handles.edit2.Value})+1);
  case 9
    L = L * (8+1);
  end

  L = L + 10;
  [Minutes Seconds] = mdivide(L,60);
  %[Minutes Seconds] = divide(L,60);
  
  handles.text4.set('String',['Run Time: ' leftpad(Minutes,2) ':' leftpad(ceil(Seconds),2)]);



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
