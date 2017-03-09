function Folders = CompareRF(Folder)

Folders = {'Trial','RoiData','Responsiveness'};
temp1 = dir(Folder);
WhitenessThreshold = 5000;

for f1 = 3:length(temp1)
	temp2 = dir(fullfile(Folder,temp1(f1).name));
	for f2 = 3:length(temp2);
		temp3 = fullfile(fullfile(Folder,temp1(f1).name),temp2(f2).name);
		if(exist(fullfile(temp3,['Analysed ' temp2(f2).name '.mat'])))
			Folders{end+1,1} = temp2(f2).name;
			temp4 = [];
			temp5 = [];
			temp6 = [];

			load(fullfile(temp3,['Analysed ' temp2(f2).name '.mat']));

			try
				for r = 1:length(RoiData)
					if(RoiData(r).AutoCorrelation > WhitenessThreshold)
						CorMatrix = RoiData(r).RFsigma;
						temp4(end+1,:) = [CorMatrix(1,1) CorMatrix(2,2)];
						temp5(end+1,:) = RoiData(r).RFmu;
						temp6(end+1,:) = RoiData(r).Coordinates;
					end
				end
			catch
				disp('Data not compatible');
				continue;
			end
			Folders{end,2} = struct('RFXVar',temp4(:,1),'RFYVar',temp4(:,2),'RFXMean',temp5(:,1),'RFYMean',temp5(:,2), ...
				'XCo',temp6(:,1),'YCo',temp6(:,2),'ZCo',temp6(:,2));
			Folders{end,3} = round(length(temp5)/length(RoiData),3);
		end
	end
end