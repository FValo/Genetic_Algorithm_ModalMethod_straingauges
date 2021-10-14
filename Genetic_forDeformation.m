classdef Genetic_forDeformation < handle
    % Genetic algorithm for best choice of strain gauges position
    % helpful in Modal Method
    % Shape Sensing Thesis, FValo 2021
    
    properties (Access = public)
        strain_value;          % static deformation
        displ_value;           % static displacement
        ms_displ;              % displacement modal shapes
        ms_strain;             % strain modal shapes
        modi;                  % chosen modal shapes
        
        n_parents;             % number of individuals in each generation
        n_mesaurements;        % number of strain gauges
        solution;              % soluzioni
        children;              % test solution
        
        error;                 % error of every solution based on fitness
        displ_calculated;      % static displacement calculated
    end
    
    methods
        
        % Inizialization
        %__________________________________________________________________
        function obj = Genetic_forDeformation(modal_shape_dis,modal_shape_strain,omega,strain,displ,n_mesaurements,n_parents)
            
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
            
            % chose of best modal shapes
            [obj.modi] = shape_choice(obj.ms_strain,obj.strain_value,omega);

            obj.n_mesaurements=n_mesaurements;
            
            % generate random parents
            obj.n_parents=n_parents;
            
            obj.solution=zeros(size(obj.strain_value, 1) , obj.n_parents );
            for i=1:obj.n_parents
                obj.solution(:,i)=random_solution(length(obj.strain_value),n_mesaurements);
            end
            
            %inizializate error vector
            obj.error = zeros(size(obj.solution,2),1);
        end
        
        % fitness function
        %__________________________________________________________________
        function fitness_function(obj)
            min=100;
            
            for i=1:size(obj.solution,2)              % size(obj.solution,2) = n_parents
                
                index= find( obj.solution(:,i) == 1 );

                pseudo_invers = obj.ms_displ(:,obj.modi) / ...
                                ( obj.ms_strain(index,obj.modi)' * obj.ms_strain(index,obj.modi) ) * ...
                                 obj.ms_strain(index,obj.modi)' ;
                w = pseudo_invers * obj.strain_value(index);   
                
                % fitness function: error for every configuration of strain
                % gauges respect to exact displacement from fem
                obj.error(i)=100*sqrt( 1/length(w) * ...
                    sum( ( (w-obj.displ_value)/max(abs(obj.displ_value)) ).^2 ) );
                
                if obj.error(i) < min
                    min = obj.error(i);
                    obj.displ_calculated=w;   % save result
                end
            end
            
            
        end
        
        % choose best solution, % best parents ever
        %__________________________________________________________________
        function best_sol(obj)    
            obj.children=zeros(size(obj.solution));
            
            [~, ord]=sort(obj.error);
            
            % ranking of best parents from 1 to n_parents, first 5 are
            % retained for the next generation without crossover
            obj.solution(:, 1:end ) = obj.solution(:,ord);
            obj.children(:, 1:5 ) = obj.solution(:, 1:5 );
        end
        
        % crossever function
        %__________________________________________________________________
        function crossover(obj)
            mid=ceil ( size(obj.children,1)/2 );
            
            prob=ceil(1./(1:obj.n_parents)*100)+20;
            
            for i=6:obj.n_parents-1
                
                % pick two random indexs
                y = randsample(obj.n_parents,2,true,prob);    
                
                % avoid repetition
                if y(1) == y(2)
                    if y(1) ~= obj.n_parents
                        y(1) = obj.n_parents;
                    else
                        y(1) = obj.n_parents-1;
                    end
                end
                    
                obj.children(:,i)=[ obj.solution(1:mid,y(1)) ; obj.solution(mid+1:end,y(2)) ];
            end
            
            % last chils is completely new, randomly generate
            obj.children(:,end)=random_solution(length(obj.strain_value),obj.n_mesaurements);
            
        end
        
        % mutation function
        %__________________________________________________________________
        function mutation(obj)
            % change the children solutions so that each has a number of 1 egual to n_mesaurements
            
            for i=6:obj.n_parents-1
                
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

