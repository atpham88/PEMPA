# PJM Electricity Model for 5 nodes.
# Language: Python
# 2021
# With Cumulative Emission Cap
# Finished coding on 04/25/2020 by An Pham

# To reset console:
# from IPython import get_ipython
# def __reset__(): get_ipython().magic('reset -sf')
# __reset__()

# import:
import pandas as pd
import numpy as np
from pyomo.environ import *

model = ConcreteModel(name="(PJM_2021")

# Switches:
# **********************************************
trans_const = 1  # Whether or not there's existence of transmission constraint (==1:yes, ==0:no)
rps_const = 1    # Whether or not there's existence of RPS (==1:yes, ==0:no)
cap_exp = 1      # Whether or not there's capacity expansion (==1:yes, ==0:no)

# **********************************************
# Define Parameters and variables:
# **********************************************
# Number of nodes, lines,load segment and elasticity of demand:
I = 5                    # Number of nodes
J = 884                  # Number of aggregated units
T = 96                   # Number of load segments
F = 10                   # Number of aggregated transmission lines
J_r = 262                # Number of plants eligible to provide RECs to PJM states.
S = 14                   # Number of PJM states.
etaD = 0.05              # Assumed elasticity of demand
# etaD = 0.000001;              # Assumed elasticity of demand
tot_loss_pct = 0.03412764857  # Assume transmission lost % in the distribution system.
state_to_region_t = np.array([[0,0,0,0,0,0,0,0,0,0,0.586434045,0,0,0],
                           [0,0,0,0,0,0,0,0,0,0,0.413565955,0,0,0],
                           [0,1,0,0,0,0,0,0,0.228034644,0,0,0,0,0],
                           [1,0,0,0,0,0.912229612,0,1,0,0,0,0,0.800495305,0.004136931],
                           [0,0,1,1,1,0.087770388,1,0,0.771965356,1,0,1,0.199504695,0.995863069]])

state_to_region = np.zeros([I, S*3])
count = 0
for s in range(S):
    state_to_region[:, count: count+3] = np.tile(np.vstack(state_to_region_t[:, s]),(1,3))
    count = count+3

gas_gr_data_2021 = 'C:/Users/atpha/Documents/Research/PJM Model/Input Data/Gas price growth rates/gas_gr_2021.xlsx'

# 2021:
load_growth = 0
gas_gr_temp = pd.read_excel(gas_gr_data_2021, "Sheet1").values
gas_gr = (1 + gas_gr_temp) * (1 + 0.1194)
oil_gr = 0.196465782 * (1 + 0.4675)
coal_gr = 0.11 * (1 + 0.0207)
nuclear_gr = 0.0062
bio_gr = -0.2

cf_gr_hydro = 0.08
cf_gr_wind = 0.024
cf_gr_solar = 0.12
cf_gr_nuclear = 0.029

# Capacity Expansion Parameters:
C_N_PA = np.hstack((70000, 165500 * (1 - 0.0170) ** 3, 135000 * (1 - 0.0219) ** 3))
C_N_RPJM = np.hstack((73900, 165500 * (1 - 0.0170) ** 3, 130000 * (1 - 0.0219) ** 3))
C_N = np.hstack((C_N_RPJM, C_N_RPJM, C_N_RPJM, C_N_RPJM, C_N_RPJM, C_N_RPJM, C_N_RPJM, C_N_RPJM,
                 C_N_RPJM, C_N_RPJM, C_N_PA, C_N_RPJM, C_N_RPJM, C_N_RPJM))

# Capacity factor of new units:
avail_g = 0.961
avail_w = 0.295
avail_s = 0.17
avail_N = np.hstack((avail_g, avail_w, avail_s))
avail_N_all = np.repeat(avail_N, S)

# Percentage of total ext REC supply available to use by state:
rec_PA_g_sc = 0.615 * 1.4859
rec_RPJM_g_sc = 0.814 * 1.08 * 1.0587

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

# Marginal cost:
MC_N_PA = np.hstack((21.1 * (1 + 0.1194), 0, 0))
MC_N_RPJM = np.hstack((24.2 * (1 + 0.1194), 0, 0))

MC_N = np.hstack((MC_N_RPJM, MC_N_RPJM, MC_N_RPJM, MC_N_RPJM, MC_N_RPJM, MC_N_RPJM, MC_N_RPJM,
                  MC_N_RPJM, MC_N_RPJM, MC_N_RPJM, MC_N_PA, MC_N_RPJM, MC_N_RPJM, MC_N_RPJM))

# RPS data:
re_1_tier_1 = 0.20  # RPS standard for DC - tier 1
re_1_tier_2 = 0  # RPS standard for DC - tier 2

re_2_tier_1 = 0.21  # RPS standard for DE
re_2_tier_2 = 0  # RPS standard for DE

re_3_tier_1 = 0.175  # RPS standard for IL
re_3_tier_2 = 0  # RPS standard for IL

re_4_tier_1 = 0.07  # RPS standard for IN
re_4_tier_2 = 0  # RPS standard for IN

re_5_no_tier = 0  # RPS standard for KY

re_6_tier_1 = 0.25  # RPS standard for MD tier 1
re_6_tier_2 = 0  # RPS standard for MD tier 2

re_7_tier_1 = 0.150  # RPS standard for MI
re_7_tier_2 = 0  # RPS standard for MI

re_8_tier_1 = 0.125  # RPS standard for NC
re_8_tier_2 = 0  # RPS standard for NC

re_9_tier_1 = 0.210  # RPS standard for NJ tier 1
re_9_tier_2 = 0.025  # RPS standard for NJ tier 2

re_10_tier_1 = 0.075  # RPS standard for OH
re_10_tier_2 = 0  # RPS standard for OH

re_11_tier_1 = 0.080  # RPS standard for PA tier 1
re_11_tier_2 = 0.10  # RPS standard for PA tier 2

re_12_no_tier = 0  # RPS standard for TN
re_13_no_tier = 0  # RPS standard for VA
re_14_no_tier = 0  # RPS standard for WV

# SREC:
se_1 = 0.0185  # solar standard for DC
se_2 = 0.0250  # solar standard for DE
se_3 = 0.0105  # solar standard for IL
se_4 = 0  # solar standard for IN
se_5 = 0  # solar standard for KY
se_6 = 0.025  # solar standard for MD
se_7 = 0  # solar standard for MI
se_8 = 0.0020  # solar standard for NC
se_9 = 0.051  # solar standard for NJ
se_10 = 0.0030  # solar standard for OH
se_11 = 0.0050  # solar standard for PA
se_12 = 0  # solar standard for TN
se_13 = 0  # solar standard for VA
se_14 = 0  # solar standard for WV

re_tier_1 = np.hstack((re_1_tier_1, re_2_tier_1, re_3_tier_1, re_4_tier_1, re_5_no_tier, re_6_tier_1, re_7_tier_1,
                       re_8_tier_1, re_9_tier_1, re_10_tier_1, re_11_tier_1, re_12_no_tier,
                       re_13_no_tier, re_14_no_tier))
re_tier_2 = np.hstack((re_1_tier_2, re_2_tier_2, re_3_tier_2, re_4_tier_2, re_5_no_tier, re_6_tier_2, re_7_tier_2,
                       re_8_tier_2, re_9_tier_2, re_10_tier_2, re_11_tier_2, re_12_no_tier,
                       re_13_no_tier, re_14_no_tier))
se = np.hstack((se_1, se_2, se_3, se_4, se_5, se_6, se_7, se_8, se_9, se_10, se_11, se_12, se_13, se_14))

