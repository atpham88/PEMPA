use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price.dta", clear
rename date date_convert
gen date_new = date(date_convert,"MDY")
gen year = year(date_new)
gen month = month(date_new)
gen date = day(date_new)
drop date_convert date_new
drop if year~=2018

sort hubname month date
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned.dta", replace

** Alliance Delivered
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned.dta", clear
drop if hubname~="Alliance Delivered"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="Alliance Delivered" if hubname==""
sort month date hour

replace pricelast = 3.57 if month==1 & date==1
replace pricemid = 3.57 if month==1 & date==1
replace year=2018 if year==.
replace pricelast = pricelast[_n-1] if pricelast==.
replace pricemid = pricemid[_n-1] if pricemid==.

bysort final_load_segment: egen avg_gas_price = mean(pricelast)
duplicates drop final_load_segment, force
drop pricelast pricemid month date hour _merge
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_AD.dta", replace

** Chicago City Gate
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned.dta", clear
drop if hubname~="Chicago City Gate"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="Chicago City Gate" if hubname==""
sort month date hour

replace pricelast = 4.7386 if month==1 & date==1
replace pricemid = 4.7386 if month==1 & date==1
replace year=2018 if year==.
replace pricelast = pricelast[_n-1] if pricelast==.
replace pricemid = pricemid[_n-1] if pricemid==.

bysort final_load_segment: egen avg_gas_price = mean(pricelast)
duplicates drop final_load_segment, force
drop pricelast pricemid month date hour _merge
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_CCG.dta", replace

** Dominion North Point
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned.dta", clear
drop if hubname~="Dominion North Point"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="Dominion North Point" if hubname==""
sort month date hour

replace pricelast = 2.5229 if month==1 & date==1
replace pricemid = 2.5229 if month==1 & date==1
replace year=2018 if year==.
replace pricelast = pricelast[_n-1] if pricelast==.
replace pricemid = pricemid[_n-1] if pricemid==.

bysort final_load_segment: egen avg_gas_price = mean(pricelast)
duplicates drop final_load_segment, force
drop pricelast pricemid month date hour _merge
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_DNP.dta", replace

** Lebanon OH Hub
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned.dta", clear
drop if hubname~="Lebanon OH Hub"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="Lebanon OH Hub" if hubname==""
sort month date hour

replace pricelast = 3.89 if month==1 & date==1
replace pricemid = 3.89 if month==1 & date==1
replace year=2018 if year==.
replace pricelast = pricelast[_n-1] if pricelast==.
replace pricemid = pricemid[_n-1] if pricemid==.

bysort final_load_segment: egen avg_gas_price = mean(pricelast)
duplicates drop final_load_segment, force
drop pricelast pricemid month date hour _merge
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_LOH.dta", replace

** Tennesse Gas Zone 4 - Marcellus
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned.dta", clear
drop if hubname~="Tennesse Gas Zone 4 - Marcellus"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="Tennesse Gas Zone 4 - Marcellus" if hubname==""
sort month date hour

replace pricelast = 2.3897 if month==1 & date==1
replace pricemid = 2.3897 if month==1 & date==1
replace year=2018 if year==.
replace pricelast = pricelast[_n-1] if pricelast==.
replace pricemid = pricemid[_n-1] if pricemid==.

bysort final_load_segment: egen avg_gas_price = mean(pricelast)
duplicates drop final_load_segment, force
drop pricelast pricemid month date hour _merge
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_TGZ4.dta", replace

** TETCO Zone M3
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned.dta", clear
drop if hubname~="TETCO Zone M3"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="TETCO Zone M3" if hubname==""
sort month date hour

replace pricelast = 26.98 if month==1 & date==1
replace pricemid = 26.98 if month==1 & date==1
replace year=2018 if year==.
replace pricelast = pricelast[_n-1] if pricelast==.
replace pricemid = pricemid[_n-1] if pricemid==.

bysort final_load_segment: egen avg_gas_price = mean(pricelast)
duplicates drop final_load_segment, force
drop pricelast pricemid month date hour _merge
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_TZ3.dta", replace

** Transco Leidy
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned.dta", clear
drop if hubname~="Transco Leidy"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="Transco Leidy" if hubname==""
sort month date hour

replace pricelast = 2.5036 if month==1 & date==1
replace pricemid = 2.5036 if month==1 & date==1
replace year=2018 if year==.
replace pricelast = pricelast[_n-1] if pricelast==.
replace pricemid = pricemid[_n-1] if pricemid==.

bysort final_load_segment: egen avg_gas_price = mean(pricelast)
duplicates drop final_load_segment, force
drop pricelast pricemid month date hour _merge
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_TL.dta", replace

** Combining:
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_AD.dta", clear
append using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_CCG.dta"
append using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_DNP.dta"
append using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_LOH.dta"
append using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_TGZ4.dta"
append using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_TZ3.dta"
append using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_TL.dta"
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned_all.dta", replace


