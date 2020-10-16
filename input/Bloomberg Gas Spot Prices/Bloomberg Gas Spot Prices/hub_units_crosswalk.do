*************************************************
***2017******************************************
*************************************************
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned_all_2017.dta", clear  
drop year year2 no_of_hr_by_segment avg_gas_price avg_gas_price_2016
reshape wide gas_gr, i(hubname) j(final_load_segment)

rename hubname gashub
merge 1:m gashub using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\hub_units_crosswalk.dta"
drop _merge
sort unit_bin 
drop gashub
bysort unit_bin: egen gas_gr_bin1 = mean(gas_gr1)
bysort unit_bin: egen gas_gr_bin2 = mean(gas_gr2)
bysort unit_bin: egen gas_gr_bin3 = mean(gas_gr3)
bysort unit_bin: egen gas_gr_bin4 = mean(gas_gr4)
bysort unit_bin: egen gas_gr_bin5 = mean(gas_gr5)
bysort unit_bin: egen gas_gr_bin6 = mean(gas_gr6)
bysort unit_bin: egen gas_gr_bin7 = mean(gas_gr7)
bysort unit_bin: egen gas_gr_bin8 = mean(gas_gr8)
bysort unit_bin: egen gas_gr_bin9 = mean(gas_gr9)
bysort unit_bin: egen gas_gr_bin10 = mean(gas_gr10)
bysort unit_bin: egen gas_gr_bin11 = mean(gas_gr11)
bysort unit_bin: egen gas_gr_bin12 = mean(gas_gr12)
bysort unit_bin: egen gas_gr_bin13 = mean(gas_gr13)
bysort unit_bin: egen gas_gr_bin14 = mean(gas_gr14)
bysort unit_bin: egen gas_gr_bin15 = mean(gas_gr15)
bysort unit_bin: egen gas_gr_bin16 = mean(gas_gr16)
bysort unit_bin: egen gas_gr_bin17 = mean(gas_gr17)
bysort unit_bin: egen gas_gr_bin18 = mean(gas_gr18)
bysort unit_bin: egen gas_gr_bin19 = mean(gas_gr19)
bysort unit_bin: egen gas_gr_bin20 = mean(gas_gr20)
bysort unit_bin: egen gas_gr_bin21 = mean(gas_gr21)
bysort unit_bin: egen gas_gr_bin22 = mean(gas_gr22)
bysort unit_bin: egen gas_gr_bin23 = mean(gas_gr23)
bysort unit_bin: egen gas_gr_bin24 = mean(gas_gr24)
bysort unit_bin: egen gas_gr_bin25 = mean(gas_gr25)
bysort unit_bin: egen gas_gr_bin26 = mean(gas_gr26)
bysort unit_bin: egen gas_gr_bin27 = mean(gas_gr27)
bysort unit_bin: egen gas_gr_bin28 = mean(gas_gr28)
bysort unit_bin: egen gas_gr_bin29 = mean(gas_gr29)
bysort unit_bin: egen gas_gr_bin30 = mean(gas_gr30)
bysort unit_bin: egen gas_gr_bin31 = mean(gas_gr31)
bysort unit_bin: egen gas_gr_bin32 = mean(gas_gr32)
bysort unit_bin: egen gas_gr_bin33 = mean(gas_gr33)
bysort unit_bin: egen gas_gr_bin34 = mean(gas_gr34)
bysort unit_bin: egen gas_gr_bin35 = mean(gas_gr35)
bysort unit_bin: egen gas_gr_bin36 = mean(gas_gr36)
bysort unit_bin: egen gas_gr_bin37 = mean(gas_gr37)
bysort unit_bin: egen gas_gr_bin38 = mean(gas_gr38)
bysort unit_bin: egen gas_gr_bin39 = mean(gas_gr39)
bysort unit_bin: egen gas_gr_bin40 = mean(gas_gr40)
bysort unit_bin: egen gas_gr_bin41 = mean(gas_gr41)
bysort unit_bin: egen gas_gr_bin42 = mean(gas_gr42)
bysort unit_bin: egen gas_gr_bin43 = mean(gas_gr43)
bysort unit_bin: egen gas_gr_bin44 = mean(gas_gr44)
bysort unit_bin: egen gas_gr_bin45 = mean(gas_gr45)
bysort unit_bin: egen gas_gr_bin46 = mean(gas_gr46)
bysort unit_bin: egen gas_gr_bin47 = mean(gas_gr47)
bysort unit_bin: egen gas_gr_bin48 = mean(gas_gr48)
bysort unit_bin: egen gas_gr_bin49 = mean(gas_gr49)
bysort unit_bin: egen gas_gr_bin50 = mean(gas_gr50)
bysort unit_bin: egen gas_gr_bin51 = mean(gas_gr51)
bysort unit_bin: egen gas_gr_bin52 = mean(gas_gr52)
bysort unit_bin: egen gas_gr_bin53 = mean(gas_gr53)
bysort unit_bin: egen gas_gr_bin54 = mean(gas_gr54)
bysort unit_bin: egen gas_gr_bin55 = mean(gas_gr55)
bysort unit_bin: egen gas_gr_bin56 = mean(gas_gr56)
bysort unit_bin: egen gas_gr_bin57 = mean(gas_gr57)
bysort unit_bin: egen gas_gr_bin58 = mean(gas_gr58)
bysort unit_bin: egen gas_gr_bin59 = mean(gas_gr59)
bysort unit_bin: egen gas_gr_bin60 = mean(gas_gr60)
bysort unit_bin: egen gas_gr_bin61 = mean(gas_gr61)
bysort unit_bin: egen gas_gr_bin62 = mean(gas_gr62)
bysort unit_bin: egen gas_gr_bin63 = mean(gas_gr63)
bysort unit_bin: egen gas_gr_bin64 = mean(gas_gr64)
bysort unit_bin: egen gas_gr_bin65 = mean(gas_gr65)
bysort unit_bin: egen gas_gr_bin66 = mean(gas_gr66)
bysort unit_bin: egen gas_gr_bin67 = mean(gas_gr67)
bysort unit_bin: egen gas_gr_bin68 = mean(gas_gr68)
bysort unit_bin: egen gas_gr_bin69 = mean(gas_gr69)
bysort unit_bin: egen gas_gr_bin70 = mean(gas_gr70)
bysort unit_bin: egen gas_gr_bin71 = mean(gas_gr71)
bysort unit_bin: egen gas_gr_bin72 = mean(gas_gr72)
bysort unit_bin: egen gas_gr_bin73 = mean(gas_gr73)
bysort unit_bin: egen gas_gr_bin74 = mean(gas_gr74)
bysort unit_bin: egen gas_gr_bin75 = mean(gas_gr75)
bysort unit_bin: egen gas_gr_bin76 = mean(gas_gr76)
bysort unit_bin: egen gas_gr_bin77 = mean(gas_gr77)
bysort unit_bin: egen gas_gr_bin78 = mean(gas_gr78)
bysort unit_bin: egen gas_gr_bin79 = mean(gas_gr79)
bysort unit_bin: egen gas_gr_bin80 = mean(gas_gr80)
bysort unit_bin: egen gas_gr_bin81 = mean(gas_gr81)
bysort unit_bin: egen gas_gr_bin82 = mean(gas_gr82)
bysort unit_bin: egen gas_gr_bin83 = mean(gas_gr83)
bysort unit_bin: egen gas_gr_bin84 = mean(gas_gr84)
bysort unit_bin: egen gas_gr_bin85 = mean(gas_gr85)
bysort unit_bin: egen gas_gr_bin86 = mean(gas_gr86)
bysort unit_bin: egen gas_gr_bin87 = mean(gas_gr87)
bysort unit_bin: egen gas_gr_bin88 = mean(gas_gr88)
bysort unit_bin: egen gas_gr_bin89 = mean(gas_gr89)
bysort unit_bin: egen gas_gr_bin90 = mean(gas_gr90)
bysort unit_bin: egen gas_gr_bin91 = mean(gas_gr91)
bysort unit_bin: egen gas_gr_bin92 = mean(gas_gr92)
bysort unit_bin: egen gas_gr_bin93 = mean(gas_gr93)
bysort unit_bin: egen gas_gr_bin94 = mean(gas_gr94)
bysort unit_bin: egen gas_gr_bin95 = mean(gas_gr95)
bysort unit_bin: egen gas_gr_bin96 = mean(gas_gr96)
duplicates drop unit_bin, force

