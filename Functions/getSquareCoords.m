function [a b] = getSquareCoords(P,siz)

% [a b] = getSquareCoords(P,siz)
% 	Finds square coordinate corresponding to P.
% 	e.g.
% 		1  4  7
% 		2  5  8
% 		3  6  9
% 
% 		6 is at position 6. The square coordinates of 6 for
% 		a 3x3 grid is [2 3]
% 
% 

if(nargin ~= 2)
	a = 0; b = 0;
	help getSquareCoords;
	return;
end

a = floor(P/siz) + 1;
b = mod(P,siz);

if(b == 0) 
	b = siz; 
	a = a - 1;
end