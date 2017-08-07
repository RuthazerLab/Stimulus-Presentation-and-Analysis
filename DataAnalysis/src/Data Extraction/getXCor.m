T = [time2Frame(StimulusData.Times,AnalysedData) StimulusData.Raw(:,3)];
[RoiCount Times] = size(AnalysedData.dFF0);
stimType  = sort(uniqueElements(StimulusData.Raw(:,3)));
stimCount = length(stimType);


critWindow = ceil(header.FPS*2);

for index1 = 1:stimCount
	temp = T(find(T(:,2) == stimType(index1)),1);
	reps = length(temp);
	for index2 = 1:reps
		for index3 = 1:critWindow
			S(index1,critWindow*(index2-1)+index3) = temp(index2) +index3;
		end
	end
end

for r = 1:RoiCount
	for index1 = 1:stimCount
		for index2 = 1:reps
			if(r == 1 && S(index1,critWindow*index2) > size(AnalysedData.dFF0,2))
				disp(['Stimulus ' int2str(index1) 'x' int2str(index2) ' has no image data']);
			else
				mu(index1,index2) = mean(AnalysedData.dFF0(r,S(index1,critWindow*(index2-1)+1:critWindow*index2)));
			end
		end
	end

	RoiData(r).XCor = mu;
	AnalysedData.Responses(r,:) = mean(RoiData(r).XCor');

	Mu = mean(RoiData(r).XCor');
	STD = std(RoiData(r).XCor');

	for index2 = 2:StimulusData.Configuration.StimuliCount
		AnalysedData.ZScore(r,index2-1) = (Mu(index2)-Mu(1))/sqrt(STD(index2)^2/10+STD(1)^2/10);
	end
end
