% PJM Electricity Model for 5 nodes.
% 2022
% With Cumulative Emission Cap
% Finished coding on 10/24/2019 by An Pham.

function [supply_data_new_2022,new_gr_all_temp_2022,p_star,d_star] = PJM_Electricity_Model_MB_2022(I,J,T,F,J_r,S,dr,trans_const,rps_const,cap_exp,policy_sc,ext_rec_sc,p_region_all,load_region_all,supply_data,rps_data,hours)  

%**********************************************
%% Define Parameters and variables:
%**********************************************
state_e_bar_data = 'C:/Users/atpha/Documents/Research/PJM Model/Input Data/State Emission Caps/Mass-Based in PJM.xlsx';
state_e_bar = xlsread(state_e_bar_data,'State Cap');

e_PA = 90111436;          % Allocated emission permits in PA (1000 metric tons)
e_RPJM = state_e_bar(15,1);       % Allocated emission permits in RPJM (1000 metric tons)

etaD_t = [0.000001;0.000001;0.05];              % Assumed elasticity of demand
etaD = etaD_t(dr);
tot_loss_pct = 0.03412764857;  % Assume transmission lost % in the distribution system.
gas_gr_data_2022 = 'C:/Users/atpha/Documents/Research/PJM Model/Input Data/Gas price growth rates/gas_gr_2022.xlsx';
gr_path_nj = 1;

% Growth Rate:
gas_gr_temp = xlsread(gas_gr_data_2022,'Sheet1');
gas_gr = gas_gr_temp(:,1:T)*(1+0.1218);
oil_gr = 0.196465782*(1+0.5393);
coal_gr = 0.11*(1+0.0202);
nuclear_gr = 0.0077;
bio_gr = -0.2;

cf_gr_hydro = 0.08;
cf_gr_wind = 0.024;
cf_gr_solar = 0.12;
cf_gr_nuclear = 0.029;

% Capacity Expansion Parameters:
C_N_PA = [72900;165500*(1-0.0170)^4;135000*(1-0.0219)^4];
C_N_RPJM = [73900;165500*(1-0.0170)^4;130000*(1-0.0219)^4];
C_N = [C_N_RPJM;C_N_RPJM;C_N_RPJM;C_N_RPJM;C_N_RPJM;C_N_RPJM;C_N_RPJM;C_N_RPJM;C_N_RPJM;C_N_RPJM;C_N_PA;C_N_RPJM;C_N_RPJM;C_N_RPJM];

% Marginal cost:
MC_N_PA = [21.1*(1+0.1218);0;0];
MC_N_RPJM = [24.2*(1+0.1218);0;0];
MC_N = [MC_N_RPJM;MC_N_RPJM;MC_N_RPJM;MC_N_RPJM;MC_N_RPJM;MC_N_RPJM;MC_N_RPJM;MC_N_RPJM;MC_N_RPJM;MC_N_RPJM;MC_N_PA;MC_N_RPJM;MC_N_RPJM;MC_N_RPJM];

% Capacity factor of new units:
avail_g = 0.961;
avail_w = 0.295;
avail_s = 0.17;
avail_N = [avail_g;avail_w;avail_s];

% Percentage of total ext REC supply available to use by state:
if ext_rec_sc == 1
   rec_PA_g_sc = 0.615;
   rec_RPJM_g_sc = 0.814*1.08;
elseif ext_rec_sc ==2
   rec_PA_g_sc = 0.615*1.6142;
   rec_RPJM_g_sc = 0.814*1.08*1.0589;
end
	  	  	  	
% RPS data:
if rps_const == 1
   re_1_tier_1 = 0.20;                                % RPS standard for DC - tier 1
   re_1_tier_2 = 0;                                   % RPS standard for DC - tier 2

   re_2_tier_1 = 0.22;                                % RPS standard for DE
   re_2_tier_2 = 0;                                   % RPS standard for DE

   re_3_tier_1 = 0.19;                                % RPS standard for IL
   re_3_tier_2 = 0;                                   % RPS standard for IL

   re_4_tier_1 = 0.07;                                % RPS standard for IN
   re_4_tier_2 = 0;                                   % RPS standard for IN

   re_5_no_tier = 0;                                  % RPS standard for KY

   re_6_tier_1 = 0.25;                                % RPS standard for MD tier 1
   re_6_tier_2 = 0;                               	  % RPS standard for MD tier 2

   re_7_tier_1 = 0.150;                               % RPS standard for MI
   re_7_tier_2 = 0;                                   % RPS standard for MI

   re_8_tier_1 = 0.125;                               % RPS standard for NC
   re_8_tier_2 = 0;                                   % RPS standard for NC

if gr_path_nj==1
   re_9_tier_1 = 0.245;
else
   re_9_tier_1 = 0.210;                               % RPS standard for NJ tier 1
end

   re_9_tier_2 = 0.025;                               % RPS standard for NJ tier 2

   re_10_tier_1 = 0.085;                              % RPS standard for OH
   re_10_tier_2 = 0;                                  % RPS standard for OH

   re_11_tier_1 = 0.080;                              % RPS standard for PA tier 1
   re_11_tier_2 = 0.10;                               % RPS standard for PA tier 2

   re_12_no_tier = 0;                                 % RPS standard for TN
   re_13_no_tier = 0;                                 % RPS standard for VA
   re_14_no_tier = 0;                                 % RPS standard for WV

   % SREC:
   se_1 = 0.0218;                                     % solar standard for DC
   se_2 = 0.0275;                                     % solar standard for DE
   se_3 = 0.0114;                                     % solar standard for IL
   se_4 = 0;                                          % solar standard for IN
   se_5 = 0;                                          % solar standard for KY
   se_6 = 0.025;                                      % solar standard for MD
   se_7 = 0;                                          % solar standard for MI
   se_8 = 0.0020;                                     % solar standard for NC
   se_9 = 0.051;                                      % solar standard for NJ
   se_10 = 0.0034;                                    % solar standard for OH
   se_11 = 0.0050;                                    % solar standard for PA
   se_12 = 0;                                         % solar standard for TN
   se_13 = 0;                                         % solar standard for VA
   se_14 = 0;                                         % solar standard for WV

   re_tier_1 = [re_1_tier_1;re_2_tier_1;re_3_tier_1;re_4_tier_1;re_5_no_tier;re_6_tier_1;re_7_tier_1;re_8_tier_1;re_9_tier_1;re_10_tier_1;re_11_tier_1;re_12_no_tier;re_13_no_tier;re_14_no_tier];
   re_tier_2 = [re_1_tier_2;re_2_tier_2;re_3_tier_2;re_4_tier_2;re_5_no_tier;re_6_tier_2;re_7_tier_2;re_8_tier_2;re_9_tier_2;re_10_tier_2;re_11_tier_2;re_12_no_tier;re_13_no_tier;re_14_no_tier];
   se = [se_1;se_2;se_3;se_4;se_5;se_6;se_7;se_8;se_9;se_10;se_11;se_12;se_13;se_14];
elseif rps_const==0
    re_tier_1 = zeros(14,1);
    re_tier_2 = zeros(14,1);
    se = zeros(14,1);
end

lg = 0.017083;

% Adding generation for states that are half outside of PJM:
x_gen_tot_DC = 0;
x_gen_tot_DE = 0;
x_gen_tot_IL = 97584668*(1+lg);
x_gen_tot_IN = 93556369*(1+lg);
x_gen_tot_KY = 67283806*(1+lg);
x_gen_tot_MD = 0;
x_gen_tot_MI = 92436894*(1+lg);
x_gen_tot_NC = 128208602*(1+lg);
x_gen_tot_NJ = 0;
x_gen_tot_OH = 0;
x_gen_tot_PA = 0;
x_gen_tot_TN = 78868763*(1+lg);
x_gen_tot_VA = 0;
x_gen_tot_WV = 0;

x_gen_tier1_DC = 0;
x_gen_tier1_DE = 0;
x_gen_tier1_IL = 4486290*(1+lg);
x_gen_tier1_IN = 1678770*(1+lg);
x_gen_tier1_KY = 3535757*(1+lg);
x_gen_tier1_MD = 0;
x_gen_tier1_MI = 8747953*(1+lg);
x_gen_tier1_NC = 9311657*(1+lg);
x_gen_tier1_NJ = 0;
x_gen_tier1_OH = 0;
x_gen_tier1_PA = 0;
x_gen_tier1_TN = 7823792*(1+lg);
x_gen_tier1_VA = 0;
x_gen_tier1_WV = 0;

