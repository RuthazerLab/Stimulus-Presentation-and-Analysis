function varargout = PlotRoiData(varargin)
% PLOTROIDATA creates a visual representation of ROI data from
% a 'Analyzed NAME'.mat file as create by the function EXTRACTDATA.
%
% See also: ANALYZEDATA, RUNEXPERIMENT 

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotRoiData_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotRoiData_OutputFcn, ...
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


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
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


% --- Sets defaults handle values.
function handles = createWorkspace(hObject, eventdata, handles)
	% Initializes values

	handles.n = 1;
	handles.prevPlot = 0;
	handles.CurrentSlice = 0;
	handles.CurrentTime = 1;
	handles.CurrentRoi = 1;
	handles.fig = figure;
	handles.toggleValue = 0;
	handles.Response_Center = 0;

	handles.radiobutton1.set('Value',0);
	handles.radiobutton2.set('Value',0);
	handles.listbox1.set('Value',1);
	handles.listbox2.set('Value',1);
	handles.fig.set('Visible','off');
	handles.pushbutton8.set('Visible','off');

	handles.prevView = [-37.5 30];
	handles.RoiCount = [];
	handles.Times = [];
	handles.xaxis = [];
	handles.yaxis = [];
	handles.zaxis = [];
	handles.colour = [];
	handles.cc = [];
	rotate3d on;


% --- Executes just before PlotRoiData is made visible.
function PlotRoiData_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlotRoiData (see VARARGIN)

	handles = createWorkspace(hObject, eventdata, handles);

	handles.output = hObject;

	warning('off','MATLAB:handle_graphics:exceptions:SceneNode');
	warning('off','MATLAB:hg:uicontrol:ValueMustBeWithinStringRange');
	warning('off','MATLAB:hg:uicontrol:ValueMustBeScalar');

	guidata(hObject, handles);

	% If this function is called with input of a filepath, directly
	% load that file.
	if(nargin == 4)
		pushbutton1_Callback(hObject,eventdata,handles,varargin{1});
	end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles, file)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Handles case where this function is called by the opening function
	if(nargin == 4)
		[Path Data] = fileparts(file);
	else
		[Data Path] = uigetfile('*.mat');
	end

	% If no file was selected, return.
	if(Data == 0)
	    return;
	end

	load(fullfile(Path,Data));

	% Inizializes variables, because apparently I didn't figure out 
	% hObject and guidata well enough.
	handles.AnalysedData = AnalysedData;
	handles.RoiData = RoiData;
	handles.header = header;
	handles.StimulusData = StimulusData;
	handles.Responses = StimulusData.Responses;
	handles = createWorkspace(hObject, eventdata, handles);

	% Shows where stimuli occur on time slider
	dispStimTimes(hObject,eventdata,handles);

	% Inizializes listbox fields
	data = {'All Slices'};
	for i = 1:RoiData(length(RoiData)).Coordinates(3)
		handles.RoiCount(i) = getRoiCount(RoiData,i);
		data = [data; {['Slice ', int2str(i)]}];
	end
	handles.listbox1.String = data;

	data = {'All Rois'};
	for i = 1:length(handles.RoiData)
		data = [data; {['ROI ', int2str(i)]}];
	end
	handles.listbox2.String = data;
	handles.listbox2.set('Value',1);

	% Shows name of file opened
	handles.text2.String = header.FileName;

	% loads coordinates of data
	for i = 1:length(RoiData)
		x(i) = RoiData(i).Coordinates(1,1);
		y(i) = RoiData(i).Coordinates(2,1);
		z(i) = RoiData(i).Coordinates(3,1);
		c(i,:) = max(0,AnalysedData.dFF0(i,:));
	end
	c = transpose(c);
	handles.xaxis = x;
	handles.yaxis = y;
	handles.zaxis = z;
	handles.colour = c;

	% Finds time difference between each slice.
	t = handles.CurrentTime;
	handles.Times = uniqueElements(handles.AnalysedData.Times(:,t));
	
	% Initializes time slider
	frames = length(RoiData(1).Brightness);
	handles.slider1.set('Max',frames);
	handles.slider1.set('Min',t);
	handles.slider1.set('value',t);
	handles.slider1.set('SliderStep', [1/(frames-1), 1/(frames-1)]);
	handles.text4.String = t;
	handles.text6.String = ['Times: ' num2str(handles.Times(1)) ' to ' num2str(handles.Times(end))];
	handles.text6.Visible = 'on';
	
	% Plots data for all slices
	plot3D(hObject,handles,t); handles.prevPlot = 1;

	handles.ax = gca;

	guidata(hObject, handles);


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

	% Finds which slice and time is currently selected
	nowslice = get(handles.listbox1,'value') - 1;
	t = handles.CurrentTime;

	% Updates which slice is selected.
	handles.CurrentSlice = nowslice;

	% If slice is selected, plot that slice, else plot all of them.
	if(nowslice > 0)
		plotSlice(hObject,handles,t,nowslice); handles.prevPlot = 0;
	else 
		plot3D(hObject, handles,t); handles.prevPlot = 1;
	end

	% Updates listbox data
	if(nowslice == 0)

		% If thresholded, update ROI list to only responding ROIs
		if(handles.toggleValue == 1 || handles.toggleValue == 3)
			handles = updateRoiList(hObject,eventdata,handles);
		else
			data = {'All ROIs'};
			for i = 1:sum(handles.RoiCount)
				data = [data; {['ROI ', int2str(i)]}];
			end
			handles.listbox2.String = data;

			handles.slider1.set('Visible','on');
			handles.text4.String = t; handles.text3.String = 'Frame: ';
		end

	else

		% Update ROI list to only responding ROIs
		if(handles.toggleValue == 1 || handles.toggleValue == 3)
			handles = updateRoiList(hObject,eventdata,handles);
		else
			roinum = sum(handles.RoiCount(1:nowslice-1));

			data = {'All ROIs'};
			for i = 1:handles.RoiCount(nowslice)
				data = [data; {['ROI ', int2str(roinum +i)]}];
			end
			handles.listbox2.String = data;

			% Updates time to correct slice-specific time
			handles.text4.String = handles.Times(nowslice); handles.text3.String = 'Time: ';
		end
	end

	% Resets second listbox selects to 'All ROIs'
	% handles.listbox2.set('Value',1);

	% Update the time for presented data.
	updateTime(hObject,eventdata,handles);

	guidata(hObject, handles);



% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

	% Gets the roi, slice, and time that is currently selected.
	nowROI = get(handles.listbox2,'value') - 1;
	nowslice = handles.CurrentSlice;
	t = ceil(get(handles.slider1,'Value'));

	% If 'All ROIs' is selected, display all of them, otherwise adjust
	% the plot to display selected ROI in yellow and plot dFF0 data for
	% that ROI
	if(nowROI == 0)

		if(nowslice == 0)
			plot3D(hObject, handles,t); handles.prevPlot = 1;
		else
			plotSlice(hObject,handles,t,nowslice); handles.prevPlot = 0;
		end

	else
		% Parse the ROI number from listbox
		roi = handles.listbox2.String(nowROI+1);
		roi = strsplit(roi{1},' ');
		n = str2num(roi{2});

		% Checks to see if there is a figure open, and, if not, creates one
		if(~isfield(handles,'fig'))
			handles.fig = figure;
			handles.fig.set('Visible','on');
		else
			try
				if(~strcmp(handles.fig.Visible,'on'))
					handles.fig.set('Visible','on');
				end
			catch
				rmfield(handles,'fig');
				handles.fig = figure;
				if(~strcmp(handles.fig.Visible,'on'))
					handles.fig.set('Visible','on');
				end
			end
		end


		set(0,'CurrentFigure',handles.fig);

		% If you have heatmap on, plot receptivity field instead of dFF0 data
		if(handles.toggleValue == 2 || handles.toggleValue == 3)
			if(handles.StimulusData.Configuration.Type == 1 || handles.StimulusData.Configuration.Type == 2)
				getRFMap(n,handles.RoiData,handles.StimulusData.Configuration);
				ax = gca;
			else
				bar(handles.RoiData(n).XCor);
			end
		else		
			YMAX = 20*median(handles.AnalysedData.dFF0(n,:));
			bar(handles.StimulusData.Times,YMAX/5*handles.StimulusData.Raw(:,3)/max(handles.StimulusData.Raw(:,3)),0.05);
			hold on;
			bar(handles.StimulusData.Times,-YMAX/5*handles.StimulusData.Raw(:,3)/max(handles.StimulusData.Raw(:,3)),0.05,'r');
			% plot(handles.AnalysedData.Times(n,:),((handles.AnalysedData.dFF0(n,:)-mean(handles.AnalysedData.dFF0(n,:)))/std(handles.AnalysedData.dFF0(n,:))));
			plot(handles.AnalysedData.Times(n,:),((handles.AnalysedData.dFF0(n,:))));
			hold off;
			xlabel('Time');
			ylabel('dF/F0');
			title(strcat('Region of Interest number ',int2str(n)));
			% ylim([0 max(1,YMAX)]); 
			xlim([0 handles.AnalysedData.Times(n,end)]);
			h = zoom;
			h.motion = 'horizontal';
		end

		% Saves current ROI number that is selected
		handles.n = n;
		guidata(hObject,handles);

		% Plots data with ROI selected
		if(nowslice == 0)
			plot3D(hObject,handles,-t); handles.prevPlot = 1;
		else
			plotSlice(hObject,handles,-t,nowslice); handles.prevPlot = 0;
		end

	end

	% Updates current ROI that is selected
	handles.CurrentRoi = nowROI;

	guidata(hObject, handles);



% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Get current value
	t = get(handles.slider1,'Value');

	% Rounds value to appropriate time.
	if(t > handles.slider1.Max - 1)
		t = handles.slider1.Max - 1;
	elseif (t < handles.slider1.Min + 1);
		t = handles.slider1.Min + 1;
	end
	if(t > handles.CurrentTime)
		t = ceil(t);
	else
		t = floor(t);
	end
	
	% Set slider to adjusted time
	handles.slider1.set('Value',t);

	% Saves current time
	handles.CurrentTime = t;
	guidata(hObject,handles);

	updateTime(hObject,eventdata,handles);

	% Plots updated time data
	listbox1_Callback(hObject, eventdata, handles);


	% Update ROI list to only responding ROIs
	% if(handles.toggleValue == 1 || handles.toggleValue == 3)
	% 	handles = updateRoiList(hObject,eventdata,handles);
	% end


function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Get unique state of the two radio buttons
toggleValue = handles.radiobutton1.get('Value') + 2*handles.radiobutton2.get('Value');
handles.pushbutton8.set('Visible','off');

[RC TC] = size(handles.AnalysedData.dFF0);

switch toggleValue

% No setting selected
case 0

	c(:,:) = max(0,handles.AnalysedData.dFF0(:,:));

% Thresholding is selected
case 1

	% Caluclates thresholded data at first instance and saves results
	if(isempty(handles.cc))

		for i = 1:RC
			c(i,:) = repmat(handles.AnalysedData.Responsive(i),[1 TC]);
		end
		handles.cc = c;
	else
		c = handles.cc;
	end

% Heatmap is selected
case 2

	handles.pushbutton8.set('Visible','on');

	% Sets colour to center to receptive field (yellow for lower and blue for higher verticle centers)
	for i = 1:RC
		colour = handles.RoiData(i).RFmu;
		try
			c(i,1) = colour(handles.Response_Center+1);
		catch
			c(i,1) = 0;
		end
	end

	c = repmat(c,[1 TC]);

