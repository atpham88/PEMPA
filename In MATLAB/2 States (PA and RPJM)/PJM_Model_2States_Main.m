% PJM Electricity Model for 5 nodes for year 2022 to 2030
% With Capacity Expansion
% With Existence of RPS extended until 2030
% Finished coding on 11/26/2019 by An Pham.

%**********************************************
%% Switches:
%**********************************************
trans_const = 1;          % Whether or not there's existence of transmission constraint (==1:yes, ==0:no)
rps_const = 1;            % Whether or not there's existence of RPS (==1:yes, ==0:no) 
policy_sc_all = [1;2;3];  % ==1: MB No Policy, ==2:MB No Trade, ==3: MB With Trade 
cap_exp = 1;              % Whether or not there's capacity expansion (==1:yes, ==0:no)
ext_rec_sc = 2;           % External RECs (==1: constant, ==2: growing)

%**********************************************
%% Define Parameters and variables:
%**********************************************
hours = [2 4 6 9 8 17 26 35	21 43 65 87	64 130 194 260 64 130 194 260 54 108 162 216 2 4 6 9 8 18 26 36	21 44 65 88	65 131 197 262 65 131 197 263 54 109 164 219 2 4 7 9 8 18 26 36	22 44 66 89	66 132 199 265 66 132 199 266 55 110 166 221 2 4 7 9 8 18 26 36	22 44 66 89	66 132 199 266 66 132 199 265 55 110 166 222]';
start_year = 2022;
end_year = 2030;
demand_run = 3;           % ==1: Run only the perfectly inelastic case, ==2: Run both cases (perflectly inelastic and etaD = 0.05)  

model_year = start_year:end_year;
supply_run = length(model_year);

% Number of nodes, lines,load segment and elasticity of demand:
I = 5;                    % Number of nodes    
J = 901;                  % Number of aggregated units
T = 96;                   % Number of load segments
F = 10;                   % Number of aggregated transmission lines
J_r = 262;                % Number of plants eligible to provide RECs to PJM states.
S = 14;                   % Number of PJM states. 

