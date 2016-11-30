function viewProfile(t, ROI)

% FUNCTION viewProfile(t,ROI)
% View responses profile for ROI to stimulus number t

StimulusData = evalin('base','StimulusData');
AnalysedData = evalin('base','AnalysedData');
RoiData		 = evalin('base','RoiData');


Stimuli = sort(uniqueElements(StimulusData.Raw(:,3)));


Indexes = find(StimulusData.Raw(:,3) == Stimuli(t));
Times = StimulusData.Times(Indexes);
Frames = time2Frame(Times,AnalysedData);
T = zeros(1,40);
for f = Frames'
	T = T + VectorPad(AnalysedData.dFF0(ROI,f:min(f+39,end)),40,1);
end
plot(T/length(Frames));
set(gca,'XTick',[0:4:40])
set(gca,'XTickLabel',{0:1:10});