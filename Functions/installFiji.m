function installFiji

disp('For Windows 64-bit, enter 1.');
disp('For MacOS, enter 2. ');
OS = input('-----> ');
disp('Please wait... ');

switch OS

case 1
	outfilename = websave('Fiji','https://downloads.imagej.net/fiji/latest/fiji-win64.zip');
case 2
	outfilename = websave('Fiji','https://downloads.imagej.net/fiji/latest/fiji-macosx.dmg');

end

Folder = input('Where do you want to save Fiji? ','s');
disp('Saving... ');

unzip(outfilename,Folder);
delete(outfilename);

Path = fullfile(Folder,'Fiji.app','scripts');
addpath(Path);

disp('Path added.');


