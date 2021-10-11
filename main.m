clear
clc

% parametri da inserire
num_modi_tot=11;     % numero forme modali restituite da patran
id_nodi=(1:561)';    % nodi dei quali si vuole la risposta spostamento


%______________________________________________________
% report estratti da patran
while true 
% load report/clumped_plate/modal_shape_dis.rpt
% load report/clumped_plate/modal_shape_strain.rpt
% load report/clumped_plate/strain_tot.rpt
% load report/clumped_plate/omega.mat

load report/clumped_plate_randomloads/modal_shape_dis_randomloads.rpt
load report/clumped_plate_randomloads/modal_shape_strain_randomloads.rpt
load report/clumped_plate_randomloads/strain_tot_randomloads.rpt
load report/clumped_plate_randomloads/omega_randloads.mat
modal_shape_dis=modal_shape_dis_randomloads;
modal_shape_strain=modal_shape_strain_randomloads;
omega=omega_randloads;
strain=strain_tot_randomloads;

% load report/semiala/modal_shape_dis_semiala.rpt
% load report/semiala/modal_shape_strain_dorsosemiala.rpt
% load report/semiala/strain_dorsosemiala.rpt
% load report/semiala/omega_semiala.mat
% modal_shape_dis=modal_shape_dis_semiala;
% modal_shape_strain=modal_shape_strain_dorsosemiala;
% omega=omega_semiala;
% strain=strain_dorsosemiala;
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
%_______________________________________________________


% indici delle defeformazioni misurate e dei nodi per spostamento
index=sort( uint64( [strain(:,1).*3-2; strain(:,1).*3-1; strain(:,1).*3] ) );
index_dis=sort( uint64( [id_nodi.*3-2; id_nodi.*3-1; id_nodi.*3] ) );


%_______________________________________________________
% criterio di selezione modale
% determinazione modi più significativi
[modi,E_modi,E_rappr] = scelta_modi(ms_str(index,:),def,omega);
%_______________________________________________________


% calcolo spostamenti
% w = phi_d * INV( phi_s^T * phi_s ) * phi_s^T   *   eps
pseudo_inversa = ms_dis(index_dis,modi) / ...
                ( ms_str(index,modi)' * ms_str(index,modi) ) * ...
                 ms_str(index,modi)' ;
w = pseudo_inversa * def;


