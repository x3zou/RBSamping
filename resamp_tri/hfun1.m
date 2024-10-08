function h = hfun1(x,y,args)

newscales = args{1};
yc        = args{2};
zc        = args{3};

h  = griddata(yc,zc,newscales,x,y);
h2 = griddata(yc,zc,newscales,x,y,'nearest');

id=find(isnan(h));
h(id)=h2(id);

% User defined size function for square

%h = 0.01 + 0.1*sqrt( (x-0.25).^2+(y-0.75).^2 );
%h  = peaks(x/2e3,(y-4e3)/1e3);
%h=1./(h.^4+10)*30e3;
end      % hfun1()
