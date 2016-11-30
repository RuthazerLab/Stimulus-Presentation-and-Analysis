function A = subBack(I, r)

I = double(I);

for i= 1+r:512-r
	for j = 1+r:512-r

		minimum = inf;

		for j2 = -r:r
			for i2 = -r:r
				if(j2^2 + i2^2 < r^2 && I(i+i2,j+j2) < minimum)
					minimum = I(i+i2,j+j2);
				end
			end
		end

		Erod(i-r:i+r,j-r:j+r) = minimum;

	end
end

A = I - Erod;