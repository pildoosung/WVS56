*WVS longitudinal
set more off
use "/Users/pildoosung/Library/Mobile Documents/com~apple~CloudDocs/DATA/WVS_Longitudinal_1981_2014_stata_v2015_04_18.dta", clear
keep if S002==5|S002==6 // Keep 5th and 6th waves  
drop if S003==320|S003==364|S003==554|S003==891 // drop Iran, Gutemala, New Zealand, and Serbia and Montenegro: trust not avaialble

*Individual variables: health, ingroup/outgroup/general trust, membership, mastery, and emancipative values
gen health= (A009==1|A009==2) if A009>0
recode D001_B G007_18_B G007_33_B G007_34_B G007_35_B G007_36_B (-5=.)(-1=.)(-4=.)(-2=.)(-3=.)(4=1)(3=2)(2=3)(1=4), prefix(R)
gen ingroup=(RD001_B+RG007_18_B+RG007_33_B)/3
gen outgroup=(RG007_34_B+RG007_35_B+RG007_36_B)/3
gen general= (A165==1) if A165>0
recode A098-A106B A174 (-5=.)(-4=.)(-3=.)(-2=.)(-1=.)(0=0)(1=1)(2=1), prefix(R)
gen m_membership=. // missing in membership: 41,547 (25.4%) 
replace m_membership=RA098+RA099+RA100+RA101+RA102+RA103+RA104+RA105+RA106+RA174 if S002==5
replace m_membership=RA098+RA099+RA100+RA101+RA102+RA103+RA104+RA105+RA106+RA106B if S002==6
egen membership=rowtotal(RA098-RA174) // temporarily reduce missing in membership: consider missing=0
gen mastery=A173 if A173>0 
gen eman=Y020

*Individual controls: age, female, married, income, educ, employed, fulltime, relig
gen age=X003 if X003>0
gen female= (X001==2) if X001>0
gen married= (X007==1|X007==2) if X007>0
gen income=X047 if X047>0
gen educ=X025 if X025>0
recode educ (1=1)(2=1)(3=1)(4=2)(5=1)(6=2)(7=3)(8=4)(9=4)
gen employed= (X028==1|X028==2|X028==3) if X028>0
gen fulltime= (X028==1) if X028>0
gen relig= (F034==1) if F034>0

sum health ingroup outgroup general membership mastery eman age female married income educ employed fulltime relig 
save "/Users/pildoosung/Library/Mobile Documents/com~apple~CloudDocs/DATA/WVS.dta", replace

*Append India data in latest version of WVS6 
use "/Users/pildoosung/Library/Mobile Documents/com~apple~CloudDocs/DATA/WV6_Stata_v_2016_01_01.dta", clear
keep if V2==356
gen S002=V1
gen S003=V2
gen S020=V262

*Coding individual variables
gen health= (V11==1|V11==2) if V11>0
recode V102-V107 (-5=.)(-1=.)(-4=.)(-2=.)(-3=.)(4=1)(3=2)(2=3)(1=4), prefix(M)
gen ingroup=(MV102+MV103+MV104)/3 
gen outgroup=(MV105+MV106+MV107)/3
gen general= (V24==1) if V24>0
recode V25-V33 V35 (-5=.)(-4=.)(-3=.)(-2=.)(-1=.)(0=0)(1=1)(2=1), prefix(M)
gen m_membership=MV25+MV26+MV27+MV28+MV29+MV30+MV31+MV32+MV33+MV35 
egen membership=rowtotal(MV25-MV35)
gen mastery=V55 if V55>0
gen eman=resemaval
gen age=V242 if V242>0
gen female= (V240==2) if V240>0
gen married= (V57==1|V57==2) if V57>0
gen income=V239 if V239>0
recode income (1=1)(2=1)(3=1)(4=2)(5=2)(6=2)(7=3)(8=3)(9=3)(10=3)
gen educ=V248 if V248>0
recode educ (1=1)(2=1)(3=1)(4=2)(5=2)(6=2)(7=3)(8=3)(9=3)
gen employed= (V229==1|V229==2|V229==3) if V229>0
gen fulltime= (V229==1) if V229>0
gen relig= (V147==1) if V147>0

sum health ingroup outgroup general membership mastery eman age female married income educ employed fulltime relig 
drop V1-WEIGHT4B
save "/Users/pildoosung/Library/Mobile Documents/com~apple~CloudDocs/DATA/WV6_India.dta", replace

*Country level: data cleaning from different sources

