function I = loadIm(imS, imF, sliceN)

% I = loadIm(imS, imF, sliceN)
%	Opens tif files from ChanA_0001_0001_sliceN_imS
% 	to ChanA_0001_0001_sliceN_imF

if(nargin ~= 3)
	I = 0;
	help loadIm;
	return;
end

I = [];

folder = input('Folder: ');

for i = imS:imF
	I(:,:,(i-imS+1)) = imread([folder '\ChanA_0001_0001_' leftpad(sliceN,4) '_' leftpad(i,4) '.tif']);
end
