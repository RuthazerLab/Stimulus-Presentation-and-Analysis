% Find ROI numbers where there is a slice change
U = uniqueElements(AnalysedData.Times(:,1));
for i = 1:length(U)
	T = find(AnalysedData.Times(:,1) == U(i));
	TimeJump(i) = T(end) + 1;
end
TimeJump(end) = TimeJump(end) - 1;


% Factor to turn stimulus indentifier into integer index value
mult = 1;

Stimuli = sort(uniqueElements(StimulusData.Raw(:,3)));

[RoiCount Times] = size(AnalysedData.dFF0);
StimuliCount = length(StimulusData.Times);

Responses = zeros(length(Stimuli),RoiCount);

% Loop through each slice, stimulus, and time point (this assumes we image all slices
% at the same time)
for t = 1:length(TimeJump)
	for j = 1:StimuliCount
		for i = 1:Times

			% Creates logical matrix from characteristic function for interval (Stimulus Time, Stimulus Time + 1)
			if(sum(AnalysedData.Times(TimeJump(t),i) > StimulusData.Times(j)) && sum(AnalysedData.Times(TimeJump(t),i) <= StimulusData.Times(j)+StimulusData.Configuration.DisplayLength))
				S(i,j,t) = 1;
			else
				S(i,j,t) = 0;
			end

		end
	end
end

% Number of frames equivalent to 0.2 s
offset = floor(0.2 * header.FPS);


h = waitbar(1/length(RoiData), 'Please Wait...', 'Name','Cross Correlating');

% Loops through each stimulus time and ROI
for j = 1:length(StimulusData.Times)
	for k = 1:RoiCount
		temp = find(TimeJump >= k);
		t = temp(1);

		waitbar(j/(length(StimulusData.Times)),h);

		% Calculuates correlation between ROI and Stimulus with offset
		Ind = find(S(:,j,t)); % Indices of stimulus number j
		if(isempty(Ind))
			continue;
		end

		if(exist('Use_Brightness'))
			disp('Raw data used.');
			M = mean(RoiData(k).Brightness(Ind(1)+offset:min(Ind(end)+offset+floor(3*header.FPS),Times)));
		else
			M = mean(AnalysedData.dFF0(k,(Ind(1)+offset:min(Ind(end)+offset+floor(3*header.FPS),Times))));
		end
		

		% Converts Stimulus time into stimulus identifier and thereafter an index
		% in the matrix Responses
		g = find(Stimuli == StimulusData.Raw(j,3));

		Responses(g,k) = Responses(g,k) + M;
	end
end

% for i = 1:RoiCount
% 	Responses(:,i) = (StimulusData.Responses(:,i)-mean(AnalysedData.dFF0(i,:)))/std(AnalysedData.dFF0(i,:));
% end

% Clears extraneous variable
delete(h);
clearvars h offset Ind M RoiCount Stimuli StimuliCount T TimeJump Times U g i j k mult t temp;


