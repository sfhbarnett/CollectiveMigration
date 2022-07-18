function [cx,cy] = findCentre(vectorfield)
%Finds the center of a circularly monolayer of cells. Takes a vectorfield as
%an imput and outputs cx and cy, the centre of the monolayer. 


%improvement, weight based on center of mass
u = vectorfield(:,3,1);
u = reshape(u,[63,63]);

ulog = u~=0;

dim1 = max(ulog,[],1);
d = diff(dim1);
left = find(d==1)+1;
right = find(d==-1);

dim2 = max(ulog,[],2);
d = diff(dim2);
top = find(d==1)+1;
bottom = find(d==-1);


cx = round(left+(right-left)/2);
cy = round(top+(bottom-top)/2);

end

