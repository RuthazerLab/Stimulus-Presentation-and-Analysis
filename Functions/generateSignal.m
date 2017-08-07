function [S y Y XCor ZScore] = generateSignal(Template,StimulusData,header,stimLambda,SNR)

% function [S y Y XCor ZScore] = generateSignal(Template,StimulusData,header,stimLambda,SNR,s)
%		 Template:		Average calcium trace (see averageResponse.m)
% 		 StimulusData:	Stimulus Data
% 		 header:		header
% 		 stimLambda:	Average number of spikes for each stimulus (i.e. stimLambda  @(i) i)
% 		 SNR:			Signal-to-Noise ratio

RoiCount = header.RoiCount;
Times = header.Frames;
stimType  = sort(uniqueElements(StimulusData.Raw(:,3)));
stimCount = length(stimType);
critWindow = ceil(header.FPS*2);

% Get stimulus frames
T = floor(StimulusData.Times*header.FPS);
for i = 1:(T(2,1)-T(1,1))
	T = [T T(:,1)+i];
end


%%%%%%%%%%% Spike Train Generator %%%%%%%%%%%
% Time frame for poisson distribution in frames
B = 50;

lambda = 5;

% Find frames for each stimulus type
for i = 1:stimCount
	K(i,:) = find(StimulusData.Raw(:,3) == stimType(i));
end

% Create poisson noise with average lambda spikes per B frames
for i = 0:B:Times
	N(i/B+1) = random('Poisson', lambda);
end
% Randomly place spikes
S = zeros(Times,1);
for i = 1:Times/B
	I = ceil(random('unif',1,B,1,N(i)));
	S(I+(i-1)*B) = 1;
end

% Place random number of spikes after each stimulus
% dictated by stimLambda.
for i = 1:stimCount
	for j = 1:StimulusData.Configuration.Repetitions
		I(i,j) = random('Poisson', stimLambda(i), 1, 1);
		ind = ceil(random('unif',0,2,1,I(i,j)));
		for k = 1:length(ind)
			S(T(K(i,j),1)+ind(k)-1) = S(T(K(i,j),1)+ind(k)-1)+1;
		end
	end
end
%%%%%%%%%%% Spike Train Generator %%%%%%%%%%%



%%%%%%%%%%% Calcium Signal Generator %%%%%%%%%%%
% Convolve the spikes with the average calcium trace.
C = conv(S,Template);

% White-noise at 10% baseline
BaseLin = 400;
y = C*SNR*BaseLin/10+wgn(length(C),1,0.00001)*BaseLin/10+400;

% Calculate dF/F
Trace = y';
AvgFrame = 2; BLThresh = 200;

av = Smooth(Trace,[-AvgFrame, AvgFrame]);

for j = 1:length(Trace)
	F0(j) = min(av(max(j-BLThresh,1):j));
end

Y = (Trace-F0)./F0;
%%%%%%%%%%% Calcium Signal Generator %%%%%%%%%%%


%%%%%%%%%%% Calcium Signal Analysis %%%%%%%%%%%
for i = 1:stimCount
	temp = T(find(StimulusData.Raw(:,3) == stimType(i)),1);
	reps = length(temp);
	for j = 1:reps
		for k = 1:critWindow
			Stimulus(i,critWindow*(j-1)+k) = temp(j) + k;
		end
		mu(i,j) = mean(Y(Stimulus(i,critWindow*(j-1)+1:critWindow*j)));
	end
end

XCor = mu;
Responses = mean(XCor');
Mu = mean(XCor');
STD = std(XCor');

for j = 2:StimulusData.Configuration.StimuliCount
	ZScore(j-1) = (Mu(j)-Mu(1))/sqrt(STD(j)^2/10+STD(1)^2/10);
end
%%%%%%%%%%% Calcium Signal Analysis %%%%%%%%%%%