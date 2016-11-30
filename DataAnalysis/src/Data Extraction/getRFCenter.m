function [Y X mult] = getRFCenter(Roi, StimulusData, RoiData)

X = 0;
Y = 0;
mult = 0;
Q{1} = [0 0];

for i = 2:length(RoiData(Roi).Responded)

	% Finds which square corresponds to the stimulus
	P(i) = StimulusData.Raw(find(StimulusData.Raw == RoiData(Roi).Responded(i))+length(StimulusData.Raw));
	[a b] =  mdivide(P(i),5);
	if(b == 0) b = 5; end
	if(a == 5) a = 4; end

	% Checks to see if any responses are repeated
	for i = 1:length(Q)
		if([a b] ==Q{i})
			mult = 1;
			break;
		end
	end

	Q{i} = [a b];
	X = X + b;
	Y = Y + a+1;
end 

% Returns average x and y coordinate
X = X/(length(RoiData(Roi).Responded)-1);
Y = Y/(length(RoiData(Roi).Responded)-1);