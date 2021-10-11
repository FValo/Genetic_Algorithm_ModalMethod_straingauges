function [matrix] = modal_shape_matrix(modal_shape,mod_number)
% costruzione matrice forme modali
%_________________________________________________________________________
% mod_shape: report estratto da patran

% mod_number: numero forme modali richieste a nastran e presenti nel report

% num_variabili: numero variabili di cui chiediamo i dati, corrisponde al
% numero di nodi di cui si è richiesto lo spostamento oppure al numero di
% centroidi di elementi di cui si sono richieste le deformazioni

% gdl: numero dei gradi di libertà di ogni variabile, quante componenti di
% spostamento o quante componenti di deformazione
%_________________________________________________________________________

dis=modal_shape';
dis(1,:)=[];

num_variabili=size(modal_shape,1)/mod_number;
gdl=size(modal_shape,2)-1;
% numero componenti totali = num_variabili * gdl

matrix=zeros(num_variabili*gdl,mod_number);   % inizializzazione

m=1;
for i=1:mod_number
    n=1;
    
    for j=1:num_variabili
        
        matrix(n:n+gdl-1,i)=dis(:,j+m-1);
        n=n+gdl;
        
    end
    
    m=m+num_variabili;
end

end

