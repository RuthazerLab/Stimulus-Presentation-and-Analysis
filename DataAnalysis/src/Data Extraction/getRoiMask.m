function A = getRoiMask(Folder,Slice)

[Path ExperimentName] = fileparts(Folder);
fileName = [ExperimentName '.mat'];

% Add ImageJ library to JAVACLASSPATH
jarDir = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))),'ext');
javaaddpath(fullfile(jarDir,'MorphoLibJ_-1.3.1.jar'));
javaaddpath(fullfile(jarDir,'ij-1.51n.jar'));
import ij.process.*;
import ij.*;

ImageName = fullfile(Folder,['Slice' int2str(Slice) '.tif']);
if(~exist(ImageName))
	load(fileName);
	I = ImageData(Slice).Average;
	if(size(I,3) ~= 1)
		I = ImageData(Slice).Average(:,:,Slice);
	end
	imwrite(suint16(I),ImageName,'tif');
end
IJ.run('Open...', ['path=[' ImageName ']']);
imp = WindowManager.getCurrentImage;
% Get the Roi Manager
K = plugin.frame.RoiManager.getRoiManager;
% Image analysis
IJ.run('Subtract Background...', 'rolling=7 stack');
imp.setProcessor( inra.ijpb.morphology.Morphology.whiteTopHat( getChannelProcessor(imp), inra.ijpb.morphology.strel.DiskStrel.fromRadius(6) ) );
IJ.run('Enhance Contrast', 'saturated=0.35');
IJ.setAutoThreshold(imp,'MinError dark');
IJ.run('Convert to Mask');
IJ.run('Remove Outliers...', 'radius=4 threshold=50 which=Dark');
IJ.run('Watershed');
IJ.run('Open');
IJ.run('Analyze Particles...', 'clear add stack');
IJ.run('Set Measurements...', 'mean redirect=None decimal=3');
rois = K.getRoisAsArray;

if(length(rois) == 0)
	ME = MException('MATLAB:actionNotTaken','No ROIs detected!');
	throw(ME);
end

A = {};
RoiCoordinates = zeros(3,length(rois));
for r = 1:length(rois)
	roi = rois(r);
	points = roi.getContainedPoints;
	Coords = zeros(length(points),3);
	temp = [];
	for p = 1:length(points)
		temp(:,p) = [points(p).x points(p).y]';
	end
	A{r,1} = temp(1,:);
	A{r,2} = temp(2,:);
end