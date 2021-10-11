clear
clc


load report/clumped_plate_randomloads/modal_shape_dis_randomloads.rpt
load report/clumped_plate_randomloads/modal_shape_strain_randomloads.rpt
load report/clumped_plate_randomloads/strain_tot_randomloads.rpt
load report/clumped_plate_randomloads/omega_randloads.mat
load report/clumped_plate_randomloads/displ_tot_randomloads.rpt

n_measurements=50;

gen = Genetic_forDeformation(modal_shape_dis_randomloads,...
                             modal_shape_strain_randomloads,...
                             omega_randloads,...
                             strain_tot_randomloads,...
                             displ_tot_randomloads,...
                             n_measurements);
%%


i=0;
while true
    % function
    % genetic rappresentation
    
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