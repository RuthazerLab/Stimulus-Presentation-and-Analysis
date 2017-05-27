function header = extractData(Folder, ImageData)

% header = extractData3(Folder)
%   Takes experiment folder and outputs analysed image data
% 
% 

  try
  switch nargin

  case 0  % Analyse raw data

    Folder = uigetdir();

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

    [header1 ImageData] = getTimeSeries(Folder);
    [header correlated] = analyseTimeSeries(header1, ImageData);

  case 2  % Analyse data from ImageData

    [header correlated] = analyseTimeSeries(Folder, ImageData);

  end

catch
  header = 0;
  return;
end

end

function [header ImageData] = getTimeSeries(Folder)

  % Add ImageJ library to JAVACLASSPATH
  jarDir = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))),'ext');
  javaaddpath(fullfile(jarDir,'MorphoLibJ_-1.3.1.jar'));
  javaaddpath(fullfile(jarDir,'ij-1.51n.jar'));
  % import ij.*;
  % import ij.process.*;
  % import inra.ijpb.morphology.strel.DiskStrel;
  % import inra.ijpb.morphology.Morphology;

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
    imp = WindowManager.getCurrentImage;
    imp.setProcessor( Morphology.whiteTopHat( getChannelProcessor(imp), DiskStrel.fromRadius(6) ) );
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
    % delete(fullfile(Folder,['Slice' int2str(Slice) '.tif']));

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

  LoadSyncEpisode([Folder '\']);
  %% below is the new vision
  frameOutLogical = logical(Frame_Out);
  frameOutDiff = diff(frameOutLogical);
  risingEdge = find(frameOutDiff>0);
  fallingEdge = find(frameOutDiff<0);
  len =fallingEdge - risingEdge;
  maxLen = max(len);
  minLen = min(len);
  frameOutDiff = diff(Frame_Out);
  if gt(maxLen,1.5*minLen)
      threshold = minLen + (maxLen - minLen)/2;
      frameOutDiff(risingEdge(len>threshold))=0;
  end
  frameOutDiff = vertcat(0,frameOutDiff);
  % z1 = Frame_In & frameOutDiff;
  indexes = find(frameOutDiff>0);
  frameTime = time(indexes);

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
    T = [time2Frame(StimulusData.Times,AnalysedData) StimulusData.Raw(:,3)];
    [RoiCount Times] = size(AnalysedData.dFF0);
    stimType  = sort(uniqueElements(StimulusData.Raw(:,3)));
    stimCount = length(stimType);

    critWindow = ceil(header.FPS*2);

    for i = 1:stimCount
      temp = T(find(T(:,2) == stimType(i)),1);
      reps = length(temp);
      for j = 1:reps
        for k = 1:critWindow
          S(i,critWindow*(j-1)+k) = temp(j) + k;
        end
      end
    end

    for r = 1:RoiCount
      for i = 1:stimCount
        for j = 1:reps
          mu(i,j) = mean(AnalysedData.dFF0(r,S(i,critWindow*(j-1)+1:critWindow*j)));
        end
      end
      RoiData(r).XCor = mu;
      StimulusData.Responses(:,r) = mean(mu');
    end

    for i = 1:RoiCount
      for j = 1:(StimulusData.Configuration.StimuliCount-1)
        [h p(i,j) ci stats] = ttest2(RoiData(i).XCor(1,:),RoiData(i).XCor(1+j,:));
      end
    end
    AnalysedData.pValues = p;
    AnalysedData.Responsive = 1 - min(AnalysedData.pValues');


    correlated = true;
    for i = 1:RoiCount
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

      CenterPosition(i,:) = [RoiData(i).RFmu];
      CenterVariance(i,:) = [RoiData(i).RFsigma(1,1) RoiData(i).RFsigma(2,2)];

    end
  catch
    Error = lasterror;
    disp('An error occured in correlation-related computation.');
  end

  AnalysedData.Parameters = [header.RoiCount;
          sum(AnalysedData.Responsive > 0.99);
          sum(AnalysedData.Responsive > 0.99)/header.RoiCount;
          std(CenterPosition(AnalysedData.Responsive > 0.99,1));
          std(CenterPosition(AnalysedData.Responsive > 0.99,2));
          mean(CenterVariance(AnalysedData.Responsive > 0.99,1));
          mean(CenterVariance(AnalysedData.Responsive > 0.99,2)); ]

  % Save final analysed data
  save(datafile, 'header','AnalysedData','StimulusData','RoiData');

  A = {'Roi Count';'Responding ROIs';'Percent Responding';'X center variance';'Y center variance';'Average horizontal size';'Average vertical size'};
  for i = 1:length(AnalysedData.Parameters)
    A{i,2} = AnalysedData.Parameters(i);
  end
  header = A;

end

function [AV ME] = zProj3(fileName, ImagesPerSlice, ImageSize, Step, FlyBackFrames)

h = waitbar(1/(ImagesPerSlice*(Step+FlyBackFrames)),['1/' int2str(ImagesPerSlice*(Step+FlyBackFrames))], 'Name','TProjection');

% Get side length of images
SL = ImageSize ^ 0.5;

fid = fopen(fileName,'r','l');

% Initialize List
List = zeros([1 ImageSize Step]);

% Add each image to List
for i = 1:ImagesPerSlice*(Step+FlyBackFrames)

  [a b] = mdivide(i,Step+FlyBackFrames);

  if(FlyBackFrames == 0)
    b = 1;
  end
    
    if(sum(b == [1:Step]) == 0)
      fseek(fid,ImageSize*2,0);
        continue;
    end

  List(:,:,b) = List(:,:,b) + fread(fid,[1 ImageSize],'uint16');

  waitbar(i/(ImagesPerSlice*(Step+FlyBackFrames)),h,[int2str(i) '/' int2str(ImagesPerSlice*(Step+FlyBackFrames))]);

end

% Divide by number of images to get mean
List(:,:,1:end) = List(:,:,1:end) / ImagesPerSlice;

% Reshape List to SL x SL
AV = zeros(SL,SL);

for j = 1:Step
  for i = 0:SL:length(List)-1
    AV(i/SL+1,:,j) = List(1,i+1:i+SL,j);
  end
end

fclose(fid);
delete(h);

end

function Results = measure(fileName, ImagesPerSlice, ImageWidth, ImageHeight, Step, FlyBackFrames, XBounds, YBounds)

  % Open raw data file
  fid = fopen(fileName,'r','l');

  h = waitbar(1/(ImagesPerSlice*(Step+FlyBackFrames)),['1/' int2str(ImagesPerSlice*(Step+FlyBackFrames))], 'Name','Measuring');

  for Slice = 1:Step
    RoiCount(Slice) = length(XBounds{Slice});
  end

  % Add each image to List
  for ii = 1:ImagesPerSlice*(Step+FlyBackFrames)

    [a b] = mdivide(ii,Step+FlyBackFrames);

    if(FlyBackFrames == 0)
      b = 1;
      a = a - 1;
    end

    if(sum(b == [1:Step]) == 0)
      fseek(fid,ImageWidth*ImageHeight*2,0);
      continue;
    end

    pixels = fread(fid,[1 ImageHeight*ImageWidth],'uint16');

    Slice = b;
    Frame = a + 1;

    YBound = YBounds{Slice};
    XBound = XBounds{Slice};

    count = zeros(1,RoiCount(Slice));
    temp = count;

    % Interates over each ROI's rectangle 
    for k = 1:RoiCount(Slice)
      for i = YBound(k,1):YBound(k,2)
        for j = XBound(k,1):XBound(k,2)
            count(k) = count(k) + 1; 
            temp(k) = temp(k) + pixels((i-1)*ImageWidth+j);
        end
      end
    end

    Result(Slice).Data(Frame,:) = temp./count;

    waitbar(ii/(ImagesPerSlice*(Step+FlyBackFrames)),h,[int2str(ii) '/' int2str(ImagesPerSlice*(Step+FlyBackFrames))]);
  end

  Results = {};

  for Slice = 1:Step
    Results{Slice} = Result(Slice).Data;
  end

  delete(h);
  fclose(fid);

end

function [Coords] = getRoiCoords(FileList)

if(nargin ~= 1)
   disp('***Incorrect Usage of getRoiCoords');
   help getRoiCoords;
   return;
end

if (iscell(FileList))
  
   Coords = [cellfun(@getRoiCoords, Linearize(FileList), 'UniformOutput', false)];
   return;

end

FileName = FileList;
clear FileList;

[a, b, ext] = fileparts(FileName);

if (isequal(ext, '.zip'))

   FileNames = ZippedFiles(FileName);
   
   Dir = tempname;
   unzip(FileName, Dir);
   
   for i = 1:length(FileNames)
      FileList{1, i} = fullfile(Dir,char(FileNames(i, 1)));
   end

   Coords = getRoiCoords(FileList);

   delete(fullfile(Dir,'*.roi'));
   rmdir(Dir);

   return;
end


fileID = fopen(FileName, 'r', 'ieee-be');

fseek(fileID, 8, -1);

Bounds = fread(fileID, [1 4], 'int16');
nNumCoords = fread(fileID, 1, 'uint16');

fseek(fileID, 64,-1);


vnX = fread(fileID, [nNumCoords 1], 'int16');
vnY = fread(fileID, [nNumCoords 1], 'int16');

% - Trim at zero
vnX(vnX < 0) = 0;
vnY(vnY < 0) = 0;

% - Offset by top left ROI bound
vnX = vnX + Bounds(2);
vnY = vnY + Bounds(1);

Coords = [vnX vnY];

% Coords = min([mean(vnX) mean(vnY)], [512 512]);

% Coords = [mean(Bounds(4),Bounds(2)) mean(Bounds(3),Bounds(1)];

fclose(fileID);

   function [files] = ZippedFiles(zipFilename)
      import java.util.zip.*;
      import java.io.*;
      
      files={};
      Buffer = ZipInputStream(FileInputStream(zipFilename));
      file = Buffer.getNextEntry();
      
      while (file ~= 0)
         files = cat(1,files,char(file.getName));
         file = Buffer.getNextEntry();
      end
      
      Buffer.close();
   end


   function [cellArray] = Linearize(FileArgs)

      if (iscell(FileArgs{1}))
         cellArray = Linearize(FileArgs{1}{:});
      else
         cellArray = FileArgs(1);
      end
      
      for (nIndexArg = 2:length(FileArgs))
         if (iscell(FileArgs{nIndexArg}))
            cellReturn = Linearize(FileArgs{nIndexArg}{:});
            cellArray = [cellArray cellReturn{:}];
         else
            cellArray = [cellArray FileArgs{nIndexArg}];
         end
      end
      
   end

end

function D = deltaF_overF(RoiData, tau0, AvgFrame, BLThresh)

av = zeros(length(RoiData),1);
av(:,1:AvgFrame) = inf;
F0(:,1:AvgFrame) = inf;
R(:,1:AvgFrame) = 0;
D(:,1:AvgFrame) = 0;

% BLThresh = 7;
AvgFrame = 2;
% tau0 = 0.8;

% Weighting parameter such that exp(-abs(k)/tau0) > 0.001
N = ceil(3*tau0/log10(exp(1)));

h = waitbar(1/length(RoiData), 'Please Wait...', 'Name','Baselining');

for i = 1:length(RoiData)
  
  % Raw data for each ROI
  F(i,:) = RoiData(i).Brightness;

  waitbar(i/(length(RoiData)),h);

  for j = 1:length(RoiData(1).Brightness)

    % Smooths data with averaging
    av(i,j) = mean(F(i,max(j-AvgFrame,1):min(j+AvgFrame,length(RoiData(1).Brightness))));

    % Finds baseline from previous BLThresh frames
    F0(i,j) = min(av(i,max(j-BLThresh,1):j));

    % Normalizes data to percent above baseline
    R(i,j) = (F(i,j)-F0(i,j))/F0(i,j);

    % Uses moving exponentially-weighted averaging to denoise
    D(i,j) = denoise(i,j);


  end

end

% D = R;


delete(h);


  function G = denoise(r,t)
    G = 0;
    num = 0;
    den = 0;

    for k = 0:min(t-1,N)
      num = num + R(r,t-k)*exp(-abs(k)/tau0);
      den = den + exp(-abs(k)/tau0);
    end
    G = num/den;
  end

end   

function Stimuli = tabulate(ST)

% Stimuli = tabulate(ST)
%   Takes the output of readLines and
%   converts cells into a matrix of numbers

if(nargin ~= 1)
  help tabulate;
  Stimuli = 0;
  return;
end

wide = length(strsplit(ST{1},','));

K = zeros(length(ST),wide);

for i = 1:length(ST)

  temp = strsplit(ST{i},',');

  for j = 1:wide
    try
      K(i,j) = str2num(temp{j});
    catch 
      Stimuli = 'Incorrect Usage';
      return;
    end
  end
  
end

Stimuli = K;

end

function LoadSyncEpisode(pathname)

filename = 'Episode001.h5';
%% Load params from XML:
clockRate = 20000000;
sampleRate = LoadSyncXML(pathname);

%% Start loading HDF5:
pathandfilename = strcat(pathname,filename);
info = h5info(pathandfilename);

%% Parse input:
props = {'start','length','interval'};
data = {[1,1],[1 Inf],[1 1]};

%% Read HDF5:

for j=1:length(info.Groups)
    for k = 1:length(info.Groups(j).Datasets)
        datasetPath = strcat(info.Groups(j).Name,'/',info.Groups(j).Datasets(k).Name);
        datasetName = info.Groups(j).Datasets(k).Name;
        datasetName(isspace(datasetName))='_';   
        datasetValue = h5read(pathandfilename,datasetPath,data{1},data{2},data{3})';
        % load digital line in binary:
        if(strcmp(info.Groups(j).Name,'/DI'))
            datasetValue(datasetValue>0) = 1;
        end
        % create time variable out of gCtr, 
        % account for 20MHz sample rate:
        if(strcmp(info.Groups(j).Name,'/Global'))
            datasetValue = double(datasetValue)./clockRate;
            datasetName = 'time';
        end
        assignStr = UniqueName(datasetName);
        assignin('caller',assignStr,datasetValue);
    end
end

end


function outStr = UniqueName(str)
%% Generate unique name for variable to be exported.

cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
vars = evalin('base','who');
index = 1;
unique = false;
cmpStr = str;

while (~unique)
    ret = cellfun(cellfind(cmpStr),vars);
    if(~any(ret))
        outStr = cmpStr;
        unique = true;
    else
        cmpStr = strcat(str,num2str(index,'%03d'));
        index=index+1;
    end
end

end

function [ s ] = xml2struct( file )

    if (nargin < 1)
        clc;
        help xml2struct
        return
    end
    
    if isa(file, 'org.apache.xerces.dom.DeferredDocumentImpl') || isa(file, 'org.apache.xerces.dom.DeferredElementImpl')
        % input is a java xml object
        xDoc = file;
    else
        %check for existance
        if (exist(file,'file') == 0)
            %Perhaps the xml extension was omitted from the file name. Add the
            %extension and try again.
            if (isempty(strfind(file,'.xml')))
                file = [file '.xml'];
            end
            
            if (exist(file,'file') == 0)
                error(['The file ' file ' could not be found']);
            end
        end
        %read the xml file
        xDoc = xmlread(file);
    end
    
    %parse xDoc into a MATLAB structure
    s = parseChildNodes(xDoc);
    
end

% ----- Subfunction parseChildNodes -----
function [children,ptext,textflag] = parseChildNodes(theNode)
    % Recurse over node children.
    children = struct;
    ptext = struct; textflag = 'Text';
    if hasChildNodes(theNode)
        childNodes = getChildNodes(theNode);
        numChildNodes = getLength(childNodes);

        for count = 1:numChildNodes
            theChild = item(childNodes,count-1);
            [text,name,attr,childs,textflag] = getNodeData(theChild);
            
            if (~strcmp(name,'#text') && ~strcmp(name,'#comment') && ~strcmp(name,'#cdata_dash_section'))
                %XML allows the same elements to be defined multiple times,
                %put each in a different cell
                if (isfield(children,name))
                    if (~iscell(children.(name)))
                        %put existsing element into cell format
                        children.(name) = {children.(name)};
                    end
                    index = length(children.(name))+1;
                    %add new element
                    children.(name){index} = childs;
                    if(~isempty(fieldnames(text)))
                        children.(name){index} = text; 
                    end
                    if(~isempty(attr)) 
                        children.(name){index}.('Attributes') = attr; 
                    end
                else
                    %add previously unknown (new) element to the structure
                    children.(name) = childs;
                    if(~isempty(text) && ~isempty(fieldnames(text)))
                        children.(name) = text; 
                    end
                    if(~isempty(attr)) 
                        children.(name).('Attributes') = attr; 
                    end
                end
            else
                ptextflag = 'Text';
                if (strcmp(name, '#cdata_dash_section'))
                    ptextflag = 'CDATA';
                elseif (strcmp(name, '#comment'))
                    ptextflag = 'Comment';
                end
                
                %this is the text in an element (i.e., the parentNode) 
                if (~isempty(regexprep(text.(textflag),'[\s]*','')))
                    if (~isfield(ptext,ptextflag) || isempty(ptext.(ptextflag)))
                        ptext.(ptextflag) = text.(textflag);
                    else
                        ptext.(ptextflag) = [ptext.(ptextflag) text.(textflag)];
                    end
                end
            end
            
        end
    end
end

% ----- Subfunction getNodeData -----
function [text,name,attr,childs,textflag] = getNodeData(theNode)
    % Create structure of node info.
    
    %make sure name is allowed as structure name
    name = toCharArray(getNodeName(theNode))';
    name = strrep(name, '-', '_dash_');
    name = strrep(name, ':', '_colon_');
    name = strrep(name, '.', '_dot_');

    attr = parseAttributes(theNode);
    if (isempty(fieldnames(attr))) 
        attr = []; 
    end
    
    %parse child nodes
    [childs,text,textflag] = parseChildNodes(theNode);
    
    if (isempty(fieldnames(childs)) && isempty(fieldnames(text)))
        text.(textflag) = toCharArray(getTextContent(theNode))';
    end
    
end

% ----- Subfunction parseAttributes -----
function attributes = parseAttributes(theNode)
    % Create attributes structure.

    attributes = struct;
    if hasAttributes(theNode)
       theAttributes = getAttributes(theNode);
       numAttributes = getLength(theAttributes);

       for count = 1:numAttributes

            %Suggestion of Adrian Wanner
            str = toCharArray(toString(item(theAttributes,count-1)))';
            k = strfind(str,'='); 
            attr_name = str(1:(k(1)-1));
            attr_name = strrep(attr_name, '-', '_dash_');
            attr_name = strrep(attr_name, ':', '_colon_');
            attr_name = strrep(attr_name, '.', '_dot_');
            attributes.(attr_name) = str((k(1)+2):(end-1));
       end
    end
end

function [RoiData RoiCoordinates] = getRoiData(ImageData);

% Reformats data into structure RoiData

RoiCoordinates = [];

for i = 1:length(ImageData)
  Co{i} = ImageData(i).RoiCoordinates;
  RoiCoordinates = [RoiCoordinates ImageData(i).RoiCoordinates];
  Data{i} = ImageData(i).Results;
end

Co = cell2mat(Co);
Data = cell2mat(Data);


for i = 1:length(Co)
  RoiData(i) = struct('Brightness', Data(:,i), 'Coordinates', Co(:,i));
end

end 

function FrameTimes = getTimeAxis(RoiData, CaptureTimes, Slices, FlyBackFrames)

% Reformats CaptureTimes so that it is a roiCount x frameCount matrix


  h = waitbar(1/length(RoiData(1).Brightness), 'Please Wait...', 'Name','Time Axis');
  
  T = zeros(length(RoiData(1).Brightness),length(RoiData));

  for i = 1:length(RoiData(1).Brightness)

    waitbar(i/length(RoiData(1).Brightness),h);

    for j = 1:length(RoiData)

      try
      T(i,j) = CaptureTimes((i-1)*(Slices+FlyBackFrames)+RoiData(j).Coordinates(3));
      catch
        disp(i);
      end
    end
  end

  FrameTimes = transpose(T);

  delete(h);

end

function [Y X mult] = getRFCenter(Roi, StimulusData, RoiData)

X = 0;
Y = 0;
mult = 0;
Q{1} = [0 0];

for i = 2:length(RoiData(Roi).Responded)

  % Finds which square corresponds to the stimulus
  P(i) = StimulusData.Raw(find(StimulusData.Raw == RoiData(Roi).Responded(i))+length(StimulusData.Raw));
  [a b] =  mdivide(P(i),5);
  if(b == 0) b = 5; end
  if(a == 5) a = 4; end

  % Checks to see if any responses are repeated
  for i = 1:length(Q)
    if([a b] ==Q{i})
      mult = 1;
      break;
    end
  end

  Q{i} = [a b];
  X = X + b;
  Y = Y + a+1;
end 

% Returns average x and y coordinate
X = X/(length(RoiData(Roi).Responded)-1);
Y = Y/(length(RoiData(Roi).Responded)-1);

end

function M = uniqueElements(A)

 M = [];

for i = 1:length(A);
  if(sum(M == A(i)) == 0)
    M(end+1) = A(i);
  end
end

end

function [div rem] = mdivide(n,m)

  % [div rem] = mdivide(n,m)
  %   Takes integers n,m and return div and rem 
  %   such that n = div * m + rem

  if(nargin ~= 2)
    div = 0; rem = 0;
    help mdivide;
    return;
  end
  div = floor(n/m);
  rem = mod(n,m);
end

function I = suint16(I)

r = (2^16-1) / double(max(max(max(I)))); 

I = uint16(I * r);

end

function List = readLines(fileName)

% List = readLines(fileName)
%   Reads lines of txt file and returns cell
%   array, or 'No Data.' if no data.

if(nargin ~= 1)
  List = 'Error.';
  help readLines;
  return;
end

  
fid = fopen(fileName);

if(fid ~= -1)
  tline = fgetl(fid);

  List = cell(0,1);

  while ischar(tline)
    List{end+1,1} = tline;
      tline = fgetl(fid);
  end
  fclose(fid);
else
  List = 'No Data.';
end

return;

end

function sampleRate = LoadSyncXML(varargin)
%% Load dll:
xmlFile = strcat(varargin{1}, 'ThorRealTimeDataSettings.xml');
assert(exist(xmlFile,'file')>0,'ThorRealTimeDataSettings.xml was not found. ');
dataStruct = xml2struct(xmlFile);

if(~isempty(dataStruct))
    BrdID = cellfun(@(x) strcmpi(x.Attributes.active,'1'),dataStruct.RealTimeDataSettings.DaqDevices.AcquireBoard);
    sampleID = cellfun(@(x) strcmpi(x.Attributes.enable,'1'),dataStruct.RealTimeDataSettings.DaqDevices.AcquireBoard{BrdID}.SampleRate);
    sampleRate = dataStruct.RealTimeDataSettings.DaqDevices.AcquireBoard{BrdID}.SampleRate{sampleID>0}.Attributes.rate;
end

end
