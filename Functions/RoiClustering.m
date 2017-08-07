function Cluster = RoiClustering(AnalysedData, header)

% function Cluster = RoiClustering(AnalysedData, header)
% 
% 	Generates clusters of mutually correlated ROIs. Itteratively, the top 2 
% 	correlated ROIs/clusters are merged in to a cluster and the "cluster signal" is 
% 	the average of the two. The new cluster is then treated as an ROI. This continues
% 	until no signals have a correlation of greater than 0.4

try
	Vectors = AnalysedData.dFF0';
catch
	Vectors = AnalysedData';
end
[Frames RoiCount] = size(Vectors);
Cluster = [];
RoiList = [1:RoiCount];
ClusterIndices = [];

MinCorrelation = 0.5;

Corr = corr(Vectors);


h = waitbar(0,'Correlation: 1', 'Name','Clustering ROIs...');

while true

Maximum = 0;

for a = 1:size(Corr,1)-1

	[values indices] = sort(Corr(a,a+1:end),2,'descend');
	if(Maximum < values(1))
		Maximum = values(1);
		indexVector1 = a;
		indexVector2 = indices(1)+a;
	end

end

% Dependings on the identity of the two objects (ROIs or clusters)
% different things happen.
MrgLogic = [isCluster(indexVector1) isCluster(indexVector2)];

if(Maximum < MinCorrelation && sum(MrgLogic) == 2)
	delete(h);
	return
end

if(sum(MrgLogic) == 0)


	waitbar((Maximum-MinCorrelation)/(1-MinCorrelation),h,['ROI ' num2str(RoiList(indexVector1)) ' + ROI ' num2str(RoiList(indexVector2)) ': Corr = ' num2str(Maximum)]);

	Cluster(end+1).ROIs = [indexVector1 indexVector2];
	Cluster(end).Vector = mean(Vectors(:,Cluster(end).ROIs),2);

	removeVectors([indexVector1,indexVector2]);
	Vectors(:,end+1) = Cluster(end).Vector;

	removeCorrs([indexVector1,indexVector2])
	calCorr(size(Vectors,2))


elseif(sum(MrgLogic) == 2)

	index1 = findCluster(indexVector1);
	index2 = findCluster(indexVector2);

	waitbar((Maximum-MinCorrelation)/(1-MinCorrelation),h,['Cluster ' num2str(index1) ' + Cluster ' num2str(index2) ': Corr = ' num2str(Maximum)]);

	mergeClusters(index1,index2);

	Vectors(:,indexVector1) = Cluster(index1).Vector;
	removeVectors([indexVector2]);

	removeCorrs(indexVector2)
	calCorr(indexVector1);	

elseif(MrgLogic(1))

	index = findCluster(indexVector1);
	l = length(Cluster(index).ROIs);

	waitbar((Maximum-MinCorrelation)/(1-MinCorrelation),h,['Cluster ' num2str(index) ' + ROI ' num2str(RoiList(indexVector2)) ': Corr = ' num2str(Maximum)]);

	Cluster(index).ROIs = [Cluster(index).ROIs indexVector2];
	Cluster(index).Vector = mean([Cluster(index).Vector;Vectors(indexVector2,:)],1);

	Vectors(:,indexVector1) = Cluster(index).Vector;
	ClusterIndices = [ClusterIndices indexVector1];
	removeVectors([indexVector2]);

	removeCorrs(indexVector2)
	calCorr(indexVector1-1);

elseif(MrgLogic(2))

	index = findCluster(indexVector2);
	l = length(Cluster(index).ROIs);

	waitbar((Maximum-MinCorrelation)/(1-MinCorrelation),h,['ROI ' num2str(RoiList(indexVector1)) ' + Cluster ' num2str(index) ': Corr = ' num2str(Maximum)]);

	Cluster(index).ROIs = [Cluster(index).ROIs indexVector1];
	Cluster(index).Vector = mean([Cluster(index).Vector Vectors(:,indexVector1)],2);

	Vectors(:,indexVector2) = Cluster(index).Vector;
	ClusterIndices = [ClusterIndices indexVector2];
	removeVectors([indexVector1]);

	removeCorrs(indexVector1)
	calCorr(indexVector2-1);

end

end
	
	function removeVectors(inputs)
		inputs = sort(inputs,'descend');
		for i = 1:length(inputs)
			if(inputs(i) == length(RoiList))
				RoiList = RoiList(1:end-1);
			elseif(inputs(i) < length(RoiList))
				RoiList = [RoiList(1:inputs(i)-1) RoiList(inputs(i)+1:end)];
			end
			Vectors = [Vectors(:,1:inputs(i)-1) Vectors(:,inputs(i)+1:end)];
		end
	end 
	
	function calCorr(index)
		B = Vectors(:,index);
		if(index == size(Vectors,2))
			Range = [1:size(Vectors,2)-1];
		else
			Range = [1:index-1 index+1:size(Vectors,2)];
		end

		temp = corr(B,Vectors(:,Range));

		Corr(Range,index) = temp';
		Corr(index,Range) = temp;
	end

	function removeCorrs(inputs)
		inputs = sort(inputs,'descend');
		for i = 1:length(inputs)
			Corr = [Corr(:,1:inputs(i)-1) Corr(:,inputs(i)+1:end)];
			Corr = [Corr(1:inputs(i)-1,:); Corr(inputs(i)+1:end,:)];
		end
	end

	function mergeClusters(index1, index2)
		ROIs = [Cluster(index1).ROIs Cluster(index2).ROIs];
		Vector = mean([Cluster(index1).Vector Cluster(index2).Vector],2);
		Temp = Cluster;
		Temp(index1).ROIs = ROIs;
		Temp(index1).Vector = Vector;
		Cluster = [];
		for i = 1:index2-1
			Cluster(i).ROIs = Temp(i).ROIs;
			Cluster(i).Vector = Temp(i).Vector;
		end
		if(index2 == length(Temp))
			return;
		end
		for i = index2+1:length(Temp)
			Cluster(i-1).ROIs = Temp(i).ROIs;
			Cluster(i-1).Vector = Temp(i).Vector;
		end
	end

	function output = isCluster(index)
		output = false;
		if(index > length(Corr) - length(Cluster))
			output = true;
		end
	end

	function output = findCluster(index)
		output = length(Cluster) - (length(Corr) - index);
	end

end