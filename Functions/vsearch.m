function Row = vsearch(A, target, column)
% Row = vsearch(A, target, column)
% 	A: the matrix you are searching
% 	column: the column in A you are searching
% 	target: what you are searching for

if(nargin ~= 3)
	help vsearch;
	Row = null(1);
	return
end

Row = 0;
for i = 1:length(A)
	if(A(i,column) == target)
		Row = i;
		return;
	end
end

