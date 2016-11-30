function Indicies = IA(X,a0,a1)

% Indicies = IA(X,a0,a1)
% 	Characteristic function: returns indices of X where
% 	x is between a0 and a1

A = X > a0;
B = X < a1;

[siz1 siz2] = size(A);

for i = 1:siz1*siz2
	C(i) = A(i) && B(i);
end

Indicies = find(C);