lg = 0.012785

# Adding generation for states that are half outside of PJM:
x_gen_tot_DC = 0
x_gen_tot_DE = 0
x_gen_tot_IL = 97584668 * (1 + lg)
x_gen_tot_IN = 93556369 * (1 + lg)
x_gen_tot_KY = 67283806 * (1 + lg)
x_gen_tot_MD = 0
x_gen_tot_MI = 92436894 * (1 + lg)
x_gen_tot_NC = 128208602 * (1 + lg)
x_gen_tot_NJ = 0
x_gen_tot_OH = 0
x_gen_tot_PA = 0
x_gen_tot_TN = 78868763 * (1 + lg)
x_gen_tot_VA = 0
x_gen_tot_WV = 0

x_gen_tier1_DC = 0
x_gen_tier1_DE = 0
x_gen_tier1_IL = 4486290 * (1 + lg)
x_gen_tier1_IN = 1678770 * (1 + lg)
x_gen_tier1_KY = 3535757 * (1 + lg)
x_gen_tier1_MD = 0
x_gen_tier1_MI = 8747953 * (1 + lg)
x_gen_tier1_NC = 9311657 * (1 + lg)
x_gen_tier1_NJ = 0
x_gen_tier1_OH = 0
x_gen_tier1_PA = 0
x_gen_tier1_TN = 7823792 * (1 + lg)
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
x_gen_solar_IL = 34610 * (1 + lg)
x_gen_solar_IN = 218641 * (1 + lg)
x_gen_solar_KY = 11732 * (1 + lg)
x_gen_solar_MD = 0
x_gen_solar_MI = 9235 * (1 + lg)
x_gen_solar_NC = 3101628 * (1 + lg)
x_gen_solar_NJ = 0
x_gen_solar_OH = 0
x_gen_solar_PA = 0
x_gen_solar_TN = 78617 * (1 + lg)
x_gen_solar_VA = 0
x_gen_solar_WV = 0

x_gen_tot = np.hstack((x_gen_tot_DC, x_gen_tot_DE, x_gen_tot_IL, x_gen_tot_IN, x_gen_tot_KY,
                       x_gen_tot_MD, x_gen_tot_MI, x_gen_tot_NC, x_gen_tot_NJ, x_gen_tot_OH,
                       x_gen_tot_PA, x_gen_tot_TN, x_gen_tot_VA, x_gen_tot_WV))

x_gen_tier1 = np.hstack((x_gen_tier1_DC, x_gen_tier1_DE, x_gen_tier1_IL, x_gen_tier1_IN, x_gen_tier1_KY,
                         x_gen_tier1_MD, x_gen_tier1_MI, x_gen_tier1_NC, x_gen_tier1_NJ, x_gen_tier1_OH,
                         x_gen_tier1_PA, x_gen_tier1_TN, x_gen_tier1_VA, x_gen_tier1_WV))

x_gen_tier2 = np.hstack((x_gen_tier2_DC, x_gen_tier2_DE, x_gen_tier2_IL, x_gen_tier2_IN, x_gen_tier2_KY, x_gen_tier2_MD,
                         x_gen_tier2_MI, x_gen_tier2_NC, x_gen_tier2_NJ, x_gen_tier2_OH, x_gen_tier2_PA,
                         x_gen_tier2_TN, x_gen_tier2_VA, x_gen_tier2_WV))

x_gen_solar = np.hstack((x_gen_solar_DC, x_gen_solar_DE, x_gen_solar_IL, x_gen_solar_IN, x_gen_solar_KY, x_gen_solar_MD,
                         x_gen_solar_MI, x_gen_solar_NC, x_gen_solar_NJ, x_gen_solar_OH, x_gen_solar_PA,
                         x_gen_solar_TN, x_gen_solar_VA, x_gen_solar_WV))

x_gen = np.hstack((x_gen_tot, x_gen_tier1, x_gen_tier2, x_gen_solar))

# Read Data:
# Read Demand Data:
demand_curve = 'C:/Users/atpha/Documents/Research/PJM Model/Input Data/Demand Data/Demand Curves_96_2021.xlsx'

load_data_region_1_temp = pd.read_excel(demand_curve, 'region 1').values
load_data_region_2_temp = pd.read_excel(demand_curve, 'region 2').values
load_data_region_3_temp = pd.read_excel(demand_curve, 'region 3').values
load_data_region_4_temp = pd.read_excel(demand_curve, 'region 4').values
load_data_region_5_temp = pd.read_excel(demand_curve, 'region 5').values

hours = pd.read_excel(demand_curve, 'hours').values

# Read Transmission Network Data:
transmission_network = 'C:/Users/atpha/Documents/Research/PJM Model/Input Data/Transmission/Transmission Networks.xlsx'
transmission_data = pd.read_excel(transmission_network, 'Transmission Network').values

# Virtual Bid:
virtual_bid = 'C:/Users/atpha/Documents/Research/PJM Model/Input Data/Virtual Bids/results_no_trans_const3.xlsx'
zdata = pd.read_excel(virtual_bid, 'beta').values

# Transmission Factor:
trans_factor = 'C:/Users/atpha/Documents/Research/PJM Model/Input Data/Transmission/trans_scaler.xlsx'
trans_factor_data = pd.read_excel(trans_factor, 'Sheet1').values

# Read Supplier Data:
supply_curve = 'C:/Users/atpha/Documents/Research/PJM Model/Input Data/Supply Data/Supply_Curve_96_final_2021.xlsx'

supply_data = pd.read_excel(supply_curve, 'bin 1').values

state = np.hstack(supply_data[:, 111])
ei_ratio = np.hstack(supply_data[:, 112])
rps_tier_1_ratio = np.hstack(supply_data[:, 113])
rps_tier_2_ratio = np.hstack(supply_data[:, 114])

region_1_no_plants = np.count_nonzero(supply_data[:, 1] == 1)
region_2_no_plants = np.count_nonzero(supply_data[:, 1] == 2)
region_3_no_plants = np.count_nonzero(supply_data[:, 1] == 3)
region_4_no_plants = np.count_nonzero(supply_data[:, 1] == 4)
region_5_no_plants = np.count_nonzero(supply_data[:, 1] == 5)
pjm_no_plants = region_1_no_plants + region_2_no_plants + region_3_no_plants + region_4_no_plants + region_5_no_plants

# Units in regions matrix:
units_in_region = np.zeros((pjm_no_plants,I))
for j_1 in range(region_1_no_plants):
    units_in_region[j_1, 0] = 1

for j_2 in range(region_2_no_plants):
    units_in_region[region_1_no_plants+j_2, 1] = 1

for j_3 in range(region_3_no_plants):
    units_in_region[region_1_no_plants+region_2_no_plants+j_3, 2] = 1

for j_4 in range(region_4_no_plants):
    units_in_region[region_1_no_plants+region_2_no_plants+region_3_no_plants+j_4, 3] = 1

for j_5 in range(region_5_no_plants):
    units_in_region[region_1_no_plants+region_2_no_plants+region_3_no_plants+region_4_no_plants+j_5, 4] = 1

# states in each region:
state_1 = state[0:region_1_no_plants]
state_2 = state[region_1_no_plants:region_1_no_plants + region_2_no_plants]
state_3 = state[region_1_no_plants + region_2_no_plants:region_1_no_plants + region_2_no_plants + region_3_no_plants]
state_4 = state[region_1_no_plants + region_2_no_plants + region_3_no_plants:region_1_no_plants + region_2_no_plants +
                                                                             region_3_no_plants + region_4_no_plants]