drop gas_gr1 gas_gr2 gas_gr3 gas_gr4 gas_gr5 gas_gr6 gas_gr7 gas_gr8 gas_gr9 gas_gr10 gas_gr11 gas_gr12 gas_gr13 gas_gr14 gas_gr15 gas_gr16 gas_gr17 gas_gr18 gas_gr19 gas_gr20 gas_gr21 gas_gr22 gas_gr23 gas_gr24 gas_gr25 gas_gr26 gas_gr27 gas_gr28 gas_gr29 gas_gr30 gas_gr31 gas_gr32 gas_gr33 gas_gr34 gas_gr35 gas_gr36 gas_gr37 gas_gr38 gas_gr39 gas_gr40 gas_gr41 gas_gr42 gas_gr43 gas_gr44 gas_gr45 gas_gr46 gas_gr47 gas_gr48 gas_gr49 gas_gr50 gas_gr51 gas_gr52 gas_gr53 gas_gr54 gas_gr55 gas_gr56 gas_gr57 gas_gr58 gas_gr59 gas_gr60 gas_gr61 gas_gr62 gas_gr63 gas_gr64 gas_gr65 gas_gr66 gas_gr67 gas_gr68 gas_gr69 gas_gr70 gas_gr71 gas_gr72 gas_gr73 gas_gr74 gas_gr75 gas_gr76 gas_gr77 gas_gr78 gas_gr79 gas_gr80 gas_gr81 gas_gr82 gas_gr83 gas_gr84 gas_gr85 gas_gr86 gas_gr87 gas_gr88 gas_gr89 gas_gr90 gas_gr91 gas_gr92 gas_gr93 gas_gr94 gas_gr95 gas_gr96