x_gen_tier2_DC = 0;
x_gen_tier2_DE = 0;
x_gen_tier2_IL = 0;
x_gen_tier2_IN = 0;
x_gen_tier2_KY = 0;
x_gen_tier2_MD = 0;
x_gen_tier2_MI = 0;
x_gen_tier2_NC = 0;
x_gen_tier2_NJ = 0;
x_gen_tier2_OH = 0;
x_gen_tier2_PA = 0;
x_gen_tier2_TN = 0;
x_gen_tier2_VA = 0;
x_gen_tier2_WV = 0;

x_gen_solar_DC = 0;
x_gen_solar_DE = 0;
x_gen_solar_IL = 34610*(1+lg);
x_gen_solar_IN = 218641*(1+lg);
x_gen_solar_KY = 11732*(1+lg);
x_gen_solar_MD = 0;
x_gen_solar_MI = 9235*(1+lg);
x_gen_solar_NC = 3101628*(1+lg);
x_gen_solar_NJ = 0;
x_gen_solar_OH = 0;
x_gen_solar_PA = 0;
x_gen_solar_TN = 78617*(1+lg);
x_gen_solar_VA = 0;
x_gen_solar_WV = 0;

x_gen_tot = [x_gen_tot_DC;x_gen_tot_DE;x_gen_tot_IL;x_gen_tot_IN;x_gen_tot_KY;x_gen_tot_MD;x_gen_tot_MI;x_gen_tot_NC;x_gen_tot_NJ;x_gen_tot_OH;x_gen_tot_PA;x_gen_tot_TN;x_gen_tot_VA;x_gen_tot_WV];
x_gen_tier1 = [x_gen_tier1_DC;x_gen_tier1_DE;x_gen_tier1_IL;x_gen_tier1_IN;x_gen_tier1_KY;x_gen_tier1_MD;x_gen_tier1_MI;x_gen_tier1_NC;x_gen_tier1_NJ;x_gen_tier1_OH;x_gen_tier1_PA;x_gen_tier1_TN;x_gen_tier1_VA;x_gen_tier1_WV];
x_gen_tier2 = [x_gen_tier2_DC;x_gen_tier2_DE;x_gen_tier2_IL;x_gen_tier2_IN;x_gen_tier2_KY;x_gen_tier2_MD;x_gen_tier2_MI;x_gen_tier2_NC;x_gen_tier2_NJ;x_gen_tier2_OH;x_gen_tier2_PA;x_gen_tier2_TN;x_gen_tier2_VA;x_gen_tier2_WV];
x_gen_solar = [x_gen_solar_DC;x_gen_solar_DE;x_gen_solar_IL;x_gen_solar_IN;x_gen_solar_KY;x_gen_solar_MD;x_gen_solar_MI;x_gen_solar_NC;x_gen_solar_NJ;x_gen_solar_OH;x_gen_solar_PA;x_gen_solar_TN;x_gen_solar_VA;x_gen_solar_WV];

x_gen = [x_gen_tot,x_gen_tier1,x_gen_tier2,x_gen_solar];

%% Read Data:
% Read Transmission Network Data:
transmission_network = '/storage/work/a/akp5369/Model_in_Matlab/Input Data/Transmission Networks.xlsx';
transmission_data = xlsread(transmission_network,'Transmission Network');

% Virtual Bid:
virtual_bid = '/storage/work/a/akp5369/Model_in_Matlab/Input Data/results_no_trans_const3.xlsx';
zdata = xlsread(virtual_bid,'beta');

% Transmission Factor:
trans_factor = '/storage/work/a/akp5369/Model_in_Matlab/Input Data/trans_scaler.xlsx';
trans_factor_data = xlsread(trans_factor,'Sheet1');

% Supply Data:
state = supply_data(:,112);
ei_ratio = supply_data(:,113);
rps_tier_1_ratio = rps_data(:,2);
rps_tier_2_ratio = rps_data(:,3);

region_1_no_plants = find(supply_data(:,2)==1,1,'last');
region_2_no_plants = find(supply_data(:,2)==2,1,'last') - region_1_no_plants;
region_3_no_plants = find(supply_data(:,2)==3,1,'last') - region_1_no_plants - region_2_no_plants;
region_4_no_plants = find(supply_data(:,2)==4,1,'last') - region_1_no_plants - region_2_no_plants - region_3_no_plants;
region_5_no_plants = find(supply_data(:,2)==5,1,'last') - region_1_no_plants - region_2_no_plants - region_3_no_plants - region_4_no_plants;

%state in each region:
state_1 = state(1:region_1_no_plants,:);
state_2 = state(region_1_no_plants+1:region_1_no_plants+region_2_no_plants,:);
state_3 = state(region_1_no_plants+region_2_no_plants+1:region_1_no_plants+region_2_no_plants+region_3_no_plants,:);
state_4 = state(region_1_no_plants+region_2_no_plants+region_3_no_plants+1:region_1_no_plants+region_2_no_plants+region_3_no_plants+region_4_no_plants,:);
state_5 = state(region_1_no_plants+region_2_no_plants+region_3_no_plants+region_4_no_plants+1:end,:);

no_bin_1  = supply_data(1:region_1_no_plants,111);
no_bin_2  = supply_data(region_1_no_plants+1:region_1_no_plants+region_2_no_plants,111);
no_bin_3  = supply_data(region_1_no_plants+region_2_no_plants+1:region_1_no_plants+region_2_no_plants+region_3_no_plants,11);
no_bin_4  = supply_data(region_1_no_plants+region_2_no_plants+region_3_no_plants+1:region_1_no_plants+region_2_no_plants+region_3_no_plants+region_4_no_plants,111);
no_bin_5  = supply_data(region_1_no_plants+region_2_no_plants+region_3_no_plants+region_4_no_plants+1:end,111);

% Gas price growth rate:
gas_gr_1 = gas_gr(1:region_1_no_plants,:);
gas_gr_2 = gas_gr(region_1_no_plants+1:region_1_no_plants+region_2_no_plants,:);
gas_gr_3 = gas_gr(region_1_no_plants+region_2_no_plants+1:region_1_no_plants+region_2_no_plants+region_3_no_plants,:);
gas_gr_4 = gas_gr(region_1_no_plants+region_2_no_plants+region_3_no_plants+1:region_1_no_plants+region_2_no_plants+region_3_no_plants+region_4_no_plants,:);
gas_gr_5 = gas_gr(region_1_no_plants+region_2_no_plants+region_3_no_plants+region_4_no_plants+1:end,:);

% Read emission intensity data:
emission_data = xlsread('/storage/work/a/akp5369/Model_in_Matlab/Input Data/Emission_Intensity_2022.xlsx');
emission_data_1 = emission_data(1:region_1_no_plants,:);
emission_data_2 = emission_data(region_1_no_plants+1:region_1_no_plants+region_2_no_plants,:);
emission_data_3 = emission_data(region_1_no_plants+region_2_no_plants+1:region_1_no_plants+region_2_no_plants+region_3_no_plants,:);
emission_data_4 = emission_data(region_1_no_plants+region_2_no_plants+region_3_no_plants+1:region_1_no_plants+region_2_no_plants+region_3_no_plants+region_4_no_plants,:);
emission_data_5 = emission_data(region_1_no_plants+region_2_no_plants+region_3_no_plants+region_4_no_plants+1:end,:);

ei_ratio_1 = ei_ratio(1:region_1_no_plants,:);
ei_ratio_2 = ei_ratio(region_1_no_plants+1:region_1_no_plants+region_2_no_plants,:);
ei_ratio_3 = ei_ratio(region_1_no_plants+region_2_no_plants+1:region_1_no_plants+region_2_no_plants+region_3_no_plants,:);
ei_ratio_4 = ei_ratio(region_1_no_plants+region_2_no_plants+region_3_no_plants+1:region_1_no_plants+region_2_no_plants+region_3_no_plants+region_4_no_plants,:);
ei_ratio_5 = ei_ratio(region_1_no_plants+region_2_no_plants+region_3_no_plants+region_4_no_plants+1:end,:);

supply_data_1 = supply_data(1:region_1_no_plants,:);
supply_data_2 = supply_data(region_1_no_plants+1:region_1_no_plants+region_2_no_plants,:);
supply_data_3 = supply_data(region_1_no_plants+region_2_no_plants+1:region_1_no_plants+region_2_no_plants+region_3_no_plants,:);
supply_data_4 = supply_data(region_1_no_plants+region_2_no_plants+region_3_no_plants+1:region_1_no_plants+region_2_no_plants+region_3_no_plants+region_4_no_plants,:);
supply_data_5 = supply_data(region_1_no_plants+region_2_no_plants+region_3_no_plants+region_4_no_plants+1:end,:);

