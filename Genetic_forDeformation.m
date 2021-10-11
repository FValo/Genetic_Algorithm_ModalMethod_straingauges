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
        children;              % test solution
        
        error;                 % error of every solution based on fitness
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
            n_parents=10;               %PARAMETER TO BE MADE VARIABLE 
            obj.solution=zeros(size(obj.strain_value, 1) , n_parents );
            for i=1:n_parents
                obj.solution(:,i)=random_solution(length(obj.strain_value),n_mesaurements);
            end
        end
        
        % fitness function
        %__________________________________________________________________
        function fitness_function(obj)
            
            obj.error = zeros(size(obj.solution,2),1);
            
            for i=1:size(obj.solution,2)              % size(obj.solution,2) = n_parents
                
                index= find( obj.solution(:,i) == 1 );
%                 [modi] = shape_choice(obj.ms_strain(index,:),obj.strain_value(index),obj.omega);
                modi=[1 2 3 4 5 11];

                pseudo_invers = obj.ms_displ(:,modi) / ...
                                ( obj.ms_strain(index,modi)' * obj.ms_strain(index,modi) ) * ...
                                 obj.ms_strain(index,modi)' ;
                w = pseudo_invers * obj.strain_value(index);   
                
                % fitness function: error for every configuration of strain
                % gauges respect to exact displacement from fem
                obj.error(i)=100*sqrt(1/obj.n_mesaurements * ...
                    sum( ( (w-obj.displ_value)/max(abs(obj.displ_value)) ).^2 ) );
            end 
        end
        
        % choose best solution
        %__________________________________________________________________
        function best_sol(obj)
            obj.children=zeros(size(obj.solution));
            
            err=obj.error;
            % three best parents ever            
            err(err==min(err))=3000;
            
            index=find(err==3000,3);
            if length(index) == 1
                err(err==min(err))=2000;
                index(2:3)=find(err==2000,2);
            elseif length(index) == 2
                err(err==min(err))=2000;
                index(3)=find(err==2000,1);
            end
            if length(index) == 2
                err(err==min(err))=1000;
                index(3)=find(err==1000,1);
            end
                                    
            obj.children(:, 1:3 ) = obj.solution(:,index);
        end
        
        % crossever function
        %__________________________________________________________________
        function crossover(obj)
            mid=ceil ( size(obj.children,1)/2 );
            
            obj.children(:,4)=[ obj.children(1:mid,1) ; obj.children(mid+1:end,2) ];
            obj.children(:,5)=[ obj.children(1:mid,2) ; obj.children(mid+1:end,1) ];
            obj.children(:,6)=[ obj.children(1:mid,1) ; obj.children(mid+1:end,3) ];
            obj.children(:,7)=[ obj.children(1:mid,3) ; obj.children(mid+1:end,1) ];
            obj.children(:,8)=[ obj.children(1:mid,3) ; obj.children(mid+1:end,2) ];
            obj.children(:,9)=[ obj.children(1:mid,2) ; obj.children(mid+1:end,3) ];
            obj.children(:,10)=[ obj.children(1:mid*2/3,1) ; ...
                obj.children(mid*2/3+1:mid*4/3,2); obj.children(mid*4/3+1:end,2) ];
        end
        
        % mutation function
        %__________________________________________________________________
        function mutation(obj)
            % change the children solutions so that each has a number of 1 egual to n_mesaurements
            
            for i=4:10
                
                diff = sum(obj.children(:,i)) - obj.n_mesaurements;
                
                if diff > 0
                    index=find(obj.children(:,i)==1);
                    rand_index=unique( index( randi(length(index),length(index),1,'uint32') ), 'stable' );
                    
                    obj.children( rand_index(1:diff) ,i) = 0;
                    
                elseif diff < 0
                    index=find(obj.children(:,i)==0);
                    rand_index=unique( index( randi(length(index),length(index),1,'uint32') ), 'stable' );
                    
                    obj.children( rand_index(1:abs(diff)) ,i) = 1;                  
                end
            end
            
            obj.solution=obj.children;
        end
        
    end
end

