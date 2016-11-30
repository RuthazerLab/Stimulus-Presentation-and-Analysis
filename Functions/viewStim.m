% Input Roi Number. Cycles through each stimulus and shows
% snapshot of the 5 seconds before and 7 seconds after each
% place the stimulus was presented.
% Must have Stimulus Data and AnalysedData in workspace

% try

ROI = input('ROI Number: ');

figure(1);

Stimuli = sort(uniqueElements(StimulusData.Raw(:,3)));

for t = 1:length(Stimuli)

disp(['Stimulus value: ' num2str(Stimuli(t))]);

Indexes = find(StimulusData.Raw(:,3) == Stimuli(t));

Times = StimulusData.Times(Indexes);

Frames = time2Frame(Times,AnalysedData);

Y = [];

Data = zeros(1, 12*floor(header.FPS/header.Slices)+length(AnalysedData.dFF0(ROI,:)));
Data(5*floor(header.FPS/header.Slices):end-1-floor(header.FPS/header.Slices)*7) = AnalysedData.dFF0(ROI,:);

for f = Frames'
	Y(end+1,:) = Data(f:f+12*floor(header.FPS/header.Slices));
end



for k = 1:ceil(length(Y(:,1))/3)
	for i = 1:3
		if(i+3*(k-1) > length(Y(:,1)))
			break;
		end
		subplot(3,1,i); plot(Y(i+3*(k-1),:)); 
		ylim([0 .8]); title(['Frame ' num2str(Frames(i+3*(k-1)))]);
		set(gca,'XTick',[0:floor(header.FPS/header.Slices):12*floor(header.FPS/header.Slices)]);
		set(gca,'XTickLabel',{-5:7});
		xlim([0 12*floor(header.FPS/header.Slices)]);
	end
	input('Next');
end

end

% catch
% 	help viewStim
% end