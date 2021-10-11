clear
clc


load report/clumped_plate_randomloads/modal_shape_dis_randomloads.rpt
load report/clumped_plate_randomloads/modal_shape_strain_randomloads.rpt
load report/clumped_plate_randomloads/strain_tot_randomloads.rpt
load report/clumped_plate_randomloads/omega_randloads.mat
modal_shape_dis=modal_shape_dis_randomloads;
modal_shape_strain=modal_shape_strain_randomloads;
omega=omega_randloads;
strain=strain_tot_randomloads;

%_______________________________________________________
%costruzione vettore colonna deformazioni
def=zeros(size(strain,1)*3,1);
n=1;
for i=1:size(strain,1)
    def(n:n+2)=strain(i,2:end);
    n=n+3;
end
%_______________________________________________________

%%

i=1;
while true
    % function
    % genetic rappresentation
    []=gen0_creation(n_measurements);
    % function
    % generate new solution

    % function
    % fitness function

    % function
    % selection of best solution

    % function
    % crossover

    % function
    % mutation

    if i==100
        break
    end
    if accuracy > 0.95
        break
    end
    i=i+1;
end