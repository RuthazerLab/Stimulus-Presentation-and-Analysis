T = [time2Frame(StimulusData.Times,AnalysedData) StimulusData.Raw(:,3)];
[RoiCount Times] = size(AnalysedData.dFF0);

% Sort stimuli in increasing order
stimType  = sort(uniqueElements(StimulusData.Raw(:,3)));
stimCount = length(stimType);

% Look two seconds after each stimulus
critWindow = ceil(header.FPS*2);

% For each stimulus type
for index1 = 1:stimCount
	% Find times when this simulus was presented
	temp = T(find(T(:,2) == stimType(index1)),1);
	% Loop through each repetition of this stimulus
	reps = length(temp);
	for index2 = 1:reps
		% Creat matrix of indicies for averaging response to stimuli
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
				% Calculuate the average dF/F0 for each stimulus presentation during the 2 following seconds
				mu(index1,index2) = mean(AnalysedData.dFF0(r,S(index1,critWindow*(index2-1)+1:critWindow*index2)));
			end
		end
	end

	% Save ROI's responses to each stimulus type x repetition
	RoiData(r).XCor = mu;
	% Response will be the average to each stimulus type
	AnalysedData.Responses(r,:) = mean(RoiData(r).XCor');

	Mu = mean(RoiData(r).XCor');
	STD = std(RoiData(r).XCor');

	for index2 = 2:stimCount
		AnalysedData.ZScore(r,index2-1) = (Mu(index2)-Mu(1))/sqrt(STD(index2)^2/reps+STD(1)^2/reps);
	end
end
