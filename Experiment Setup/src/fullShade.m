function I = fullShade(varargin)   % Called from stimulusFull.m

% Returns full field shade.

  variables = varargin{1};

  shade = variables{1};
  width = variables{2};
  height = variables{3};

  I = zeros(height,width);

  I(:,:) = shade;