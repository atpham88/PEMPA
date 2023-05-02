# PJM+RGGI Multi-market simulation Model for 5 nodes
# Language: Python/Pyomo
# 2017 Calibration
# Pre-existing policies: Clean Air Act Title IV, Nuclear Subsidies, RPS, RGGI
# Finished coding on 04/25/2020 by An Pham

# **********************************************
# Model's Domain Overview:
# **********************************************
# Region 1: PA East
# Region 2: PA West
# Region 3: RPJM East
# Region 4: RPJM Central
# Region 5: RPJM West

# Available aggregated transmission lines:
# PA West to PA East: 1-2
# PA East to RPJM East: 1-3
# PA East to RPJM Central: 1-4
# PA West to RPJM West: 2-5
# BDC to RPJM West: 4-5

# To reset console:
# from IPython import get_ipython
# def __reset__(): get_ipython().magic('reset -sf')
# __reset__()

# import:
import pandas as pd
import numpy as np
from pyomo.environ import *
from pyomo.opt import SolverFactory
from math import *
import time
start_time = time.time()

model = ConcreteModel(name="PJM_2017")

# **********************************************
# Switches:
# **********************************************
trans_const = 1     # Whether or not there's existence of transmission constraint (=1:yes, =0:no)
rps_const = 1       # Whether or not there's existence of RPS (=1:yes, =0:no)
cap_exp = 1         # Whether or not there's capacity expansion (=1:yes, =0:no)
in_RGGI = 1         # Whether or not there's existence of RGGI  (=1:yes, =0:no)
run_on_cluster = 0  # =1: Running on supercomputer system, =0: Running on personal laptop

# **********************************************
# Data and Parameters:
# **********************************************
# Number of nodes, lines,load segment and elasticity of demand:
I = 5                           # Number of nodes
J = 845                         # Number of aggregated EGUs
T = 96                          # Number of load segments
F = 5                           # Number of aggregated transmission lines
J_r = 262                       # Number of EGUs eligible to provide RECs to PJM states
S = 14                          # Number of PJM states
etaD = 0.05                     # Assumed elasticity of demand
tot_loss_pct = 0.03412764857    # Assume system lost % in the power system.
metric_convert = 0.907185       # Convert from short ton to metric ton

if run_on_cluster == 0:
    roc = 'C:/Users/atpha/Documents/Research/PJM Model/Input Data/'
elif run_on_cluster == 1:
    roc = '/storage/work/a/akp5369/Model_in_Matlab/Input Data/'

# 2017 growth rates and capacity factors:
load_growth = 0
oil_gr = 0.199
coal_gr = 0.0078
nuclear_gr = 0
bio_gr = -0.1

cf_gr_hydro = 0.08
cf_gr_wind = 0.024
cf_gr_solar = 0.12
cf_gr_nuclear = 0.029

# Capacity Expansion Parameters:
C_N_PA_g = 70000
C_N_PA_w = 135580
C_N_PA_s = 135000
C_N_RPJM_g = 73900
C_N_RPJM_w = 130000
C_N_RPJM_s = 105000

C_N_g = pd.DataFrame({'capital_cost_gas': [C_N_RPJM_g, C_N_RPJM_g, C_N_RPJM_g, C_N_RPJM_g, C_N_RPJM_g, C_N_RPJM_g,
                              C_N_RPJM_g, C_N_RPJM_g, C_N_RPJM_g, C_N_RPJM_g, C_N_PA_g, C_N_RPJM_g,
                              C_N_RPJM_g, C_N_RPJM_g]})

C_N_w = pd.DataFrame({'capital_cost_wind': [C_N_RPJM_w, C_N_RPJM_w, C_N_RPJM_w, C_N_RPJM_w, C_N_RPJM_w, C_N_RPJM_w,
                               C_N_RPJM_w, C_N_RPJM_w, C_N_RPJM_w, C_N_RPJM_w, C_N_PA_w, C_N_RPJM_w,
                               C_N_RPJM_w, C_N_RPJM_w]})

C_N_s = pd.DataFrame({'capital_cost_solar': [C_N_RPJM_s, C_N_RPJM_s, C_N_RPJM_s, C_N_RPJM_s, C_N_RPJM_s, C_N_RPJM_s,
                                C_N_RPJM_s, C_N_RPJM_s, C_N_RPJM_s, C_N_RPJM_s, C_N_PA_s, C_N_RPJM_s,
                                C_N_RPJM_s, C_N_RPJM_s]})

C_N = C_N_g
C_N['capital_cost_wind'] = C_N_w
C_N['capital_cost_solar'] = C_N_s


# Capacity factor of new units:
avail_g = 0.961
avail_w = 0.295
avail_s = 0.17
avail_N = {'avail_factor': [avail_g, avail_w, avail_s]}
avail_N_fin = avail_N['avail_factor']

# Percentage of total ext REC supply available to use by state:
rec_PA_g_sc = 0.615
rec_RPJM_g_sc = 0.81

# Adjusted variable operation and maintenance costs:
vom_wind = 3.38
vom_hydro = 3.5
vom_solar = 5.4
vom_nuclear = 4.28

vom_bio_PA = 17.0
vom_bio_RPJM = 3.5

vom_gas_PA_winter = 22
vom_gas_RPJM_winter = 14.5
vom_gas_PA_spring = 7.3
vom_gas_RPJM_spring = 5.2
vom_gas_PA_summer = 14.8
vom_gas_RPJM_summer = 12.2
vom_gas_PA_fall = 16.3
vom_gas_RPJM_fall = 13.8

vom_oil_PA = 1.8
vom_oil_RPJM = 0.2

vom_coal_PA_winter = 1.25
vom_coal_RPJM_winter = 1.25
vom_coal_PA_spring = 1.25
vom_coal_RPJM_spring = 1.25
vom_coal_PA_summer = 1.25
vom_coal_RPJM_summer = 1.25
vom_coal_PA_fall = 1.25
vom_coal_RPJM_fall = 1.25

f_cs_bio = 1.25

f_cs_coal_winter = 1.45
f_cs_gas_winter = 0.83
f_cs_oil_winter = 0.61

f_cs_coal_spring = 1.45
f_cs_gas_spring = 0.75
f_cs_oil_spring = 0.8

f_cs_coal_summer = 1.45
f_cs_gas_summer = 0.83
f_cs_oil_summer = 0.61

f_cs_coal_fall = 1.45
f_cs_gas_fall = 0.83
f_cs_oil_fall = 0.61


