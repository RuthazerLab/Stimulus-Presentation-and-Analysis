IJ.run('Open...', ['path=[' Folder '\Slice' int2str(Slice) '.tif]']);
imp = WindowManager.getCurrentImage;

% Get the Roi Manager 
K = plugin.frame.RoiManager.getRoiManager;

% Image analysis
IJ.run('Subtract Background...', 'rolling=7 stack');
IJ.run('Gaussian Blur...', 'sigma=1');
IJ.run('Enhance Contrast', 'saturated=0.35');
imp = WindowManager.getCurrentImage;
imp.setProcessor( inra.ijpb.morphology.Morphology.whiteTopHat( getChannelProcessor(imp), inra.ijpb.morphology.strel.DiskStrel.fromRadius(6) ) );
IJ.setAutoThreshold(imp,'Mean dark');
IJ.run('Convert to Mask');
IJ.run('Watershed');
IJ.run('Remove Outliers...', 'radius=4 threshold=50 which=Dark');
IJ.run('Analyze Particles...', 'clear add stack');
IJ.run('Set Measurements...', 'mean redirect=None decimal=3');
K.runCommand('save',fullfile(Folder,'RoiSet.zip'));    % Save ROI data
% IJ.run('Close All'); 

% Get coordinates from previously saved ROI data
Coords = getRoiCoords(fullfile(Folder,'RoiSet.zip'));
CoordinateCenter = [];
for i = 1:length(Coords)
  temp = Coords{i};
  CoordinateCenter(i,1:2) = min([mean(temp(:,1)) mean(temp(:,2))], [ImageWidth ImageHeight]);
end
CoordinateCenter(:,3) = Slice;

delete(fullfile(Folder,'RoiSet.zip'));
delete(fullfile(Folder,['Slice' int2str(Slice) '.tif']));

 % Save Roi Coordinates in struct
ImageData(Slice) = struct('Slice', Slice, 'Results', [], 'NumOfROIs', length(CoordinateCenter(:,1)), ...
  'RoiCoordinates', transpose(CoordinateCenter),'Average',Average_Images(:,:,Slice), 'XBounds',[],'YBounds',[]);