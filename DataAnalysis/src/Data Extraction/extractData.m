function header = extractData(Folder, ImageData)

% header = extractData3(Folder)
%   Takes experiment folder and outputs analysed image data
% 
% 

  abort = 0;

  if(~exist(fullfile(Folder,'Episode001.h5')))
    disp([Folder ' is missing Episode001.h5']);
    abort = 1;
  end
  if(~exist(fullfile(Folder,'Experiment.xml')))
    disp([Folder ' is missing Experiment.xml']);
    abort = 1;
  end
  if(~exist(fullfile(Folder,'Image_0001_0001.raw')))
    disp([Folder ' is missing Image_0001_0001.raw']);
    abort = 1;
  end
  if(~exist(fullfile(Folder,'StimulusConfig.txt')))
    disp([Folder ' is missing StimulusConfig.txt']);
    abort = 1;
  end
  if(~exist(fullfile(Folder,'StimulusTimes.txt')))
    disp([Folder ' is missing StimulusTimes.txt']);
    abort = 1;
  end
  if(~exist(fullfile(Folder,'ThorRealTimeDataSettings.xml')))
    disp([Folder ' is missing ThorRealTimeDataSettings.xml']);
    abort = 1;
  end

  if(abort)
    return;
  end

  email = 'brakeniklas@gmail.com';
  reply = 'N'; %input('Email when done? Y/N [Y]:','s');

  tic;
  
  try

    switch nargin

    case 1  % Analyse raw data

        [header1 ImageData] = getTimeSeries(Folder);
        [header correlated] = analyseTimeSeries(header1, ImageData);

    case 2  % Analyse data from ImageData

        [header correlated] = analyseTimeSeries(Folder, ImageData);

    otherwise

      ME = MException('MATLAB:actionNotTaken','Invalid number of input arguments.');
      throw(ME);

    end

    if isempty(reply)
      sendMail(email,'Analysis is complete!', [header.FileName, ' was analysed in ', int2str(round(toc/6)/10), ' minutes. Correlated = ' int2str(correlated)]);
    end

  catch Last_Error

    msg = getReport(Last_Error);

    if isempty(reply)
      sendMail(email,'Analysis incomplete. ', msg);
    end
    disp(msg);
    header = msg;
  end

  clearvars -except header;

end

