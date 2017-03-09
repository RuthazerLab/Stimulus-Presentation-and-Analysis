function getRFMap2(Roi,StimulusData,Config)

siz = Config.Number^0.5;
typ = Config.Type;

switch typ

case 1  % Random Squares
	Q = reshape(StimulusData.Responses(2:end,Roi),[siz siz]);

	control = StimulusData.Responses(1,Roi);

	% Shows heatmap of receptivity as percent above control
	% figure;
	imagesc((Q-control)./std(StimulusData.Responses(2:end,Roi))); title(['Roi ' int2str(Roi) ' responses']); axis square;  

	% Sets colour axis from absolution value of lower percent to upper percent,
	% to get some measure of normal variance in brightness
	CLim = get(gca,'Clim'); 
	set(gca,'CLim',[0 3]);
	% if(abs(CLim(1)) > CLim(2))
	% 	set(gca,'CLim',[CLim(2)+1 CLim(2)+2]);
	% else
	% 	set(gca,'Clim',[abs(CLim(1)) CLim(2)]); 
	% end
	colorbar;

case 5  % Balanced Squares

	% Breaks stimuli in up and down stimuli
	Q1 = reshape(StimulusData.Responses(siz^2+2:end,Roi),[siz siz]);
	Q2 = reshape(StimulusData.Responses(1:siz^2,Roi),[siz siz]);

	control = StimulusData.Responses(siz^2+1,Roi);
	
	% Shows heatmap of receptivity as percent above control
	% figure;
	subplot(1,2,1), imagesc(Q1-control); title(['ROI ' int2str(Roi) ' on responses']);
	ax.XTick = []; ax.YTick = []; axis square; %set(gca,'Clim',CLim);
	CLim = get(gca,'Clim'); 
	if(abs(CLim(1)) > CLim(2))
		set(gca,'CLim',[CLim(2)+1 CLim(2)+2]);
	else
		set(gca,'Clim',[abs(CLim(1)) CLim(2)]); 
	end

	subplot(1,2,2), imagesc(Q2-control); title(['ROI ' int2str(Roi) ' off responses']);
	ax.XTick = []; ax.YTick = []; axis square; %set(gca,'Clim',CLim);
	CLim = get(gca,'Clim'); 
	if(abs(CLim(1)) > CLim(2))
		set(gca,'CLim',[CLim(2)+1 CLim(2)+2]);
	else
		set(gca,'Clim',[abs(CLim(1)) CLim(2)]); 
	end

case 6  % Bars

	siz = Config.Number/2;
	T = StimulusData.Responses(2:end,Roi);
	Q = ones(siz,siz);
	for i = 1:siz
		Q(i,:) = Q(i,:).*repmat(T(i),[1 siz]);
		Q(:,i) = Q(:,i).*repmat(T(i+siz),[siz 1]);
	end

	control = StimulusData.Responses(1,Roi);


	imagesc((Q-control)./std(StimulusData.Responses(2:end,Roi))); title(['Roi ' int2str(Roi) ' responses']); axis square;  

	% CLim = get(gca,'Clim'); 
	% set(gca,'CLim',[0 3]);

	% Sets colour axis from absolution value of lower percent to upper percent,
	% to get some measure of normal variance in brightness
	% CLim = get(gca,'Clim'); 
	% set(gca,'CLim',[0 3]);
	% if(abs(CLim(1)) > CLim(2))
	% 	set(gca,'CLim',[CLim(2)+1 CLim(2)+2]);
	% else
	% 	set(gca,'Clim',[abs(CLim(1)) CLim(2)]); 
	% end
	colorbar;

otherwise
	imagesc(StimulusData.Responses(:,Roi));

end  	
