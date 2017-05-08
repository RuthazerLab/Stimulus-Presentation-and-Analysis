Folder = uigetdir;
Folders = {};

d = dir(Folder);

if(sum([d(:).isdir]) == 2)
	[a FolderName] = fileparts(Folder);
	FileNames.String = FolderName;
	Folders{1} = Folder;
	disp(['Analysing ' FolderName]);
else
	S = {};
	Folders = [];
	temp = dir(Folder);
	for f = 3:length(temp)
		if(isdir(fullfile(Folder,temp(f).name)))
			S{end+1} = temp(f).name;
			Folders{end+1} = fullfile(Folder,temp(f).name);
		end
	end
	if(length(S) > 7)
		S{7} = '...';
	end
	FileNames.String = S;

	disp('Analysing: ');
	for i = 1:length(FileNames.String)
		disp(['  -' FileNames.String{i}]);
	end
end


[FolderPath FolderName] = fileparts(Folders{1});

h = waitbar(1/length(Folders), FolderName, 'Name','Analyzing Data');


for i = 1:length(Folders)
	Correct = 1;
	[FolderPath FolderName] = fileparts(Folders{i});

	waitbar(i/length(Folders),h,FolderName);

	extractData(Folders{i});

end
