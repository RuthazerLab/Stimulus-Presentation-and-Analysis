function [RoiData RoiCoordinates] = getRoiData(ImageData);

% Reformats data into structure RoiData

RoiCoordinates = [];

for i = 1:length(ImageData)
	Co{i} = ImageData(i).RoiCoordinates;
	RoiCoordinates = [RoiCoordinates ImageData(i).RoiCoordinates];
	Data{i} = ImageData(i).Results;
end

Co = cell2mat(Co);
Data = cell2mat(Data);


for i = 1:length(Co)
	RoiData(i) = struct('Brightness', Data(:,i), 'Coordinates', Co(:,i));
end