state_5 = state[region_1_no_plants + region_2_no_plants + region_3_no_plants + region_4_no_plants:]

# Gas price growth rate:
gas_gr_1 = gas_gr[0:region_1_no_plants, :]
gas_gr_2 = gas_gr[region_1_no_plants:region_1_no_plants + region_2_no_plants, :]
gas_gr_3 = gas_gr[region_1_no_plants + region_2_no_plants:region_1_no_plants + region_2_no_plants
                                                          + region_3_no_plants, :]
gas_gr_4 = gas_gr[region_1_no_plants + region_2_no_plants + region_3_no_plants:region_1_no_plants + region_2_no_plants +
                                                                        region_3_no_plants + region_4_no_plants, :]
gas_gr_5 = gas_gr[region_1_no_plants + region_2_no_plants + region_3_no_plants + region_4_no_plants:, :]

supply_data_1 = supply_data[0:region_1_no_plants, :]
supply_data_2 = supply_data[region_1_no_plants:region_1_no_plants + region_2_no_plants, :]
supply_data_3 = supply_data[
                region_1_no_plants + region_2_no_plants:region_1_no_plants + region_2_no_plants + region_3_no_plants, :]
supply_data_4 = supply_data[region_1_no_plants + region_2_no_plants + region_3_no_plants:region_1_no_plants +
                                                 region_2_no_plants + region_3_no_plants + region_4_no_plants, :]
supply_data_5 = supply_data[region_1_no_plants + region_2_no_plants + region_3_no_plants + region_4_no_plants:, :]

cap_region_1 = np.hstack(supply_data_1[:, 2])
cap_region_2 = np.hstack(supply_data_2[:, 2])
cap_region_3 = np.hstack(supply_data_3[:, 2])
cap_region_4 = np.hstack(supply_data_4[:, 2])
cap_region_5 = np.hstack(supply_data_5[:, 2])
cap_region_t = np.hstack((cap_region_1, cap_region_2, cap_region_3, cap_region_4, cap_region_5))

# REC units:
REC_units = 'C:/Users/atpha/Documents/Research/PJM Model/Input Data/External RECs/REC_units_clear2.xlsx'
tier1_units_data = pd.read_excel(REC_units, 'tier 1').values
tier2_units_data = pd.read_excel(REC_units, 'tier 2').values
solar_units_data = pd.read_excel(REC_units, 'solar').values
all_units_data = pd.read_excel(REC_units, 'All Units').values
g_all_tot = np.hstack(all_units_data[:, 21])
rec_region = np.hstack(all_units_data[:, 22])
rec_state = np.hstack(all_units_data[:, -1])

tier_1_cat = np.hstack(tier1_units_data[:, 17])
tier_2_cat = np.hstack(tier2_units_data[:, 17])
solar_cat = np.hstack(solar_units_data[:, 17])
rec_state_tier1 = np.hstack(tier1_units_data[:, -1])
rec_state_tier2 = np.hstack(tier2_units_data[:, -1])
rec_state_solar = np.hstack(solar_units_data[:, -1])

unit_dummy_tier1_temp = tier1_units_data[:, 0:S]
unit_dummy_tier2_temp = tier2_units_data[:, 0:S]
unit_dummy_solar_temp = solar_units_data[:, 0:S]

tier_1_cat_tile = np.transpose(np.tile(tier_1_cat, (S, 1)))
tier_2_cat_tile = np.transpose(np.tile(tier_2_cat, (S, 1)))
solar_cat_tile = np.transpose(np.tile(solar_cat, (S, 1)))
unit_dummy_tier1 = np.multiply(tier_1_cat_tile, unit_dummy_tier1_temp)
unit_dummy_tier2 = np.multiply(tier_2_cat_tile, unit_dummy_tier2_temp)
unit_dummy_solar = np.multiply(solar_cat_tile, unit_dummy_solar_temp)

# Flow constraints (in 10 lines):
no_trans = np.zeros(T)
trans_factor = np.vstack((trans_factor_data[0, :], trans_factor_data[1, :], trans_factor_data[2, :], no_trans, no_trans,
                          no_trans, trans_factor_data[3, :], no_trans, no_trans, trans_factor_data[4, :]))

# Read emission intensity data:
emission_data_1 = supply_data[1:region_1_no_plants, 107]
emission_data_2 = supply_data[region_1_no_plants:region_1_no_plants + region_2_no_plants, 107]
emission_data_3 = supply_data[region_1_no_plants + region_2_no_plants:region_1_no_plants + region_2_no_plants +
                                                                      region_3_no_plants, 107]
emission_data_4 = supply_data[region_1_no_plants + region_2_no_plants + region_3_no_plants:region_1_no_plants +
                                                   region_2_no_plants + region_3_no_plants + region_4_no_plants, 107]
emission_data_5 = supply_data[region_1_no_plants + region_2_no_plants + region_3_no_plants + region_4_no_plants:, 107]

# Region 1: PA East
# Region 2: PA West
# Region 3: RPJM East
# Region 4: RPJM Central
# Region 5: RPJM West

# Available transmission lines:
# PA West to PA East: 1-2
# PA East to RPJM East: 1-3
# PA East to BDC: 1-4
# PA West to RPJM West: 2-5
# BDC to RPJM West: 4-5

rec_region_tolist = np.hstack((rec_region.tolist()))
rec_g_sc_all = np.zeros(J_r)

for j in range(J_r):
    if rec_region_tolist[j] == 1:
        rec_g_sc_all[j] = rec_PA_g_sc
    else:
        rec_g_sc_all[j] = rec_RPJM_g_sc

# Available transmission lines:
# PA West to PA East: 1-2
# PA East to RPJM East: 1-3
# PA East to Central RPJM: 1-4
# PA West to RPJM West: 2-5
# Central RPJM to RPJM West: 4-5

# Emissions intensity:
ei_ratio_1 = ei_ratio[0:region_1_no_plants]
ei_ratio_2 = ei_ratio[region_1_no_plants:region_1_no_plants + region_2_no_plants]
ei_ratio_3 = ei_ratio[
             region_1_no_plants + region_2_no_plants:region_1_no_plants + region_2_no_plants + region_3_no_plants]
ei_ratio_4 = ei_ratio[region_1_no_plants + region_2_no_plants + region_3_no_plants:region_1_no_plants +
                                           region_2_no_plants + region_3_no_plants + region_4_no_plants]
ei_ratio_5 = ei_ratio[region_1_no_plants + region_2_no_plants + region_3_no_plants + region_4_no_plants:]

# Emissions intensity:
ei_region_1 = np.multiply(supply_data_1[:, 107] * 0.907185, ei_ratio_1)
ei_region_2 = np.multiply(supply_data_2[:, 107] * 0.907185, ei_ratio_2)
ei_region_3 = np.multiply(supply_data_3[:, 107] * 0.907185, ei_ratio_3)
ei_region_4 = np.multiply(supply_data_4[:, 107] * 0.907185, ei_ratio_4)
ei_region_5 = np.multiply(supply_data_5[:, 107] * 0.907185, ei_ratio_5)

# Fuel-type:
fuel_region_1 = supply_data_1[:, 0]
fuel_region_2 = supply_data_2[:, 0]
fuel_region_3 = supply_data_3[:, 0]
fuel_region_4 = supply_data_4[:, 0]
fuel_region_5 = supply_data_5[:, 0]
fuel_region_t = np.hstack((fuel_region_1, fuel_region_2, fuel_region_3, fuel_region_4, fuel_region_5))

