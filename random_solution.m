function [sol] = random_solution(length_sol,n_mesaurements)

% sol is initialized as a series of random numbers from 1 to length_sol 
sol=randi(length_sol*100,length_sol,1,'uint32');

i=1;
while true
    ind= sol==max(sol) ;
    sol( ind )=1;            % maximum of sol is set egual to 1
    cont=sum(sol==1);                % count number of 1 in sol
    
    if cont >= n_mesaurements
        break
    end
    if i > n_mesaurements
        error('error in generating of new solution');
    end
    i=1+1;
end

sol(sol~=1)=0;                      % all parameters different to 1 is set egual to 0
end

