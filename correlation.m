function [correl] = Correlation(vectorfieldstack, startframe, endframe)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

u = 1;

minsize = sqrt(size(vectorfieldstack,1));
%check if minsize is odd, if so, subtract 1
if floor(minsize/2) ~= minsize/2
    minsize = minsize-1;
end
radius = minsize/2;

CX=zeros(endframe-startframe,radius); %dt is n_timepoints, radius is half field size
CY=zeros(endframe-startframe,radius);

for frame = startframe:endframe
    
    vectorfield = vectorfieldstack(:,:,frame);
    
    vectorfield(:,1) = vectorfield(:,1)./vectorfield(1,1);
    vectorfield(:,2) = vectorfield(:,2)./vectorfield(1,2);
    
    vvx = reshape(vectorfield(:,3),[sqrt(size(vectorfield,1)),sqrt(size(vectorfield,1))]);
    vvy = reshape(vectorfield(:,4),[sqrt(size(vectorfield,1)),sqrt(size(vectorfield,1))]);
    %make sure image width/height is even number of elements
    vvx(isnan(vvx)==1) = 0;
    vvy(isnan(vvy)==1) = 0;
    vvx = vvx(1:minsize,1:minsize);
    vvy = vvy(1:minsize,1:minsize);
    
    V1=ifft2(abs(fft2(vvx)).^2);
    V2=ifft2(abs(fft2(vvy)).^2);
    
    ccx=V1;
    ccy=V2;
    CX(u,:)=ccx(1:radius);
    CY(u,:)=ccy(1:radius);
    u = u + 1;
end

CX=CX/(minsize^2);
CY=CY/(minsize^2);
correl=mean(CX+CY);

end

