function List = readLines(fileName)

% List = readLines(fileName)
% 	Reads lines of txt file and returns cell
% 	array, or 'No Data.' if no data.

if(nargin ~= 1)
	List = 'Error.';
	help readLines;
	return;
end

	
fid = fopen(fileName);

if(fid ~= -1)
	tline = fgetl(fid);

	List = cell(0,1);

	while ischar(tline)
		List{end+1,1} = tline;
    	tline = fgetl(fid);
	end
	fclose(fid);
else
	List = 'No Data.';
end

return;