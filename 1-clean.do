clear all 

import delimited "C:\Users\jsemprini\OneDrive - University of Iowa\6-HNC\5-MDPI-HPV2\raw\hpv_case.csv"

tab hpvrecode20102017, gen(dum_hpv)

gen hpv=.
replace hpv=0 if hpvrecode20102017=="HPV Negative"
replace hpv=1 if hpvrecode20102017=="HPV Positive"

drop hpvrecode20102017 dum*

order hpv

tab siterecodeicdo3who2008, gen(dum_site)

destring(monthsfromdiagnosistotreatment), force gen(m2tx)

order hpv m2tx

rename year year
rename m2tx mo2tx

rename (agerecodewith1yearolds raceandoriginrecodenhwnhbnhaiann sex maritalstatusatdiagnosis seerregistrywithcaandgaaswholest) (age race sex marital state)
foreach x in age race sex marital state{
	
	tab `x', gen(dum_`x')

}

tab tnm7csv0204schemarecode, gen(dum_schema)
drop tnm7csv0204schemathru2017

foreach x in behaviorrecodeforanalysis gradethru2017 gradeclinical2018 gradepathological2018 diagnosticconfirmation{
	
	tab `x'
}

drop behaviorrecodeforanalysis
drop diagnosticconfirmation
drop behaviorcodeicdo2

gen grade=0
replace grade=1 if gradethru2017=="Well differentiated; Grade I" | gradeclinical2018=="1"
replace grade=2 if gradethru2017=="Moderately differentiated; Grade II" | gradeclinical2018=="2"
replace grade=3 if gradethru2017=="Poorly differentiated; Grade III" | gradeclinical2018=="3"
replace grade=4 if gradethru2017=="Undifferentiated; anaplastic; Grade IV" | gradeclinical2018=="4"

drop gradethru gradeclin gradepath

gen scc=0
replace scc=1 if histologyrecodebroadgroupings=="8050-8089: squamous cell neoplasms"

drop histologyrecodebroadgroupings 

rename histologyicdo2 histology
destring(histology), force replace


foreach x in combinedsummarystage2004 summarystage200019982017  seerhistoricstagea19732015{
	
	tab `x'
}

drop seercombinedsummarystage20002004

gen stage=combinedsummarystage2004 if year>=2004
replace stage=summarystage200019982017 if year<=2003

replace stage="Localized" if stage=="In situ"

replace stage=seerhistoricstagea19732015 if stage=="Blank(s)"

replace stage="Unknown" if stage=="Unknown/unstaged" | stage=="Unstaged"

tab stage, gen(dum_stage)

rename dum_stage2 localized
rename dum_stage3 regional
rename dum_stage1 distant
rename dum_stage4 stage_unknown

drop combinedsummarystage2004 summarystage200019982017 seerhistoricstagea19732015

global controls dum_* grade scc histology localized regional distant stage_unknown

foreach x in  rxsummsurgradseq   rxsummsystemicsurseq{
	tab `x', gen(dum_rx`x')
}

gen surg_primary=.
replace surg_primary=0 if rxsummsurgprimsite1998==0
replace surg_primary=1 if rxsummsurgprimsite1998>0 & rxsummsurgprimsite1998<90

gen ln_removed=.
replace ln_removed=0 if rxsummscopereglnsur2003=="None"
replace ln_removed=1 if rxsummscopereglnsur2003!="None" & rxsummscopereglnsur2003!="Blank(s)" & rxsummscopereglnsur2003!="Unknown or not applicable"

drop rxsummscopereglnsur2003
drop rxsummsurgothregdis2003

gen chemo=0
replace chemo=1 if chemotherapyrecodeyesnounk=="Yes"

drop chemotherapyrecodeyesnounk

gen rad=1
replace rad=0 if radiationrecode=="None/Unknown"| radiationrecode=="Recommended, unknown if administered" | radiationrecode=="Refused (1988+)"

drop radiationrecode

gen surg_any=0
replace surg_any=1 if reasonnocancerdirectedsurgery== "Surgery performed"

gen surg_notrec=0
replace surg_notrec=1 if reasonnocancerdirectedsurgery=="Not recommended"

drop reasonnocancerdirectedsurgery

gen syst_rad=1
replace syst_rad=0 if dum_rxrxsummsurgradseq3==1

rename syst_rad postop_rad

gen systemic=1 
replace systemic=0 if dum_rxrxsummsystemicsurseq1==1 | dum_rxrxsummsystemicsurseq4==1

