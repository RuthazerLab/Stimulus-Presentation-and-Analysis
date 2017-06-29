function I = circle(varargin)   % Called from stimulusFull.m

  % Displays a circle with appropriate shade and radius

  variables = varargin{1};

  shade = variables{1};
  width = variables{2};
  height = variables{3};
  ssiz = variables{4};
  buff = variables{5};
  radius = variables{6};
  

  a1 = height-buff-ssiz;
  b1 = height-buff;
  a2 = (width -ssiz)/2;
  b2 = (width + ssiz)/2;

  x1 = (b2+a2)/2;
  y1 = (b1+a1)/2;


  if(length(variables) == 6)
    I = zeros(height,width);
  elseif(length(variables) == 7)
    I = ones(height,width)*variables{7};
  end

  for i = 1:height
    for j = 1:width
      if(((i-y1)^2 + (j-x1)^2) <= radius^2)
        I(i,j) = shade;
      end
    end
  end

  