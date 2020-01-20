function compareSpatial(pThresh,ZThresh)


%%%%%%%%%%%%%%% Folders for Control and LPS Sampled.mat Files %%%%%%%%%%%%%%% 

Folders{1} = 'E:\Documents\Work\RuthazerLab\Data\Spatial\Control\';
Folders{2} = 'E:\Documents\Work\RuthazerLab\Data\Spatial\LPS\';

%%%%%%%%%%%%%%% --------------------------------------------- %%%%%%%%%%%%%%% 


T = compFact(800); T = T(3:end);
hold off;
for i = 1:length(Folders)
	load(fullfile(Folders{i},'Sampled.mat'));
	zz = squeeze(ZScore(:,1,:));

	% The finds all cells such that:
	% The slope's p-value is less that pThresh (is the slope actually nonzero?)
	% The slope is negative
	% We are confident the cell is actually responding
	[a,b] = find((LM.SlopeP < pThresh).*(LM.Slope<0).*(zz>ZThresh));
	for i = 1:max(b)
		temp = mean(ZScore(a(b==i),:,i));
		M(i,:) = temp/max(temp);
	end
	errorbar(T,mean(M),std(M)/sqrt(max(b)),'LineWidth',1); hold on;
end
line([T(1) T(end)],[0,0],'Color','k')


set(gca,'XScale','log');
set(gca,'XTick',[4,16,64,256])
xlim([T(1) T(end)]);
xlabel('Period of Spatial Grating')
ylabel('Z/Z_{max}')
legend('Control','LPS')
set(gca,'FontSize',12);
set(gca,'LineWidth',1);