# Capacity Scaler:
cs_coal_PA = 0.997082931 * 1.004
cs_hydro_PA = 0.986734678
cs_gas_PA = 0.834969638
cs_nuclear_PA = 0.908225067
cs_oil_PA = 0.921889581
cs_wind_PA = 0.884053657
cs_bio_PA = 0.870537542
cs_solar_PA = 0.935752345

cs_coal_RPJM = 1.212691835 * 1.004
cs_hydro_RPJM = 0.967782977
cs_gas_RPJM = 0.989663052
cs_nuclear_RPJM = 1.216346754
cs_oil_RPJM = 0.982988775
cs_wind_RPJM = 1.586726142
cs_bio_RPJM = 0.890537542
cs_solar_RPJM = 0.333057297

# Capacity Factors:
cf_hydro_PA = 0.108869594 + cf_gr_hydro
cf_wind_PA = 0.288445696 + cf_gr_wind
cf_solar_PA = 0.16698141 + cf_gr_solar
cf_nuclear_PA = 0.963595727 + cf_gr_nuclear

cf_hydro_RPJM = 0.222765215 + cf_gr_hydro
cf_wind_RPJM = 0.273548196 + cf_gr_wind
cf_solar_RPJM = 0.2205 + cf_gr_solar
cf_nuclear_RPJM = 0.892684446 + cf_gr_nuclear

# Total Marginal Costs:
marginal_cost_1 = supply_data_1[:, 4:100]
marginal_cost_2 = supply_data_2[:, 4:100]
marginal_cost_3 = supply_data_3[:, 4:100]
marginal_cost_4 = supply_data_4[:, 4:100]
marginal_cost_5 = supply_data_5[:, 4:100]

# Wind MC:
for i in range(region_1_no_plants):
    if fuel_region_1[i] == 8:
        marginal_cost_1[i, :] = marginal_cost_1[i, :] + vom_wind

for i in range(region_2_no_plants):
    if fuel_region_2[i] == 8:
        marginal_cost_2[i, :] = marginal_cost_2[i, :] + vom_wind

for i in range(region_3_no_plants):
    if fuel_region_3[i] == 8:
        marginal_cost_3[i, :] = marginal_cost_3[i, :] + vom_wind

for i in range(region_4_no_plants):
    if fuel_region_4[i] == 8:
        marginal_cost_4[i, :] = marginal_cost_4[i, :] + vom_wind

for i in range(region_5_no_plants):
    if fuel_region_5[i] == 2:
        marginal_cost_5[i, :] = marginal_cost_5[i, :] + vom_wind

# Solar MC:
for i in range(region_1_no_plants):
    if fuel_region_1[i] == 7:
        marginal_cost_1[i, :] = marginal_cost_1[i, :] + vom_solar

for i in range(region_2_no_plants):
    if fuel_region_2[i] == 7:
        marginal_cost_2[i, :] = marginal_cost_2[i, :] + vom_solar

for i in range(region_3_no_plants):
    if fuel_region_3[i] == 7:
        marginal_cost_3[i, :] = marginal_cost_3[i, :] + vom_solar

for i in range(region_4_no_plants):
    if fuel_region_4[i] == 7:
        marginal_cost_4[i, :] = marginal_cost_4[i, :] + vom_solar

for i in range(region_5_no_plants):
    if fuel_region_5[i] == 7:
        marginal_cost_5[i, :] = marginal_cost_5[i, :] + vom_solar

# Hydro MC:
for i in range(region_1_no_plants):
    if fuel_region_1[i] == 3:
        marginal_cost_1[i, :] = marginal_cost_1[i, :] + vom_hydro

for i in range(region_2_no_plants):
    if fuel_region_2[i] == 3:
        marginal_cost_2[i, :] = marginal_cost_2[i, :] + vom_hydro

for i in range(region_3_no_plants):
    if fuel_region_3[i] == 3:
        marginal_cost_3[i, :] = marginal_cost_3[i, :] + vom_hydro

for i in range(region_4_no_plants):
    if fuel_region_4[i] == 3:
        marginal_cost_4[i, :] = marginal_cost_4[i, :] + vom_hydro

for i in range(region_5_no_plants):
    if fuel_region_5[i] == 3:
        marginal_cost_5[i, :] = marginal_cost_5[i, :] + vom_hydro

# Nuclear MC:
for i in range(region_1_no_plants):
    if fuel_region_1[i] == 4:
        marginal_cost_1[i, :] = marginal_cost_1[i, :]*(1+nuclear_gr) + vom_nuclear

for i in range(region_2_no_plants):
    if fuel_region_2[i] == 4:
        marginal_cost_2[i, :] = marginal_cost_2[i, :]*(1+nuclear_gr) + vom_nuclear

for i in range(region_3_no_plants):
    if fuel_region_3[i] == 4 and state_3[i] == 3:
        marginal_cost_3[i, :] = marginal_cost_3[i, :]*(1+nuclear_gr) + vom_nuclear - 16.5
    elif fuel_region_3[i] == 4 and state_3[i] == 9:
        marginal_cost_3[i, :] = marginal_cost_3[i, :]*(1+nuclear_gr) + vom_nuclear - 10.012
    elif fuel_region_3[i] == 4 and state_3[i] != 9 and state_3[i] != 3:
        marginal_cost_3[i, :] = marginal_cost_3[i, :]*(1+nuclear_gr) + vom_nuclear

for i in range(region_4_no_plants):
    if fuel_region_4[i] == 4 and state_4[i] == 3:
        marginal_cost_4[i, :] = marginal_cost_4[i, :]*(1+nuclear_gr) + vom_nuclear - 16.5
    elif fuel_region_4[i] == 4 and state_4[i] == 9:
        marginal_cost_4[i, :] = marginal_cost_4[i, :]*(1+nuclear_gr) + vom_nuclear - 10.012
    elif fuel_region_4[i] == 4 and state_4[i] != 9 and state_4[i] != 3:
        marginal_cost_4[i, :] = marginal_cost_4[i, :]*(1+nuclear_gr) + vom_nuclear

for i in range(region_5_no_plants):
    if fuel_region_5[i] == 4 and state_5[i] == 3:
        marginal_cost_5[i, :] = marginal_cost_5[i, :]*(1+nuclear_gr) + vom_nuclear - 16.5
    elif fuel_region_5[i] == 4 and state_5[i] == 9:
        marginal_cost_5[i, :] = marginal_cost_5[i, :]*(1+nuclear_gr) + vom_nuclear - 10.012
    elif fuel_region_5[i] == 4 and state_5[i] != 9 and state_5[i] != 3:
        marginal_cost_5[i, :] = marginal_cost_5[i, :]*(1+nuclear_gr) + vom_nuclear

# Biomass MC:
for i in range(region_1_no_plants):
    if fuel_region_1[i] == 1:
        marginal_cost_1[i, :] = marginal_cost_1[i, :]*f_cs_bio*(1+bio_gr) + vom_bio_PA

for i in range(region_2_no_plants):
    if fuel_region_2[i] == 1:
        marginal_cost_2[i, :] = marginal_cost_2[i, :]*f_cs_bio*(1+bio_gr) + vom_bio_PA

for i in range(region_3_no_plants):
    if fuel_region_3[i] == 1:
        marginal_cost_3[i, :] = marginal_cost_3[i, :]*f_cs_bio*(1+bio_gr) + vom_bio_RPJM

for i in range(region_4_no_plants):
    if fuel_region_4[i] == 1:
        marginal_cost_4[i, :] = marginal_cost_4[i, :]*f_cs_bio*(1+bio_gr) + vom_bio_RPJM

