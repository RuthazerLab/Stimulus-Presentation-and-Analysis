function header = combineData(Folder1, Folder2)

  Folder1 = fullfile(pwd,Folder1); Folder2 = fullfile(pwd,Folder2);


  %% Extract data from .raw file in Folder
  [header1 ImageData] = getTimeSeries(Folder1, Folder2);

  %% Analyse data from ImageData 
  [header correlated] = analyseTimeSeries(header1, ImageData);

  clearvars -except header;




function [header ImageData] = getTimeSeries(Folder1, Folder2)

  Folder = pwd;

  % Extract experiment data from Experiment.xml file
  MetaData      = xml2struct(fullfile(Folder1,'Experiment.xml'));
  ImageWidth    = str2num(MetaData.ThorImageExperiment.LSM.Attributes.pixelX);
  ImageHeight   = str2num(MetaData.ThorImageExperiment.LSM.Attributes.pixelY);
  FrameCount    = str2num(MetaData.ThorImageExperiment.Streaming.Attributes.frames);
  StepCount     = str2num(MetaData.ThorImageExperiment.ZStage.Attributes.steps);
  fps           = str2num(MetaData.ThorImageExperiment.LSM.Attributes.frameRate(1:5));
  FlyBackFrames = str2num(MetaData.ThorImageExperiment.Streaming.Attributes.flybackFrames);

  if(StepCount == 1)
    FlyBackFrames = 0;
  end

  fps = fps/(StepCount+FlyBackFrames);

  ImagesPerSlice = FrameCount / (StepCount + FlyBackFrames);

  % Get projected Images for each slice
  Average_Images = zProj3(fullfile(Folder1,'Image_0001_0001.raw'),ImagesPerSlice,ImageWidth*ImageHeight,StepCount,FlyBackFrames);

  % Add ImageJ library to JAVACLASSPATH
  Miji(false);
  import ij.*

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
    % IJ.run('Despeckle');
    % IJ.run('Sharpen');
    % IJ.run('Sharpen');
    % IJ.setAutoThreshold(imp,'MinError dark');
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
    ImageData(Slice) = struct('Slice', Slice, 'Results', [], 'NumOfROIs', length(CoordinateCenter(:,1)), 'RoiCoordinates', transpose(CoordinateCenter));


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
  clearvars Average_Images;
  IJ.getInstance().quit();

  % Measures average pixel value for each ROI
  Results = measure(fullfile(Folder1,'Image_0001_0001.raw'), ImagesPerSlice, ImageWidth, ImageHeight, StepCount, FlyBackFrames, XBounds, YBounds);
  Results2 = measure(fullfile(Folder2, 'Image_0001_0001.raw'), ImagesPerSlice, ImageWidth, ImageHeight, StepCount, FlyBackFrames, XBounds, YBounds);
  % Save measurements for each ROI
  for Slice = 1:StepCount
    ImageData(Slice).Results = [Results{Slice}; Results2{Slice}];
  end  

  % Get Folder name, save data with name 
  [Path ExperimentName] = fileparts(Folder);
  fileName = [ExperimentName '.mat'];

  % Removing "noisy" frames.
  excludeIndices = [];

  header = struct('FileName', fileName, 'DataPath1',Folder1, 'DataPath2',Folder2, 'Slices', StepCount, 'Frames', ImagesPerSlice, 'fps', fps, 'exInd', excludeIndices,'FlyBackFrames',FlyBackFrames,'ImageWidth',ImageWidth,'ImageHeight',ImageHeight);
  save(fullfile(Folder,fileName), 'header', 'ImageData');




function [header correlated] = analyseTimeSeries(header, ImageData)

  Folder = pwd;

  Folder1 = header.DataPath1;
  Folder2 = header.DataPath2;
  filename = header.FileName;
  datafile = [Folder '\Analysed ' filename];

  % Read StimulusTimes.txt and StimulusConfig.txt. If no config file
  % use default values.
  RawStimulusData = tabulate(readLines(fullfile(Folder1,'StimulusTimes.txt')));
  RawStimulusData2 = tabulate(readLines(fullfile(Folder2,'StimulusTimes.txt')));
  l = length(RawStimulusData);
  RawStimulusData = [RawStimulusData; RawStimulusData2];
  RawStimulusData(l+1:end,2) = RawStimulusData(l+1:end,2) + RawStimulusData(l,2);
  RawStimulusData(l+1:end,1) = RawStimulusData(l+1:end,1) + RawStimulusData(l,1);


  try
    temp = tabulate(readLines(fullfile(Folder1,'StimulusConfig.txt')));
  catch
    temp = [5 2 10 0.2 5; 600 1200 140 360 0];
  end
  Config.StimuliCount   = temp(1,1);
  Config.Repetitions    = 2*temp(1,2);
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
  LoadSyncEpisode([Folder1 '\']);
  GenerateFrameTime;
  frameTime1 = frameTime;
  LoadSyncEpisode([Folder2 '\']);
  GenerateFrameTime;
  frameTime2 = frameTime + repmat(frameTime1(end),[length(frameTime1) 1]);
  frameTime = [frameTime1;frameTime2];

  % Get length of experiment
  TimeLapse = frameTime(end);

  % Reorient data to ROI-oriented structure
  [RoiData RoiCoordinates] = getRoiData(ImageData);

  % Normalize data with percent above baseline
  try
    load('Parameters.mat');
  catch
    tau0 = 0.2;   % Denoising parameter
    AvgFrame = 7; % Number of frames before and after point for average
  end
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
    header.Frames, 'Slices', header.Slices,'ImageWidth',header.ImageWidth,'ImageHeight',header.ImageHeight, 'FlyBackFrames', header.FlyBackFrames);

  % Add cross correlation results to StimulusData
  try
    XCor;
    StimulusData.Responses = Responses;
    StimulusData.Vector = S;
    correlated = true;
    for i = 1:length(RoiData)
      RoiData(i).ControlResponse = Responses(1,i);
      if(StimulusData.Configuration.Type == 1 || StimulusData.Configuration.Type == 6)
        squareSize = sqrt(StimulusData.Configuration.StimuliCount-1);
        RoiData(i).RF = reshape(Responses(2:end,i),[squareSize squareSize]);
      end
      RoiData(i).RFCenter = getMiddle(Responses,i,StimulusData.Configuration);
      RoiData(i).RFSize = [];
    end
  catch Error
    Error = lasterror;
    disp(['Unexpected error in XCor.m line ' int2str(Error.stack(1).line) ': ']);
    disp(Error.message);
    correlated = false;
  end

  % Save final analysed data
  save(datafile, 'header','AnalysedData','StimulusData','RoiData');