% Both Heatmap and Thresholding are selected
case 3

	handles.pushbutton8.set('Visible','on');

	if(isempty(handles.cc))
		for i = 1:RC
			c(i,:) = repmat(handles.AnalysedData.Responsive(i),[1 TC]);
		end
	else
		c = handles.cc;
	end

	for i = 1:RC
		colour = handles.RoiData(i).RFmu;
		for j = 1:TC
			if(c(i,j) > 0.9999)
				try
					c(i,j) = colour(handles.Response_Center+1);
				catch
					c(i,j) = 0;
				end
			end
		end
	end

end

handles.colour = transpose(c);
handles.toggleValue = toggleValue;

guidata(hObject, handles);

% Updates graphs
listbox1_Callback(hObject, eventdata, handles)
listbox2_Callback(hObject, eventdata, handles)




% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% See radiobutton1_Callback %%

toggleValue = handles.radiobutton1.get('Value') + 2*handles.radiobutton2.get('Value');
handles.pushbutton8.set('Visible','off');

[RC TC] = size(handles.AnalysedData.dFF0);


switch toggleValue

case 0

	c(:,:) = max(0,handles.AnalysedData.dFF0(:,:));

case 1

	if(isempty(handles.cc))
		for i = 1:RC
			c(i,:) = repmat(handles.AnalysedData.Responsive(i),[1 TC]);
		end
	else
		c = handles.cc;
	end

case 2

	handles.pushbutton8.set('Visible','on');
	for i = 1:RC
		colour = handles.RoiData(i).RFmu;
		try
			
			c(i,1) = colour(handles.Response_Center+1);
		catch
			c(i,1) = 0;
		end
	end

	c = repmat(c,[1 TC]);

case 3

	handles.pushbutton8.set('Visible','on');
	if(isempty(handles.cc))
		for i = 1:RC
			c(i,:) = repmat(handles.AnalysedData.Responsive(i),[1 TC]);
		end
		handles.cc = c;
	else
		c = handles.cc;
	end

	for i = 1:RC
		colour = handles.RoiData(i).RFmu;
		for j = 1:TC
			if(c(i,j) > 0.9999)
				try
					
					c(i,j) = colour(handles.Response_Center+1);
				catch
					c(i,j) = 0;
				end
			end
		end
	end

end

handles.colour = transpose(c);
handles.toggleValue = toggleValue;

guidata(hObject, handles);

listbox1_Callback(hObject, eventdata, handles)
listbox2_Callback(hObject, eventdata, handles)


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Turns on data cursor mode
handles.dcm_obj = datacursormode(handles.figure1);
set(handles.dcm_obj,'Enable','on','UpdateFcn',{@dcm_UpdateFunction,hObject})

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Turns on rotate mode
rotate3d(handles.axes1);

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Label_Options = {'Vertical','Horizontal'};

handles.Response_Center = mod(handles.Response_Center+1,2);
hObject.set('String',Label_Options(handles.Response_Center+1));

guidata(hObject,handles);


radiobutton2_Callback(hObject,eventdata,handles);




% --- Outputs from this function are returned to the command line.
function varargout = PlotRoiData_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;



% --- Updates the information when a data point is selected
function txt = dcm_UpdateFunction(~,event_obj,hObject)

try
handles = guidata(hObject);

pos = get(event_obj,'Position');

if(length(pos) == 2)
	pos(3) = get(handles.listbox1,'value') - 1;
end

txt = ['(' num2str(pos(1)) ', ' num2str(pos(2)) ',' num2str(pos(3)) ')'];

for i = 1:length(handles.RoiData)
	if(sum(round(handles.RoiData(i).Coordinates,0) == round(transpose(pos),0)) == 3)
		CC = round(handles.RoiData(i).Coordinates,1);
		txt = ['Roi ' int2str(i)];
		break;
	end
end


n = find(strcmpi(txt, handles.listbox2.String));
handles.listbox2.set('Value',n);

n = i;

txt = {['Roi ' int2str(i)], ['(' num2str(CC(1)) ',' num2str(CC(2)) ',' num2str(CC(3)) ')']};