# State-level Clean Energy Standards (RPS) - tier 1 and tier 2:
re_1_tier_1 = 0.135                               # RPS standard for DC - tier 1
re_1_tier_2 = 0.015                               # RPS standard for DC - tier 2

re_2_tier_1 = 0.16                                # RPS standard for DE
re_2_tier_2 = 0                                   # RPS standard for DE

re_3_tier_1 = 0.115                               # RPS standard for IL
re_3_tier_2 = 0                                   # RPS standard for IL

re_4_tier_1 = 0                                   # RPS standard for IN
re_4_tier_2 = 0                                   # RPS standard for IN

re_5_no_tier = 0                                  # RPS standard for KY

re_6_tier_1 = 0.1310                              # RPS standard for MD tier 1
re_6_tier_2 = 0.025                               # RPS standard for MD tier 2

re_7_tier_1 = 0.10                                # RPS standard for MI
re_7_tier_2 = 0                                   # RPS standard for MI

re_8_tier_1 = 0.06                                # RPS standard for NC
re_8_tier_2 = 0                                   # RPS standard for NC

re_9_tier_1 = 0.135                               # RPS standard for NJ tier 1
re_9_tier_2 = 0.025                               # RPS standard for NJ tier 2

re_10_tier_1 = 0.055                              # RPS standard for OH
re_10_tier_2 = 0                                  # RPS standard for OH

re_11_tier_1 = 0.06                               # RPS standard for PA tier 1
re_11_tier_2 = 0.082                              # RPS standard for PA tier 2

re_12_no_tier = 0                                 # RPS standard for TN
re_13_no_tier = 0                                 # RPS standard for VA
re_14_no_tier = 0                                 # RPS standard for WV

# State-level Clean Energy Standards (RPS) - solar:
se_1 = 0.0098                                     # solar standard for DC
se_2 = 0.015                                      # solar standard for DE
se_3 = 0.0069                                     # solar standard for IL
se_4 = 0                                          # solar standard for IN
se_5 = 0                                          # solar standard for KY
se_6 = 0.0115                                     # solar standard for MD
se_7 = 0                                          # solar standard for MI
se_8 = 0.0014                                     # solar standard for NC
se_9 = 0.03                                       # solar standard for NJ
se_10 = 0.0022                                    # solar standard for OH
se_11 = 0.002933                                  # solar standard for PA
se_12 = 0                                         # solar standard for TN
se_13 = 0                                         # solar standard for VA
se_14 = 0                                         # solar standard for WV

re_tier_1 = {'rps_t1': [re_1_tier_1, re_2_tier_1, re_3_tier_1, re_4_tier_1, re_5_no_tier, re_6_tier_1, re_7_tier_1,
                       re_8_tier_1, re_9_tier_1, re_10_tier_1, re_11_tier_1, re_12_no_tier,
                       re_13_no_tier, re_14_no_tier]}

re_tier_2 = {'rps_t2': [re_1_tier_2, re_2_tier_2, re_3_tier_2, re_4_tier_2, re_5_no_tier, re_6_tier_2, re_7_tier_2,
                       re_8_tier_2, re_9_tier_2, re_10_tier_2, re_11_tier_2, re_12_no_tier,
                       re_13_no_tier, re_14_no_tier]}

se = {'srps': [se_1, se_2, se_3, se_4, se_5, se_6, se_7, se_8, se_9, se_10, se_11, se_12, se_13, se_14]}


# Adding generation for states that are half outside of PJM:
lg = -0.02356
x_gen_tot_DC = 0
x_gen_tot_DE = 0
x_gen_tot_IL = 97584668*(1+lg)
x_gen_tot_IN = 93556369*(1+lg)
x_gen_tot_KY = 67283806*(1+lg)
x_gen_tot_MD = 0
x_gen_tot_MI = 92436894*(1+lg)
x_gen_tot_NC = 128208602*(1+lg)
x_gen_tot_NJ = 0
x_gen_tot_OH = 0
x_gen_tot_PA = 0
x_gen_tot_TN = 78868763*(1+lg)
x_gen_tot_VA = 0
x_gen_tot_WV = 0

x_gen_tier1_DC = 0
x_gen_tier1_DE = 0
x_gen_tier1_IL = 4486290*(1+lg)
x_gen_tier1_IN = 1678770*(1+lg)
x_gen_tier1_KY = 3535757*(1+lg)
x_gen_tier1_MD = 0
x_gen_tier1_MI = 8747953*(1+lg)
x_gen_tier1_NC = 9311657*(1+lg)
x_gen_tier1_NJ = 0
x_gen_tier1_OH = 0
x_gen_tier1_PA = 0
x_gen_tier1_TN = 7823792*(1+lg)
x_gen_tier1_VA = 0
x_gen_tier1_WV = 0

x_gen_tier2_DC = 0
x_gen_tier2_DE = 0
x_gen_tier2_IL = 0
x_gen_tier2_IN = 0
x_gen_tier2_KY = 0
x_gen_tier2_MD = 0
x_gen_tier2_MI = 0
x_gen_tier2_NC = 0
x_gen_tier2_NJ = 0
x_gen_tier2_OH = 0
x_gen_tier2_PA = 0
x_gen_tier2_TN = 0
x_gen_tier2_VA = 0
x_gen_tier2_WV = 0

x_gen_solar_DC = 0
x_gen_solar_DE = 0
x_gen_solar_IL = 34610*(1+lg)
x_gen_solar_IN = 218641*(1+lg)
x_gen_solar_KY = 11732*(1+lg)
x_gen_solar_MD = 0
x_gen_solar_MI = 9235*(1+lg)
x_gen_solar_NC = 3101628*(1+lg)
x_gen_solar_NJ = 0
x_gen_solar_OH = 0
x_gen_solar_PA = 0
x_gen_solar_TN = 78617*(1+lg)
x_gen_solar_VA = 0
x_gen_solar_WV = 0

x_gen_tot = {'x_gen_tot': [x_gen_tot_DC, x_gen_tot_DE, x_gen_tot_IL, x_gen_tot_IN, x_gen_tot_KY,
                       x_gen_tot_MD, x_gen_tot_MI, x_gen_tot_NC, x_gen_tot_NJ, x_gen_tot_OH,
                       x_gen_tot_PA, x_gen_tot_TN, x_gen_tot_VA, x_gen_tot_WV]}

