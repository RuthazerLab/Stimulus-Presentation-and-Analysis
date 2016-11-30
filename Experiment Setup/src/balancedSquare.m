function I = balancedSquare(varargin)   % Called from stimulusFull.m

% Returns an image with properties specified in varargin.
% Displays a single square either brighter or darker than
% a grey background.

  variables = varargin{1};

  gridnum = variables{1}; % Position of square
  ssiz = variables{2};    % Size of display area
  num = variables{3};     % Number of squares in display area
  height = variables{4};  % Height of image
  width = variables{5};   % Width of image
  buff = variables{6};    % Offset from bottom of screen
  Sign = variables{7};    % Darker or lighter than background
  GreyBackground = variables{8};  % Weight of background
  PlusMinusDifference = variables{9};   % Absolute difference between light/dark and background


  Colour = GreyBackground + Sign*PlusMinusDifference;
  I = ones(height,width) * GreyBackground;

  if(gridnum == 0)
    return
  end

  pos = gridnum -1;
  siz = ssiz/num;

  a1 = height-buff-ssiz;
  b1 = height-buff;
  a2 = (width -ssiz)/2;
  b2 = (width + ssiz)/2;

% Loops through all pixels in display area
  for i = a1:b1
    for j = a2:b2

      if(mod(pos,num)*siz+a1 < i && i <= (mod(pos,num)+1)*siz+a1 && floor(pos/num)*siz+a2 < j && j <= (floor(pos/num)+1)*siz+a2)
        I(i,j) = Colour;
      end

    end
  end

