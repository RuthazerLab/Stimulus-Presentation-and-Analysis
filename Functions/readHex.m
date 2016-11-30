function List = readHex(fileName, endian, startLine, endLine)

% FUNCTION List = readHex(fileName, endian)
% 	fileName is STRING
% 	endian is 'l' for little and 'b' for big
%	
% FUNCTION List = readHex(fileName, endian, startLine, endLine)
% 	fileName is STRING
% 	endian is 'l' for little and 'b' for big
% 	startLine and endLine are INTEGERs


if(nargin == 2)
	startAt = 0;
	statement = '1';
elseif(nargin == 4)
	assert(startLine ~= 0, 'Index exceeds matrix dimensions.')

	interval = endLine-startLine+1;
	if(interval < 0)
		List = [];
		return;
	end
	statement = ['i < ' int2str(interval)];
	startAt = startLine;
else
	List = 0;
	help readHex;
	return;
end



fid = fopen(fileName,'r',endian);


if(fid ~= -1)
	fseek(fid,16*(startLine-1),-1);
	Line = fread(fid,[1 8],'uint16');

	i = 1;
	while (length(Line) == 8 && eval(statement))
		List(i,:) = Line;
		i = i + 1;
		Line = fread(fid,[1 8],'uint16');
	end
	if(length(Line) > 0)
		List(i,1:length(Line)) = Line;
	end
else
	List = 'No Data.';
end

fclose(fid);
