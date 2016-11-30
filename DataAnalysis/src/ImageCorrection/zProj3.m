function [AV ME] = zProj3(fileName, ImagesPerSlice, ImageSize, Step, FlyBackFrames)

h = waitbar(1/(ImagesPerSlice*(Step+FlyBackFrames)),['1/' int2str(ImagesPerSlice*(Step+FlyBackFrames))], 'Name','TProjection');

% Get side length of images
SL = ImageSize ^ 0.5;

fid = fopen(fileName,'r','l');

% Initialize List
List = zeros([1 ImageSize Step]);

% Add each image to List
for i = 1:ImagesPerSlice*(Step+FlyBackFrames)

	[a b] = mdivide(i,Step+FlyBackFrames);

	if(FlyBackFrames == 0)
		b = 1;
	end
    
    if(sum(b == [1:Step]) == 0)
    	fseek(fid,ImageSize*2,0);
      	continue;
    end

    Slice = b;

	List(:,:,Slice) = List(:,:,Slice) + fread(fid,[1 ImageSize],'uint16');

	waitbar(i/(ImagesPerSlice*(Step+FlyBackFrames)),h,[int2str(i) '/' int2str(ImagesPerSlice*(Step+FlyBackFrames))]);

end

% Divide by number of images to get mean
List(:,:,1:end) = List(:,:,1:end) / ImagesPerSlice;

% Reshape List to SL x SL
AV = zeros(SL,SL);

for j = 1:Step
	for i = 0:SL:length(List)-1
		AV(i/SL+1,:,j) = List(1,i+1:i+SL,j);
	end
end

fclose(fid);
delete(h);