drop dum_rxrxsummsurgradseq1 dum_rxrxsummsurgradseq2 dum_rxrxsummsurgradseq3 dum_rxrxsummsurgradseq4 dum_rxrxsummsurgradseq5 dum_rxrxsummsurgradseq6 dum_rxrxsummsurgradseq7 dum_rxrxsummsurgradseq8 dum_rxrxsummsystemicsurseq1 dum_rxrxsummsystemicsurseq2 dum_rxrxsummsystemicsurseq3 dum_rxrxsummsystemicsurseq4 dum_rxrxsummsystemicsurseq5 dum_rxrxsummsystemicsurseq6 dum_rxrxsummsystemicsurseq7 dum_rxrxsummsystemicsurseq8 dum_rxrxsummsystemicsurseq9

drop  rxsummsurgradseq rxsummsystemicsurseq

global treatment surg_primary surg_any surg_notrec ln_removed chemo rad postop_rad systemic

foreach x in survivalmonths survivalmonthsflag {
	
	tab `x'
}

gen alive=0
replace alive=1 if vitalstatusrecodestudycutoffused=="Alive"

gen dead=0
replace dead=1 if alive==0

drop vitalstatusrecodestudycutoffused
drop codtositereckm

rename dead allcause

gen cancercause=0
replace cancercause=1 if seercausespecificdeathclassifica=="Dead (attributable to this cancer dx)"

drop codtositerecode seercausespecificdeathclassifica seerothercauseofdeathclassificat 

sum survivalmonths

gen surv_1yr=0
replace surv_1yr=1 if survivalmonths>=12

gen surv_2yr=0
replace surv_2yr=1 if survivalmonths>=24

gen surv_5yr=0
replace surv_5yr=1 if survivalmonths>=60

global survival survivalmonths alive dead cancercause surv_1yr surv_2yr surv_5yr 

gen pharynx=0
foreach p in TongueBase PharyngealTonsil EpiglottisAnterior Oropharynx PalateSoft Hypopharynx Nasopharynx PharynxOther  {
	
replace pharynx=1 if tnm7csv0204schemarecode=="`p'"
}

gen code_hpv=hpv
replace code_hpv=0 if pharynx==0

***set up HPV imputation***
mi query
misstable summarize code_hpv
mi set wide
mi register imputed code_hpv
mi impute chained (logit, include(histology  dum_schema* grade scc) bootstrap) code_hpv, add(100) rseed(1) double force

****test imputation****

	sum _1_code_hpv _2_code_hpv _3_code_hpv _4_code_hpv _5_code_hpv _6_code_hpv _7_code_hpv _8_code_hpv _9_code_hpv _10_code_hpv _11_code_hpv _12_code_hpv _13_code_hpv _14_code_hpv _15_code_hpv _16_code_hpv _17_code_hpv _18_code_hpv _19_code_hpv _20_code_hpv _21_code_hpv _22_code_hpv _23_code_hpv _24_code_hpv _25_code_hpv _26_code_hpv _27_code_hpv _28_code_hpv _29_code_hpv _30_code_hpv _31_code_hpv _32_code_hpv _33_code_hpv _34_code_hpv _35_code_hpv _36_code_hpv _37_code_hpv _38_code_hpv _39_code_hpv _40_code_hpv _41_code_hpv _42_code_hpv _43_code_hpv _44_code_hpv _45_code_hpv _46_code_hpv _47_code_hpv _48_code_hpv _49_code_hpv _50_code_hpv _51_code_hpv _52_code_hpv _53_code_hpv _54_code_hpv _55_code_hpv _56_code_hpv _57_code_hpv _58_code_hpv _59_code_hpv _60_code_hpv _61_code_hpv _62_code_hpv _63_code_hpv _64_code_hpv _65_code_hpv _66_code_hpv _67_code_hpv _68_code_hpv _69_code_hpv _70_code_hpv _71_code_hpv _72_code_hpv _73_code_hpv _74_code_hpv _75_code_hpv _76_code_hpv _77_code_hpv _78_code_hpv _79_code_hpv _80_code_hpv _81_code_hpv _82_code_hpv _83_code_hpv _84_code_hpv _85_code_hpv _86_code_hpv _87_code_hpv _88_code_hpv _89_code_hpv _90_code_hpv _91_code_hpv _92_code_hpv _93_code_hpv _94_code_hpv _95_code_hpv _96_code_hpv _97_code_hpv _98_code_hpv _99_code_hpv _100_code_hpv if code_hpv==.


