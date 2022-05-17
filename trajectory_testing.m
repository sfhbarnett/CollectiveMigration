%trajectories

MSD = [];
counter = 1
zerovectors = 0
pixel_size = 0.65
timestep = 30;

for j = 1:size(vectorfield,1)
    if or(vectorfield(j,3,1)~=0, vectorfield(j,3,1)~=0)
        x = vectorfield(j,1,1);
        y = vectorfield(j,2,1);
        trajectory = [x,y];
        lostvector = 0;
        for i = 2:size(vectorfield,3)
            ufield = reshape(vectorfield(:,3,i-1),[63,63]);
            vfield = reshape(vectorfield(:,4,i-1),[63,63]);
            newx = round(trajectory(i-1,1));
            newy = round(trajectory(i-1,2));
            newu = ufield(newy,newx);
            newv = vfield(newy,newx);
            if and(newu==0, newv==0)
                lostvector = 1;
                break
            end
            trajectory(i,:) = [trajectory(i-1,1)+newu,trajectory(i-1,2)+newv];
        end
        if lostvector ~= 1
            for t = 1:size(trajectory,1)
                MSD(t,counter) = ((trajectory(t,1)-trajectory(1,1))^2 + (trajectory(t,2)-trajectory(1,2))^2);
            end
            counter = counter + 1;
        end
    end
end

mMSD = mean(MSD,2).*pixel_size^2
time = (1:126) .* timestep;
MSDfit = fit(time',mMSD,'A*x.^2/(1+(B*x))','startpoint',[10 .5],'weight',1./time.^2);

A = MSDfit.A;
B = MSDfit.B;
ci = confint(MSDfit,.95);
da = ci(2,1)-ci(1,1);
db = ci(2,2)-ci(1,2);
L_p = sqrt(A)./B;
%delta_p = sqrt((.5*da/(sqrt(A1)*B1)).^2+(db*sqrt(A1)./B1.^2))*3;