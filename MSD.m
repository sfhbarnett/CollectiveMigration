%trajectories
function msd = MSD(vectorfield)

msd = [];
counter = 1;
zerovectors = 0;
%pixel_size = 0.65;
%timestep = 30;
tottrajectories = [];

for j = 1:size(vectorfield,1)
    if or(vectorfield(j,3,1)~=0, vectorfield(j,3,1)~=0)
        x = vectorfield(j,1,1)./vectorfield(1,1,1);
        y = vectorfield(j,2,1)./vectorfield(1,2,1);
        trajectory = [x,y];
        lostvector = 0;
        for i = 2:size(vectorfield,3) %for every timesetep
            ufield = reshape(vectorfield(:,3,i-1),[sqrt(size(vectorfield,1)),sqrt(size(vectorfield,1))]);
            vfield = reshape(vectorfield(:,4,i-1),[sqrt(size(vectorfield,1)),sqrt(size(vectorfield,1))]);
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
        %calculate MSD
        if lostvector ~= 1
            tottrajectories(:,:,counter) = trajectory;
            %for t = 1:size(trajectory,1)
            %    msd(t,counter) = ((trajectory(t,1)-trajectory(1,1))^2 + (trajectory(t,2)-trajectory(1,2))^2);
            %end
            counter = counter + 1;
        end
    end
end

for tau = 1:size(tottrajectories,1)/4
    for t = 1:size(tottrajectories,3)
        deltacoords = tottrajectories(1+tau:end,:,t)-tottrajectories(1:end-tau,:,t);
        squares = sum(deltacoords.^2,2);
        msd(t,tau) = mean(squares);
    end
end
end
