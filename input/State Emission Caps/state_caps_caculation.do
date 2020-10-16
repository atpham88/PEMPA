* Total Emissions in Metric Tons in States That are Partially outside of PJM:
use "C:\Users\atpha\Box\CPP Trading\Data\Calibration v1\Model in MATLAB\Input Data\State Emission Caps\needs_2012_active.dta", clear
keep if state=="IL" || state=="IN" || state=="MI" || state=="KY" || state=="NC" || state=="TN"
rename oriscode orisplantcode
gen oris_master = orisplantcode
gen short_to_metric_convert = 0.907185
gen in_master = 1

replace carbondioxideemissionstons=subinstr(carbondioxideemissionstons,",","",.)
destring carbondioxideemissionstons, replace
drop if category=="EXCLUDE"
bysort state: egen e_by_state_st = sum(carbondioxideemissionstons)
gen e_by_state_mt_tot = e_by_state_st*short_to_metric_convert
duplicates drop state, force
format e_by_state_mt_tot %10.0g
keep state e_by_state_mt_tot

save "C:\Users\atpha\Box\CPP Trading\Data\Calibration v1\Model in MATLAB\Input Data\State Emission Caps\partial_states_total_emission.dta", replace


* In-PJM Emissions in Metric Tons in States That are Partially outside of PJM:
use "C:\Users\atpha\Box\CPP Trading\Data\Calibration v1\Model in MATLAB\Input Data\State Emission Caps\needs_2012_active.dta", clear
keep if state=="IL" || state=="IN" || state=="MI" || state=="KY" || state=="NC" || state=="TN"
rename oriscode orisplantcode
gen oris_master = orisplantcode
gen short_to_metric_convert = 0.907185
gen in_master = 1

rename plantname plantname_master
merge m:m orisplantcode using "C:\Users\atpha\Box\CPP Trading\Data\Calibration v1\Model in MATLAB\Input Data\State Emission Caps\partial_state_2016.dta"

drop if _merge==2

gen in_PJM = 0 if _merge~=3
replace in_PJM = 1 if _merge==3

drop _merge
replace carbondioxideemissionstons=subinstr(carbondioxideemissionstons,",","",.)
destring carbondioxideemissionstons, replace

bysort in_PJM state: egen e_by_state_st = sum(carbondioxideemissionstons)
gen e_by_state_mt = e_by_state_st*short_to_metric_convert
duplicates drop in_PJM state, force

drop if in_PJM==0
br state e_by_state_mt 

****
use "C:\Users\atpha\Box\CPP Trading\Data\Calibration v1\Model in MATLAB\Input Data\State Emission Caps\manually_picked_partial_state_PJM.dta",clear
gen short_to_metric_convert = 0.907185
bysort inpjm state: egen e_by_state_st = sum(carbondioxideemissionstons)
gen e_by_state_mt = e_by_state_st*short_to_metric_convert
duplicates drop inpjm state, force
drop if inpjm==0
br state e_by_state_mt

