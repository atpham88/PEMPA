# Model Overview
A multi-market numerical simulation model that combines:

1. An aggregate model of electricity dispatch in the PJM footprint with virtual bidding.

2. The endogenous supply of new generation capacity within PJM.

3. Pre-existing policies affecting the PJM power system.

4. The importation of alternative/renewable energy credits (RECs) from outside of PJM.

5. The supply of CO2 abatement from non-PJM RGGI member states.

6. The supply/demand of banked CO2 allowances from current RGGI market participants.


Designed to explore state/regional/federal policy interactions within large-scale PJM wholesale electricity market annually from 2016 to 2030. 

Model has full coverage of all existing generation units, calibrated to match year 2016 and allows new NGCC, wind, and solar capacity expansion starting in 2017.

Model has five load zones aggregated from over 20 load zones in PJM, but units and policies can be modelled at system, state, or state-approximate level. Links based upon transmission lines observed  between  zones.

Model considers 96 load segments for each load zone (24 per season), to capture temporal variation in demand. Demand  is elastic (-0.05).

Model is calibrated using 2016 and 2017 data and validated using 2018 data across several dimensions: generation mix, CO2 emission by zones, predicted new capacity, and zonal LMPs.

Model includes many pre-existing policies: Clean Air Act (NOx and SO2 allowances), state Rewnewable Portfolio Standard (RPS), RGGI, and state nuclear subsidies. Also allows for importation of external RECs from outside of PJM.

Model runs on an annual basis.

<img src="https://user-images.githubusercontent.com/56058936/100789477-801ee300-33e4-11eb-8a79-854d6b52a522.png" width="900">

# Model Outputs
Generation by aggregate units for 96 load segments for years 2017-2030.

Emissions by aggregate units for 96 load segments for years 2017-2030.

CO2 emissions from RGGI states not in PJM for years 2017-2030.

Loads in 5 zones for 96 load segments for years 2017-2030.

Annual NGCC, wind, solar capacity expanded in 14 states in PJM for years 2017-2030.

LMPs in 5 zones for 96 load segments for years 2017-2030.

REC prices (tier 1, tier 2 and SREC prices) for 14 states for years 2017-2030.

Annual economic benefits/losses (consumer surpluses, producer surpluses, total cost of allowances bought and total value of allowances sold) for 5 zones (can be broken down to 14 states) for years 2017-2030.
