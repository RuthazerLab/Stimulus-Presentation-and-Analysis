function runLinearModel(Folder)

load(fullfile(Folder,'Sampled.mat'));

if(length(size(Responses)) == 4)
	XCor = Responses;
	Responses = permute(mean(Responses,2),[3 1 4 2]);
end

SI = [];

[a Group] = fileparts(Folder);
[a Stim] = fileparts(a);

switch Stim
	case 'Brightness'
		T = [3:9];
		S = T;
	case 'Spatial'
		T = compFact(800)/(180/pi*2*atan(11.5/(2*2.3)));
		T = log(T(1:9));
		S = [1:9];
	otherwise
		return;
end



for i = 1:size(ZScore,3)
	for j = 1:RoiMin
		SI(j,i) = 1-min(Responses(j,2:end,i))/max(Responses(j,2:end,i));
		LRL = fitlm(T,Responses(j,S,i));
		LM.XIntercept(j,i) = LRL.Coefficients.Estimate(1);
		LM.Slope(j,i) = LRL.Coefficients.Estimate(2);
		LM.RSquared(j,i) = LRL.Rsquared.Ordinary;
	end
	xlswrite([Stim '.' Group '.LinearRegression.xlsx'],[{'XInt'},{'Slope'},{'R^2'}; num2cell([LM.XIntercept(:,i) LM.Slope(:,i) LM.RSquared(:,i)])],['Fish ' int2str(i)]);
end

xlswrite([Stim '.' Group '.LinearRegression.xlsx'],[LM.XIntercept],['XIntercept']);
xlswrite([Stim '.' Group '.LinearRegression.xlsx'],[LM.Slope],['Slope']);
xlswrite([Stim '.' Group '.LinearRegression.xlsx'],[LM.RSquared],['RSquared']);

save(fullfile(Folder,'Sampled.mat'),'RoiMin','ZScore','Responses','SI','LM','RoiNumbers');