egen tot_hpv = rowtotal(_1_code_hpv _2_code_hpv _3_code_hpv _4_code_hpv _5_code_hpv _6_code_hpv _7_code_hpv _8_code_hpv _9_code_hpv _10_code_hpv _11_code_hpv _12_code_hpv _13_code_hpv _14_code_hpv _15_code_hpv _16_code_hpv _17_code_hpv _18_code_hpv _19_code_hpv _20_code_hpv _21_code_hpv _22_code_hpv _23_code_hpv _24_code_hpv _25_code_hpv _26_code_hpv _27_code_hpv _28_code_hpv _29_code_hpv _30_code_hpv _31_code_hpv _32_code_hpv _33_code_hpv _34_code_hpv _35_code_hpv _36_code_hpv _37_code_hpv _38_code_hpv _39_code_hpv _40_code_hpv _41_code_hpv _42_code_hpv _43_code_hpv _44_code_hpv _45_code_hpv _46_code_hpv _47_code_hpv _48_code_hpv _49_code_hpv _50_code_hpv _51_code_hpv _52_code_hpv _53_code_hpv _54_code_hpv _55_code_hpv _56_code_hpv _57_code_hpv _58_code_hpv _59_code_hpv _60_code_hpv _61_code_hpv _62_code_hpv _63_code_hpv _64_code_hpv _65_code_hpv _66_code_hpv _67_code_hpv _68_code_hpv _69_code_hpv _70_code_hpv _71_code_hpv _72_code_hpv _73_code_hpv _74_code_hpv _75_code_hpv _76_code_hpv _77_code_hpv _78_code_hpv _79_code_hpv _80_code_hpv _81_code_hpv _82_code_hpv _83_code_hpv _84_code_hpv _85_code_hpv _86_code_hpv _87_code_hpv _88_code_hpv _89_code_hpv _90_code_hpv _91_code_hpv _92_code_hpv _93_code_hpv _94_code_hpv _95_code_hpv _96_code_hpv _97_code_hpv _98_code_hpv _99_code_hpv _100_code_hpv)

gen imp_hpv=hpv
replace imp_hpv=0 if hpv==. & tot_hpv<50
replace imp_hpv=1 if hpv==. & tot_hpv>=50 

tab hpv imp_hpv, missing

drop _1_code_hpv _2_code_hpv _3_code_hpv _4_code_hpv _5_code_hpv _6_code_hpv _7_code_hpv _8_code_hpv _9_code_hpv _10_code_hpv _11_code_hpv _12_code_hpv _13_code_hpv _14_code_hpv _15_code_hpv _16_code_hpv _17_code_hpv _18_code_hpv _19_code_hpv _20_code_hpv _21_code_hpv _22_code_hpv _23_code_hpv _24_code_hpv _25_code_hpv _26_code_hpv _27_code_hpv _28_code_hpv _29_code_hpv _30_code_hpv _31_code_hpv _32_code_hpv _33_code_hpv _34_code_hpv _35_code_hpv _36_code_hpv _37_code_hpv _38_code_hpv _39_code_hpv _40_code_hpv _41_code_hpv _42_code_hpv _43_code_hpv _44_code_hpv _45_code_hpv _46_code_hpv _47_code_hpv _48_code_hpv _49_code_hpv _50_code_hpv _51_code_hpv _52_code_hpv _53_code_hpv _54_code_hpv _55_code_hpv _56_code_hpv _57_code_hpv _58_code_hpv _59_code_hpv _60_code_hpv _61_code_hpv _62_code_hpv _63_code_hpv _64_code_hpv _65_code_hpv _66_code_hpv _67_code_hpv _68_code_hpv _69_code_hpv _70_code_hpv _71_code_hpv _72_code_hpv _73_code_hpv _74_code_hpv _75_code_hpv _76_code_hpv _77_code_hpv _78_code_hpv _79_code_hpv _80_code_hpv _81_code_hpv _82_code_hpv _83_code_hpv _84_code_hpv _85_code_hpv _86_code_hpv _87_code_hpv _88_code_hpv _89_code_hpv _90_code_hpv _91_code_hpv _92_code_hpv _93_code_hpv _94_code_hpv _95_code_hpv _96_code_hpv _97_code_hpv _98_code_hpv _99_code_hpv _100_code_hpv

*drop if year<2007



save "C:\Users\jsemprini\OneDrive - University of Iowa\6-HNC\5-MDPI-HPV2\stata\hpvcase_20002018.dta", replace


