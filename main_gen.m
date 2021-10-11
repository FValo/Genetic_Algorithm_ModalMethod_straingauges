clear
clc


load report/clumped_plate_randomloads/modal_shape_dis_randomloads.rpt
load report/clumped_plate_randomloads/modal_shape_strain_randomloads.rpt
load report/clumped_plate_randomloads/strain_tot_randomloads.rpt
load report/clumped_plate_randomloads/omega_randloads.mat
load report/clumped_plate_randomloads/displ_tot_randomloads.rpt

n_measurements=20;

gen = Genetic_forDeformation(modal_shape_dis_randomloads,...
                             modal_shape_strain_randomloads,...
                             omega_randloads,...
                             strain_tot_randomloads,...
                             displ_tot_randomloads,...
                             n_measurements);
 
                         
accuracy = 100;
iter=1;

while iter < 100 && accuracy > 5
             
    gen.fitness_function;
    gen.best_sol;
    gen.crossover;
    gen.mutation;
    
    iter=iter+1;
    accuracy=min(gen.error);
    
    sol=gen.solution(:,gen.error==min(gen.error));
end
