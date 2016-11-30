function header = extractFrogData(Folder, ImageData)

% header = extractData3(Folder)
%   Takes experiment folder and outputs analysed image data
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

  catch

    Error = lasterror;
    if isempty(reply)
      sendMail(email,'Analysis incomplete. ', [Error.message ' @line ' int2str(Error.stack(1).line)]);
    end
    disp(['Unexpected error in extractData3.m' Error.identifier ': ']);
    disp(Error.message);
    disp(Error.stack(1).line);

  end

  clearvars;

end

function [header ImageData] = getTimeSeries(Folder)

  % Extract experiment data from Experiment.xml file
  MetaData    = xml2struct(fullfile(Folder,'Experiment.xml'));
  ImageWidth  = str2num(MetaData.ThorImageExperiment.LSM.Attributes.pixelX);
  ImageHeight = str2num(MetaData.ThorImageExperiment.LSM.Attributes.pixelY);
  FrameCount  = str2num(MetaData.ThorImageExperiment.Streaming.Attributes.frames);
  StepCount   = str2num(MetaData.ThorImageExperiment.ZStage.Attributes.steps);
  fps         = str2num(MetaData.ThorImageExperiment.LSM.Attributes.frameRate(1:5));

  ImagesPerSlice = FrameCount / StepCount;


  GridSize = input('Grid side length: ');

  % Loop through each slice
  for Slice = 1:StepCount 

    I = zProj2(fullfile(Folder,'Image_0001_0001.raw'),Slice,ImagesPerSlice,ImageWidth*ImageHeight);

    imwrite(I,fullfile(Folder,'Averaged Image.tif'),'tif');

    Square_Size = 512/GridSize;

    if(mod(Square_Size,2) ~= 0)
      ME = MException('MATLAB:SquareSizeNotAssigned','Gride side length not a multiple of 2.');
      throw(ME);
    end

    YBound = []; XBound = []; CoordinateCenter = [];

    for i = 1:GridSize
      for j = 1:GridSize
        YBound(end+1,1) = 1+(i-1)*Square_Size;
        YBound(end,2) =  i * Square_Size;
        XBound(end+1,1) = 1+(j-1)*Square_Size;
        XBound(end,2) = j * Square_Size;
        CoordinateCenter(end+1,1) = mean(XBound(end,:));
        CoordinateCenter(end,2) = mean(YBound(end,:));
      end
    end
    CoordinateCenter(:,3) = 1;

    % Open raw data file
    fid = fopen(fullfile(Folder,'Image_0001_0001.raw'),'r','l');

    h = waitbar(1/(FrameCount),['1/' int2str(FrameCount)], 'Name','Measuring');

    % Loops through all images
    for ii = 1:FrameCount

      % Loads each image's pixel values and creates ImageJ image class
      pixels = fread(fid,[1 ImageHeight*ImageWidth],'uint16');

      temp = zeros(1,GridSize^2);

      % Interates over each ROI's rectangle 
      for k = 1:GridSize^2
        for i = YBound(k,1):YBound(k,2)
          for j = XBound(k,1):XBound(k,2)
              temp(k) = temp(k) + pixels((i-1)*ImageWidth+j);
          end
        end
      end

      % Calculate average pixel value in ROI number k
      Results(ii,:) = temp./Square_Size^2;

      waitbar(ii/(FrameCount),h,[int2str(ii) '/' int2str(FrameCount)]);
    end

    delete(h);

    % Save ImageData for slice
    ImageData(Slice) = struct('Slice', Slice, 'Results', Results, 'NumOfROIs', length(CoordinateCenter(:,1)), 'RoiCoordinates', transpose(CoordinateCenter));

  end

  % Get Folder name, save data with name 
  [Path ExperimentName] = fileparts(Folder);
  fileName = [ExperimentName '.mat'];

  % Vestige of removing "noisy" frames.
  excludeIndices = [];

  header = struct('FileName', fileName, 'DataPath',Folder, 'Slices', StepCount, 'Frames', FrameCount, 'fps', fps, 'exInd', excludeIndices);
  save(fileName, 'header', 'ImageData');

  % Clean up
  fclose(fid);
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
    CaptureTimes = getCaptureTimes(Folder);
  catch % Depreciated
    CaptureTimes = [0:header.Frames]/header.fps;
  end

  % Get length of experiment
  try
    TimeLapse = CaptureTimes(end);
  catch % Depreciated
    TimeLapse = header.Frames / header.fps;
  end

  % Reorient data to ROI-oriented structure
  [RoiData RoiCoordinates] = getRoiData(ImageData);

  % Normalize data with percent above baseline
  tau0 = 0.2;   % Denoising parameter
  AvgFrame = 7; % Number of frames before and after point for average
  BaseLineCount = ceil(Config.RestLength*header.fps);  % Number of data points for baseline
  difF = deltaF_overF(RoiData,tau0, AvgFrame, BaseLineCount);

  % Get time axis for each ROI time series
  FrameTimes = getTimeAxis(RoiData,CaptureTimes,header.Slices);

  % Get stimulus times calibrated to beginning of frame capture if applicable
  StimulusTimes = RawStimulusData(:,2) + CaptureTimes(1);


  % Save data in structures
  AnalysedData = struct('dFF0', difF,'Times', FrameTimes,'RoiCoords',RoiCoordinates);
  StimulusData = struct('Raw',RawStimulusData,'Times',StimulusTimes,'Configuration',Config);
  header = struct('FileName',['Analysed ' filename], 'RoiCount', length(RoiData), 'StimuliCount', ...
    length(StimulusTimes),'TimeLapse', TimeLapse, 'FPS', header.fps, 'Frames', ...
    header.Frames, 'Slices', header.Slices);

  % Add cross correlation results to StimulusData
  try
    XCor;
    StimulusData.Responses = Responses;
    StimulusData.Vector = S;
    correlated = true;
  catch
    Error = lasterror;
    disp(['Unexpected error in XCor.m line ' int2str(Error.stack(1).line) ': ']);
    disp(Error.message);
    correlated = false;
  end

  % Save final analysed data
  save(datafile, 'header','AnalysedData','StimulusData','RoiData');


end

function frameTime = getCaptureTimes(Folder)
    LoadSyncEpisode([Folder '\']);
    if(exist('Frame_In') == 0)
      Frame_In = 1;
    end
    GenerateFrameTime;
end