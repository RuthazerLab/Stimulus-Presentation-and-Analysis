function [AV ME] = zProj(imS, imF, sliceN, folder)

AV = zeros(512,512);

% folder = input('Folder: ');

h = waitbar(1/(imF-imS+1),['1/' int2str(imF-imS+1)], 'Name','TProjection');

for i = imS:imF
	D = double(imread([folder '\ChanA_0001_0001_' leftpad(sliceN,4) '_' leftpad(i,4) '.tif']));
	ME(i) = mean(mean(D));
	AV =  AV + D;
	waitbar(i/(imF-imS+1),h,[int2str(i) '/' int2str(imF-imS+1)]);
end

AV = AV/(imF-imS+1);

delete(h);