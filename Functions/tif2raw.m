function I = tif2raw(imS, imF, sliceN, folder)

fid = fopen('New_Raw_Image.raw','w');

for i = imS:sliceN:imF
	for n = 1:sliceN	
		I(:,:,i+n) = imread([folder '\ChanA_0001_0001_' leftpad(n,4) '_' leftpad(i,4) '.tif']);
		fwrite(fid,I(:,:,i+n)','uint16','ieee-le');
	end
end

fclose(fid);