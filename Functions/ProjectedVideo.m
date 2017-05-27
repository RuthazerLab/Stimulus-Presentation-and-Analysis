Folder = pwd;

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


P = StimulusData.Raw(:,2);
Q = sort(uniqueElements(StimulusData.Raw(:,3)));
T = time2Frame(P,AnalysedData);

FrameWindow = T(2)-T(1);

for i = 1:512
	for j = 1:512
		if((i-45)^2+(j-450)^2<=34^2)
			K(i,j) = 1;
		else
			K(i,j) = 0;
		end
	end
end


I = uint8(zeros(512,512,FrameWindow,length(Q)));


fid = fopen(fullfile(Folder,'Image_0001_0001.raw'),'r','l');

filename = [];

h = waitbar(1/(FrameCount),['1/' int2str(FrameCount)], 'Name','Building');


for ii = 1:FrameCount

    [a b] = mdivide(ii,StepCount+FlyBackFrames);

    if(FlyBackFrames == 0 && StepCount == 1)
    	b = 1;
    end

    
    if(b ~= 3 || mod(a+1,Skipped_Frames) == 0)
      fseek(fid,ImageWidth*ImageHeight*2,0);
      continue;
    end

    Slice = b;
    Frame = a + 1;

	pixels = fread(fid,[1 ImageHeight*ImageWidth],'uint16');
	J = suint8(reshape(pixels,[ImageHeight ImageWidth])');

	if(sum(Frame==T)>0)
		F = find(Frame == T);
		Index = find(StimulusData.Raw(F,3) == Q);
		I(:,:,1,Index) = I(:,:,1,Index) + J + suint8(K).*(StimulusData.Raw(find(Frame==T),3)/max(StimulusData.Raw(:,3)));
	end
	for i = 1:FrameWindow-1
		if(sum(Frame==T+i)>0)
			F = find(Frame-i == T);
			Index = find(StimulusData.Raw(F,3) == Q);
			I(:,:,i+1,Index) = I(:,:,i+1,Index) + J;
		end
	end
		
	waitbar(ii/(FrameCount),h,[int2str(ii) '/' int2str(FrameCount)]);
end

delete(h);
fclose(fid);

