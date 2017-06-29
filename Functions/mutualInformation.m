function I = mutualInformation(RoiNumber)


StimulusData = evalin('base','StimulusData');
header 		 = evalin('base','header');
AnalysedData = evalin('base','AnalysedData');

StimCount = StimulusData.Configuration.StimuliCount;
Stimuli = uniqueElements(StimulusData.Raw(:,3));


WindowSize = floor(2*header.FPS);

S = time2Frame(StimulusData.Raw(:,2),AnalysedData);

T = [];
for i = 1:WindowSize
	T = [T; S+i];
end

R = repmat(StimulusData.Raw(:,3),[WindowSize 1]);

for i = 1:StimCount
	JointDist(i,:) = AnalysedData.dFF0(RoiNumber,T(R==Stimuli(i)));
end

[CalciumCount bins] = hist(AnalysedData.dFF0(RoiNumber,T));
CalciumProb = CalciumCount/sum(CalciumCount);
binSize = bins(2)-bins(1);




for x = 1:length(bins)
	for s = 1:StimCount
		J = and(JointDist(s,:) > bins(x)-binSize/2,JointDist(s,:) < binSize/2);
		XgiveS = sum(J)/(10*WindowSize);
		if(sum(J) == 0 || CalciumProb(x) == 0)
			logTerm(x,s) = 0;
		else
			logTerm(x,s) = log2(sum(J)/(CalciumProb(x)*10*WindowSize));
		end
		P(x,s) = 1/StimCount*XgiveS*logTerm(x,s);
	end
end

I = sum(sum(P));