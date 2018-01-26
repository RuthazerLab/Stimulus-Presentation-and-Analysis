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

warning('off','MATLAB:xlswrite:AddSheet');

F = dir(Folder);
% Calculates minimum Roi Count
RoiMin = inf;
for i = 3:length(F)
	if(exist(fullfile(Folder,F(i).name,['Analysed ' F(i).name '.mat'])))
		load(fullfile(Folder,F(i).name,['Analysed ' F(i).name '.mat']));
		L(i) = 1;
		if(length(RoiData)<RoiMin)
			RoiMin = length(RoiData);
		end
	else
		if(isdir(F(i).name))
			disp(['Can''t find ' fullfile(Folder,F(i).name,['Analysed ' F(i).name '.mat'])]);
		end
		L(i) = 0;
	end
end

L = find(L);

[a Group] = fileparts(Folder);
[a Stim] = fileparts(a);

% Samples information from each fish
for i = 1:length(L)
	load(fullfile(Folder,F(L(i)).name,['Analysed ' F(L(i)).name '.mat']));
	ROIS = datasample([1:length(RoiData)],RoiMin,'Replace',false);
	ZScore(:,:,i) = AnalysedData.ZScore(ROIS,:);
	Responses(:,:,i) = AnalysedData.Responses(ROIS,:);
	for r = 1:RoiMin
		XCor(r,:,:,i) = RoiData(r).XCor;
		SI(r,i) = 1-min(AnalysedData.Responses(r,:))/max(AnalysedData.Responses(r,:));
	end

	switch Stim
		case 'Brightness'
			Title = [{'Blank',} num2cell([0.1:0.1:1])];
		case 'Direction'
			Title = [{'Blank'} num2cell([30:30:360])];
		case 'Spatial'
			CPD = repmat(800,[1 18])./compFact(800);
			Title = [{'Blank'} num2cell(CPD(1:16))];
		otherwise
			continue;
	end

	xlswrite([Stim '.' Group '.Fish' int2str(i) '.xlsx'],[Title; num2cell(Responses(:,:,i))],'DeltaF');
	xlswrite([Stim '.' Group '.Fish' int2str(i) '.xlsx'],[Title(2:end); num2cell(ZScore(:,:,i))],'ZScore');
	xlswrite([Stim '.' Group '.Fish' int2str(i) '.xlsx'],(SI(:,i)),'SI');
	xlswrite([Stim '.' Group '.Fish' int2str(i) '.xlsx'],ROIS,'RoiNumbers');

	RoiNumbers(:,i) = ROIS;
end

save(fullfile(Folder,'Sampled.mat'),'Responses','ZScore','XCor','RoiMin','SI','RoiNumbers');