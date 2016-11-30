function [div rem] = mdivide(n,m)

	% [div rem] = mdivide(n,m)
	% 	Takes integers n,m and return div and rem 
	% 	such that n = div * m + rem

	if(nargin ~= 2)
		div = 0; rem = 0;
		help mdivide;
		return;
	end
	div = floor(n/m);
	rem = mod(n,m);
end
