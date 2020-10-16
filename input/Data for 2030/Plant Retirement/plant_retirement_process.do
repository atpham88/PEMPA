use "C:\Users\atpha\Documents\Comprehensive Exam\Data for 2030\Plant Retirement\planned_retirements_pjm.dta", clear
gen dect_date_temp = date(actualdeactivationdate , "MDY")
gen dect_year = year(dect_date_temp)
gen dect_month = month(dect_date_temp)
gen dect_date = day(dect_date_temp)
drop actualdeactivationdate requesteddeactivationdate projecteddeactivationdate reliabilitymustrunrmr rmrstudyresults reliabilityanalysis teacmaterials rmrzonalcostallocation relatedupgrades withdrawndeactivationdate ownernotificationdate
save "C:\Users\atpha\Documents\Comprehensive Exam\Data for 2030\Plant Retirement\planned_retirements_pjm_cleaned.dta", replace

use "C:\Users\atpha\Documents\Comprehensive Exam\Data for 2030\Plant Retirement\planned_retirements_future_pjm.dta", clear
gen dect_date_temp = date(projecteddeactivationdate , "MDY")
gen dect_year = year(dect_date_temp)
gen dect_month = month(dect_date_temp)
gen dect_date = day(dect_date_temp)
drop actualdeactivationdate requesteddeactivationdate projecteddeactivationdate reliabilitymustrunrmr rmrstudyresults reliabilityanalysis teacmaterials rmrzonalcostallocation relatedupgrades withdrawndeactivationdate ownernotificationdate
save "C:\Users\atpha\Documents\Comprehensive Exam\Data for 2030\Plant Retirement\planned_retirements_future_pjm_cleaned.dta", replace



**
use "C:\Users\atpha\Documents\Comprehensive Exam\Data for 2030\Plant Retirement\planned_retirements_pjm_cleaned.dta", clear
append using "C:\Users\atpha\Documents\Comprehensive Exam\Data for 2030\Plant Retirement\planned_retirements_future_pjm_cleaned.dta"
drop dect_date_temp
drop if capacity==.
drop if dect_year < 2019
save "C:\Users\atpha\Documents\Comprehensive Exam\Data for 2030\Plant Retirement\planned_retirements_until_2021.dta", replace