x_gen_tier1 = {'x_gen_t1': [x_gen_tier1_DC, x_gen_tier1_DE, x_gen_tier1_IL, x_gen_tier1_IN, x_gen_tier1_KY,
                         x_gen_tier1_MD, x_gen_tier1_MI, x_gen_tier1_NC, x_gen_tier1_NJ, x_gen_tier1_OH,
                         x_gen_tier1_PA, x_gen_tier1_TN, x_gen_tier1_VA, x_gen_tier1_WV]}

x_gen_tier2 = {'x_gen_t2': [x_gen_tier2_DC, x_gen_tier2_DE, x_gen_tier2_IL, x_gen_tier2_IN, x_gen_tier2_KY, x_gen_tier2_MD,
                         x_gen_tier2_MI, x_gen_tier2_NC, x_gen_tier2_NJ, x_gen_tier2_OH, x_gen_tier2_PA,
                         x_gen_tier2_TN, x_gen_tier2_VA, x_gen_tier2_WV]}

x_gen_solar = {'x_gen_s': [x_gen_solar_DC, x_gen_solar_DE, x_gen_solar_IL, x_gen_solar_IN, x_gen_solar_KY, x_gen_solar_MD,
                         x_gen_solar_MI, x_gen_solar_NC, x_gen_solar_NJ, x_gen_solar_OH, x_gen_solar_PA,
                         x_gen_solar_TN, x_gen_solar_VA, x_gen_solar_WV]}

x_gen = {'x_gen': [x_gen_tot, x_gen_tier1, x_gen_tier2, x_gen_solar]}

# Read Data:
# Read Demand Data:
if run_on_cluster == 0:
    demand_curve = roc+'Demand Data/Demand Curves_96_2017_v3.xlsx'
elif run_on_cluster ==1:
    demand_curve = roc+'Demand Curves_96_2017_v3.xlsx'

load_data_region_1_temp = pd.read_excel(demand_curve, 'region 1')
load_data_region_2_temp = pd.read_excel(demand_curve, 'region 2')
load_data_region_3_temp = pd.read_excel(demand_curve, 'region 3')
load_data_region_4_temp = pd.read_excel(demand_curve, 'region 4')
load_data_region_5_temp = pd.read_excel(demand_curve, 'region 5')

hours_temp = pd.read_excel(demand_curve, 'hours')
delta_temp = hours_temp['no_of_hr_by_segment']
delta = delta_temp[0:T]

# Read Transmission Network Data:
if run_on_cluster == 0:
    transmission_network = roc + 'Transmission/Transmission Networks.xlsx'
elif run_on_cluster == 1:
    transmission_network = roc + 'Transmission Networks.xlsx'

transmission_data_temp = pd.read_excel(transmission_network, 'Transmission Network')
transmission_data = transmission_data_temp.iloc[[0,1,2,6,9],[20]]

# Virtual Bid:
if run_on_cluster == 0:
    virtual_bid = roc + 'Virtual Bids/results_no_trans_const3.xlsx'
elif run_on_cluster == 1:
    virtual_bid = roc + 'results_no_trans_const3.xlsx'

zdata = pd.read_excel(virtual_bid, 'beta')
net_vb = zdata['loss_lmp_ratio']

# Transmission Factor:
if run_on_cluster == 0:
    trans_factor = roc + 'trans_scaler.xlsx'
elif run_on_cluster == 1:
    trans_factor = roc + 'trans_scaler.xlsx'

trans_factor_data = pd.read_excel(trans_factor, 'Sheet1')

# Read Supplier Data:
if run_on_cluster == 0:
    supply_curve = roc + 'Supply Data/Supply_Curve_2017.xlsx'
elif run_on_cluster == 1:
    supply_curve = roc + 'Supply_Curve_2017.xlsx'

supply_data = pd.read_excel(supply_curve, 'supply curve')

state = supply_data['state']
rps_tier_1_ratio = supply_data['RPS_ratio_tier_1']
rps_tier_2_ratio = supply_data['RPS_ratio_tier_2']
lmp_region = supply_data['LMP_region']

region_1_no_plants = np.count_nonzero(lmp_region == 1)
region_2_no_plants = np.count_nonzero(lmp_region == 2)
region_3_no_plants = np.count_nonzero(lmp_region == 3)
region_4_no_plants = np.count_nonzero(lmp_region == 4)
region_5_no_plants = np.count_nonzero(lmp_region == 5)
pjm_no_plants = region_1_no_plants + region_2_no_plants + region_3_no_plants + region_4_no_plants + region_5_no_plants

# states in each region:
state_1 = state.iloc[0:region_1_no_plants]
state_2 = state.iloc[region_1_no_plants:region_1_no_plants + region_2_no_plants]
state_3 = state.iloc[region_1_no_plants + region_2_no_plants:region_1_no_plants +
                       region_2_no_plants + region_3_no_plants]
state_4 = state.iloc[region_1_no_plants + region_2_no_plants +
                       region_3_no_plants:region_1_no_plants + region_2_no_plants +
                       region_3_no_plants + region_4_no_plants]
state_5 = state.iloc[region_1_no_plants + region_2_no_plants + region_3_no_plants +
                       region_4_no_plants:]

# Gas price growth rate:
gas_gr = supply_data.iloc[:, 114:210]
gas_gr_1 = gas_gr.iloc[0:region_1_no_plants, :]
gas_gr_2 = gas_gr.iloc[region_1_no_plants:region_1_no_plants + region_2_no_plants, :]
gas_gr_3 = gas_gr.iloc[region_1_no_plants + region_2_no_plants:region_1_no_plants +
                       region_2_no_plants + region_3_no_plants, :]
gas_gr_4 = gas_gr.iloc[region_1_no_plants + region_2_no_plants +
                       region_3_no_plants:region_1_no_plants + region_2_no_plants +
                       region_3_no_plants + region_4_no_plants, :]
gas_gr_5 = gas_gr.iloc[region_1_no_plants + region_2_no_plants + region_3_no_plants +
                       region_4_no_plants:, :]

supply_data_1 = supply_data.iloc[0:region_1_no_plants, :]
supply_data_2 = supply_data.iloc[region_1_no_plants:region_1_no_plants + region_2_no_plants, :]
supply_data_3 = supply_data.iloc[region_1_no_plants + region_2_no_plants:region_1_no_plants +
                            region_2_no_plants + region_3_no_plants, :]
