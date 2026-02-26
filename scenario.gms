$ontext
    scenario file for sasm

$offtext

* This file is included in the main sasm file and contains settings for the scenario to be run.
* It is read in at the beginning of the main file, before any calculations are done.
* This allows you to easily change settings for different scenarios without having to edit the main file.

* --- PARAMETER DEFINITIONS
* -- Define time horizons and scalars

* - Choose simulation year
YEAR = 2025;
* Time parameters defined in main model code:
* YR  = Number of years from base year 2025; YEAR - 0
* YRA = Number of years from base year for acreages, 2022; YEAR - 2022
* YRT = Number of years from base year for technical coefficients, 2020; YEAR - 2020

* - Activate long-run effects
LONGRUN  =    no;
LONGRUN1 =    yes;
LONGRUN2 =    yes;
* LONGRUN  = no for short run analysis, i.e. without depreciation of buildings and investments. Base year for acreage och buildings is 2021
* LONGRUN1 = no for analysis without price changes. If LONGRUN1 = yes, LONGRUN should also be yes.
* LONGRUN2 = no for analysis without productivity development

* - Set exchange rate, SEK/EUR
KURS = 11.2;

* - Consumer price index
KPI =  1.267;
KPI2 = 1.034;
KPI3 = 1.248;
* KPI changes consumer price index from base year
* KPI2 changes consumer price index from 2023
* KPI3 changed all prices from base year to monetary value 2024

* - Productivity development
prodGrowthYields    = 1.005;
prodGrowthInputs    = 0.995;
prodGrowthLabour    = 0.985;
prodGrowthPower     = 0.985;

* - Activate GHG emissions embodied in traded goods
CO2IMP   =    no;
* CO2IMP = no for analysis without climate effects of imported inputs and products

RED =  1.00;
* Reduction factor in trade and transport


* --- FARM PAYMENTS ADJUSTMENTS
* supportPct: percentage change in decimal, e.g. 0.10 = +10%, -0.05 = -5%
* supportAdd: absolute value change in EUR/ha or SEK/ha; use currency indicated on respective row below

* Basic income support for sustainability (BISS). Baseline value: 138 EUR
supportPct('GACRSUB') = 0;
supportAdd('GACRSUB') = 0;

* Coupled direct payments to cattle (CIS). Baseline value: 91 EUR
supportPct('CATTLESUB') = 0;
supportAdd('CATTLESUB') = 0;

* - Eco-schemes: Schemes for the climate, the environment and animal welfare
* Eco-scheme 1: not in use
supportPct('ES1') = 0;
supportAdd('ES1') = 0;
* Eco-scheme 2: not in use
supportPct('ES2') = 0;
supportAdd('ES2') = 0;
* Eco-scheme 3: precision farming. Baseline value: 25 EUR
supportPct('ES3') = 0;
supportAdd('ES3') = 0;
* Eco-scheme 4: cover crop. Baseline value: 128 EUR
supportPct('ES4') = 0;
supportAdd('ES4') = 0;
* Eco-scheme 5: catch crop. Baseline value: 147 EUR
supportPct('ES5') = 0;
supportAdd('ES5') = 0;
* Eco-scheme 6: spring tilling. Baseline value: 69 EUR
supportPct('ES6') = 0;
supportAdd('ES6') = 0;
* Payment for organic production. Baseline value: 1000 EUR
supportPct('ECOSUB') = 0;
supportAdd('ECOSUB') = 0;
* Payment for forage production (vallstöd). Baseline value: 500 SEK
supportPct('FORSUB') = 0;
supportAdd('FORSUB') = 0;

