function VideoWithStimuli(Folder,StimulusData,AnalysedData, Slice)

% BuildVideo(Folder,Skipped_Frames)
% 	Folder: Experiment folder
% 	Skipped_Frames: Step size between each frame of video
% 
% 	Saves video as 'Experiment.avi'


% Extract experiment data from Experiment.xml file
MetaData    	= xml2struct(fullfile(Folder,'Experiment.xml'));
ImageWidth  	= str2num(MetaData.ThorImageExperiment.LSM.Attributes.pixelX);
ImageHeight 	= str2num(MetaData.ThorImageExperiment.LSM.Attributes.pixelY);
FrameCount  	= str2num(MetaData.ThorImageExperiment.Streaming.Attributes.frames);
StepCount   	= str2num(MetaData.ThorImageExperiment.ZStage.Attributes.steps);
fps         	= str2num(MetaData.ThorImageExperiment.LSM.Attributes.frameRate(1:5));
FlyBackFrames 	= str2num(MetaData.ThorImageExperiment.Streaming.Attributes.flybackFrames);

for i = 1:512
	for j = 1:512
		if((i-45)^2+(j-450)^2<=34^2)
			J(i,j) = 1;
		else
			J(i,j) = 0;
		end
	end
end

[Folder2 File] = fileparts(Folder);

T = time2Frame(StimulusData.Raw(:,2),AnalysedData);

if(StepCount == 1)
	FlyBackFrames = 0;
end

vobj = VideoWriter(File,'Motion JPEG AVI');
vobj.FrameRate = 30;
vobj.Quality = 75;
open(vobj);

fid = fopen(fullfile(Folder,'Image_0001_0001.raw'),'r','l');

filename = [];

h = waitbar(1/(FrameCount),['1/' int2str(FrameCount)], 'Name','Building');


for i = 1800*(StepCount+FlyBackFrames):2250*(StepCount+FlyBackFrames)

	[a b] = mdivide(i,StepCount+FlyBackFrames);
	if(b~=Slice)
      fseek(fid,ImageWidth*ImageHeight*2,0);
      continue;
    end

    Slice = b;
    Frame = a + 1;

	I = get8BitImage(fid,ImageHeight,ImageWidth);

	if(sum(Frame==T)>0)
		I = I + suint8(J).*StimulusData.Raw(find(Frame==T),3);
	end

	writeVideo(vobj, I);

	waitbar(i/(FrameCount),h,[int2str(i) '/' int2str(FrameCount)]);
end

close(vobj);
fclose(fid);
delete(h);

end


function I = get8BitImage(fid,ImageHeight,ImageWidth)

pixels = fread(fid,[1 ImageHeight*ImageWidth],'uint16');
I = suint8(reshape(pixels,[ImageHeight ImageWidth])');

end

function I = suint8(I)

r = (2^8-1) / double(max(max(max(I)))); 

I = uint8(I * r);

end