supply_data_4 = supply_data.iloc[region_1_no_plants + region_2_no_plants +
                            region_3_no_plants:region_1_no_plants +
                            region_2_no_plants + region_3_no_plants + region_4_no_plants, :]
supply_data_5 = supply_data.iloc[region_1_no_plants + region_2_no_plants +
                            region_3_no_plants + region_4_no_plants:, :]

cap_region_1 = supply_data_1['capacity_by_bin']
cap_region_2 = supply_data_2['capacity_by_bin']
cap_region_3 = supply_data_3['capacity_by_bin']
cap_region_4 = supply_data_4['capacity_by_bin']
cap_region_5 = supply_data_5['capacity_by_bin']
cap_region_t = supply_data['capacity_by_bin']

# REC units:
if run_on_cluster == 0:
    REC_units = roc + 'External RECs/REC_units_clear2.xlsx'
elif run_on_cluster == 1:
    REC_units = roc + 'REC_units_clear2.xlsx'

tier1_units_data = pd.read_excel(REC_units, 'tier 1')
tier2_units_data = pd.read_excel(REC_units, 'tier 2')
solar_units_data = pd.read_excel(REC_units, 'solar')
all_units_data = pd.read_excel(REC_units, 'All Units')

g_all_tot = all_units_data['tot gen']
rec_region = all_units_data['region']
rec_state = all_units_data['states']

tier_1_cat = tier1_units_data['rec_tier_1']
tier_2_cat = tier2_units_data['rec_tier_2']
solar_cat = solar_units_data['srec']
rec_state_tier1 = tier1_units_data['state']
rec_state_tier2 = tier2_units_data['state']
rec_state_solar = solar_units_data['state']

unit_dummy_tier1_temp = tier1_units_data.iloc[:, 0:S]
unit_dummy_tier2_temp = tier2_units_data.iloc[:, 0:S]
unit_dummy_solar_temp = solar_units_data.iloc[:, 0:S]

tier_1_cat_tile = np.transpose(np.tile(tier_1_cat.values, (S, 1)))
tier_2_cat_tile = np.transpose(np.tile(tier_2_cat.values, (S, 1)))
solar_cat_tile = np.transpose(np.tile(solar_cat.values, (S, 1)))

unit_dummy_tier1 = unit_dummy_tier1_temp * tier_1_cat_tile
unit_dummy_tier2 = unit_dummy_tier2_temp * tier_2_cat_tile
unit_dummy_solar = unit_dummy_solar_temp * solar_cat_tile

# Flow constraints (in 10 lines):
trans_factor = trans_factor_data

# Read emission intensity data:
emission_data = supply_data['ei_by_bin_ton']
emission_data_1 = emission_data[1:region_1_no_plants]
emission_data_2 = emission_data[region_1_no_plants:region_1_no_plants + region_2_no_plants]
emission_data_3 = emission_data[region_1_no_plants + region_2_no_plants:region_1_no_plants +
                                region_2_no_plants + region_3_no_plants]
emission_data_4 = emission_data[region_1_no_plants + region_2_no_plants +
                                region_3_no_plants:region_1_no_plants +
                                region_2_no_plants + region_3_no_plants + region_4_no_plants]
emission_data_5 = emission_data[region_1_no_plants + region_2_no_plants +
                                region_3_no_plants + region_4_no_plants:]

rec_g_sc_all = pd.DataFrame(np.zeros(J_r))

for j in range(J_r):
    if rec_region[j] == 1:
        rec_g_sc_all.iloc[j] = rec_PA_g_sc
    else:
        rec_g_sc_all.iloc[j] = rec_RPJM_g_sc

# Emissions intensity converted to metric ton per MWh
ei_region_1 = emission_data_1 * metric_convert
ei_region_2 = emission_data_2 * metric_convert
ei_region_3 = emission_data_3 * metric_convert
ei_region_4 = emission_data_4 * metric_convert
ei_region_5 = emission_data_5 * metric_convert

# Fuel-type:
fuel_region_1 = supply_data_1['fueltype']
fuel_region_2 = supply_data_2['fueltype']
fuel_region_3 = supply_data_3['fueltype']
fuel_region_4 = supply_data_4['fueltype']
fuel_region_5 = supply_data_5['fueltype']
fuel_region_t = supply_data['fueltype']

# Capacity Scaler:
cs_coal_PA = 0.997082931*1.004
cs_hydro_PA = 0.986734678
cs_gas_PA = 0.834969638
cs_nuclear_PA = 0.908225067
cs_oil_PA = 0.921889581
cs_wind_PA = 0.884053657
cs_bio_PA = 0.870537542
cs_solar_PA = 0.935752345

cs_coal_RPJM = 1.212691835*1.004
cs_hydro_RPJM = 0.967782977
cs_gas_RPJM = 0.989663052
cs_nuclear_RPJM = 1.216346754
cs_oil_RPJM = 0.982988775
cs_wind_RPJM = 1.586726142
cs_bio_RPJM = 0.890537542
cs_solar_RPJM = 0.333057297

# Capacity Factors:
cf_hydro_PA = 0.108869594+0.006
cf_wind_PA = 0.288445696+0.009
cf_solar_PA = 0.16098141-0.006
cf_nuclear_PA = 0.963595727+0.008

cf_hydro_RPJM = 0.222765215+0.024
cf_wind_RPJM = 0.273548196+0.049
cf_solar_RPJM = 0.2205+0.031
cf_nuclear_RPJM = 0.892684446+0.038

# Total Marginal Costs:
marginal_cost_1 = supply_data_1.iloc[:, 4:100]
marginal_cost_2 = supply_data_2.iloc[:, 4:100]
marginal_cost_3 = supply_data_3.iloc[:, 4:100]
marginal_cost_4 = supply_data_4.iloc[:, 4:100]
marginal_cost_5 = supply_data_5.iloc[:, 4:100]

# Marginal costs of newly expanded EGUs:
MC_N_PA_g = 21
MC_N_PA_w = 0
MC_N_PA_s = 0

MC_N_RPJM_g = 23.5
MC_N_RPJM_w = 0
MC_N_RPJM_s = 0

MC_N_g = pd.DataFrame({'mc_g': [MC_N_RPJM_g, MC_N_RPJM_g, MC_N_RPJM_g, MC_N_RPJM_g, MC_N_RPJM_g, MC_N_RPJM_g,
                   MC_N_RPJM_g, MC_N_RPJM_g, MC_N_RPJM_g, MC_N_RPJM_g, MC_N_PA_g, MC_N_RPJM_g,
                   MC_N_RPJM_g, MC_N_RPJM_g]})