%**********************************************
%% Main Loops:
%**********************************************
sr = 1;
while sr <= supply_run
    % 2022
    if sr==1        
        % Supply data input:
        supply_curve = 'C:/Users/atpha/Documents/Research/PJM Model/Input Data/Supply Data/Supply_Curve_96_final_2022.xlsx';
        supply_data = xlsread(supply_curve,'bin 1');
        rps_data = xlsread(supply_curve,'rps');
        
        % Demand data input:
        load_growth = 0.017083;        
        dr = 1;
        while dr <= demand_run
            if dr == 1
                policy_sc = policy_sc_all(1);            
                demand_curve = 'C:/Users/atpha/Documents/Research/PJM Model/Input Data/Demand Data/Demand Curves_96_2018.xlsx';
                load_data_region_1_temp = xlsread(demand_curve,'region 1');
                load_data_region_2_temp = xlsread(demand_curve,'region 2');
                load_data_region_3_temp = xlsread(demand_curve,'region 3');
                load_data_region_4_temp = xlsread(demand_curve,'region 4');
                load_data_region_5_temp = xlsread(demand_curve,'region 5');
                
                load_region_1 = load_data_region_1_temp(:,4)*(1+load_growth);
                load_region_2 = load_data_region_2_temp(:,4)*(1+load_growth);
                load_region_3 = load_data_region_3_temp(:,4)*(1+load_growth);
                load_region_4 = load_data_region_4_temp(:,4)*(1+load_growth);
                load_region_5 = load_data_region_5_temp(:,4)*(1+load_growth);
                
                p_region_1 = load_data_region_1_temp(:,3);
                p_region_2 = load_data_region_2_temp(:,3);
                p_region_3 = load_data_region_3_temp(:,3);
                p_region_4 = load_data_region_4_temp(:,3);
                p_region_5 = load_data_region_5_temp(:,3);   
                load_region_all_1 = [load_region_1,load_region_2,load_region_3,load_region_4,load_region_5];         
                p_region_all_1 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
            elseif dr == 2       
                load_region_1 = d_star_2022(1,:)'.*hours;
                load_region_2 = d_star_2022(2,:)'.*hours;
                load_region_3 = d_star_2022(3,:)'.*hours;
                load_region_4 = d_star_2022(4,:)'.*hours;
                load_region_5 = d_star_2022(5,:)'.*hours;  
                
                p_region_1 = p_star_2022(1,:)';
                p_region_2 = p_star_2022(2,:)';
                p_region_3 = p_star_2022(3,:)';
                p_region_4 = p_star_2022(4,:)';
                p_region_5 = p_star_2022(5,:)';  
                load_region_all_2 = [load_region_1,load_region_2,load_region_3,load_region_4,load_region_5];         
                p_region_all_2 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
            elseif dr == 3
                load_region_all_3 = load_region_all_2;
                p_region_1 = p_star_1(1,:)';
                p_region_2 = p_star_1(2,:)';
                p_region_3 = p_star_1(3,:)';
                p_region_4 = p_star_1(4,:)';
                p_region_5 = p_star_1(5,:)';  
                p_region_all_3 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
            end
                        
            if dr == 1
                load_region_all = load_region_all_1;
                p_region_all = p_region_all_1;
                [supply_data_new_2022_1,new_gr_all_temp_2022_1,p_star_2022,d_star_2022] = PJM_Electricity_Model_MB_2022(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,rps_data,hours); 
            elseif dr==2
                load_region_all = load_region_all_2;
                p_region_all = p_region_all_2; 
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);
                    if i==1
                        [supply_data_new_2022_2_1,new_gr_all_temp_2022_2_1,p_star_1,d_star_1] = PJM_Electricity_Model_MB_2022(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,rps_data,hours);
                        J_2022_1 = length(supply_data_new_2022_2_1);
                    elseif i==2
                        [supply_data_new_2022_2_2,new_gr_all_temp_2022_2_2,p_star_2,d_star_2] = PJM_Electricity_Model_MB_2022(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,rps_data,hours);
                        J_2022_2 = length(supply_data_new_2022_2_2);
                    elseif i==3
                        [supply_data_new_2022_2_3,new_gr_all_temp_2022_2_3,p_star_3,d_star_3] = PJM_Electricity_Model_MB_2022(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,rps_data,hours);
                        J_2022_3 = length(supply_data_new_2022_2_3);
                    end                                                        
                end
            elseif dr==3
                load_region_all = load_region_all_3;
                p_region_all = p_region_all_3; 
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);
                    if i==1
                        [supply_data_new_2022_3_1,new_gr_all_temp_2022_3_1,p_star_1,d_star_1] = PJM_Electricity_Model_MB_2022(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,rps_data,hours);
                        J_2022_1 = length(supply_data_new_2022_3_1);
                    elseif i==2
                        [supply_data_new_2022_3_2,new_gr_all_temp_2022_3_2,p_star_2,d_star_2] = PJM_Electricity_Model_MB_2022(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,rps_data,hours);
                        J_2022_2 = length(supply_data_new_2022_3_2);
                    elseif i==3
                        [supply_data_new_2022_3_3,new_gr_all_temp_2022_3_3,p_star_3,d_star_3] = PJM_Electricity_Model_MB_2022(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,rps_data,hours);
                        J_2022_3 = length(supply_data_new_2022_3_3);
                    end                    
                                     
                end

            end            
                                
            dr = dr+1;            
        end
    % 2023    
    elseif sr==2        
        % Supply data input:
        clear supply_data
        clear p_region_all
        clear load_region_all
        clear gas_gr_temp               
                        
        % Demand data input:
        load_growth = 0.0214;        
        dr = 1;
        while dr <= demand_run
            if dr == 1
                supply_data = supply_data_new_2022_3_1;
                gas_gr_temp = new_gr_all_temp_2022_3_1;
                J = J_2022_1;
                
                demand_curve = 'C:/Users/atpha/Documents/Research/PJM Model/Input Data/Demand Data/Demand Curves_96_2018.xlsx';
                load_data_region_1_temp = xlsread(demand_curve,'region 1');
                load_data_region_2_temp = xlsread(demand_curve,'region 2');
                load_data_region_3_temp = xlsread(demand_curve,'region 3');
                load_data_region_4_temp = xlsread(demand_curve,'region 4');
                load_data_region_5_temp = xlsread(demand_curve,'region 5');
                
                load_region_1 = load_data_region_1_temp(:,4)*(1+load_growth);
                load_region_2 = load_data_region_2_temp(:,4)*(1+load_growth);
                load_region_3 = load_data_region_3_temp(:,4)*(1+load_growth);
                load_region_4 = load_data_region_4_temp(:,4)*(1+load_growth);
                load_region_5 = load_data_region_5_temp(:,4)*(1+load_growth);
                
                p_region_1 = p_region_all_3(:,1);
                p_region_2 = p_region_all_3(:,2);
                p_region_3 = p_region_all_3(:,3);
                p_region_4 = p_region_all_3(:,4);
                p_region_5 = p_region_all_3(:,5);   
                clear p_region_all_3 
                load_region_all_1 = [load_region_1,load_region_2,load_region_3,load_region_4,load_region_5];         
                p_region_all_1 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
            elseif dr == 2      
                load_region_1 = d_star_2023(1,:)'.*hours;
                load_region_2 = d_star_2023(2,:)'.*hours;
                load_region_3 = d_star_2023(3,:)'.*hours;
                load_region_4 = d_star_2023(4,:)'.*hours;
                load_region_5 = d_star_2023(5,:)'.*hours;                 
                
                p_region_1 = p_star_2023(1,:)';
                p_region_2 = p_star_2023(2,:)';
                p_region_3 = p_star_2023(3,:)';
                p_region_4 = p_star_2023(4,:)';
                p_region_5 = p_star_2023(5,:)';   
                load_region_all_2 = [load_region_1,load_region_2,load_region_3,load_region_4,load_region_5];         
                p_region_all_2 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
            elseif dr == 3
                load_region_all_3 = load_region_all_2;
                p_region_1 = p_star_1(1,:)';
                p_region_2 = p_star_1(2,:)';
                p_region_3 = p_star_1(3,:)';
                p_region_4 = p_star_1(4,:)';
                p_region_5 = p_star_1(5,:)';  
                p_region_all_3 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
            end
            
            if dr == 1
                load_region_all = load_region_all_1;
                p_region_all = p_region_all_1;
                [supply_data_new_2023_1,new_gr_all_temp_2023_1,p_star_2023,d_star_2023] = PJM_Electricity_Model_MB_2023(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
            elseif dr==2
                load_region_all = load_region_all_2;
                p_region_all = p_region_all_2; 
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);                                       
                    if i==1
                        J = J_2022_1;
                        supply_data = supply_data_new_2022_3_1;
                        gas_gr_temp = new_gr_all_temp_2022_3_1; 
                        [supply_data_new_2023_2_1,new_gr_all_temp_2023_2_1,p_star_1,d_star_1] = PJM_Electricity_Model_MB_2023(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
                        J_2023_1 = length(supply_data_new_2023_2_1);
                    elseif i==2
                        J = J_2022_2;
                        supply_data = supply_data_new_2022_3_2;
                        gas_gr_temp = new_gr_all_temp_2022_3_2; 
                        [supply_data_new_2023_2_2,new_gr_all_temp_2023_2_2,p_star_2,d_star_2] = PJM_Electricity_Model_MB_2023(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2023_2 = length(supply_data_new_2023_2_2);
                    elseif i==3
                        J = J_2022_3;
                        supply_data = supply_data_new_2022_3_3;
                        gas_gr_temp = new_gr_all_temp_2022_3_3; 
                        [supply_data_new_2023_2_3,new_gr_all_temp_2023_2_3,p_star_2,d_star_3] = PJM_Electricity_Model_MB_2023(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2023_3 = length(supply_data_new_2023_2_3);
                    end                                                                                                   
                end
            elseif dr==3
                load_region_all = load_region_all_3;
                p_region_all = p_region_all_3; 
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);                                       
                    if i==1
                        J = J_2022_1;
                        supply_data = supply_data_new_2022_3_1;
                        gas_gr_temp = new_gr_all_temp_2022_3_1; 
                        [supply_data_new_2023_3_1,new_gr_all_temp_2023_3_1,p_star_1,d_star_1] = PJM_Electricity_Model_MB_2023(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
                        J_2023_1 = length(supply_data_new_2023_3_1);
                    elseif i==2
                        J = J_2022_2;
                        supply_data = supply_data_new_2022_3_2;
                        gas_gr_temp = new_gr_all_temp_2022_3_2; 
                        [supply_data_new_2023_3_2,new_gr_all_temp_2023_3_2,p_star_2,d_star_2] = PJM_Electricity_Model_MB_2023(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2023_2 = length(supply_data_new_2023_3_2);
                    elseif i==3
                        J = J_2022_3;
                        supply_data = supply_data_new_2022_3_3;
                        gas_gr_temp = new_gr_all_temp_2022_3_3; 
                        [supply_data_new_2023_3_3,new_gr_all_temp_2023_3_3,p_star_2,d_star_3] = PJM_Electricity_Model_MB_2023(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2023_3 = length(supply_data_new_2023_3_3);
                    end                                                                                                   
                end
            end 
               
            
            dr = dr+1;            
        end
    % 2024    
    elseif sr==3
        % Supply data input:
        clear supply_data
        clear p_region_all
        clear load_region_all
        clear gas_gr_temp
        
         % Demand data input:
        load_growth = 0.025733;        
        dr = 1;
        while dr <= demand_run
            if dr == 1
                supply_data = supply_data_new_2023_3_1;
                gas_gr_temp = new_gr_all_temp_2023_3_1;
                J = J_2023_1;
                
                demand_curve = 'C:/Users/atpha/Documents/Research/PJM Model/Input Data/Demand Data/Demand Curves_96_2018.xlsx';
                load_data_region_1_temp = xlsread(demand_curve,'region 1');
                load_data_region_2_temp = xlsread(demand_curve,'region 2');
                load_data_region_3_temp = xlsread(demand_curve,'region 3');
                load_data_region_4_temp = xlsread(demand_curve,'region 4');
                load_data_region_5_temp = xlsread(demand_curve,'region 5');
                
                load_region_1 = load_data_region_1_temp(:,4)*(1+load_growth);
                load_region_2 = load_data_region_2_temp(:,4)*(1+load_growth);
                load_region_3 = load_data_region_3_temp(:,4)*(1+load_growth);
                load_region_4 = load_data_region_4_temp(:,4)*(1+load_growth);
                load_region_5 = load_data_region_5_temp(:,4)*(1+load_growth);
                
                p_region_1 = load_data_region_1_temp(:,3);
                p_region_2 = load_data_region_2_temp(:,3);
                p_region_3 = load_data_region_3_temp(:,3);
                p_region_4 = load_data_region_4_temp(:,3);
                p_region_5 = load_data_region_5_temp(:,3);  
                load_region_all_1 = [load_region_1,load_region_2,load_region_3,load_region_4,load_region_5];         
                p_region_all_1 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
            elseif dr == 2      
                cap_exp = 1; 
                load_region_1 = d_star_2024(1,:)'.*hours;
                load_region_2 = d_star_2024(2,:)'.*hours;
                load_region_3 = d_star_2024(3,:)'.*hours;
                load_region_4 = d_star_2024(4,:)'.*hours;
                load_region_5 = d_star_2024(5,:)'.*hours;
                
                p_region_1 = p_star_2024(1,:)';
                p_region_2 = p_star_2024(2,:)';
                p_region_3 = p_star_2024(3,:)';
                p_region_4 = p_star_2024(4,:)';
                p_region_5 = p_star_2024(5,:)';
                load_region_all_2 = [load_region_1,load_region_2,load_region_3,load_region_4,load_region_5];         
                p_region_all_2 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
            elseif dr == 3
                load_region_all_3 = load_region_all_2;
                p_region_1 = p_star_1(1,:)';
                p_region_2 = p_star_1(2,:)';
                p_region_3 = p_star_1(3,:)';
                p_region_4 = p_star_1(4,:)';
                p_region_5 = p_star_1(5,:)';  
                p_region_all_3 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
            end
            
            if dr == 1
                load_region_all = load_region_all_1;
                p_region_all = p_region_all_1;
                [supply_data_new_2024_1,new_gr_all_temp_2024_1,p_star_2024,d_star_2024] = PJM_Electricity_Model_MB_2024(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
            elseif dr==2
                load_region_all = load_region_all_2;
                p_region_all = p_region_all_2; 
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);                                       
                    if i==1
                        J = J_2023_1;
                        supply_data = supply_data_new_2023_3_1;
                        gas_gr_temp = new_gr_all_temp_2023_3_1; 
                        [supply_data_new_2024_2_1,new_gr_all_temp_2024_2_1,p_star_1,d_star_1] = PJM_Electricity_Model_MB_2024(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
                        J_2024_1 = length(supply_data_new_2024_2_1);
                    elseif i==2
                        J = J_2023_2;
                        supply_data = supply_data_new_2023_3_2;
                        gas_gr_temp = new_gr_all_temp_2023_3_2; 
                        [supply_data_new_2024_2_2,new_gr_all_temp_2024_2_2,p_star_2,d_star_2] = PJM_Electricity_Model_MB_2024(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2024_2 = length(supply_data_new_2024_2_2);
                    elseif i==3
                        J = J_2023_3;
                        supply_data = supply_data_new_2023_3_3;
                        gas_gr_temp = new_gr_all_temp_2023_3_3; 
                        [supply_data_new_2024_2_3,new_gr_all_temp_2024_2_3,p_star_2,d_star_3] = PJM_Electricity_Model_MB_2024(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2024_3 = length(supply_data_new_2024_2_3);
                    end                                                                                                   
                end
            elseif dr==3
                load_region_all = load_region_all_3;
                p_region_all = p_region_all_3; 
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);                                       
                    if i==1
                        J = J_2023_1;
                        supply_data = supply_data_new_2023_3_1;
                        gas_gr_temp = new_gr_all_temp_2023_3_1; 
                        [supply_data_new_2024_3_1,new_gr_all_temp_2024_3_1,p_star_1,d_star_1] = PJM_Electricity_Model_MB_2024(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
                        J_2024_1 = length(supply_data_new_2024_3_1);
                    elseif i==2
                        J = J_2023_2;
                        supply_data = supply_data_new_2023_3_2;
                        gas_gr_temp = new_gr_all_temp_2023_3_2; 
                        [supply_data_new_2024_3_2,new_gr_all_temp_2024_3_2,p_star_2,d_star_2] = PJM_Electricity_Model_MB_2024(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2024_2 = length(supply_data_new_2024_3_2);
                    elseif i==3
                        J = J_2023_3;
                        supply_data = supply_data_new_2023_3_3;
                        gas_gr_temp = new_gr_all_temp_2023_3_3; 
                        [supply_data_new_2024_3_3,new_gr_all_temp_2024_3_3,p_star_2,d_star_3] = PJM_Electricity_Model_MB_2024(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2024_3 = length(supply_data_new_2024_3_3);
                    end                                                                                                   
                end
            end 

            dr = dr+1;            
        end
    % 2025             
    elseif sr==4
        % Supply data input:
        clear supply_data
        clear p_region_all
        clear load_region_all
        clear gas_gr_temp
        
         % Demand data input:
        load_growth = 0.030086;        
        dr = 1;
        while dr <= demand_run
            if dr == 1
                supply_data = supply_data_new_2024_3_1;
                gas_gr_temp = new_gr_all_temp_2024_3_1;
                J = J_2024_1;
                
                demand_curve = 'C:/Users/atpha/Documents/Research/PJM Model/Input Data/Demand Data/Demand Curves_96_2018.xlsx';
                load_data_region_1_temp = xlsread(demand_curve,'region 1');
                load_data_region_2_temp = xlsread(demand_curve,'region 2');
                load_data_region_3_temp = xlsread(demand_curve,'region 3');
                load_data_region_4_temp = xlsread(demand_curve,'region 4');
                load_data_region_5_temp = xlsread(demand_curve,'region 5');
                
                load_region_1 = load_data_region_1_temp(:,4)*(1+load_growth);
                load_region_2 = load_data_region_2_temp(:,4)*(1+load_growth);
                load_region_3 = load_data_region_3_temp(:,4)*(1+load_growth);
                load_region_4 = load_data_region_4_temp(:,4)*(1+load_growth);
                load_region_5 = load_data_region_5_temp(:,4)*(1+load_growth);
                
                p_region_1 = load_data_region_1_temp(:,3);
                p_region_2 = load_data_region_2_temp(:,3);
                p_region_3 = load_data_region_3_temp(:,3);
                p_region_4 = load_data_region_4_temp(:,3);
                p_region_5 = load_data_region_5_temp(:,3);  
                load_region_all_1 = [load_region_1,load_region_2,load_region_3,load_region_4,load_region_5];         
                p_region_all_1 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
            elseif dr == 2 
                load_region_1 = d_star_2025(1,:)'.*hours;
                load_region_2 = d_star_2025(2,:)'.*hours;
                load_region_3 = d_star_2025(3,:)'.*hours;
                load_region_4 = d_star_2025(4,:)'.*hours;
                load_region_5 = d_star_2025(5,:)'.*hours;  
                
                p_region_1 = p_star_2025(1,:)';
                p_region_2 = p_star_2025(2,:)';
                p_region_3 = p_star_2025(3,:)';
                p_region_4 = p_star_2025(4,:)';
                p_region_5 = p_star_2025(5,:)';     
                load_region_all_2 = [load_region_1,load_region_2,load_region_3,load_region_4,load_region_5];         
                p_region_all_2 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
            elseif dr == 3
                load_region_all_3 = load_region_all_2;
                p_region_1 = p_star_1(1,:)';
                p_region_2 = p_star_1(2,:)';
                p_region_3 = p_star_1(3,:)';
                p_region_4 = p_star_1(4,:)';
                p_region_5 = p_star_1(5,:)';  
                p_region_all_3 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];

            end
            
            if dr == 1
                load_region_all = load_region_all_1;
                p_region_all = p_region_all_1;
                [supply_data_new_2025_1,new_gr_all_temp_2025_1,p_star_2025,d_star_2025] = PJM_Electricity_Model_MB_2025(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
            elseif dr==2
                load_region_all = load_region_all_2;
                p_region_all = p_region_all_2; 
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);                                       
                    if i==1
                        J = J_2024_1;
                        supply_data = supply_data_new_2024_3_1;
                        gas_gr_temp = new_gr_all_temp_2024_3_1; 
                        [supply_data_new_2025_2_1,new_gr_all_temp_2025_2_1,p_star_1,d_star_1] = PJM_Electricity_Model_MB_2025(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
                        J_2025_1 = length(supply_data_new_2025_2_1);
                    elseif i==2
                        J = J_2024_2;
                        supply_data = supply_data_new_2024_3_2;
                        gas_gr_temp = new_gr_all_temp_2024_3_2; 
                        [supply_data_new_2025_2_2,new_gr_all_temp_2025_2_2,p_star_2,d_star_2] = PJM_Electricity_Model_MB_2025(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2025_2 = length(supply_data_new_2025_2_2);
                    elseif i==3
                        J = J_2024_3;
                        supply_data = supply_data_new_2024_3_3;
                        gas_gr_temp = new_gr_all_temp_2024_3_3; 
                        [supply_data_new_2025_2_3,new_gr_all_temp_2025_2_3,p_star_2,d_star_3] = PJM_Electricity_Model_MB_2025(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2025_3 = length(supply_data_new_2025_2_3);
                    end                                                                                                   
                end
            elseif dr==3
                load_region_all = load_region_all_3;
                p_region_all = p_region_all_3; 
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);                                       
                    if i==1
                        J = J_2024_1;
                        supply_data = supply_data_new_2024_3_1;
                        gas_gr_temp = new_gr_all_temp_2024_3_1; 
                        [supply_data_new_2025_3_1,new_gr_all_temp_2025_3_1,p_star_1,d_star_1] = PJM_Electricity_Model_MB_2025(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
                        J_2025_1 = length(supply_data_new_2025_3_1);
                    elseif i==2
                        J = J_2024_2;
                        supply_data = supply_data_new_2024_3_2;
                        gas_gr_temp = new_gr_all_temp_2024_3_2; 
                        [supply_data_new_2025_3_2,new_gr_all_temp_2025_3_2,p_star_2,d_star_2] = PJM_Electricity_Model_MB_2025(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2025_2 = length(supply_data_new_2025_3_2);
                    elseif i==3
                        J = J_2024_3;
                        supply_data = supply_data_new_2024_3_3;
                        gas_gr_temp = new_gr_all_temp_2024_3_3; 
                        [supply_data_new_2025_3_3,new_gr_all_temp_2025_3_3,p_star_2,d_star_3] = PJM_Electricity_Model_MB_2025(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2025_3 = length(supply_data_new_2025_3_3);
                    end                                                                                                   
                end
            end   
            dr = dr+1;            
        end
    % 2026    
    elseif sr==5
        % Supply data input:
        clear supply_data
        clear p_region_all
        clear load_region_all
        clear gas_gr_temp
        
         % Demand data input:
        load_growth = 0.03446;        
        dr = 1;
        while dr <= demand_run
            if dr == 1
                supply_data = supply_data_new_2025_3_1;
                gas_gr_temp = new_gr_all_temp_2025_3_1;
                J = J_2025_1;
                
                demand_curve = 'C:/Users/atpha/Documents/Research/PJM Model/Input Data/Demand Data/Demand Curves_96_2018.xlsx';
                load_data_region_1_temp = xlsread(demand_curve,'region 1');
                load_data_region_2_temp = xlsread(demand_curve,'region 2');
                load_data_region_3_temp = xlsread(demand_curve,'region 3');
                load_data_region_4_temp = xlsread(demand_curve,'region 4');
                load_data_region_5_temp = xlsread(demand_curve,'region 5');
                
                load_region_1 = load_data_region_1_temp(:,4)*(1+load_growth);
                load_region_2 = load_data_region_2_temp(:,4)*(1+load_growth);
                load_region_3 = load_data_region_3_temp(:,4)*(1+load_growth);
                load_region_4 = load_data_region_4_temp(:,4)*(1+load_growth);
                load_region_5 = load_data_region_5_temp(:,4)*(1+load_growth);
                
                p_region_1 = load_data_region_1_temp(:,3);
                p_region_2 = load_data_region_2_temp(:,3);
                p_region_3 = load_data_region_3_temp(:,3);
                p_region_4 = load_data_region_4_temp(:,3);
                p_region_5 = load_data_region_5_temp(:,3); 
                load_region_all_1 = [load_region_1,load_region_2,load_region_3,load_region_4,load_region_5];         
                p_region_all_1 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
            elseif dr == 2  
                load_region_1 = d_star_2026(1,:)'.*hours;
                load_region_2 = d_star_2026(2,:)'.*hours;
                load_region_3 = d_star_2026(3,:)'.*hours;
                load_region_4 = d_star_2026(4,:)'.*hours;
                load_region_5 = d_star_2026(5,:)'.*hours;  
                
                p_region_1 = p_star_2026(1,:)';
                p_region_2 = p_star_2026(2,:)';
                p_region_3 = p_star_2026(3,:)';
                p_region_4 = p_star_2026(4,:)';
                p_region_5 = p_star_2026(5,:)'; 
                load_region_all_2 = [load_region_1,load_region_2,load_region_3,load_region_4,load_region_5];         
                p_region_all_2 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
            elseif dr == 3
                load_region_all_3 = load_region_all_2;
                p_region_1 = p_star_1(1,:)';
                p_region_2 = p_star_1(2,:)';
                p_region_3 = p_star_1(3,:)';
                p_region_4 = p_star_1(4,:)';
                p_region_5 = p_star_1(5,:)';  
                p_region_all_3 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];

            end
            
            if dr == 1
                load_region_all = load_region_all_1;
                p_region_all = p_region_all_1;
                [supply_data_new_2026_1,new_gr_all_temp_2026_1,p_star_2026,d_star_2026] = PJM_Electricity_Model_MB_2026(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
            elseif dr==2
                load_region_all = load_region_all_2;
                p_region_all = p_region_all_2; 
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);                                       
                    if i==1
                        J = J_2025_1;
                        supply_data = supply_data_new_2025_3_1;
                        gas_gr_temp = new_gr_all_temp_2025_3_1; 
                        [supply_data_new_2026_2_1,new_gr_all_temp_2026_2_1,p_star_1,d_star_1] = PJM_Electricity_Model_MB_2026(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
                        J_2026_1 = length(supply_data_new_2026_2_1);
                    elseif i==2
                        J = J_2025_2;
                        supply_data = supply_data_new_2025_3_2;
                        gas_gr_temp = new_gr_all_temp_2025_3_2; 
                        [supply_data_new_2026_2_2,new_gr_all_temp_2026_2_2,p_star_2,d_star_2] = PJM_Electricity_Model_MB_2026(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2026_2 = length(supply_data_new_2026_2_2);
                    elseif i==3
                        J = J_2025_3;
                        supply_data = supply_data_new_2025_3_3;
                        gas_gr_temp = new_gr_all_temp_2025_3_3; 
                        [supply_data_new_2026_2_3,new_gr_all_temp_2026_2_3,p_star_2,d_star_3] = PJM_Electricity_Model_MB_2026(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2026_3 = length(supply_data_new_2026_2_3);
                    end                                                                                                   
                end
            elseif dr==3
                load_region_all = load_region_all_3;
                p_region_all = p_region_all_3; 
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);                                       
                    if i==1
                        J = J_2025_1;
                        supply_data = supply_data_new_2025_3_1;
                        gas_gr_temp = new_gr_all_temp_2025_3_1; 
                        [supply_data_new_2026_3_1,new_gr_all_temp_2026_3_1,p_star_1,d_star_1] = PJM_Electricity_Model_MB_2026(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
                        J_2026_1 = length(supply_data_new_2026_3_1);
                    elseif i==2
                        J = J_2025_2;
                        supply_data = supply_data_new_2025_3_2;
                        gas_gr_temp = new_gr_all_temp_2025_3_2; 
                        [supply_data_new_2026_3_2,new_gr_all_temp_2026_3_2,p_star_2,d_star_2] = PJM_Electricity_Model_MB_2026(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2026_2 = length(supply_data_new_2026_3_2);
                    elseif i==3
                        J = J_2025_3;
                        supply_data = supply_data_new_2025_3_3;
                        gas_gr_temp = new_gr_all_temp_2025_3_3; 
                        [supply_data_new_2026_3_3,new_gr_all_temp_2026_3_3,p_star_2,d_star_3] = PJM_Electricity_Model_MB_2026(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2026_3 = length(supply_data_new_2026_3_3);
                    end                                                                                                   
                end

            end 
            dr = dr+1;     
        end
    % 2027    
    elseif sr==6
        % Supply data input:
        clear supply_data
        clear p_region_all
        clear load_region_all
        clear gas_gr_temp
        
         % Demand data input:
        load_growth = 0.03885;        
        dr = 1;
        while dr <= demand_run
            if dr == 1
                supply_data = supply_data_new_2026_3_1;
                gas_gr_temp = new_gr_all_temp_2026_3_1;
                J = J_2026_1;
                
                demand_curve = 'C:/Users/atpha/Documents/Research/PJM Model/Input Data/Demand Data/Demand Curves_96_2018.xlsx';
                load_data_region_1_temp = xlsread(demand_curve,'region 1');
                load_data_region_2_temp = xlsread(demand_curve,'region 2');
                load_data_region_3_temp = xlsread(demand_curve,'region 3');
                load_data_region_4_temp = xlsread(demand_curve,'region 4');
                load_data_region_5_temp = xlsread(demand_curve,'region 5');
                
                load_region_1 = load_data_region_1_temp(:,4)*(1+load_growth);
                load_region_2 = load_data_region_2_temp(:,4)*(1+load_growth);
                load_region_3 = load_data_region_3_temp(:,4)*(1+load_growth);
                load_region_4 = load_data_region_4_temp(:,4)*(1+load_growth);
                load_region_5 = load_data_region_5_temp(:,4)*(1+load_growth);
                
                p_region_1 = load_data_region_1_temp(:,3);
                p_region_2 = load_data_region_2_temp(:,3);
                p_region_3 = load_data_region_3_temp(:,3);
                p_region_4 = load_data_region_4_temp(:,3);
                p_region_5 = load_data_region_5_temp(:,3); 
                load_region_all_1 = [load_region_1,load_region_2,load_region_3,load_region_4,load_region_5];         
                p_region_all_1 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
            elseif dr == 2  
                load_region_1 = d_star_2027(1,:)'.*hours;
                load_region_2 = d_star_2027(2,:)'.*hours;
                load_region_3 = d_star_2027(3,:)'.*hours;
                load_region_4 = d_star_2027(4,:)'.*hours;
                load_region_5 = d_star_2027(5,:)'.*hours;  
                
                p_region_1 = p_star_2027(1,:)';
                p_region_2 = p_star_2027(2,:)';
                p_region_3 = p_star_2027(3,:)';
                p_region_4 = p_star_2027(4,:)';
                p_region_5 = p_star_2027(5,:)'; 
                load_region_all_2 = [load_region_1,load_region_2,load_region_3,load_region_4,load_region_5];         
                p_region_all_2 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
            elseif dr == 3
                load_region_all_3 = load_region_all_2;
                p_region_1 = p_star_1(1,:)';
                p_region_2 = p_star_1(2,:)';
                p_region_3 = p_star_1(3,:)';
                p_region_4 = p_star_1(4,:)';
                p_region_5 = p_star_1(5,:)';  
                p_region_all_3 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
            end
            
            if dr == 1
                load_region_all = load_region_all_1;
                p_region_all = p_region_all_1;
                [supply_data_new_2027_1,new_gr_all_temp_2027_1,p_star_2027,d_star_2027] = PJM_Electricity_Model_MB_2027(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
            elseif dr==2
                load_region_all = load_region_all_2;
                p_region_all = p_region_all_2; 
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);                                       
                    if i==1
                        J = J_2026_1;
                        supply_data = supply_data_new_2026_3_1;
                        gas_gr_temp = new_gr_all_temp_2026_3_1; 
                        [supply_data_new_2027_3_1,new_gr_all_temp_2027_3_1,p_star_1,d_star_1] = PJM_Electricity_Model_MB_2027(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
                        J_2027_1 = length(supply_data_new_2027_3_1);
                    elseif i==2
                        J = J_2026_2;
                        supply_data = supply_data_new_2026_3_2;
                        gas_gr_temp = new_gr_all_temp_2026_3_2; 
                        [supply_data_new_2027_2_2,new_gr_all_temp_2027_2_2,p_star_2,d_star_2] = PJM_Electricity_Model_MB_2027(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2027_2 = length(supply_data_new_2027_2_2);
                    elseif i==3
                        J = J_2026_3;
                        supply_data = supply_data_new_2026_3_3;
                        gas_gr_temp = new_gr_all_temp_2026_3_3; 
                        [supply_data_new_2027_2_3,new_gr_all_temp_2027_2_3,p_star_2,d_star_3] = PJM_Electricity_Model_MB_2027(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2027_3 = length(supply_data_new_2027_2_3);
                    end                                                                                                   
                end
            elseif dr==3
                load_region_all = load_region_all_3;
                p_region_all = p_region_all_3; 
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);                                       
                    if i==1
                        J = J_2026_1;
                        supply_data = supply_data_new_2026_3_1;
                        gas_gr_temp = new_gr_all_temp_2026_3_1; 
                        [supply_data_new_2027_3_1,new_gr_all_temp_2027_3_1,p_star_1,d_star_1] = PJM_Electricity_Model_MB_2027(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
                        J_2027_1 = length(supply_data_new_2027_3_1);
                    elseif i==2
                        J = J_2026_2;
                        supply_data = supply_data_new_2026_3_2;
                        gas_gr_temp = new_gr_all_temp_2026_3_2; 
                        [supply_data_new_2027_3_2,new_gr_all_temp_2027_3_2,p_star_2,d_star_2] = PJM_Electricity_Model_MB_2027(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2027_2 = length(supply_data_new_2027_3_2);
                    elseif i==3
                        J = J_2026_3;
                        supply_data = supply_data_new_2026_3_3;
                        gas_gr_temp = new_gr_all_temp_2026_3_3; 
                        [supply_data_new_2027_3_3,new_gr_all_temp_2027_3_3,p_star_2,d_star_3] = PJM_Electricity_Model_MB_2027(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2027_3 = length(supply_data_new_2027_3_3);
                    end                                                                                                   
                end

            end 
            dr = dr+1;     
        end
    % 2028    
    elseif sr==7
        % Supply data input:
        clear supply_data
        clear p_region_all
        clear load_region_all
        clear gas_gr_temp
        
         % Demand data input:
        load_growth = 0.0433;        
        dr = 1;
        while dr <= demand_run
            if dr == 1
                supply_data = supply_data_new_2027_3_1;
                gas_gr_temp = new_gr_all_temp_2027_3_1;
                J = J_2027_1;
                
                demand_curve = 'C:/Users/atpha/Documents/Research/PJM Model/Input Data/Demand Data/Demand Curves_96_2018.xlsx';
                load_data_region_1_temp = xlsread(demand_curve,'region 1');
                load_data_region_2_temp = xlsread(demand_curve,'region 2');
                load_data_region_3_temp = xlsread(demand_curve,'region 3');
                load_data_region_4_temp = xlsread(demand_curve,'region 4');
                load_data_region_5_temp = xlsread(demand_curve,'region 5');
                
                load_region_1 = load_data_region_1_temp(:,4)*(1+load_growth);
                load_region_2 = load_data_region_2_temp(:,4)*(1+load_growth);
                load_region_3 = load_data_region_3_temp(:,4)*(1+load_growth);
                load_region_4 = load_data_region_4_temp(:,4)*(1+load_growth);
                load_region_5 = load_data_region_5_temp(:,4)*(1+load_growth);
                
                p_region_1 = load_data_region_1_temp(:,3);
                p_region_2 = load_data_region_2_temp(:,3);
                p_region_3 = load_data_region_3_temp(:,3);
                p_region_4 = load_data_region_4_temp(:,3);
                p_region_5 = load_data_region_5_temp(:,3); 
                load_region_all_1 = [load_region_1,load_region_2,load_region_3,load_region_4,load_region_5];         
                p_region_all_1 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
            elseif dr == 2    
                load_region_1 = d_star_2028(1,:)'.*hours;
                load_region_2 = d_star_2028(2,:)'.*hours;
                load_region_3 = d_star_2028(3,:)'.*hours;
                load_region_4 = d_star_2028(4,:)'.*hours;
                load_region_5 = d_star_2028(5,:)'.*hours;  
                
                p_region_1 = p_star_2028(1,:)';
                p_region_2 = p_star_2028(2,:)';
                p_region_3 = p_star_2028(3,:)';
                p_region_4 = p_star_2028(4,:)';
                p_region_5 = p_star_2028(5,:)';   
                load_region_all_2 = [load_region_1,load_region_2,load_region_3,load_region_4,load_region_5];         
                p_region_all_2 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
            elseif dr == 3
                load_region_all_3 = load_region_all_2;
                p_region_1 = p_star_1(1,:)';
                p_region_2 = p_star_1(2,:)';
                p_region_3 = p_star_1(3,:)';
                p_region_4 = p_star_1(4,:)';
                p_region_5 = p_star_1(5,:)';  
                p_region_all_3 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];

            end
            
            if dr == 1
                load_region_all = load_region_all_1;
                p_region_all = p_region_all_1;
                [supply_data_new_2028_1,new_gr_all_temp_2028_1,p_star_2028,d_star_2028] = PJM_Electricity_Model_MB_2028(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
            elseif dr==2
                load_region_all = load_region_all_2;
                p_region_all = p_region_all_2; 
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);                                       
                    if i==1
                        J = J_2027_1;
                        supply_data = supply_data_new_2027_3_1;
                        gas_gr_temp = new_gr_all_temp_2027_3_1; 
                        [supply_data_new_2028_2_1,new_gr_all_temp_2028_2_1,p_star_1,d_star_1] = PJM_Electricity_Model_MB_2028(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
                        J_2028_1 = length(supply_data_new_2028_2_1);
                    elseif i==2
                        J = J_2027_2;
                        supply_data = supply_data_new_2027_3_2;
                        gas_gr_temp = new_gr_all_temp_2027_3_2; 
                        [supply_data_new_2028_2_2,new_gr_all_temp_2028_2_2,p_star_2,d_star_2] = PJM_Electricity_Model_MB_2028(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2028_2 = length(supply_data_new_2028_2_2);
                    elseif i==3
                        J = J_2027_3;
                        supply_data = supply_data_new_2027_3_3;
                        gas_gr_temp = new_gr_all_temp_2027_3_3; 
                        [supply_data_new_2028_2_3,new_gr_all_temp_2028_2_3,p_star_2,d_star_3] = PJM_Electricity_Model_MB_2028(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2028_3 = length(supply_data_new_2028_2_3);
                    end                                                                                                   
                end
            elseif dr==3
                load_region_all = load_region_all_3;
                p_region_all = p_region_all_3; 
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);                                       
                    if i==1
                        J = J_2027_1;
                        supply_data = supply_data_new_2027_3_1;
                        gas_gr_temp = new_gr_all_temp_2027_3_1; 
                        [supply_data_new_2028_3_1,new_gr_all_temp_2028_3_1,p_star_1,d_star_1] = PJM_Electricity_Model_MB_2028(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
                        J_2028_1 = length(supply_data_new_2028_3_1);
                    elseif i==2
                        J = J_2027_2;
                        supply_data = supply_data_new_2027_3_2;
                        gas_gr_temp = new_gr_all_temp_2027_3_2; 
                        [supply_data_new_2028_3_2,new_gr_all_temp_2028_3_2,p_star_2,d_star_2] = PJM_Electricity_Model_MB_2028(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2028_2 = length(supply_data_new_2028_3_2);
                    elseif i==3
                        J = J_2027_3;
                        supply_data = supply_data_new_2027_3_3;
                        gas_gr_temp = new_gr_all_temp_2027_3_3; 
                        [supply_data_new_2028_3_3,new_gr_all_temp_2028_3_3,p_star_2,d_star_3] = PJM_Electricity_Model_MB_2028(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2028_3 = length(supply_data_new_2028_3_3);
                    end                                                                                                   
                end
            end 
            dr = dr+1;     
        end
    % 2029
    elseif sr==8
        % Supply data input:
        clear supply_data
        clear p_region_all
        clear load_region_all
        clear gas_gr_temp
        
         % Demand data input:
        load_growth = 0.047683;        
        dr = 1;
        while dr <= demand_run
            if dr == 1
                supply_data = supply_data_new_2028_3_1;
                gas_gr_temp = new_gr_all_temp_2028_3_1;
                J = J_2028_1;
                
                demand_curve = 'C:/Users/atpha/Documents/Research/PJM Model/Input Data/Demand Data/Demand Curves_96_2018.xlsx';
                load_data_region_1_temp = xlsread(demand_curve,'region 1');
                load_data_region_2_temp = xlsread(demand_curve,'region 2');
                load_data_region_3_temp = xlsread(demand_curve,'region 3');
                load_data_region_4_temp = xlsread(demand_curve,'region 4');
                load_data_region_5_temp = xlsread(demand_curve,'region 5');
                
                load_region_1 = load_data_region_1_temp(:,4)*(1+load_growth);
                load_region_2 = load_data_region_2_temp(:,4)*(1+load_growth);
                load_region_3 = load_data_region_3_temp(:,4)*(1+load_growth);
                load_region_4 = load_data_region_4_temp(:,4)*(1+load_growth);
                load_region_5 = load_data_region_5_temp(:,4)*(1+load_growth);
                
                p_region_1 = load_data_region_1_temp(:,3);
                p_region_2 = load_data_region_2_temp(:,3);
                p_region_3 = load_data_region_3_temp(:,3);
                p_region_4 = load_data_region_4_temp(:,3);
                p_region_5 = load_data_region_5_temp(:,3);  
                load_region_all_1 = [load_region_1,load_region_2,load_region_3,load_region_4,load_region_5];         
                p_region_all_1 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
            elseif dr == 2    
                load_region_1 = d_star_2029(1,:)'.*hours;
                load_region_2 = d_star_2029(2,:)'.*hours;
                load_region_3 = d_star_2029(3,:)'.*hours;
                load_region_4 = d_star_2029(4,:)'.*hours;
                load_region_5 = d_star_2029(5,:)'.*hours;  
                
                p_region_1 = p_star_2029(1,:)';
                p_region_2 = p_star_2029(2,:)';
                p_region_3 = p_star_2029(3,:)';
                p_region_4 = p_star_2029(4,:)';
                p_region_5 = p_star_2029(5,:)';     
                load_region_all_2 = [load_region_1,load_region_2,load_region_3,load_region_4,load_region_5];         
                p_region_all_2 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];

            elseif dr == 3
                load_region_all_3 = load_region_all_2;
                p_region_1 = p_star_1(1,:)';
                p_region_2 = p_star_1(2,:)';
                p_region_3 = p_star_1(3,:)';
                p_region_4 = p_star_1(4,:)';
                p_region_5 = p_star_1(5,:)';  
                p_region_all_3 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];

            end
            
           if dr == 1
                load_region_all = load_region_all_1;
                p_region_all = p_region_all_1;
                [supply_data_new_2029_1,new_gr_all_temp_2029_1,p_star_2029,d_star_2029] = PJM_Electricity_Model_MB_2029(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
            elseif dr==2
                load_region_all = load_region_all_2;
                p_region_all = p_region_all_2; 
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);                                       
                    if i==1
                        J = J_2028_1;
                        supply_data = supply_data_new_2028_3_1;
                        gas_gr_temp = new_gr_all_temp_2028_3_1; 
                        [supply_data_new_2029_2_1,new_gr_all_temp_2029_2_1,p_star_1,d_star_1] = PJM_Electricity_Model_MB_2029(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
                        J_2029_1 = length(supply_data_new_2029_2_1);
                    elseif i==2
                        J = J_2028_2;
                        supply_data = supply_data_new_2028_3_2;
                        gas_gr_temp = new_gr_all_temp_2028_3_2; 
                        [supply_data_new_2029_2_2,new_gr_all_temp_2029_2_2,p_star_2,d_star_2] = PJM_Electricity_Model_MB_2029(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2029_2 = length(supply_data_new_2029_2_2);
                    elseif i==3
                        J = J_2028_3;
                        supply_data = supply_data_new_2028_3_3;
                        gas_gr_temp = new_gr_all_temp_2028_3_3; 
                        [supply_data_new_2029_2_3,new_gr_all_temp_2029_2_3,p_star_2,d_star_3] = PJM_Electricity_Model_MB_2029(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2029_3 = length(supply_data_new_2029_2_3);
                    end                                                                                                   
                end
            elseif dr==3
                load_region_all = load_region_all_3;
                p_region_all = p_region_all_3; 
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);                                       
                    if i==1
                        J = J_2028_1;
                        supply_data = supply_data_new_2028_3_1;
                        gas_gr_temp = new_gr_all_temp_2028_3_1; 
                        [supply_data_new_2029_3_1,new_gr_all_temp_2029_3_1,p_star_1,d_star_1] = PJM_Electricity_Model_MB_2029(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
                        J_2029_1 = length(supply_data_new_2029_3_1);
                    elseif i==2
                        J = J_2028_2;
                        supply_data = supply_data_new_2028_3_2;
                        gas_gr_temp = new_gr_all_temp_2028_3_2; 
                        [supply_data_new_2029_3_2,new_gr_all_temp_2029_3_2,p_star_2,d_star_2] = PJM_Electricity_Model_MB_2029(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2029_2 = length(supply_data_new_2029_3_2);
                    elseif i==3
                        J = J_2028_3;
                        supply_data = supply_data_new_2028_3_3;
                        gas_gr_temp = new_gr_all_temp_2028_3_3; 
                        [supply_data_new_2029_3_3,new_gr_all_temp_2029_3_3,p_star_2,d_star_3] = PJM_Electricity_Model_MB_2029(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2029_3 = length(supply_data_new_2029_3_3);
                    end                                                                                                   
                end
            end 
            dr = dr+1;     
        end
    % 2030
    elseif sr==9
        % Supply data input:
        clear supply_data
        clear p_region_all
        clear load_region_all
        clear gas_gr_temp
        
         % Demand data input:
        load_growth = 0.05213;        
        dr = 1;
        while dr <= demand_run
            if dr == 1
                supply_data = supply_data_new_2029_3_1;
                gas_gr_temp = new_gr_all_temp_2029_3_1;
                J = J_2029_1;
                
                demand_curve = 'C:/Users/atpha/Documents/Research/PJM Model/Input Data/Demand Data/Demand Curves_96_2018.xlsx';
                load_data_region_1_temp = xlsread(demand_curve,'region 1');
                load_data_region_2_temp = xlsread(demand_curve,'region 2');
                load_data_region_3_temp = xlsread(demand_curve,'region 3');
                load_data_region_4_temp = xlsread(demand_curve,'region 4');
                load_data_region_5_temp = xlsread(demand_curve,'region 5');
                
                load_region_1 = load_data_region_1_temp(:,4)*(1+load_growth);
                load_region_2 = load_data_region_2_temp(:,4)*(1+load_growth);
                load_region_3 = load_data_region_3_temp(:,4)*(1+load_growth);
                load_region_4 = load_data_region_4_temp(:,4)*(1+load_growth);
                load_region_5 = load_data_region_5_temp(:,4)*(1+load_growth);
                
                p_region_1 = load_data_region_1_temp(:,3);
                p_region_2 = load_data_region_2_temp(:,3);
                p_region_3 = load_data_region_3_temp(:,3);
                p_region_4 = load_data_region_4_temp(:,3);
                p_region_5 = load_data_region_5_temp(:,3);   
                load_region_all_1 = [load_region_1,load_region_2,load_region_3,load_region_4,load_region_5];         
                p_region_all_1 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
            elseif dr == 2
                load_region_1 = d_star_2030(1,:)'.*hours;
                load_region_2 = d_star_2030(2,:)'.*hours;
                load_region_3 = d_star_2030(3,:)'.*hours;
                load_region_4 = d_star_2030(4,:)'.*hours;
                load_region_5 = d_star_2030(5,:)'.*hours;  
                
                p_region_1 = p_star_2030(1,:)';
                p_region_2 = p_star_2030(2,:)';
                p_region_3 = p_star_2030(3,:)';
                p_region_4 = p_star_2030(4,:)';
                p_region_5 = p_star_2030(5,:)';   
                load_region_all_2 = [load_region_1,load_region_2,load_region_3,load_region_4,load_region_5];         
                p_region_all_2 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];

            elseif dr == 3
                load_region_all_3 = load_region_all_2;
                p_region_1 = p_star_1(1,:)';
                p_region_2 = p_star_1(2,:)';
                p_region_3 = p_star_1(3,:)';
                p_region_4 = p_star_1(4,:)';
                p_region_5 = p_star_1(5,:)';  
                p_region_all_3 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];

            end
            
            if dr == 1
                load_region_all = load_region_all_1;
                p_region_all = p_region_all_1;
                [supply_data_new_2030_1,new_gr_all_temp_2030_1,p_star_2030,d_star_2030] = PJM_Electricity_Model_MB_2030(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
            elseif dr==2
                load_region_all = load_region_all_2;
                p_region_all = p_region_all_2; 
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);                                       
                    if i==1
                        J = J_2029_1;
                        supply_data = supply_data_new_2029_3_1;
                        gas_gr_temp = new_gr_all_temp_2029_3_1; 
                        [supply_data_new_2030_2_1,new_gr_all_temp_2030_2_1,p_star_1,d_star_1] = PJM_Electricity_Model_MB_2030(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
                        J_2030_1 = length(supply_data_new_2030_2_1);
                    elseif i==2
                        J = J_2029_2;
                        supply_data = supply_data_new_2029_3_2;
                        gas_gr_temp = new_gr_all_temp_2029_3_2; 
                        [supply_data_new_2030_2_2,new_gr_all_temp_2030_2_2,p_star_2,d_star_2] = PJM_Electricity_Model_MB_2030(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2030_2 = length(supply_data_new_2030_2_2);
                    elseif i==3
                        J = J_2029_3;
                        supply_data = supply_data_new_2029_3_3;
                        gas_gr_temp = new_gr_all_temp_2029_3_3; 
                        [supply_data_new_2030_2_3,new_gr_all_temp_2030_2_3,p_star_2,d_star_3] = PJM_Electricity_Model_MB_2030(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2030_3 = length(supply_data_new_2030_2_3);
                    end                                                                                                   
                end
            elseif dr==3
                load_region_all = load_region_all_3;
                p_region_all = p_region_all_3; 
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);                                       
                    if i==1
                        J = J_2029_1;
                        supply_data = supply_data_new_2029_3_1;
                        gas_gr_temp = new_gr_all_temp_2029_3_1; 
                        [supply_data_new_2030_3_1,new_gr_all_temp_2030_3_1,p_star_1,d_star_1] = PJM_Electricity_Model_MB_2030(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours); 
                        J_2030_1 = length(supply_data_new_2030_3_1);
                    elseif i==2
                        J = J_2029_2;
                        supply_data = supply_data_new_2029_3_2;
                        gas_gr_temp = new_gr_all_temp_2029_3_2; 
                        [supply_data_new_2030_3_2,new_gr_all_temp_2030_3_2,p_star_2,d_star_2] = PJM_Electricity_Model_MB_2030(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2030_2 = length(supply_data_new_2030_3_2);
                    elseif i==3
                        J = J_2029_3;
                        supply_data = supply_data_new_2029_3_3;
                        gas_gr_temp = new_gr_all_temp_2029_3_3; 
                        [supply_data_new_2030_3_3,new_gr_all_temp_2030_3_3,p_star_2,d_star_3] = PJM_Electricity_Model_MB_2030(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours);
                        J_2030_3 = length(supply_data_new_2030_3_3);
                    end                                                                                                   
                end
            end 
            dr = dr+1;     
        end
    end
    
    sr = sr+1;   
                                              
end
    


