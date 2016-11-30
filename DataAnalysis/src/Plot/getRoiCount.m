function count = getRoiCount(RoiData, i)

count = 0;
for j = 1:length(RoiData)
	if(RoiData(j).Coordinates(3) == i)
		count = count + 1;
	end
end