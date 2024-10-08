function res=gausfun(in)
global x2 b y2
id=find(x2==0);

%a=in(1);
c=in(1);
%res=norm(a*exp(-((x2-b)/c).^2)-y2);
res=y2(id)*exp(-((x2-b)/c).^2)-y2;
