function I = circle_looming(varargin)   % Called from stimulusFull.m

  % Simulates a looming circle stimulus. The circle's radius is passed to
  % this function from showStimuli. The time-dependent change in radius is
  % actually calculated in showStimuli, and the desired radius is simply 
  %passed here.

  % Created by Michael Lynn

  variables = varargin{1};

  shade = variables{1};
  width = variables{2};
  height = variables{3};
  ssiz = variables{4};
  buff = variables{5};
  radius = variables{6};
  background = variables{7};

  a1 = height-buff-ssiz;
  b1 = height-buff;
  a2 = (width -ssiz)/2;
  b2 = (width + ssiz)/2;

  x1 = (b2+a2)/2;
  y1 = (b1+a1)/2;


  %Add condition to automatically generate inverted-contrast stimulus
  %depending on whether background is 0 or 1 (modify shade param)
  if(background == 0)
    I = zeros(height,width);
    shade = 1;
  elseif(background == 1)
    I = ones(height,width);
    shade = 0;
  end

  for i = 1:height
    for j = 1:width
      if(((i-y1)^2 + (j-x1)^2) <= radius^2)
        I(i,j) = shade;

      end
    end
  end
