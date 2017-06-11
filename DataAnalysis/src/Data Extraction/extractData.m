function header = extractData(Folder, ImageData)

% header = extractData3(Folder)
%   Takes experiment folder and outputs analysed image data
% 
% 


  try

    switch nargin

    case {0,1}  % Analyse raw data

      if(nargin == 0)
        Folder = uigetdir('Data Folder');
      end

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

      jarDir = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))),'ext');
      javaaddpath(jarDir);

      [header1 ImageData] = getTimeSeries(Folder);
      header = analyseTimeSeries(header1, ImageData);

    case 2  % Analyse data from ImageData

      header = analyseTimeSeries(Folder, ImageData);

    otherwise

      ME = MException('MATLAB:actionNotTaken','Invalid number of input arguments.');
      throw(ME);

    end


  catch Last_Error

    msg = getReport(Last_Error);
    disp(msg);
    header = msg;

  end

end

function [header ImageData] = getTimeSeries(Folder)

  % Add ImageJ library to JAVACLASSPATH
  jarDir = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))),'ext');
  javaaddpath(fullfile(jarDir,'MorphoLibJ_-1.3.1.jar'));
  javaaddpath(fullfile(jarDir,'ij-1.51n.jar'));
  import ij.process.*;
  import ij.*;

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
  % [Average_Images tform] = zProjReg(fullfile(Folder,'Image_0001_0001.raw'),ImagesPerSlice,ImageWidth*ImageHeight,StepCount,FlyBackFrames);
  Average_Images = zProj3(fullfile(Folder,'Image_0001_0001.raw'),ImagesPerSlice,ImageWidth*ImageHeight,StepCount,FlyBackFrames);

  for Slice = 1:StepCount
    imwrite(suint16(Average_Images(:,:,Slice)),fullfile(Folder,['Slice' int2str(Slice) '.tif']),'tif');
  end

  % Loop through each slice
  for Slice = 1:StepCount
   
    % Get ROIs and initialize their respective rectangular regions
    IJ.run('Open...', ['path=[' Folder '\Slice' int2str(Slice) '.tif]']);
    imp = WindowManager.getCurrentImage;

    % Get the Roi Manager 
    K = plugin.frame.RoiManager.getRoiManager;

    % Image analysis
    IJ.run('Subtract Background...', 'rolling=7 stack');
    IJ.run('Gaussian Blur...', 'sigma=1');
    IJ.run('Enhance Contrast', 'saturated=0.35');
    imp = WindowManager.getCurrentImage;
    imp.setProcessor( inra.ijpb.morphology.Morphology.whiteTopHat( getChannelProcessor(imp), inra.ijpb.morphology.strel.DiskStrel.fromRadius(6) ) );
    IJ.setAutoThreshold(imp,'Mean dark');
    IJ.run('Convert to Mask');
    IJ.run('Watershed');
    IJ.run('Remove Outliers...', 'radius=4 threshold=50 which=Dark');
    IJ.run('Analyze Particles...', 'clear add stack');
    IJ.run('Set Measurements...', 'mean redirect=None decimal=3');
    K.runCommand('save',fullfile(Folder,'RoiSet.zip'));    % Save ROI data
    % IJ.run('Close All'); 

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
    ImageData(Slice) = struct('Slice', Slice, 'Results', [], 'NumOfROIs', length(CoordinateCenter(:,1)), ...
      'RoiCoordinates', transpose(CoordinateCenter),'Average',Average_Images(:,:,Slice), 'XBounds',[],'YBounds',[]);
        R = K.getRoisAsArray;
        Results = zeros(ImagesPerSlice,length(R));

    for k = 1:length(R)
      XBound(k,1:2) = [max(R(k).getBounds.x,1) min(R(k).getBounds.x+R(k).getBounds.width,512)];
      YBound(k,1:2) = [max(R(k).getBounds.y,1) min(R(k).getBounds.y+R(k).getBounds.height,512)];
    end

    ImageData(Slice).XBounds = XBound;
    ImageData(Slice).YBounds = YBound;
    XBounds{Slice} = XBound;
    YBounds{Slice} = YBound;

  end

  % Measures average pixel value for each ROI
  Results = measure(fullfile(Folder,'Image_0001_0001.raw'), ImagesPerSlice, ImageWidth, ImageHeight, StepCount, FlyBackFrames, XBounds, YBounds);

  % Save measurements for each ROI
  for Slice = 1:StepCount
    ImageData(Slice).Results = Results{Slice};
  end  

  % Get Folder name, save data with name 
  [Path ExperimentName] = fileparts(Folder);
  fileName = [ExperimentName '.mat'];

  header = struct('FileName', fileName, 'DataPath',Folder, 'Slices', StepCount, 'Frames', ...
    ImagesPerSlice, 'fps', fps,'FlyBackFrames',FlyBackFrames, ...
    'ImageWidth',ImageWidth,'ImageHeight',ImageHeight,'fieldSize',fieldSize,'zScale',zScale,'zStart',zStart);
  save(fullfile(Folder,fileName), 'header', 'ImageData');

end


function header = analyseTimeSeries(header, ImageData)

  Folder = header.DataPath;
  filename = header.FileName;
  datafile = fullfile(Folder,['Analysed ' filename]);

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
  RawStimulusData(:,2) = RawStimulusData(:,2) + frameTime(1);
  StimulusTimes = RawStimulusData(:,2);


  % Save data in structures
  AnalysedData = struct('dFF0', difF,'Times', FrameTimes,'RoiCoords',RoiCoordinates);
  StimulusData = struct('Raw',RawStimulusData,'Times',StimulusTimes,'Configuration',Config);
  header = struct('FileName',['Analysed ' filename], 'RoiCount', length(RoiData), 'StimuliCount', ...
    length(StimulusTimes),'TimeLapse', TimeLapse, 'FPS', header.fps, 'Frames', ...
    header.Frames, 'Slices', header.Slices,'ImageWidth',header.ImageWidth,'ImageHeight', ...
    header.ImageHeight, 'fieldSize',header.fieldSize, 'zScale',header.zScale, 'zStart',header.zStart, ...
    'FlyBackFrames', header.FlyBackFrames);

  getXCor;
  getResponsive;

  % Save final analysed data
  save(datafile, 'header','AnalysedData','StimulusData','RoiData');

  saveDataXLS;

  % PlotRoiData(header.FileName);

end