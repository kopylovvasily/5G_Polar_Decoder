function generateHistPlots(mPlots,nPlots)

%declare global variable LOGDATA and clear current figure
global ArithLibStatistics 
clf

%calculate number of figures needed
maxPlotsPerFig = mPlots.*nPlots;
fnames = fieldnames(ArithLibStatistics);
ComplexFields = {'InFixPtREAL','InFixPtIMAG';'HistDataREAL','HistDataIMAG'};
N = length(fnames);
noOfFigs = ceil(N./maxPlotsPerFig);

NComplex = 0;
for cnt = 1:N
  IDField = fnames{cnt};
  isComplex = ArithLibStatistics.(IDField).IsComplex;  
  if isComplex
    NComplex = NComplex+1;
  end
end
noOfFigs = ceil((N+NComplex)./maxPlotsPerFig);
%set trigger vector for generating a new figure
% trigger value is '0'
if noOfFigs > 1
  newFigTrigger = circshift(mod([1:N+NComplex],maxPlotsPerFig)',1)';
  if (newFigTrigger(1) == 0)
    newFigTrigger(1) = 1; %case when mod(N,maxPlotsPerFig) = 0
  end
else
  newFigTrigger = ones(1,N+NComplex); % do not trigger new figures
end
%get screensize
scrsz = get(0,'ScreenSize');

%plotting loop
figCntr = 1;
spCnt = 1; %subplot Counter
for cnt = 1:N
  if newFigTrigger(spCnt) == 0
    h = gcf;
    h = h+1;
    figure(h) 
    figCntr = figCntr+1;
  end
  %set up figure
  set(gcf,'Position',[scrsz(3)/2-scrsz(3)/2*.80, scrsz(4)/2-scrsz(4)/2*.80, scrsz(3)*.80 ,scrsz(4)*.80])
  set(gcf,'NumberTitle','off')
  set(gcf,'Name',['ArithLibStatistics Analysis (Figure ',num2str(figCntr),' of ',num2str(noOfFigs), ')'])
  %copy HistData
  IDField = fnames{cnt};
  IDFieldComplex = {[IDField, '(REAL)'],[IDField, '(IMAG)']};
  isComplex = ArithLibStatistics.(IDField).IsComplex;
  %get correct HistData and InFixP configs
  if isComplex
      for cidx = 1:2
      HistDataField = ComplexFields{2,cidx};
      InFixPField = ComplexFields{1,cidx};
      HistData = ArithLibStatistics.(IDField).(HistDataField);
      INTW_in = ArithLibStatistics.(IDField).(InFixPField){1};
      FRACW_in = ArithLibStatistics.(IDField).(InFixPField){2};
      SIGN_in = ArithLibStatistics.(IDField).(InFixPField){3};
      INTW = ArithLibStatistics.(IDField).OutFixPt{1};
      FRACW = ArithLibStatistics.(IDField).OutFixPt{2};
      SIGN = ArithLibStatistics.(IDField).OutFixPt{3};      
      binWidth = length(HistData);
      % quantization Type string
      qTypeString = regexprep(ArithLibStatistics.(IDField).QuantType, '_', ' '); %replace underscores with space characters
      % make subplot graphics
      doSubplot(INTW_in,INTW,FRACW_in,FRACW,HistData,binWidth,SIGN_in,SIGN,mPlots,nPlots,maxPlotsPerFig,qTypeString,spCnt,IDFieldComplex{cidx})
      spCnt = spCnt + 1;
      end
  else
    HistData = ArithLibStatistics.(IDField).HistData;
    %get InFixP data
    INTW_in = ArithLibStatistics.(IDField).InFixPt{1};
    FRACW_in = ArithLibStatistics.(IDField).InFixPt{2};
    SIGN_in = ArithLibStatistics.(IDField).InFixPt{3};
    INTW = ArithLibStatistics.(IDField).OutFixPt{1};
    FRACW = ArithLibStatistics.(IDField).OutFixPt{2};
    SIGN = ArithLibStatistics.(IDField).OutFixPt{3};
    binWidth = length(HistData);
    qTypeString = regexprep(ArithLibStatistics.(IDField).QuantType, '_', ' '); %replace underscores with space characters
    doSubplot(INTW_in,INTW,FRACW_in,FRACW,HistData,binWidth,SIGN_in,SIGN,mPlots,nPlots,maxPlotsPerFig,qTypeString,spCnt,IDField)
    spCnt = spCnt + 1;
  end

%disp('------------------')
end %loop

return

function doSubplot(INTW_in,INTW,FRACW_in,FRACW,HistData,binWidth,SIGN_in,SIGN,mPlots,nPlots,maxPlotsPerFig,qTypeString,cnt,IDField)
%MSB handling
  if (INTW_in - INTW > 0) % need more int ticks for display!
    xLabels = [-FRACW:1:INTW_in-1];
  else % pad zeros MSB
    padZeros = INTW - INTW_in;
    HistData = [zeros(1,padZeros) , HistData, zeros(1,padZeros)];
    binWidth = length(HistData);
    xLabels = [-FRACW:1:INTW-1];
  end
  %LSB handling
  if (FRACW_in - FRACW > 0) % need more frac ticks for display!      
    xLabels = [-FRACW_in:1:xLabels(1)-1,xLabels];   
    RoundingBound = FRACW_in - FRACW;
    OverflowBound = FRACW_in + INTW;
    FixPDot = FRACW_in;
  else
    padZeros = FRACW - FRACW_in;
    HistData = [HistData(:,1:binWidth/2), zeros(1,2.*padZeros) , HistData(:,binWidth/2+1:end)];
    binWidth = length(HistData);        
    RoundingBound = 0;
    OverflowBound = FRACW + INTW;
    FixPDot = FRACW;
  end      
  if SIGN == 's'
    nonOvIdx = [binWidth/2-OverflowBound+1:1:binWidth/2+OverflowBound];
    NonOverflowValues = [zeros(1,binWidth/2-OverflowBound),HistData(nonOvIdx)];
    RndIdx = [binWidth/2-RoundingBound+1:1:binWidth/2+RoundingBound];
    RndValues = [zeros(1,binWidth/2-RoundingBound),HistData(RndIdx)];
    signStringOut = 'signed';
  else %unsigned
    nonOvIdx = [binWidth/2+1:1:binWidth/2+OverflowBound];
    NonOverflowValues = [zeros(1,binWidth/2),HistData(nonOvIdx)];
    RndIdx = [binWidth/2+1:1:binWidth/2+RoundingBound];
    RndValues = [zeros(1,binWidth/2),HistData(RndIdx)];    
    signStringOut = 'unsigned';
  end
  if SIGN_in == 's'
    signStringIn = 'signed';
  else
    signStringIn = 'unsigned';
  end
  
  %plot data
  subplot(mPlots,nPlots,mod(cnt-1,maxPlotsPerFig)+1);
  hold on
  bar(HistData,0.7,'r')
  bar(NonOverflowValues,0.7,'g')
  bar(RndValues,0.7,'y')
  plot( binWidth/2+0.5+FixPDot,0,'k.') %fixed point dot +
  if SIGN == 's'
    plot( binWidth/2+0.5-FixPDot,0,'k.') %fixed point dot -  
  end
  xlim([0 binWidth+1])
  hold off
  
  %titles, axis labels
  
  title(['\bf',IDField,'\rm','\newlineQType: ',qTypeString,...
       '\newlineInCfg: ',num2str(INTW_in),'.',num2str(FRACW_in),' ',signStringIn,...
       '\newlineOutCfg: ',num2str(INTW),'.',num2str(FRACW),' ',signStringOut] ) 
  
  %x axis labels
  xLabels = {num2str(xLabels')}; %convert
  xLabelsTotal = [flipud(xLabels{1}) ; xLabels]'; %mirror
  set(gca,'xTick',1:1:binWidth)
  if binWidth/2 >= 10
    set(gca,'XTickLabel',xLabelsTotal,'Fontsize',8)
  else
    set(gca,'XTickLabel',xLabelsTotal)
  end
  set(gca,'YTickLabel',[],'yTick',[],'YColor','w') % hide Y axis


  %centerline
  line([binWidth/2, binWidth/2]+0.5,[0,max(HistData)],'Color','b','LineWidth',1)
  %boundaries
  [maxArithLibStatistics,idxMaxArithLibStatistics] = max(HistData);
  %max bound
  line(binWidth/2+0.5+[OverflowBound, OverflowBound],[0,maxArithLibStatistics],'Color','r','LineWidth',1,'LineStyle','--')
  %min
  if SIGN == 's'
    line(binWidth/2+0.5-[OverflowBound, OverflowBound],[0,maxArithLibStatistics],'Color','r','LineWidth',1,'LineStyle','--')
    %LSB rounding
    line(binWidth/2+0.5+[RoundingBound, RoundingBound],[0,maxArithLibStatistics],'Color','g','LineWidth',1,'LineStyle','--')
    line(binWidth/2+0.5-[RoundingBound, RoundingBound],[0,maxArithLibStatistics],'Color','g','LineWidth',1,'LineStyle','--')
  else
    line(binWidth/2+0.5-[0, 0],[0,maxArithLibStatistics],'Color','r','LineWidth',1,'LineStyle','--')
    %LSB rounding
    line(binWidth/2+0.5+[RoundingBound, RoundingBound],[0,maxArithLibStatistics],'Color','g','LineWidth',1,'LineStyle','--')
  end

  %percentage of overflows
  %pos
  totalCount = sum(HistData(binWidth/2+1:end));
  if totalCount
    nonOverflowCount = sum(NonOverflowValues(binWidth/2+1:end));
    overflowCount = totalCount - nonOverflowCount;  
    overflowPercentage = round(100./totalCount.*overflowCount);
    text(binWidth+1, double(maxArithLibStatistics),[num2str(overflowPercentage),'%'], 'Color', 'r','HorizontalAlignment','Right');
  end
  %neg
  totalCount = sum(HistData(1:binWidth/2));
  if totalCount
    nonOverflowCount = sum(NonOverflowValues(1:binWidth/2));
    overflowCount = totalCount - nonOverflowCount;
    overflowPercentage = round(100./totalCount.*overflowCount);
    text(0, double(maxArithLibStatistics),[num2str(overflowPercentage),'%'], 'Color', 'r','HorizontalAlignment','Left');  
  end

return
