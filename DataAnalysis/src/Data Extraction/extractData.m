function header = extractData(Folder, ImageData)

% header = extractData3(Folder)
%   Takes experiment folder and outputs analysed image data
% 
% 

  email = 'brakeniklas@gmail.com';
  reply = input('Email when done? Y/N [Y]:','s');

  tic;
  
  try

    switch nargin

    case 1
        %% Extract data from .raw file in Folder
        [header1 ImageData] = getTimeSeries(Folder);
        
        %% Analyse data from ImageData 
        [header correlated] = analyseTimeSeries(header1, ImageData);
    case 2
        %% Analyse data from ImageData 
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
  end

  clearvars -except header;

end

function [header ImageData] = getTimeSeries(Folder)

  % Extract experiment data from Experiment.xml file
  MetaData      = xml2struct(fullfile(Folder,'Experiment.xml'));
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
  Average_Images = zProj3(fullfile(Folder,'Image_0001_0001.raw'),ImagesPerSlice,ImageWidth*ImageHeight,StepCount,FlyBackFrames);

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

    % Image analysis (self explanatory)
    IJ.run('Subtract Background...', 'rolling=7 stack');
    IJ.run('Gaussian Blur...', 'sigma=1');
    IJ.run('Despeckle');
    IJ.run('Sharpen');
    IJ.run('Sharpen');
    IJ.run('Enhance Contrast', 'saturated=0.35');
    IJ.setAutoThreshold(imp,'MinError dark');   % Thresholding algorithm "MinError"
    IJ.run('Convert to Mask');
    IJ.run('Watershed');
    IJ.run('Remove Outliers...', 'radius=5 threshold=50 which=Dark');
    IJ.run('Analyze Particles...', 'size=50-300 pixel clear add stack');
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

  header = struct('FileName', fileName, 'DataPath',Folder, 'Slices', StepCount, 'Frames', ImagesPerSlice, 'fps', fps, 'exInd', excludeIndices,'FlyBackFrames',FlyBackFrames,'ImageWidth',ImageWidth,'ImageHeight',ImageHeight);
  save(fullfile(Folder,fileName), 'header', 'ImageData');

end


function [header correlated] = analyseTimeSeries(header, ImageData)

  Folder = header.DataPath;
  filename = header.FileName;
  datafile = [Folder '\Analysed ' filename];

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
    header.Frames, 'Slices', header.Slices,'ImageWidth',header.ImageWidth,'ImageHeight',header.ImageHeight);

  % Add cross correlation results to StimulusData
  try
    XCor;
    StimulusData.Responses = Responses;
    StimulusData.Vector = S;
    correlated = true;
    for i = 1:length(RoiData)
      RoiData(i).ControlResponse = Responses(1,i);
      RoiData(i).ReceptiveCenter = getMiddle(Responses,i,StimulusData.Configuration);
      if(StimulusData.Configuration.Type == 1 || StimulusData.Configuration.Type == 6)
        squareSize = sqrt(StimulusData.Configuration.StimuliCount-1);
        RoiData(i).Heatmap = reshape(Responses(2:end,i),[squareSize squareSize]);
      end
    end
  catch Error
    Error = lasterror;
    disp(['Unexpected error in XCor.m line ' int2str(Error.stack(1).line) ': ']);
    disp(Error.message);
    correlated = false;
  end

  % Save final analysed data
  save(datafile, 'header','AnalysedData','StimulusData','RoiData');


end
