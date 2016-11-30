function BuildVideo(Folder,Skipped_Frames)

% BuildVideo(Folder,Skipped_Frames)
% 	Folder: Experiment folder
% 	Skipped_Frames: Step size between each frame of video
% 
% 	Saves video as 'Experiment.avi'

if(nargin ~= 2)
	help BuildVideo;
	return;
end

% Extract experiment data from Experiment.xml file
MetaData    	= xml2struct(fullfile(Folder,'Experiment.xml'));
ImageWidth  	= str2num(MetaData.ThorImageExperiment.LSM.Attributes.pixelX);
ImageHeight 	= str2num(MetaData.ThorImageExperiment.LSM.Attributes.pixelY);
FrameCount  	= str2num(MetaData.ThorImageExperiment.Streaming.Attributes.frames);
StepCount   	= str2num(MetaData.ThorImageExperiment.ZStage.Attributes.steps);
fps         	= str2num(MetaData.ThorImageExperiment.LSM.Attributes.frameRate(1:5));
FlyBackFrames 	= str2num(MetaData.ThorImageExperiment.Streaming.Attributes.flybackFrames);


if(StepCount == 1)
	FlyBackFrames = 0;
end


fid = fopen(fullfile(Folder,'Image_0001_0001.raw'),'r','l');

filename = [];

for i = 1:StepCount
	if(StepCount == 1)
		filename{i} = ['Experiment.avi'];
	else
		filename{i} = ['Experiment' int2str(i) '.avi'];
	end

	if(exist(fullfile(Folder,filename{i})))
		delete(fullfile(Folder,filename{i}));
	end
	vobj{i}=VideoWriter(filename{i}, 'Motion JPEG AVI');
	vobj{i}.FrameRate=30;
	vobj{i}.Quality=75;
	open(vobj{i});
end


h = waitbar(1/(FrameCount),['1/' int2str(FrameCount)], 'Name','Building');


for ii = 1:FrameCount

    [a b] = mdivide(ii,StepCount+FlyBackFrames);

    if(FlyBackFrames == 0 && StepCount == 1)
    	b = 1;
    end

    
    if(sum(b == [1:StepCount]) == 0 || mod(a+1,Skipped_Frames) == 0)
      fseek(fid,ImageWidth*ImageHeight*2,0);
      continue;
    end

    Slice = b;
    Frame = a + 1;

	I = get8BitImage(fid,ImageHeight,ImageWidth);
	
	writeVideo(vobj{Slice}, I);
		
	waitbar(ii/(FrameCount),h,[int2str(ii) '/' int2str(FrameCount)]);
end

delete(h);
fclose(fid);
for i =	1:StepCount
	close(vobj{i});
end

end

function I = get8BitImage(fid,ImageHeight,ImageWidth)

pixels = fread(fid,[1 ImageHeight*ImageWidth],'uint16');
I = suint8(reshape(pixels,[ImageHeight ImageWidth])');

end

