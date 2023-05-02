% PJM Electricity Model for 5 nodes for year 2020 to 2030
% Use for RGGI Project
% With Capacity Expansion
% With Existence of RPS extended until 2030
% Finished coding on 04/20/2020 by An Pham.
% Updated on 08/23/2020

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RUN ALL THREE POLICIES YEAR BY YEAR %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%**********************************************
%% Switches:
%**********************************************
trans_const = 1;          % Whether or not there's existence of transmission constraint (==1:yes, ==0:no)
rps_const = 1;            % Whether or not there's existence of RPS (==1:yes, ==0:no) 
cap_exp = 1;              % Whether or not there's capacity expansion (==1:yes, ==0:no)
ext_rec_sc = 2;           % External RECs (==1: constant, ==2: growing)
run_on_cluster = 1;       % ==0: run on An's computer, ==1: run on the cluster
run_new_MEC_curve = 1;    % ==0: old estimated MEC curve, ==1: new estimated MEC curve
with_VA = 1;              % Whether or not VA joins RGGI in 2021 (==1: yes, ==0: no)

policy_sc_all = [1;2;3];  % ==1: No Policy, ==2: PA joining RGGI, ==3: PA Removing RPS

PA_in_RGGI = 0;           % This is the starting case (DO NOT CHANGE)  
PA_in_RPS = 1;            % This is the starting case (DO NOT CHANGE) 

%**********************************************
%% Define Parameters and variables:
%**********************************************
hours = [2 4 6 9 8 17 26 35	21 43 65 87	64 130 194 260 64 130 194 260 54 108 162 216 2 4 6 9 8 18 26 36	21 44 65 88	65 131 197 262 65 131 197 263 54 109 164 219 2 4 7 9 8 18 26 36	22 44 66 89	66 132 199 265 66 132 199 266 55 110 166 221 2 4 7 9 8 18 26 36	22 44 66 89	66 132 199 266 66 132 199 265 55 110 166 222]';
start_year = 2020;
end_year = 2030;
demand_run = 3;           % ==1: Run only the perfectly inelastic case, ==2: Run both cases (perflectly inelastic and etaD = 0.05)  

model_year = start_year:end_year;
supply_run = length(model_year);

if run_new_MEC_curve == 0
    % RGGI abatement intercept:
    b_RGGI = 91235399.86371646821498870850*0.907185;
    % RGGI abatement slope:
    m_RGGI = -4978988.24362862110137939453*0.907185;

    % RGGI bank:
    b_RGGI_b_t = 19841346.04586441814899444580*0.907185;
    m_RGGI_b = -4563206.41636333614587783813*0.907185;

    bank_t_1 = 96713580.78900006413459777832*0.907185;
    m_bank_t_1= 0.99559818645428532768;

    b_RGGI_b = b_RGGI_b_t + bank_t_1*m_bank_t_1;

    % RGGI in PJM only:
    b_RGGI_PJM = 6038648.9; 
    m_RGGI_PJM = -250892.22;

    % non PJM RGGI + banking:
    b_RGGI_nonPJM = b_RGGI - b_RGGI_PJM ;
    m_RGGI_nonPJM = m_RGGI - m_RGGI_PJM;
elseif run_new_MEC_curve == 1
    % RGGI bank:
    b_RGGI_b_t = 20080917.74470088258385658264*0.907185;
    m_RGGI_b = -4494074.78231317549943923950*0.907185;

    bank_t_1 = 96713580.78900001943111419678*0.907185;
    m_bank_t_1= 0.99081421558380533554;

    b_RGGI_b = b_RGGI_b_t + bank_t_1*m_bank_t_1;

    % non PJM RGGI:
    b_RGGI_nonPJM = 66440333.04332622140645980835*0.907185;
    m_RGGI_nonPJM = -3699101.38184171915054321289*0.907185;
end

% Number of nodes, lines,load segment and elasticity of demand:
I = 5;                    % Number of nodes    
J = 880;                  % Number of aggregated units
T = 96;                   % Number of load segments
F = 10;                   % Number of aggregated transmission lines
J_r = 262;                % Number of plants eligible to provide RECs to PJM states.
S = 14;                   % Number of PJM states. 

if run_on_cluster ==0
    roc = 'C:/Users/atpha/Documents/Research/PJM Electricity Model/In MATLAB/case 2/Input/';
elseif run_on_cluster ==1
    roc = '/storage/work/a/akp5369/PJM_Electricity_Model/case_2/Input/';
end

RGGI_cap_OH = [74,860,408.51;72,471,238.57;70,082,068.63;67,692,898.70;65,303,728.76;62,914,558.82;60,525,388.88;58,136,218.95;55,747,049.01];
RGGI_cap_WV = [62,803,753.48;60,799,371.69;58,794,989.90;56,790,608.11;54,786,226.31;52,781,844.52;50,777,462.73;48,773,080.94;46,768,699.14];

RGGI_cap_data_withPA = strcat(roc,'RGGI_caps6.xlsx');
RGGI_cap_data_noPA = strcat(roc,'RGGI_caps_noPA2.xlsx');
Banking_no_VA = strcat(roc,'RGGI_caps9.xlsx');

RGGI_cap_VA = xlsread(RGGI_cap_data_withPA,'VA');

PA_NJ_VA_cap_withPA = xlsread(RGGI_cap_data_withPA,'Total');
PA_NJ_VA_cap_noPA = xlsread(RGGI_cap_data_noPA,'Total');
Others_cap = xlsread(RGGI_cap_data_withPA,'Others');

if with_VA == 1
    Bank_adjustment = xlsread(RGGI_cap_data_withPA,'Banking');
elseif with_VA == 0
    Bank_adjustment = xlsread(Banking_no_VA,'Banking');
end

if with_VA == 1
    e_bar_RGGI_data_withPA = PA_NJ_VA_cap_withPA(2,:)+Others_cap(2,:)-Bank_adjustment(2,:);
    e_bar_RGGI_data_noPA = PA_NJ_VA_cap_noPA(2,:)+Others_cap(2,:)-Bank_adjustment(2,:);
elseif with_VA == 0
    e_bar_RGGI_data_withPA = PA_NJ_VA_cap_withPA(2,:)+Others_cap(2,:)-Bank_adjustment(2,:)-RGGI_cap_VA(2,:);
    e_bar_RGGI_data_noPA = PA_NJ_VA_cap_noPA(2,:)+Others_cap(2,:)-Bank_adjustment(2,:)-RGGI_cap_VA(2,:);
end
metric_convert = 0.907185;