MC_N_w = pd.DataFrame({'mc_w': [MC_N_RPJM_w, MC_N_RPJM_w, MC_N_RPJM_w, MC_N_RPJM_w, MC_N_RPJM_w, MC_N_RPJM_w,
                   MC_N_RPJM_w, MC_N_RPJM_w, MC_N_RPJM_w, MC_N_RPJM_w, MC_N_PA_w, MC_N_RPJM_w,
                   MC_N_RPJM_w, MC_N_RPJM_w]})

MC_N_s = pd.DataFrame({'mc_s': [MC_N_RPJM_s, MC_N_RPJM_s, MC_N_RPJM_s, MC_N_RPJM_s, MC_N_RPJM_s, MC_N_RPJM_s,
                   MC_N_RPJM_s, MC_N_RPJM_s, MC_N_RPJM_s, MC_N_RPJM_s, MC_N_PA_s, MC_N_RPJM_s,
                   MC_N_RPJM_s, MC_N_RPJM_s]})

MC_N = MC_N_g
MC_N['mc_w'] = MC_N_w
MC_N['mc_s'] = MC_N_s

# Demand  parameters virtual bid percentage:
z = zdata['z']/100
lost_component = 1+tot_loss_pct-net_vb

b_1 = marginal_cost_1
b_2 = marginal_cost_2
b_3 = marginal_cost_3
b_4 = marginal_cost_4
b_5 = marginal_cost_5
b = pd.concat([b_1, b_2, b_3, b_4, b_5])

m_1 = 0 * b_1
m_2 = 0 * b_2
m_3 = 0 * b_3
m_4 = 0 * b_4
m_5 = 0 * b_5
m = pd.concat([m_1, m_2, m_3, m_4, m_5])

# Total Hourly loads in each region:
load_region_1 = load_data_region_1_temp['final_load']*(1 + load_growth)
load_region_2 = load_data_region_2_temp['final_load']*(1 + load_growth)
load_region_3 = load_data_region_3_temp['final_load']*(1 + load_growth)
load_region_4 = load_data_region_4_temp['final_load']*(1 + load_growth)
load_region_5 = load_data_region_5_temp['final_load']*(1 + load_growth)

# Average LMPs in each region:
p_region_1 = load_data_region_1_temp['DA_final_segment_lmp']
p_region_2 = load_data_region_2_temp['DA_final_segment_lmp']
p_region_3 = load_data_region_3_temp['DA_final_segment_lmp']
p_region_4 = load_data_region_4_temp['DA_final_segment_lmp']
p_region_5 = load_data_region_5_temp['DA_final_segment_lmp']

load_region_by_t_1 = load_region_1 / delta.values
load_region_by_t_2 = load_region_2 / delta.values
load_region_by_t_3 = load_region_3 / delta.values
load_region_by_t_4 = load_region_4 / delta.values
load_region_by_t_5 = load_region_5 / delta.values

# Demand curve intercepts(c) and slope(n):
n_1 = (1 / etaD)*(p_region_1 / load_region_by_t_1.values)
n_2 = (1 / etaD)*(p_region_2 / load_region_by_t_2.values)
n_3 = (1 / etaD)*(p_region_3 / load_region_by_t_3.values)
n_4 = (1 / etaD)*(p_region_4 / load_region_by_t_4.values)
n_5 = (1 / etaD)*(p_region_5 / load_region_by_t_5.values)
n = pd.concat([pd.DataFrame(n_1).transpose(), pd.DataFrame(n_2).transpose(), pd.DataFrame(n_3).transpose(),
               pd.DataFrame(n_4).transpose(), pd.DataFrame(n_5).transpose()])

c_1 = (1 + (1 / etaD)) * p_region_1
c_2 = (1 + (1 / etaD)) * p_region_2
c_3 = (1 + (1 / etaD)) * p_region_3
c_4 = (1 + (1 / etaD)) * p_region_4
c_5 = (1 + (1 / etaD)) * p_region_5
c = pd.concat([pd.DataFrame(c_1).transpose(), pd.DataFrame(c_2).transpose(), pd.DataFrame(c_3).transpose(),
               pd.DataFrame(c_4).transpose(), pd.DataFrame(c_5).transpose()])

if trans_const == 1:
    fbar_t = (pd.concat([transmission_data]*T, axis=1, ignore_index=True)) * trans_factor.values

elif trans_const == 0:
    fbar_12 = 999999
    fbar_13 = 999999
    fbar_14 = 999999
    fbar_25 = 999999
    fbar_45 = 999999
    fbar_t = pd.concat([pd.DataFrame([fbar_12, fbar_13, fbar_14, fbar_25, fbar_45])]*T, axis=1, ignore_index=True)

# ****************FINISH READING DATA****************************************

# ****************MODEL BEGINS***********************************************

# ***************************
# Define sets:
# ***************************
model.D = list(range(I))
model.G_in = list(range(J))
model.Fl = list(range(F))
model.S = list(range(S))
model.Ex_rec = list(range(J_r))
model.T = list(range(T))
model.Ft = list(range(3))


# ***************************
# Define parameters:
# ***************************
model.f_param = pd.DataFrame({'region_1': [1, 1, 1, 0, 0], 'region_2':[-1, 0, 0, 1, 0],
                 'region_3':[0, -1, 0, 0, 0], 'region_4':[0, 0, -1, 0, 1], 'region_5':[0, 0, 0, -1, -1]})

model.f_param_T = model.f_param.transpose()

model.state_region = pd.DataFrame({'region_1': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.586434045, 0, 0, 0],
                      'region_2': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.413565955, 0, 0, 0],
                      'region_3': [0, 1, 0, 0, 0, 0, 0, 0, 0.228034644, 0, 0, 0, 0, 0],
                      'region_4': [1, 0, 0, 0, 0, 0.912229612, 0, 1, 0, 0, 0, 0, 0.800495305, 0.004136931],
                      'region_5': [0, 0, 1, 1, 1, 0.087770388, 1, 0, 0.771965356, 1, 0, 1, 0.199504695, 0.995863069]})

model.state_region_T = model.state_region.transpose()

