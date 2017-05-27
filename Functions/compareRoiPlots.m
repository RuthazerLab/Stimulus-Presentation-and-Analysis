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
	bar(RoiData(n).XCor);
	title(['Response X Stimulus Coefficient']);

subplot(2,3,5);
	bar(RoiData(m).XCor);
	title(['Response X Stimulus Coefficient']);

% subplot(2,3,3);
% 	imagesc(reshape(StimulusData.Responses(2:end,n),[4 4])- StimulusData.Responses(1,n)/std(AnalysedData.dFF0(n,:)));
% 	colorbar;
% 	set(gca,'CLim',[0 2])
% 	set(gca,'XTick',[]);
% 	set(gca,'YTick',[]);
% 	title(['Response Heatmap']);
% 	axis square;

% subplot(2,3,6);
% 	imagesc(reshape(StimulusData.Responses(2:end,m),[4 4])- StimulusData.Responses(1,m)/std(AnalysedData.dFF0(m,:)));
% 	colorbar;
% 	set(gca,'CLim',[0 2])
% 	set(gca,'XTick',[]);
% 	set(gca,'YTick',[]);
% 	axis square;