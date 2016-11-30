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