for i in range(region_5_no_plants):
    if fuel_region_5[i] == 1:
        marginal_cost_5[i, :] = marginal_cost_5[i, :]*f_cs_bio*(1+bio_gr) + vom_bio_RPJM

# Gas MC:
# Winter - Gas:
for i in range(region_1_no_plants):
    if fuel_region_1[i] == 9:
        marginal_cost_1[i, 0:24] = f_cs_gas_winter*np.multiply(marginal_cost_1[i, 0:24], gas_gr_1[i, 0:24]) \
                                   + vom_gas_PA_winter

for i in range(region_2_no_plants):
    if fuel_region_2[i] == 9:
        marginal_cost_2[i, 0:24] = f_cs_gas_winter*np.multiply(marginal_cost_2[i, 0:24], gas_gr_2[i, 0:24]) \
                                   + vom_gas_PA_winter

for i in range(region_3_no_plants):
    if fuel_region_3[i] == 9:
        marginal_cost_3[i, 0:24] = f_cs_gas_winter*np.multiply(marginal_cost_3[i, 0:24], gas_gr_3[i, 0:24]) \
                                   + vom_gas_RPJM_winter

for i in range(region_4_no_plants):
    if fuel_region_4[i] == 9:
        marginal_cost_4[i, 0:24] = f_cs_gas_winter*np.multiply(marginal_cost_4[i, 0:24], gas_gr_4[i, 0:24]) \
                                   + vom_gas_RPJM_winter

for i in range(region_5_no_plants):
    if fuel_region_5[i] == 9:
        marginal_cost_5[i, 24:48] = f_cs_gas_winter*np.multiply(marginal_cost_5[i, 24:48], gas_gr_5[i, 0:24]) \
                                   + vom_gas_RPJM_winter

# Spring - Gas:
for i in range(region_1_no_plants):
    if fuel_region_1[i] == 9:
        marginal_cost_1[i, 24:48] = f_cs_gas_spring*np.multiply(marginal_cost_1[i, 24:48], gas_gr_1[i, 24:48]) \
                                   + vom_gas_PA_spring

for i in range(region_2_no_plants):
    if fuel_region_2[i] == 9:
        marginal_cost_2[i, 24:48] = f_cs_gas_spring*np.multiply(marginal_cost_2[i, 24:48], gas_gr_2[i, 24:48]) \
                                   + vom_gas_PA_spring

for i in range(region_3_no_plants):
    if fuel_region_3[i] == 9:
        marginal_cost_3[i, 24:48] = f_cs_gas_spring*np.multiply(marginal_cost_3[i, 24:48], gas_gr_3[i, 24:48]) \
                                   + vom_gas_PA_spring

for i in range(region_4_no_plants):
    if fuel_region_4[i] == 9:
        marginal_cost_4[i, 24:48] = f_cs_gas_spring*np.multiply(marginal_cost_4[i, 24:48], gas_gr_4[i, 24:48]) \
                                   + vom_gas_PA_spring

for i in range(region_5_no_plants):
    if fuel_region_5[i] == 9:
        marginal_cost_5[i, 24:48] = f_cs_gas_spring*np.multiply(marginal_cost_5[i, 24:48], gas_gr_5[i, 24:48]) \
                                   + vom_gas_PA_spring

# Summer - Gas:
for i in range(region_1_no_plants):
    if fuel_region_1[i] == 9:
        marginal_cost_1[i, 48:72] = f_cs_gas_summer*np.multiply(marginal_cost_1[i, 48:72], gas_gr_1[i, 48:72]) \
                                   + vom_gas_PA_summer

for i in range(region_2_no_plants):
    if fuel_region_2[i] == 9:
        marginal_cost_2[i, 48:72] = f_cs_gas_summer*np.multiply(marginal_cost_2[i, 48:72], gas_gr_2[i, 48:72]) \
                                   + vom_gas_PA_summer

for i in range(region_3_no_plants):
    if fuel_region_3[i] == 9:
        marginal_cost_3[i, 48:72] = f_cs_gas_summer*np.multiply(marginal_cost_3[i, 48:72], gas_gr_3[i, 48:72]) \
                                   + vom_gas_PA_summer

for i in range(region_4_no_plants):
    if fuel_region_4[i] == 9:
        marginal_cost_4[i, 48:72] = f_cs_gas_summer*np.multiply(marginal_cost_4[i, 48:72], gas_gr_4[i, 48:72]) \
                                   + vom_gas_PA_summer

for i in range(region_5_no_plants):
    if fuel_region_5[i] == 9:
        marginal_cost_5[i, 48:72] = f_cs_gas_summer*np.multiply(marginal_cost_5[i, 48:72], gas_gr_5[i, 48:72]) \
                                   + vom_gas_PA_summer

# Fall - Gas:
for i in range(region_1_no_plants):
    if fuel_region_1[i] == 9:
        marginal_cost_1[i, 72:T] = f_cs_gas_fall*np.multiply(marginal_cost_1[i, 72:T], gas_gr_1[i, 72:T]) \
                                   + vom_gas_PA_fall

for i in range(region_2_no_plants):
    if fuel_region_2[i] == 9:
        marginal_cost_2[i, 72:T] = f_cs_gas_fall*np.multiply(marginal_cost_2[i, 72:T], gas_gr_2[i, 72:T]) \
                                   + vom_gas_PA_fall

for i in range(region_3_no_plants):
    if fuel_region_3[i] == 9:
        marginal_cost_3[i, 72:T] = f_cs_gas_fall*np.multiply(marginal_cost_3[i, 72:T], gas_gr_3[i, 72:T]) \
                                   + vom_gas_PA_fall

for i in range(region_4_no_plants):
    if fuel_region_4[i] == 9:
        marginal_cost_4[i, 72:T] = f_cs_gas_fall*np.multiply(marginal_cost_4[i, 72:T], gas_gr_4[i, 72:T]) \
                                   + vom_gas_PA_fall

for i in range(region_5_no_plants):
    if fuel_region_5[i] == 9:
        marginal_cost_5[i, 72:T] = f_cs_gas_fall*np.multiply(marginal_cost_5[i, 72:T], gas_gr_5[i, 72:T]) \
                                   + vom_gas_PA_fall

# Oil MC:
# Winter - Oil:
for i in range(region_1_no_plants):
    if fuel_region_1[i] == 6:
        marginal_cost_1[i, 0:24] = marginal_cost_1[i, 0:24]*f_cs_oil_winter*(1+oil_gr) + vom_oil_PA

for i in range(region_2_no_plants):
    if fuel_region_2[i] == 6:
        marginal_cost_2[i, 0:24] = marginal_cost_2[i, 0:24]*f_cs_oil_winter*(1+oil_gr) + vom_oil_PA

for i in range(region_3_no_plants):
    if fuel_region_3[i] == 6:
        marginal_cost_3[i, 0:24] = marginal_cost_3[i, 0:24]*f_cs_oil_winter*(1+oil_gr) + vom_oil_RPJM

for i in range(region_4_no_plants):
    if fuel_region_4[i] == 6:
        marginal_cost_4[i, 0:24] = marginal_cost_4[i, 0:24]*f_cs_oil_winter*(1+oil_gr) + vom_oil_RPJM

for i in range(region_5_no_plants):
    if fuel_region_5[i] == 6:
        marginal_cost_5[i, 24:48] = marginal_cost_5[i, 24:48]*f_cs_oil_winter*(1+oil_gr) + vom_oil_RPJM

# Spring - Oil:
for i in range(region_1_no_plants):
    if fuel_region_1[i] == 6:
        marginal_cost_1[i, 24:48] = marginal_cost_1[i, 24:48]*f_cs_oil_spring*(1+oil_gr) + vom_oil_PA