cap_region_1 = supply_data_1(:,3);
cap_region_2 = supply_data_2(:,3);
cap_region_3 = supply_data_3(:,3);
cap_region_4 = supply_data_4(:,3);
cap_region_5 = supply_data_5(:,3);
cap_region_t = [cap_region_1;cap_region_2;cap_region_3;cap_region_4;cap_region_5];

supply_data_all = [supply_data,rps_tier_1_ratio,rps_tier_2_ratio];

% REC units:
REC_units = '/storage/work/a/akp5369/Model_in_Matlab/Input Data/REC_units_clear2.xlsx';
tier1_units_data = xlsread(REC_units,'tier 1');
tier2_units_data = xlsread(REC_units,'tier 2');
solar_units_data = xlsread(REC_units,'solar');
all_units_data = xlsread(REC_units,'All Units');
g_all_tot = all_units_data(:,22);
rec_region = all_units_data(:,23);
rec_state = all_units_data(:,end);

tier_1_cat = tier1_units_data(:,18);
tier_2_cat = tier2_units_data(:,18);
solar_cat = solar_units_data(:,18);
rec_state_tier1 = tier1_units_data(:,end);
rec_state_tier2 = tier2_units_data(:,end);
rec_state_solar = solar_units_data(:,end);

unit_dummy_tier1_temp = tier1_units_data(:,1:S);
unit_dummy_tier2_temp = tier2_units_data(:,1:S);
unit_dummy_solar_temp = solar_units_data(:,1:S);

unit_dummy_tier1 = zeros(J_r,S);
unit_dummy_tier2 = zeros(J_r,S);
unit_dummy_solar = zeros(J_r,S);

for s = 1:S
    unit_dummy_tier1(:,s) = tier_1_cat.*unit_dummy_tier1_temp(:,s);
    unit_dummy_tier2(:,s) = tier_2_cat.*unit_dummy_tier2_temp(:,s);
    unit_dummy_solar(:,s) = solar_cat.*unit_dummy_solar_temp(:,s);
end

% Flow constraints (in 10 lines):
no_trans = zeros(1,96);
trans_factor = [trans_factor_data(1,:);trans_factor_data(2,:);trans_factor_data(3,:);no_trans;no_trans;no_trans;trans_factor_data(4,:);no_trans;no_trans;trans_factor_data(5,:)];

% Region 1: PA East
% Region 2: PA West
% Region 3: RPJM East
% Region 4: BDC
% Region 5: RPJM West

% Available trasmission lines:
% PA West to PA East: 1-2
% PA East to RPJM East: 1-3
% PA East to Central RPJM: 1-4
% PA West to RPJM West: 2-5
% Central RPJM to RPJM West: 4-5

rec_g_sc_all = zeros(J_r,1);
for j=1:J_r
    if rec_region(j) == 1
        rec_g_sc_all(j,1) =  rec_PA_g_sc;
    else 
        rec_g_sc_all(j,1) =  rec_RPJM_g_sc;
    end
end

% Emissions intensity:

size(emission_data)
size(ei_ratio)

ei_region_1 = emission_data_1.*ei_ratio_1*0.907185;
ei_region_2 = emission_data_2.*ei_ratio_2*0.907185;
ei_region_3 = emission_data_3.*ei_ratio_3*0.907185;
ei_region_4 = emission_data_4.*ei_ratio_4*0.907185;
ei_region_5 = emission_data_5.*ei_ratio_5*0.907185;
ei_region_t = [ei_region_1;ei_region_2;ei_region_3;ei_region_4;ei_region_5];

% Fueltype:
fuel_region_1 = supply_data_1(:,1);
fuel_region_2 = supply_data_2(:,1);
fuel_region_3 = supply_data_3(:,1);
fuel_region_4 = supply_data_4(:,1);
fuel_region_5 = supply_data_5(:,1);
fuel_region_t = [fuel_region_1;fuel_region_2;fuel_region_3;fuel_region_4;fuel_region_5];

% Capacity Scaler:
cs_coal_PA = 0.997082931*1.004;
cs_hydro_PA = 0.986734678;
cs_gas_PA = 0.834969638;
cs_nuclear_PA = 0.908225067;
cs_oil_PA = 0.921889581;
cs_wind_PA = 0.884053657;
cs_bio_PA = 0.870537542;
cs_solar_PA = 0.935752345;

cs_coal_RPJM = 1.212691835*1.004;
cs_hydro_RPJM = 0.967782977;
cs_gas_RPJM = 0.989663052;
cs_nuclear_RPJM = 1.216346754;
cs_oil_RPJM = 0.982988775;
cs_wind_RPJM = 1.586726142;
cs_bio_RPJM = 0.890537542;
cs_solar_RPJM = 0.333057297;

% Capacity Factors:
cf_hydro_PA = 0.108869594+cf_gr_hydro;
cf_wind_PA = 0.288445696+cf_gr_wind; 
cf_solar_PA = 0.16698141+cf_gr_solar;
cf_nuclear_PA = 0.963595727+cf_gr_nuclear;

cf_hydro_RPJM = 0.222765215+cf_gr_hydro;
cf_wind_RPJM = 0.273548196+cf_gr_wind; 
cf_solar_RPJM = 0.2205+cf_gr_solar;
cf_nuclear_RPJM = 0.892684446+cf_gr_nuclear;

% Total Marginal Costs:
marginal_cost_1 = supply_data_1(:,5:100);
marginal_cost_2 = supply_data_2(:,5:100);
marginal_cost_3 = supply_data_3(:,5:100);
marginal_cost_4 = supply_data_4(:,5:100);
marginal_cost_5 = supply_data_5(:,5:100);
marginal_cost_t = [marginal_cost_1;marginal_cost_2;marginal_cost_3;marginal_cost_4;marginal_cost_5];

% Demand parameters virtual bid percentage:
z = zdata(:,5)/100;
net_vb = zdata(:,12);
    
b_1 = marginal_cost_1;
b_2 = marginal_cost_2;
b_3 = marginal_cost_3;
b_4 = marginal_cost_4;
b_5 = marginal_cost_5;
 
m_1 = zeros*b_1;
m_2 = zeros*b_2;
m_3 = zeros*b_3;
m_4 = zeros*b_4;
m_5 = zeros*b_5;

delta = hours;

p_region_1 = p_region_all(:,1);
p_region_2 = p_region_all(:,2);
p_region_3 = p_region_all(:,3);
p_region_4 = p_region_all(:,4);
p_region_5 = p_region_all(:,5);

load_region_1 = load_region_all(:,1);
load_region_2 = load_region_all(:,2);
load_region_3 = load_region_all(:,3);
load_region_4 = load_region_all(:,4);
load_region_5 = load_region_all(:,5);

load_region_by_t_1 = load_region_1./delta;
load_region_by_t_2 = load_region_2./delta;
load_region_by_t_3 = load_region_3./delta;
load_region_by_t_4 = load_region_4./delta;
load_region_by_t_5 = load_region_5./delta;

