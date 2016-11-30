function I = balancedSquare(varargin)   % Called from stimulusFull.m

% Same as balancedSquare except returns image with three square
% instead of just one
  
  variables = varargin{1};

  gridnum = variables{1};
  ssiz = variables{2};
  num = variables{3};
  height = variables{4};
  width = variables{5};
  buff = variables{6};

  Sign = variables{7};
  GreyBackground = variables{8};
  PlusMinusDifference = variables{9};

  Colour = GreyBackground + Sign.*PlusMinusDifference;

  I = ones(height,width) * GreyBackground;

  pos = gridnum -1;
  siz = ssiz/num;



  a1 = height-buff-ssiz;
  b1 = height-buff;
  a2 = (width -ssiz)/2;
  b2 = (width + ssiz)/2;

for k = 1:3
  pos2 = pos(k); 
  Colour2 = Colour(k);


  for i = a1:b1
    for j = a2:b2
      if(mod(pos2,num)*siz+a1 < i && i <= (mod(pos2,num)+1)*siz+a1 && floor(pos2/num)*siz+a2 < j && j <= (floor(pos2/num)+1)*siz+a2)
        I(i,j) = Colour2;
      end
    end
  end

end