function [header ImageData] = getTimeSeries(Folder)

  % Add ImageJ library to JAVACLASSPATH
  try
      Miji(false);
  catch
      disp('Fiji\scripts is not on your path. Please add to your path, or run installFiji.')
      return;
  end
  import ij.*

  % Extract experiment data from Experiment.xml file
  MetaData      = xml2struct(fullfile(Folder,'Experiment.xml'));
  ImageWidth    = str2num(MetaData.ThorImageExperiment.LSM.Attributes.pixelX);
  ImageHeight   = str2num(MetaData.ThorImageExperiment.LSM.Attributes.pixelY);
  FrameCount    = str2num(MetaData.ThorImageExperiment.Streaming.Attributes.frames);
  StepCount     = str2num(MetaData.ThorImageExperiment.ZStage.Attributes.steps);
  fps           = str2num(MetaData.ThorImageExperiment.LSM.Attributes.frameRate(1:5));
  FlyBackFrames = str2num(MetaData.ThorImageExperiment.Streaming.Attributes.flybackFrames);
  fieldSize     = str2num(MetaData.ThorImageExperiment.LSM.Attributes.fieldSize);
  zScale        = str2num(MetaData.ThorImageExperiment.ZStage.Attributes.stepSizeUM);
  zStart        = str2num(MetaData.ThorImageExperiment.ZStage.Attributes.startPos);

  if(StepCount == 1)
    FlyBackFrames = 0;
  end

  fps = fps/(StepCount+FlyBackFrames);

  ImagesPerSlice = FrameCount / (StepCount + FlyBackFrames);

  % Get projected Images for each slice
  Average_Images = zProj3(fullfile(Folder,'Image_0001_0001.raw'),ImagesPerSlice,ImageWidth*ImageHeight,StepCount,FlyBackFrames);

  % Loop through each slice
  for Slice = 1:StepCount

    % Save slice and then open it in ImageJ
    imwrite(suint16(Average_Images(:,:,Slice)),[Folder '\Slice' int2str(Slice) '.tif'],'tif');
    IJ.run('Open...', ['path=[' Folder '\Slice' int2str(Slice) '.tif]']);
    imp = WindowManager.getCurrentImage;

    % Get the Roi Manager 
    K = plugin.frame.RoiManager.getRoiManager;

    % Image analysis
    IJ.run('Subtract Background...', 'rolling=7 stack');
    IJ.run('Gaussian Blur...', 'sigma=1');
    IJ.run('Enhance Contrast', 'saturated=0.35');
    IJ.run('Morphological Filters', 'operation=[White Top Hat] element=Disk radius=6');
    imp = WindowManager.getCurrentImage;
    IJ.setAutoThreshold(imp,'Mean dark');
    IJ.run('Convert to Mask');
    IJ.run('Watershed');
    IJ.run('Remove Outliers...', 'radius=4 threshold=50 which=Dark');
    IJ.run('Analyze Particles...', 'clear add stack');
    IJ.run('Set Measurements...', 'mean redirect=None decimal=3');
    K.runCommand('save',fullfile(Folder,'RoiSet.zip'));    % Save ROI data
    IJ.run('Close All'); 

    % Get coordinates from previously saved ROI data
    Coords = getRoiCoords(fullfile(Folder,'RoiSet.zip'));
    CoordinateCenter = [];
    for i = 1:length(Coords)
      temp = Coords{i};
      CoordinateCenter(i,1:2) = min([mean(temp(:,1)) mean(temp(:,2))], [ImageWidth ImageHeight]);
    end
    CoordinateCenter(:,3) = Slice;

    delete(fullfile(Folder,'RoiSet.zip'));
    delete(fullfile(Folder,['Slice' int2str(Slice) '.tif']));

    % Save Roi Coordinates in struct
    ImageData(Slice) = struct('Slice', Slice, 'Results', [], 'NumOfROIs', length(CoordinateCenter(:,1)), 'RoiCoordinates', transpose(CoordinateCenter),'Average',Average_Images);


    % Get ROIs and initialize their respective rectangular regions
    R = K.getRoisAsArray;
    Results = zeros(ImagesPerSlice,length(R));
    for k = 1:length(R)
      XBound(k,1:2) = [max(R(k).getBounds.x,1) min(R(k).getBounds.x+R(k).getBounds.width,512)];
      YBound(k,1:2) = [max(R(k).getBounds.y,1) min(R(k).getBounds.y+R(k).getBounds.height,512)];
    end

    XBounds{Slice} = XBound;
    YBounds{Slice} = YBound;

  end

  % Clean up workspace
  IJ.getInstance().quit();

  % Measures average pixel value for each ROI
  Results = measure(fullfile(Folder,'Image_0001_0001.raw'), ImagesPerSlice, ImageWidth, ImageHeight, StepCount, FlyBackFrames, XBounds, YBounds);

  % Save measurements for each ROI
  for Slice = 1:StepCount
    ImageData(Slice).Results = Results{Slice};
  end  

  % Get Folder name, save data with name 
  [Path ExperimentName] = fileparts(Folder);
  fileName = [ExperimentName '.mat'];

  % Removing "noisy" frames.
  excludeIndices = [];

  header = struct('FileName', fileName, 'DataPath',Folder, 'Slices', StepCount, 'Frames', ...
    ImagesPerSlice, 'fps', fps, 'exInd', excludeIndices,'FlyBackFrames',FlyBackFrames, ...
    'ImageWidth',ImageWidth,'ImageHeight',ImageHeight,'fieldSize',fieldSize,'zScale',zScale,'zStart',zStart);
  save(fullfile(Folder,fileName), 'header', 'ImageData');

end