# ***************************
# Define bounds:
# ***************************
# For existing units:
cap_scaler_1 = pd.DataFrame(np.zeros(shape=(region_1_no_plants,1)))
cap_scaler_2 = pd.DataFrame(np.zeros(shape=(region_2_no_plants,1)))
cap_scaler_3 = pd.DataFrame(np.zeros(shape=(region_3_no_plants,1)))
cap_scaler_4 = pd.DataFrame(np.zeros(shape=(region_4_no_plants,1)))
cap_scaler_5 = pd.DataFrame(np.zeros(shape=(region_5_no_plants,1)))

egu_bin_1 = supply_data_1['bin']
egu_bin_2 = supply_data_2['bin']
egu_bin_3 = supply_data_3['bin']
egu_bin_4 = supply_data_4['bin']
egu_bin_5 = supply_data_5['bin']

for ju in range(region_1_no_plants):
    if fuel_region_1.iloc[ju] == 1 and egu_bin_1.iloc[ju] < 2000:
        cap_scaler_1.iloc[ju] = cs_bio_PA * 0.961
    elif fuel_region_1.iloc[ju] == 2 and egu_bin_1.iloc[ju] < 2000:
        cap_scaler_1.iloc[ju] = cs_coal_PA * 0.961
    elif fuel_region_1.iloc[ju] == 3 and egu_bin_1.iloc[ju]< 2000:
        cap_scaler_1.iloc[ju] = cs_hydro_PA * cf_hydro_PA
    elif fuel_region_1.iloc[ju] == 4 and egu_bin_1.iloc[ju] < 2000:
        cap_scaler_1.iloc[ju] = cs_nuclear_PA * cf_nuclear_PA
    elif fuel_region_1.iloc[ju] == 5 and egu_bin_1.iloc[ju] < 2000:
        cap_scaler_1.iloc[ju] = 0.961
    elif fuel_region_1.iloc[ju] == 6 and egu_bin_1.iloc[ju] < 2000:
        cap_scaler_1.iloc[ju] = cs_oil_PA * 0.961
    elif fuel_region_1.iloc[ju] == 7 and egu_bin_1.iloc[ju] < 2000:
        cap_scaler_1.iloc[ju] = cs_solar_PA * cf_solar_PA
    elif fuel_region_1.iloc[ju] == 8 and egu_bin_1.iloc[ju] < 2000:
        cap_scaler_1.iloc[ju] = cs_wind_PA * cf_wind_PA
    elif fuel_region_1.iloc[ju] == 9 and egu_bin_1.iloc[ju] < 2000:
        cap_scaler_1.iloc[ju] = cs_gas_PA * 0.961

for ju in range(region_2_no_plants):
    if fuel_region_2.iloc[ju] == 1 and egu_bin_2.iloc[ju] < 2000:
        cap_scaler_2.iloc[ju] = cs_bio_PA * 0.961
    elif fuel_region_2.iloc[ju] == 2 and egu_bin_2.iloc[ju] < 2000:
        cap_scaler_2.iloc[ju] = cs_coal_PA * 0.961
    elif fuel_region_2.iloc[ju] == 3 and egu_bin_2.iloc[ju] < 2000:
        cap_scaler_2.iloc[ju] = cs_hydro_PA * cf_hydro_PA
    elif fuel_region_2.iloc[ju] == 4 and egu_bin_2.iloc[ju] < 2000:
        cap_scaler_2.iloc[ju] = cs_nuclear_PA * cf_nuclear_PA
    elif fuel_region_2.iloc[ju] == 5 and egu_bin_2.iloc[ju] < 2000:
        cap_scaler_2.iloc[ju] = 0.961
    elif fuel_region_2.iloc[ju] == 6 and egu_bin_2.iloc[ju] < 2000:
        cap_scaler_2.iloc[ju] = cs_oil_PA * 0.961
    elif fuel_region_2.iloc[ju] == 7 and egu_bin_2.iloc[ju] < 2000:
        cap_scaler_2.iloc[ju] = cs_solar_PA * cf_solar_PA
    elif fuel_region_2.iloc[ju] == 8 and egu_bin_2.iloc[ju] < 2000:
        cap_scaler_2.iloc[ju] = cs_wind_PA * cf_wind_PA
    elif fuel_region_2.iloc[ju] == 9 and egu_bin_2.iloc[ju] < 2000:
        cap_scaler_2.iloc[ju] = cs_gas_PA * 0.961

for ju in range(region_3_no_plants):
    if fuel_region_3.iloc[ju] == 1 and egu_bin_3.iloc[ju] < 2000:
        cap_scaler_3.iloc[ju] = cs_bio_RPJM * 0.961
    elif fuel_region_3.iloc[ju] == 2 and egu_bin_3.iloc[ju] < 2000:
        cap_scaler_3.iloc[ju] = cs_coal_RPJM * 0.961
    elif fuel_region_3.iloc[ju] == 3 and egu_bin_3.iloc[ju] < 2000:
        cap_scaler_3.iloc[ju] = cs_hydro_RPJM * cf_hydro_RPJM
    elif fuel_region_3.iloc[ju] == 4 and egu_bin_3.iloc[ju] < 2000:
        cap_scaler_3.iloc[ju] = cs_nuclear_RPJM * cf_nuclear_RPJM
    elif fuel_region_3.iloc[ju] == 5 and egu_bin_3.iloc[ju] < 2000:
        cap_scaler_3.iloc[ju] = 0.961
    elif fuel_region_3.iloc[ju] == 6 and egu_bin_3.iloc[ju] < 2000:
        cap_scaler_3.iloc[ju] = cs_oil_RPJM * 0.961
    elif fuel_region_3.iloc[ju] == 7 and egu_bin_3.iloc[ju] < 2000:
        cap_scaler_3.iloc[ju] = cs_solar_RPJM * cf_solar_RPJM
    elif fuel_region_3.iloc[ju] == 8 and egu_bin_3.iloc[ju] < 2000:
        cap_scaler_3.iloc[ju] = cs_wind_RPJM * cf_wind_RPJM
    elif fuel_region_3.iloc[ju] == 9 and egu_bin_3.iloc[ju] < 2000:
        cap_scaler_3.iloc[ju] = cs_gas_RPJM * 0.961

