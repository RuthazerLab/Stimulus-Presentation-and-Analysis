Corr = zeros(header.RoiCount,header.RoiCount);
for a = 1:header.RoiCount

	A = AnalysedData.dFF0(a,:);
	mA = mean(A);
	sA = std(A);

	for r = a:header.RoiCount

		B = AnalysedData.dFF0(r,:);
		mB = mean(B);
		sB = std(B);

		for t = 1:header.Frames/(header.Slices+header.FlyBackFrames)
			temp(t) = (B(t)-mB)*(A(t)-mA)/(sB*sA);
		end

		Corr(a,r) = (header.Slices+header.FlyBackFrames)/header.Frames*sum(temp);
	end

end
B = Corr' + Corr;
B(1:length(B)+1:end) = diag(Corr);
Corr = B;

clearvars A B a mA mB r sA sB t temp;