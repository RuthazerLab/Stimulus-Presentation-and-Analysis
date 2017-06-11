  temp = {'Random Squares'; 'RF Bars';'Brightness Levels'; 'Spatial Frequency'; 'Direction'; 'Orientation'};
  StimulusData.Configuration.Type = temp{StimulusData.Configuration.Type};

  a = [{'Times','Frame','Stimulus'};num2cell(StimulusData.Raw(:,2)),num2cell(time2Frame(StimulusData.Raw(:,2),AnalysedData)),num2cell(StimulusData.Raw(:,3))];
  b = [fieldnames(StimulusData.Configuration) struct2cell(StimulusData.Configuration)];

  X = [];

  for i = 1:length(RoiData)
    X(:,i) = mean(RoiData(i).XCor');
  end

  c = [{''},num2cell(sort(uniqueElements(StimulusData.Raw(:,3))));num2cell([[1:length(RoiData)]' X'])];
  d = [{''},num2cell(sort(uniqueElements(StimulusData.Raw(find(StimulusData.Raw(:,3)),3)))); num2cell([[1:length(RoiData)]' AnalysedData.pValues])];

  e = [fieldnames(header) struct2cell(header)];

  xlswrite([fullfile(Folder,header.FileName(1:end-4)) '.xlsx'],b,'MetaData');
  xlswrite([fullfile(Folder,header.FileName(1:end-4)) '.xlsx'],e,'MetaData','D1');
  xlswrite([fullfile(Folder,header.FileName(1:end-4)) '.xlsx'],a,'Stimulus Times');
  xlswrite([fullfile(Folder,header.FileName(1:end-4)) '.xlsx'],c,'ROI Responses');
  xlswrite([fullfile(Folder,header.FileName(1:end-4)) '.xlsx'],d,'pValues');