
for k=1:numfaults
  xt     = mean(faultstruct(k).vertices(1,:));
  yt     = mean(faultstruct(k).vertices(2,:));
  strike = faultstruct(k).strike;
  L      = faultstruct(k).L;
  W      = faultstruct(k).W;
  dip    = faultstruct(k).dip;
  zt     = faultstruct(k).zt;
  Lp     = Lps(k);

  strikerad = strike*pi/180;
  diprad    = dip*pi/180;
  if(dip>0)
    x0        = xt+W.*cos(diprad).*cos(strikerad);   
    y0        = yt-W.*cos(diprad).*sin(strikerad);  
  else
    x0        = xt-W.*cos(diprad).*cos(strikerad);   
    y0        = yt+W.*cos(diprad).*sin(strikerad);   
    diprad    = -diprad;
    dip       = -dip;
  end    
  z0        = zt+W.*sin(diprad);
  xs        = mean([xt,x0]);
  ys        = mean([yt,y0]);
  zs        = mean([zt,z0]);
  
  dL    = L/Lp;
  dW    = W/Wp;
  dx    = (xt-x0)/Wp;
  dy    = (yt-y0)/Wp;

  for i=1:Wp
    
    xtc = xt-dx*(i-1);
    x0c = xt-dx*(i);
    ytc = yt-dy*(i-1);
    y0c = yt-dy*(i);
    z0p = z0-dW*(Wp-i).*sin(diprad);
    ztp = z0-dW*(Wp-i+1).*sin(diprad);
    zsp = mean([z0p,ztp]);
    
    for j=1:Lp
      
      id     = (i-1)*totLp+sum(Lps(1:k-1))+Lp-j+1;
      
      lsina  = (L/2-dL*(j-1)).*sin(strikerad);
      lsinb  = (L/2-dL*j).*sin(strikerad);
      lcosa  = (L/2-dL*(j-1)).*cos(strikerad);
      lcosb  = (L/2-dL*j).*cos(strikerad);
      lsin   = (L/2-dL*(j-.5)).*sin(strikerad);
      lcos   = (L/2-dL*(j-.5)).*cos(strikerad);
      
      xfault = [xtc+lsina, xtc+lsinb, x0c+lsinb, x0c+lsina, xtc+lsina]';
      yfault = [ytc+lcosa, ytc+lcosb, y0c+lcosb, y0c+lcosa, ytc+lcosa]';
      zfault = [ztp ztp z0p z0p ztp]';

      x0p    = x0c+lsin;
      y0p    = y0c+lcos;
      
      patchstruct(id).x0     = x0p;
      patchstruct(id).y0     = y0p;
      patchstruct(id).z0     = z0p;
      patchstruct(id).strike = strike;
      patchstruct(id).dip    = dip;
      patchstruct(id).L      = dL;
      patchstruct(id).W      = dW;
      patchstruct(id).xfault = xfault;
      patchstruct(id).yfault = yfault;
      patchstruct(id).zfault = zfault;
%      patchstruct(id).breakno= breakno(k);
      patchstruct(id).edgetype=0;
    end
  end
end

patchstruct(1).zone=faultstruct(1).zone;