save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\gas_gr_unit_crosswalk_2017.dta", replace


use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\unit_order.dta", replace
rename bin unit_bin
merge 1:1 unit_bin using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\gas_gr_unit_crosswalk_2017.dta"
sort index
drop _merge index unit_bin


*************************************************
***2018******************************************
*************************************************
use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\bloomberg_gas_price_cleaned_all_2018.dta", clear  
drop year year2 no_of_hr_by_segment avg_gas_price avg_gas_price_2016
reshape wide gas_gr, i(hubname) j(final_load_segment)

rename hubname gashub
merge 1:m gashub using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\hub_units_crosswalk.dta"
drop _merge
sort unit_bin 
drop gashub
bysort unit_bin: egen gas_gr_bin1 = mean(gas_gr1)
bysort unit_bin: egen gas_gr_bin2 = mean(gas_gr2)
bysort unit_bin: egen gas_gr_bin3 = mean(gas_gr3)
bysort unit_bin: egen gas_gr_bin4 = mean(gas_gr4)
bysort unit_bin: egen gas_gr_bin5 = mean(gas_gr5)
bysort unit_bin: egen gas_gr_bin6 = mean(gas_gr6)
bysort unit_bin: egen gas_gr_bin7 = mean(gas_gr7)
bysort unit_bin: egen gas_gr_bin8 = mean(gas_gr8)
bysort unit_bin: egen gas_gr_bin9 = mean(gas_gr9)
bysort unit_bin: egen gas_gr_bin10 = mean(gas_gr10)
bysort unit_bin: egen gas_gr_bin11 = mean(gas_gr11)
bysort unit_bin: egen gas_gr_bin12 = mean(gas_gr12)
bysort unit_bin: egen gas_gr_bin13 = mean(gas_gr13)
bysort unit_bin: egen gas_gr_bin14 = mean(gas_gr14)
bysort unit_bin: egen gas_gr_bin15 = mean(gas_gr15)
bysort unit_bin: egen gas_gr_bin16 = mean(gas_gr16)
bysort unit_bin: egen gas_gr_bin17 = mean(gas_gr17)
bysort unit_bin: egen gas_gr_bin18 = mean(gas_gr18)
bysort unit_bin: egen gas_gr_bin19 = mean(gas_gr19)
bysort unit_bin: egen gas_gr_bin20 = mean(gas_gr20)
bysort unit_bin: egen gas_gr_bin21 = mean(gas_gr21)
bysort unit_bin: egen gas_gr_bin22 = mean(gas_gr22)
bysort unit_bin: egen gas_gr_bin23 = mean(gas_gr23)
bysort unit_bin: egen gas_gr_bin24 = mean(gas_gr24)
bysort unit_bin: egen gas_gr_bin25 = mean(gas_gr25)
bysort unit_bin: egen gas_gr_bin26 = mean(gas_gr26)
bysort unit_bin: egen gas_gr_bin27 = mean(gas_gr27)
bysort unit_bin: egen gas_gr_bin28 = mean(gas_gr28)
bysort unit_bin: egen gas_gr_bin29 = mean(gas_gr29)
bysort unit_bin: egen gas_gr_bin30 = mean(gas_gr30)
bysort unit_bin: egen gas_gr_bin31 = mean(gas_gr31)
bysort unit_bin: egen gas_gr_bin32 = mean(gas_gr32)
bysort unit_bin: egen gas_gr_bin33 = mean(gas_gr33)
bysort unit_bin: egen gas_gr_bin34 = mean(gas_gr34)
bysort unit_bin: egen gas_gr_bin35 = mean(gas_gr35)
bysort unit_bin: egen gas_gr_bin36 = mean(gas_gr36)
bysort unit_bin: egen gas_gr_bin37 = mean(gas_gr37)
bysort unit_bin: egen gas_gr_bin38 = mean(gas_gr38)
bysort unit_bin: egen gas_gr_bin39 = mean(gas_gr39)
bysort unit_bin: egen gas_gr_bin40 = mean(gas_gr40)
bysort unit_bin: egen gas_gr_bin41 = mean(gas_gr41)
bysort unit_bin: egen gas_gr_bin42 = mean(gas_gr42)
bysort unit_bin: egen gas_gr_bin43 = mean(gas_gr43)
bysort unit_bin: egen gas_gr_bin44 = mean(gas_gr44)
bysort unit_bin: egen gas_gr_bin45 = mean(gas_gr45)
bysort unit_bin: egen gas_gr_bin46 = mean(gas_gr46)
bysort unit_bin: egen gas_gr_bin47 = mean(gas_gr47)
bysort unit_bin: egen gas_gr_bin48 = mean(gas_gr48)
bysort unit_bin: egen gas_gr_bin49 = mean(gas_gr49)
bysort unit_bin: egen gas_gr_bin50 = mean(gas_gr50)
bysort unit_bin: egen gas_gr_bin51 = mean(gas_gr51)
bysort unit_bin: egen gas_gr_bin52 = mean(gas_gr52)
bysort unit_bin: egen gas_gr_bin53 = mean(gas_gr53)
bysort unit_bin: egen gas_gr_bin54 = mean(gas_gr54)
bysort unit_bin: egen gas_gr_bin55 = mean(gas_gr55)
bysort unit_bin: egen gas_gr_bin56 = mean(gas_gr56)
bysort unit_bin: egen gas_gr_bin57 = mean(gas_gr57)
bysort unit_bin: egen gas_gr_bin58 = mean(gas_gr58)
bysort unit_bin: egen gas_gr_bin59 = mean(gas_gr59)
bysort unit_bin: egen gas_gr_bin60 = mean(gas_gr60)
bysort unit_bin: egen gas_gr_bin61 = mean(gas_gr61)
bysort unit_bin: egen gas_gr_bin62 = mean(gas_gr62)
bysort unit_bin: egen gas_gr_bin63 = mean(gas_gr63)
bysort unit_bin: egen gas_gr_bin64 = mean(gas_gr64)
bysort unit_bin: egen gas_gr_bin65 = mean(gas_gr65)
bysort unit_bin: egen gas_gr_bin66 = mean(gas_gr66)
bysort unit_bin: egen gas_gr_bin67 = mean(gas_gr67)
bysort unit_bin: egen gas_gr_bin68 = mean(gas_gr68)
bysort unit_bin: egen gas_gr_bin69 = mean(gas_gr69)
bysort unit_bin: egen gas_gr_bin70 = mean(gas_gr70)
bysort unit_bin: egen gas_gr_bin71 = mean(gas_gr71)
bysort unit_bin: egen gas_gr_bin72 = mean(gas_gr72)
bysort unit_bin: egen gas_gr_bin73 = mean(gas_gr73)
bysort unit_bin: egen gas_gr_bin74 = mean(gas_gr74)
bysort unit_bin: egen gas_gr_bin75 = mean(gas_gr75)
bysort unit_bin: egen gas_gr_bin76 = mean(gas_gr76)
bysort unit_bin: egen gas_gr_bin77 = mean(gas_gr77)
bysort unit_bin: egen gas_gr_bin78 = mean(gas_gr78)
bysort unit_bin: egen gas_gr_bin79 = mean(gas_gr79)
bysort unit_bin: egen gas_gr_bin80 = mean(gas_gr80)
bysort unit_bin: egen gas_gr_bin81 = mean(gas_gr81)
bysort unit_bin: egen gas_gr_bin82 = mean(gas_gr82)
bysort unit_bin: egen gas_gr_bin83 = mean(gas_gr83)
bysort unit_bin: egen gas_gr_bin84 = mean(gas_gr84)
bysort unit_bin: egen gas_gr_bin85 = mean(gas_gr85)
bysort unit_bin: egen gas_gr_bin86 = mean(gas_gr86)
bysort unit_bin: egen gas_gr_bin87 = mean(gas_gr87)
bysort unit_bin: egen gas_gr_bin88 = mean(gas_gr88)
bysort unit_bin: egen gas_gr_bin89 = mean(gas_gr89)
bysort unit_bin: egen gas_gr_bin90 = mean(gas_gr90)
bysort unit_bin: egen gas_gr_bin91 = mean(gas_gr91)
bysort unit_bin: egen gas_gr_bin92 = mean(gas_gr92)
bysort unit_bin: egen gas_gr_bin93 = mean(gas_gr93)
bysort unit_bin: egen gas_gr_bin94 = mean(gas_gr94)
bysort unit_bin: egen gas_gr_bin95 = mean(gas_gr95)
bysort unit_bin: egen gas_gr_bin96 = mean(gas_gr96)
duplicates drop unit_bin, force

