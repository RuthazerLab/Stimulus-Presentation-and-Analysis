function Stimuli = tabulate(ST)

% Stimuli = tabulate(ST)
% 	Takes the output of readLines and
% 	converts cells into a matrix of numbers

if(nargin ~= 1)
	help tabulate;
	Stimuli = 0;
	return;
end

wide = length(strsplit(ST{1},','));

K = zeros(length(ST),wide);

for i = 1:length(ST)

	temp = strsplit(ST{i},',');

	for j = 1:wide
		try
			K(i,j) = str2num(temp{j});
		catch 
			Stimuli = 'Incorrect Usage';
			return;
		end
	end
	
end

Stimuli = K;