figHandles = get(0,'Children');

if(length(figHandles) > 0)
	handles.fig = figHandles(1);
	handles.fig.set('Visible','on');
else
	handles.fig = figure;
	handles.fig.set('Visible','on');
end

set(0,'CurrentFigure',handles.fig);

if(handles.toggleValue == 2 || handles.toggleValue == 3)
	if(handles.StimulusData.Configuration.Type == 1 || handles.StimulusData.Configuration.Type == 2)
		getRFMap(n,handles.RoiData,handles.StimulusData.Configuration);
		colorbar;
		ax = gca;
	else
		bar(handles.RoiData(n).XCor);
	end
else		
	YMAX = 20*median(handles.AnalysedData.dFF0(n,:));
	bar(handles.StimulusData.Times,YMAX/5*handles.StimulusData.Raw(:,3)/max(handles.StimulusData.Raw(:,3)),0.05);
	hold on;
	bar(handles.StimulusData.Times,-YMAX/5*handles.StimulusData.Raw(:,3)/max(handles.StimulusData.Raw(:,3)),0.05,'r');
	plot(handles.AnalysedData.Times(n,:),((handles.AnalysedData.dFF0(n,:)-mean(handles.AnalysedData.dFF0(n,:)))/std(handles.AnalysedData.dFF0(n,:))));
	hold off;
	xlabel('Time');
	ylabel('dF/F0');
	title(strcat('Region of Interest number ',int2str(n)));
	% ylim([0 max(1,YMAX)]);
	xlim([0 handles.AnalysedData.Times(n,end)]);
	h = zoom;
	h.motion = 'horizontal';
end


guidata(hObject,handles);
catch
	lasterror
end

% --- Updates the RoiList wrt the activated ROI
function handles = updateRoiList(hObject, eventdata, handles)

c = handles.colour;
t = ceil(get(handles.slider1,'Value'));

data = {'All ROIs'};
if(handles.CurrentSlice == 0)
	for i = 1:sum(handles.RoiCount)
		if(c(t,i) > 0)
			data = [data; {['ROI ', int2str(i)]}];
		end
	end
else
	roinum = sum(handles.RoiCount(1:handles.CurrentSlice-1));

	for i = 1:handles.RoiCount(handles.CurrentSlice)
		if(c(t,roinum+i) > 0)
			data = [data; {['ROI ', int2str(roinum +i)]}];
		end
	end
end

handles.listbox2.String = data;


% --- Updates time/frame value 
function updateTime(hObject,eventdata,handles)

t = handles.CurrentTime;

handles.Times = uniqueElements(handles.AnalysedData.Times(:,t));

A = handles.StimulusData.Times > handles.Times(1);
B = handles.StimulusData.Times < handles.Times(end) + 0.2;
for i = 1:length(A)
	C(i) = A(i) && B(i);
end

if(sum(C) ~= 0)
	handles.axes3.set('Visible','on');
else
	handles.axes3.set('Visible','off');
end


if(handles.CurrentSlice == 0)
	handles.text3.String = 'Frame: ';
	handles.text4.String = t;
	handles.text6.String = ['Times: ' num2str(handles.Times(1)) ' to ' num2str(handles.Times(end))];
	handles.text6.Visible = 'on';
else
	handles.text3.String = 'Time: ';
	handles.text6.Visible = 'off';
	try
		handles.text4.String = handles.Times(handles.CurrentSlice);
	catch
		handles.Times(handles.CurrentSlice) = handles.Times(end);
		handles.text4.String = handles.Times(handles.CurrentSlice);
	end

end

guidata(hObject,handles);



function dispStimTimes(hObject,eventdata,handles)

T = transpose(handles.StimulusData.Times);

handles.axes2.set('Visible','on');

axes(handles.axes2);
axis([0 handles.header.TimeLapse 0 1]);
axis off;
hold on;
for i = 1:length(T)
	plot([T(i) T(i)],[0 1]);
end

axes(handles.axes1);


guidata(hObject,handles);


