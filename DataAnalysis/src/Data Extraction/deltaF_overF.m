function D = deltaF_overF(RoiData, tau0, AvgFrame, BLThresh)
% deltaF_overF is adapted from the section "Calculuation of Calcium
% Signal" from the paper "In vivo two-photon imaging of sensory-evoked 
% dendritic calcium signals in cortical neurons" by  Hongbo Jia and 
% Nathalie L Rochefort.
%
% Usage: D = deltaF_overF(RoiData,tau0)
% 	RoiData is stuct field generated by imanalyse.m
% 	tau0 is a noise-filtering parameter.


% Initialize variables and adjusted to avoid perturbation
% due to convolution-related field shrinkage

AvgFrame = 2;

% Weighting parameter such that exp(-abs(k)/tau0) > 0.001
N = ceil(3*tau0/log10(exp(1)));

h = waitbar(1/length(RoiData), 'Please Wait...', 'Name','Baselining');

for i = 1:length(RoiData)
	
	% Raw data for each ROI, 1 by FrameCount matrix
	Trace = RoiData(i).Brightness;

	av = Smooth(Trace,[-AvgFrame, AvgFrame]);

	for j = 1:length(Trace)
		F0(j) = min(av(max(j-BLThresh,1):j));
	end
	
	R = (Trace'-F0)./F0;

	waitbar(i/(length(RoiData)),h);

	D(i,:) = R;

end

if(sum(isnan(D)) > 0)
	frame = find(isnan(D(1,:)));
	disp(['Error: Data has 0 brightness at frame ' num2str(frame)]);
end

delete(h);

function G = denoise(R,t,N,tau0)
	G = 0;
	num = 0;
	den = 0;

	% exp(-abs(k)/tau0) -> 0 as k -> Inf, with the rate
	% determined by tau0. N is determined to reduce 
	% calculation time (otheriwse by the time we get to 
	% the last time point we would be looping through 
	% all previous time points.)
	for k = 0:min(t-1,N)
		num = num + R(t-k)*exp(-abs(k)/tau0);
		den = den + exp(-abs(k)/tau0);
	end
	G = num/den;
