function payoffs=smileSkewEuro(nx,bmObj,param)
% SMILESKEWEURO generates European option payoffs for asset paths with a
% volatility smile and skew

bmPaths = genPaths(bmObj,nx); %generate the Brownian motion paths
[nPaths,d] = size(bmPaths); %get dimension of payoffs
stockPaths = zeros(nPaths,d); %initialize stock paths
vol=param.assetParam.volatility ...
   +param.assetParam.sigskew*(param.assetParam.initPrice./param.payoffParam.strike-1) ...
   +param.assetParam.sigsmile*(param.assetParam.initPrice./param.payoffParam.strike-1).^2;
stockPaths(:,1)=param.assetParam.initPrice ...
   .*exp((param.assetParam.interest-vol.*vol/2)*bmObj.timeDim.timeIncrement(1) ...
   + vol.*bmPaths(:,1));
for j=2:d
   vol=param.assetParam.volatility ...
      +param.assetParam.sigskew*(stockPaths(:,j-1)./param.payoffParam.strike-1) ...
      +param.assetParam.sigsmile*(stockPaths(:,j-1)./param.payoffParam.strike-1).^2;
   stockPaths(:,j)=stockPaths(:,j-1) ...
      .*exp((param.assetParam.interest-vol.*vol/2)*bmObj.timeDim.timeIncrement(j) + ...
      vol.*(bmPaths(:,j)-bmPaths(:,j-1)));
end
if strcmp(param.payoffParam.putCallType,'call')
   payoffs = max(stockPaths(:,d)-param.payoffParam.strike,0) ...
      *exp(-param.assetParam.interest*bmObj.timeDim.endTime);
elseif strcmp(param.payoffParam.putCallType,'put')
   payoffs = max(param.payoffParam.strike-stockPaths(:,d),0) ...
      *exp(-param.assetParam.interest*bmObj.timeDim.endTime);
end