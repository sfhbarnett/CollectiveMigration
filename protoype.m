
quiver(vectorfield(:,1)./16,vectorfield(:,2)./16,vectorfield(:,3),vectorfield(:,4),5)
axis([20 45 20 45])
axis equal
hold on
plot(31.5,31.5,'o')
%%
x = 34-63/2;
y = 40-63/2;
u = 0.036272;
v = -0.05467;

%plot(x,y,'o')


theta = rad2deg(atan2(y,x))+180;
fromN = deg2rad(270 - theta);

rotmat = [cos(fromN),-sin(fromN);sin(fromN),cos(fromN)];

rotated = rotmat*[x;y];



normalised = [u,v]/norm([u,v]);
nu = normalised(1);
nv = normalised(2);

rotnormuv = rotmat*[nu;nv];
rotuv = rotmat*[u;v];
rotuvnorm = rotuv/norm(rotuv);

angle = rad2deg(atan2(rotnormuv(2),rotnormuv(1)))+180;
if angle < 90
    1-angle/90
elseif angle >=90 && angle < 180
    (angle-90)/90
elseif angle >= 180 && angle < 270
    1-(angle-180)/90
elseif angle > 270
    (angle-270)/90
end


%(rad2deg(atan2(rotnormuv(2),rotnormuv(1)))+180)/90;

%%

%%
x = 31-63/2;
y = 39-63/2;

%plot(x,y,'o')


theta = rad2deg(atan2(y,x))+180;
if theta > 0 && theta < 90
    theta = theta + 180
elseif theta > 270
    theta = theta - 270
end
    

fromN = deg2rad(270 - theta);

rotmat = [cos(fromN),-sin(fromN);sin(fromN),cos(fromN)];

rotated = rotmat*[x;y]

u = -0.013237;
v = 0.19387;

normalised = [u,v]/norm([u,v]);
nu = normalised(1);
nv = normalised(2);

rotnormuv = rotmat*[nu;nv];
rotuv = rotmat*[u;v];
rotuvnorm = rotuv/norm(rotuv);

rad2deg(atan2(rotnormuv(2),rotnormuv(1)))/90