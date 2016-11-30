function Field = getReceptivity(ROI,StimulusData)
% getReceptivity = FUNCTION processes ROI and stimulus data and returns matrix 	corresponding to receptive field of the sepcified ROI.

% Usage: Field = getRecptivity(ROI, Stimulus)
% 	ROI is an element of RoiData
% 	Stimulus is the structer StimulusData.


squares = [];

% Finds size of display area (square root of the number of stimuli)
siz = max(StimulusData.Raw(:,3))^0.5;

for i = 1:length(ROI.Responded)
	R = vsearch(StimulusData.Raw,ROI.Responded(i),2);
	if(~R)
		continue;
	end
	squares = [squares StimulusData.Raw(R,3)];
end

for i = 1:siz^2
	Field(i) = sum(i == squares);
end

Field = reshape(Field, siz, siz);