function FrameTimes = getTimeAxis(RoiData, CaptureTimes, Slices, FlyBackFrames)

% Reformats CaptureTimes so that it is a roiCount x frameCount matrix


	h = waitbar(1/length(RoiData(1).Brightness), 'Please Wait...', 'Name','Time Axis');
	
	T = zeros(length(RoiData(1).Brightness),length(RoiData));

	for i = 1:length(RoiData(1).Brightness)

		waitbar(i/length(RoiData(1).Brightness),h);

		for j = 1:length(RoiData)
			% disp((i-1)*(Slices+FlyBackFrames)+RoiData(j).Coordinates(3));
			T(i,j) = CaptureTimes((i-1)*(Slices+FlyBackFrames)+RoiData(j).Coordinates(3));
		end
	end

	FrameTimes = transpose(T);

	delete(h);

end


