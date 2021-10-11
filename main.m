clear
clc

% parametri da inserire
num_modi_tot=11;     % numero forme modali restituite da patran
id_nodi=(1:561)';    % nodi dei quali si vuole la risposta spostamento


%______________________________________________________
% report estratti da patran
while true 

load report/clumped_plate_randomloads/modal_shape_dis_randomloads.rpt
load report/clumped_plate_randomloads/modal_shape_strain_randomloads.rpt
load report/clumped_plate_randomloads/strain_tot_randomloads.rpt
load report/clumped_plate_randomloads/omega_randloads.mat
load report/clumped_plate_randomloads/displ_tot_randomloads.rpt
modal_shape_dis=modal_shape_dis_randomloads;
modal_shape_strain=modal_shape_strain_randomloads;
omega=omega_randloads;
strain=strain_tot_randomloads;
displ=displ_tot_randomloads;
break
end
%______________________________________________________


[ms_dis] = modal_shape_matrix(  modal_shape_dis,    num_modi_tot );
[ms_str] = modal_shape_matrix( modal_shape_strain,  num_modi_tot );

%_______________________________________________________
%costruzione vettore colonna deformazioni
def=zeros(size(strain,1)*3,1);
n=1;
for i=1:size(strain,1)
    def(n:n+2)=strain(i,2:end);
    n=n+3;
end
%costruzione vettore colonna spostamenti
displ_value=zeros(size(displ,1)*3,1);
n=1;
for i=1:size(displ,1)
    displ_value(n:n+2)=displ(i,2:end);
    n=n+3;
end
%_______________________________________________________


% indici delle defeformazioni misurate e dei nodi per spostamento
index=sort( uint64( [strain(:,1).*3-2; strain(:,1).*3-1; strain(:,1).*3] ) );
index_dis=sort( uint64( [id_nodi.*3-2; id_nodi.*3-1; id_nodi.*3] ) );

index=[35:3:50, 351:3:357, 401:3:407, 451:3:457]';  %posizioni migliori per misura def

%_______________________________________________________
% criterio di selezione modale
% determinazione modi pi� significativi
[modi,E_modi,E_rappr] = scelta_modi(ms_str(index,:),def(index),omega);
%_______________________________________________________


% calcolo spostamenti
% w = phi_d * INV( phi_s^T * phi_s ) * phi_s^T   *   eps
pseudo_inversa = ms_dis(index_dis,modi) / ...
                ( ms_str(index,modi)' * ms_str(index,modi) ) * ...
                 ms_str(index,modi)' ;
w = pseudo_inversa * def(index);

err=100*sqrt(1/size(index,1) * sum( ( (w-displ_value)/max(abs(displ_value)) ).^2 ) );
