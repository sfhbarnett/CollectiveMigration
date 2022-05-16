
clear
path = '/Users/sbarnett/Documents/PIVData/Adil/100nm/WH Zeiss 100 nm_Results/PIV_roi_velocity_text/';
files = dir(path);
names = {};
for i=1:size(files,1)
    test = files(i).name;
    names{i} = files(i).name;
end
f = natsort(names).';
%%
ROP = [];
LOP = []
for i = 3:size(files,1)
    vectorfield = csvread(fullfile(files(3).folder,cell2mat(f(i))));
    %Uncomment which one you want to use
    ROP(i-2) = RotationalOrderParameter(vectorfield);
    LOP(i-2) = LinearOrderParameter(vectorfield)
end