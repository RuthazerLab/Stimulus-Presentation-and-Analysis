function Template = averageResponse(AnalysedData,StimulusData)

% Averages the dF/F after each stimulus across all ROIs

% Find frame times of each stimulus
T = [time2Frame(StimulusData.Times,AnalysedData)];
for i = 1:(T(2,1)-T(1,1))
	T = [T T(:,1)+i];
end

% Record dF/F
for r = 1:size(AnalysedData.dFF0,1)
	for i = 1:length(uniqueElements(StimulusData.Raw(:,3)))*StimulusData.Configuration.Repetitions
		Trace(:,i,r) = AnalysedData.dFF0(r,T(i,:));
	end
end

% Average across ROIs with Z Score > 3 (Responding cells), as well as 
% stimulus repetitions.
Template = mean(mean(Trace(:,:,find(max(AnalysedData.ZScore,[],2)>3)),3),2);
Template = Template	- min(Template);
Template = Template./max(Template);