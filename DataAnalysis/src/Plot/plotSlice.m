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
	CC = c(1,n);
	c(:,n) = 0;
	X = x;
	Y = y;
	Z = y;
end

% If threshold view is selected, coordiates are divided into 
% two sets: respnding and not responding
if(handles.toggleValue == 1 || handles.toggleValue == 3)
	L = c(t,:) > 0.99;

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

figure(1);


% Plots two sets of coordinates with colour values.
if(length(c(t,:)) > 0)

	% Fixes MATLAB bug which supresses display if there are only three point...
	if(length(c(t,:)) == 3)
		x(end+1) = x(end); y(end+1) = y(end); c(t,end+1) = c(t,end);
	end
	if(Single_Roi)
		scatter(X(n),Y(n),100,CC,'filled','d');
	end
	scatter(x,y,50,c(t,:),'filled'); hold on;
	
else

	scatter(1,1,0.1,1,'filled'); hold on;

end

if(handles.toggleValue == 1 || handles.toggleValue == 3)
	if(Single_Roi)
		scatter(X(n),Y(n),100,CC,'filled','d');
	end
	scatter(x2,y2,5,c2(t,:),'filled');

end

hold off;

axis([0 handles.header.ImageWidth 0 handles.header.ImageHeight]); axis ij;

try
	% xlabel = get(gca,'XTickLabel');
	% ylabel = get(gca,'YTickLabel');
	% for i = 1:length(xlabel)
	% 	newxlabel{i} = round(str2num(xlabel{i})*handles.header.fieldSize/512);
	% 	newylabel{i} = round(str2num(ylabel{i})*handles.header.fieldSize/512);
	% end
	% set(gca,'XTickLabel',newxlabel);
	% set(gca,'YTickLabel',newylabel);
	% axis ij;
catch
	
end

if(Single_Roi || handles.toggleValue ~= 2 && handles.toggleValue ~= 3)

	% set(gca,'Color',[0.05 0.05 0.05]);
	% colormap gray;

else
	colormap parula;
end

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

t = getframe();