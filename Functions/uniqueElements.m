function M = uniqueElements(A)

% M = uniqueElements(A) returns vector of unique 
% 	elements in vector A
% 	

 M = [];

for i = 1:length(A);
	if(sum(M == A(i)) == 0)
		M(end+1) = A(i);
	end
end
