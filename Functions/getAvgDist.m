function getAvgDist(Folder)

[a FishName] = fileparts(Folder);

load(fullfile(Folder,['Analysed ' FishName]));

for i = 1:length(RoiData)
	SD(i) = find(AnalysedData.ZScore(i,:) == max(AnalysedData.ZScore(i,:)));
	SI(i) = 1-min(AnalysedData.Responses(i,:)/max(AnalysedData.Responses(i,:)));
	temp = RoiData(i);
	Coord(i,:) = temp.Coordinates;
end

Conv = [80/512 80/512 15];

for i = 1:length(RoiData)
	N{i} = find(and(SD==SD(i),(Coord(:,3) == Coord(i,3))'));
	for j = 1:length(RoiData)
		d(i,j) = sqrt(sum(((Coord(i,:)-Coord(j,:)).*Conv).^2));
	end
end

Mean_Nghbr_Dist = cell(length(uniqueElements(SD)),5);

for i = 1:length(RoiData)
	[D n] = sort(d(i,N{i}),'ascend');
	len = length(D);
	for Trunc = 10:10:50
		Mean_Dist = mean(D(1:min(len,Trunc)));
		Mean_Nghbr_Dist{SD(i),Trunc/10} = [Mean_Nghbr_Dist{SD(i),Trunc/10} Mean_Dist];
	end
end

save(fullfile(Folder,['Analysed ' FishName]),'header','AnalysedData','StimulusData','RoiData','Mean_Nghbr_Dist');