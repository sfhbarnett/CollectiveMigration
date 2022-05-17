%trajectories

MSD = [];
counter = 1
zerovectors = 0
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
