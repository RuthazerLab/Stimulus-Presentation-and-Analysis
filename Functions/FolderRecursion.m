function FolderRecursion(Folder,func)


D = dir(Folder);

if(length(D) > 2)
	for i = 3:length(D)
		if(isdir(fullfile(Folder,D(i).name)))
			FolderRecursion(fullfile(Folder,D(i).name),func);
		end
	end
end

try
	func(Folder);
	disp(['Ran function on ' Folder]);
catch
	disp(['Can''t run function on ' Folder]);
end