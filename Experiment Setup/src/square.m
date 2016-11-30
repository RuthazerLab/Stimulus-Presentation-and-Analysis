function I = square(varargin)   % Called from stimulusFull.m

  % Returns image of a square in specified location.

  variables = varargin{1};

  gridnum = variables{1}; % Position of square
  ssiz = variables{2};    % Size of display area
  num = variables{3};     % Number of squares in display area
  height = variables{4};  % Height of image
  width = variables{5};   % Width of image
  buff = variables{6};    % Offset from bottom of screen
  

  pos = gridnum -1;
  siz = ssiz/num;

  I = zeros(height,width);

  a1 = height-buff-ssiz;
  b1 = height-buff;
  a2 = floor((width -ssiz)/2);
  b2 = floor((width + ssiz)/2);

% Loops through all pixels in display area
  for i = a1:b1
    for j = a2:b2
      if(mod(pos,num)*siz+a1 < i && i <= (mod(pos,num)+1)*siz+a1 && floor(pos/num)*siz+a2 < j && j <= (floor(pos/num)+1)*siz+a2)
        I(i,j) = 1;
      end
    end
  end