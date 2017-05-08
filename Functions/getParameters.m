function Data = getParameters(File)
    cd(File)
    datafile = ['Analysed ' File '.mat'];
    load(datafile);
    getXCor;

    for i = 1:length(RoiData)
      for j = 1:(StimulusData.Configuration.StimuliCount-1)
        [h p(i,j) ci stats] = ttest2(RoiData(i).XCor(1,:),RoiData(i).XCor(1+j,:),'tail','left');
      end
    end
    AnalysedData.pValues = p;


    correlated = true;
    for i = 1:length(RoiData)

      RoiData(i).ControlResponse = StimulusData.Responses(1,i);

      if(StimulusData.Configuration.Type == 1)
        siz = sqrt(StimulusData.Configuration.StimuliCount-1);
        RoiData(i).RF = reshape(StimulusData.Responses(2:end,i),[siz siz]);

      elseif(StimulusData.Configuration.Type == 6)
        siz = (StimulusData.Configuration.StimuliCount-1)/2;
        p = 1-AnalysedData.pValues(i,:);
        Q = ones(siz,siz);
        for j = 1:siz
          Q(j,:) = Q(j,:).*repmat(p(j),[1 siz]);
          Q(:,j) = Q(:,j).*repmat(p(j+siz),[siz 1]);
        end
        RoiData(i).RF = Q;
      end

      Z = RoiData(i).RF;
      Y = []; X = [];
      for a = 1:siz
        for b = 1:siz
          X(end+1:end+max(floor(Z(a,b)*1000),1)) = a;
          Y(end+1:end+max(floor(Z(a,b)*1000),1)) = b;
        end
      end
      Z = [X' Y'];
      RoiData(i).RFmu = mean(Z); RoiData(i).RFsigma = cov(Z);
    end

    AnalysedData.Responsive = 1-min(AnalysedData.pValues')';

    % Save final analysed data
    save(datafile, 'header','AnalysedData','StimulusData','RoiData');
    load(datafile);

    R = AnalysedData.Responsive > .99;
    RFmu = []; RFSigma = [];
    for i = 1:length(RoiData)
      if(R(i) < 1)
        continue;
      end
      RFmu(end+1,:) = RoiData(i).RFmu;
      RFSigma(end+1,:) = [RoiData(i).RFsigma(1,1) RoiData(i).RFsigma(2,2)];
    end

    Data(1) = sum(R)/length(RoiData);
    Data(2:3) = mean(RFmu)';
    Data(4:5) = std(RFmu)';
    Data(6:7) = mean(RFSigma)';
    Data(8:9) = std(RFSigma)';
    Data(10:11) = [sum(R) length(RoiData)];
    cd ..;
end
  
 
  
  
  
