function [data shade] = showStimuli(hObject, variables, handles)
%%% ---- Support Functions for RunExperiment.m ---- %%

% Initializes trigger through National Instrument's USB-6009 port ao1
try
  s = daq.createSession('ni');
  addAnalogOutputChannel(s,'Dev1','ao1','Voltage');
  Triggered = 1;
catch Last_Error
  disp(getReport(Last_Error));
  Triggered = 0;
end


fois = variables(1);        % Number of times stimulus is presented
typ = variables(2);         % Type of stimulus presented
num = variables(3);         % Length of display area in case of squares

height  = handles.height;   % Height of image
width = handles.width;      % Width of image
buff = handles.buffer;      % Offset from bottom of screen
ssiz = handles.ssiz;        % Size of display area
radius = handles.circleRadius;  % Radius of a circle
lag1 = handles.lag1;        % Length of stimulus
lag2 = handles.lag2;        % Length of pause

Background = handles.Background;
PlusMinusDifference = handles.Contrast;

% Initializes black screen and White
Black = zeros(height,width);
White = ones(height,width);


if(Background < 0.5)
  Sign = 1;
else
  Sign = -1;
end


% Initializes figure (maximize window after it appears)
fig = figure('NumberTitle','off','MenuBar','none','toolbar','none','color',[Background Background Background],'DockControls','off');


% Generates images to be presented to reduce computation time alter
switch typ

case 1  % Random squares

  % Set stimulus-specific functions and variables
  num = num^2;
  number2data = @(vars) vars{1};
  vars = {0};
  conversion = @(i,num) i;
  

  % Load stimuli into matrix
  for i = 1:num
    I(:,:,i) = square({i, ssiz, sqrt(num), height, width, buff, Sign, Background, PlusMinusDifference});
  end

case 2  % Displays bars, overlap for ROI detection.

  % Set stimulus-specific functions and variables
  num = num;
  number2data = @(vars) vars{1};
  vars = {0};
  conversion = @(i,num) i;

  % Load stimuli into matrix. Top Bottom Left Right
  for j = 0:1
    for i = 1:num
      I(:,:,i+num*j) = RoiBars({i, ssiz, num, height, width, buff, Sign, Background, PlusMinusDifference, j});
    end
  end

  num = 2*num;

case 3  % Display Brightness Levels

  radius = 1000;
  GreyValue = 0;

  % Set stimulus-specific functions and variables
  number2data = @(vars) vars{1}/vars{2};
  vars = {0,num,GreyValue};
  conversion = @(i,num) i+1;
  Background = 0;

  % Load stimuli into matrix
  for i = 1:num+1
    vars{1} = i;
    y = number2data(vars);
    I(:,:,i) = circle({y,width,height,ssiz,buff,radius,Background});
  end

case 4  % Spatial Frequency

  F = compFact(width);
  F = F(1:end-2);
  num = length(F);
  % num = 4*length(F);
  vars = {1, F, width};
  number2data = @(vars) vars{2}(vars{1})/vars{3};
  % number2data = @(vars) vars{1};
  conversion = @(i,num) i;

  % I = zeros(height,width,num*4); J = zeros(height,width,num*4);
  % for theta = 45:45:180
  %   [temp1 temp2] = SpatialFrequencyAngled(theta,height,width);
  %   I(:,:,end+1:end+1+size(temp1,3)) = temp1;
  %   J(:,:,end+1:end+1+size(temp2,3)) = temp2;
  % end
  [I J] = SpatialFrequencyAngled(0,height,width);

  Hz = 0.05;

case 5 % Displays bar in specified direction and width

  number2data = @(vars) vars{1}*vars{2};
  vars = {0, num};

  h = waitbar(1/(360/num),['1/' int2str(360/num)], 'Name','Constructing');

  for i = num:num:360
    temp2 = dirSelect(i,width,floor(height/4));
    I{i/num} = temp2(1:height,:,:);
    waitbar(i/360,h,[int2str(i/num) '/' int2str(360/num)]);
  end

  Period = 0.1;

  delete(h);

  White = I{1};
  White = White(:,:,1);
  Background = 1;
  
  num = 360/num;


case 6 % Orientation Selectivity

  number2data = @(vars) vars{1}*vars{2};
  vars = {0, num};
  conversion = @(i,num) i;

  I = ones(height,width,180/num+1);

  H = ssiz/20;
  y1 = (height-ssiz/2+buff);
  x1 = (width/2);

  for theta = num:num:180
    m = tan(theta*pi/180);
    M = sqrt(m^2+1);
    if(theta == 90)
      I(:,width/2-H:width/2+H,theta/num) = 0;
      continue;
    end
    for y = 1:height
      for x = 1:width
        if(abs((y-y1) - m*(x-x1)) < H*M)
          I(y,x,theta/num) = 0;
        end
      end
    end
  end

  num = 180/num;

