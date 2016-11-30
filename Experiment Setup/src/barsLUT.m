function data = barsLUT(I, fig, variables, data);
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

spacing = variables(1);
bwidth = variables(2);
speed = variables(3);


tic;
while true
	for i = 1:speed:bwidth+spacing
		if(~ishandle(fig))
			break
		end
		imshow(I(:,:,i),'border','tight','parent',gca); drawnow;
	end
	if(~ishandle(fig))
		data(end+1,2) = toc;
		break
	end
	data(end+1,2) = toc
end


