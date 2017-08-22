function BuildVideo(Folder,FrameRate)

% BuildVideo(Folder,StimulusData,AnalysedData,FrameRate)
% 	Folder: Experiment folder
% 	Skipped_Frames: Step size between each frame of video
% 
% 	Saves video as 'Experiment.avi'

[a b] = fileparts(Folder);

load(fullfile(Folder,['Analysed ' b '.mat']));

% Extract experiment data from Experiment.xml file
MetaData    	= xml2struct(fullfile(Folder,'Experiment.xml'));
ImageWidth  	= str2num(MetaData.ThorImageExperiment.LSM.Attributes.pixelX);
ImageHeight 	= str2num(MetaData.ThorImageExperiment.LSM.Attributes.pixelY);
FrameCount  	= str2num(MetaData.ThorImageExperiment.Streaming.Attributes.frames);
StepCount   	= str2num(MetaData.ThorImageExperiment.ZStage.Attributes.steps);
fps         	= str2num(MetaData.ThorImageExperiment.LSM.Attributes.frameRate(1:5));
FlyBackFrames 	= str2num(MetaData.ThorImageExperiment.Streaming.Attributes.flybackFrames);

Skipped_Frames = 0;

if(StepCount == 1)
	FlyBackFrames = 0;
end

% Generate circle in top right corner
for i = 1:512
	for j = 1:512
		if((i-45)^2+(j-450)^2<=34^2)
			J(i,j) = 1;
		else
			J(i,j) = 0;
		end
	end
end

% Convert times to frame number
T = time2Frame(StimulusData.Raw(:,2),AnalysedData);
for i = 1:24
	T = [T T(:,1)+i];
end
U = uniqueElements(StimulusData.Raw(:,3));
for i = 1:length(U)
	S(i,:) = find(StimulusData.Raw(:,3) == U(i));
end

fid = fopen(fullfile(Folder,'Image_0001_0001.raw'),'r','l');

filename = [];

% Video writer boiler plate
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
	vobj{i}.FrameRate=FrameRate;
	vobj{i}.Quality=75;
	open(vobj{i});
	V{i} = uint8(zeros(512,512,length(U),25));
end


h = waitbar(1/(FrameCount),['1/' int2str(FrameCount)], 'Name','Building');

for ii = 1:FrameCount

    [a b] = mdivide(ii,StepCount+FlyBackFrames);

    if(FlyBackFrames == 0 && StepCount == 1)
    	b = 1;
    end

    % Skip fly-back frames
    if(sum(b == [1:StepCount]) == 0 || mod(a+1,Skipped_Frames) == 0)
      fseek(fid,ImageWidth*ImageHeight*2,0);
      continue;
    end

    Slice = b;
    Frame = a + 1;

	I = get8BitImage(fid,ImageHeight,ImageWidth);

	% Add circle to image with appropriate shading
	if(sum(sum(Frame==T))>0)
		[a postframe] = find(Frame == T);
		[stimtyp d] = find(S == a);
		V{Slice}(:,:,stimtyp,postframe) = V{Slice}(:,:,stimtyp,postframe) + I;
	end
		
	waitbar(ii/(FrameCount),h,[int2str(ii) '/' int2str(FrameCount)]);
end

S = sort(U);

for Slice = 1:4
	I = V{Slice};
	for i = 1:length(U)
		F = find(U(i) == S);
		for j = 1:25
			writeVideo(vobj{Slice},suint8(I(:,:,F,j))+suint8(J).*uint8(length(U)/length(U)*(j == 1)));
		end
	end
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

function I = suint8(I)

r = (2^8-1) / double(max(max(max(I)))); 

I = uint8(I * r);

end
