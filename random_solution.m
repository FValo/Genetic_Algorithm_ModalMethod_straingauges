function [sol] = random_solution(length_sol,n_mesaurements)

sol=randi(length_sol*100,length_sol,1,'uint32');

i=1;
while true
    sol(sol==max(sol))=1;
    cont=sum(sol==1);
    
    if cont == n_mesaurements
        break
    end
    if i > n_mesaurements
        error('error in generating of new solution');
    end
    i=1+1;
end

sol(sol~=1)=0;
end

