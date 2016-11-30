function t = plotStimulusView(hObject, eventData, handles);

x = handles.xaxis;
y = handles.yaxis;
z = handles.zaxis;
c = handles.colour;

value = handles.listbox3.get('Value');

Roi2Show = [];

if(value == 0)
	for i = 1:length(RoiData)
		if(sum(0 ~= RoiData(i).Responded))
			Roi2Show = [Roi2Show i];
		end
	end
end



c(:,:) = 0;

c(Roi2Show,:) = 255;

t = 1;


handles.axes1 = scatter3(x,y,z,50,c(:,t),'filled');
h = rotate3d;
set(h,'Enable','on');
set(gca,'ZDIR','reverse');
axis([0 512 0 512 0 handles.RoiData(length(handles.RoiData)).Coordinates(3)]); axis ij;

guidata(hObject, handles);