for i in range(region_2_no_plants):
    if fuel_region_2[i] == 6:
        marginal_cost_2[i, 24:48] = marginal_cost_2[i, 24:48]*f_cs_oil_spring*(1+oil_gr) + vom_oil_PA

for i in range(region_3_no_plants):
    if fuel_region_3[i] == 6:
        marginal_cost_3[i, 24:48] = marginal_cost_3[i, 24:48]*f_cs_oil_spring*(1+oil_gr) + vom_oil_RPJM

for i in range(region_4_no_plants):
    if fuel_region_4[i] == 6:
        marginal_cost_4[i, 24:48] = marginal_cost_4[i, 24:48]*f_cs_oil_spring*(1+oil_gr) + vom_oil_RPJM

for i in range(region_5_no_plants):
    if fuel_region_5[i] == 6:
        marginal_cost_5[i, 24:48] = marginal_cost_5[i, 24:48]*f_cs_oil_spring*(1+oil_gr) + vom_oil_RPJM

# Summer - Oil:
for i in range(region_1_no_plants):
    if fuel_region_1[i] == 6:
        marginal_cost_1[i, 48:72] = marginal_cost_1[i, 48:72]*f_cs_oil_summer*(1+oil_gr) + vom_oil_PA

for i in range(region_2_no_plants):
    if fuel_region_2[i] == 6:
        marginal_cost_2[i, 48:72] = marginal_cost_2[i, 48:72]*f_cs_oil_summer*(1+oil_gr) + vom_oil_PA

for i in range(region_3_no_plants):
    if fuel_region_3[i] == 6:
        marginal_cost_3[i, 48:72] = marginal_cost_3[i, 48:72]*f_cs_oil_summer*(1+oil_gr) + vom_oil_RPJM

for i in range(region_4_no_plants):
    if fuel_region_4[i] == 6:
        marginal_cost_4[i, 48:72] = marginal_cost_4[i, 48:72]*f_cs_oil_summer*(1+oil_gr) + vom_oil_RPJM

for i in range(region_5_no_plants):
    if fuel_region_5[i] == 6:
        marginal_cost_5[i, 48:72] = marginal_cost_5[i, 48:72]*f_cs_oil_summer*(1+oil_gr) + vom_oil_RPJM

# Fall - Oil:
for i in range(region_1_no_plants):
    if fuel_region_1[i] == 6:
        marginal_cost_1[i, 72:T] = marginal_cost_1[i, 72:T]*f_cs_oil_fall*(1+oil_gr) + vom_oil_PA

for i in range(region_2_no_plants):
    if fuel_region_2[i] == 6:
        marginal_cost_2[i, 72:T] = marginal_cost_2[i, 72:T]*f_cs_oil_fall*(1+oil_gr) + vom_oil_PA

for i in range(region_3_no_plants):
    if fuel_region_3[i] == 6:
        marginal_cost_3[i, 72:T] = marginal_cost_3[i, 72:T]*f_cs_oil_fall*(1+oil_gr) + vom_oil_RPJM

for i in range(region_4_no_plants):
    if fuel_region_4[i] == 6:
        marginal_cost_4[i, 72:T] = marginal_cost_4[i, 72:T]*f_cs_oil_fall*(1+oil_gr) + vom_oil_RPJM

for i in range(region_5_no_plants):
    if fuel_region_5[i] == 6:
        marginal_cost_5[i, 72:T] = marginal_cost_5[i, 72:T]*f_cs_oil_fall*(1+oil_gr) + vom_oil_RPJM

# Coal MC:
# Winter - Coal:
for i in range(region_1_no_plants):
    if fuel_region_1[i] == 2:
        marginal_cost_1[i, 0:24] = marginal_cost_1[i, 0:24]*f_cs_coal_winter*(1+coal_gr) + vom_coal_PA_winter

for i in range(region_2_no_plants):
    if fuel_region_2[i] == 2:
        marginal_cost_2[i, 0:24] = marginal_cost_2[i, 0:24]*f_cs_coal_winter*(1+coal_gr) + vom_coal_PA_winter

for i in range(region_3_no_plants):
    if fuel_region_3[i] == 2:
        marginal_cost_3[i, 0:24] = marginal_cost_3[i, 0:24]*f_cs_coal_winter*(1+coal_gr) + vom_coal_RPJM_winter

for i in range(region_4_no_plants):
    if fuel_region_4[i] == 2:
        marginal_cost_4[i, 0:24] = marginal_cost_4[i, 0:24]*f_cs_coal_winter*(1+coal_gr) + vom_coal_RPJM_winter

for i in range(region_5_no_plants):
    if fuel_region_5[i] == 2:
        marginal_cost_5[i, 24:48] = marginal_cost_5[i, 24:48]*f_cs_coal_winter*(1+coal_gr) + vom_coal_RPJM_winter

# Spring - Coal:
for i in range(region_1_no_plants):
    if fuel_region_1[i] == 2:
        marginal_cost_1[i, 24:48] = marginal_cost_1[i, 24:48]*f_cs_coal_spring*(1+coal_gr) + vom_coal_PA_spring

for i in range(region_2_no_plants):
    if fuel_region_2[i] == 2:
        marginal_cost_2[i, 24:48] = marginal_cost_2[i, 24:48]*f_cs_coal_spring*(1+coal_gr) + vom_coal_PA_spring

for i in range(region_3_no_plants):
    if fuel_region_3[i] == 2:
        marginal_cost_3[i, 24:48] = marginal_cost_3[i, 24:48]*f_cs_coal_spring*(1+coal_gr) + vom_coal_PA_spring

for i in range(region_4_no_plants):
    if fuel_region_4[i] == 2:
        marginal_cost_4[i, 24:48] = marginal_cost_4[i, 24:48]*f_cs_coal_spring*(1+coal_gr) + vom_coal_PA_spring

for i in range(region_5_no_plants):
    if fuel_region_5[i] == 2:
        marginal_cost_5[i, 24:48] = marginal_cost_5[i, 24:48]*f_cs_coal_spring*(1+coal_gr) + vom_coal_PA_spring

# Summer - Coal:
for i in range(region_1_no_plants):
    if fuel_region_1[i] == 2:
        marginal_cost_1[i, 48:72] = marginal_cost_1[i, 48:72]*f_cs_coal_summer*(1+coal_gr) + vom_coal_PA_summer

for i in range(region_2_no_plants):
    if fuel_region_2[i] == 2:
        marginal_cost_2[i, 48:72] = marginal_cost_2[i, 48:72]*f_cs_coal_summer*(1+coal_gr) + vom_coal_PA_summer

for i in range(region_3_no_plants):
    if fuel_region_3[i] == 2:
        marginal_cost_3[i, 48:72] = marginal_cost_3[i, 48:72]*f_cs_coal_summer*(1+coal_gr) + vom_coal_PA_summer

for i in range(region_4_no_plants):
    if fuel_region_4[i] == 2:
        marginal_cost_4[i, 48:72] = marginal_cost_4[i, 48:72]*f_cs_coal_summer*(1+coal_gr) + vom_coal_PA_summer

for i in range(region_5_no_plants):
    if fuel_region_5[i] == 2:
        marginal_cost_5[i, 48:72] = marginal_cost_5[i, 48:72]*f_cs_coal_summer*(1+coal_gr) + vom_coal_PA_summer

# Fall - Coal:
for i in range(region_1_no_plants):
    if fuel_region_1[i] == 2:
        marginal_cost_1[i, 72:T] = marginal_cost_1[i, 72:T]*f_cs_coal_fall*(1+coal_gr) + vom_coal_PA_fall

