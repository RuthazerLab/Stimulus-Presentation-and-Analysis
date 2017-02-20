function [AV ME] = zProjGroup(fileName, ImagesPerSlice, ImageSize, Step, FlyBackFrames, GroupSize)

h = waitbar(1/(ImagesPerSlice*(Step+FlyBackFrames)),['1/' int2str(ImagesPerSlice*(Step+FlyBackFrames))], 'Name','TProjection');

% Get side length of images
SL = ImageSize ^ 0.5;
GroupNum = ceil(ImagesPerSlice/GroupSize);

fid = fopen(fileName,'r','l');

% Initialize List
List = zeros([1 ImageSize Step GroupNum]);

GroupCount = 0;
Group = 1;

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
    if(GroupCount >= GropuSize * Step)
    	GropuCount = 0;
    	Group = Group + 1;
    end

	List(:,:,Slice,Group) = List(:,:,Slice,Group) + fread(fid,[1 ImageSize],'uint16');

	GropuCount = GroupCount + 1;

	waitbar(i/(ImagesPerSlice*(Step+FlyBackFrames)),h,[int2str(i) '/' int2str(ImagesPerSlice*(Step+FlyBackFrames))]);

end

% Divide by number of images to get mean
List(:,:,1:end,1:end) = List(:,:,1:end,1:end) / ImagesPerSlice;

% Reshape List to SL x SL
AV = zeros(SL,SL);

for k = 1:GroupNum
	for j = 1:Step
		for i = 0:SL:length(List)-1
			AV(i/SL+1,:,j,k) = List(1,i+1:i+SL,j,k);
		end
	end
end

fclose(fid);
delete(h);