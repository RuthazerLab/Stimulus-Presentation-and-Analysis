function [AV ME] = zProj2(fileName, Slice, ImagesPerSlice, ImageSize, Step, FlyBackFrames)

if(nargin == 4)
	Step = 1;
end

h = waitbar(1/(ImagesPerSlice),['1/' int2str(ImagesPerSlice)], 'Name','TProjection');

% Get side length of images
SL = ImageSize ^ 0.5;

fid = fopen(fileName,'r','l');

% Initialize List
List = zeros([1 ImageSize]);

% Skip to the beginning of slice in file
fseek(fid,2*(Slice-1)*ImageSize,-1);

% Add each image to List
for i = 1:ImagesPerSlice
	List = List + fread(fid,[1 ImageSize],'uint16');
	waitbar(i/(ImagesPerSlice),h,[int2str(i) '/' int2str(ImagesPerSlice)]);
	fseek(fid,ImageSize*2*(Step+FlyBackFrames-1),0);
end

% Divide by number of images to get mean
List = List / ImagesPerSlice;

% Reshape List to SL x SL
AV = zeros(SL,SL);
for i = 0:SL:length(List)-1
	AV(i/SL+1,:) = List(1,i+1:i+SL);
end

fclose(fid);
delete(h);