function output = vectCond(A,Conditionals)


bool = ones(1,length(A));
for i = 1:length(A)
	for c = 1:length(Conditionals)
		temp = Conditionals{c};
		bool(i) = bool(i) & temp(i);
	end
end

output = A(bool);

