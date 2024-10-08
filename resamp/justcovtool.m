resamp_in

% Load data and add zeros so that ~ power of 2
[datastruct] = load_any_data(datafilename,zone,limitny,azo,scaleval);
datastruct.data=[-datastruct.data];
[datastruct] = load_los(datastruct,losfilename,azo,const_los);
[datastruct] = heightscale(datastruct,demfilename);

res=datastruct.data;

if(dohgt)
    hgt=datastruct.hgt;
    disp('Scaling by height')
    hgtid  = and(isfinite(res),hgt>minhgt);
    p      = polyfit(hgt(hgtid),res(hgtid),1);
    modhgt = p(1)*hgt+p(2);
    rhgt   = res-modhgt;
%     subplot(2,3,3)
%     if(nx>500);
%         a=1:10:ny;
%         b=1:10:nx;
%         pcolor(X(a,b)/1e3,Y(a,b)/1e3,rhgt(a,b))
%     else
%         pcolor(X/1e3,Y/1e3,rhgt)
%     end
%     axis image,colorbar('h'),shading flat
%     title('res scaled by hgt')
%     caxis(cax);
else
    rhgt=[];
end

Var                = var(res(isfinite(res)));

disp('Calculating data covariance')
covstruct=struct('cov',[],'Var',Var,'tx',[],'ty',[],'Vxy',[],'allnxy',[],'els',[]);
plotflag    = 1;
covstruct   = get_cov_quick(covstruct,plotflag,res);
savestruct.covstruct=covstruct;

if(demfilename)
    Varh       = var(rhgt(isfinite(rhgt)));
    covstructh = struct('cov',[],'Var',Varh,'tx',[],'ty',[],'Vxy',[],'allnxy',[],'els',[]);

    plotflag    = 1;
    covstructh  = get_cov_quick(covstructh,plotflag,rhgt);
    savestruct.covstructh=covstructh;
end

save saved savestruct