for ju in range(region_4_no_plants):
    if fuel_region_4.iloc[ju] == 1 and egu_bin_4.iloc[ju] < 2000:
        cap_scaler_4.iloc[ju] = cs_bio_RPJM * 0.961
    elif fuel_region_4.iloc[ju] == 2 and egu_bin_4.iloc[ju] < 2000:
        cap_scaler_4.iloc[ju] = cs_coal_RPJM * 0.961
    elif fuel_region_4.iloc[ju] == 3 and egu_bin_4.iloc[ju] < 2000:
        cap_scaler_4.iloc[ju] = cs_hydro_RPJM * cf_hydro_RPJM
    elif fuel_region_4.iloc[ju] == 4 and egu_bin_4.iloc[ju] < 2000:
        cap_scaler_4.iloc[ju] = cs_nuclear_RPJM * cf_nuclear_RPJM
    elif fuel_region_4.iloc[ju] == 5 and egu_bin_4.iloc[ju] < 2000:
        cap_scaler_4.iloc[ju] = 0.961
    elif fuel_region_4.iloc[ju] == 6 and egu_bin_4.iloc[ju] < 2000:
        cap_scaler_4.iloc[ju] = cs_oil_RPJM * 0.961
    elif fuel_region_4.iloc[ju] == 7 and egu_bin_4.iloc[ju] < 2000:
        cap_scaler_4.iloc[ju] = cs_solar_RPJM * cf_solar_RPJM
    elif fuel_region_4.iloc[ju] == 8 and egu_bin_4.iloc[ju] < 2000:
        cap_scaler_4.iloc[ju] = cs_wind_RPJM * cf_wind_RPJM
    elif fuel_region_4.iloc[ju] == 9 and egu_bin_4.iloc[ju] < 2000:
        cap_scaler_4.iloc[ju] = cs_gas_RPJM * 0.961

for ju in range(region_5_no_plants):
    if fuel_region_5.iloc[ju] == 1 and egu_bin_5.iloc[ju] < 2000:
        cap_scaler_5.iloc[ju] = cs_bio_RPJM * 0.961
    elif fuel_region_5.iloc[ju] == 2 and egu_bin_5.iloc[ju] < 2000:
        cap_scaler_5.iloc[ju] = cs_coal_RPJM * 0.961
    elif fuel_region_5.iloc[ju] == 3 and egu_bin_5.iloc[ju] < 2000:
        cap_scaler_5.iloc[ju] = cs_hydro_RPJM * cf_hydro_RPJM
    elif fuel_region_5.iloc[ju] == 4 and egu_bin_5.iloc[ju] < 2000:
        cap_scaler_5.iloc[ju] = cs_nuclear_RPJM * cf_nuclear_RPJM
    elif fuel_region_5.iloc[ju] == 5 and egu_bin_5.iloc[ju] < 2000:
        cap_scaler_5.iloc[ju] = 0.961
    elif fuel_region_5.iloc[ju] == 6 and egu_bin_5.iloc[ju] < 2000:
        cap_scaler_5.iloc[ju] = cs_oil_RPJM * 0.961
    elif fuel_region_5.iloc[ju] == 7 and egu_bin_5.iloc[ju] < 2000:
        cap_scaler_5.iloc[ju] = cs_solar_RPJM * cf_solar_RPJM
    elif fuel_region_5.iloc[ju] == 8 and egu_bin_5.iloc[ju] < 2000:
        cap_scaler_5.iloc[ju] = cs_wind_RPJM * cf_wind_RPJM
    elif fuel_region_5.iloc[ju] == 9 and egu_bin_5.iloc[ju] < 2000:
        cap_scaler_5.iloc[ju] = cs_gas_RPJM * 0.961

cap_scaler = pd.concat([cap_scaler_1, cap_scaler_2, cap_scaler_3, cap_scaler_4, cap_scaler_5], ignore_index=True)
upper_b_gen_in =  pd.DataFrame(cap_region_t) * cap_scaler.values
upper_b_gen_in_all = upper_b_gen_in.to_dict()

# For external REC units:
ub_new_g_tier1_temp = unit_dummy_tier1* np.tile(pd.DataFrame(g_all_tot).values,S) * np.tile(rec_g_sc_all.values,S)
ub_new_g_tier2_temp = unit_dummy_tier2* np.tile(pd.DataFrame(g_all_tot).values,S) * np.tile(rec_g_sc_all.values,S)
ub_new_g_solar_temp = unit_dummy_solar* np.tile(pd.DataFrame(g_all_tot).values,S) * np.tile(rec_g_sc_all.values,S)

ub_new_g_tier1_temp.iloc[:, 3:5] = np.zeros((J_r, 2))
ub_new_g_tier1_temp.iloc[:, 7] = np.zeros(J_r)
ub_new_g_tier1_temp.iloc[:, 11:14] = np.zeros((J_r,3))
ub_new_g_tier2_temp.iloc[:, 3:5] = np.zeros((J_r, 2))
ub_new_g_tier2_temp.iloc[:, 7] = np. zeros(J_r)
ub_new_g_tier2_temp.iloc[:, 11:14] = np.zeros((J_r,3))
ub_new_g_solar_temp.iloc[:, 3:5] = np.zeros((J_r, 2))
ub_new_g_solar_temp.iloc[:, 7] = np. zeros(J_r)
ub_new_g_solar_temp.iloc[:, 11:14] = np.zeros((J_r,3))

ub_g_rec_tier1 = ub_new_g_tier1_temp
ub_g_rec_tier2 = ub_new_g_tier2_temp
ub_g_rec_solar = ub_new_g_solar_temp


# ***************************
# Define variables:
# ***************************
# Load:
model.d = Var(model.D, model.T, within=NonNegativeReals)

# Generation from existing EGUs:
capacity_by_bin = upper_b_gen_in_all['capacity_by_bin']

def gen_in_bounds(m, g_in, t):
    return (0, capacity_by_bin[g_in])

model.gen_in = Var(model.G_in, model.T, bounds=gen_in_bounds)

# Flows:
def fl_bounds(m, fl, t):
    return (-fbar_t.iloc[fl,t], fbar_t.iloc[fl,t])

model.fl = Var(model.Fl, model.T, bounds=fl_bounds)

# New capacities:
model.k = Var(model.S, model.Ft, within=NonNegativeReals)

# Generation from new EGUs:
model.gen_ex = Var(model.S, model.Ft, model.T, within=NonNegativeReals)

# External RECs:
# Tier 1:
def ex_rec_t1_bounds(m, ex_r, s):
    return (0, ub_g_rec_tier1.iloc[ex_r,s])

model.ex_rec_tier1 = Var(model.Ex_rec, model.S, bounds=ex_rec_t1_bounds)