*GDP (Feenstra et al. 2015): Penn World Tables (PWT version 9.0 (June, 2016) 
*data to be downloaded from http://www.rug.nl/research/ggdc/data/pwt/pwt-9.0
use "/Users/pildoosung/Library/Mobile Documents/com~apple~CloudDocs/DATA/pwt90.dta", clear
kountry countrycode, from(iso3c) // use third party program "kountry" to standardize country name 
gen gdppc=rgdpe/pop // generate GDP per capita
keep NAMES_STD year gdppc // keep key variables 
save "/Users/pildoosung/Library/Mobile Documents/com~apple~CloudDocs/DATA/gdppc.dta", replace

*GINI (Solt, 2016): The Standardized World Income Ineqluality Database (SWIID version 5.1 (July, 2016))
*data to be downloaded from https://dataverse.harvard.edu/dataset.xhtml?persistentId=hdl:1902.1/11992
use "/Users/pildoosung/Library/Mobile Documents/com~apple~CloudDocs/DATA/SWIIDv5_1.dta", clear
replace country="South Korea" if country=="Korea, Republic of" // have to manually convert country names
replace country="Russia" if country=="Russian Federation" 
replace country="Vietnam" if country=="Viet Nam" 
replace country="Yemen" if country=="Yemen, Republic of" 
drop gini_market-_100_abs_red
egen GINI=rowmean(_1_gini_net-_100_gini_net) // temporarily calculate mean gini scores to simplify the analysis
save "/Users/pildoosung/Library/Mobile Documents/com~apple~CloudDocs/DATA/gini.dta", replace

*QOG: The Quality of Government institute (QOG Standard data version Jan, 2016)
use "/Users/pildoosung/Library/Mobile Documents/com~apple~CloudDocs/DATA/qog_std_ts_jan16.dta", clear
gen S003=ccode // to match country code with WVS data
keep S003 year wdi_pop wdi_pop65 al_ethnic fe_etfra wdi_gdppccur wdi_gini ti_cpi wbgi_rle wbgi_pse wdi_hetot wdi_lifexptot
save "/Users/pildoosung/Library/Mobile Documents/com~apple~CloudDocs/DATA/qog.dta", replace

*Append Indian samples 
use "/Users/pildoosung/Library/Mobile Documents/com~apple~CloudDocs/DATA/WVS.dta", clear
drop if S002==6&S003==356 // drop 6th wave India data only
append using "/Users/pildoosung/Library/Mobile Documents/com~apple~CloudDocs/DATA/WV6_India.dta"

*Merge data  GDP, GINI, and QOG data
kountry S003, from(iso3n) geo(un) // create standardized country variable and regions
replace NAMES_STD = "Taiwan" if NAMES_STD=="158" // have to manually convert Taiwan
gen country=NAMES_STD
replace GEO = "Asia" if NAMES_STD=="Taiwan"
gen year=S020 // matching survey year 

merge m:1 NAMES_STD year using "/Users/pildoosung/Library/Mobile Documents/com~apple~CloudDocs/DATA/gdppc.dta"
drop if _merge==2
drop _merge // GDP per capita
merge m:1 S003 year using "/Users/pildoosung/Library/Mobile Documents/com~apple~CloudDocs/DATA/qog.dta"
drop if _merge==2
drop _merge // QOG 
merge m:1 country year using "/Users/pildoosung/Library/Mobile Documents/com~apple~CloudDocs/DATA/gini.dta"
drop if _merge==2
drop _merge // GINI: missing - Algeria, Andorra, Azerbaijan, Bahrain, Palestine, Iraq, Kuwair, Lebanon, Libya, 
            // Pakistan, Qatar, Zimbabwe, T.Tobago, Tunisia, Uzbekistan, Yemen

* Country level variables: in/outgroup trust, population, ethnic, gdp, gini, cpi, democracy, health expenditure, and life exp.  
egen ingroup_c=mean(ingroup), by(S003) 
egen outgroup_c=mean(outgroup), by(S003)
gen pop=log(wdi_pop)
egen log_pop=mean(pop), by(S003)
gen ethnic=fe_etfra
replace ethnic=al_ethnic if eth==.
egen eth=mean(ethnic), by(S003)
replace gdppc=wdi_gdppccur if S003==20|S003==434 // replace missing in Andorra and Libya from WDI GDP data
gen gdp_pc=log(gdppc)
egen log_gdppc=mean(gdp_pc), by(S003)
replace GINI=wdi_gini if GINI==. // gini in IRAQ was added from WDI estimates
egen gini=mean(GINI), by(S003)
egen cpi=mean(ti_cpi), by(S003)
egen law=mean(wbgi_rle), by(S003)
egen hexp=mean(wdi_hetot), by(S003)
egen lifexp=mean(wdi_lifexptot), by(S003)

sum ingroup_c outgroup_c log_pop eth log_gdppc gini cpi law hexp lifexp

*Center/standardize the variable (check "ssc install center") 
center ingroup outgroup membership eman mastery ///
age female married income educ employed fulltime relig  ///
ingroup_c outgroup_c log_pop eth log_gdppc gini cpi law hexp lifexp, prefix(cent_) 
center ingroup outgroup membership eman ///
age female married income educ employed fulltime relig mastery ///
ingroup_c outgroup_c log_pop eth log_gdppc gini cpi law hexp lifexp, prefix(std_) standardize
 
*Interaction variables
*1)individual
gen inoutgroup=cent_ingroup*cent_outgroup
*2)ind*country
gen in_ingroup=cent_ingroup*cent_ingroup_c
gen in_outgroup=cent_ingroup*cent_outgroup_c
gen out_ingroup=cent_outgroup*cent_ingroup_c
gen out_outgroup=cent_outgroup*cent_outgroup_c

*Multiple imputation at lindividual level variables (not done yet) 

mi update

*1) Identify missing values (check "ssc install fmiss")
fmiss health ingroup outgroup m_membership mastery eman ///
age female married income educ employed fulltime relig

*2) MI set/register
mi set wide
mi register imputed health ingroup outgroup membership mastery eman ///
age female married income educ employed fulltime relig

*3) Imputation
mi xtset, clear 
mi stset, clear // clear previously made MIs from merged data

mi impute chained (logit) health female married employed fulltime relig ///
(ologit) membership mastery income educ  ///
(pmm, knn(10)) ingroup outgroup (regress) eman age, augment force noisily add(5) rseed(5342)

