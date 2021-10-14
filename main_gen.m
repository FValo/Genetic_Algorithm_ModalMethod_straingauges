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
n_measurements=10;              % number of strain gauges available
requested_precision=0.01;       % error of sol, calculated by fitness function
max_iter=300;                   % maximum number of generation
n_parents=10;                   % number of solution for each generation
%__________________________________________________________________________

tic
gen = Genetic_forDeformation(modal_shape_dis_semialabeam,...
                             modal_shape_strain_dorsosemialabeam,...
                             omega_semialabeam,...
                             strain_dorsosemialabeam,...
                             displ_tot_semialabeam,...
                             n_measurements,...
                             n_parents);
% gen = Genetic_forDeformation(modal_shape_dis_randomloads,...
%                              modal_shape_strain_randomloads,...
%                              omega_randloads,...
%                              strain_tot_randomloads,...
%                              displ_tot_randomloads,...
%                              n_measurements,...
%                              n_parents);
                       
accuracy = 100;
iter=0;

while true % iter < max_iter && accuracy > requested_precision
             
    gen.fitness_function;
    
    accuracy=min(gen.error);
    
    if iter >= max_iter || accuracy <= requested_precision
        sol=gen.solution(:,gen.error==min(gen.error));
        strain_gauges=ceil(find(sol(:,1)==1)/3);
        break
    end
    
    gen.best_sol;
    gen.crossover;
    gen.mutation;
    iter=iter+1;
    
    plot(iter,accuracy,'bo');
    hold on
    grid on
    plot([0 iter],[requested_precision requested_precision]);
    pause(0.001)
end

plot(iter,accuracy,'bo');


if iter == max_iter
    disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
    toc; disp(' ');
    disp(['Exit for reaching maximum generation: ',num2str(iter)]);
    disp(['with an error of: ',num2str(accuracy),' %'])
    disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
else
    disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
    toc; disp(' ');
    disp(['Exit for reaching required accuracy, error: ',num2str(accuracy),' %']);
    disp(['Generation: ',num2str(iter)]);
    disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
end