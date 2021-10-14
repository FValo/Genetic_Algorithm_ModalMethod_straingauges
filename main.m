clear
clc

% parametri da inserire
id_nodi=(1:1534)';    % nodi dei quali si vuole la risposta spostamento


%______________________________________________________
% report estratti da patran
while true 

% load report/clumped_plate_randomloads/modal_shape_dis_randomloads.rpt
% load report/clumped_plate_randomloads/modal_shape_strain_randomloads.rpt
% load report/clumped_plate_randomloads/strain_tot_randomloads.rpt
% load report/clumped_plate_randomloads/omega_randloads.mat
% load report/clumped_plate_randomloads/displ_tot_randomloads.rpt

% load report/semiala/modal_shape_dis_semiala.rpt
% load report/semiala/modal_shape_strain_dorsosemiala.rpt
% load report/semiala/strain_dorsosemiala.rpt
% load report/semiala/omega_semiala.mat
% load report/semiala/displ_tot_semiala.rpt

load report/semiala_beam/modal_shape_dis_semialabeam.rpt
load report/semiala_beam/modal_shape_strain_dorsosemialabeam.rpt
load report/semiala_beam/strain_dorsosemialabeam.rpt
load report/semiala_beam/omega_semialabeam.mat
load report/semiala_beam/displ_tot_semialabeam.rpt

modal_shape_dis=modal_shape_dis_semialabeam;
modal_shape_strain=modal_shape_strain_dorsosemialabeam;
omega=omega_semialabeam;
strain=strain_dorsosemialabeam;
displ=displ_tot_semialabeam;
break
end
%______________________________________________________

num_modi_tot=length(omega);     % numero forme modali restituite da patran
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

% index=[43 121 227 307 406 486 1405]';  %posizioni migliori per misura def, clumped plate
index=[1 132 206 249 704 721 724 777 1006 1288]'; %semiala
%_______________________________________________________
% criterio di selezione modale
% determinazione modi più significativi
% [modi,E_modi,E_rappr] = scelta_modi(ms_str(index,:),def(index),omega);
[modi,E_modi,E_rappr] = scelta_modi(ms_str,def,omega);
%_______________________________________________________


% calcolo spostamenti
% w = phi_d * INV( phi_s^T * phi_s ) * phi_s^T   *   eps
pseudo_inversa = ms_dis(index_dis,modi) / ...
                ( ms_str(index,modi)' * ms_str(index,modi) ) * ...
                 ms_str(index,modi)' ;
w = pseudo_inversa * def(index);

err=100*sqrt(1/length(w) * sum( ( (w-displ_value)/max(abs(displ_value)) ).^2 ) );
