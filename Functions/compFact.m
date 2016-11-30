function fact = compFact(n)

% fact = compFact(n)
% 	Returns the factors of n

if(nargin ~= 1)
	fact = 0;
	help compFact;
	return;
end

fact = [];

for i = 1:n
	if(mod(n,i) == 0)
		fact = [fact i];
	end
end