function [fixed tform] = zProj3(fileName, ImagesPerSlice, ImageSize, StepCount, FlyBackFrames)


jarDir = fullfile(fullfile(fileparts(fileparts(mfilename('fullpath'))),'DataAnalysis'),'ext');
javaaddpath(fullfile(jarDir,'MorphoLibJ_-1.3.1.jar'));
javaaddpath(fullfile(jarDir,'ij-1.51n.jar'));
import ij.*;
import ij.process.*;

h = waitbar(1/(ImagesPerSlice*(StepCount+FlyBackFrames)),['1/' int2str(ImagesPerSlice*(StepCount+FlyBackFrames))], 'Name','TProjection');

% Get side length of images
SL = ImageSize ^ 0.5;

fid = fopen(fileName,'r','l');

H = ImagesPerSlice*(StepCount+FlyBackFrames);

for inc = 1:20

	% Initialize List
	List = zeros([1 ImageSize StepCount]);

	% Add each image to List
	for i = (inc-1)*H/20+1:H*inc/20

		[a b] = mdivide(i,StepCount+FlyBackFrames);

		if(FlyBackFrames == 0)
			b = 1;
		end
	    
	    if(sum(b == [1:StepCount]) == 0)
	    	fseek(fid,ImageSize*2,0);
	      	continue;
	    end

		List(:,:,b) = List(:,:,b) + fread(fid,[1 ImageSize],'uint16');

		waitbar(i/(ImagesPerSlice*(StepCount+FlyBackFrames)),h,[int2str(i) '/' int2str(ImagesPerSlice*(StepCount+FlyBackFrames))]);

	end

	% Divide by number of images to get mean
	List(:,:,1:end) = List(:,:,1:end) / ImagesPerSlice;

	% Reshape List to SL x SL
	AV = zeros(SL,SL);

	for j = 1:StepCount
		for i = 0:SL:length(List)-1
			AV(i/SL+1,:,j) = List(1,i+1:i+SL,j);
		end
	end

	I{inc} = AV;

end

fclose(fid);
delete(h);

for i = 1:20
	J(:,:,:,i) = I{i};
end
I = {};
for i = 1:4
	temp = suint16(permute(J(:,:,i,:),[1 2 4 3]));
	imwrite(temp(:,:,i), ['Averages' int2str(i) '.tif']);
	for k = 2:size(temp,3)
		imwrite(temp(:,:,k), ['Averages' int2str(i) '.tif'], 'writemode', 'append');
	end
end

clearvars -except fileName

[folder file] = fileparts(fileName);



IJ.run('Image Sequence...', ['open=[' fullfile(folder,'Averages1.tif') ' number=80 starting=1 file=Averages sort']);
IJ.run('Stack to Hyperstack...', 'order=xyczt(default) channels=1 slices=20 frames=4 display=Color');
IJ.run('Re-order Hyperstack...', 'channels=[Channels (c)] slices=[Slices (z)] frames=[Frames (t)]');
IJ.run('Correct 3D drift', ['channel=1 only please=[' fullfile(folder,'shifts.txt')]);

