function [Coords] = getRoiCoords(FileList)

% getRoiCoords is adapted from ReadImageJROI.m created by
% Dylan Muir <dylan.muir@unibas.ch>.
%
% Usage: [Coords] = getRoiCoords(FileList)
%  FileList can be the path to ImageJ ROI binary file or
%  the path to a ImageJ-generated zip file for ROI data.
% 

if(nargin ~= 1)
   disp('***Incorrect Usage of getRoiCoords');
   help getRoiCoords;
   return;
end

if (iscell(FileList))
  
   Coords = [cellfun(@getRoiCoords, Linearize(FileList), 'UniformOutput', false)];
   return;

end

FileName = FileList;
clear FileList;

[a, b, ext] = fileparts(FileName);

if (isequal(ext, '.zip'))

   FileNames = ZippedFiles(FileName);
   
   Dir = tempname;
   unzip(FileName, Dir);
   
   for i = 1:length(FileNames)
      FileList{1, i} = fullfile(Dir,char(FileNames(i, 1)));
   end

   Coords = getRoiCoords(FileList);

   delete(fullfile(Dir,'*.roi'));
   rmdir(Dir);

   return;
end


fileID = fopen(FileName, 'r', 'ieee-be');

fseek(fileID, 8, -1);

Bounds = fread(fileID, [1 4], 'int16');
nNumCoords = fread(fileID, 1, 'uint16');

fseek(fileID, 64,-1);


vnX = fread(fileID, [nNumCoords 1], 'int16');
vnY = fread(fileID, [nNumCoords 1], 'int16');

% - Trim at zero
vnX(vnX < 0) = 0;
vnY(vnY < 0) = 0;

% - Offset by top left ROI bound
vnX = vnX + Bounds(2);
vnY = vnY + Bounds(1);

Coords = [vnX vnY];

% Coords = min([mean(vnX) mean(vnY)], [512 512]);

% Coords = [mean(Bounds(4),Bounds(2)) mean(Bounds(3),Bounds(1)];

fclose(fileID);

   function [files] = ZippedFiles(zipFilename)
      import java.util.zip.*;
      import java.io.*;
      
      files={};
      Buffer = ZipInputStream(FileInputStream(zipFilename));
      file = Buffer.getNextEntry();
      
      while (file ~= 0)
         files = cat(1,files,char(file.getName));
         file = Buffer.getNextEntry();
      end
      
      Buffer.close();
   end


   function [cellArray] = Linearize(FileArgs)

      if (iscell(FileArgs{1}))
         cellArray = Linearize(FileArgs{1}{:});
      else
         cellArray = FileArgs(1);
      end
      
      for (nIndexArg = 2:length(FileArgs))
         if (iscell(FileArgs{nIndexArg}))
            cellReturn = Linearize(FileArgs{nIndexArg}{:});
            cellArray = [cellArray cellReturn{:}];
         else
            cellArray = [cellArray FileArgs{nIndexArg}];
         end
      end
      
   end

end