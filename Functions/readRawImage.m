function I = readRawImage(fileName, imageSize, imageNumber)

	% I = readRawImage(fileName, imageSize, imageNumber)
	% 	Reads uint16 type image from a raw image 
	% 	file that is little-endian.
	% 
	% 	e.g. I = readRawImage('Image_0001_0001.raw',512*512,5)
	% 		would return the 5th image in Image_0001_0001.raw

	if(nargin ~= 3)
		help readRawImage;
		I = 0;
		return;
	end
		
	lengthSize = imageSize^0.5;
	if(mod(lengthSize,1) ~= 0)
		disp('Image is not square');
		I = null(imaegSize);
		return;
	end

	fid = fopen(fileName,'r','l');

	fseek(fid,2*imageSize*(imageNumber-1) ,-1);

	List = fread(fid,[1 imageSize],'uint16');

	for i = 0:lengthSize:length(List)-1
		I(i/lengthSize+1,:) = List(1,i+1:i+lengthSize);
	end

	fclose(fid);

