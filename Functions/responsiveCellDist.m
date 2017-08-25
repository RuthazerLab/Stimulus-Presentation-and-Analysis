function I = responsiveCellDist(AnalysedData,header)

Responsive_Rois = find(max(AnalysedData.ZScore,[],2)>1.6);

I = zeros(512,512,4);

K(1) = 0;

for i = 1:4
	K(i+1) = K(i) + length(header.RoiMask{i});
	for j = 1:length(header.RoiMask{i})
		p.x = max(min(header.RoiMask{i}{j,1},512),1);
		p.y = max(min(header.RoiMask{i}{j,2},512),1);
		for k = 1:length(p.y)
			I(p.y(k),p.x(k),i) = 0.5;
		end
	end
end

for i = 1:length(Responsive_Rois)
	Slice = find(K>=Responsive_Rois(i))-1; Slice = Slice(1);
	p.x = max(min(header.RoiMask{Slice}{Responsive_Rois(i)-K(Slice),1},512),1);
	p.y = max(min(header.RoiMask{Slice}{Responsive_Rois(i)-K(Slice),2},512),1);
	for j = 1:length(p.y)
		I(p.y(j),p.x(j),Slice) = 1;
	end
end

