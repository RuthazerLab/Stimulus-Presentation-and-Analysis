function Results = measure(fileName, header, ImageData, tform)

  Frames        = header.Frames;
  ImageHeight   = header.ImageHeight;
  ImageWidth    = header.ImageWidth;
  Step          = header.Slices;
  FlyBackFrames = header.FlyBackFrames;

  % Open raw data file
  fid = fopen(fileName,'r','l');
  H = Frames*(Step+FlyBackFrames);


  for Slice = 1:Step
    RoiCount(Slice) = ImageData(Slice).NumOfROIs;
  end

  [slicecount TSegs] = size(tform);

  h = waitbar(1/(Frames*(Step+FlyBackFrames)),['1/' int2str(TSegs)], 'Name','Measuring');

  for inc = 1:TSegs

    % Calculate ROI pixels in registered images
    for Slice = 1:Step
      T = tform{Slice,inc};
      A = ImageData(Slice).RoiMask;
      for k = 1:RoiCount(Slice)
        for p = 1:length(A{k,1});
          a(p) = min(max(round(A{k,2}(p)),1),ImageHeight);
          b(p) = min(max(round(A{k,1}(p)),1),ImageWidth);
        end
        Coords = [a' b'];
        TCoords = min(max(round(transformPointsInverse(T,Coords)),1),ImageWidth);
        RoiMask{Slice,k} = min(max((TCoords(:,1)-1)*ImageHeight+TCoords(:,2),1),ImageHeight*ImageWidth);
        % RoiMask{Slice,k} = min(max((Coords(:,1)-1)*ImageHeight+Coords(:,2),1),ImageHeight*ImageWidth);
      end
    end

    % Measure each ROI value for this TSegment
    for i = (inc-1)*H/TSegs+1:H*inc/TSegs

      waitbar(i/(Frames*(Step+FlyBackFrames)),h,[int2str(inc) '/' int2str(TSegs)]);

      [Frame Slice] = mdivide(i,Step+FlyBackFrames);

      if(FlyBackFrames == 0)
        Slice = 1;
        Frame = a - 1;
      end
        
      if(sum(Slice == [1:Step]) == 0)
        fseek(fid,ImageWidth*ImageHeight*2,0);
        continue;
      end

      pixels = fread(fid,[1 ImageHeight*ImageWidth],'uint16');

      for k = 1:RoiCount(Slice)
        Result(Slice).Data(Frame+1,k) = mean(pixels(RoiMask{Slice,k}));
      end

    end
  end

  Results = {};

  for Slice = 1:Step
    Results{Slice} = Result(Slice).Data;
  end

  delete(h);
  fclose(fid);
