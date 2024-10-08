
A=covd2;
[n,jnk]=size(A);
for j = 1:n
    % s = real(A(j,j)) - A(1:j-1,j)' * A(1:j-1,j);
    %s = 0;
    ajj=sum(A(1:j-1,j).^2);
    %for k = 1:j-1
    %    akj = A(k,j);
    %    s = s + real(akj)*real(akj) + imag(akj)*imag(akj);
    %end
    A(j+1:n,j)=0;
    %for k = j+1:n
    %    A(k,j) = 0;
    %end
   % alls(j)=s;
%end
%for j=1:n
    %ajj = real(A(j,j)) - alls(j);
%difs(j)=A(j,j)-ajj;
%alljj(j)=ajj;
%alla(j)=A(j,j);
    if A(j,j)-ajj <= 0
     id=[1:j-1 j+1:n];
        A(j,id)=0;
        A(id,j)=0;
        ajj=0;
%        A(j,j) = ajj*2;
        p = j;
        disp('ack')
        %return
    end
    ajj = sqrt(A(j,j)-ajj);
 
    A(j+1:n,j)=0;
    A(j,j) = ajj;

    for k = j+1:n
        A(j,k)=(A(j,k)-sum(A(1:j-1,j).*A(1:j-1,k)))/ajj;
       
        %A(j,k)=(A(j,k)-t)/ajj;
    end
end