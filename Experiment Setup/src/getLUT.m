function I = loadLUT(direction,spacing,bwidth,height,width);
% bars displays moving bars across a figure.
% Usage: T = bars(direction ,num)
% 	direction:
%		 1 = N  to S
%		-1 = S  to N
%		 2 = W  to E
%		-2 = E  to W
%		 3 = SW to NE
%		-3 = NE to SW
%		 4 = NW to SE
%		-4 = SE to NW
%	num: number of times bars shift

	% Initializes variables
	countB = 0;
	countW = 0;
	sw = 1;
	speed = 1;
	oheight = height;
	owidth = width;
	Brightness = 0.5; % Sets brightness of the bars 0 to 1.

	% Initializes correct transformation based on direction.
	switch direction

	case 1
		theta = 180;
	case -1
		theta = 0;
	case 2
		theta = -90;
		temp = height;
		height = width;
		width = temp;
	case -2
		theta = 90;
		temp = height;
		height = width;
		width = temp;
	case 3
		theta = -45;
		height = ceil(width / sqrt(2) + height / sqrt(2)); width = height;
	case -3
		theta = 135;
		height = ceil(width / sqrt(2) + height / sqrt(2)); width = height;
	case 4
		theta = -135;
		height = ceil(width / sqrt(2) + height / sqrt(2)); width = height;
	case -4
		theta = 45;
		height = ceil(width / sqrt(2) + height / sqrt(2)); width = height;
	end


	B = zeros(height,width);
	
	% Initializes B with bars of correct width and spacing
	for i = 1:height
		if(sw)
			countW = countW + 1;
			B(i,:) = Brightness;
		else
			countB = countB + 1;
		end
		if(countW == bwidth || countB == spacing)
			countW = 0; countB = 0;
			sw = ~sw;
		end
	end

	% Creates one period of moving bars.
	for k = 1:bwidth+spacing

		% Deals with censure from rotating by a multiple of 45 degrees.
		if(abs(direction) > 2)
			temp = imrotate(B,theta);
			[a b] = size(temp);
			I(:,:,k) = temp(ceil(a/2-oheight/2):floor(a/2+oheight/2),ceil(b/2-owidth/2):floor(b/2+owidth/2));
		else
			I(:,:,k) = imrotate(B,theta);
		end
		
		% Moves bars over by one.
		for i = 1:height-1
			if(B(i,1) ~= B(i+1,1))
				for j = 1:width
					if(B(i,j) == 0)
						B(i,j) =  Brightness;
					else
						B(i,j) = 0;
					end
				end

			end
		end

		% Adds bars at the edge of image when necessary
		if(sw)
			B(height-1,:) = Brightness;
			countW = countW + 1;
			if(countW > bwidth)
				countW = 0;
				sw = ~sw;
			end
		else
			B(height-1,:) = 0;
			countB = countB + 1;;
			if(countB > spacing);
				countB = 0;
				sw = ~sw;
			end
		end

	end