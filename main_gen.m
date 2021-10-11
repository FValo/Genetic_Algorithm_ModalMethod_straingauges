clear
close all
clc

% parameters to set
%__________________________________________________________________________
load report/clumped_plate_randomloads/modal_shape_dis_randomloads.rpt
load report/clumped_plate_randomloads/modal_shape_strain_randomloads.rpt
load report/clumped_plate_randomloads/strain_tot_randomloads.rpt
load report/clumped_plate_randomloads/omega_randloads.mat
load report/clumped_plate_randomloads/displ_tot_randomloads.rpt

n_measurements=40;
requested_precision=3;       % error of sol, calculated by fitness function
max_iter=100;
%__________________________________________________________________________

tic
gen = Genetic_forDeformation(modal_shape_dis_randomloads,...
                             modal_shape_strain_randomloads,...
                             omega_randloads,...
                             strain_tot_randomloads,...
                             displ_tot_randomloads,...
                             n_measurements);
 
                         
accuracy = 100;
iter=0;

while iter < max_iter && accuracy > requested_precision
             
    gen.fitness_function;
    gen.best_sol;
    gen.crossover;
    gen.mutation;
    
    iter=iter+1;
    accuracy=min(gen.error);
    
    sol=gen.solution(:,gen.error==min(gen.error));
    
    pause(0.01)
    plot(iter,accuracy,'o--');
    hold on
    grid on
end
toc

disp(iter)
strain_gauges=ceil(find(sol==1)/3);