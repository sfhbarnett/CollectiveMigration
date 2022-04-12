path = '/Users/sbarnett/Documents/PIVData/Adil/100nm/WH Zeiss 100 nm_Results/PIV_roi_velocity_text/';
files = dir(path);
names = {};
for i=1:128
    test = files(i).name;
    names{i} = files(i).name;
end
filessort = natsort(names).';


%%

vectorfield = csvread(fullfile(files(3).folder,files(4).name));
vectorfield(:,1) = vectorfield(:,1)./vectorfield(1,1);
vectorfield(:,2) = vectorfield(:,2)./vectorfield(1,2);
vvx = reshape(vectorfield(:,1),[119,119]);
vvy = reshape(vectorfield(:,2),[119,119]);

V1=ifft2(abs(fft2(vvx)).^2);
V2=ifft2(abs(fft2(vvy)).^2);

%            ccx=cust_mask_anav(V1,1,M);
%            ccy=cust_mask_anav(V2,1,M);
ccx=V1;
ccy=V2;
CX(u,:)=ccx(1:L);
CY(u,:)=ccy(1:L);

%%

u=0;
FRAME1 = 10;
FRAME2 = 100;
LL = 62;
L = LL/2;
for s=FRAME1:FRAME2
    vectorfield = csvread(fullfile(files(3).folder,files(s).name));
    vectorfield(:,1) = vectorfield(:,1)./vectorfield(1,1);
    vectorfield(:,2) = vectorfield(:,2)./vectorfield(1,2);
    u=u+1;
    
    vvx = reshape(vectorfield(:,3),[max(vectorfield(:,1)),max(vectorfield(:,2))]);
    vvy = reshape(vectorfield(:,4),[max(vectorfield(:,1)),max(vectorfield(:,2))]);
    
    vvx=vvx(1:LL,1:LL);
    vvy=vvy(1:LL,1:LL);
    
    V1=ifft2(abs(fft2(vvx)).^2);
    V2=ifft2(abs(fft2(vvy)).^2);
    
    %            ccx=cust_mask_anav(V1,1,M);
    %            ccy=cust_mask_anav(V2,1,M);
    ccx=V1;
    ccy=V2;
    CX(u,:)=ccx(1:L);
    CY(u,:)=ccy(1:L);
end

CX=CX/(LL^2);
CY=CY/(LL^2);
C=mean(CX+CY);
x=(1:length(C))-1;
f_=fit(x',C','exp2');
F = f_.a*exp(f_.b*x) + f_.c*exp(f_.d*x);

plot(x,C./(f_.a +f_.c),'s');

hold on
plot(x,F/(f_.a +f_.c),'r');


