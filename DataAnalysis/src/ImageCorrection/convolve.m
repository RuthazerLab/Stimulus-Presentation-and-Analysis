function A = convolve(I, option)

% FUNCTION A = convole(I,option)
% 	I is the image on which you wish to run the convolution.
% 	option is an applicable convolution name:
% 
% 	 Edge Detection: "Sobel"
% 			Denoise: "Despeckle" AND "Remove Outlier"
% 	  Gaussion Blur: "Gaussian Blur"
% 			Sharpen: "Sharpen"
% 
% 	Note: function returns image as double


try
	F = str2func(option);
	I = double(I);
	A = F(I);
catch
	disp('***Incorrect Usage');
	help convolve;
	return;
end


% Edge detection with Sobel operator
function S = Sobel(I)

[a b] = size(I);

kernH = [-1 -2 -1; 0 0 0; 1 2 1];
kernV = [-1 0 1; -2 0 2; -1 0 1];

for i = 2:a-1
	for j = 2:b-1
		HS = sum(sum(bsxfun(@times,kernH,I(i-1:i+1,j-1:j+1))));
		VS = sum(sum(bsxfun(@times,kernV,I(i-1:i+1,j-1:j+1))));
		S(i-1,j-1) = sqrt(HS^2+VS^2);
	end
end

% Despeckling with median filter
function S = Despeckle(I)

[a b] = size(I);

for i = 2:a-1
	for j = 2:b-1
		S(i-1,j-1) = median(reshape(I(i-1:i+1,j-1:j+1),[1 9]));
	end
end


% Gaussian Blur with unit standard deviation
function S = GaussianBlur(I)

[a b] = size(I);

kernGB = 1/263 * [1 4 7 4 1; 4 16 26 16 4; 7 26 41 26 7; 4 16 26 16 4; 1 4 7 4 1];

for i = 3:a-2
	for j = 3:b-2
		S(i-2,j-2) = sum(sum(bsxfun(@times,kernGB,I(i-2:i+2,j-2:j+2))));
	end
end

% Sharpens image
function S = Sharpen(I)

[a b] = size(I);

kernS = [-1 -1 -1; -1 12 -1; -1 -1 -1];

for i = 2:a-1
	for j = 2:a-1
		S(i-1,j-1) = sum(sum(bsxfun(@times,kernS,I(i-1:i+1,j-1:j+1))));
	end
end

function I = RemoveOutlier(I)

[a b] = size(I);

for i = 3:a-3
	for j = 3:b-3
		M = median(reshape(I(i-2:i+2,j-2:j+2),[1 25]));
		if(I(i,j) - M == -1)
			I(i-2,j-2) = M;
		end
	end
end