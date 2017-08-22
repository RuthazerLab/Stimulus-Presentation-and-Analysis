function [Averaged_Images tform] = zProj3(fileName, ImagesPerSlice, ImageSize, StepCount, FlyBackFrames,DoReg)


h = waitbar(1/(ImagesPerSlice*(StepCount+FlyBackFrames)),['1/' int2str(ImagesPerSlice*(StepCount+FlyBackFrames))], 'Name','TProjection');

% Number of dirft-correction segments
TSegs = 20;


SL = ImageSize ^ 0.5;	% Side length of images (assume square)
H = ImagesPerSlice*(StepCount+FlyBackFrames);	% Total number of frames collected

fid = fopen(fileName,'r','l');

for inc = 1:TSegs

	% Initialize List
	List = zeros([SL*SL StepCount]);

	% Add each image to List
	for i = (inc-1)*H/TSegs+1:H*inc/TSegs

		[a b] = mdivide(i,StepCount+FlyBackFrames);
		if(FlyBackFrames == 0)
			b = 1;
		end
	    
	    if(sum(b == [1:StepCount]) == 0)
	    	fseek(fid,ImageSize*2,0);
	      	continue;
	    end

		List(:,b) = List(:,b) + fread(fid,[1 ImageSize],'uint16')';

		waitbar(i/(ImagesPerSlice*(StepCount+FlyBackFrames)),h,[int2str(i) '/' int2str(ImagesPerSlice*(StepCount+FlyBackFrames))]);

	end

	% Divide by number of images to get mean
	I{inc} = List / ImagesPerSlice;

end

fclose(fid);
delete(h);


for i = 1:TSegs
	J(:,:,:,i) = reshape(I{i},[SL SL StepCount]);
end

h = waitbar(1/(StepCount*TSegs),['1/' int2str(StepCount*TSegs)], 'Name','Registration...');


if(DoReg)
	% Register all average segments to first segment average.
	[optimizer, metric] = imregconfig('monomodal');
	I = [];
	tform = {};

	for Slice = 1:StepCount
		I = suint16(permute(J(:,:,Slice,:),[2 1 4 3]));

		for i = 1:TSegs
			waitbar((i+(Slice-1)*TSegs)/(StepCount*TSegs),h,[int2str(i+(Slice-1)*TSegs) '/' int2str(StepCount*TSegs)]);

			% Register image and find transformation
			K(:,:,i) = imregister(I(:,:,i),I(:,:,TSegs/2),'translation',optimizer,metric);
			tform{Slice,i} = imregtform(I(:,:,i),I(:,:,TSegs/2),'translation',optimizer,metric);

			if(i>1)
				Err(i-1) = sum(sum((K(:,:,i)-K(:,:,i-1)).^2))/ImageSize;
			end
			if(i>2)
				Diffs(i-2) = Err(i-1)-Err(i-2);
			end

		end

		zScore = (Diffs-mean(Diffs))/std(Diffs);
		if(sum(zScore > 2))
			% disp(['Mean-squared error suggests incorrect registeration in slice ' int2str(Slice) '. It''s possbile there''s z-drift.']);
		end 


		Averaged_Images(:,:,Slice) = suint16(mean(K,3));

	end
else
	I = mean(J,4);
	for i = 1:StepCount
		Averaged_Images(:,:,i) = suint16(I(:,:,i)');
	end
	tform = 0;
end

delete(h);