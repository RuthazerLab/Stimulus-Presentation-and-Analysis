function t = plot3D(hObject, handles, t);

% This function plots the ROIs in a 3D graph, i.e. no slice was selected. Cousin to plotSlice

handles.figure1.set('Visible','off');
handles.figure1.set('Visible','on');
handles.slider1.set('Visible','on');

c = handles.colour;
x = handles.xaxis;
y = handles.yaxis;
z = handles.zaxis;

n = 0;

% If there is a single ROI selected, all other values are zeroed
if(t < 0)
	t = -t;
	n = handles.n;
	if(handles.toggleValue == 0 || handles.toggleValue == 2)
		c(:,:) = 0;
	end
	c(:,n) = 100*max(max(c(t,:)))+1;
end

% If threshold view is selected, coordiates are divided into 
% two sets: respnding and not responding
if(handles.toggleValue == 1 || handles.toggleValue == 3)

	L = c(t,:) > 0.99;

	x2 = x(~L);
	y2 = y(~L);
	z2 = z(~L);
	c2 = c(:,~L);


	x = x(L);
	y = y(L);
	z = z(L);
	c = c(:,L);
end

% Insures data plots to the correct axes
if(handles.prevPlot)
	handles.prevView = get(gca,'view');
end


% Plots two sets of coordinates with colour values.
if(length(c) > 0)

	% Fixes MATLAB bug which supresses display if there are only three point...
	if(length(c(t,:)) == 3)
		x(end+1) = x(end); y(end+1) = y(end); z(end+1) = z(end); c(t,end+1) = c(t,end);
	end	
	scatter3(x,y,z,30,c(t,:),'filled'); hold on;

else

	handles.axes1 = scatter3(1,1,1,0.1,1,'filled'); hold on;

end

if(handles.toggleValue == 1 || handles.toggleValue == 3)
	handles.axes1 = scatter3(x2,y2,z2,5,c2(t,:),'filled');
end

hold off;
set(gca,'ZDIR','reverse');
axis([0 512 0 512 1 handles.RoiData(length(handles.RoiData)).Coordinates(3)]); 
set(get(gca,'ZAxis'),'TickValues',[1:handles.RoiData(length(handles.RoiData)).Coordinates(3)])
set(get(gca,'XAxis'),'TickValues',[0:512/4:512]);
set(get(gca,'YAxis'),'TickValues',[0:512/4:512]);
set(get(gca,'XAxis'),'TickLabels',{0:20:80});
set(get(gca,'YAxis'),'TickLabels',{0:20:80});

try

	% xlabel = get(gca,'XTickLabel');
	% ylabel = get(gca,'YTickLabel');
	% zlabel = get(gca,'ZTickLabel');
	% for i = 1:length(xlabel)
	% 	newxlabel{i} = round(str2num(xlabel{i})*handles.header.fieldSize/512,0);
	% 	newylabel{i} = round(str2num(ylabel{i})*handles.header.fieldSize/512,0);
	% end
	% for i = 1:length(zlabel)
	% 	newzlabel{i} = handles.header.zStart*1000+(i-1)*handles.header.zScale;
	% end
	% set(gca,'ZTickLabel',newzlabel);
	% set(gca,'XTickLabel',newxlabel);
	% set(gca,'YTickLabel',newylabel);
	% axis ij;
catch
	axis([0 512 0 512 0 handles.RoiData(length(handles.RoiData)).Coordinates(3)]); 
end
axis ij; set(gca,'view',handles.prevView);

colormap('default')


if(handles.toggleValue == 1)
	set(gca,'CLim',[0.99 1]);
end

if(handles.toggleValue == 2 || handles.toggleValue == 3)
	for i = 1:length(handles.RoiData)
		Center(i,:) = handles.RoiData(i).RFmu;
	end
	m = mean(Center(~isnan(Center(:,handles.Response_Center+1)),handles.Response_Center+1));
	s = std(Center(~isnan(Center(:,handles.Response_Center+1)),handles.Response_Center+1));
	set(gca,'CLim',[m-2*s m+2*s]);
end