******************
*** 2016 gas *****

** Alliance Delivered
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_2016.dta", clear
rename hub_name hubname
rename year year2
drop if hubname~="Alliance Delivered"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="Alliance Delivered" if hubname==""
sort month date hour

bysort final_load_segment: egen avg_gas_price_2016 = mean(avg_gas_price)
duplicates drop final_load_segment, force
drop month date hour _merge avg_gas_price
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_AD_2016.dta", replace

** Chicago City Gate
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_2016.dta", clear
rename hub_name hubname
rename year year2
drop if hubname~="Regional Hubs Chicago City Gate"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="Regional Hubs Chicago City Gate" if hubname==""
sort month date hour

bysort final_load_segment: egen avg_gas_price_2016 = mean(avg_gas_price)
duplicates drop final_load_segment, force
drop month date hour _merge avg_gas_price

replace hubname="Chicago City Gate"
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_CCG_2016.dta", replace

** Dominion North Point
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_2016.dta", clear
rename hub_name hubname
rename year year2
drop if hubname~="Dominion North Point"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="Dominion North Point" if hubname==""
sort month date hour

bysort final_load_segment: egen avg_gas_price_2016 = mean(avg_gas_price)
duplicates drop final_load_segment, force
drop month date hour _merge avg_gas_price
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_DNP_2016.dta", replace

** Lebanon OH Hub
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_2016.dta", clear
rename hub_name hubname
rename year year2
drop if hubname~="Regional Hubs Lebanon OH Hub"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="Regional Hubs Lebanon OH Hub" if hubname==""
sort month date hour

bysort final_load_segment: egen avg_gas_price_2016 = mean(avg_gas_price)
duplicates drop final_load_segment, force
drop month date hour _merge avg_gas_price
replace hubname="Lebanon OH Hub"
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_LOH_2016.dta", replace

** Tennesse Gas Zone 4 - Marcellus
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_2016.dta", clear
rename hub_name hubname
rename year year2
drop if hubname~="Tennessee Gas Zone 4 -Marcellus"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="Tennessee Gas Zone 4 -Marcellus" if hubname==""
sort month date hour

bysort final_load_segment: egen avg_gas_price_2016 = mean(avg_gas_price)
duplicates drop final_load_segment, force
drop month date hour _merge avg_gas_price
replace hubname = "Tennesse Gas Zone 4 - Marcellus"
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_TGZ4_2016.dta", replace

** TETCO Zone M3
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_2016.dta", clear
rename hub_name hubname
rename year year2
drop if hubname~="TETCO Zone M3"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="TETCO Zone M3" if hubname==""
sort month date hour

bysort final_load_segment: egen avg_gas_price_2016 = mean(avg_gas_price)
duplicates drop final_load_segment, force
drop month date hour _merge avg_gas_price
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_TZ3_2016.dta", replace

** Transco Leidy
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_2016.dta", clear
rename hub_name hubname
rename year year2
drop if hubname~="Transco Leidy"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="Transco Leidy" if hubname==""
sort month date hour

bysort final_load_segment: egen avg_gas_price_2016 = mean(avg_gas_price)
duplicates drop final_load_segment, force
drop month date hour _merge avg_gas_price
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_TL_2016.dta", replace

** Combining:
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_AD_2016.dta", clear
append using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_CCG_2016.dta"
append using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_DNP_2016.dta"
append using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_LOH_2016.dta"
append using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_TGZ4_2016.dta"
append using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_TZ3_2016.dta"
append using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_TL_2016.dta"

save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned_all_2016.dta", replace

*** MERGE 2016 and 2018 GAS PRICE:
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned_all_2016.dta", clear
merge 1:1 hubname final_load_segment using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned_all.dta"
drop _merge
gen gas_gr = (avg_gas_price-avg_gas_price_2016)/avg_gas_price_2016
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned_all_2018.dta", replace


******************************************************************************
**** NOW DO THE SAME THING FOR 2017 CALIBRATION ******************************
******************************************************************************
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price.dta", clear
rename date date_convert
gen date_new = date(date_convert,"MDY")
gen year = year(date_new)
gen month = month(date_new)
gen date = day(date_new)
drop date_convert date_new
drop if year~=2017

sort hubname month date
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned_2017.dta", replace

** Alliance Delivered
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned_2017.dta", clear
drop if hubname~="Alliance Delivered"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="Alliance Delivered" if hubname==""
sort month date hour

replace pricelast = 3.535 if month==1 & date==1
replace pricemid = 3.535 if month==1 & date==1
replace year=2017 if year==.
replace pricelast = pricelast[_n-1] if pricelast==.
replace pricemid = pricemid[_n-1] if pricemid==.

