function compareRoiPlots(n,m,Path)

[Path Folder] = fileparts(Path);
load(['Analysed ' Folder '.mat']);

subplot(1,1,1); cla; hold off;

subplot(2,3,1); 
	plot(AnalysedData.Times(n,:),AnalysedData.dFF0(n,:))
	xlim([0 AnalysedData.Times(n,end)])
	get(gca,'YLabel'); 
	set(ans,'String',['ROI' int2str(n)]);
	title(['Response dF/F0']);
subplot(2,3,4);
	plot(AnalysedData.Times(m,:),AnalysedData.dFF0(m,:))
	xlim([0 AnalysedData.Times(m,end)])
	get(gca,'YLabel'); 
	set(ans,'String',['ROI' int2str(m)]);
	get(gca,'XLabel');
	set(ans,'String','Time (s)');

subplot(2,3,2);
	bar([0:16],StimulusData.Responses(:,n));
	hold on;
	bar([0:16], [RoiData(n).ControlResponse zeros(1,16)],'r');
	xlim([-1 17]);
	title(['Response X Stimulus Coefficient']);

subplot(2,3,5);
	bar([0:16],StimulusData.Responses(:,m));
	hold on;
	bar([0:16], [RoiData(m).ControlResponse zeros(1,16)],'r');
	get(gca,'XLabel');
	set(ans,'String','Square Number');
	xlim([-1 17]);

subplot(2,3,3);
	imagesc(reshape(StimulusData.Responses(2:end,n),[4 4])- StimulusData.Responses(1,n)/std(AnalysedData.dFF0(n,:)));
	colorbar;
	set(gca,'CLim',[0 2])
	set(gca,'XTick',[]);
	set(gca,'YTick',[]);
	title(['Response Heatmap']);
	axis square;

subplot(2,3,6);
	imagesc(reshape(StimulusData.Responses(2:end,m),[4 4])- StimulusData.Responses(1,m)/std(AnalysedData.dFF0(m,:)));
	colorbar;
	set(gca,'CLim',[0 2])
	set(gca,'XTick',[]);
	set(gca,'YTick',[]);
	axis square;