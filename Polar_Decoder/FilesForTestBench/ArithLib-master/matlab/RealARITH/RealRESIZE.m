function y = RealRESIZE(x,FixP,QType,IDString)
% function y = RealRESIZE(x,FixP,QType)
% Quantize x-vector to fixpoint configuration FixP, using quantization
% type QType.
         
LSB=2^-FixP{2};

if strcmp(QType,'WrpRnd') | strcmp(QType,'ClpRnd') | strcmp(QType,'SatRnd') | ...
   strcmp(QType,'WrpRnd_NoWarn') | strcmp(QType,'ClpRnd_NoWarn') | strcmp(QType,'SatRnd_NoWarn')
    % ROUND
    y=floor(x/LSB+0.5);
elseif strcmp(QType,'WrpTrc') | strcmp(QType,'ClpTrc') | strcmp(QType,'SatTrc') | ...
    strcmp(QType,'WrpTrc_NoWarn') | strcmp(QType,'ClpTrc_NoWarn') | strcmp(QType,'SatTrc_NoWarn')
    % TRUNCATE
    y=floor(x/LSB);
else
    error('QType must be one of ''WrpTrc'', ''WrpRnd'', ''SatTrc'', ''SatRnd'' or ''*_NoWarn''');
end;

maxVal = 2^(FixP{1}+FixP{2})-1;
if FixP{3} == 's'
    % signed
    minVal_clp = -2^(FixP{1}+FixP{2}); % for overflow
    minVal_sat = minVal_clp+1; % symmetric range for saturation
elseif FixP{3} == 'u'
    minVal_clp = 0;
    minVal_sat = minVal_clp;
else
    error('FixP{3} (Type) must be one of ''s'' or ''u''.');
end
if any(any(y>maxVal)) | any(any(y<minVal_sat))
    if strcmp(QType,'SatTrc') | strcmp(QType,'SatRnd') | ...
        strcmp(QType,'SatTrc_NoWarn') | strcmp(QType,'SatRnd_NoWarn')
        % SATURATE
        if ~(strcmp(QType,'SatTrc_NoWarn') | strcmp(QType,'SatRnd_NoWarn'))
          warning('CLS:RealARITH:Saturation','Saturation performed!');
        end
        y = max(min(y, maxVal), minVal_sat);
    elseif any(any(y>maxVal)) | any(any(y<minVal_clp))
        % OVERFLOW
        if ~(strcmp(QType,'WrpTrc_NoWarn') | strcmp(QType,'WrpRnd_NoWarn') |...
             strcmp(QType,'ClpTrc_NoWarn') | strcmp(QType,'ClpRnd_NoWarn'))
          warning('CLS:RealARITH:Overflow','Overflow performed!');
        end
        % unsigned
        % y = y - floor(y/2^(FixP{1}+FixP{2}))*2^(FixP{1}+FixP{2});
        y = mod(y-minVal_clp,2^(FixP{1}+FixP{2}+(FixP{3}=='s')))+minVal_clp;
    end
end
y = y*LSB;  
