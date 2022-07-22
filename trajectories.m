function trajectories = trajectories(vectorfield,width,height)

trajectories = [];
counter = 1;
zerovectors = 0;
%pixel_size = 0.65;
%timestep = 30;

% for each vector
for j = 1:size(vectorfield,1)
    % if either u or v is not zero
    %if or(vectorfield(j,3,1)~=0, vectorfield(j,4,1)~=0)
    %normalise x/y
    x = vectorfield(j,1,1)/vectorfield(1,1,1);
    y = vectorfield(j,2,1)/vectorfield(1,1,1);
    trajectory = [x,y];
    lostvector = 0;
    for i = 2:size(vectorfield,3)
        ufield = reshape(vectorfield(:,3,i-1),[width,height]);
        vfield = reshape(vectorfield(:,4,i-1),[width,height]);
        newx = round(trajectory(i-1,1));
        newy = round(trajectory(i-1,2));
        
        %             if newy < 1 || newy > 67 || newx < 1 || newx > 67 %if trajectory leaves field
        %                 lostvector = 1;
        %                 break
        %             end
        
        if newx > width
            newx = width;
        end
        if newy > height
            newy = height;
        end
        if newx < 1
            newx = 1;
        end
        if newy < 1
            newy = 1;
        end
        newu = ufield(newy,newx);
        newv = vfield(newy,newx);
        
        %             if and(newu==0, newv==0) %should change this to be NaNs maybe
        %                 lostvector = 1;
        %                 break
        %             end
        trajectory(i,:) = [trajectory(i-1,1)+newu,trajectory(i-1,2)+newv];
    end
    if lostvector ~= 1
        trajectories(:,counter:counter+1) = trajectory;
        counter = counter + 2;
    end
    %end
end

for t = 1:size(vectorfield,3)
    ufield(:,:,t) = reshape(vectorfield(:,3,t),[width,height]);
    vfield(:,:,t) = reshape(vectorfield(:,4,t),[width,height]);
end

uind = 1:width;
vind = 1:height;
[uind,vind] = meshgrid(uind,vind);

for t = 2:size(vectorfield,3)
    tjs = trajectories(t,:);
    t
    xcoord = tjs(1:2:end).';
    xcoord = repmat(xcoord,1,width,height);
    xcoord = permute(xcoord,[3,2,1]);
    
    ycoord = tjs(2:2:end).';
    ycoord = repmat(ycoord,1,width,heigth);
    ycoord = permute(ycoord,[3,2,1]);
    
    diffx = (xcoord-uind).^2;
    diffy = (ycoord-vind).^2;
    
    d = min(diffx + diffy,[],3);
    
    idx = find(d>1.5);
    
    for i = 1:size(idx,1)
        new_tj = [uind(idx(i)),vind(idx(i))];
        c = 1;
        lostvector = 0;
        for furthert = t+1:size(vectorfield,3)
            newx = round(new_tj(c,1));
            newy = round(new_tj(c,2));
            
%             if newy < 1 || newy > 67 || newx < 1 || newx > 67 %if trajectory leaves field
%                 lostvector = 1;
%                 break
%             end
            
            if newx > width
                newx = width;
            end
            if newy > height
                newy = height;
            end
            if newx < 1
                newx = 1;
            end
            if newy < 1
                newy = 1;
            end
            
            newu = ufield(newy,newx,furthert);
            newv = vfield(newy,newx,furthert);
            
            new_tj(c+1,:) = [new_tj(c,1)+newu,new_tj(c,2)+newv];
            c = c + 1;
        end
        if lostvector ~= 1
            trajectories(t:end,end+1:end+2) = new_tj;
        end
    end
end


end
