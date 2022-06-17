
%This script runs through PIV results data from Hui Ting's package and
%calculates the rotational and tangent components for each vector assuming
%a starting position of 25,25
clear
path = '/Users/sbarnett/Documents/PIVData/fatima/200_D_C1_Phase_20220307_MCF10ARab5A_H2BGFP_uPatterns-01-Scene-04-P5-A01_cr_Results/PIV_roi_velocity_text';
files = dir(path);
vectorfield = csvread(fullfile(files(3).folder,files(3).name));
cx = max(vectorfield(:,1)/vectorfield(1,1))/2;
cy = max(vectorfield(:,2)/vectorfield(1,2))/2;
cx = 25;
cy = 25;

rotationcomponent = NaN(cx*2,cy*2,size(files,1)-2);
tangentcomponent = NaN(cx*2,cy*2,size(files,1)-2);
radius = 10;

for f = 3:size(files)
    f
    vectorfield = csvread(fullfile(files(f).folder,files(f).name));
    for i = 1:size(vectorfield(:,1))
        x = vectorfield(i,1)/vectorfield(1,1);
        y = vectorfield(i,2)/vectorfield(1,2);
        u = vectorfield(i,3);
        v = vectorfield(i,4);
        
        radialdistance = ((cx-x)^2+(cy-y)^2);
        if radialdistance < radius;
            if or(u~=0, v~=0)
                [xcomponent, ycomponent] = rotacity(cx,cy,x,y,u,v);
                rotationcomponent(x,y,f-2) = xcomponent;
                tangentcomponent(x,y,f-2) = ycomponent;
            else
                tangentcomponent(x,y,f-2) = NaN;
            end
        end
    end
end