function [res,modcovs]=fit_covs_powlaw(in,tx,ty,Vxy,Var)

alpha=in(1);
a=in(2);
b=in(3);
V=in(4);
shortdist=1; %length scale of decorrelation/random noise

dists=sqrt(tx.^2+ty.^2);
angs       = atan2(ty,tx);
Q     = [cos(alpha), -sin(alpha); sin(alpha) cos(alpha)];
angs2 = atan(a/b*tan(angs-alpha));
X     = Q*[a*cos(angs2');b*sin(angs2')];
x2    = X(1,:);
y2    = X(2,:);


eldist  = sqrt(X(1,:).^2+X(2,:).^2);
scale=max(Vxy);
Vxy=Vxy/scale;
Var=Var/scale;
V=V/scale;

modcovs1 = (Var-V)*10.^(-dists/shortdist);
modcovs2 = V*10.^(-dists./eldist');

modcovs=modcovs1+modcovs2;

res=Vxy-modcovs;

modcovs=modcovs*scale;

return
scale=max(c);
c=c/scale;
Var=in(1);
Var=Var/scale;
l=in(2);
n=n/max(n);


%res=norm(a*exp(-((x2-b)/c).^2)-y2);
%res=a*exp(-((x2-b)/c).^2)-y2;

powfit        = Var*10.^(-x/l);

%whos powfitx c

res=powfit-c;
res=res.*n;
%disp(norm(res))

