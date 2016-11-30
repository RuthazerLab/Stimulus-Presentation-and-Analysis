function frame = time2Frame(A,AnalysedData)

% frame = time2Frame(A, AnalysedData) 
% 	returns frame number for times in A

if(nargin ~= 2)
	frame = 0;
	help time2Frame;
	return;
end

for index = 1:length(A)

	frame(index) = 1;
	while AnalysedData.Times(1,frame(index)) < A(index) && frame(index) < length(AnalysedData.Times)
		frame(index) = frame(index) + 1;
	end

end

frame = frame';
