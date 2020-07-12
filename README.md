# Model Overview
DCOPF model of the PJM power system, designed to explore state/federal policy interactions within large-scale wholesale electricity markets annually from 2016 to 2030. 

Model has full coverage of all existing generation units, calibrated to match year 2016 and allows new NGCC,  wind, and solar capacity expansion starting in 2017.

Model has five load zones aggregated from over 20 load zones in PJM, but units and policies can be modelled at system, state, or state-approximate level. Links based upon transmission lines observed  between  zones.

Model considers 96 load segments  for each load zone  (24 per season), to capture temporal variation in demand.  Demand  is elastic (-0.05).

Model is validated using 2018 data across several dimensions: generation mix, CO2 emission by zones, predicted new capacity, and zonal LMPs.

<img src="https://user-images.githubusercontent.com/56058936/87237658-11a29f80-c3c7-11ea-8256-6c68cc44e66e.png" width="700">

# Model Outputs
Generation by aggregate units for 96 load segments for years 2017-2030.

Emission by aggregate units for 96 load segments for years 2017-2030.

Loads in 5 zones for 96 load segments for years 2017-2030.

Annual NGCC, wind, solar capacity expanded in 14 states in PJM for years 2017-2030.

LMPs in 5 zones for 96 load segments for years 2017-2030.

REC prices (tier 1, tier 2 and SREC prices) for 14 states for years 2017-2030.

Aggregate surpluses (including consumer surpluses, producer surpluses, total cost of permits bought and total value of permits sold) for 5 zones (can be broken down to 14 states) for years 2017-2030.

# Example
Example data for year 2021 provided in \input folder. 
