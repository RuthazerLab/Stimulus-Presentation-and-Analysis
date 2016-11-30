function I = imPad(Im, h, w);

% I = imPad(Im,h,w)
% 	Pads image Im, fitting it in center of h x w picture

[hIm wIm] = size(Im);

I = zeros(h,w);

for j = 1:w
	if(j > (w-wIm)/2 && j < (w+wIm)/2)
		for i = 1:hIm
			I(i,j) = Im(i,j-(w-wIm)/2);
		end
	end
end
