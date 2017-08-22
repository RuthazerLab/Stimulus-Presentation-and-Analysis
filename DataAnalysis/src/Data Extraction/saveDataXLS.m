function saveDataXLS(Folder)

warning('off','MATLAB:xlswrite:AddSheet');

F = dir(Folder);
% Calculates minimum Roi Count

F = dir(Folder);
% Calculates minimum Roi Count
RoiMin = inf;
for i = 3:length(F)
  if(exist(fullfile(Folder,F(i).name,['Analysed ' F(i).name '.mat'])))
    load(fullfile(Folder,F(i).name,['Analysed ' F(i).name '.mat']));
    L(i) = 1;
  else
    if(isdir(F(i).name))
      disp(['Can''t find ' fullfile(Folder,F(i).name,['Analysed ' F(i).name '.mat'])]);
    end
    L(i) = 0;
  end
end

L = find(L)

[a Group] = fileparts(Folder);
[a Stim] = fileparts(a);

% Samples information from each fish
for i = 1:length(L)
  load(fullfile(Folder,F(L(i)).name,['Analysed ' F(L(i)).name '.mat']));

  for i = 1:length(RoiData)
    R1 = fitlm([1:11],AnalysedData.Responses(i,:));
    R2 = fitlm([1:10],AnalysedData.ZScore(i,:));
    FLM(i,1) = R1.Coefficients.Estimate(1);
    FLM(i,2) = R1.Coefficients.Estimate(2);
    FLM(i,3) = R1.Rsquared.Ordinary
    ZLM(i,1) = R1.Coefficients.Estimate(1);
    ZLM(i,2) = R1.Coefficients.Estimate(2);
    ZLM(i,3) = R1.Rsquared.Ordinary
  end
  
  switch Stim
    case 'Brightness'
      Title = [{'RoiNum','Blank'} num2cell([0.1:0.1:1]) {'X-Int','Slope','R^2'}];
    case 'Direction'
      Title = [{'Blank'} num2cell([30:30:360])];
    case 'Spatial'
      CPD = repmat(800,[1 18])./compFact(800);
      Title = [{'Blank'} num2cell(CPD(1:16))];
    otherwise
      continue;
  end

  dF(1:length(RoiData),1) = [1:length(RoiData)];
  zS(1:length(RoiData),1) = [1:length(RoiData)];
  dF(1:length(RoiData),1:11) = AnalysedData.Responses;
  zS(1:length(RoiData),1:10) = AnalysedData.ZScore;
  dF(1:length(RoiData),1:3) = FLM;
  zS(1:length(RoiData),1:3) = ZLM;

  xlswrite([Stim '.' Group '.' F(L(i)).name '.xlsx'],[Title; num2cell(dF)],'DeltaF');
  xlswrite([Stim '.' Group '.' F(L(i)).name '.xlsx'],[Title([1 3:end]); num2cell(zS)],'ZScore');
end