for i in range(region_2_no_plants):
    if fuel_region_2[i] == 2:
        marginal_cost_2[i, 72:T] = marginal_cost_2[i, 72:T]*f_cs_coal_fall*(1+coal_gr) + vom_coal_PA_fall

for i in range(region_3_no_plants):
    if fuel_region_3[i] == 2:
        marginal_cost_3[i, 72:T] = marginal_cost_3[i, 72:T]*f_cs_coal_fall*(1+coal_gr) + vom_coal_PA_fall

for i in range(region_4_no_plants):
    if fuel_region_4[i] == 2:
        marginal_cost_4[i, 72:T] = marginal_cost_4[i, 72:T]*f_cs_coal_fall*(1+coal_gr) + vom_coal_PA_fall

for i in range(region_5_no_plants):
    if fuel_region_5[i] == 2:
        marginal_cost_5[i, 72:T] = marginal_cost_5[i, 72:T]*f_cs_coal_fall*(1+coal_gr) + vom_coal_PA_fall

# Demand  parameters virtual bid percentage:
z = zdata[:, 4]/100
hours_all = hours[0:T, 1]
net_vb = zdata[:, 11]
lost_component = 1+tot_loss_pct-net_vb

b_1 = marginal_cost_1
b_2 = marginal_cost_2
b_3 = marginal_cost_3
b_4 = marginal_cost_4
b_5 = marginal_cost_5

m_1 = 0 * b_1
m_2 = 0 * b_2
m_3 = 0 * b_3
m_4 = 0 * b_4
m_5 = 0 * b_5

delta = hours_all

# Total Hourly loads in each region:
load_region_1 = load_data_region_1_temp[:, 3]*(1 + load_growth)
load_region_2 = load_data_region_2_temp[:, 3]*(1 + load_growth)
load_region_3 = load_data_region_3_temp[:, 3]*(1 + load_growth)
load_region_4 = load_data_region_4_temp[:, 3]*(1 + load_growth)
load_region_5 = load_data_region_5_temp[:, 3]*(1 + load_growth)

# Average LMPs in each region:
p_region_1 = load_data_region_1_temp[:, 2]
p_region_2 = load_data_region_2_temp[:, 2]
p_region_3 = load_data_region_3_temp[:, 2]
p_region_4 = load_data_region_4_temp[:, 2]
p_region_5 = load_data_region_5_temp[:, 2]

load_region_by_t_1 = np.divide(load_region_1, delta)
load_region_by_t_2 = np.divide(load_region_2, delta)
load_region_by_t_3 = np.divide(load_region_3, delta)
load_region_by_t_4 = np.divide(load_region_4, delta)
load_region_by_t_5 = np.divide(load_region_5, delta)

# Demand curve intercepts(c) and slope(n):
n_1 = (1 / etaD)*np.divide(p_region_1, load_region_by_t_1)
n_2 = (1 / etaD)*np.divide(p_region_2, load_region_by_t_2)
n_3 = (1 / etaD)*np.divide(p_region_3, load_region_by_t_3)
n_4 = (1 / etaD)*np.divide(p_region_4, load_region_by_t_4)
n_5 = (1 / etaD)*np.divide(p_region_5, load_region_by_t_5)
n = np.vstack((n_1, n_2, n_3, n_4, n_5))

c_1 = (1 + (1 / etaD)) * p_region_1
c_2 = (1 + (1 / etaD)) * p_region_2
c_3 = (1 + (1 / etaD)) * p_region_3
c_4 = (1 + (1 / etaD)) * p_region_4
c_5 = (1 + (1 / etaD)) * p_region_5
c = np.vstack((c_1, c_2, c_3, c_4, c_5))

if trans_const == 1:
    trans_data_temp = np.vstack((transmission_data[0, 20], transmission_data[1, 20],  transmission_data[2, 20], 0, 0, 0,
                                 transmission_data[6, 20], 0, 0, transmission_data[9, 20]))
    fbar_t = np.multiply(np.tile(trans_data_temp, (1, T)), trans_factor)
elif trans_const == 0:
    fbar_12 = 99999
    fbar_13 = 99999
    fbar_14 = 99999
    fbar_15 = 0
    fbar_23 = 0
    fbar_24 = 0
    fbar_25 = 99999
    fbar_34 = 0
    fbar_35 = 0
    fbar_45 = 99999
    fbar_t = np.tile(np.vstack((fbar_12, fbar_13, fbar_14, fbar_15, fbar_23, fbar_24, fbar_25, fbar_34,
                                    fbar_35, fbar_45)), (1, T))

# ****************FINISH READING DATA****************************************

# ****************MODEL BEGINS***********************************************
# Define bounds:
cap_scaler_1 = np.ones(region_1_no_plants)
cap_scaler_2 = np.ones(region_2_no_plants)
cap_scaler_3 = np.ones(region_3_no_plants)
cap_scaler_4 = np.ones(region_4_no_plants)
cap_scaler_5 = np.ones(region_5_no_plants)

for ju in range(region_1_no_plants):
    if fuel_region_1[ju] == 1 and supply_data_1[ju, 110] < 2000:
        cap_scaler_1[ju] = cs_bio_PA * 0.961
    elif fuel_region_1[ju] == 2 and supply_data_1[ju, 110] < 2000:
        cap_scaler_1[ju] = cs_coal_PA * 0.961
    elif fuel_region_1[ju] == 3 and supply_data_1[ju, 110] < 2000:
        cap_scaler_1[ju,] = cs_hydro_PA * cf_hydro_PA
    elif fuel_region_1[ju] == 4 and supply_data_1[ju, 110] < 2000:
        cap_scaler_1[ju] = cs_nuclear_PA * cf_nuclear_PA
    elif fuel_region_1[ju] == 5 and supply_data_1[ju, 110] < 2000:
        cap_scaler_1[ju] = 0.961
    elif fuel_region_1[ju] == 6 and supply_data_1[ju, 110] < 2000:
        cap_scaler_1[ju] = cs_oil_PA * 0.961
    elif fuel_region_1[ju] == 7 and supply_data_1[ju, 110] < 2000:
        cap_scaler_1[ju] = cs_solar_PA * cf_solar_PA
    elif fuel_region_1[ju] == 8 and supply_data_1[ju, 110] < 2000:
        cap_scaler_1[ju] = cs_wind_PA * cf_wind_PA
    elif fuel_region_1[ju] == 9 and supply_data_1[ju, 110] < 2000:
        cap_scaler_1[ju] = cs_gas_PA * 0.961

for ju in range(region_2_no_plants):
    if fuel_region_2[ju] == 1 and supply_data_2[ju, 110] < 2000:
        cap_scaler_2[ju] = cs_bio_PA * 0.961
    elif fuel_region_2[ju] == 2 and supply_data_2[ju, 110] < 2000:
        cap_scaler_2[ju] = cs_coal_PA * 0.961
    elif fuel_region_2[ju] == 3 and supply_data_2[ju, 110] < 2000:
        cap_scaler_2[ju] = cs_hydro_PA * cf_hydro_PA
    elif fuel_region_2[ju] == 4 and supply_data_2[ju, 110] < 2000:
        cap_scaler_2[ju] = cs_nuclear_PA * cf_nuclear_PA
    elif fuel_region_2[ju] == 5 and supply_data_2[ju, 110] < 2000:
        cap_scaler_2[ju] = 0.961
    elif fuel_region_2[ju] == 6 and supply_data_2[ju, 110] < 2000:
        cap_scaler_2[ju] = cs_oil_PA * 0.961
    elif fuel_region_2[ju] == 7 and supply_data_2[ju, 110] < 2000:
        cap_scaler_2[ju] = cs_solar_PA * cf_solar_PA
    elif fuel_region_2[ju] == 8 and supply_data_2[ju, 110] < 2000:
        cap_scaler_2[ju] = cs_wind_PA * cf_wind_PA
    elif fuel_region_2[ju] == 9 and supply_data_2[ju, 110] < 2000:
        cap_scaler_2[ju] = cs_gas_PA * 0.961

