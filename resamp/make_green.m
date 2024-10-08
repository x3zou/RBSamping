function [green,greenX,greenY,greenZ]=make_green(patchstruct,datastruct)
%ss +=left-lateral
%ds +=thrust


x    = [];
y    = [];
S    = [];

numfiles = length(datastruct);
Npatch   = length(patchstruct);

for i=1:numfiles;
  x    = [x; datastruct(i).X];
  y    = [y; datastruct(i).Y];
  st   = [datastruct(i).S];
  S    = [S; datastruct(i).S];
end
[n,m]=size(st);
if(n==3)
    S=reshape(S,3,length(x));
    S=S';
elseif(m==3)
    S=S;
else
    disp('S needs one dimension to be 3');
end

np=length(x);

green=zeros(np,Npatch*2);
if (nargout>1)
  greenX=zeros(np,Npatch*2);
  greenY=zeros(np,Npatch*2);
  greenZ=zeros(np,Npatch*2);
end

%h=waitbar(0,'Calculating Green''s Functions');
for j=1:2
 for i=1:Npatch
   id     = i+(j-1)*Npatch;
   x0     = patchstruct(i).x0;
   y0     = patchstruct(i).y0;
   z0     = patchstruct(i).z0;
   L      = patchstruct(i).L;
   W      = patchstruct(i).W;
   strike = patchstruct(i).strike;
   dip    = patchstruct(i).dip;

   [ux,uy,uz]  = calc_okada(1,x-x0,y-y0,.25,dip,z0,L,W,j,strike);

   green(:,id) = [ux.*S(:,1)+uy.*S(:,2)+uz.*S(:,3)];
 
  if (nargout>1)
    greenX(:,id)= ux;
    greenY(:,id)= uy;
    greenZ(:,id)= uz;
  end
 % waitbar(id/Npatch/2,h);
 end
end

%close(h)
