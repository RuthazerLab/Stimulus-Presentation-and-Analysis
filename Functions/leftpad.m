function S = leftpad(n, siz)

% S = leftpad(n,siz)
% 	Takes a number n and adds zeros to the left
% 	of the most significant digit until n is siz long

if(nargin ~= 2)
	S = 0;
	help leftpad;
	return;
end

n = num2str(n);

if(length(n)>=siz)
	S = n;
else
	for i = 1:siz-length(n)
		S(i) = '0';
	end
	S = [S n];
end
