function t = plotSlice(hObject,handles,t,nowslice)

% This function plots the ROIs selected slice. Cousin to plot3D

handles.figure1.set('Visible','off');
handles.figure1.set('Visible','on');
handles.slider1.set('Visible','on');

x = handles.xaxis;
y = handles.yaxis;
z = handles.zaxis;
c = handles.colour;

S = (z == nowslice);
n = 0;

if(t < 0)
	Single_Roi = true;
	t = -t;
else
	Single_Roi = false;
end


% If there is a single ROI selected, all other values are zeroed
if(Single_Roi)
	n = handles.n;
	% if(handles.toggleValue == 0)
		c(:,:) = 0;
	% end
	c(:,n) = Inf;
end

% If threshold view is selected, coordiates are divided into 
% two sets: respnding and not responding
if(handles.toggleValue == 1 || handles.toggleValue == 3)

	L = c(t,:) > 0;

	% ROIs that both respond and are in selected slice
	for i = 1:length(L)
		M(i) = ~L(i) && S(i);
		N(i) = L(i) && S(i);
	end

	x2 = x(M);
	y2 = y(M);
	z2 = z(M);
	c2 = c(:,M);
	

	x = x(N);
	y = y(N);
	z = z(N);
	c = c(:,N);

else
	x = x(S);
	y = y(S);
	z = z(S);
	c = c(:,S);
end

% try
% 	% I = imread('Averaged Image.tif');
% 	% imshow(I,'Parent',handles.axes1); hold on;
% 	% CLim = get(gca,'CLim');
% 	if(~Single_Roi)
% 		c(t,:) = c(t,:) * CLim(2) / 1.5;
% 	end
% 	Background_Image = false;
% catch
% 	Background_Image = false;
% end


% Plots two sets of coordinates with colour values.
if(length(c(t,:)) > 0)

	% Fixes MATLAB bug which supresses display if there are only three point...
	if(length(c(t,:)) == 3)
		x(end+1) = x(end); y(end+1) = y(end); c(t,end+1) = c(t,end);
	end
	% handles.axes1 = 
	scatter(x,y,50,c(t,:),'filled','s'); hold on;
else

	% handles.axes1 = 
	scatter(1,1,0.1,1,'filled'); hold on;

end

if(handles.toggleValue == 1 || handles.toggleValue == 3)
	% handles.axes1 = 
	scatter(x2,y2,5,c2(t,:),'filled');
end

hold off;

try
	axis([0 handles.header.ImageWidth 0 handles.header.ImageHeight]); axis ij;
catch
	axis([0 512 0 512]); axis ij;
end

if(Single_Roi || handles.toggleValue ~= 2 && handles.toggleValue ~= 3)

	set(gca,'Color',[0.05 0.05 0.05]);
	colormap gray;

else
	colormap parula;
end

	

% Changes axis limits to reflect number of times stimulus was presented (Change to nonstatic)
if(handles.toggleValue == 2 || handles.toggleValue == 3)
	ax.CLim = [0 5];
else
	ax.Clim = [0 1.5];
end

t = getframe();