% Demand curve intercepts (c) and slope (n):
n_1 = (1/etaD)*(p_region_1./(load_region_by_t_1));
n_2 = (1/etaD)*(p_region_2./(load_region_by_t_2));
n_3 = (1/etaD)*(p_region_3./(load_region_by_t_3));
n_4 = (1/etaD)*(p_region_4./(load_region_by_t_4));
n_5 = (1/etaD)*(p_region_5./(load_region_by_t_5));
n = [n_1';n_2';n_3';n_4';n_5'];

c_1 = (1+(1/etaD)).*p_region_1;
c_2 = (1+(1/etaD)).*p_region_2; 
c_3 = (1+(1/etaD)).*p_region_3;
c_4 = (1+(1/etaD)).*p_region_4;
c_5 = (1+(1/etaD)).*p_region_5;
c = [c_1';c_2';c_3';c_4';c_5'];


if trans_const == 1
    trans_data_temp = [transmission_data(1,21);transmission_data(2,21);transmission_data(3,21);0;0;0;transmission_data(7,21);0;0;transmission_data(10,21)];
    fbar_t_tot = repmat(trans_data_temp,1,96).*trans_factor;
elseif trans_const ==0
    fbar_12 = 99999;
    fbar_13 = 99999;
    fbar_14 = 99999;
    fbar_15 = 0;
    fbar_23 = 0;
    fbar_24 = 0;
    fbar_25 = 99999;
    fbar_34 = 0;
    fbar_35 = 0;
    fbar_45 = 99999;
    fbar_t_tot = repmat([fbar_12;fbar_13;fbar_14;fbar_15;fbar_23;fbar_24;fbar_25;fbar_34;fbar_35;fbar_45],1,96);
end

fbar_t = fbar_t_tot;

%**********************************************
%% Define x variable:
%**********************************************
% Initialize demands in 5 regions:
d_t = ones(I,1);

% Initialize generation in 5 regions:
g_1_t = ones(region_1_no_plants,1);  
g_2_t = ones(region_2_no_plants,1);                                     
g_3_t = ones(region_3_no_plants,1); 
g_4_t = ones(region_4_no_plants,1); 
g_5_t = ones(region_5_no_plants,1); 
g_t = [g_1_t;g_2_t;g_3_t;g_4_t;g_5_t];

% Initialize flows in 5 regions:
f_12 = 1;
f_13 = 1;
f_14 = 1;
f_15 = 1;
f_23 = 0;
f_24 = 0;
f_25 = 1;
f_34 = 0;
f_35 = 0;
f_45 = 1;
f_t = [f_12;f_13;f_14;f_15;f_23;f_24;f_25;f_34;f_35;f_45];

% Initialize external RECs purchased:
g_tier_1 = ones(J_r*S,1);
g_tier_2 = ones(J_r*S,1);
g_solar = ones(J_r*S,1);

% Initialize capacity expansion terms:
g_n_t = ones(S*3,1);
K_n = ones(S*3,1);

% Pack-out x
x_t = [d_t;g_t;f_t];
x_int = repmat(x_t,T,1);                    % Internal x
x_ext_rec = [g_tier_1;g_tier_2;g_solar];    % External x 
x_cap_exp = [repmat(g_n_t,T,1);K_n];        % Capacity expansion x

if cap_exp == 0 && rps_const == 1
    x = [x_int;x_ext_rec];
elseif cap_exp ==1 && rps_const == 1
    x = [x_int;x_ext_rec;x_cap_exp];
elseif cap_exp == 0 && rps_const == 0
    x = x_int;
elseif cap_exp ==1 && rps_const == 0
    x = [x_int;x_cap_exp];    
end


%**********************************************
%% Define Lower and Upper Bounds:
%**********************************************
% Lower bounds (lb):
lb_d_t = zeros(I,1);
lb_g_t = zeros(length(g_t),1);
lb_f_t = -fbar_t;

for t = 1:T
    lb_t(:,t) = [lb_d_t;lb_g_t;lb_f_t(:,t)];
end

lb_int = reshape(lb_t,[length(lb_t)*T,1]);
lb_ext_rec = 0*x_ext_rec;

if cap_exp ==0 && rps_const == 1
    lb = [lb_int;lb_ext_rec];
elseif cap_exp ==1 && rps_const == 1
    lb = [lb_int;lb_ext_rec;0*x_cap_exp];
elseif cap_exp == 0 && rps_const == 0
    lb = lb_int;
elseif cap_exp ==1 && rps_const == 0
    lb = [lb_int;0*x_cap_exp];     
end

% Upper bounds (ub):
ub_d_t = Inf*ones(I,1);

cap_scaler_1 = ones(region_1_no_plants,T);
cap_scaler_2 = ones(region_2_no_plants,T);
cap_scaler_3 = ones(region_3_no_plants,T);
cap_scaler_4 = ones(region_4_no_plants,T);
cap_scaler_5 = ones(region_5_no_plants,T);
for t = 1:T
    for fr = 1:region_1_no_plants
        for ju = 1:region_1_no_plants            
            if fuel_region_1(ju)==1 && supply_data_1(ju,111)<2000
                cap_scaler_1(ju,t) = cs_bio_PA*0.961;
            elseif fuel_region_1(ju)==2 && supply_data_1(ju,111)<2000
                cap_scaler_1(ju,t) = cs_coal_PA*0.961;               
            elseif fuel_region_1(ju)==3 && supply_data_1(ju,111)<2000
                cap_scaler_1(ju,t) = cs_hydro_PA*cf_hydro_PA;
            elseif fuel_region_1(ju)==4 && supply_data_1(ju,111)<2000
                cap_scaler_1(ju,t) = cs_nuclear_PA*cf_nuclear_PA;
            elseif fuel_region_1(ju)==5 && supply_data_1(ju,111)<2000
                cap_scaler_1(ju,t) = 0.961;
            elseif fuel_region_1(ju)==6 && supply_data_1(ju,111)<2000
                cap_scaler_1(ju,t) = cs_oil_PA*0.961;
            elseif fuel_region_1(ju)==7 && supply_data_1(ju,111)<2000
                cap_scaler_1(ju,t) = cs_solar_PA*cf_solar_PA;
            elseif fuel_region_1(ju)==8 && supply_data_1(ju,111)<2000
                cap_scaler_1(ju,t) = cs_wind_PA*cf_wind_PA;
            elseif fuel_region_1(ju)==9 && supply_data_1(ju,111)<2000
                cap_scaler_1(ju,t) = cs_gas_PA*0.961;
            end  
        end
    end  
 
    for fr = 1:region_2_no_plants
        for ju = 1:region_2_no_plants
            if fuel_region_2(ju)==1 && supply_data_2(ju,111)<2000
                cap_scaler_2(ju,t) = cs_bio_PA*0.961;
            elseif fuel_region_2(ju)==2 && supply_data_2(ju,111)<2000
                cap_scaler_2(ju,t) = cs_coal_PA*0.961;               
            elseif fuel_region_2(ju)==3 && supply_data_2(ju,111)<2000
                cap_scaler_2(ju,t) = cs_hydro_PA*cf_hydro_PA;
            elseif fuel_region_2(ju)==4 && supply_data_2(ju,111)<2000
                cap_scaler_2(ju,t) = cs_nuclear_PA*cf_nuclear_PA;
            elseif fuel_region_2(ju)==5 && supply_data_2(ju,111)<2000
                cap_scaler_2(ju,t) = 0.961;
            elseif fuel_region_2(ju)==6 && supply_data_2(ju,111)<2000
                cap_scaler_2(ju,t) = cs_oil_PA*0.961;
            elseif fuel_region_2(ju)==7 && supply_data_2(ju,111)<2000
                cap_scaler_2(ju,t) = cs_solar_PA*cf_solar_PA;
            elseif fuel_region_2(ju)==8 && supply_data_2(ju,111)<2000
                cap_scaler_2(ju,t) = cs_wind_PA*cf_wind_PA;
            elseif fuel_region_2(ju)==9 && supply_data_2(ju,111)<2000
                cap_scaler_2(ju,t) = cs_gas_PA*0.961;
            end  
        end
    end 
    
    for fr = 1:region_3_no_plants
        for ju = 1:region_3_no_plants
            if fuel_region_3(ju)==1 && supply_data_3(ju,111)<2000
                cap_scaler_3(ju,t) = cs_bio_RPJM*0.961;
            elseif fuel_region_3(ju)==2 && supply_data_3(ju,111)<2000
                cap_scaler_3(ju,t) = cs_coal_RPJM*0.961;               
            elseif fuel_region_3(ju)==3 && supply_data_3(ju,111)<2000
                cap_scaler_3(ju,t) = cs_hydro_RPJM*cf_hydro_RPJM;
            elseif fuel_region_3(ju)==4 && supply_data_3(ju,111)<2000 
                cap_scaler_3(ju,t) = cs_nuclear_RPJM*cf_nuclear_RPJM;
            elseif fuel_region_3(ju)==5 && supply_data_3(ju,111)<2000
                cap_scaler_3(ju,t) = 0.961;
            elseif fuel_region_3(ju)==6 && supply_data_3(ju,111)<2000
                cap_scaler_3(ju,t) = cs_oil_RPJM*0.961;
            elseif fuel_region_3(ju)==7 && supply_data_3(ju,111)<2000
                cap_scaler_3(ju,t) = cs_solar_RPJM*cf_solar_RPJM;
            elseif fuel_region_3(ju)==8 && supply_data_3(ju,111)<2000
                cap_scaler_3(ju,t) = cs_wind_RPJM*cf_wind_RPJM;
            elseif fuel_region_3(ju)==9 && supply_data_3(ju,111)<2000
                cap_scaler_3(ju,t) = cs_gas_RPJM*0.961;
            end  
        end
    end     
    
    for fr = 1:region_4_no_plants
        for ju = 1:region_4_no_plants
            if fuel_region_4(ju)==1 && supply_data_4(ju,111)<2000
                cap_scaler_4(ju,t) = cs_bio_RPJM*0.961;
            elseif fuel_region_4(ju)==2 && supply_data_4(ju,111)<2000
                cap_scaler_4(ju,t) = cs_coal_RPJM*0.961;               
            elseif fuel_region_4(ju)==3 && supply_data_4(ju,111)<2000
                cap_scaler_4(ju,t) = cs_hydro_RPJM*cf_hydro_RPJM;
            elseif fuel_region_4(ju)==4 && supply_data_4(ju,111)<2000
                cap_scaler_4(ju,t) = cs_nuclear_RPJM*cf_nuclear_RPJM;
            elseif fuel_region_4(ju)==5 && supply_data_4(ju,111)<2000
                cap_scaler_4(ju,t) = 0.961;
            elseif fuel_region_4(ju)==6 && supply_data_4(ju,111)<2000
                cap_scaler_4(ju,t) = cs_oil_RPJM*0.961;
            elseif fuel_region_4(ju)==7 && supply_data_4(ju,111)<2000
                cap_scaler_4(ju,t) = cs_solar_RPJM*cf_solar_RPJM;
            elseif fuel_region_4(ju)==8 && supply_data_4(ju,111)<2000
                cap_scaler_4(ju,t) = cs_wind_RPJM*cf_wind_RPJM;
            elseif fuel_region_4(ju)==9 && supply_data_4(ju,111)<2000
                cap_scaler_4(ju,t) = cs_gas_RPJM*0.961;
            end  
        end
    end 
    
    for fr = 1:region_5_no_plants
        for ju = 1:region_5_no_plants
            if fuel_region_5(ju)==1 && supply_data_5(ju,111)<2000
                cap_scaler_5(ju,t) = cs_bio_RPJM*0.961;
            elseif fuel_region_5(ju)==2 && supply_data_5(ju,111)<2000
                cap_scaler_5(ju,t) = cs_coal_RPJM*0.961;               
            elseif fuel_region_5(ju)==3 && supply_data_5(ju,111)<2000
                cap_scaler_5(ju,t) = cs_hydro_RPJM*cf_hydro_RPJM;
            elseif fuel_region_5(ju)==4 && supply_data_5(ju,111)<2000
                cap_scaler_5(ju,t) = cs_nuclear_RPJM*cf_nuclear_RPJM;
            elseif fuel_region_5(ju)==5 && supply_data_5(ju,111)<2000
                cap_scaler_5(ju,t) = 0.961;
            elseif fuel_region_5(ju)==6 && supply_data_5(ju,111)<2000
                cap_scaler_5(ju,t) = cs_oil_RPJM*0.961;
            elseif fuel_region_5(ju)==7 && supply_data_5(ju,111)<2000
                cap_scaler_5(ju,t) = cs_solar_RPJM*cf_solar_RPJM;
            elseif fuel_region_5(ju)==8 && supply_data_5(ju,111)<2000
                cap_scaler_5(ju,t) = cs_wind_RPJM*cf_wind_RPJM;
            elseif fuel_region_5(ju)==9 && supply_data_5(ju,111)<2000
                cap_scaler_5(ju,t) = cs_gas_RPJM*0.961;
            end  
        end
    end           
end    
cap_scaler = [cap_scaler_1;cap_scaler_2;cap_scaler_3;cap_scaler_4;cap_scaler_5];

ub_g_t = ones(J,T);
for t = 1:T
    ub_g_t(:,t) = cap_region_t.*cap_scaler(:,t);
end
ub_f_t = fbar_t;
ub_t = ones(I+J+F,T);
for ls = 1:T
    ub_t(:,ls) = [ub_d_t;ub_g_t(:,ls);ub_f_t(:,ls)];
end
ub_int = reshape(ub_t,[length(ub_t)*T,1]);

ub_new_g_tier1_temp = ones(J_r,S);
ub_new_g_tier2_temp = ones(J_r,S);
ub_new_g_solar_temp = ones(J_r,S);

for s = 1:S
    ub_new_g_tier1_temp(:,s) = g_all_tot.*rec_g_sc_all.*unit_dummy_tier1(:,s);
    ub_new_g_tier2_temp(:,s) = g_all_tot.*rec_g_sc_all.*unit_dummy_tier2(:,s);
    ub_new_g_solar_temp(:,s) = g_all_tot.*rec_g_sc_all.*unit_dummy_solar(:,s);
end

ub_new_g_tier1_temp(:,4:5) = zeros(J_r,2);
ub_new_g_tier1_temp(:,8) = zeros(J_r,1);
ub_new_g_tier1_temp(:,12:14) = zeros(J_r,3);
ub_new_g_tier2_temp(:,4:5) = zeros(J_r,2);
ub_new_g_tier2_temp(:,8) = zeros(J_r,1);
ub_new_g_tier2_temp(:,12:14) = zeros(J_r,3);
ub_new_g_solar_temp(:,4:5) = zeros(J_r,2);
ub_new_g_solar_temp(:,8) = zeros(J_r,1);
ub_new_g_solar_temp(:,12:14) = zeros(J_r,3);

ub_new_g_tier1 = reshape(ub_new_g_tier1_temp,[J_r*S,1]);
ub_new_g_tier2 = reshape(ub_new_g_tier2_temp,[J_r*S,1]);
ub_new_g_solar = reshape(ub_new_g_solar_temp,[J_r*S,1]);

ub_ext_rec = [ub_new_g_tier1;ub_new_g_tier2;ub_new_g_solar];

if cap_exp ==0 && rps_const == 1
    ub = [ub_int;ub_ext_rec];
elseif cap_exp ==1 && rps_const == 1
    ub = [ub_int;ub_ext_rec;inf*x_cap_exp];
elseif cap_exp == 0 && rps_const == 0
    ub = ub_int;
elseif cap_exp ==1 && rps_const == 0
    ub = [ub_int;inf*x_cap_exp];     
end

%**********************************************
%% Define Objective Function
%**********************************************
% Vector f (demand) - by nodes and load segment:
f_d = -c.*repmat(delta',I,1);

% Vector f (supply):
f_g_1 = zeros(region_1_no_plants,T);
for t = 1:T
    f_g_1(:,t) = b_1(:,t)*delta(t);
end

f_g_2 = zeros(region_2_no_plants,T);
for t = 1:T
    f_g_2(:,t) = b_2(:,t)*delta(t);
end

f_g_3 = zeros(region_3_no_plants,T);
for t = 1:T
    f_g_3(:,t) = b_3(:,t)*delta(t);
end

f_g_4 = zeros(region_4_no_plants,T);
for t = 1:T
    f_g_4(:,t) = b_4(:,t)*delta(t);
end

f_g_5 = zeros(region_5_no_plants,T);
for t = 1:T
    f_g_5(:,t) = b_5(:,t)*delta(t);
end

% Vector f (flows):
f_f_t = zeros(F,1);

% Define ceplex f vector in for each load segment;
f_params_t = zeros(I+J+F,T);

for t = 1:T
    f_params_t(:,t) = [f_d(:,t);f_g_1(:,t);f_g_2(:,t);f_g_3(:,t);f_g_4(:,t);f_g_5(:,t);f_f_t];
end

f_params_int = reshape(f_params_t,[length(x_int),1]);
f_params_ext_rec = 0*x_ext_rec;

% Vector f (Capacity expansion):
f_params_gn_t = MC_N;
f_params_gn_temp = zeros(S*3,T);
for t = 1:T
    f_params_gn_temp(:,t) = f_params_gn_t*delta(t);
end
f_params_gn = reshape(f_params_gn_temp,[T*S*3,1]);
f_params_K = C_N;

if cap_exp == 0 && rps_const == 1
    f_params = [f_params_int;f_params_ext_rec];
elseif cap_exp == 1 && rps_const == 1
    f_params = [f_params_int;f_params_ext_rec;f_params_gn;f_params_K];
elseif cap_exp == 0 && rps_const == 0
    f_params = f_params_int;
elseif cap_exp ==1 && rps_const == 0
    f_params = [f_params_int;f_params_gn;f_params_K];     
end

% Matrix H (demand):
H_d_0 = n.*repmat(delta',I,1);

for t = 1:T
    for i=1:size(H_d_0,1)
       H_d(i,i,t) = H_d_0(i,t);
    end
end

% Matrix H (supply):
H_g_1_0 = zeros(region_1_no_plants,T);
for t = 1:T
    H_g_1_0(:,t) = m_1(:,t)*delta(t);
end

for t = 1:T
    for i=1:size(H_g_1_0,1)
       H_g_1(i,i,t) = H_g_1_0(i,t);
    end
end

H_g_2_0 = zeros(region_2_no_plants,T);
for t = 1:T
    H_g_2_0(:,t) = m_2(:,t)*delta(t);
end

for t = 1:T
    for i=1:size(H_g_2_0,1)
       H_g_2(i,i,t) = H_g_2_0(i,t);
    end
end

H_g_3_0 = zeros(region_3_no_plants,T);
for t = 1:T
    H_g_3_0(:,t) = m_3(:,t)*delta(t);
end

for t = 1:T
    for i=1:size(H_g_3_0,1)
       H_g_3(i,i,t) = H_g_3_0(i,t);
    end
end

H_g_4_0 = zeros(region_4_no_plants,T);
for t = 1:T
    H_g_4_0(:,t) = m_4(:,t)*delta(t);
end

for t = 1:T
    for i=1:size(H_g_4_0,1)
       H_g_4(i,i,t) = H_g_4_0(i,t);
    end
end

H_g_5_0 = zeros(region_5_no_plants,T);
for t = 1:T
    H_g_5_0(:,t) = m_5(:,t)*delta(t);
end

for t = 1:T
    for i=1:size(H_g_5_0,1)
       H_g_5(i,i,t) = H_g_5_0(i,t);
    end
end

% Matrix H (flows):
H_f = zeros(F,F,T);

% Ensemble ceplex matrix H for internal units:
H_params_t = zeros(size(f_params_t,1),size(f_params_t,1),T);

% Denote dimension values:
H_d_size = size(H_d,1);
H_g_1_size = size(H_d,1)+ size(H_g_1,1);
H_g_2_size = H_g_1_size + size(H_g_2,1);
H_g_3_size = H_g_2_size + size(H_g_3,1);
H_g_4_size = H_g_3_size + size(H_g_4,1);
H_g_5_size = H_g_4_size + size(H_g_5,1);
H_f_size = H_g_5_size + size(H_f,1);

H_params_t(1:H_d_size,1:H_d_size,:) = H_d;
H_params_t(H_d_size+1:H_g_1_size,H_d_size+1:H_g_1_size,:) = H_g_1;
H_params_t(H_g_1_size+1:H_g_2_size,H_g_1_size+1:H_g_2_size,:) = H_g_2;
H_params_t(H_g_2_size+1:H_g_3_size,H_g_2_size+1:H_g_3_size,:) = H_g_3;
H_params_t(H_g_3_size+1:H_g_4_size,H_g_3_size+1:H_g_4_size,:) = H_g_4;
H_params_t(H_g_4_size+1:H_g_5_size,H_g_4_size+1:H_g_5_size,:) = H_g_5;
H_params_t(H_g_5_size+1:H_f_size,H_g_5_size+1:H_f_size,:) = H_f;

H_params_int = zeros(length(x_int),length(x_int));
count = 1;
for t = 1:T
    H_params_int(count:count+size(H_params_t,1)-1,count:count+size(H_params_t,1)-1) = H_params_t(:,:,t);
    count = count + size(H_params_t,1);
end

% Put all pieces of H matrix together:
H_params = zeros(length(x),length(x));
H_params(1:length(x_int),1:length(x_int)) = H_params_int;

%% Define Constraints:
% Equality constraints:
% Internal Units Market Clearing:
lost_component = 1+tot_loss_pct-net_vb;

Aeq_d = -eye(I,I);
Aeq_g = [ones(1,region_1_no_plants),zeros(1,region_2_no_plants+region_3_no_plants+region_4_no_plants+region_5_no_plants);zeros(1,region_1_no_plants),ones(1,region_2_no_plants),zeros(1,region_3_no_plants+region_4_no_plants+region_5_no_plants);zeros(1,region_1_no_plants+region_2_no_plants),ones(1,region_3_no_plants),zeros(1,region_4_no_plants+region_5_no_plants);zeros(1,region_1_no_plants+region_2_no_plants+region_3_no_plants),ones(1,region_4_no_plants),zeros(1,region_5_no_plants);zeros(1,region_1_no_plants+region_2_no_plants+region_3_no_plants+region_4_no_plants),ones(1,region_5_no_plants)];
Aeq_f = [1,1,1,1,0,0,0,0,0,0;-1,0,0,0,1,1,1,0,0,0;0,-1,0,0,-1,0,0,1,1,0;0,0,-1,0,0,-1,0,-1,0,1;0,0,0,-1,0,0,-1,0,-1,-1];
Aeq_t = [Aeq_d,Aeq_g,Aeq_f];

Aeq_int = zeros(T*size(Aeq_t,1),length(x_int));
count_row = 1;
count_column = 1;
for t = 1:T
    Aeq_int(count_row:count_row+size(Aeq_t,1)-1,count_column:count_column+size(Aeq_t,2)-1) = [Aeq_d*lost_component(t),Aeq_g,Aeq_f];
    count_row = count_row + size(Aeq_t,1);
    count_column = count_column + size(Aeq_t,2);
end

% Add capacity expansion to equality constraint:
state_to_region_t = [0,0,0,0,0,0,0,0,0,0,0.586434045,0,0,0;0,0,0,0,0,0,0,0,0,0,0.413565955,0,0,0;0,1,0,0,0,0,0,0,0.228034644,0,0,0,0,0;1,0,0,0,0,0.912229612,0,1,0,0,0,0,0.800495305,0.004136931;0,0,1,1,1,0.087770388,1,0,0.771965356,1,0,1,0.199504695,0.995863069];
count=1;
for s = 1:S
    state_to_region(:,count:count+2) = repmat(state_to_region_t(:,s),1,3);
    count = count+3;
end

Aeq_g_N_1 = [zeros(1,3*10),1,1,1,zeros(1,3*3)];
Aeq_g_N_2 = [zeros(1,3*10),1,1,1,zeros(1,3*3)];
Aeq_g_N_3 = [zeros(1,3*1),1,1,1,zeros(1,3*12)];
Aeq_g_N_4 = [1,1,1,zeros(1,3*4),1,1,1,zeros(1,3),1,1,1,zeros(1,3*4),1,1,1,1,1,1];
Aeq_g_N_5 = [zeros(1,3*2),ones(1,3*5),zeros(1,3),ones(1,3*2),zeros(1,3),ones(1,3*3)];
Aeq_g_N = [Aeq_g_N_1;Aeq_g_N_2;Aeq_g_N_3;Aeq_g_N_4;Aeq_g_N_5].*state_to_region;

Aeq_cap_exp = zeros(I*T,3*S*T);
count_new_r = 1;
count_new_c = 1;
for t = 1:T
    Aeq_cap_exp(count_new_r:count_new_r+size(Aeq_g_N,1)-1,count_new_c:count_new_c+size(Aeq_g_N,2)-1) = Aeq_g_N;
    count_new_r = count_new_r + size(Aeq_g_N,1);
    count_new_c = count_new_c + size(Aeq_g_N,2);
end

if cap_exp==0
    Aeq = zeros(T*size(Aeq_t,1),length(x));
    Aeq(:,1:length(x_t)*T) = Aeq_int;
elseif cap_exp==1 && rps_const==0
    Aeq = zeros(T*size(Aeq_t,1),length(x));
    Aeq(:,1:length(x_t)*T) = Aeq_int;
    Aeq(:,length(x_t)*T+1:length(x_t)*T+S*3*T) = Aeq_cap_exp;    
elseif cap_exp==1 && rps_const==1
    Aeq = zeros(T*size(Aeq_t,1),length(x));
    Aeq(:,1:length(x_t)*T) = Aeq_int;
    Aeq(:,length(x_t)*T+J_r*S*3+1:length(x_t)*T+J_r*S*3+S*3*T) = Aeq_cap_exp;
end
beq = zeros((I)*T,1);

% Inequality constraints:
% External Units Market Clearing:
Aineq_new_tier1= repmat(diag(ones(J_r,1)),1,S);
Aineq_new_tier2 = repmat(diag(ones(J_r,1)),1,S);
Aineq_new_solar = repmat(diag(ones(J_r,1)),1,S);

for s = 1:S
    unit_dummy_tier1_diag_temp(:,:,s) = diag(unit_dummy_tier1_temp(:,s));
    unit_dummy_tier2_diag_temp(:,:,s) = diag(unit_dummy_tier2_temp(:,s));
    unit_dummy_solar_diag_temp(:,:,s) = diag(unit_dummy_solar_temp(:,s));
end

unit_dummy_tier1_diag = reshape(unit_dummy_tier1_diag_temp,[J_r,J_r*S]);
unit_dummy_tier2_diag = reshape(unit_dummy_tier2_diag_temp,[J_r,J_r*S]);
unit_dummy_solar_diag = reshape(unit_dummy_solar_diag_temp,[J_r,J_r*S]);
Aineq_new_g = [Aineq_new_tier1,Aineq_new_tier2,Aineq_new_solar].*[unit_dummy_tier1_diag,unit_dummy_tier2_diag,unit_dummy_solar_diag];

Aineq_ext_rec = zeros(J_r,length(x));
Aineq_ext_rec(:,length(x_int)+1:length(x_int)+J_r*S*3) = Aineq_new_g;
bineq_ext_rec = g_all_tot.*rec_g_sc_all;

% RPS constraints:
% Internal Units:
% REC - tier 1:
A_ineq_g_re_int_t_1 = zeros(S,J);
for s = 1:S
    for i = 1:J
        if state(i) == s
            if rps_tier_1_ratio(i) ~= 0
                A_ineq_g_re_int_t_1(s,i) = re_tier_1(s) - rps_tier_1_ratio(i);
            else
                A_ineq_g_re_int_t_1(s,i) = re_tier_1(s);
            end
        end
    end
end

% REC - tier 2:
A_ineq_g_re_int_t_2 = zeros(S,J);
for s = 1:S
    for i = 1:J
        if state(i) == s
            if rps_tier_2_ratio(i) ~= 0
                A_ineq_g_re_int_t_2(s,i) = re_tier_2(s) - rps_tier_2_ratio(i);
            else
                A_ineq_g_re_int_t_2(s,i) = re_tier_2(s);
            end
        end
    end
end

% SREC:
A_ineq_g_se_int_t = zeros(S,J);
for s = 1:S
    for i = 1:J
        if state(i) == s
            if fuel_region_t(i) == 7 
                A_ineq_g_se_int_t(s,i) = se(s) - 1;
            else
                A_ineq_g_se_int_t(s,i) = se(s);
            end
        end
    end
end

A_ineq_d_t = zeros(S,I);
A_ineq_f_t = zeros(S,F);
A_ineq_re_int_t_1 = [A_ineq_d_t,A_ineq_g_re_int_t_1,A_ineq_f_t];
A_ineq_re_int_t_2 = [A_ineq_d_t,A_ineq_g_re_int_t_2,A_ineq_f_t];
A_ineq_re_int_t = [A_ineq_re_int_t_1;A_ineq_re_int_t_2];
A_ineq_se_int_t = [A_ineq_d_t,A_ineq_g_se_int_t,A_ineq_f_t];

% Combine interal RE and SE:
count = 1;
for t = 1:T
    A_ineq_re_int(:,count:count+size(A_ineq_re_int_t,2)-1) = A_ineq_re_int_t*delta(t);
    A_ineq_se_int(:,count:count+size(A_ineq_se_int_t,2)-1) = A_ineq_se_int_t*delta(t);
    count = count + size(A_ineq_re_int_t,2);
end

A_ineq_rps_int = [A_ineq_re_int;A_ineq_se_int];

% External RECs:
A_ineq_g_ext_rec_s = -ones(1,J_r);
A_ineq_g_ext_rec_1 = zeros(S,J_r*S);
A_ineq_g_ext_rec_2 = zeros(S,J_r*S);
A_ineq_g_ext_rec_sol = zeros(S,J_r*S);

unit_dummy_tier1_trs = unit_dummy_tier1';
unit_dummy_tier2_trs = unit_dummy_tier2';
unit_dummy_solar_trs = unit_dummy_solar';

count = 1;
for s = 1:S
    A_ineq_g_ext_rec_1(s,count:count+J_r-1) = A_ineq_g_ext_rec_s.*unit_dummy_tier1_trs(s,:);
    A_ineq_g_ext_rec_2(s,count:count+J_r-1) = A_ineq_g_ext_rec_s.*unit_dummy_tier2_trs(s,:);
    A_ineq_g_ext_rec_sol(s,count:count+J_r-1) = A_ineq_g_ext_rec_s.*unit_dummy_solar_trs(s,:);
    count = count + J_r;
end

A_ineq_g_rps_ext_rec = zeros(S*3,J_r*S*3);
A_ineq_g_rps_ext_rec(1:S,1:J_r*S) = A_ineq_g_ext_rec_1;
A_ineq_g_rps_ext_rec(S+1:2*S,J_r*S+1:J_r*S*2) = A_ineq_g_ext_rec_2;
A_ineq_g_rps_ext_rec(2*S+1:S*3,J_r*S*2+1:end) = A_ineq_g_ext_rec_sol;

% Compile inequality constraint without capacity expansion:
A_ineq_rps_no_cap_ext = [A_ineq_rps_int,A_ineq_g_rps_ext_rec];
bineq_rps = -1*[re_tier_1.*x_gen(:,1) - x_gen(:,2);re_tier_2.*x_gen(:,1) - x_gen(:,3);se.*x_gen(:,1) - x_gen(:,4)];

% Capacity expansion inequality:
% New inequalities (to include g < K*avail):
A_ineg_g_N_t = ones(S*3*T,1);
A_ineg_g_N = diag(A_ineg_g_N_t);

A_ineq_K_t_diag = -repmat(avail_N,S,1);
A_ineg_K_t = diag(A_ineq_K_t_diag);
A_ineg_K = repmat(A_ineg_K_t,T,1);
A_ineq_gK = [A_ineg_g_N,A_ineg_K];
b_ineq_gK = zeros(S*3*T,1);

% New capacity in RPS constraints:
% Tier 1 (new wind + new solar):
A_ineq_rps_g_n_1_t = zeros(S,S*3); 
count=1;
for s = 1:S
    A_ineq_rps_g_n_1_t(s,count:count+2) = [re_tier_1(s),re_tier_1(s)-1,re_tier_1(s)-1];       
    count = count+3;
end

A_ineq_rps_g_n_1=zeros(S,S*3*T);
count=1;
for t = 1:T
    A_ineq_rps_g_n_1(:,count:count+S*3-1) = A_ineq_rps_g_n_1_t*delta(t);
    count = count+S*3;
end

% Tier 2 (not applicable to new generation):
A_ineq_rps_g_n_2_t = zeros(S,S*3); 
count=1;
for s = 1:S
    A_ineq_rps_g_n_2_t(s,count:count+2) = [re_tier_2(s),re_tier_2(s),re_tier_2(s)];       
    count = count+3;
end
A_ineq_rps_g_n_2=zeros(S,S*3*T);
count=1;
for t = 1:T
    A_ineq_rps_g_n_2(:,count:count+S*3-1) = A_ineq_rps_g_n_2_t*delta(t);
    count = count+S*3;
end

% Solar REC (new solar):
A_ineq_rps_g_n_solar_t = zeros(S,S*3); 
count=1;
for s = 1:S
    A_ineq_rps_g_n_solar_t(s,count:count+2) = [se(s),se(s),se(s)-1];       
    count = count+3;
end

A_ineq_rps_g_n_solar=zeros(S,S*3*T);
count=1;
for t = 1:T
    A_ineq_rps_g_n_solar(:,count:count+S*3-1) = A_ineq_rps_g_n_solar_t*delta(t);
    count = count+S*3;
end

A_ineq_rps_g_n = [A_ineq_rps_g_n_1;A_ineq_rps_g_n_2;A_ineq_rps_g_n_solar];
A_ineq_rps_K_n = zeros(S*3,S*3);

A_ineq_rps_new_cap = [A_ineq_rps_g_n,A_ineq_rps_K_n];

% Compile inequality:
Aineq_ext_rec_final = zeros(size(Aineq_ext_rec,1),length(x));
Aineq_ext_rec_final(:,1:size(Aineq_ext_rec,2)) = Aineq_ext_rec;

if cap_exp == 0
    if rps_const == 0     
        Aineq_no_CPP = []; 
        bineq_no_CPP = [];
    elseif rps_const == 1
        A_ineq_rps_final = [A_ineq_rps_int,A_ineq_g_rps_ext_rec];
        Aineq_no_CPP = zeros(size(Aineq_ext_rec,1)+size(A_ineq_rps_no_cap_ext,1),length(x));
        Aineq_no_CPP(1:J_r,1:length(x)) = Aineq_ext_rec_final;     
        Aineq_no_CPP(J_r+1:J_r+S*3,1:length(x)) = A_ineq_rps_final; 

        bineq_no_CPP = [bineq_ext_rec;bineq_rps];
    end   
elseif cap_exp == 1
    if rps_const == 0 
        Aineq_no_CPP = zeros(size(A_ineq_gK,1),length(x));
        Aineq_no_CPP(:,length(x_int)+1:length(x)) = A_ineq_gK; 

        bineq_no_CPP = b_ineq_gK;
    elseif rps_const == 1
        A_ineq_rps_final = [A_ineq_rps_int,A_ineq_g_rps_ext_rec,A_ineq_rps_new_cap];
        Aineq_no_CPP = zeros(size(Aineq_ext_rec,1)+size(A_ineq_rps_no_cap_ext,1)+size(A_ineq_gK,1),length(x));
        Aineq_no_CPP(1:J_r,1:length(x)) = Aineq_ext_rec_final; 
        Aineq_no_CPP(J_r+1:J_r+S*3,1:length(x)) = A_ineq_rps_final; 
        Aineq_no_CPP(J_r+S*3+1:end,length(x_int)+length(x_ext_rec)+1:length(x)) = A_ineq_gK; 

        bineq_no_CPP = [bineq_ext_rec;bineq_rps;b_ineq_gK];
    end    
end


% Adding Mass-Based Contraints:
if policy_sc==2
      A_ineq_MB_d = zeros(2,I);
      A_ineq_MB_f = zeros(2,F);
      A_ineq_MB_g_1_t = [ones(1,region_1_no_plants+region_2_no_plants),zeros(1,region_3_no_plants+region_4_no_plants+region_5_no_plants)].*ei_region_t';
      A_ineq_MB_g_2_t = [zeros(1,region_1_no_plants+region_2_no_plants),ones(1,region_3_no_plants+region_4_no_plants+region_5_no_plants)].*ei_region_t';
      A_ineq_MB_g_1_temp = repmat(A_ineq_MB_g_1_t',1,T);
      A_ineq_MB_g_2_temp = repmat(A_ineq_MB_g_2_t',1,T);

      for t = 1:T
          A_ineq_MB_g_1_temp_2(:,t) = A_ineq_MB_g_1_temp(:,t)*delta(t);
          A_ineq_MB_g_2_temp_2(:,t) = A_ineq_MB_g_2_temp(:,t)*delta(t);
      end

      for t = 1:T
          A_ineq_MB_1_t(:,t) = [A_ineq_MB_d(1,:)';A_ineq_MB_g_1_temp_2(:,t);A_ineq_MB_f(1,:)'];
          A_ineq_MB_2_t(:,t) = [A_ineq_MB_d(1,:)';A_ineq_MB_g_2_temp_2(:,t);A_ineq_MB_f(1,:)'];
      end

      A_ineq_MB_1 = reshape(A_ineq_MB_1_t,length(A_ineq_MB_1_t)*T,1)';
      A_ineq_MB_2 = reshape(A_ineq_MB_2_t,length(A_ineq_MB_2_t)*T,1)';

      A_ineq_MB = zeros(2,length(x));
      A_ineq_MB(:,1:length(x_int)) = [A_ineq_MB_1;A_ineq_MB_2];
      b_ineq_MB = [e_PA;e_RPJM];
elseif policy_sc==3
      A_ineq_MB_d = zeros(1,I);
      A_ineq_MB_f = zeros(1,F);
      A_ineq_MB_g_t = [ones(1,region_1_no_plants+region_2_no_plants),ones(1,region_3_no_plants+region_4_no_plants+region_5_no_plants)].*ei_region_t';
      A_ineq_MB_g_temp = repmat(A_ineq_MB_g_t',1,T);

      for t = 1:T
          A_ineq_MB_g_temp_2(:,t) = A_ineq_MB_g_temp(:,t).*delta(t);
      end

      for t = 1:T
          A_ineq_MB_t(:,t) = [A_ineq_MB_d';A_ineq_MB_g_temp_2(:,t);A_ineq_MB_f'];
      end

      A_ineq_MB = zeros(1,length(x));
      A_ineq_MB(1,1:length(x_int)) = reshape(A_ineq_MB_t,length(A_ineq_MB_t)*T,1)';
      b_ineq_MB = e_PA+e_RPJM; 
end

if policy_sc==1
      Aineq = Aineq_no_CPP;
      bineq = bineq_no_CPP;
elseif policy_sc==2 || policy_sc==3
      Aineq = [Aineq_no_CPP;A_ineq_MB];
      bineq = [bineq_no_CPP;b_ineq_MB];
end


%% Solve RTO problem
% Initital starting values
% x0 = ones(length(x),1);
x0 = [];

options = cplexoptimset('Display','on','TolFun',0.0000001,'TolRLPFun',0.0000001,'MaxNodes',50000,'MaxIter',50000);

tic
[x_star,fval,exitflag,output,mu] = cplexqp(H_params,f_params,Aineq,bineq,Aeq,beq,lb,ub,x0,options); %#ok<ASGLU>
toc;

%% Unpack Solution:
% Unpack internal units, demand and flows:
x_star_int = x_star(1:length(x_int));
x_star_reshape = reshape(x_star_int,[length(x_t),T]);
d_star = x_star_reshape(1:length(d_t),:);
g_1_star = x_star_reshape(1+length(d_t):length(d_t)+region_1_no_plants,:);
g_2_star = x_star_reshape(1+length(d_t)+region_1_no_plants:length(d_t)+region_1_no_plants+region_2_no_plants,:);
g_3_star = x_star_reshape(1+length(d_t)+region_1_no_plants+region_2_no_plants:length(d_t)+region_1_no_plants+region_2_no_plants+region_3_no_plants,:);
g_4_star = x_star_reshape(1+length(d_t)+region_1_no_plants+region_2_no_plants+region_3_no_plants:length(d_t)+region_1_no_plants+region_2_no_plants+region_3_no_plants+region_4_no_plants,:);
g_5_star = x_star_reshape(1+length(d_t)+region_1_no_plants+region_2_no_plants+region_3_no_plants+region_4_no_plants:length(d_t)+region_1_no_plants+region_2_no_plants+region_3_no_plants+region_4_no_plants+region_5_no_plants,:);
f_star = x_star_reshape(1+length(d_t)+J:end,:);

% Unpack RECs purchased from outside of PJM:
if rps_const==1
    x_star_ext_rec = x_star(length(x_int)+1:length(x_int)+J_r*S*3);
    tier_1_g_ex = x_star_ext_rec(1:J_r*S);
    tier_1_g_ex_reshape = reshape(tier_1_g_ex,[J_r,S]);
    tier_2_g_ex = x_star_ext_rec(J_r*S+1:J_r*S*2);
    tier_2_g_ex_reshape = reshape(tier_2_g_ex,[J_r,S]);
    solar_g_ex = x_star_ext_rec(J_r*S*2+1:end);
    solar_g_ex_reshape = reshape(solar_g_ex,[J_r,S]);
    tot_tier_1_gen = sum(tier_1_g_ex_reshape);
    tot_tier_2_gen = sum(tier_2_g_ex_reshape);
    tot_solar_gen = sum(solar_g_ex_reshape);
else
    tot_tier_1_gen = zeros(1,S);
    tot_tier_2_gen = zeros(1,S);
    tot_solar_gen = zeros(1,S);
end

% Unpact new units and capacity:
if cap_exp ==1 && rps_const == 0
    x_star_cap_exp = x_star(length(x_int)+1:length(x));
elseif cap_exp ==1 && rps_const == 1
    x_star_cap_exp = x_star(length(x_int)+J_r*S*3+1:length(x));
else
    x_star_cap_exp = [zeros(S*3*T,1);zeros(S*3,1)];
end

g_n_t = x_star_cap_exp(1:S*3*T);
g_n_star = reshape(g_n_t,[S*3 T]);
K_n_t = x_star_cap_exp(S*3*T+1:end);
K_n_star = reshape(K_n_t,[3 S])';
for t = 1:T
    g_n_star_2(:,t) = g_n_star(:,t)*delta(t);
end

% Unpact prices and permit prices:
mu00 = mu.eqlin;
mu_ineq00 = mu.ineqlin;

mu_p_star = mu00(1:I*T);
p_star0 = reshape(mu_p_star,[I,T]);
for t = 1:T
    p_star0(:,t) = -p_star0(:,t)/delta(t);
end
p_star = p_star0;

if rps_const==0 
    mu_REC_star = zeros(S*3,1);
elseif rps_const == 1
    mu_REC_star = mu_ineq00(J_r+1:J_r+S*3);
end


if dr==3
    if policy_sc==1
        save('2022_baseline_results.mat')
    elseif policy_sc==2
        save('2022_MB_NoTrade_results.mat')
    elseif policy_sc==3
        save('2022_MB_Trade_results.mat')
    end
end



end
