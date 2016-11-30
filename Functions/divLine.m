% Input the two ROIs you wish to use to define your
% 	dividing line. Saves under RoiData(k).Contra whether 
% 	Roi k is left or right of the line. Must have RoiData
% 	in workspace.

try

a = input('ROI 1: ');
b = input('ROI 2: ');

x1 = RoiData(a).Coordinates(1);
x2 = RoiData(b).Coordinates(1);
y1 = RoiData(a).Coordinates(2);
y2 = RoiData(b).Coordinates(2);

m = (y2-y1)/(x2-x1);

f = @(x) m*(x-x1) + y1;


for k = 1:length(RoiData)
	if(RoiData(k).Coordinates(2) > f(RoiData(k).Coordinates(1)))
		RoiData(k).Contra = true;
	else
		RoiData(k).Contra = false;
	end
end

catch
	help divLine
end