function Cluster = RoiClustering(AnalysedData, header)


Vectors = AnalysedData;
[RoiCount Frames] = size(Vectors);
Cluster = [];

Corr = zeros(header.RoiCount,header.RoiCount);
for a = 1:header.RoiCount

	A = Vectors(a,:);
	mA = mean(A);
	sA = std(A);

	for r = a+1:header.RoiCount

		B = Vectors(r,:);
		mB = mean(B);
		sB = std(B);

		for t = 1:Frames/(header.Slices+header.FlyBackFrames)
			temp(t) = (B(t)-mB)*(A(t)-mA)/(sB*sA);
		end

		Corr(a,r) = (header.Slices+header.FlyBackFrames)/Frames*sum(temp);
	end
end

h = waitbar(0,'Correlation: 1', 'Name','Clustering ROIs...');

while true

Maximum = 0;

for a = 1:length(Vectors(:,1))

	waitbar(a/length(Vectors(:,1)),h,['Correlation: ' num2str(Maximum)]);

	for r = a+1:length(Vectors(:,1))

		if(Corr(a,r) > Maximum)
			Maximum = Corr(a,r);
			indexVector1 = a; indexVector2 = r;
		end

	end
end

if(Maximum < 0.5 && sum(MrgLogic) == 2)
	delete(h);
	return
end

MrgLogic = [isCluster(indexVector1) isCluster(indexVector2)];

if(sum(MrgLogic) == 0)

	Cluster(end+1).ROIs = [indexVector1 indexVector2];
	Cluster(end).Vector = mean(Vectors(Cluster(end).ROIs,:));

	removeVectors({indexVector1,indexVector2});
	Vectors(end+1,:) = Cluster(end).Vector;

	removeCorrs({indexVector1,indexVector2})
	calCorr(length(Vectors(:,1)));


elseif(sum(MrgLogic) == 2)

	index1 = findCluster(indexVector1);
	index2 = findCluster(indexVector2);

	mergeClusters(index1,index2);

	Vectors(indexVector1,:) = Cluster(index1).Vector;
	removeVectors({indexVector2});

	removeCorrs({indexVector2})
	calCorr(indexVector1);	

elseif(MrgLogic(1))

	index = findCluster(indexVector1);
	l = length(Cluster(index).ROIs);

	Cluster(index).ROIs = [Cluster(index).ROIs indexVector2];
	Cluster(index).Vector = 1/(l+1)*(l*Cluster(index).Vector + Vectors(indexVector2,:));

	Vectors(indexVector1,:) = Cluster(index).Vector;
	removeVectors({indexVector2});

	removeCorrs({indexVector2})
	calCorr(indexVector1-1);

elseif(MrgLogic(2))

	index = findCluster(indexVector2);
	l = length(Cluster(index).ROIs);

	Cluster(index).ROIs = [Cluster(index).ROIs indexVector1];
	Cluster(index).Vector = 1/(l+1)*(l*Cluster(index).Vector + Vectors(indexVector1,:));

	Vectors(indexVector2,:) = Cluster(index).Vector;
	removeVectors({indexVector1});

	removeCorrs({indexVector1})
	calCorr(indexVector2-1);

end

end
	
	function removeVectors(inputs)
		for i = 1:length(inputs)
			Vectors = [Vectors(1:inputs{i}-1,:); Vectors(inputs{i}+1:end,:)];
		end
	end 
	
	function calCorr(index)
		B = Vectors(index,:);
		mB = mean(B);
		sB = std(B);
		for a = 1:length(Vectors(:,1))
			A = Vectors(a,:);
			mA = mean(A);
			sA = std(A);
			for t = 1:Frames/(header.Slices+header.FlyBackFrames)
				temp(t) = (B(t)-mB)*(A(t)-mA)/(sB*sA);
			end

			if(a < index)
				Corr(a,index) = (header.Slices+header.FlyBackFrames)/Frames*sum(temp);
			else
				Corr(index,a) = (header.Slices+header.FlyBackFrames)/Frames*sum(temp);
			end
		end
	end

	function removeCorrs(inputs)
		for i = 1:length(inputs)
			Corr = [Corr(:,1:inputs{i}-1) Corr(:,inputs{i}+1:end)];
			Corr = [Corr(1:inputs{i}-1,:); Corr(inputs{i}+1:end,:)];
		end
	end

	function mergeClusters(index1, index2)
		ROIs = [Cluster(index1).ROIs Cluster(index2).ROIs];
		Vector = mean([Cluster(index1).Vector;Cluster(index2).Vector]);
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