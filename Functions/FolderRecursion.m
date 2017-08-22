function FolderRecursion(Folder,func)


D = dir(Folder);

if(length(D) > 2)
	for i = 3:length(D)
		if(isdir(fullfile(Folder,D(i).name)))
			FolderRecursion(fullfile(Folder,D(i).name),func);
		end
	end
end

[a b] = fileparts(Folder);

if(exist(fullfile(Folder,['Analysed ' b '.mat'])) & ~exist(fullfile(Folder,['Analysed ' b '-noReg.mat']))) 
	func(Folder);
	disp(['Ran function on ' Folder]);
else
	% disp(['Can''t run function on ' Folder]);
end