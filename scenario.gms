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
* LONGRUN  = no for short run analysis. Base year for acreage och buildings is 2021
* LONGRUN1 = no for ?
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