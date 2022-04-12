

path = '/Users/sbarnett/Documents/PIVData/Adil/100nm/WH Zeiss 100 nm_Results/PIV_roi_velocity_text/';
files = dir(path);
names = {};
for i=1:128
    test = files(i).name;
    names{i} = files(i).name;
end

vectorfield = csvread(fullfile(files(3).folder,files(4).name));
%%
filessort = natsort(names).';
average = 0;
total = 0;
totalu = 0;
totalv = 0;

for vector = 1:size(vectorfield,1)
    x = vectorfield(i,1)/vectorfield(1,1);
    y = vectorfield(i,2)/vectorfield(1,2);
    u = vectorfield(i,3);
    v = vectorfield(i,4);

    angle = rad2deg(atan2(v,u))+180;
    average = average + (u^2 + v^2);
    totalu = totalu + u;
    totalv = totalv + v;
    total = total + 1;
end
vrms = sqrt(average/total);
avgu = totalu/total;
avgv = totalv/total;
absvector = (avgu^2 + avgv^2)

absvector/(average/total)

%%

order = [];
for f = 3:size(files)
    vectorfield = csvread(fullfile(files(3).folder,files(f).name));
    ind = vectorfield(:,2)<(1904);
    meanu = mean(vectorfield(ind,3));
    meanv = mean(vectorfield(ind,4));
    mean_v2=mean(mean(vectorfield(ind,3).^2+vectorfield(ind,4).^2));
    mean_abs_v=mean(mean(sqrt(vectorfield(ind,3).^2+vectorfield(ind,4).^2)));

    order(f-2) = (meanu.^2+meanv.^2)./(mean_v2);
end

%%



vrms = sqrt(average/total);
avgu = totalu/total;
avgv = totalv/total;
absvector = (avgu^2 + avgv^2)

absvector/(average/total)

%%

order = [];
for f = 3:size(files)
    vectorfield = csvread(fullfile(files(3).folder,files(f).name));
    ind = vectorfield(:,2)<(1904);
    meanu = mean(vectorfield(ind,3));
    meanv = mean(vectorfield(ind,4));
    mean_v2=mean(mean(vectorfield(ind,3).^2+vectorfield(ind,4).^2));
    mean_abs_v=mean(mean(sqrt(vectorfield(ind,3).^2+vectorfield(ind,4).^2)));

    order(f-2) = (meanu.^2+meanv.^2)./(mean_v2);
end

%%


order = [];

for f = 3:size(files)
    vectorfield = csvread(fullfile(files(3).folder,files(f).name));
    
    meanu = mean(vectorfield(:,3));
    meanv = mean(vectorfield(:,4));
    mean_v2=mean(mean(vectorfield(:,3).^2+vectorfield(:,4).^2));
    mean_abs_v=mean(mean(sqrt(vectorfield(:,3).^2+vectorfield(:,4).^2)));

    order(f-2) = (meanu.^2+meanv.^2)./(mean_v2);
end


plot(order)

%%










