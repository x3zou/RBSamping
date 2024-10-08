function [smooth]=trismooth_ro(twoD,patchstruct)

np=length(patchstruct);
x=[patchstruct.xfault];
y=[patchstruct.yfault];
z=[patchstruct.zfault];

smooth=eye(np);

for i=1:np
    poly=[x(:,i) y(:,i) z(:,i)];
    areas(i)=polygonArea3d(poly);
    connects=zeros(1,np);
    for j=1:3
        [id,jd]=find(and(and(x==x(j,i),y==y(j,i)),z==z(j,i)));
        connects(jd)=connects(jd)+1;
    end
    
    neighbs=find(connects==2);
    nneighb=length(neighbs);
    if(nneighb<1)
        disp('no neighbors?')
    elseif(nneighb>3)
        disp('too many neighbors')
    else
        smooth(i,neighbs)=-1/nneighb;
    end
end

if (twoD==2)
  smooth=blkdiag(smooth,smooth);
end
