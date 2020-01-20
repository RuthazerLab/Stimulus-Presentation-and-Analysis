% Finds ROIs whos max Z score (to any stimulus) is greater than a threshold
ZThresh = 4;
idcsResponders = find(max(AnalysedData.ZScore,[],2)>ZThresh);
nResponders = length(idcsResponders); % Number of responders
nStimuli = length(unique(StimulusData.Raw(:,3))); % Number of different stimuli presented

% Total # of ROIs
N = size(AnalysedData.ZScore,1);

% Convert absolute number to fraction of total 
frNResp = nResponders/N;

% Get average response to each stimulus
tempResponses = permute(mean(AnalysedData.AllResponses(idcsResponders,:,:,:),3),[4,2,1,3]);

% Plot average responses of max responders
CM = parula(nStimuli); CM(:,1) = 0; % Get colours to plot
for s = 1:nStimuli
	errorbar(mean(tempResponses(:,s,:),3),std(tempResponses(:,s,:),[],3)/sqrt(nResponders), ...
		'LineWidth',1,'Color',CM(s,:)); 
	hold on;
end

% Compute correlation between stimulus and response
r = zeros(nResponders,1);
for i = 1:nResponders
	r(i) = corr([2:9]',AnalysedData.Responses(idcsResponders(i),2:9)');
end
