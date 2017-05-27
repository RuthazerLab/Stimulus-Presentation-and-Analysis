function I = RoiBars(varargin)

% Returns an image with properties specified in varargin.
% Displays a single square either brighter or darker than
% a grey background.

  variables = varargin{1};

  gridnum = variables{1}; % Position of square
  ssiz = variables{2};    % Size of display area
  num = variables{3};     % Number of bars in display area
  height = variables{4};  % Height of image
  width = variables{5};   % Width of image
  buff = variables{6};    % Offset from bottom of screen
  Sign = variables{7};    % Darker or lighter than background
  GreyBackground = variables{8};  % Weight of background
  PlusMinusDifference = variables{9};   % Absolute difference between light/dark and background
  isVert = variables{10};

  Colour = GreyBackground + Sign*PlusMinusDifference;
  I = ones(height,width) * GreyBackground;

  if(gridnum == 0)
    return
  end

  pos = gridnum;
  siz = ssiz/num;

  a1 = height-buff-ssiz;	% Top Edge
  b1 = height-buff;			% Bottom Edge
  a2 = (width -ssiz)/2;		% Left Side
  b2 = (width + ssiz)/2;	% Right Side

  % if(isVert)
  %   I(a1:b1,a2+siz*(pos-1):a2+siz*pos) = Colour;
  % else
  % 	I(a1+siz*(pos-1):a1+siz*pos,a2:b2) = Colour;
  % end
 if(isVert)
    I(:,a2+siz*(pos-1):a2+siz*pos) = Colour;
  else
    I(a1+siz*(pos-1):a1+siz*pos,:) = Colour;
  end