case 7 % Radii

  % Set stimulus-specific functions and variables
  number2data = @(vars) vars{3}*vars{1}/vars{2};
  vars = {0,num,height/2};
  conversion = @(i,num) i+1;
  Background = 0;

  % Load stimuli into matrix
  for i = 1:num+1
    vars{1} = i-1;
    radius = number2data(vars);
    I(:,:,i) = circle({1,width,height,ssiz,buff,radius,Background});
  end


end 

% Display blank background
figure(fig), hImage = imshow(Background*White,'border','tight','Parent',gca);
shade = Background(1,1);


% Generate random order for stimuli
ran = randomOrder(num, fois, 1);

% Wait for user to click continue
if(~Execution)
  data = 0;
  close;
  return;
end

% Outputs a 5V trigger if devices is connected
if(Triggered)
  outputSingleScan(s,5);
end
start = tic;
pause(1);
if(Triggered)
  outputSingleScan(s,0);
end

% Saves stimulus configuration data
Props(1,:) = [length(ran)/fois fois, typ, lag1, lag2, PlusMinusDifference];
Props(2,:) = [Sign, height, width, buff,ssiz, Background];

% Position screen
Pos = get(gcf,'Position');
set(gcf,'Position',Pos + [0 0 0 25]);


% Loop through each stimulus
for i = 1:length(ran)
  vars{1} = ran(i);
  data(i,1) = i;
  if(ran(i) == 0)
    data(i,3) = 0;
  else
    data(i,3) = number2data(vars);  % Convert stimulus number into discriptive number
  end
end

% Pause 10 (1+9) seconds to set baseline
pause(9); 

if(typ == 5)  % Special presentaton for moving bars

  for j = 1:length(ran)
    data(j,2) = toc(start);
    if(ran(j) == 0)
      pause(lag2);
      data(j,3) = 0;
    else
      J = I{ran(j)};
      tic;
      for k = 0:floor(lag1)-1
        for i = 1:size(J,3)
            set(hImage,'CData',J(:,:,i));
            pause(Period/size(J,3));
        end
      end
      pause(lag2);
    end
  end

elseif(typ == 4)

  for j = 1:length(ran)
    if(ran(j) == 0)
      pause(lag2);
      data(j,2) = toc(start);
      pause(lag1);
      data(j,3) = 0;
    else
      set(hImage,'CData',I(:,:,ran(j)));
      pause(lag2);
      data(j,2) = toc(start);
      for i = 1:lag1*floor(1/Hz)
          set(hImage,'CData',J(:,:,ran(j)));
          pause(Hz/2);
          set(hImage,'CData',I(:,:,ran(j)));
          pause(Hz/2);
      end
    end
  end

else    % All other stimuli

  for i = 1:length(ran)
    data(i,2) = toc(start);
    % Presentation background as control
    if(ran(i) == 0)
      pause(lag1);
      data(i,3) = 0;
    else
      tic;
      imshow(I(:,:,conversion(ran(i),num)),'border','tight','Parent',gca); % Show stimulus and convert stimulus number into matrix index
      pause(max(lag1-toc,0)); % Accounts for image presentation time in lag 
    end
    tic;
    imshow(Background*White,'border','tight','Parent',gca);
    pause(max(lag2-toc,0)); % Accounts for image presentation time in lag 
  end

end

disp('StimulusTimes: ');
disp(data);
disp('StimulusConfig: ');
disp(Props);


%% Saves Data as StimulusTimes.txt and properties as StimulusConfig.txt

file = fullfile(handles.folder,'StimulusTimes.txt');
file2 = fullfile(handles.folder,'StimulusConfig.txt');

i = 2;
while(exist(file))
  file = fullfile(handles.folder,['StimulusTimes(' int2str(i) ').txt']);
  file2 = fullfile(handles.folder,['StimulusConfig(' int2str(i) ').txt']);
  i = i + 1;
end

dlmwrite(file,data,'precision','%.3f');
dlmwrite(file2,Props,'precision','%.3f');



%% --- Random ordering of {0,1,....,num*fois}
function ran = randomOrder(num, fois,d,typ)

ran = datasample(repmat([0:num],[1 fois]),(num+1)*fois,'Replace',false);
ran = transpose(ran);



