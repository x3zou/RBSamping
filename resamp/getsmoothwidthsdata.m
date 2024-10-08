function [smoothwidths] = getsmoothwidthsdata(N,datastruct,plotflag);
clear b x2 y2
global b x2 y2

options  = optimset('Display','off');

np       = length(datastruct);
alli     = np;

%s=0; 
%h=waitbar(s,'','name','calculating smoothing');
for i=1:alli
  %tic

  x1    = datastruct(i).x;
  y1    = datastruct(i).y;
  scale = datastruct(i).scale;
  
  dists = sqrt(([datastruct.x]-x1).^2+([datastruct.y]-y1).^2);
  b     = 0;
  x2    = [dists];
  y2    = N(i,1:np);
  id=find(y2>0);
  y2=y2(id);
  x2=x2(id);
%  id    = find(abs(y2-y2(i)/2)==min(abs(y2-y2(i)/2)));
%  [jnk,tmpid]=sort(x2,'ascend');
%  [out,resn,res]   = lsqnonlin('gausfun',[N(i,i) x2(id)],[],[],options);
  [out,resn,res]   = lsqnonlin('gausfun',[N(i,i) scale],[],[],options);

  if(plotflag(i))
    figure
    plot(x2,y2,'.')
    hold on
    %plot(x2(id),N(i,i),'r*')
    plot(scale*2,N(i,i),'rv')
    plot(out(2),out(1),'ko')
    plot(x2,res+y2,'g.')
    title(num2str(i))
  
 % if(0)
 %     figure
 %     plot(x2,y2,'.')
 %     hold on
 %     plot(x2(tmpid),res(tmpid)+y2(tmpid));
 % end
 % if(i==alli-30)
 %     plot(x2,y2,'r.')
 %     plot(x2(tmpid),res(tmpid)+y2(tmpid),'r')
 % end
  end
  smoothwidths(i)=abs(out(2));
  %update_time
end
%close(h)
