T = [time2Frame(StimulusData.Times,AnalysedData) StimulusData.Raw(:,3)];
[RoiCount Times] = size(AnalysedData.dFF0);
stimType 	= sort(uniqueElements(StimulusData.Raw(:,3)));
stimCount = length(stimType);

critWindow = ceil(header.FPS*2);

for i = 1:stimCount
	temp = T(find(T(:,2) == stimType(i)),1);
	reps = length(temp);
	for j = 1:reps
		for k = 1:critWindow
			S(i,critWindow*(j-1)+k) = temp(j) + k;
		end
	end
end

for r = 1:RoiCount
	for i = 1:stimCount
		for j = 1:reps
			mu(i,j) = mean(AnalysedData.dFF0(r,S(i,critWindow*(j-1)+1:critWindow*j)));
		end
	end
	RoiData(r).XCor = mu;
	StimulusData.Responses(:,r) = mean(mu');
end




% for i = 1:stimCount
% 	xbar(i) = mean(RoiData(560).XCor(i,:));
% 	sigma(i) = std(RoiData(560).XCor(i,:));
% end
% hold off;
% bar([0:16],RoiData(560).XCor); hold on;
% h=errorbar([0:16],xbar,sigma,'b'); set(h,'linestyle','none')