function [covstruct] = resampcov(resampstruct,datastruct,covstruct)

maxcovp     = 1e3;
np          = length(resampstruct);
pixelsize   = datastruct.pixelsize;
data        = datastruct.data;
im          = sqrt(-1);
tmpid1      = randperm(maxcovp)';
tmpid2      = randperm(maxcovp)';
Var         = covstruct.Var;
els         = covstruct.els;
a           = els(1);
b           = els(2);
alpha       = els(3);
Q           = [cos(alpha), -sin(alpha); sin(alpha) cos(alpha)];
sampledcov  = zeros(np);

tic
h=waitbar(0,'Calculating Cd');
for i=1:np

    %calc new variance of average
    bxx      = ((resampstruct(i).x-resampstruct(i).scale/2)):((resampstruct(i).x+resampstruct(i).scale/2-1));
    bxy      = ((resampstruct(i).y-resampstruct(i).scale/2)):((resampstruct(i).y+resampstruct(i).scale/2-1));
    tmpdata  = data(bxy,bxx);
    goodid   = find(isfinite(tmpdata));
    n        = length(goodid);
    [bxx,bxy]= meshgrid(bxx,bxy);
    if(n^2>maxcovp)
        tmp1   = mod(tmpid1,n)+1;
        tmp2   = mod(tmpid2,n)+1;
        distsx = bxx(goodid(tmp1))-bxx(goodid(tmp2));
        distsy = bxy(goodid(tmp1))-bxy(goodid(tmp2));

    else
        bx       = meshgrid(bxx(goodid),bxx(goodid));
        by       = meshgrid(bxy(goodid),bxy(goodid));
        distsx   = bx-bx';
        distsy   = by-by';

    end
    newd  = sqrt(distsx.^2+distsy.^2);
    angs  = atan2(distsy(:),distsx(:))';
    angs2 = atan(a/b*tan(angs-alpha));
    X     = Q*[a*cos(angs2);b*sin(angs2)];
    sc    = sqrt(X(1,:).^2+X(2,:).^2);
    covs  = Var(1)*10.^(-newd(:)./sc');
    if(~isfinite(mean(covs(:))))
        disp(i)
        return
    end
    sampledcov(i,i) = mean(covs(:));

    %now do vs. other patches
    for l=(i+1):np
        dx   = resampstruct(i).x-resampstruct(l).x;
        dy   = resampstruct(i).y-resampstruct(l).y;
        avgl = sqrt(dx^2+dy^2);

        bxx2        = ((resampstruct(l).x-resampstruct(l).scale/2)):((resampstruct(l).x+resampstruct(l).scale/2-1));
        bxy2        = ((resampstruct(l).y-resampstruct(l).scale/2)):((resampstruct(l).y+resampstruct(l).scale/2-1));
        tmpdata     = data(bxy2,bxx2);
        goodid2     = find(isfinite(tmpdata));
        n2          = length(goodid2);
        [bxx2,bxy2] = meshgrid(bxx2,bxy2);

        if(n*n2>maxcovp)
            tmp1   = mod(tmpid1,n)+1;
            tmp2   = mod(tmpid2,n2)+1;
            distsx = bxx(goodid(tmp1))-bxx2(goodid2(tmp2));
            distsy = bxy(goodid(tmp1))-bxy2(goodid2(tmp2));
        else
            [bx,bx2]  = meshgrid(bxx(goodid),bxx2(goodid2));
            [by,by2]  = meshgrid(bxy(goodid),bxy2(goodid2));
            distsx    = bx-bx2;
            distsy    = by-by2;
        end
        newd  = sqrt(distsx.^2+distsy.^2);
        angs  = atan2(distsy(:),distsx(:))';
        angs2 = atan(a/b*tan(angs-alpha));
        X     = Q*[a*cos(angs2);b*sin(angs2)];
        sc    = sqrt(X(1,:).^2+X(2,:).^2);
        covs  = Var(1)*10.^(-newd(:)./sc');
        
        sampledcov(i,l) = mean(covs(:));
        sampledcov(l,i) = sampledcov(i,l);
    end
    waitbar(i/np,h);
end
close(h)


%manipulate matrix a bit to make it REALLY positive definite.
[U,E,V]       = svd(sampledcov);
sampledcov    = U*E*U';
covstruct.cov = sampledcov;

%Generate some noise
%If you want to check covariance, n should be diag.
noise = corr_noise(sampledcov,1);

[ch,junk] = chol(sampledcov);
if(junk==0)
    Cdinv = inv(ch');
    n     = Cdinv*noise;
    figure
    patch([resampstruct.boxx]/1e3,[resampstruct.boxy]/1e3,n')
    axis image,shading flat
    colorbar('h')
    title('Weighted noise, should be random if Chol worked');
    
else
    disp('Cholesky fact. failed')
    disp('You should never get to this point...something is wrong!')
    n     = noise;
end

figure,orient landscape,wysiwyg
subplot(2,3,1)
imagesc(sampledcov)
axis square
title('Sampled covariance matrix, Cd')

subplot(2,3,2)
patch([resampstruct.boxx]/1e3,[resampstruct.boxy]/1e3,noise')
axis image,shading flat
colorbar('h')
title('synthetic noise, generated with Cd')

subplot(2,3,3)
patch([resampstruct.boxx]/1e3,[resampstruct.boxy]/1e3,diag(sampledcov)')
axis image,shading flat
colorbar('h')
title('Resampled Variance (cm^2)');

pointid=10;
subplot(2,3,4)
patch([resampstruct.boxx]/1e3,[resampstruct.boxy]/1e3,sampledcov(pointid,:))
hold on
plot(resampstruct(pointid).boxx/1e3,resampstruct(pointid).boxy/1e3,'k','linewidth',4)
axis image,shading flat
colorbar('h')
title('Resampled Covariance at 10th point (cm)^2');


pointid=np-10;
subplot(2,3,5)
patch([resampstruct.boxx]/1e3,[resampstruct.boxy]/1e3,sampledcov(pointid,:))
hold on
plot(resampstruct(pointid).boxx/1e3,resampstruct(pointid).boxy/1e3,'k','linewidth',4)
axis image,shading flat
colorbar('h')
title('Resampled Covariance at 10th to last point (cm)^2');

dists=sqrt(([resampstruct.X]-resampstruct(pointid).X).^2+([resampstruct.Y]-resampstruct(pointid).Y).^2);
subplot(2,3,6)
plot(dists(:)/1e3,sampledcov(pointid,:),'b.')
hold on
a=axis;
xlabel('Distance (km)')
ylabel('Covariance (cm^2)')




