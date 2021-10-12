clear
close all
clc

% parameters to set
%__________________________________________________________________________
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
break
end
n_measurements=8;
requested_precision=5;       % error of sol, calculated by fitness function
max_iter=300;                % maximum number of generation
%__________________________________________________________________________

tic
gen = Genetic_forDeformation(modal_shape_dis_semialabeam,...
                             modal_shape_strain_dorsosemialabeam,...
                             omega_semialabeam,...
                             strain_dorsosemialabeam,...
                             displ_tot_semialabeam,...
                             n_measurements);
% gen = Genetic_forDeformation(modal_shape_dis_randomloads,...
%                              modal_shape_strain_randomloads,...
%                              omega_randloads,...
%                              strain_tot_randomloads,...
%                              displ_tot_randomloads,...
%                              n_measurements);
                       
accuracy = 100;
iter=0;

while iter < max_iter && accuracy > requested_precision
             
    gen.fitness_function;
    gen.best_sol;
    gen.crossover;
    gen.mutation;
    
    iter=iter+1;
    accuracy=min(gen.error);
    
    if iter >= max_iter || accuracy <= requested_precision
        sol=gen.solution(:,gen.error==min(gen.error));
        strain_gauges=ceil(find(sol(:,1)==1)/3);
    end
    
    plot(iter,accuracy,'bo');
    hold on
    plot([0 iter],[requested_precision requested_precision]);
    grid on
    pause(0.001)
end
toc

disp(['exit at generation number: ',num2str(iter)])
disp(['with an error of: ',num2str(accuracy),' %'])