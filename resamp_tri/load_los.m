function datastruct = load_los(datastruct,losfilename,xzone,yzone,azo,const_los,nx1)

if(azo==1)
    % changed to use heading from input .rsc file EJF 2010/4/29
    heading  = load_rscs(losfilename,'HEADING')
    S        = zeros(datastruct.ny,datastruct.nx,3);
    S(:,:,1) = sind(heading);
    S(:,:,2) = cosd(heading);
    S(:,:,3) = 0;
else
    
    nx     = datastruct.nx;
    ny     = datastruct.ny;
    
    
    if(xzone)
        nx=xzone(2)-xzone(1)+1;
    else
        xzone=[1 nx];
    end
    if(yzone)
        ny=yzone(2)-yzone(1)+1;
    else
        yzone=[1 ny];
    end

    
    if const_los
        disp('check directions, here look=23, heading=170');
        const_look    = 23;
        const_heading = 170;
        look          = ones(ny,nx)*const_look;    % this needs to be set manually right now
        heading       = ones(ny,nx)*const_heading;
    else
        fid          = fopen(losfilename,'r','native');
        [temp,count] = fread(fid,[nx1*2,(yzone(1)-1)],'real*4');
        [temp,count] = fread(fid,[nx1*2,ny],'real*4');
        status       = fclose(fid);

        look    = temp(xzone(1):xzone(2),:);
        heading = temp([xzone(1):xzone(2)]+nx1,:);
        heading = flipud(heading');
        look    = flipud(look');
    end

    %squint  = 0.1;
    %heading = (heading-squint).*pi/180;
    heading = (180-heading).*pi/180;
    look    = look.*pi/180;

    id          = find(look==0);
    jd          = find(look~=0);
    heading(id) = mean(heading(jd));
    look(id)    = mean(look(jd));

    S1 = [sin(heading).*sin(look)];
    S2 = [cos(heading).*sin(look)];
    S3 = [ -cos(look)];

    badid   = find(S1(:)==0);
    S1(badid) = S1(1); % set to average in load_los
    S2(badid) = S2(1);
    S3(badid) = S2(1);

    S(:,:,1)  = S1;
    S(:,:,2)  = S2;
    S(:,:,3)  = S3;
    
end

datastruct.S=S;