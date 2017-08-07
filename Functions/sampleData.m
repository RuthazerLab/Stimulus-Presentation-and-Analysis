function sampleData(Folder)

% function sampleData(Folder)
% 		input: Folder containing different experiments
% 		output: Sampled.mat
% 
% This function calculates the minimum Roi Count across
% all fish in the group. Then this many ROIs are sampled
% from each fish. The Z Scores, dF/F, and XCor are recorded
% in the file Sampled.mat


% Find all folders in the Folder directory (i.e. excludes .mat files)
F = dir(Folder);
for i = 3:length(F)
	L(i) = isdir(F(i).name);
end
L = find(L);

% Calculates minimum Roi Count
RoiMin = inf;
for i = 1:length(L)
	load(fullfile(Folder,F(L(i)).name,['Analysed ' F(L(i)).name '.mat']));
	if(length(RoiData)<RoiMin)
		RoiMin = length(RoiData);
	end
end

% Samples information from each fish
for i = 1:length(L)
	load(fullfile(Folder,F(L(i)).name,['Analysed ' F(L(i)).name '.mat']));
	ROIS = datasample([1:length(RoiData)],RoiMin,'Replace',false);
	ZScore(:,:,i) = AnalysedData.ZScore(ROIS,:);
	Responses(:,:,i) = AnalysedData.Responses(ROIS,:);
	for r = 1:RoiMin
		XCor(:,:,r,i) = RoiData(r).XCor;
	end
end

save(fullfile(Folder,'Sampled.mat'),'Responses','ZScore','XCor','RoiMin');