function time = num2then(n)

	% time = num2then(n)
	% 	Takes number from function now2num and converts
	% 	it back into the format hh:mm:ss mil

	if(nargin ~= 1)
		help num2then;
		time = 0;
		return;
	end

	[hour minute] = mdivide(n,3600);
	[minute second] = mdivide(minute, 60);
	[second milisecond] = mdivide(second,1);

	hour = int2str(hour);
	minute = int2str(minute);
	second = int2str(second);
	milisecond = int2str(milisecond*1000);

	if(length(hour) == 1)
		hour = ['0' hour];
	end
	if(length(minute) == 1)
		minute = ['0' minute];
	end
	if(length(second) == 1)
		second = ['0' second];
	end
	if(length(milisecond) == 1)
		milisecond = ['00' milisecond];
	elseif(length(milisecond) == 2)
		milisecond = ['0' milisecond];
	end

	

	time = [hour ':' minute ':' second ' ' milisecond];
