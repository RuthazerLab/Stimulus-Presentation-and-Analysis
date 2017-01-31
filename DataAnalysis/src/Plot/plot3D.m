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

	L = c(t,:) > 0;

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
	handles.axes1 = scatter3(x,y,z,30,c(t,:),'filled'); hold on;

else

	handles.axes1 = scatter3(1,1,1,0.1,1,'filled'); hold on;

end

if(handles.toggleValue == 1 || handles.toggleValue == 3)
	handles.axes1 = scatter3(x2,y2,z2,5,c2(t,:),'filled');
end

hold off;
set(gca,'ZDIR','reverse');
try
	axis([0 handles.header.ImageWidth 0 handles.header.ImageHeight 0 handles.RoiData(length(handles.RoiData)).Coordinates(3)]); 
catch
	axis([0 512 0 512 0 handles.RoiData(length(handles.RoiData)).Coordinates(3)]); 
end
axis ij; set(gca,'view',handles.prevView);

colormap('default')

% Changes axis limits to reflect number of times stimulus was presented (Change to nonstatic)
if(handles.toggleValue == 2 || handles.toggleValue == 3)
	ax.CLim = [1 5];
else
	ax.CLim = [mean(prctile(c,10)) mean(prctile(c,90))];
end