bysort final_load_segment: egen avg_gas_price = mean(pricelast)
duplicates drop final_load_segment, force
drop pricelast pricemid month date hour _merge
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_AD_2017.dta", replace

** Chicago City Gate
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned_2017.dta", clear
drop if hubname~="Chicago City Gate"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="Chicago City Gate" if hubname==""
sort month date hour

replace pricelast = 3.625 if month==1 & date==1
replace pricemid = 3.625 if month==1 & date==1
replace year=2017 if year==.
replace pricelast = pricelast[_n-1] if pricelast==.
replace pricemid = pricemid[_n-1] if pricemid==.

bysort final_load_segment: egen avg_gas_price = mean(pricelast)
duplicates drop final_load_segment, force
drop pricelast pricemid month date hour _merge
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_CCG_2017.dta", replace

** Dominion North Point
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned_2017.dta", clear
drop if hubname~="Dominion North Point"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="Dominion North Point" if hubname==""
sort month date hour

replace pricelast = 3.1275 if month==1 & date==1
replace pricemid = 3.1275 if month==1 & date==1
replace year=2017 if year==.
replace pricelast = pricelast[_n-1] if pricelast==.
replace pricemid = pricemid[_n-1] if pricemid==.

bysort final_load_segment: egen avg_gas_price = mean(pricelast)
duplicates drop final_load_segment, force
drop pricelast pricemid month date hour _merge
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_DNP_2017.dta", replace

** Lebanon OH Hub
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned_2017.dta", clear
drop if hubname~="Lebanon OH Hub"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="Lebanon OH Hub" if hubname==""
sort month date hour

replace pricelast = 3.57125 if month==1 & date==1
replace pricemid = 3.57125 if month==1 & date==1
replace year=2017 if year==.
replace pricelast = pricelast[_n-1] if pricelast==.
replace pricemid = pricemid[_n-1] if pricemid==.

bysort final_load_segment: egen avg_gas_price = mean(pricelast)
duplicates drop final_load_segment, force
drop pricelast pricemid month date hour _merge
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_LOH_2017.dta", replace

** Tennesse Gas Zone 4 - Marcellus
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned_2017.dta", clear
drop if hubname~="Tennesse Gas Zone 4 - Marcellus"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="Tennesse Gas Zone 4 - Marcellus" if hubname==""
sort month date hour

replace pricelast = 3.045 if month==1 & date==1
replace pricemid = 3.045 if month==1 & date==1
replace year=2017 if year==.
replace pricelast = pricelast[_n-1] if pricelast==.
replace pricemid = pricemid[_n-1] if pricemid==.

bysort final_load_segment: egen avg_gas_price = mean(pricelast)
duplicates drop final_load_segment, force
drop pricelast pricemid month date hour _merge
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_TGZ4_2017.dta", replace

** TETCO Zone M3
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned_2017.dta", clear
drop if hubname~="TETCO Zone M3"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="TETCO Zone M3" if hubname==""
sort month date hour

replace pricelast = 3.21 if month==1 & date==1
replace pricemid = 3.21 if month==1 & date==1
replace year=2017 if year==.
replace pricelast = pricelast[_n-1] if pricelast==.
replace pricemid = pricemid[_n-1] if pricemid==.

bysort final_load_segment: egen avg_gas_price = mean(pricelast)
duplicates drop final_load_segment, force
drop pricelast pricemid month date hour _merge
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_TZ3_2017.dta", replace

** Transco Leidy
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned_2017.dta", clear
drop if hubname~="Transco Leidy"
merge m:m month date using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\load segment cross-walk 2016\load segment crosswalk.dta"

replace hubname ="Transco Leidy" if hubname==""
sort month date hour

replace pricelast = 3.1325 if month==1 & date==1
replace pricemid = 3.1325 if month==1 & date==1
replace year=2017 if year==.
replace pricelast = pricelast[_n-1] if pricelast==.
replace pricemid = pricemid[_n-1] if pricemid==.

bysort final_load_segment: egen avg_gas_price = mean(pricelast)
duplicates drop final_load_segment, force
drop pricelast pricemid month date hour _merge
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_TL_2017.dta", replace

** Combining:
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_AD_2017.dta", clear
append using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_CCG_2017.dta"
append using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_DNP_2017.dta"
append using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_LOH_2017.dta"
append using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_TGZ4_2017.dta"
append using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_TZ3_2017.dta"
append using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_TL_2017.dta"
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned_all_2017_temp.dta", replace


*** MERGE 2016 and 2017 GAS PRICE:
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned_all_2016.dta", clear
merge 1:1 hubname final_load_segment using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned_all_2017_temp.dta"
drop _merge
gen gas_gr = (avg_gas_price-avg_gas_price_2016)/avg_gas_price_2016
save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned_all_2017.dta", replace