# Tier 2:
def ex_rec_t2_bounds(m, ex_r, s):
    return (0, ub_g_rec_tier2.iloc[ex_r,s])

model.ex_rec_tier2 = Var(model.Ex_rec, model.S, bounds=ex_rec_t2_bounds)

# SREC:
def ex_srec_bounds(m, ex_r, s):
    return (0, ub_g_rec_solar.iloc[ex_r,s])

model.ex_rec_solar = Var(model.Ex_rec, model.S, bounds=ex_srec_bounds)


# ***************************
# Define constraints:
# ***************************
# external generation constraints:
def gen_ex_constraint(model, s, ft, t):
    return model.gen_ex[s, ft, t] <= model.k[s, ft]*avail_N_fin[ft]

model.gen_ex_cstr = Constraint(model.S, model.Ft, model.T, rule=gen_ex_constraint)

# market clearing condition constraints:
def market_clearing(model, d, t):
    for d in model.D:
        for t in model.T:
            return sum(model.gen_in[g_in, t] for g_in in model.G_in if lmp_region[g_in]==d) \
                  + sum(model.state_region_T.iloc[d, s]* model.gen_ex[s, ft, t] for s in model.S for ft in model.Ft) \
                  + sum(model.fl[fl, t]*model.f_param_T.iloc[d, fl] for fl in model.Fl) \
                  == model.d[d, t]*lost_component[t]


model.market_clearing_cstr = Constraint(model.D, model.T, rule=market_clearing)

# RPS constraints:
# Tier 1:
rps_tier_1 = re_tier_1['rps_t1']
rps_tier_2 = re_tier_2['rps_t2']
srps = se['srps']

def rps_constraint_1(model, s):
    for s in model.S:
        return (sum(model.gen_in[g_in, t]*(rps_tier_1_ratio.iloc[g_in]-rps_tier_1[s])*delta[t]
                    for d in model.D for t in model.T for g_in in model.G_in
                    if state[g_in]==s if rps_tier_1_ratio.iloc[g_in]>0)
                + sum(model.gen_ex[s, ft, t]*(1-rps_tier_1[s])*delta[t]
                      for t in model.T for ft in model.Ft if ft>0)
                + sum(model.gen_in[g_in, t]*rps_tier_1[s]*delta[t]
                      for d in model.D for t in model.T for g_in in model.G_in
                      if state[g_in]==s if rps_tier_1_ratio.iloc[g_in]==0)
                + sum(model.gen_ex[s, ft, t]*rps_tier_1[s]*delta[t]
                      for ft in model.Ft for t in model.T if ft == 0)
                + sum(model.ex_rec_tier1[jr, s]
                      for jr in model.Ex_rec)) >= 0


model.rps_constraint_1 = Constraint(model.S, rule=rps_constraint_1)

# Tier 2:
def rps_constraint_2(model, s):
    for s in model.S:
        return (sum(model.gen_in[g_in, t]*(rps_tier_2_ratio.iloc[g_in]-rps_tier_2[s])*delta[t]
                    for d in model.D for t in model.T for g_in in model.G_in
                    if state[g_in]==s if rps_tier_2_ratio.iloc[g_in]>0)
                + sum(model.gen_ex[s, ft, t]*(1-rps_tier_2[s])*delta[t]
                      for t in model.T for ft in model.Ft if ft>2)
                + sum(model.gen_in[g_in, t]*rps_tier_2[s]*delta[t]
                      for d in model.D for t in model.T for g_in in model.G_in
                      if state[g_in]==s if rps_tier_2_ratio.iloc[g_in]==0)
                + sum(model.gen_ex[s, ft, t]*rps_tier_2[s]*delta[t]
                      for ft in model.Ft for t in model.T if ft == 0)
                + sum(model.ex_rec_tier2[jr, s]
                      for jr in model.Ex_rec)) >= 0

model.rps_constraint_2 = Constraint(model.S, rule=rps_constraint_2)

# SREC:
def rps_constraint_3(model, s):
    for s in model.S:
        return (sum(model.gen_in[g_in, t]*(1-srps[s])*delta[t]
                    for d in model.D for t in model.T for g_in in model.G_in
                    if state[g_in]==s if fuel_region_t[g_in]==7)
                + sum(model.gen_ex[s, ft, t]*(1-srps[s])*delta[t]
                      for t in model.T for ft in model.Ft if ft==2)
                + sum(model.gen_in[g_in, t]*srps[s]*delta[t]
                      for d in model.D for t in model.T for g_in in model.G_in
                      if state[g_in]==s if fuel_region_t[g_in]!=7)
                + sum(model.gen_ex[s, ft, t] * srps[s]*delta[t]
                      for t in model.T for ft in model.Ft if ft == 0)
                + sum(model.ex_rec_solar[jr, s]
                      for jr in model.Ex_rec)) >= 0

model.rps_constraint_3 = Constraint(model.S, rule=rps_constraint_3)


# ***************************
# Define objective function:
# ***************************
def objective_func(model):
    return -(sum((-0.5*n.iloc[d, t]*model.d[d, t]**2 + c.iloc[d, t]*model.d[d, t])*delta[t]
                 for d in model.D for t in model.T)
             + sum((0.5*m.iloc[g_in, t]*model.gen_in[g_in, t]**2 + b.iloc[g_in, t]*model.gen_in[g_in, t])*delta[t]
                  for g_in in model.G_in for t in model.T)
             - sum(C_N.iloc[s, ft]*model.k[s, ft]
                  for s in model.S for ft in model.Ft)
             - sum(MC_N.iloc[s, ft]*model.gen_ex[s, ft, t]*delta[t]
                   for s in model.S for ft in model.Ft for t in model.T))


model.objective_func = Objective(rule=objective_func)

# Solving the model:
model.dual = Suffix(direction=Suffix.IMPORT_EXPORT)
solver = SolverFactory('cplex')
results = solver.solve(model, logfile='output.txt',
                    symbolic_solver_labels=True, tee=True, load_solutions=True)

print("--- %s seconds ---" % (time.time() - start_time))

model.solutions.store_to(results)


if (results.solver.status == SolverStatus.ok) and (results.solver.termination_condition == TerminationCondition.optimal):
    print('Solution is feasible')
elif (results.solver.termination_condition == TerminationCondition.infeasible):
    print('Solution is infeasible')
else:
    # Something else is wrong
    print('Solver Status: ',  results.solver.status)

print('Total Welfare:', -value(model.objective_func))