%**********************************************
%% Main Loops:
%**********************************************
sr = 1;
while sr <= supply_run    
    % 2020:
    if sr==1        
        % Supply data input:
        supply_curve = strcat(roc,'Supply_Curve_2020.xlsx');
        supply_data = xlsread(supply_curve,'supply curve');
        rps_data = supply_data(:,114:115);
        
        % Demand data input:
        load_growth = 0.008505;        
        dr = 1;
        while dr <= demand_run
            if dr == 1
                demand_curve = strcat(roc,'Demand_Curve_2018.xlsx');
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
                
                load_region_all = load_region_all_1;
                p_region_all = p_region_all_1;
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                % solve:
                [supply_data_new_2020_1,new_gr_all_temp_2020_1,p_star_2020,d_star_2020,x_RGGI_b_2020] = PJM_Model_RGGI_All_Policies_2020(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,rps_data,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b,m_RGGI_b,PA_in_RGGI,PA_in_RPS); 
                
            elseif dr == 2       
                load_region_1 = d_star_2020(1,:)'.*hours;
                load_region_2 = d_star_2020(2,:)'.*hours;
                load_region_3 = d_star_2020(3,:)'.*hours;
                load_region_4 = d_star_2020(4,:)'.*hours;
                load_region_5 = d_star_2020(5,:)'.*hours;  
                
                p_region_1 = p_star_2020(1,:)';
                p_region_2 = p_star_2020(2,:)';
                p_region_3 = p_star_2020(3,:)';
                p_region_4 = p_star_2020(4,:)';
                p_region_5 = p_star_2020(5,:)';  
                load_region_all_2 = [load_region_1,load_region_2,load_region_3,load_region_4,load_region_5];         
                p_region_all_2 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
                load_region_all = load_region_all_2;
                p_region_all = p_region_all_2; 
                policy_sc = 1;
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;

                [supply_data_new_2020_2,new_gr_all_temp_2020_2,p_star_2,d_star_2,x_RGGI_b_2020_2] = PJM_Model_RGGI_All_Policies_2020(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,rps_data,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1, b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS);
                J_2020_1 = length(supply_data_new_2020_2);
                              
            elseif dr == 3
                load_region_all_3 = load_region_all_2;
                p_region_1 = p_star_2(1,:)';
                p_region_2 = p_star_2(2,:)';
                p_region_3 = p_star_2(3,:)';
                p_region_4 = p_star_2(4,:)';
                p_region_5 = p_star_2(5,:)';  
                p_region_all_3 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
                load_region_all = load_region_all_3;
                
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);
                    if policy_sc == 1
                        PA_in_RGGI = 0;
                        PA_in_RPS = 1;                       
                    elseif policy_sc == 2
                        PA_in_RGGI = 1;
                        PA_in_RPS = 1;                        
                    elseif policy_sc == 3
                        PA_in_RGGI = 1;
                        PA_in_RPS = 0;                        
                    end
                    
                    if i==1 
                        e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                        [supply_data_new_2020_3_1,new_gr_all_temp_2020_3_1,p_star_3_1,d_star_3_1,x_RGGI_b_2020_3_1] = PJM_Model_RGGI_All_Policies_2020(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,rps_data,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1, b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS);
                        b_RGGI_b_2020_1 = b_RGGI_b_t + x_RGGI_b_2020_3_1*m_bank_t_1;
                        bank_2020_1 = x_RGGI_b_2020_3_1;
                        J_2020_1 = length(supply_data_new_2020_3_1);
                    elseif i==2
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        [supply_data_new_2020_3_2,new_gr_all_temp_2020_3_2,p_star_3_2,d_star_3_2,x_RGGI_b_2020_3_2] = PJM_Model_RGGI_All_Policies_2020(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,rps_data,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1, b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS);
                        b_RGGI_b_2020_2 = b_RGGI_b_t + x_RGGI_b_2020_3_2*m_bank_t_1;
                        bank_2020_2 = x_RGGI_b_2020_3_2;
                        J_2020_2 = length(supply_data_new_2020_3_2);
                    elseif i==3
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        [supply_data_new_2020_3_3,new_gr_all_temp_2020_3_3,p_star_3_3,d_star_3_3,x_RGGI_b_2020_3_3] = PJM_Model_RGGI_All_Policies_2020(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,rps_data,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1, b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS);
                        b_RGGI_b_2020_3 = b_RGGI_b_t + x_RGGI_b_2020_3_3*m_bank_t_1;
                        bank_2020_3 = x_RGGI_b_2020_3_3;
                        J_2020_3 = length(supply_data_new_2020_3_3);
                    end                                                        
                end                 
            end                                                                 
            dr = dr+1;            
        end
    % 2021   
    elseif sr==2        
        % Supply data input:
        clear supply_data
        clear p_region_all
        clear load_region_all
        clear gas_gr_temp
        clear b_RGGI_b
        clear bank_t_1
        
        PA_in_RGGI = 0;           % This is the starting case (DO NOT CHANGE)  
        PA_in_RPS = 1;            % This is the starting case (DO NOT CHANGE) 
                        
        % Demand data input:
        load_growth = 0.012785;    
        
        % RGGI input:
        b_RGGI_b = b_RGGI_b_2020_1;
        bank_t_1 = bank_2020_1;
        
        dr = 1;
        while dr <= demand_run
            if dr == 1
                supply_data = supply_data_new_2020_3_1;
                gas_gr_temp = new_gr_all_temp_2020_3_1;
                J = J_2020_1;                

                demand_curve = strcat(roc,'Demand_Curve_2018.xlsx');                
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
                
                load_region_all = load_region_all_1;
                p_region_all = p_region_all_1;
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                
                [supply_data_new_2021_1,new_gr_all_temp_2021_1,p_star_2021,d_star_2021,x_RGGI_b_2021] = PJM_Model_RGGI_All_Policies_2021(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
                
            elseif dr == 2      
                load_region_1 = d_star_2021(1,:)'.*hours;
                load_region_2 = d_star_2021(2,:)'.*hours;
                load_region_3 = d_star_2021(3,:)'.*hours;
                load_region_4 = d_star_2021(4,:)'.*hours;
                load_region_5 = d_star_2021(5,:)'.*hours;                 
                
                p_region_1 = p_star_2021(1,:)';
                p_region_2 = p_star_2021(2,:)';
                p_region_3 = p_star_2021(3,:)';
                p_region_4 = p_star_2021(4,:)';
                p_region_5 = p_star_2021(5,:)';   
                load_region_all_2 = [load_region_1,load_region_2,load_region_3,load_region_4,load_region_5];         
                p_region_all_2 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
                load_region_all = load_region_all_2;
                p_region_all = p_region_all_2; 
                
                J = J_2020_1;
                supply_data = supply_data_new_2020_3_1;
                gas_gr_temp = new_gr_all_temp_2020_3_1; 
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                
                [supply_data_new_2021_2,new_gr_all_temp_2021_2,p_star_2,d_star_2,x_RGGI_b_2021_2] = PJM_Model_RGGI_All_Policies_2021(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b,m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
            elseif dr == 3
                load_region_all_3 = load_region_all_2;
                p_region_1 = p_star_2(1,:)';
                p_region_2 = p_star_2(2,:)';
                p_region_3 = p_star_2(3,:)';
                p_region_4 = p_star_2(4,:)';
                p_region_5 = p_star_2(5,:)';  
                p_region_all_3 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
                load_region_all = load_region_all_3;
                p_region_all = p_region_all_3;                                                                
                
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);
                    if policy_sc == 1
                        PA_in_RGGI = 0;
                        PA_in_RPS = 1;
                    elseif policy_sc == 2
                        PA_in_RGGI = 1;
                        PA_in_RPS = 1;
                    elseif policy_sc == 3
                        PA_in_RGGI = 1;
                        PA_in_RPS = 0;
                    end
                    
                    if i==1
                        J = J_2020_1;
                        supply_data = supply_data_new_2020_3_1;
                        gas_gr_temp = new_gr_all_temp_2020_3_1; 
                        b_RGGI_b = b_RGGI_b_2020_1;
                        bank_t_1 = bank_2020_1;
                        e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                        
                        [supply_data_new_2021_3_1,new_gr_all_temp_2021_3_1,p_star_3_1,d_star_3_1,x_RGGI_b_2021_3_1] = PJM_Model_RGGI_All_Policies_2021(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b,m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                        b_RGGI_b_2021_1 = b_RGGI_b_t + x_RGGI_b_2021_3_1*m_bank_t_1;
                        bank_2021_1 = x_RGGI_b_2021_3_1;
                        J_2021_1 = length(supply_data_new_2021_3_1);
                    elseif i==2
                        J = J_2020_2;
                        supply_data = supply_data_new_2020_3_2;
                        gas_gr_temp = new_gr_all_temp_2020_3_2;
                        b_RGGI_b = b_RGGI_b_2020_2;
                        bank_t_1 = bank_2020_2;
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        
                        [supply_data_new_2021_3_2,new_gr_all_temp_2021_3_2,p_star_3_2,d_star_3_2,x_RGGI_b_2021_3_2] = PJM_Model_RGGI_All_Policies_2021(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b,m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                        b_RGGI_b_2021_2 = b_RGGI_b_t + x_RGGI_b_2021_3_2*m_bank_t_1;
                        bank_2021_2 = x_RGGI_b_2021_3_2;
                        J_2021_2 = length(supply_data_new_2021_3_2);
                    elseif i==3
                        J = J_2020_3;
                        supply_data = supply_data_new_2020_3_3;
                        gas_gr_temp = new_gr_all_temp_2020_3_3;
                        b_RGGI_b = b_RGGI_b_2020_3;
                        bank_t_1 = bank_2020_3;
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        
                        [supply_data_new_2021_3_3,new_gr_all_temp_2021_3_3,p_star_3_3,d_star_3_3,x_RGGI_b_2021_3_3] = PJM_Model_RGGI_All_Policies_2021(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b,m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                        b_RGGI_b_2021_3 = b_RGGI_b_t + x_RGGI_b_2021_3_3*m_bank_t_1;
                        bank_2021_3 = x_RGGI_b_2021_3_3;
                        J_2021_3 = length(supply_data_new_2021_3_3);
                    end                                                        
                end    
            end                         
            dr = dr+1;            
        end
        
    % 2022
    elseif sr==3        
        % Supply data input:
        clear supply_data
        clear p_region_all
        clear load_region_all
        clear gas_gr_temp    
        clear b_RGGI_b
        clear bank_t_1
        
        PA_in_RGGI = 0;           % This is the starting case (DO NOT CHANGE)  
        PA_in_RPS = 1;            % This is the starting case (DO NOT CHANGE) 

        % Demand data input:
        load_growth = 0.017083;   

        % RGGI input:
        b_RGGI_b = b_RGGI_b_2021_1;
        bank_t_1 = bank_2021_1;

        dr = 1;
        while dr <= demand_run
            if dr == 1
                supply_data = supply_data_new_2021_3_1;
                gas_gr_temp = new_gr_all_temp_2021_3_1;
                J = J_2021_1;

                demand_curve = strcat(roc,'Demand_Curve_2018.xlsx');
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
                
                load_region_all = load_region_all_1;
                p_region_all = p_region_all_1;
                
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                [supply_data_new_2022_1,new_gr_all_temp_2022_1,p_star_2022,d_star_2022,x_RGGI_b_2022] = PJM_Model_RGGI_All_Policies_2022(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 

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
                
                load_region_all = load_region_all_2;
                p_region_all = p_region_all_2; 

                J = J_2021_1;
                supply_data = supply_data_new_2021_3_1;
                gas_gr_temp = new_gr_all_temp_2021_3_1; 
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                
                [supply_data_new_2022_2,new_gr_all_temp_2022_2,p_star_2,d_star_2,x_RGGI_b_2022] = PJM_Model_RGGI_All_Policies_2022(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
            elseif dr == 3
                load_region_all_3 = load_region_all_2;
                p_region_1 = p_star_2(1,:)';
                p_region_2 = p_star_2(2,:)';
                p_region_3 = p_star_2(3,:)';
                p_region_4 = p_star_2(4,:)';
                p_region_5 = p_star_2(5,:)';  
                p_region_all_3 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
                load_region_all = load_region_all_3;
                p_region_all = p_region_all_3; 
                                                                
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);
                    if policy_sc == 1
                        PA_in_RGGI = 0;
                        PA_in_RPS = 1;
                    elseif policy_sc == 2
                        PA_in_RGGI = 1;
                        PA_in_RPS = 1;
                    elseif policy_sc == 3
                        PA_in_RGGI = 1;
                        PA_in_RPS = 0;
                    end
                    
                    if i==1
                        J = J_2021_1;
                        supply_data = supply_data_new_2021_3_1;
                        gas_gr_temp = new_gr_all_temp_2021_3_1; 
                        b_RGGI_b = b_RGGI_b_2021_1;
                        bank_t_1 = bank_2021_1;
                        e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                        
                        [supply_data_new_2022_3_1,new_gr_all_temp_2022_3_1,p_star_3_1,d_star_3_1,x_RGGI_b_2022_3_1] = PJM_Model_RGGI_All_Policies_2022(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                        b_RGGI_b_2022_1 = b_RGGI_b_t + x_RGGI_b_2022_3_1*m_bank_t_1;
                        bank_2022_1 = x_RGGI_b_2022_3_1;
                        J_2022_1 = length(supply_data_new_2022_3_1);
                    elseif i==2
                        J = J_2021_2;
                        supply_data = supply_data_new_2021_3_2;
                        gas_gr_temp = new_gr_all_temp_2021_3_2;
                        b_RGGI_b = b_RGGI_b_2021_2;
                        bank_t_1 = bank_2021_2;
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        
                        [supply_data_new_2022_3_2,new_gr_all_temp_2022_3_2,p_star_3_2,d_star_3_2,x_RGGI_b_2022_3_2] = PJM_Model_RGGI_All_Policies_2022(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                        b_RGGI_b_2022_2 = b_RGGI_b_t + x_RGGI_b_2022_3_2*m_bank_t_1;
                        bank_2022_2 = x_RGGI_b_2022_3_2;
                        J_2022_2 = length(supply_data_new_2022_3_2);
                    elseif i==3
                        J = J_2021_3;
                        supply_data = supply_data_new_2021_3_3;
                        gas_gr_temp = new_gr_all_temp_2021_3_3;
                        b_RGGI_b = b_RGGI_b_2021_3;
                        bank_t_1 = bank_2021_3;
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        
                        [supply_data_new_2022_3_3,new_gr_all_temp_2022_3_3,p_star_3_3,d_star_3_3,x_RGGI_b_2022_3_3] = PJM_Model_RGGI_All_Policies_2022(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                        b_RGGI_b_2022_3 = b_RGGI_b_t + x_RGGI_b_2022_3_3*m_bank_t_1;
                        bank_2022_3 = x_RGGI_b_2022_3_3;
                        J_2022_3 = length(supply_data_new_2022_3_3);
                    end                                                        
                end    
            end            
        dr = dr+1;            
        end
        
    % 2023
    elseif sr==4        
        % Supply data input:
        clear supply_data
        clear p_region_all
        clear load_region_all
        clear gas_gr_temp 
        clear b_RGGI_b
        clear bank_t_1
        
        PA_in_RGGI = 0;       
        PA_in_RPS = 1;            

        % Demand data input:
        load_growth = 0.021399;   

        % RGGI input:
        b_RGGI_b = b_RGGI_b_2022_1;
        bank_t_1 = bank_2022_1;

        dr = 1;
        while dr <= demand_run
            if dr == 1
                supply_data = supply_data_new_2022_3_1;
                gas_gr_temp = new_gr_all_temp_2022_3_1;
                J = J_2022_1;

                demand_curve = strcat(roc,'Demand_Curve_2018.xlsx');
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
                
                load_region_all = load_region_all_1;
                p_region_all = p_region_all_1;
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                
                [supply_data_new_2023_1,new_gr_all_temp_2023_1,p_star_2023,d_star_2023,x_RGGI_b_2023] = PJM_Model_RGGI_All_Policies_2023(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);

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
                
                load_region_all = load_region_all_2;
                p_region_all = p_region_all_2; 

                J = J_2022_1;
                supply_data = supply_data_new_2022_3_1;
                gas_gr_temp = new_gr_all_temp_2022_3_1; 
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                
                [supply_data_new_2023_2,new_gr_all_temp_2023_2,p_star_2,d_star_2,x_RGGI_b_2023] = PJM_Model_RGGI_All_Policies_2023(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
            elseif dr == 3
                load_region_all_3 = load_region_all_2;
                p_region_1 = p_star_2(1,:)';
                p_region_2 = p_star_2(2,:)';
                p_region_3 = p_star_2(3,:)';
                p_region_4 = p_star_2(4,:)';
                p_region_5 = p_star_2(5,:)';  
                p_region_all_3 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
                load_region_all = load_region_all_3;
                p_region_all = p_region_all_3; 
                
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);
                    if policy_sc == 1
                        PA_in_RGGI = 0;
                        PA_in_RPS = 1;
                    elseif policy_sc == 2
                        PA_in_RGGI = 1;
                        PA_in_RPS = 1;
                    elseif policy_sc == 3
                        PA_in_RGGI = 1;
                        PA_in_RPS = 0;
                    end
                    
                    if i==1
                        J = J_2022_1;
                        supply_data = supply_data_new_2022_3_1;
                        gas_gr_temp = new_gr_all_temp_2022_3_1; 
                        b_RGGI_b = b_RGGI_b_2022_1;
                        bank_t_1 = bank_2022_1;
                        e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                        
                        [supply_data_new_2023_3_1,new_gr_all_temp_2023_3_1,p_star_3_1,d_star_3_1,x_RGGI_b_2023_3_1] = PJM_Model_RGGI_All_Policies_2023(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                        b_RGGI_b_2023_1 = b_RGGI_b_t + x_RGGI_b_2023_3_1*m_bank_t_1;
                        bank_2023_1 = x_RGGI_b_2023_3_1;
                        J_2023_1 = length(supply_data_new_2023_3_1);
                    elseif i==2
                        J = J_2022_2;
                        supply_data = supply_data_new_2022_3_2;
                        gas_gr_temp = new_gr_all_temp_2022_3_2;
                        b_RGGI_b = b_RGGI_b_2022_2;
                        bank_t_1 = bank_2022_2;
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        
                        [supply_data_new_2023_3_2,new_gr_all_temp_2023_3_2,p_star_3_2,d_star_3_2,x_RGGI_b_2023_3_2] = PJM_Model_RGGI_All_Policies_2023(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                        b_RGGI_b_2023_2 = b_RGGI_b_t + x_RGGI_b_2023_3_2*m_bank_t_1;
                        bank_2023_2 = x_RGGI_b_2023_3_2;
                        J_2023_2 = length(supply_data_new_2023_3_2);
                    elseif i==3
                        J = J_2022_3;
                        supply_data = supply_data_new_2022_3_3;
                        gas_gr_temp = new_gr_all_temp_2022_3_3;
                        b_RGGI_b = b_RGGI_b_2022_3;
                        bank_t_1 = bank_2022_3;
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        
                        [supply_data_new_2023_3_3,new_gr_all_temp_2023_3_3,p_star_3_3,d_star_3_3,x_RGGI_b_2023_3_3] = PJM_Model_RGGI_All_Policies_2023(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                        b_RGGI_b_2023_3 = b_RGGI_b_t + x_RGGI_b_2023_3_3*m_bank_t_1;
                        bank_2023_3 = x_RGGI_b_2023_3_3;
                        J_2023_3 = length(supply_data_new_2023_3_3);
                    end                                                        
                end                                 
            end            
        dr = dr+1;            
        end
        
    % 2024:    
    elseif sr==5
        % Supply data input:
        clear supply_data
        clear p_region_all
        clear load_region_all
        clear gas_gr_temp
        clear b_RGGI_b
        clear bank_t_1
        
        PA_in_RGGI = 0;       
        PA_in_RPS = 1;
        
         % Demand data input:
        load_growth = 0.025733; 
        
        % RGGI input:
        b_RGGI_b = b_RGGI_b_2023_1;
        bank_t_1 = bank_2023_1;
    
        dr = 1;
        while dr <= demand_run
            if dr == 1
                supply_data = supply_data_new_2023_3_1;
                gas_gr_temp = new_gr_all_temp_2023_3_1;
                J = J_2023_1;
                
                demand_curve = strcat(roc,'Demand_Curve_2018.xlsx');
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
                
                load_region_all = load_region_all_1;
                p_region_all = p_region_all_1;
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                
                [supply_data_new_2024_1,new_gr_all_temp_2024_1,p_star_2024,d_star_2024,x_RGGI_b_2024] = PJM_Model_RGGI_All_Policies_2024(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                
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
                
                load_region_all = load_region_all_2;
                p_region_all = p_region_all_2; 

                J = J_2023_1;
                supply_data = supply_data_new_2023_3_1;
                gas_gr_temp = new_gr_all_temp_2023_3_1; 
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                
                [supply_data_new_2024_2,new_gr_all_temp_2024_2,p_star_2,d_star_2,x_RGGI_b_2024] = PJM_Model_RGGI_All_Policies_2024(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
            elseif dr == 3
                load_region_all_3 = load_region_all_2;
                p_region_1 = p_star_2(1,:)';
                p_region_2 = p_star_2(2,:)';
                p_region_3 = p_star_2(3,:)';
                p_region_4 = p_star_2(4,:)';
                p_region_5 = p_star_2(5,:)';  
                p_region_all_3 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
                load_region_all = load_region_all_3;
                p_region_all = p_region_all_3; 
                                              
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);
                    if policy_sc == 1
                        PA_in_RGGI = 0;
                        PA_in_RPS = 1;
                    elseif policy_sc == 2
                        PA_in_RGGI = 1;
                        PA_in_RPS = 1;
                    elseif policy_sc == 3
                        PA_in_RGGI = 1;
                        PA_in_RPS = 0;
                    end
                    
                    if i==1
                        J = J_2023_1;
                        supply_data = supply_data_new_2023_3_1;
                        gas_gr_temp = new_gr_all_temp_2023_3_1; 
                        b_RGGI_b = b_RGGI_b_2023_1;
                        bank_t_1 = bank_2023_1;
                        e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                        
                        [supply_data_new_2024_3_1,new_gr_all_temp_2024_3_1,p_star_3_1,d_star_3_1,x_RGGI_b_2024_3_1] = PJM_Model_RGGI_All_Policies_2024(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
                        b_RGGI_b_2024_1 = b_RGGI_b_t + x_RGGI_b_2024_3_1*m_bank_t_1;
                        bank_2024_1 = x_RGGI_b_2024_3_1;
                        J_2024_1 = length(supply_data_new_2024_3_1);
                    elseif i==2
                        J = J_2023_2;
                        supply_data = supply_data_new_2023_3_2;
                        gas_gr_temp = new_gr_all_temp_2023_3_2;
                        b_RGGI_b = b_RGGI_b_2023_2;
                        bank_t_1 = bank_2023_2;
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        
                        [supply_data_new_2024_3_2,new_gr_all_temp_2024_3_2,p_star_3_2,d_star_3_2,x_RGGI_b_2024_3_2] = PJM_Model_RGGI_All_Policies_2024(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
                        b_RGGI_b_2024_2 = b_RGGI_b_t + x_RGGI_b_2024_3_2*m_bank_t_1;
                        bank_2024_2 = x_RGGI_b_2024_3_2;
                        J_2024_2 = length(supply_data_new_2024_3_2);
                    elseif i==3
                        J = J_2023_3;
                        supply_data = supply_data_new_2023_3_3;
                        gas_gr_temp = new_gr_all_temp_2023_3_3;
                        b_RGGI_b = b_RGGI_b_2023_3;
                        bank_t_1 = bank_2023_3;
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        
                        [supply_data_new_2024_3_3,new_gr_all_temp_2024_3_3,p_star_3_3,d_star_3_3,x_RGGI_b_2024_3_3] = PJM_Model_RGGI_All_Policies_2024(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
                        b_RGGI_b_2024_3 = b_RGGI_b_t + x_RGGI_b_2024_3_3*m_bank_t_1;
                        bank_2024_3 = x_RGGI_b_2024_3_3;
                        J_2024_3 = length(supply_data_new_2024_3_3);
                    end                                                        
                end              
            end
            dr = dr+1;            
        end
    % 2025             
    elseif sr==6
        % Supply data input:
        clear supply_data
        clear p_region_all
        clear load_region_all
        clear gas_gr_temp
        clear b_RGGI_b
        clear bank_t_1
        
        PA_in_RGGI = 0;       
        PA_in_RPS = 1;
        
         % Demand data input:
        load_growth = 0.030086;    
        
        % RGGI input:
        b_RGGI_b = b_RGGI_b_2024_1;
        bank_t_1 = bank_2024_1;
        
        dr = 1;
        while dr <= demand_run
            if dr == 1
                supply_data = supply_data_new_2024_3_1;
                gas_gr_temp = new_gr_all_temp_2024_3_1;
                J = J_2024_1;
                
                demand_curve = strcat(roc,'Demand_Curve_2018.xlsx');              
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
                
                load_region_all = load_region_all_1;
                p_region_all = p_region_all_1;
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                
                [supply_data_new_2025_1,new_gr_all_temp_2025_1,p_star_2025,d_star_2025,x_RGGI_b_2025] = PJM_Model_RGGI_All_Policies_2025(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
                
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
                
                load_region_all = load_region_all_2;
                p_region_all = p_region_all_2; 

                J = J_2024_1;
                supply_data = supply_data_new_2024_3_1;
                gas_gr_temp = new_gr_all_temp_2024_3_1; 
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                
                [supply_data_new_2025_2_1,new_gr_all_temp_2025_2,p_star_2,d_star_2,x_RGGI_b_2025] = PJM_Model_RGGI_All_Policies_2025(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
            elseif dr == 3
                load_region_all_3 = load_region_all_2;
                p_region_1 = p_star_2(1,:)';
                p_region_2 = p_star_2(2,:)';
                p_region_3 = p_star_2(3,:)';
                p_region_4 = p_star_2(4,:)';
                p_region_5 = p_star_2(5,:)';  
                p_region_all_3 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
                load_region_all = load_region_all_3;
                p_region_all = p_region_all_3;
                
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);
                    if policy_sc == 1
                        PA_in_RGGI = 0;
                        PA_in_RPS = 1;
                    elseif policy_sc == 2
                        PA_in_RGGI = 1;
                        PA_in_RPS = 1;
                    elseif policy_sc == 3
                        PA_in_RGGI = 1;
                        PA_in_RPS = 0;
                    end
                    
                    if i==1
                        J = J_2024_1;
                        supply_data = supply_data_new_2024_3_1;
                        gas_gr_temp = new_gr_all_temp_2024_3_1; 
                        b_RGGI_b = b_RGGI_b_2024_1;
                        bank_t_1 = bank_2024_1;
                        e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                        
                        [supply_data_new_2025_3_1,new_gr_all_temp_2025_3_1,p_star_3_1,d_star_3_1,x_RGGI_b_2025_3_1] = PJM_Model_RGGI_All_Policies_2025(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
                        b_RGGI_b_2025_1 = b_RGGI_b_t + x_RGGI_b_2025_3_1*m_bank_t_1;
                        bank_2025_1 = x_RGGI_b_2025_3_1;
                        J_2025_1 = length(supply_data_new_2025_3_1);
                    elseif i==2
                        J = J_2024_2;
                        supply_data = supply_data_new_2024_3_2;
                        gas_gr_temp = new_gr_all_temp_2024_3_2;
                        b_RGGI_b = b_RGGI_b_2024_2;
                        bank_t_1 = bank_2024_2;
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        
                        [supply_data_new_2025_3_2,new_gr_all_temp_2025_3_2,p_star_3_2,d_star_3_2,x_RGGI_b_2025_3_2] = PJM_Model_RGGI_All_Policies_2025(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
                        b_RGGI_b_2025_2 = b_RGGI_b_t + x_RGGI_b_2025_3_2*m_bank_t_1;
                        bank_2025_2 = x_RGGI_b_2025_3_2;
                        J_2025_2 = length(supply_data_new_2025_3_2);
                    elseif i==3
                        J = J_2024_3;
                        supply_data = supply_data_new_2024_3_3;
                        gas_gr_temp = new_gr_all_temp_2024_3_3;
                        b_RGGI_b = b_RGGI_b_2024_3;
                        bank_t_1 = bank_2024_3;
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        
                        [supply_data_new_2025_3_3,new_gr_all_temp_2025_3_3,p_star_3_3,d_star_3_3,x_RGGI_b_2025_3_3] = PJM_Model_RGGI_All_Policies_2025(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
                        b_RGGI_b_2025_3 = b_RGGI_b_t + x_RGGI_b_2025_3_3*m_bank_t_1;
                        bank_2025_3 = x_RGGI_b_2025_3_3;
                        J_2025_3 = length(supply_data_new_2025_3_3);
                    end                                                        
                end           
            end                       
            dr = dr+1;            
        end
    % 2026    
    elseif sr==7
        % Supply data input:
        clear supply_data
        clear p_region_all
        clear load_region_all
        clear gas_gr_temp
        clear b_RGGI_b
        clear bank_t_1
        
        PA_in_RGGI = 0;       
        PA_in_RPS = 1;
        
         % Demand data input:
        load_growth = 0.03446;  
        
        % RGGI input:
        b_RGGI_b = b_RGGI_b_2025_1;
        bank_t_1 = bank_2025_1;
        
        dr = 1;
        while dr <= demand_run
            if dr == 1
                supply_data = supply_data_new_2025_3_1;
                gas_gr_temp = new_gr_all_temp_2025_3_1;
                J = J_2025_1;
                
                demand_curve = strcat(roc,'Demand_Curve_2018.xlsx');            
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
                
                load_region_all = load_region_all_1;
                p_region_all = p_region_all_1;
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                
                [supply_data_new_2026_1,new_gr_all_temp_2026_1,p_star_2026,d_star_2026,x_RGGI_b_2026] = PJM_Model_RGGI_All_Policies_2026(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
                
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
                
                load_region_all = load_region_all_2;
                p_region_all = p_region_all_2; 

                J = J_2025_1;
                supply_data = supply_data_new_2025_3_1;
                gas_gr_temp = new_gr_all_temp_2025_3_1; 
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                
                [supply_data_new_2026_2,new_gr_all_temp_2026_2,p_star_2,d_star_2,x_RGGI_b_2026] = PJM_Model_RGGI_All_Policies_2026(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
            elseif dr == 3
                load_region_all_3 = load_region_all_2;
                p_region_1 = p_star_2(1,:)';
                p_region_2 = p_star_2(2,:)';
                p_region_3 = p_star_2(3,:)';
                p_region_4 = p_star_2(4,:)';
                p_region_5 = p_star_2(5,:)';  
                p_region_all_3 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
                load_region_all = load_region_all_3;
                p_region_all = p_region_all_3; 
                
                
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);
                    if policy_sc == 1
                        PA_in_RGGI = 0;
                        PA_in_RPS = 1;
                    elseif policy_sc == 2
                        PA_in_RGGI = 1;
                        PA_in_RPS = 1;
                    elseif policy_sc == 3
                        PA_in_RGGI = 1;
                        PA_in_RPS = 0;
                    end
                    
                    if i==1
                        J = J_2025_1;
                        supply_data = supply_data_new_2025_3_1;
                        gas_gr_temp = new_gr_all_temp_2025_3_1; 
                        b_RGGI_b = b_RGGI_b_2025_1;
                        bank_t_1 = bank_2025_1;
                        e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                        
                        [supply_data_new_2026_3_1,new_gr_all_temp_2026_3_1,p_star_3_1,d_star_3_1,x_RGGI_b_2026_3_1] = PJM_Model_RGGI_All_Policies_2026(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                        b_RGGI_b_2026_1 = b_RGGI_b_t + x_RGGI_b_2026_3_1*m_bank_t_1;
                        bank_2026_1 = x_RGGI_b_2026_3_1;
                        J_2026_1 = length(supply_data_new_2026_3_1);
                    elseif i==2
                        J = J_2025_2;
                        supply_data = supply_data_new_2025_3_2;
                        gas_gr_temp = new_gr_all_temp_2025_3_2;
                        b_RGGI_b = b_RGGI_b_2025_2;
                        bank_t_1 = bank_2025_2;
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        
                        [supply_data_new_2026_3_2,new_gr_all_temp_2026_3_2,p_star_3_2,d_star_3_2,x_RGGI_b_2026_3_2] = PJM_Model_RGGI_All_Policies_2026(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
                        b_RGGI_b_2026_2 = b_RGGI_b_t + x_RGGI_b_2026_3_2*m_bank_t_1;
                        bank_2026_2 = x_RGGI_b_2026_3_2;
                        J_2026_2 = length(supply_data_new_2026_3_2);
                    elseif i==3
                        J = J_2025_3;
                        supply_data = supply_data_new_2025_3_3;
                        gas_gr_temp = new_gr_all_temp_2025_3_3;
                        b_RGGI_b = b_RGGI_b_2025_3;
                        bank_t_1 = bank_2025_3;
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        
                        [supply_data_new_2026_3_3,new_gr_all_temp_2026_3_3,p_star_3_3,d_star_3_3,x_RGGI_b_2026_3_3] = PJM_Model_RGGI_All_Policies_2026(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                        b_RGGI_b_2026_3 = b_RGGI_b_t + x_RGGI_b_2026_3_3*m_bank_t_1;
                        bank_2026_3 = x_RGGI_b_2026_3_3;
                        J_2026_3 = length(supply_data_new_2026_3_3);
                    end                                                        
                end           
            end
            dr = dr+1;     
        end
    % 2027    
    elseif sr==8
        % Supply data input:
        clear supply_data
        clear p_region_all
        clear load_region_all
        clear gas_gr_temp
        clear b_RGGI_b
        clear bank_t_1
        
        PA_in_RGGI = 0;       
        PA_in_RPS = 1;
        
         % Demand data input:
        load_growth = 0.03885; 
        
        % RGGI input:
        b_RGGI_b = b_RGGI_b_2026_1;
        bank_t_1 = bank_2026_1;
        
        dr = 1;
        while dr <= demand_run
            if dr == 1
                supply_data = supply_data_new_2026_3_1;
                gas_gr_temp = new_gr_all_temp_2026_3_1;
                J = J_2026_1;
                
                demand_curve = strcat(roc,'Demand_Curve_2018.xlsx');              
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
                
                load_region_all = load_region_all_1;
                p_region_all = p_region_all_1;
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                
                [supply_data_new_2027_1,new_gr_all_temp_2027_1,p_star_2027,d_star_2027,x_RGGI_b_2027] = PJM_Model_RGGI_All_Policies_2027(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                
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
                
                load_region_all = load_region_all_2;
                p_region_all = p_region_all_2; 

                J = J_2026_1;
                supply_data = supply_data_new_2026_3_1;
                gas_gr_temp = new_gr_all_temp_2026_3_1; 
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                
                [supply_data_new_2027_2,new_gr_all_temp_2027_2,p_star_2,d_star_2,x_RGGI_b_2027] = PJM_Model_RGGI_All_Policies_2027(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
            elseif dr == 3
                load_region_all_3 = load_region_all_2;
                p_region_1 = p_star_2(1,:)';
                p_region_2 = p_star_2(2,:)';
                p_region_3 = p_star_2(3,:)';
                p_region_4 = p_star_2(4,:)';
                p_region_5 = p_star_2(5,:)';  
                p_region_all_3 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
                load_region_all = load_region_all_3;
                p_region_all = p_region_all_3;
                
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);
                    if policy_sc == 1
                        PA_in_RGGI = 0;
                        PA_in_RPS = 1;
                    elseif policy_sc == 2
                        PA_in_RGGI = 1;
                        PA_in_RPS = 1;
                    elseif policy_sc == 3
                        PA_in_RGGI = 1;
                        PA_in_RPS = 0;
                    end
                    
                    if i==1
                        J = J_2026_1;
                        supply_data = supply_data_new_2026_3_1;
                        gas_gr_temp = new_gr_all_temp_2026_3_1; 
                        b_RGGI_b = b_RGGI_b_2026_1;
                        bank_t_1 = bank_2026_1;
                        e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                        
                        [supply_data_new_2027_3_1,new_gr_all_temp_2027_3_1,p_star_3_1,d_star_3_1,x_RGGI_b_2027_3_1] = PJM_Model_RGGI_All_Policies_2027(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                        b_RGGI_b_2027_1 = b_RGGI_b_t + x_RGGI_b_2027_3_1*m_bank_t_1;
                        bank_2027_1 = x_RGGI_b_2027_3_1;
                        J_2027_1 = length(supply_data_new_2027_3_1);
                    elseif i==2
                        J = J_2026_2;
                        supply_data = supply_data_new_2026_3_2;
                        gas_gr_temp = new_gr_all_temp_2026_3_2;
                        b_RGGI_b = b_RGGI_b_2026_2;
                        bank_t_1 = bank_2026_2;
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        
                        [supply_data_new_2027_3_2,new_gr_all_temp_2027_3_2,p_star_3_2,d_star_3_2,x_RGGI_b_2027_3_2] = PJM_Model_RGGI_All_Policies_2027(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                        b_RGGI_b_2027_2 = b_RGGI_b_t + x_RGGI_b_2027_3_2*m_bank_t_1;
                        bank_2027_2 = x_RGGI_b_2027_3_2;
                        J_2027_2 = length(supply_data_new_2027_3_2);
                    elseif i==3
                        J = J_2026_3;
                        supply_data = supply_data_new_2026_3_3;
                        gas_gr_temp = new_gr_all_temp_2026_3_3;
                        b_RGGI_b = b_RGGI_b_2026_3;
                        bank_t_1 = bank_2026_3;
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        
                        [supply_data_new_2027_3_3,new_gr_all_temp_2027_3_3,p_star_3_3,d_star_3_3,x_RGGI_b_2027_3_3] = PJM_Model_RGGI_All_Policies_2027(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                        b_RGGI_b_2027_3 = b_RGGI_b_t + x_RGGI_b_2027_3_3*m_bank_t_1;
                        bank_2027_3 = x_RGGI_b_2027_3_3;
                        J_2027_3 = length(supply_data_new_2027_3_3);
                    end                                                        
                end           
            end
            dr = dr+1;     
        end
    % 2028    
    elseif sr==9
        % Supply data input:
        clear supply_data
        clear p_region_all
        clear load_region_all
        clear gas_gr_temp
        clear b_RGGI_b
        clear bank_t_1
        
        PA_in_RGGI = 0;       
        PA_in_RPS = 1;
        
         % Demand data input:
        load_growth = 0.0433; 
        
        % RGGI input:
        b_RGGI_b = b_RGGI_b_2027_1;
        bank_t_1 = bank_2027_1;
        
        dr = 1;
        while dr <= demand_run
            if dr == 1
                supply_data = supply_data_new_2027_3_1;
                gas_gr_temp = new_gr_all_temp_2027_3_1;
                J = J_2027_1;
                
                demand_curve = strcat(roc,'Demand_Curve_2018.xlsx');
                
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
                
                load_region_all = load_region_all_1;
                p_region_all = p_region_all_1;
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                
                [supply_data_new_2028_1,new_gr_all_temp_2028_1,p_star_2028,d_star_2028,x_RGGI_b_2028] = PJM_Model_RGGI_All_Policies_2028(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                
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
                
                load_region_all = load_region_all_2;
                p_region_all = p_region_all_2; 

                J = J_2027_1;
                supply_data = supply_data_new_2027_3_1;
                gas_gr_temp = new_gr_all_temp_2027_3_1; 
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                
                [supply_data_new_2028_2,new_gr_all_temp_2028_2,p_star_2,d_star_2,x_RGGI_b_2028] = PJM_Model_RGGI_All_Policies_2028(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
            elseif dr == 3
                load_region_all_3 = load_region_all_2;
                p_region_1 = p_star_2(1,:)';
                p_region_2 = p_star_2(2,:)';
                p_region_3 = p_star_2(3,:)';
                p_region_4 = p_star_2(4,:)';
                p_region_5 = p_star_2(5,:)';  
                p_region_all_3 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
                load_region_all = load_region_all_3;
                p_region_all = p_region_all_3; 
                
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);
                    if policy_sc == 1
                        PA_in_RGGI = 0;
                        PA_in_RPS = 1;
                    elseif policy_sc == 2
                        PA_in_RGGI = 1;
                        PA_in_RPS = 1;
                    elseif policy_sc == 3
                        PA_in_RGGI = 1;
                        PA_in_RPS = 0;
                    end
                    
                    if i==1
                        J = J_2027_1;
                        supply_data = supply_data_new_2027_3_1;
                        gas_gr_temp = new_gr_all_temp_2027_3_1; 
                        b_RGGI_b = b_RGGI_b_2027_1;
                        bank_t_1 = bank_2027_1;
                        e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                        
                        [supply_data_new_2028_3_1,new_gr_all_temp_2028_3_1,p_star_3_1,d_star_3_1,x_RGGI_b_2028_3_1] = PJM_Model_RGGI_All_Policies_2028(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                        b_RGGI_b_2028_1 = b_RGGI_b_t + x_RGGI_b_2028_3_1*m_bank_t_1;
                        bank_2028_1 = x_RGGI_b_2028_3_1;
                        J_2028_1 = length(supply_data_new_2028_3_1);
                    elseif i==2
                        J = J_2027_2;
                        supply_data = supply_data_new_2027_3_2;
                        gas_gr_temp = new_gr_all_temp_2027_3_2;
                        b_RGGI_b = b_RGGI_b_2027_2;
                        bank_t_1 = bank_2027_2;
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        
                        [supply_data_new_2028_3_2,new_gr_all_temp_2028_3_2,p_star_3_2,d_star_3_2,x_RGGI_b_2028_3_2] = PJM_Model_RGGI_All_Policies_2028(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                        b_RGGI_b_2028_2 = b_RGGI_b_t + x_RGGI_b_2028_3_2*m_bank_t_1;
                        bank_2028_2 = x_RGGI_b_2028_3_2;
                        J_2028_2 = length(supply_data_new_2028_3_2);
                    elseif i==3
                        J = J_2027_3;
                        supply_data = supply_data_new_2027_3_3;
                        gas_gr_temp = new_gr_all_temp_2027_3_3;
                        b_RGGI_b = b_RGGI_b_2027_3;
                        bank_t_1 = bank_2027_3;
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        
                        [supply_data_new_2028_3_3,new_gr_all_temp_2028_3_3,p_star_3_3,d_star_3_3,x_RGGI_b_2028_3_3] = PJM_Model_RGGI_All_Policies_2028(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                        b_RGGI_b_2028_3 = b_RGGI_b_t + x_RGGI_b_2028_3_3*m_bank_t_1;
                        bank_2028_3 = x_RGGI_b_2028_3_3;
                        J_2028_3 = length(supply_data_new_2028_3_3);
                    end                                                        
                end                           
            end
            dr = dr+1;     
        end
    % 2029
    elseif sr==10
        % Supply data input:
        clear supply_data
        clear p_region_all
        clear load_region_all
        clear gas_gr_temp
        clear b_RGGI_b
        clear bank_t_1
        
        PA_in_RGGI = 0;       
        PA_in_RPS = 1;
        
         % Demand data input:
        load_growth = 0.047683;  
        
        % RGGI input:
        b_RGGI_b = b_RGGI_b_2028_1;
        bank_t_1 = bank_2028_1;
        
        dr = 1;
        while dr <= demand_run
            if dr == 1
                supply_data = supply_data_new_2028_3_1;
                gas_gr_temp = new_gr_all_temp_2028_3_1;
                J = J_2028_1;
                
                demand_curve = strcat(roc,'Demand_Curve_2018.xlsx');             
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
                
                load_region_all = load_region_all_1;
                p_region_all = p_region_all_1;
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                
                [supply_data_new_2029_1,new_gr_all_temp_2029_1,p_star_2029,d_star_2029,x_RGGI_b_2029] = PJM_Model_RGGI_All_Policies_2029(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
                
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
                
                load_region_all = load_region_all_2;
                p_region_all = p_region_all_2; 

                J = J_2028_1;
                supply_data = supply_data_new_2028_3_1;
                gas_gr_temp = new_gr_all_temp_2028_3_1; 
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                
                [supply_data_new_2029_2,new_gr_all_temp_2029_2,p_star_2,d_star_2,x_RGGI_b_2029] = PJM_Model_RGGI_All_Policies_2029(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 

            elseif dr == 3
                load_region_all_3 = load_region_all_2;
                p_region_1 = p_star_2(1,:)';
                p_region_2 = p_star_2(2,:)';
                p_region_3 = p_star_2(3,:)';
                p_region_4 = p_star_2(4,:)';
                p_region_5 = p_star_2(5,:)';  
                p_region_all_3 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
                load_region_all = load_region_all_3;
                p_region_all = p_region_all_3;
                
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);
                    if policy_sc == 1
                        PA_in_RGGI = 0;
                        PA_in_RPS = 1;
                    elseif policy_sc == 2
                        PA_in_RGGI = 1;
                        PA_in_RPS = 1;
                    elseif policy_sc == 3
                        PA_in_RGGI = 1;
                        PA_in_RPS = 0;
                    end
                    
                    if i==1
                        J = J_2028_1;
                        supply_data = supply_data_new_2028_3_1;
                        gas_gr_temp = new_gr_all_temp_2028_3_1; 
                        b_RGGI_b = b_RGGI_b_2028_1;
                        bank_t_1 = bank_2028_1;
                        e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                        
                        [supply_data_new_2029_3_1,new_gr_all_temp_2029_3_1,p_star_3_1,d_star_3_1,x_RGGI_b_2029_3_1] = PJM_Model_RGGI_All_Policies_2029(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                        b_RGGI_b_2029_1 = b_RGGI_b_t + x_RGGI_b_2029_3_1*m_bank_t_1;
                        bank_2029_1 = x_RGGI_b_2029_3_1;
                        J_2029_1 = length(supply_data_new_2029_3_1);
                    elseif i==2
                        J = J_2028_2;
                        supply_data = supply_data_new_2028_3_2;
                        gas_gr_temp = new_gr_all_temp_2028_3_2;
                        b_RGGI_b = b_RGGI_b_2028_2;
                        bank_t_1 = bank_2028_2;
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        
                        [supply_data_new_2029_3_2,new_gr_all_temp_2029_3_2,p_star_3,d_star_3_2,x_RGGI_b_2029_3_2] = PJM_Model_RGGI_All_Policies_2029(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                        b_RGGI_b_2029_2 = b_RGGI_b_t + x_RGGI_b_2029_3_2*m_bank_t_1;
                        bank_2029_2 = x_RGGI_b_2029_3_2;
                        J_2029_2 = length(supply_data_new_2029_3_2);
                    elseif i==3
                        J = J_2028_3;
                        supply_data = supply_data_new_2028_3_3;
                        gas_gr_temp = new_gr_all_temp_2028_3_3;
                        b_RGGI_b = b_RGGI_b_2028_3;
                        bank_t_1 = bank_2028_3;
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        
                        [supply_data_new_2029_3_3,new_gr_all_temp_2029_3_3,p_star_3_3,d_star_3_3,x_RGGI_b_2029_3_3] = PJM_Model_RGGI_All_Policies_2029(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA);
                        b_RGGI_b_2029_3 = b_RGGI_b_t + x_RGGI_b_2029_3_3*m_bank_t_1;
                        bank_2029_3 = x_RGGI_b_2029_3_3;
                        J_2029_3 = length(supply_data_new_2029_3_3);
                    end                                                        
                end        
            end
            dr = dr+1;     
        end
    % 2030
    elseif sr==11
        % Supply data input:
        clear supply_data
        clear p_region_all
        clear load_region_all
        clear gas_gr_temp
        clear b_RGGI_b
        clear bank_t_1
        
        PA_in_RGGI = 0;       
        PA_in_RPS = 1;
        
         % Demand data input:
        load_growth = 0.05213;
        
        % RGGI input:
        b_RGGI_b = b_RGGI_b_2029_1;
        bank_t_1 = bank_2029_1;
        
        dr = 1;
        while dr <= demand_run
            if dr == 1
                supply_data = supply_data_new_2029_3_1;
                gas_gr_temp = new_gr_all_temp_2029_3_1;
                J = J_2029_1;
                
                demand_curve = strcat(roc,'Demand_Curve_2018.xlsx');
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
                
                load_region_all = load_region_all_1;
                p_region_all = p_region_all_1;
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                
                [supply_data_new_2030_1,new_gr_all_temp_2030_1,p_star_2030,d_star_2030,x_RGGI_b_2030] = PJM_Model_RGGI_All_Policies_2030(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
                
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
                
                load_region_all = load_region_all_2;
                p_region_all = p_region_all_2; 

                J = J_2029_1;
                supply_data = supply_data_new_2029_3_1;
                gas_gr_temp = new_gr_all_temp_2029_3_1; 
                e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                
                [supply_data_new_2030_2,new_gr_all_temp_2030_2,p_star_2,d_star_2,x_RGGI_b_2030] = PJM_Model_RGGI_All_Policies_2030(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 

            elseif dr == 3
                load_region_all_3 = load_region_all_2;
                p_region_1 = p_star_2(1,:)';
                p_region_2 = p_star_2(2,:)';
                p_region_3 = p_star_2(3,:)';
                p_region_4 = p_star_2(4,:)';
                p_region_5 = p_star_2(5,:)';  
                p_region_all_3 = [p_region_1,p_region_2,p_region_3,p_region_4,p_region_5];
                
                load_region_all = load_region_all_3;
                p_region_all = p_region_all_3; 
                
                
                for i = 1:3                    
                    policy_sc = policy_sc_all(i);
                    if policy_sc == 1
                        PA_in_RGGI = 0;
                        PA_in_RPS = 1;
                    elseif policy_sc == 2
                        PA_in_RGGI = 1;
                        PA_in_RPS = 1;
                    elseif policy_sc == 3
                        PA_in_RGGI = 1;
                        PA_in_RPS = 0;
                    end
                    
                    if i==1
                        J = J_2029_1;
                        supply_data = supply_data_new_2029_3_1;
                        gas_gr_temp = new_gr_all_temp_2029_3_1; 
                        b_RGGI_b = b_RGGI_b_2029_1;
                        bank_t_1 = bank_2029_1;
                        e_bar_RGGI = e_bar_RGGI_data_noPA(sr)*metric_convert;
                        
                        [supply_data_new_2030_3_1,new_gr_all_temp_2030_3_1,p_star_3_1,d_star_3_1,x_RGGI_b_2030_3_1] = PJM_Model_RGGI_All_Policies_2030(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
                        b_RGGI_b_2030_1 = b_RGGI_b_t + x_RGGI_b_2030_3_1*m_bank_t_1;
                        bank_2030_1 = x_RGGI_b_2030_3_1;
                        J_2030_1 = length(supply_data_new_2030_3_1);
                    elseif i==2
                        J = J_2029_2;
                        supply_data = supply_data_new_2029_3_2;
                        gas_gr_temp = new_gr_all_temp_2029_3_2;
                        b_RGGI_b = b_RGGI_b_2029_2;
                        bank_t_1 = bank_2029_2;
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        
                        [supply_data_new_2030_3_2,new_gr_all_temp_2030_3_2,p_star_3_2,d_star_3_2,x_RGGI_b_2030_3_2] = PJM_Model_RGGI_All_Policies_2030(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
                        b_RGGI_b_2030_2 = b_RGGI_b_t + x_RGGI_b_2030_3_2*m_bank_t_1;
                        bank_2030_2 = x_RGGI_b_2030_3_2;
                        J_2030_2 = length(supply_data_new_2030_3_2);
                    elseif i==3
                        J = J_2029_3;
                        supply_data = supply_data_new_2029_3_3;
                        gas_gr_temp = new_gr_all_temp_2029_3_3;
                        b_RGGI_b = b_RGGI_b_2029_3;
                        bank_t_1 = bank_2029_3;
                        e_bar_RGGI = e_bar_RGGI_data_withPA(sr)*metric_convert;
                        
                        [supply_data_new_2030_3_3,new_gr_all_temp_2030_3_3,p_star_3_3,d_star_3_3,x_RGGI_b_2030_3_3] = PJM_Model_RGGI_All_Policies_2030(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,ext_rec_sc,p_region_all,load_region_all,supply_data,gas_gr_temp,hours,run_on_cluster,b_RGGI_nonPJM,m_RGGI_nonPJM,e_bar_RGGI,bank_t_1,b_RGGI_b, m_RGGI_b,PA_in_RGGI,PA_in_RPS,with_VA); 
                        b_RGGI_b_2030_3 = b_RGGI_b_t + x_RGGI_b_2030_3_3*m_bank_t_1;
                        bank_2030_3 = x_RGGI_b_2030_3_3;
                        J_2030_3 = length(supply_data_new_2030_3_3);
                    end                                                        
                end        
            end            
            dr = dr+1;     
        end
    end
    
    sr = sr+1;   
                                              
end
    