drop gas_gr1 gas_gr2 gas_gr3 gas_gr4 gas_gr5 gas_gr6 gas_gr7 gas_gr8 gas_gr9 gas_gr10 gas_gr11 gas_gr12 gas_gr13 gas_gr14 gas_gr15 gas_gr16 gas_gr17 gas_gr18 gas_gr19 gas_gr20 gas_gr21 gas_gr22 gas_gr23 gas_gr24 gas_gr25 gas_gr26 gas_gr27 gas_gr28 gas_gr29 gas_gr30 gas_gr31 gas_gr32 gas_gr33 gas_gr34 gas_gr35 gas_gr36 gas_gr37 gas_gr38 gas_gr39 gas_gr40 gas_gr41 gas_gr42 gas_gr43 gas_gr44 gas_gr45 gas_gr46 gas_gr47 gas_gr48 gas_gr49 gas_gr50 gas_gr51 gas_gr52 gas_gr53 gas_gr54 gas_gr55 gas_gr56 gas_gr57 gas_gr58 gas_gr59 gas_gr60 gas_gr61 gas_gr62 gas_gr63 gas_gr64 gas_gr65 gas_gr66 gas_gr67 gas_gr68 gas_gr69 gas_gr70 gas_gr71 gas_gr72 gas_gr73 gas_gr74 gas_gr75 gas_gr76 gas_gr77 gas_gr78 gas_gr79 gas_gr80 gas_gr81 gas_gr82 gas_gr83 gas_gr84 gas_gr85 gas_gr86 gas_gr87 gas_gr88 gas_gr89 gas_gr90 gas_gr91 gas_gr92 gas_gr93 gas_gr94 gas_gr95 gas_gr96

save "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\gas_gr_unit_crosswalk_2018.dta", replace


use "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\unit_order.dta", replace
rename bin unit_bin
merge 1:1 unit_bin using "C:\Users\An\Box Sync\CPP Trading\Data\Calibration v1\Model in MATLAB\Bloomberg Gas Spot Prices\gas_gr_unit_crosswalk_2018.dta"
sort index
drop _merge index unit_bin
