$ontext
    scenario file for sasm

$offtext

* --- This file is included in the main sasm file and contains settings for the scenario to be run. 
* It is read in at the beginning of the main file, before any calculations are done. 
* This allows you to easily change settings for different scenarios without having to edit the main file.

* --- Define which folder to store results in
$setGlobal resultFolder output

* --- Give results a name
$setGlobal scenarioName baseline

* --- Output control set OC ---
* OC controls which result blocks are written to the output
* Toggle items by commenting/uncommenting the yes lines below.
  OC('DSETS')    =  yes;    * Display of dynamic sets
  OC('PARAM')    =  no;     * Display all parameters
  OC('PRODIO')   =  no;     * Display of prod act coef
  OC('CONST')    =  no;     * Display constraints on crop production
  OC('UTCOST')   =  no;     * Display of unit trans costs
  OC('DATA')     =  no;     * Display manure, nutrients and more
  OC('PRODUCTS') =  yes;    * Display product summaries
  OC('PPRICES')  =  yes;    * Display product price summaries
  OC('INPUTS')   =  yes;    * Display input summaries
  OC('IPRICES')  =  yes;    * Display input price summaries
  OC('PRODACT')  =  yes;    * Display production activity summaries
  OC('VARS')     =  yes;    * Display results for all variables
  OC('EQNS')     =  no;     * Display results for all equation


* --- Define time horizons and scalars
* Choose simulation year
YEAR = 2025; 

* Time parameters defined in main model code:
* YR  = Number of years from base year 2025; YEAR - 0
* YRA = Number of years from base year for acreages, 2022; YEAR - 2022
* YRT = Number of years from base year for technical coefficients, 2020; YEAR - 2020

LONGRUN  =    no;       * no for short run analysis. Base year for acreage och buildings is 2021
LONGRUN1 =    yes;      * ?
LONGRUN2 =    yes;      * no for analysis without productivity development
CO2IMP   =    no;       * no for analysis without climate effects of imported inputs and products

KURS = 11.2;    * Exchange rate SEK per EUR

KPI =  1.267;   * Changed consumer price index from base year
KPI2 = 1.034;   * Changed consumer price index from 2023
KPI3 = 1.248;   * Changed all prices from base year to monetary value 2024

RED =  1.00;    * Reduction factor in trade and transport
