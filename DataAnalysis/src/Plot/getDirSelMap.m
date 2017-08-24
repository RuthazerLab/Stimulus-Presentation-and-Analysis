function getDirSelMap(Folder)

[a FishName] = fileparts(Folder);

load(fullfile(Folder,['Analysed ' FishName]));

A = ones(512,512,3,4,4);

RoiCount(1) = 0;
for i = 1:4
	RoiCount(i+1) = length(header.RoiMask{i});
end

for i = 1:length(RoiData)
	SD(i) = find(AnalysedData.ZScore(i,:) == max(AnalysedData.ZScore(i,:)));
	SI(i) = 1-min(AnalysedData.Responses(i,:)/max(AnalysedData.Responses(i,:)));

	[Quad b] = mdivide(SD(i)-1,3);
	Quad = Quad+1;
	Dir = b + 1;
	switch Dir
		case 1
			cmp = [0 0 1]*(SI(i)-0.4)/(0.8-0.4);
		case 2
			cmp = [1 1 0]*(SI(i)-0.4)/(0.8-0.4);
		case 3
			cmp = [1 0 0]*(SI(i)-0.4)/(0.8-0.4);
	end
	temp = RoiData(i);
	Slice = temp.Coordinates(3);

	XPoints = max(min(header.RoiMask{Slice}{i-sum(RoiCount(1:Slice)),1},512),1);
	YPoints = max(min(header.RoiMask{Slice}{i-sum(RoiCount(1:Slice)),2},512),1);

	for k = 1:length(XPoints)


		A(YPoints(k),XPoints(k),:,Slice,:) = repmat(permute([0 0 0],[1 3 2 4 5]),[1 1 1 1 4]);
		A(YPoints(k),XPoints(k),:,Slice,Quad) = cmp;

	end
end



for Slice = 1:4
	Fig = figure(1);
	for i = 1:4
		subplot(2,2,i); imagesc(A(:,:,:,Slice,i)); axis square
		colormap([0 0 1; 1 1 0; 1 0 0]);
		H = colorbar;
		set(H,'YTick',[0 0.5 1]);
		set(H,'YTickLabel',[30 60 90]+90*(i-1));
		set(get(gca,'XAxis'),'Visible','off');
		set(get(gca,'YAxis'),'Visible','off');
	end
	if(~exist(fullfile('E:\Data\ToCynthia',FishName)))
		mkdir(fullfile('E:\Data\ToCynthia',FishName));
	end
	FigName = ['Slice' int2str(Slice) 'DirectionSelective'];
	saveas(Fig,fullfile('E:\Data\ToCynthia',FishName,FigName));
end

