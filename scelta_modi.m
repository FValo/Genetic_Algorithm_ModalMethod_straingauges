function [num_modi_usare,E_modi,E_rappr] = scelta_modi(ms_str,def,omega)
% criterio di selezione dei modi
%_______________________________________________________
% ms_str: matrice delle forme modali in termini di deformazioni
% def: vettore colonna contenente le deformazioni misurate
% omega: pulsazioni dei modi
%_______________________________________________________

q=(ms_str'*ms_str) \ ms_str' * def;

Ei=1/2*omega.^2.*q.^2;
E_tot=sum(Ei);
E_modi=Ei;

num_modi=zeros(size(Ei,1)+1,1);
E_accumulata=0;
i=1;

while true
    massimo=max(Ei);
    num_modi(i)=find(Ei==massimo);
    
    E_accumulata=E_accumulata+massimo;
    Ei(num_modi(i))=0;
    
    if E_accumulata/E_tot>0.96
        break
    else
        i=i+1;
    end      
end

% forzare inserimento ultimo modo
num_modi(end)=size(Ei,1);
num_modi_usare=unique(num_modi);

if num_modi_usare(1)==0
    num_modi_usare(1)=[];
end

E_rappr=E_accumulata/E_tot*100;

end

