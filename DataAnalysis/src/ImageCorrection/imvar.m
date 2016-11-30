function VARIM = imvar(fileName, AV, Slice, ImagesPerSlice, ImageSize)


% Similar to zProj2 except calculates variance

h = waitbar(1/(ImagesPerSlice),['1/' int2str(ImagesPerSlice)], 'Name','TProjection');

SL = ImageSize^0.5;

fid = fopen(fileName,'r','l');

List = zeros([1 ImageSize]);
VARIM = zeros(SL,SL);

fseek(fid,2*(Slice-1)*ImagesPerSlice*ImageSize,-1);

for i = 1:ImagesPerSlice
	List = List + fread(fid,[1 ImageSize],'uint16');

	for k = 0:SL:length(List)-1
		IM(k/SL+1,:) = List(1,k+1:k+SL);
	end

	VARIM = VARIM + (AV - IM).^2;

	waitbar(i/(ImagesPerSlice),h,[int2str(i) '/' int2str(ImagesPerSlice)]);
end

VARIM = VARIM / ImagesPerSlice;

delete(h);