* -- CAP: Rural development
* - Environmental, climate-related and other management commitments (ENVCLIM)
* Livestock subsidy for sow health. Baseline value: 2100 SEK
supportPct('SOWHLTSUB') = 0;
supportAdd('SOWHLTSUB') = 0;
* Standard payment for permanent pasture. Baseline value: 1850 SEK
supportPct('BIODIVSUB') = 0;
supportAdd('BIODIVSUB') = 0;
* Higher payment for permanent pasture. Baseline value: 2100 SEK
supportPct('BIODIVSUB2') = 0;
supportAdd('BIODIVSUB2') = 0;
* Highest payment for top value pasture. Baseline value: 3950 SEK
supportPct('BIODIVSUB3') = 0;
supportAdd('BIODIVSUB3') = 0;
* Payment for permanent pasture on Alvaret. Baseline value: 1400 SEK
supportPct('BIODIVSUBA') = 0;
supportAdd('BIODIVSUBA') = 0;
* Payment for permanent pasture in forest. Baseline value: 3500 SEK
supportPct('BIODIVSUBF') = 0;
supportAdd('BIODIVSUBF') = 0;
* Payment for permanent pasture on mosaic land. Baseline value: 2700 SEK
supportPct('BIODIVSUBM') = 0;
supportAdd('BIODIVSUBM') = 0;
* Payment for permanent pasture on low productive land (gräsfattig mark). Baseline value: 2700 SEK
supportPct('BIODIVSUBG') = 0;
supportAdd('BIODIVSUBG') = 0;
* Payment for permanent chalet pasture (fäbod). Baseline value: 2000 SEK
supportPct('BIODIVSUBC') = 0;
supportAdd('BIODIVSUBC') = 0;
* Payment for land with hay meadow (slåtteräng). Baseline value: 5500 SEK
supportPct('BIODIVSUBS') = 0;
supportAdd('BIODIVSUBS') = 0;

* - Natural or other area-specific constraints (ANC)
* Compensation subsidy base level
*supportPct('COMPSUB') = 0;
*supportAdd('COMPSUB') = 0;
* Compensation subsidy added per livestock unit:
*supportPct('COMPSUBL') = 0;
*supportAdd('COMPSUBL') = 0;
* (Acreage restriction on COMPSUPL: 1000 support units)
*supportPct('COMPSUBF') = 0;
*supportAdd('COMPSUBF') = 0;
* Compensation subsidy for grain etc
*supportPct('COMP4SUB') = 0;
*supportAdd('COMP4SUB') = 0;

* -- National policy
* National support for less favoured areas. Baseline value: 1
supportPct('NATSUB') = 0;
supportAdd('NATSUB') = 0;
* Tax reduction on sales instead of on diesel.
supportPct('FARMSUB') = 0;
supportAdd('FARMSUB') = 0;


* --- OUTPUT CONTROLS

* - Define which folder to store results in
$setGlobal resultFolder output
* - Give results a name
$setGlobal scenarioName baseline

* -- Output control set OC
* OC controls which result blocks are written to the output
* Toggle items by commenting/uncommenting the yes lines below.
  OC('DSETS')    =  yes;
  OC('PARAM')    =  no;
  OC('PRODIO')   =  yes;
  OC('CONST')    =  no;
  OC('UTCOST')   =  no;
  OC('DATA')     =  no;
  OC('PRODUCTS') =  yes;
  OC('PPRICES')  =  yes;
  OC('INPUTS')   =  yes;
  OC('IPRICES')  =  yes;
  OC('PRODACT')  =  yes;
  OC('VARS')     =  yes;
  OC('EQNS')     =  no;

* DSETS     Display of dynamic sets:                PNED, PNFD, PRED, PRFD, PSED, PSFD, INES, INFS, IRES, IRFS, ISES, ISFS,
*                                                   RIR, RSR, RSRIS, RPR, RSRPS, PREX, PRIM, RPREX, RPRIM, RSRAS, T, TIP
* PARAM     Display all parameters:                 BIN, BIR, BIS, BISF, BISFA, BPN, BPR, BPS, BXR, BMR
* PRODIO    Display of prod act coef:               EAS, ECR
* CONST     Display constraints on crop production: CONST
* UTCOST    Display of unit transportation costs:   CT, DT, UT
* DATA      Display manure, nutrients and more:     MANURE, NSUB, NUTRIENT, POP, DPTR, DPTC, MS
* PRODUCTS  Display product summaries
* PPRICES   Display product price summaries
* INPUTS    Display input summaries
* IPRICES   Display input price summaries
* PRODACT   Display production activity summaries
* VARS      Display results for all variables
* EQNS      Display results for all equations