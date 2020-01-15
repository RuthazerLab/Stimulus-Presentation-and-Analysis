function [data shade] = showStimuli(hObject, variables, handles)
%%% ---- Support Functions for RunExperiment.m ---- %%

%Initializes trigger through National Instrument's USB-6009 port ao1
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

%Looming stimulus: Add some variable definitions which are unique to this
%stim. For example, rv_ratio is a user-defined variable which dictates the
%apparent speed of the approaching disk (lower rv_ratio means higher
%speed). d_screen is the distance between the fish's head and the screen,
%used to calibrate the apparent velocity between setups (probably not that
%important, but it's part of the equation governing looming stims).
if typ == 8
  rv_ratio = variables(4);
  min_size = num;
  maxtime = 5;
  d_screen = 5;
end



height  = handles.height;       % Height of image
width = handles.width;          % Width of image
buff = handles.buffer;          % Offset from bottom of screen
ssiz = handles.ssiz;            % Size of display area
radius = handles.circleRadius;  % Radius of a circle
lag1 = handles.lag1;            % Length of stimulus
lag2 = handles.lag2;            % Length of pause

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

  [I J] = SpatialFrequencyAngled(0,height,width);

  Hz = 5;

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
  conversion = @(i,num) i;
  Background = 0;

  % Load stimuli into matrix
  for i = 1:num
    vars{1} = i;
    radius = number2data(vars)
    I(:,:,i) = circle({1,width,height,ssiz,buff,radius,Background});
  end

case 8 % Looming stimuli. Here, we consider a disk with constant velocity and radius 
    %which is approaching the fish. The radius of the 2d circle plotted on the screen to
    %simulate this will increase proportial to 1/(-time) (see equation below - 
    %commonly found in literature for looming stimuli). 
    %We also need to define r/v (radius/velocity - which will be constant)
    %from user input
    %Distance between the fish and screen is also defined above (d_screen -
    %fixed it to 5cm but this will only affect the r/v value required to
    %obtain some perceived velocity.

    % Created by Michael Lynn 
    
  % Set stimulus-specific functions and variables
  number2data = @(vars) vars{3}*vars{1}/vars{2};
  vars = {0,num,height/2};
  conversion = @(i,num) i+1;

  % Load stimuli into matrix. Create time_array, then iterate through times, 
  %calculating the desired radius based on and creating a new matrix to show, 
  %encoded in the third dimension of I.
  
  min_radius = min_size %Minimum size of 2d circle
  maxtime_new = 1 * rv_ratio * d_screen / (min_radius) %Apparent size of 2d circle this timestep
  
  interval = 1/60
  time_array = 0:interval:maxtime_new;
  time_array = -1 * flip(time_array);
  
  I = ones(height,width,length(time_array));

  data_special_looming = zeros(fois, length(time_array), 2);  
  
  for time_ind = 1:length(time_array)
    vars{1} = time_ind-1;
    desired_radius = (-1 * rv_ratio * d_screen) / (time_array(time_ind));
    data_special_looming(:, time_ind, 2) = desired_radius; %Store the desired radius in data_special_looming
    %so that it can be referred back to.
    
    I(:,:,time_ind) = circle_looming({0,width,height,ssiz,buff,desired_radius, Background});
    %sum(sum(I(:,:,time_ind)))
  end

case 9  % Moving Spatial Frequency


  % Bar widths (in pixels)
  screenWidth = 11.5; % centimeters
  barSize = [2,1,0.925,0.85,0.785,0.68,0.5,0.24]; % centimeters
  F = ceil(barSize/screenWidth*width); % pixels
  % F = compFact(width);
  % F = F(1:end-4);
  num = length(F);

  

  vars = {1, barSize};
  number2data = @(vars) vars{2}(vars{1});

  h = waitbar(1/num,['1/' int2str(num)], 'Name','Constructing');
  for i = 1:num
    temp2 = PlusMinusDifference*(dirSelect(0,width,F(i))-0.5)+0.5;
    I{i} = temp2(1:height,1:width,:);
    waitbar(i/num,h,[int2str(i) '/' int2str(num)]);
  end

  Period = 0.1; % seconds

  delete(h);

  White = ones(size(I{1}(:,:,1)));

  conversion = @(i,num) i;
  set(fig,'Color',[0.5 0.5 0.5]);
  Background = 0.5;

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

% Saves stimulus configuration data
if(typ==8)
    Props(1,:) = [length(ran)/fois fois, typ, lag1, lag2, PlusMinusDifference, rv_ratio];
    Props(2,:) = [Sign, height, width, buff,ssiz, Background, min_radius];
else 
    Props(1,:) = [length(ran)/fois fois, typ, lag1, lag2, PlusMinusDifference];
    Props(2,:) = [Sign, height, width, buff,ssiz, Background];
end

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


% Outputs a 5V trigger if devices is connected
if(Triggered)
  outputSingleScan(s,5);
end
start = tic;
pause(1);
if(Triggered)
  outputSingleScan(s,0);
end

% Pause 10 (1+9) seconds to set baseline
pause(9); 



% Code related to looming stimuli: Change background color for 2 seconds,
% then change back, then start timer (start = tic). This is so we can look
% at red channel on 2P images to estimate when each stimulus started (since
% we did not have a TTL output available for precise stimulus timing

% imshow(Background, 'border','tight','Parent',gca);
% pause(1)
% 
% imshow(I(:, :, length(time_array)), 'border','tight','Parent',gca);
% pause(2)
% 
%imshow(Background, 'border','tight','Parent',gca);  
%start = tic;


if(typ == 5 || typ == 9)  % Special presentation for moving bars
  for j = 1:length(ran)
    data(j,2) = toc(start);
    if(ran(j) == 0)
      set(hImage,'CData',Background*White);
      pause(lag2);
      data(j,3) = 0;
    else
      J = I{ran(j)};
      N = size(J,3);
      totalTime = tic;
      counter = 0;
      while(toc(totalTime) < floor(lag1))
          tic;
          i = mod(counter,N)+1;
          set(hImage,'CData',J(:,:,i));
          counter = counter+1;
          pauseTime = max(Period/N-toc,0);
          pause(pauseTime);
      end
      set(hImage,'CData',Background*White);
      pause(lag2);
    end
  end

elseif(typ == 4)  % Special Presentation for spatial frequency

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
      for i = 1:lag1*floor(Hz)
          set(hImage,'CData',J(:,:,ran(j)));
          pause(1/(2*Hz));
          set(hImage,'CData',I(:,:,ran(j)));
          pause(1/(2*Hz));
      end
    end
  end


elseif(typ == 8) %Special presentation for looming. Here, num refers to the max time to present.
  %Define time array for 60Hz stim presentation from 0 to maxtime seconds

  time_array = 0:(1/60):maxtime_new;
  time_pause = 1/60;

  for sweeps = 1:fois
      imshow(I(:, :, 1), 'border','tight','Parent',gca);
      pause(5)
      
        for time_ind = 1:length(time_array)
          data_special_looming(sweeps, time_ind, 1) = toc(start);
          tic;
          imshow(I(:, :, time_ind), 'border','tight','Parent',gca);

          %sum(sum(I(:, :, time_ind)))
          time_topause = max(time_pause-toc,0);
          pause(time_topause);
        end
      imshow(I(:, :, length(time_array)), 'border','tight','Parent',gca);
      pause(5)
      imshow(Background, 'border','tight','Parent',gca)
      pause(3)
  end

else    % All other stimuli

  for i = 1:length(ran)
    data(i,2) = toc(start);
    % Presentation background as control
    if(ran(i) == 0)
      pause(lag1);
      data(i,3) = 0;
    else
      % Show stimulus and convert stimulus number into matrix index
      set(hImage,'CData',I(:,:,conversion(ran(i),num))); 
      pause(lag1);
    end
    set(hImage,'CData',Background*White);
    pause(lag2);
  end

end

if(typ == 8)
    disp('StimulusTimes: ');
    disp(data_special_looming);
else
    disp('StimulusTimes: ');
    disp(data);
    disp('StimulusConfig: ');
    disp(Props);
end

%% Saves Data as StimulusTimes.txt and properties as StimulusConfig.txt

file = fullfile(handles.folder,'StimulusTimes.txt');
file2 = fullfile(handles.folder,'StimulusConfig.txt');

i = 2;

while(exist(file))
  file = fullfile(handles.folder,['StimulusTimes(' int2str(i) ').txt']);
  file2 = fullfile(handles.folder,['StimulusConfig(' int2str(i) ').txt']);
  i = i + 1;
end

%Added condition to write 'data_special_looming' (with additional
%time-vs-radius information) to file, instead of 'data', if the looming
%stimulus is activated.
if(typ == 8)
    dlmwrite(file,data_special_looming,'precision','%.3f'); 
else
    dlmwrite(file,data,'precision','%.3f');
end

size(data)

dlmwrite(file2,Props,'precision','%.3f');



%% --- Random ordering of {0,1,....,num*fois}
function ran = randomOrder(num, fois,d,typ)

ran = datasample(repmat([0:num],[1 fois]),(num+1)*fois,'Replace',false);
ran = transpose(ran);
