function [resampstruct,res,rhgt,smoothwidths] = resampler(datastruct,patchstruct,faultstruct)
resamp_in

splitid = 0;
iter    = 0;
rp      = 0:0.01:pi*2;
rx      = cos(rp);
ry      = sin(rp);
px      = datastruct.pixelsize;
scale   = datastruct.scale;
nx      = datastruct.nx;
ny      = datastruct.ny;
S       = datastruct.S;
data    = datastruct.data;
X       = datastruct.X;
Y       = datastruct.Y;
hgt     = datastruct.hgt;
Var     = var(data(isfinite(data)));
if(~isempty(hgt))
    dohgt=1;
else
    dohgt=0;
end

smooth  = smoother(2,patchstruct);
a       = scale/2+1:scale:nx;
b       = scale/2+1:scale:ny;

id=0;
for i=1:length(a)
  for j=1:length(b)
    id=id+1;
    resampstruct(id).x     = a(i);
    resampstruct(id).y     = b(j);
    resampstruct(id).scale = scale;
  end
end
np       = length([resampstruct.x]);
Scolumns = reshape(S,nx*ny,3);

while(or(iter==0,~isempty(splitid)))
    disp(['num points=' num2str(np) ' minres=' num2str(min([resampstruct.scale]))])
    iter     = iter+1;

    for i=1:np
        x         = resampstruct(i).x;
        y         = resampstruct(i).y;
        nscale    = resampstruct(i).scale;
        bxx       = (x-nscale/2):(x+nscale/2-1);
        bxy       = (y-nscale/2):(y+nscale/2-1);

        [xi,yi]   = meshgrid(bxx,bxy);
        boxids    = sub2ind(size(X),yi,xi);
        goodids   = boxids(isfinite(data(boxids)));

        resampstruct(i).count  = length(goodids);
        if(goodids)
            resampstruct(i).X    = mean(X(goodids));
            resampstruct(i).Y    = mean(Y(goodids));
            resampstruct(i).data = mean(data(goodids));
            resampstruct(i).S    = mean(Scolumns(goodids,:),1)';
            if(dohgt)
                resampstruct(i).hgt = mean(hgt(goodids));
            end
            bxid(1)=sub2ind(size(X),min(bxy),min(bxx));
            bxid(2)=sub2ind(size(X),min(max(bxy)+1,ny),min(bxx));
            bxid(3)=sub2ind(size(X),min(max(bxy)+1,ny),min(max(bxx)+1,nx));
            bxid(4)=sub2ind(size(X),min(bxy),min(max(bxx)+1,nx));

            resampstruct(i).boxx = X(bxid([1:4 1]))';
            resampstruct(i).boxy = Y(bxid([1:4 1]))';
        end
    end
    id               = find([resampstruct.count]);
    resampstruct     = resampstruct(id);
    np               = length(id);
    if(0)
        save(['iter' num2str(iter) '.mat'],'resampstruct','zone')
    end

    green            = make_green(patchstruct,resampstruct);
    quickinvert
    plotflag         = [resampstruct.scale]==1;
    smoothwidths     = getsmoothwidthsdata(N,resampstruct,plotflag);
    splittest        = (and(smoothwidths<[resampstruct.scale],[resampstruct.scale]>=4));
    splitid          = find(splittest);
    %disp([min(smoothwidths) min([resampstruct.scale]) sum(splittest) sum(splittest2) length(splitid)])
    if(iter==5)
        save alliter5
    end
    sx=[-1 1 1 -1];
    sy=[-1 -1 1 1];
 
    if(np+length(splitid)*3<=maxnp)
        for i=splitid
            nscale=resampstruct(i).scale/2;
            for j=1:4
                resampstruct(np+j).x     = resampstruct(i).x+nscale/2*sx(j);
                resampstruct(np+j).y     = resampstruct(i).y+nscale/2*sy(j);
                resampstruct(np+j).scale = nscale;
            end
            np = length(resampstruct);
        end
        resampstruct = resampstruct(setdiff(1:np,splitid));
        np = length(resampstruct);
    else
        disp('stopping at max points')
        splitid=[];
    end
end

id               = find([resampstruct.count]./[resampstruct.scale].^2*100<=throwout);
disp(['Throwing out ' num2str(length(id)) ' points with less than ' num2str(throwout) '% points'])
id               = find([resampstruct.count]./[resampstruct.scale].^2*100>throwout);
resampstruct     = resampstruct(id);
np               = length(id);
green            = make_green(patchstruct,resampstruct);
quickinvert
   
disp('Calculating residual')
synth   = [green Gramp]*mil;
ramp    = [Gramp]*mil(Npatch*2+[1:nramp]);
zi      = griddata([resampstruct.X],[resampstruct.Y],synth,X,Y);
res     = data-zi;

ver        = [faultstruct.vertices];
dists      = dist_point_lines(X(:),Y(:),ver(1,:),ver(2,:));
res(find(dists<maskdist))=NaN;


figure
subplot(2,3,1)
patch([resampstruct.boxx]/1e3,[resampstruct.boxy]/1e3,[resampstruct.data])
axis image,colorbar('h'),shading flat
title(['resampled data, np=' num2str(np)])

subplot(2,3,2)
if(nx>500);
  a=1:10:ny;
  b=1:10:nx;
  pcolor(X(a,b)/1e3,Y(a,b)/1e3,res(a,b))
else
  pcolor(X/1e3,Y/1e3,res)
end
hold on
%plot([patchstruct.xfault]/1e3,[patchstruct.yfault]/1e3,'k')
axis image,colorbar('h'),shading flat
title('res used in covariance estimation')
cax=caxis;

subplot(2,3,4)
patch([resampstruct.boxx]/1e3,[resampstruct.boxy]/1e3,[resampstruct.scale])
axis image,colorbar('h')
title(['minimum scale=' num2str(min([resampstruct.scale]))])

subplot(2,3,5)
patch([resampstruct.boxx]/1e3,[resampstruct.boxy]/1e3,[resampstruct.count])
hold on
plot([resampstruct.X]/1e3,[resampstruct.Y]/1e3,'k.','markersize',1)
axis image,colorbar('h');
title('count per box');

subplot(2,3,6)
patch([resampstruct.boxx]/1e3,[resampstruct.boxy]/1e3,ramp')
axis image,colorbar('h')
title('best fit bilinear ramp')



if(dohgt)
    disp('Scaling by height')
    hgtid  = and(isfinite(res),hgt>minhgt);
    p      = polyfit(hgt(hgtid),res(hgtid),1);
    modhgt = p(1)*hgt+p(2);
    rhgt   = res-modhgt;
    subplot(2,3,3)
    if(nx>500);
        a=1:10:ny;
        b=1:10:nx;
        pcolor(X(a,b)/1e3,Y(a,b)/1e3,rhgt(a,b))
    else
        pcolor(X/1e3,Y/1e3,rhgt)
    end
    axis image,colorbar('h'),shading flat
    title('res scaled by hgt')
    caxis(cax);
else
    rhgt=[];
end



