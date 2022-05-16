
vectorfield = generateVortex(100,100,0);
%quiver(vectorfield(:,1),vectorfield(:,2),vectorfield(:,3),vectorfield(:,4))
ROP = RotationalOrderParameter(vectorfield)
%%
[LFu,LFv] = LinearizeField(vectorfield,50,50);
quiver(vectorfield(:,1),vectorfield(:,2),LFu(:),LFv(:),1)