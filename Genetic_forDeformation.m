classdef Genetic_forDeformation < handle
    % Genetic algorithm for best choice of strain gauges position
    % helpful in Modal Method
    % Shape Sensing Thesis, FValo 2021
    
    properties (Access = public)
        strain_value;          % static deformation
        displ_value;           % static displacement
        ms_displ;              % displacement modal shapes
        ms_strain;             % strain modal shapes
        omega;                 % pulsations of modal shapes
        
        n_mesaurements;        % number of strain gauges
        solution;              % soluzioni
        
        accuracy;
    end
    
    methods
        
        % Inizialization
        %__________________________________________________________________
        function obj = Genetic_forDeformation(modal_shape_dis,modal_shape_strain,omega,strain,displ,n_mesaurements)
            
            % transform strain from matrix to column vector rappresentation
            obj.strain_value=zeros(size(strain,1)*3,1);
            n=1;
            for i=1:size(strain,1)
                obj.strain_value(n:n+2)=strain(i,2:end);
                n=n+3;
            end
            % transform displ from matrix to column vector rappresentation
            obj.displ_value=zeros(size(displ,1)*3,1);
            n=1;
            for i=1:size(displ,1)
                obj.displ_value(n:n+2)=displ(i,2:end);
                n=n+3;
            end
            
            num_modi_tot=length(omega);
            % create modal shape matrix [m x n], 
            % m: gdl, n: number of mode shape
            [obj.ms_displ] = modal_shape_matrix(  modal_shape_dis,    num_modi_tot );
            [obj.ms_strain] = modal_shape_matrix( modal_shape_strain,  num_modi_tot );
            
            obj.omega=omega;
            obj.n_mesaurements=n_mesaurements;
            
            % generate random parents
            n_parents=10;
            obj.solution=zeros(size(obj.strain_value, 1) , n_parents );
            for i=1:n_parents
                obj.solution(:,i)=random_solution(length(obj.strain_value),n_mesaurements);
            end
        end
        
        % fitness function
        %__________________________________________________________________
        function fitness_function(obj)
            
            obj.accuracy = zeros(size(obj.solution,2),1);
            
            for i=1:size(obj.solution,2)
                
                index= find( obj.solution(:,i) == 1 );
                [modi] = shape_choice(obj.ms_strain(index,:),obj.strain_value(index),obj.omega);
                
                pseudo_invers = obj.ms_displ(:,modi) / ...
                                ( obj.ms_strain(index,modi)' * obj.ms_strain(index,modi) ) * ...
                                 obj.ms_strain(index,modi)' ;
                w = pseudo_invers * obj.strain_value(index);   
                
                % fitness function: error for every configuration of strain
                % gauges respect to exact displacement from fem
                obj.accuracy(i)=100*sqrt(1/obj.n_mesaurements * ...
                    sum( ( (w-obj.displ_value)/max(abs(obj.displ_value)) ).^2 ) );
            end 
        end
        
        % choose best solution
        %__________________________________________________________________
        function best_sol(obj)
        end
    end
end