for ju in range(region_3_no_plants):
    if fuel_region_3[ju] == 1 and supply_data_3[ju, 110] < 2000:
        cap_scaler_3[ju] = cs_bio_RPJM * 0.961
    elif fuel_region_3[ju] == 2 and supply_data_3[ju, 110] < 2000:
        cap_scaler_3[ju] = cs_coal_RPJM * 0.961
    elif fuel_region_3[ju] == 3 and supply_data_3[ju, 110] < 2000:
        cap_scaler_3[ju] = cs_hydro_RPJM * cf_hydro_RPJM
    elif fuel_region_3[ju] == 4 and supply_data_3[ju, 110] < 2000:
        cap_scaler_3[ju] = cs_nuclear_RPJM * cf_nuclear_RPJM
    elif fuel_region_3[ju] == 5 and supply_data_3[ju, 110] < 2000:
        cap_scaler_3[ju] = 0.961
    elif fuel_region_3[ju] == 6 and supply_data_3[ju, 110] < 2000:
        cap_scaler_3[ju] = cs_oil_RPJM * 0.961
    elif fuel_region_3[ju] == 7 and supply_data_3[ju, 110] < 2000:
        cap_scaler_3[ju] = cs_solar_RPJM * cf_solar_RPJM
    elif fuel_region_3[ju] == 8 and supply_data_3[ju, 110] < 2000:
        cap_scaler_3[ju] = cs_wind_RPJM * cf_wind_RPJM
    elif fuel_region_3[ju] == 9 and supply_data_3[ju, 110] < 2000:
        cap_scaler_3[ju] = cs_gas_RPJM * 0.961

for ju in range(region_4_no_plants):
    if fuel_region_4[ju] == 1 and supply_data_4[ju, 110] < 2000:
        cap_scaler_4[ju] = cs_bio_RPJM * 0.961
    elif fuel_region_4[ju] == 2 and supply_data_4[ju, 110] < 2000:
        cap_scaler_4[ju] = cs_coal_RPJM * 0.961
    elif fuel_region_4[ju] == 3 and supply_data_4[ju, 110] < 2000:
        cap_scaler_4[ju] = cs_hydro_RPJM * cf_hydro_RPJM
    elif fuel_region_4[ju] == 4 and supply_data_4[ju, 110] < 2000:
        cap_scaler_4[ju] = cs_nuclear_RPJM * cf_nuclear_RPJM
    elif fuel_region_4[ju] == 5 and supply_data_4[ju, 110] < 2000:
        cap_scaler_4[ju] = 0.961
    elif fuel_region_4[ju] == 6 and supply_data_4[ju, 110] < 2000:
        cap_scaler_4[ju] = cs_oil_RPJM * 0.961
    elif fuel_region_4[ju] == 7 and supply_data_4[ju, 110] < 2000:
        cap_scaler_4[ju] = cs_solar_RPJM * cf_solar_RPJM
    elif fuel_region_4[ju] == 8 and supply_data_4[ju, 110] < 2000:
        cap_scaler_4[ju] = cs_wind_RPJM * cf_wind_RPJM
    elif fuel_region_4[ju] == 9 and supply_data_4[ju, 110] < 2000:
        cap_scaler_4[ju] = cs_gas_RPJM * 0.961

for ju in range(region_5_no_plants):
    if fuel_region_5[ju] == 1 and supply_data_5[ju, 110] < 2000:
        cap_scaler_5[ju] = cs_bio_RPJM * 0.961
    elif fuel_region_5[ju] == 2 and supply_data_5[ju, 110] < 2000:
        cap_scaler_5[ju] = cs_coal_RPJM * 0.961
    elif fuel_region_5[ju] == 3 and supply_data_5[ju, 110] < 2000:
        cap_scaler_5[ju] = cs_hydro_RPJM * cf_hydro_RPJM
    elif fuel_region_5[ju] == 4 and supply_data_5[ju, 110] < 2000:
        cap_scaler_5[ju] = cs_nuclear_RPJM * cf_nuclear_RPJM
    elif fuel_region_5[ju] == 5 and supply_data_5[ju, 110] < 2000:
        cap_scaler_5[ju] = 0.961
    elif fuel_region_5[ju] == 6 and supply_data_5[ju, 110] < 2000:
        cap_scaler_5[ju] = cs_oil_RPJM * 0.961
    elif fuel_region_5[ju] == 7 and supply_data_5[ju, 110] < 2000:
        cap_scaler_5[ju] = cs_solar_RPJM * cf_solar_RPJM
    elif fuel_region_5[ju] == 8 and supply_data_5[ju, 110] < 2000:
        cap_scaler_5[ju] = cs_wind_RPJM * cf_wind_RPJM
    elif fuel_region_5[ju] == 9 and supply_data_5[ju, 110] < 2000:
        cap_scaler_5[ju] = cs_gas_RPJM * 0.961

cap_scaler = np.hstack((cap_scaler_1, cap_scaler_2, cap_scaler_3, cap_scaler_4, cap_scaler_5))
upper_b_gen_in = np.multiply(cap_scaler, cap_region_t)

# Define sets:
model.D = RangeSet(I)
model.G_in = RangeSet(J)
model.Fl = RangeSet(F)
model.K = RangeSet(S*3)
model.Ex_rec = RangeSet(J_r*S*3)
model.T = RangeSet(T)

# Define variables:
model.d = Var(model.D, model.T, within=NonNegativeReals)
model.gen_in = Var(model.G_in, model.T, bounds=(np.zeros((J, T)), np.tile(np.vstack(upper_b_gen_in), T)))
model.fl = Var(model.Fl, model.T, bounds=(-fbar_t, fbar_t))
model.k = Var(model.K, within=NonNegativeReals)
model.gen_ex = Var(model.K, model.T, within=NonNegativeReals)
model.ex_rec = Var(model.Ex_rec, within=NonNegativeReals) # still need to fix this

# Constraints:
# external generation constraints:
def gen_ex_constraint(model, k, t):
    for k in model.K:
        for t in model.T:
            return model.gen_ex[k, t] <= model.k[k]*avail_N_all[k]

model.gen_ex_cstr = Constraint(model.K, model.T, rule=gen_ex_constraint)

# market clearing condition constraints:
def market_clearing(model, i, t):
    for i in model.D:
        for t in model.T:
            return sum(model.gen_in[g, t] for g in model.G_in) \
                  + sum(model.gen_ex[k, t] for k in model.K) \
                  + sum(model.fl[f, t] for f in model.Fl) \
                  == model.d[i, t]*lost_component[t]

model.market_clearing_cstr = Constraint(model.D, model.T, rule=market_clearing)

#sum(model.gen_in[g, t]*units_in_region[g, i] for g in model.G_in) \
#                   + sum(model.gen_ex[k, t]*state_to_region[i, k] for k in model.K) \
#                   + model.fl[0, t] + model.fl[1, t] + model.fl[2, t] \
#                   == model.d[i, t]*lost_component[t]

# RPS constraints:

# Objective function:


