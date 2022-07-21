function [L1,delta1] = CorrelationLength(vectorfield,t1,t2,corel,x,DX,f_)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

meanu = mean(mean(vectorfield(:,3,t1:t2)));
meanv = mean(mean(vectorfield(:,4,t1:t2)));
meanu2 = mean(mean(vectorfield(:,3,t1:t2).^2));
meanv2 = mean(mean(vectorfield(:,4,t1:t2).^2));

difference = (meanu2+meanv2)-(meanu^2+meanv^2);

corr = corel-difference;
flcorr=fit(x',corr','a*exp(-abs(b*x).^c)','startpoint',[corr(1) .01 1],'lower',[0 0 0],'upper',[inf inf 2]);
f2 = f_;
ci = confint(f2,.2);
delta1=abs((ci(2,2)-ci(1,2)));
delta1=DX*delta1./flcorr.b^2;
L1=(DX./flcorr.b)*gamma(1/flcorr.c)./flcorr.c;
delta1=min(L1*.9,delta1);

end