subplot(2,1,2); 
% stem(StimulusData.Times,StimulusData.Raw(:,3),'Marker','none');

for i = 1:110
	Temp(:,i) = StimulusData.Vector(:,i)*StimulusData.Raw(i,3);
end

StimulusVector = sum(Temp');

bar(AnalysedData.Times(1,:),StimulusVector,1);

set(get(gca,'XAxis'),'Limits',[0 AnalysedData.Times(1,end)])
set(get(get(gca,'YAxis'),'Label'),'String','Stimulus')
set(get(get(gca,'XAxis'),'Label'),'String','Time')

subplot(2,1,1); 
imagesc(AnalysedData.Times(1,:),[1:header.RoiCount],AnalysedData.dFF0)
set(get(get(gca,'YAxis'),'Label'),'String','Roi')
set(gca,'CLim',[0 2]);
disp('CLim: set(gca,''Clim'',[0 2]);');