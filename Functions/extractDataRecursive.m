function extractDataRecursive(Folder)

D = dir(Folder);

if(length(D) > 2)
	for i = 3:length(D)
		if(isdir(fullfile(Folder,D(i).name)))
			extractDataRecursive(fullfile(Folder,D(i).name))
		end
	end
end

try
	% disp(Folder);
	% extractData(Folder);

	if(736895 == floor(D(1).datenum))
		extractData(Folder);
	end
	
catch
	disp(['Can''t analysed ' Folder]);
end
