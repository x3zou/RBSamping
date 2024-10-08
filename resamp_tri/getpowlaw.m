function res=getpowlaw(in,x,c,n)


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