function [header correlated] = analyseTimeSeries(header, ImageData)

  Folder = header.DataPath;
  filename = header.FileName;
  datafile = [Folder '\Analysed ' filename];

  % Parameters

  tau0 = 0.2;   % Denoising parameter
  AvgFrame = 7; % Number of frames before and after point for average
  WhitenessThreshold = 1000;

  % Read StimulusTimes.txt and StimulusConfig.txt. If no config file
  % use default values.
  RawStimulusData = tabulate(readLines(fullfile(Folder,'StimulusTimes.txt')));
  try
    temp = tabulate(readLines(fullfile(Folder,'StimulusConfig.txt')));
  catch
    temp = [5 2 10 0.2 5; 600 1200 140 360 0];
  end
  Config.StimuliCount   = temp(1,1);
  Config.Repetitions    = temp(1,2);
  Config.Type           = temp(1,3);
  Config.DisplayLength  = temp(1,4);
  Config.RestLength     = temp(1,5);
  Config.PlusMinus      = temp(1,6);
  Config.Number         = temp(2,1);
  Config.Height         = temp(2,2);
  Config.Width          = temp(2,3);
  Config.BottomPad      = temp(2,4);
  Config.Area           = temp(2,5);
  Config.Background     = temp(2,6);

  % Attempt to get capture times, otherwise estimate with frames per second.
  try
    LoadSyncEpisode([Folder '\']);
    GenerateFrameTime;
  catch
    disp('No Sync data');
    frameTime = linspace(0,header.Frames/header.fps,header.Frames);
  end

  % Get length of experiment
  TimeLapse = frameTime(end);

  % Reorient data to ROI-oriented structure
  [RoiData RoiCoordinates] = getRoiData(ImageData);



  % Normalize data with percent above baseline
  BaseLineCount = ceil(Config.RestLength*header.fps);  % Number of data points for baseline
  difF = deltaF_overF(RoiData,tau0, AvgFrame, BaseLineCount);

  % Get time axis for each ROI time series
  FrameTimes = getTimeAxis(RoiData,frameTime,header.Slices,header.FlyBackFrames);

  % Get stimulus times calibrated to beginning of frame capture if applicable
  StimulusTimes = RawStimulusData(:,2) + frameTime(1);


  % Save data in structures
  AnalysedData = struct('dFF0', difF,'Times', FrameTimes,'RoiCoords',RoiCoordinates);
  StimulusData = struct('Raw',RawStimulusData,'Times',StimulusTimes,'Configuration',Config);
  header = struct('FileName',['Analysed ' filename], 'RoiCount', length(RoiData), 'StimuliCount', ...
    length(StimulusTimes),'TimeLapse', TimeLapse, 'FPS', header.fps, 'Frames', ...
    header.Frames, 'Slices', header.Slices,'ImageWidth',header.ImageWidth,'ImageHeight', ...
    header.ImageHeight, 'fieldSize',header.fieldSize, 'zScale',header.zScale, 'zStart',header.zStart, ...
    'FlyBackFrames', header.FlyBackFrames);



  try
    getXCor;

    for i = 1:length(RoiData)
      for j = 1:(StimulusData.Configuration.StimuliCount-1)
        [h p(i,j) ci stats] = ttest2(RoiData(i).XCor(1,:),RoiData(i).XCor(1+j,:));
      end
    end
    AnalysedData.pValues = p;


    correlated = true;
    for i = 1:length(RoiData)
      RoiData(i).ControlResponse = StimulusData.Responses(1,i);

      if(StimulusData.Configuration.Type == 1)
        siz = sqrt(StimulusData.Configuration.StimuliCount-1);
        RoiData(i).RF = reshape(StimulusData.Responses(2:end,i),[siz siz]);

      elseif(StimulusData.Configuration.Type == 6)
        siz = (StimulusData.Configuration.StimuliCount-1)/2;
        Q = ones(siz,siz);

        for j = 1:siz
          Q(j,:) = Q(j,:).*repmat(1-AnalysedData.pValues(i,j),[1 siz]);
          Q(:,j) = Q(:,j).*repmat(1-AnalysedData.pValues(i,j+siz),[siz 1]);
        end
        
        RoiData(i).RF = Q;
      end

      Z = RoiData(i).RF;
      Y = []; X = [];
      for a = 1:siz
        for b = 1:siz
          X(end+1:end+max(floor(Z(a,b)*1000),1)) = a;
          Y(end+1:end+max(floor(Z(a,b)*1000),1)) = b;
        end
      end
      Z = [X' Y'];
      RoiData(i).RFmu = mean(Z); RoiData(i).RFsigma = cov(Z);
    end
  catch
    Error = lasterror;
    disp('An error occured in correlation-related computation.');
  end

  % Save final analysed data
  save(datafile, 'header','AnalysedData','StimulusData','RoiData');

end
