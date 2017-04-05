function [Coords RFmu] = plotTop(HV,XY)

AnalysedData =  evalin('base','AnalysedData');
RoiData = evalin('base','RoiData');

RFmu = []; Coords = [];
for i = 1:length(RoiData)
	if(AnalysedData.Responsive(i) > 0.99)
		continue;
	end
	Coords(end+1,:) = RoiData(i).Coordinates;
	RFmu(end+1,:) = RoiData(i).RFmu;
	end

for i = 1:4
	subplot(2,2,i);
	scatter(Coords(Coords(:,3)==i,XY),RFmu(Coords(:,3)==i,HV),'filled')
	disp(['Slice ' int2str(i) ': ' num2str(corr(Coords(Coords(:,3)==i,XY),RFmu(Coords(:,3)==i,HV)))]);
end