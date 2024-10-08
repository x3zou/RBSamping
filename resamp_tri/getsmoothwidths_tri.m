function [smoothwidths,stats] = getsmoothwidths_tri(N,resampstruct,plotflag)
clear b x2 y2
global b x2 y2

options  = optimset('Display','off');

np       = length(resampstruct);

for i=1:np


  x1    = resampstruct(i).X;
  y1    = resampstruct(i).Y;
  
  dists = sqrt(([resampstruct.X]-x1).^2+([resampstruct.Y]-y1).^2);
  b     = 0;
  x2    = [dists];
  y2    = N(i,1:np);
  %id=find(y2>0);  %leaving in the zeros results in narrower spatial scales and better fits "by eye"
  %y2=y2(id);
  %x2=x2(id);
  minx=min(x2(x2>0))/2;
  maxx=max(dists)/2;
  
  %try to pick a good starting width
  xstart=abs(sum(x2.*y2)/sum(y2));
  if(xstart<minx)
          xstart=minx;
  elseif(xstart>.75*maxx)
          xstart=.75*maxx;
  end
  if(isnan(xstart))
    xmoothwidths(i)=1e4;
    
    stats(i,:)=[xstart NaN NaN];
  else
  %constrain peak to be less than 1, width > half minimum spacing, < half size of all data

  %debugging the 'double' error
  N(i,i) = double(N(i,i));
  
  xstart = double(xstart);
  minx = double(minx);
  maxx = double(maxx);

  new_N = N(i,i);
  new_N = double(new_N);
  %[out,resn,res]   = lsqnonlin('gausfun',[N(i,i) xstart],[0 minx],[1 maxx],options);
  [out,resn,res]   = lsqnonlin('gausfun',[new_N xstart],[0 minx],[1 maxx],options);
   
  if(plotflag(i))
    figure
    plot(x2,y2,'.')
    hold on
    plot(out(2),out(1),'ko')
    plot(xstart,N(i,i),'ro')
    plot(x2,res+y2,'g.')
    legend('data','output peak/width','input peak/width','fit')
    title(['point ' num2str(i) ', width ' num2str(out(2))])
  
  end

  smoothwidths(i)=out(2);
  stats(i,:)=[xstart out resn];
  end
  
end

