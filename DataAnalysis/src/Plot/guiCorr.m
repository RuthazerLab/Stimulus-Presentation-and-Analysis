function guiCorr(Folder,Slice)

[Path ExperimentName] = fileparts(Folder);
fileName = ['Analysed ' ExperimentName '.mat'];

load(fullfile(Folder,fileName));

R = corrcoef(AnalysedData.dFF0(:,100:end)');

S = AnalysedData.RoiCoords(3,:) == Slice;
T = find(S);

header.RoiMask{Slice} = getRoiMask(Folder,Slice);


A = zeros(512,512);
for i = 1:sum(S)
	for p = 1:length(header.RoiMask{Slice}{i,1});
		A(min(max(header.RoiMask{Slice}{i,2}(p),1),512),min(max(header.RoiMask{Slice}{i,1}(p),1),512)) = 1;
	end
end

fig = figure;

% subplot(1,2,1);
H = imagesc(A);
axis square;

while true
	userpoint = round(ginput(1));
	I = 0;
	for i = 1:sum(S)
		for p = 1:length(header.RoiMask{Slice}{i,1});
			if(min(max(header.RoiMask{Slice}{i,2}(p),1),512) == userpoint(2) && min(max(header.RoiMask{Slice}{i,1}(p),1),512) == userpoint(1))
				I = i + T(1) -1;
				break;
			end
		end
	end
	if(I == 0)
		close(fig)
		return;
	end

	A = zeros(512,512);
	for i = 1:sum(S)
		for p = 1:length(header.RoiMask{Slice}{i,1});
			A(min(max(header.RoiMask{Slice}{i,2}(p),1),512),min(max(header.RoiMask{Slice}{i,1}(p),1),512)) = max(R(I,i+T(1)-1),0.4);
		end
	end

	set(H,'CData',A);
	set(gca,'CLim',[0.3 1]);
	% subplot(1,2,2);
	% plot(AnalysedData.Times(I,:),AnalysedData.dFF0(I,:)); title(['Roi ' int2str(I)])
	% Y = get(gca,'YTick')';
	% hold on;
	% for i = 1:size(StimulusData.Raw,1)
	% 	line([StimulusData.Raw(i,2) StimulusData.Raw(i,2)],[Y(1) Y(1)+StimulusData.Raw(i,3)*(Y(2)-Y(1))],'color','r');
	% end
	

	% for i = 1:AnalysedData.Times(I,end)/20:AnalysedData.Times(I,end)
	% 	line([(i-1) AnalysedData.Times(I,end)/20+i],[Y(end-1)+i/AnalysedData.Times(I,end)*(Y(end)-Y(end-1)) Y(end-1)+i/AnalysedData.Times(I,end)*(Y(end)-Y(end-1))],'color','g');
	% end

	% hold off;
	


end