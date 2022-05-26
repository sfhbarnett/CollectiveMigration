function trajectories = trajectories(vectorfield)

trajectories = [];
counter = 1;
zerovectors = 0;
%pixel_size = 0.65;
%timestep = 30;

for j = 1:size(vectorfield,1)
    if or(vectorfield(j,3,1)~=0, vectorfield(j,3,1)~=0)
        x = vectorfield(j,1,1)/vectorfield(1,1,1);
        y = vectorfield(j,2,1)/vectorfield(1,1,1);
        trajectory = [x,y];
        lostvector = 0;
        for i = 2:size(vectorfield,3)
            ufield = reshape(vectorfield(:,3,i-1),[63,63]);
            vfield = reshape(vectorfield(:,4,i-1),[63,63]);
            newx = round(trajectory(i-1,1));
            newy = round(trajectory(i-1,2));
            
            if newy < 1 || newy > 63 || newx < 1 || newx > 63 %if trajectory leaves field
                lostvector = 1;
                break
            end
            
            newu = ufield(newy,newx);
            newv = vfield(newy,newx);
            
            if and(newu==0, newv==0) %should change this to be NaNs maybe
                lostvector = 1;
                break
            end
            trajectory(i,:) = [trajectory(i-1,1)+newu,trajectory(i-1,2)+newv];
        end
        if lostvector ~= 1
            trajectories(:,counter:counter+1) = trajectory;
            counter = counter + 2;
        end
    end
end


end
