function plotRF(dataName)

% This function is similar to getRFMap, however it plots multiple ROI
% receptive maps in a grid.

load(dataName)

% Plot all ROIs between the two user inputs.
k = input('ROI 1: ');
l = input('ROI 2: ');

% Insures ROIs are in correct order
if(l - k < 0)
	disp('Incorrect Usage');
	return;
end

% Creates grid of 5x5 fields that is 20 across.
[m n] = mdivide(l-k,20);
m = m + 1;
Q = zeros(m*5,100*(m ~= 1)+n*(m == 1));


% Loops through each ROI and all their respective responses
for j = k:l
	for i = 2:length(RoiData(j).Responded)

		% Finds which square corresponds to the stimulus
		P(i) = StimulusData.Raw(find(StimulusData.Raw == RoiData(j).Responded(i))+length(StimulusData.Raw));
		[a b] =  mdivide(P(i),5);
		[c d] = mdivide(j-k+1, 20);
		if(b == 0) b = 5; end
		if(a == 5) a = 4; end

		% Incriments the square region if cell responded to stimulus there
		Q(c*5+a+1, d*5+b) = Q(c*5+a+1, d*5+b) + 1;
	end 
end

image(.5,.5,Q,'CDataMapping','scaled'); ax = gca; ax.CLim = [0 5]; colorbar; title(['Region of Interests ' int2str(k) ' to ' int2str(l)]);

ax.XTick = [0:5:100];
ax.YTick = [0:5:l-k+1];
ax.XAxisLocation = 'top';
ax.DataAspectRatio = [1 1 1];

for i= 1:length(ax.XTickLabel)
	ax.XTickLabel{i} = int2str(i);
end
for i = 1:length(ax.YTickLabel)
	ax.YTickLabel{i} = int2str(i);
end