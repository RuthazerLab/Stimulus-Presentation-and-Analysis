h = waitbar(1/length(RoiData), 'Getting Responses', 'Name','Analyzing Data');

for i = 1:length(RoiData)

  waitbar(i/length(RoiData),h,'Getting Responses');

  % for j = 1:length(RoiData)
  %   temp = corrcoef(AnalysedData.dFF0(i,:),AnalysedData.dFF0(j,:));
  %   AnalysedData.XCor(i,j) = temp(2,1);
  % end

  if(StimulusData.Configuration.Type == 1)
    siz = sqrt(StimulusData.Configuration.StimuliCount-1);
    RoiData(i).RF = reshape(AnalysedData.ZScore(i,:),[siz siz]);

  elseif(StimulusData.Configuration.Type == 2)
    siz = (StimulusData.Configuration.StimuliCount-1)/2;
    Q = ones(siz,siz);

    for j = 1:siz
      Q(j,:) = Q(j,:).*repmat(1-AnalysedData.ZScore(i,j),[1 siz]);
      Q(:,j) = Q(:,j).*repmat(1-AnalysedData.ZScore(i,j+siz),[siz 1]);
    end
    
    RoiData(i).RF = Q;
  end
  if(StimulusData.Configuration.Type == 1 || StimulusData.Configuration.Type == 2)

    % Z = RoiData(i).RF;
    % Y = []; X = [];
    % for a = 1:siz
    %   for b = 1:siz
    %     Y(end+1:end+max(floor(Z(a,b)*1000),1)) = a;
    %     X(end+1:end+max(floor(Z(a,b)*1000),1)) = b;
    %   end
    % end
    % Z = [Y' X'];
    % RoiData(i).RFmu = mean(Z); RoiData(i).RFsigma = cov(Z);

    % CenterPosition(i,:) = [RoiData(i).RFmu];
    % CenterVariance(i,:) = [RoiData(i).RFsigma(1,1) RoiData(i).RFsigma(2,2)];

    RoiData(i).RFmu(1) = find(AnalysedData.ZScore(i,1:7) == max(AnalysedData.ZScore(i,1:7)));
    RoiData(i).RFmu(2) = find(AnalysedData.ZScore(i,8:14) == max(AnalysedData.ZScore(i,8:14)));
  else
    RoiData(i).RFmu(1) = find(AnalysedData.ZScore(i,:) == max(AnalysedData.ZScore(i,:)));
    RoiData(i).RFmu(2) = RoiData(i).RFmu(1);  
  end
end

delete(h);
