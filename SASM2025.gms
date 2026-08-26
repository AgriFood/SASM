$title SASM 2025, 2025 based on Outlook 2024, Bas 2025.
$offSymXRef
$offSymList
$onText

SASM is a Swedish agricultural sector model designed for analysing the economic impacts of
changes in technology, markets and policy. The model includes farm production activities and
processing activities which use regional and subregional inputs and produce regional and subregional products. Production and processing activities capture implicit
derived demand and supply functions. Exogenous input supply functions and/or fixed input
endowments may be introduced. Domestic product demand is described by exogenous demand functions
and/or fixed demands. Regional products may be transported between regions and international
trade activities are included. The general structure of the model is such that it may be adapted
for the analysis of a wide range of problems and may be adapted for use in studying other
economies. 

Version 2021 of SASM has 2021 as the base year. 

The original model is documented in "Conceptual Foundations and Structure of SASM: a Swedish Agricultural
Sector Model" by Jeffrey Apland and Lars Jonasson, department of Economics, Swedish University of
Agricultural Sciences, Uppsala, Sweden. The documentation includes the original dairy version of the
model as an example. That version was constructed by Jeffrey Apland and Lars Jonasson.
 
Tables and formulas without row number or with a * direcly after the row number are not activated
in the calculation. SASM is prepared for something that is not used at the moment.

Output Control:  Set OC controls contents of the output file from GAMS, *.lst.  The execution of
sets of display statements and the inclusion of other output items depends on the assignment of
the associated element to OC.

$offText

*============================================================
* Project Style Guide (GAMS)
* ============================================================
* Purpose:
* - Keep the project readable and maintainable for long-term use
*   by researchers and public agencies.
*
* Folder responsibilities:
* - Model/ : model declarations, equations, model definition, solve
* - Data/  : input data in GDX (no model logic)
* - Report/: output formatting, presentation, exports (no solve)
*
* Naming and casing:
* - Use CamelCase for GAMS keywords: Set, Parameter, Scalar, Variable, Equation, Model, Solve, Option.
* - Use lowerCamelCase for symbol names (recommended), e.g., exchangeRate, transportCost, demand.
* - Use UPPERCASE for Output Control Items (OCI) to emphasize their role as switches.
* - Use consistent naming across Excel/GDX and GAMS (symbol names must match).
*
* Recommended prefixes (lightweight):
* - Variables start with v... (e.g., vProduction, vFlow, vObj)
* - Equations start with e... (e.g., eObj, eCapacity, eBalance)
* - Models start with m... (e.g., mMain)
* (Sets/parameters/scalars may be unprefixed; prefer descriptive names.)
*
* Descriptions:
* - Provide an English description string for every declared symbol.
*
* Declarations layout:
* - Group declarations in this order:
*   SETS / ALIASES / SCALARS / PARAMETERS / TABLES / VARIABLES / EQUATIONS
* - Prefer one symbol per line when lists become long.
*
* Formatting:
* - Use consistent indentation (2 or 4 spaces) and line breaks for readability.
* - Break long expressions across multiple lines.
*
* Comments:
* - Comments must be in English.
* - Explain "why" rather than "what" when possible.
*
* Data loading (GDX):
* - Keep $gdxin/$load in a dedicated block near the top (after declarations).
* - Load base data first, then scenario overrides (if used).
*
* Scenarios:
* - Scenario assumptions belong in scenario GDX files (e.g., baseline.gdx).
* - Avoid scenario-specific code branches scattered throughout the model.
*
* Reporting:
* - Reporting must not change the model; it may only read solution values (.l, .m).
* - Do not place Solve statements in Report/ files.
* ============================================================



*============================================================
* Code Structure
* ============================================================
* 0) Run options
*
* 1) DECLARATIONS: SETS
** 1.1 Output control set OC
** 1.2 Overview of sets
** 1.3 Sets
*** R Regions
*** IP Inputs and products
*** AS Crop and livestock production activities
*** CR Processing activities regional
*** Other sets
*
* 2) DECLARATIONS: PARAMETERS / SCALARS
** 2.1 Overview of SASM data
** 2.2 Declaration of parameters
** 2.3 Declaration of symbols for scenario settings
*
* 3) DECLARATIONS: VARIABLES
*
* 4) DECLARATIONS: EQUATIONS
*
* 5) DEFINITIONS: SET DEFAULTS (optional)
*
* 6) DEFINITION: PARAMETERS
** 6.1 Define time horizons and scalars
** 6.2 Load data: ../Data/data.gdx
** 6.3 Calculations of parameters
** 6.3b Calibration adjustments
** 6.4 Supply and demand functions
** 6.5 Variable bounds & initial levels
*
* 7) DEFINITIONS: EQUATIONS
* 
* 8) MODEL + SOLVE
* 
* ============================================================


* ------------------------
* 0) Run options
* ------------------------
options LimRow=0, LimCol=0, SolPrint=OFF, IterLim=2000000, ResLim=900000;
*OPTION LIMROW=0, LIMCOL=0, SOLPRINT=OFF, ITERLIM=1000, RESLIM=900000;

*======================================================================


* ------------------------
* 1) DECLARATIONS: SETS
* ------------------------

** 1.1 Output control set
*  Output control items used to switch reporting blocks on/off.
*  Switch on/off in the settings file.

Set OCI  "Output control items"
 /
* --- Results: written to results Excel file ---
  PRODUCTS       "Product summaries (national)"
  INPUTS         "Input summaries (national)"
  ACTIVITIES     "Production activity summaries (national)"
  PRICES         "Product prices, input prices, and land rent"
  PAYMENTS       "Agricultural support payments"
  TRADE          "Import, export, and inter-regional shipments"
  ECONOMY        "Economic aggregates: producer surplus, profitability"
  NATIONAL       "Results at national level"
  UPR_SUMMARY    "Results by output region"
  REGIONAL       "Results at R level"
  SUBREGIONAL    "Results at SR level"
  DUAL           "Shadow prices of subregional input balance constraints"
* --- Diagnostics: written to lst file or control file ---
  VARS           "All solution variables"
  EQNS           "All equation slacks and marginals"
  DSETS          "Dynamic sets"
  PARAM          "All parameters"
  PRODIO         "Production activity coefficients"
  CONST          "Crop production constraints"
  UTCOST         "Unit transportation costs"
  DATA           "Manure, nutrients and more"
 /;

Set OC(OCI) "Output control set";
  OC(OCI) = no;


$sTitle SET DECLARATIONS AND ASSIGNMENTS

** 1.2 Overview of sets
*---------------------------------------------------------------------------------------------------
*Set..............  Description....................................................................
*---------------------------------------------------------------------------------------------------
*TIME               Simulation years
* 
*R                  Regions (markets)
*RS                 Source regions, alias R
*RD                 Destination regions, alias R
*SR                 Subregions for production
*RSR(R,SR)          Subregions mapped to regions **
*PR                 Production regions for production data
*PRSR(PR,SR)        Subregions mapped to production regions **
*
*IP                 Inputs and products
*
*I(IP)              Inputs
*IN(I)              National inputs
*IR(I)              Regional inputs
*RIR(R,IR)          Regional inputs mapped to regions **
*IS(I)              Subregional inputs
*RSRIS(R,SR,IS)     Subregional inputs mapped to regions and subregions **
*
*P(IP)              Products
*PN(P)              National products
*PR(P)              Regional products
*PS(P)              Subregional products
*RSRPS(R,SR,PS)     Subregional products mapped to regions and subregions **
*RPR(R,PR)          Regional products mapped to regions **
*PEX(P)             Exported products
*PIM(P)             Imported products
*PREX(PR)           Exported regional products **
*PRIM(PR)           Imported regional products **
*
*RPREX(R,PR)        Exported regional products mapped to regions **
*RPRIM(R,PR)        Imported regional products mapped to regions **
*
*AS                 Crop and livestock production activities, subregional 
*RSRAS(R,SR,AS)     Crop and livestock production activities mapped to regions and subregions **
*
*CR                 Processing activities, regional 
*RCR(R,CR)          Processing activities mapped to regions **
*
*T(RS,RD)           Transportation patterns **
*TIP(RS,RD,IP)      Regional inputs and products mapped to shipping patterns RS to RD **
*
*SDP                Supply and demand parameters
*
*INES(IN)           Elastic supply national inputs **
*INFS(IN)           Fixed supply national inputs **
*IRES(R,IR)         Elastic supply regional inputs mapped to regions **
*IRFS(R,IR)         Fixed supply regional inputs mapped to regions **
*ISES(R,SR,IS)      Elastic supply subregional inputs mapped to regions and subregions **
*ISFS(R,SR,IS)      Fixed supply subregional inputs mapped to regions and subregions **
*
*PNED(PN)           Elastic demand national products **
*PNFD(PN)           Fixed demand national products **
*PRED(R,PR)         Elastic demand regional products mapped to regions **
*PRFD(R,PR)         Fixed demand regional products mapped to regions **
*PSED(R,SR,PS)      Elastic demand subregional products mapped to regions and subregions **
*PSFD(R,SR,PS)      Fixed demand subregional products mapped to regions and subregions **
*
*TRD                Trade parameters;
*---------------------------------------------------------------------------------------------------
** This set is dynamic in that its elements are assigned. Such assignments are based on the
*   elements of other sets or the values of certain parameters. Once membership has been assigned,
*   it is useful to exclude elements from certain sets in order to manage model size. For example,
*   all regional inputs are assigned to all regions. However, if some inputs are not used in some
*   regions, the number of constraints may be reduced by excluding the inputs from those regions.
*   Elements should be removed from the following sets when it is appropriate to do so: RIR, RPR,
*   RPREX, RPRIM, RAR, RCR, T.

** 1.3 Sets


*** TIME Simulation years

Set TIME "Simulation years" / 2025*2055 /;


*** R Region sets

Set R "Regions (markets)"
/ R1 "North: AC-BD"
  R2 "Middle: W-X-Y-Z"
  R3 "Stockholm: AB-C-D-E-T-U"
  R4 "Gothenburg: O-S"
  R5 "Smaland: F-G-H-I-K-N"
  R6 "Skane: L-M" /;
  
Alias (R, RS);
Alias (R, RD);

* --- Region subsets (ranges) ---
Set
  R1to2(R) "Regions R1 to R2" / R1*R2 /
  R3to6(R) "Regions R3 to R6" / R3*R6 /;

* --- Subregions (production level) ---
Set SR "Subregions for production"
/ SR001* SR081 /;
** Production regions are chosen to match municipal and support areas.

* --- Subregions by Region ---
Set
  RSR1(SR)    "Subregions in R1"   / SR001,SR003,SR006,SR009 /
  RSR2(SR)    "Subregions in R2"   / SR002,SR004,SR005,SR007,SR008,SR010,SR012,SR014,SR016,SR024 /
  RSR3(SR)    "Subregions in R3"   / SR017,SR019,SR022,SR025,SR027,SR030,SR033,SR035,SR039,SR043,SR045,SR049,
                                   SR051,SR054,SR058,SR061,SR064,SR068*SR070,SR074,SR076 /
  RSR4(SR)    "Subregions in R4"   / SR011,SR013,SR015,SR018,SR020,SR023,SR026,SR028,SR031,SR032,SR034,SR036,
                                   SR040,SR041,SR044,SR046,SR050,SR052,SR055,SR059,SR062,SR065,SR071,SR075,SR077 /
  RSR5(SR)    "Subregions in R5"   / SR021,SR029,SR037,SR042,SR047,SR053,SR056,SR060,SR063,SR066,SR072,SR078,SR080 /
  RSR6(SR)    "Subregions in R6"   / SR038,SR048,SR057,SR067,SR073,SR079,SR081 /;

* --- Mapping set of subregions used by the model ---
Set RSR(R,SR) "Subregions mapped to regions";
RSR(R,SR) = no;

RSR('R1',RSR1) = yes;
RSR('R2',RSR2) = yes;
RSR('R3',RSR3) = yes;
RSR('R4',RSR4) = yes;
RSR('R5',RSR5) = yes;
RSR('R6',RSR6) = yes;

* --- Map subregions to CAP support areas ---
Set SA "Support areas, all" / SA01,SA02,SA03,SA04,SA04a,SA04b,SA05,SA06,SA06a,SA06b,SA07,SA07a,SA07b,SA08,SA09,SA10,SA11,SA12,SA13,
                     SA13ssk,SA13gsk,SA13ss,SA13gns,SA13gmb,SA13gss,SA13m,SA13s /;

Set SASR(SA,SR) "Map SA to subregions" /
  SA01.(SR001*SR002)
  SA02.(SR003*SR005)
  SA03.(SR006*SR008)
  SA04.(SR009*SR011)
  SA05.(SR012*SR015)
  SA06.(SR016*SR023)
  SA07.(SR024*SR032)
  SA08.(SR033*SR042)
  SA09.(SR043*SR053)
  SA10.(SR054*SR060)
  SA11.(SR061*SR067)
  SA12.SR068
  SA13.(SR069*SR081)
  SA04a.SR009
  SA04b.(SR010*SR011)
  SA06a.(SR016*SR020,SR022*SR023)
  SA06b.SR021
  SA07a.(SR024*SR028,SR030*SR032)
  SA07b.SR029
  SA13ssk.SR069
  SA13gsk.(SR070*SR073)
  SA13ss.(SR074*SR075)
  SA13gns.(SR076*SR077)
  SA13gmb.(SR078*SR079)
  SA13gss.(SR080*SR081)
  SA13m.(SR069,SR074*SR077)
  SA13s.(SR070*SR073,SR078*SR081) /;
  
Set SA_prod(SA) "Unique SA->SR map for PRODCOEF" / SA01,SA02,SA03,SA04a,SA04b,SA05,SA06a,SA06b,SA07a,SA07b,SA08,SA09,SA10,SA11,SA12,SA13ssk,SA13gsk,SA13ss,SA13gns,SA13gmb,SA13gss /;

Set SA_prod_ANC(SA) "Support areas for PRODCOEF, excluding SA13" / SA01,SA02,SA03,SA04a,SA04b,SA05,SA06a,SA06b,SA07a,SA07b,SA08,SA09,SA10,SA11,SA12 /;

Set SA_prod_13(SA) "Support areas for SA13" / SA13ssk,SA13gsk,SA13ss,SA13gns,SA13gmb,SA13gss /;

Set SASR_prod(SA,SR);
* For SASR_prod, assign 1 to SA-SR pairs that are in SASR, if they are also in SA_Prod:
* SASR_prod(SA,SR) is 1 for those SA–SR pairs that exist in SASR(SA,SR) and whose SA is contained in SA_prod:
SASR_prod(SA,SR) = SASR(SA,SR) $  SA_prod(SA);


* --- Map subregions to production areas PO8 ---
Set PO "Production regions PO8" /NOO,NN,SSK,GSK,SS,GNS,GMB,GSS/;

Set POSR(PO,SR) "Map PO to subregions" /
  NOO.(SR001*SR004,SR006*SR007,SR009)
  NN.(SR005,SR008,SR010*SR013)
  SSK.(SR014*SR018,SR024*SR026,SR033*SR034,SR043*SR044,SR061,SR069)
  GSK.(SR019*SR021,SR027*SR029,SR035*SR038,SR045*SR048,SR054*SR057,SR062*SR063,SR070*SR073)
  SS.(SR022,SR030*SR031,SR039*SR040,SR049*SR050,SR058,SR064,SR068,SR074*SR075)
  GNS.(SR023,SR032,SR041,SR051,SR052,SR059,SR065,SR076*SR077)
  GMB.(SR042,SR053,SR060,SR066,SR078*SR079)
  GSS.(SR067,SR080*SR081) /;

* --- Output regions mapped to subregions ---
Set UPR "Output regions"    / UPR01*UPR08 /;

Set UPRSR(UPR,SR) "Production regions mapped to subregions";
UPRSR(UPR,SR) = no;
  
  UPRSR('UPR01',SR) $ POSR('GSS',SR) = yes;
  UPRSR('UPR02',SR) $ POSR('GMB',SR) = yes;
  UPRSR('UPR03',SR) $ POSR('GNS',SR) = yes;
  UPRSR('UPR04',SR) $ POSR('SS',SR)  = yes;
  UPRSR('UPR05',SR) $ POSR('GSK',SR) = yes;
  UPRSR('UPR06',SR) $ POSR('SSK',SR) = yes;
  UPRSR('UPR07',SR) $ POSR('NN',SR)  = yes;
  UPRSR('UPR08',SR) $ POSR('NOO',SR) = yes;
$ONTEXT
  UPRSR('UPR01',SR) $ SASR('SA01',SR)    = yes;
  UPRSR('UPR02',SR) $ SASR('SA02',SR)    = yes;
  UPRSR('UPR03',SR) $ SASR('SA03',SR)    = yes;
  UPRSR('UPR04',SR) $ SASR('SA04a',SR)   = yes;
  UPRSR('UPR04',SR) $ SASR('SA04b',SR)   = yes;
  UPRSR('UPR05',SR) $ SASR('SA05',SR)    = yes;
  UPRSR('UPR06',SR) $ SASR('SA06a',SR)   = yes;
  UPRSR('UPR06',SR) $ SASR('SA06b',SR)   = yes;
  UPRSR('UPR07',SR) $ SASR('SA07a',SR)   = yes;
  UPRSR('UPR07',SR) $ SASR('SA07b',SR)   = yes;
  UPRSR('UPR08',SR) $ SASR('SA08',SR)    = yes;
  UPRSR('UPR09',SR) $ SASR('SA09',SR)    = yes;
  UPRSR('UPR10',SR) $ SASR('SA10',SR)    = yes;
  UPRSR('UPR11',SR) $ SASR('SA11',SR)    = yes;
  UPRSR('UPR12',SR) $ SASR('SA12',SR)    = yes;
  UPRSR('UPR13',SR) $ SASR('SA13ss',SR)  = yes;
  UPRSR('UPR13',SR) $ SASR('SA13ssk',SR) = yes;
  UPRSR('UPR13',SR) $ SASR('SA13gns',SR) = yes;
  UPRSR('UPR14',SR) $ SASR('SA13gsk',SR) = yes;
  UPRSR('UPR14',SR) $ SASR('SA13gmb',SR) = yes;
  UPRSR('UPR14',SR) $ SASR('SA13gss',SR) = yes;
$OFFTEXT


* --- Other subregion groupings ---  
Set
  SA01TO04a(SR)  "Support areas SA01 TO SA04a"   / SR001*SR009 /
  SA01TO04b(SR)  "Support areas SA01 TO SA04b"   / SR001*SR011 /
  SA01TO05(SR)   "Support areas SA01 TO SA05"    / SR001*SR015 /
  SA01TO07a(SR)  "Support areas SA01 TO SA07a"   / SR001*SR028,SR030*SR032 /
  SA01TO07b(SR)  "Support areas SA01 TO SA07b"   / SR001*SR032 /
  SA01TO12(SR)   "Support areas SA01 TO SA12"    / SR001*SR068 /
  SA06TO12(SR)   "Support areas SA06 TO SA12"    / SR016*SR068 /
  LFAHIGH(SR)    "Support areas WHAT?"           / SR001*SR042,SR061*SR068 /
  SA9TO10(SR)    "Support areas SA09 TO SA10"    / SR043*SR060 /;


*** IP Inputs and products sets

Set IP "Inputs and products"

*---------------------------------------------------------------------------------------------------
* Item......     Description........................................................................
*---------------------------------------------------------------------------------------------------
* Fixed inputs -- land
* -- Cropland
 /CROPLAND           Arable land: 1000 ha

* -- Permanent pasture: base categories
  PRMPAST            Permanent pasture: 1000 ha
  PRMPASTT           Permanent pasture with top supported values: 1000 ha
  PRMPASTN           Permanent pasture with Natura2000 support: 1000 ha
  PRMPASTH           Part of permanent pasture with high production: 1000 ha
  PRMPASTHT          Part of permanent pasture with high production and top supported values: 1000 ha
  PRMPASTHN          Part of permanent pasture with high production and Natura2000 support: 1000 ha

* -- Permanent pasture: special types
  PRMALV             Permanent pasture on Alvaret: 1000 ha
  PRMFOR             Permanent forest pasture: 1000 ha
  PRMMOS             Permanent pasture mosaik: 1000 ha
  PRMLOW             Permanent pasture low production (grasfattig): 1000 ha
  PRMCHAL            Permanent chalet pasture (fäbod): 1000 ha
  PRMMEAD            Permanent hay meadow (slåtteräng): 1000 ha

* -- Permanent pasture: upgradeable and potential
  PRMPASTUP          Part of permanent pasture that can be upgraded to top support: 1000 ha
  PRMPASTHUP         Part of permanent high productive pasture that can be upgraded: 1000 ha
  POTPAST            Potential permanent pasture: 1000 ha
  POTPASTT           Potential permanent pasture with high values: 1000 ha
  POTPASTN           Potential permanent pasture with top values: 1000 ha
  POTALV             Potential permanent pasture on Alvaret: 1000 ha
  POTFOR             Potential permanent forest pasture: 1000 ha
  POTMOS             Potential permanent pasture mosaik: 1000 ha
  POTLOW             Potential permanent pasture low production (gräsfattig): 1000 ha
  POTCHAL            Potential permanent chalet pasture (fäbod): 1000 ha
  POTMEAD            Potential permanent hay meadow (slåtteräng): 1000 ha

* -- Histosols (for emissions modelling)
  ORGCROPL           Histosol arable land: 1000 ha
  ORGPASTR           Histosol pasture: 1000 ha

* -- Acreage-based costs
  ACRCOST            Various cost for crop acreage: 1000 ha
  ACRCOSTP           Various cost for permanent pasture: 1000 ha
  ACRCOSTPB          Various cost for permanent pasture with basic support: 1000 ha (not used)
  ACRCOSTPT          Various cost for permanent pasture with top support: 1000 ha
  ACRCOSTPN          Various cost for permanent pasture with N2000 support: 1000 ha
  ACRCOSTPH          Various cost for permanent pasture with high production: 1000 ha
  ACRCOSTPHB         Various cost for permanent pasture high prod basic support: 1000 ha (not used)
  ACRCOSTPHT         Various cost for permanent pasture with high production and top support: 1000 ha
  ACRCOSTPHN         Various cost for permanent pasture with high production and N2000 supp: 1000 ha
  ACRCOSTALV         Various cost for pasture at Alvaret: 1000 ha
  ACRCOSTFOR         Various cost for pasture at forestpasture: 1000 ha
  ACRCOSTMOS         Various cost for pasture at mosaik land: 1000 ha
  ACRCOSTLOW         Various cost for pasture at low productive land: 1000 ha
  ACRCOSTCHA         Various cost for pasture at chalet land: 1000 ha
  ACRCOSTMEA         Various cost for hay meadow: 1000 ha
  ACRECO             Tillable organic crop land: 1000 ha
  ACRECON            Various cost convert to organic production: 1000 ha

* Fixed inputs -- processing and production capacity
* -- Processing capacity
  PCAPKMILK          Consumption milk processing capacity: 1000 ton
  PCAPCHEESE         Cheese processing capacity: 1000 ton
  PCAPBUTTER         Butter processing capacity: 1000 ton
  PCAPDRYMLK         Dry milk processing capacity: 1000 ton
  PCAPBEEF           Beef slaughtering capacity: 1000 ton
  PCAPPORK           Pork slaughtering capacity: 1000 ton
  PCAPPLTRY          Poultry slaughtering capacity: 1000 ton
  PCAPMILL           Milling processing capacity: 1000 ton
  PCAPFEED           Feed processing capacity: 1000 ton
  PCAPPOTS           Potato seed processing capacity: 1000 ton

* -- Production facilities
  DAIRYFAC           Dairy production facilities: 1000 cows
  DAIRYFACR          Dairy prod facilities remodelable: 1000 cows
  BULLFAC            Bull production facilities: 1000 bulls
  BULLFACR           Bull production facilities remodelable: 1000 bulls
  BEEFCFAC           Beef cattle production facilities: 1000 cows
  BEEFCFACR          Beef cattle production facilities remodelable: 1000 cows
  SOWFAC             Production facilities for sows: 1000 sow
  SOWFACR            Production facilities for sows remodelable: 1000 sow
  SWINEFAC           Production facilities for slaughter swine: 1000 hd
  SWINEFACR          Production facilities for slaughter swine remodelable: 1000 hd
  PLTRYFAC           Poultry production facilities: Mil hd
  PLTRYFACR          Poultry production facilities remodelable: Mil hd
  PLTRYCAP           Poultry production capacity: Mil hd
  CHICKFAC           Chicken production facilities: Mil hd
  CHICKFACR          Chicken production facilities remodelable: Mil hd
  CHICKCAP           Chicken production capacity: Mil hd
  HORSEFAC           Production facilities for horses: 1000 horses
  SHEEPFAC           Production facilities for sheep: 1000 ewes

* Variable inputs
* -- Labor and machinery
  CAPITAL            Operating capital costs: Mil SEK
  LABOR              Labor: Mil hours
  LABOR2             Additional labor cost livestock: Mil hours
  POWER              Use of tractors etc: Mil hours
  DIESEL             Diesel: 1000 m3

* -- Fertilizers: conventional
  NITROGEN           Nitrogen fertiliser: ton nitrogen
  PHOSPHORUS         Phosphorus fertiliser: ton phosphorus
  POTASSIUM          Potassium fertiliser: ton potassium

* -- Fertilizers: organic
  ECON               Nitrogen in organic rotation: ton nitrogen
  ECOP               Phosphorus in organic rotation: ton phosphorus
  ECOK               Potassium in organic rotation: ton potassium

* -- Pesticides
  PESTICIDES         Pesticide costs: Mil SEK
  HERBICIDES         Herbicides: ton active substance
  GLYFOSAT           Herbicides: ton active substance
  FUNGICIDES         Fungicides: ton active substance
  INSECTICID         Insecticides: ton active substance

* -- Feed inputs
  SOJA               Meal from soybean: 1000 ton
  BETFOR             Betfor: 1000 ton
  HPMASSA            HP-massa: 1000 ton ts
  PROTFEED           Protein feed: 1000 ton
  OTHERFEED          Other feed costs: Mil SEK

* -- Seeds
  GRAINSEED          Grain seed: 1000 ton
  OILGRSEED          Oilgrain seed: Mil units (1 unit = 10 kg)
  PEASSEED           Feed peas seed: Mil units (1 unit = 17.5 kg)
  POTATOSEED         Potatoes seed: 1000 ton
  SUGARBSEED         Sugar-beet seed: Mil units
  VEGETSEED          Seed for vegetables: 1000 ha

* -- Environmental emissions
  NLEAKAGE           Loss of nitrogen through soil: 1000 tons
  PLEAKAGE           Loss of phosphorus through soil: 1000 tons
  CO2                Loss of CO2 (carbon dioxide): 1000 tons
  CH4                Loss of CH4 (methane): 1000 tons
  N2O                Loss of N2O (laughing gas): 1000 tons
  CO2EQ              Loss of CO2 equivalents: 1000 tons
  NH3                Loss of NH3 (ammonia): 1000 tons
  CBONDING           Changed bonding of carbon in the soil: 1000 tons
  ENERGYUSE          Energy use: TWh

* -- Inconvenience costs
  INCONVPRO          Inconvenience of protein crops: 1000 ha
  INCONVCOV          Inconvenience of cover crops: 1000 ha
  INCONVCAT          Inconvenience of catch crops: 1000 ha
  INCONVLAT          Inconvenience of late or spring tillage: 1000 ha
  INCONVEPRO         Inconvenience of organic protein crops: 1000 ha
  INCONVECOV         Inconvenience of organic cover crops: 1000 ha
  INCONVECAT         Inconvenience of organic catch crops: 1000 ha
  INCONVELAT         Inconvenience of organic late or spring tillage: 1000 ha

* -- Other variable inputs
  PLASTIC            Plastic for bales of silage: 1000 rolls
  OTHRVARCST         Other variable costs: Mil SEK
  PCOST              Processing cost: Mil SEK
  YIELDRIRE1         Yield risk reduction for forage and pasture: 1000 ton
  YIELDRIRE2         Yield risk reduction for forage and pasture: 1000 ton
  YIELDRIRE3         Max yield risk reduction for forage and pasture: 1000 ton

* -- Calibration
  CALIBRATION        PMP calibration cost: Mil SEK


* Products
* -- Cereals
  BREADGRAIN         Bread grains (wheat rye): 1000 ton
  COARSGRAIN         Coarse grains (barley oats mixed): 1000 ton
  FLOUR              Flour from bread grains (wheat rye): 1000 ton
  FEEDGRAIN          Bread and coarse grains used for feed: 1000 ton
  ENERBGR            Breadgrains used for energy: 1000 ton
  ENERCGR            Coarse grains used for energy: 1000 ton
  GSILAGE            Grain silage: 1000 ton
  MSILAGE            Majs silage: 1000 ton

* -- Legumes and oilseeds
  PEAS               Feed peas harvested: 1000 ton
  FPEAS              Feed peas for feed: 1000 ton
  PPEAS              Processed feed peas: 1000 ton
  EPEAS              Organic feed peas: 1000 ton
  OILGRAIN           Oil grains (rape turnip. rape other): 1000 ton
  ENEROILG           Oil grains used for energy: 1000 ton
  RAPEOIL            Oil from rape seed: 1000 ton
  RAPEMEAL           Meal from extraction of oil: 1000 ton
  RAPSKAKA           Cake from cold processing of oil: 1000 ton

* -- Root crops and sugar
  POTATOES           Potatoes: 1000 ton
  SUGARBEET          Sugar-beet: 1000 ton
  WHITESUGAR         Processed white sugar: 1000 ton

* -- Forage and pasture
  SILAGE             Silage: 1000 ton ts
  SILAGEHQ           Silage with high quality: 1000 ton ts
  HAY                Hay for dairy cows: 1000 ton
  GRASSPASTR         Pasture grass: 1000 ton
  GRASSPASTF         Pasture grass from forage: 1000 ton
  ESILAGE            Organic silage and hay: 1000 ton
  ESILAGEHQ          Organic silage with high quality: 1000 ton
  EGRASSPAST         Organic pasture grass: 1000 ton
  EGRASSPASF         Organic pasture grass from forage: 1000 ton
  USEPASTR           Required use of pasture grass: 1000 ton

* -- Other crop products
  OTHRCROPPR         Other crop products: 1000 ha
  ICRPR              Industry crop products: 1000 ha
  SALIXMJ            Energy from Salix: 1000 MWh
  UNDEFUSE           Acreage with undefined use: 1000 ha

* -- Milk and dairy
  MILK               Farm milk: 1000 ton
  SKIMMILK           Skim milk: 1000 ton
  MILKFAT            Milk fat: 1000 ton
  KMILK              Consumption milk: 1000 ton
  CHEESE             Cheese: 1000 ton
  BUTTER             Butter: 1000 ton
  CREAM              Cream: 1000 ton
  DRYMILK            Dry skim milk: 1000 ton
  DRYMILK2           Dry full milk: 1000 ton

* -- Meat and eggs
  SLGHBEEF           Slaughter beef including culls and dairy: 1000 ton
  SLGHPORK           Slaughter hogs: 1000 ton
  SLGHPLTRY          Slaughter poultry: 1000 ton
  SLGHSHEEP          Slaughter sheep: 1000 ton
  EGG                Egg: 1000 ton
  RIDING             Horses for riding: 1000 hd
  BEEF               Beef: 1000 ton
  PORK               Pork: 1000 ton
  PLTRYMEAT          Poultry meat: 1000 ton
  WILDMEAT           Meat from game animals and reindeers: 1000 ton
  FISH               Fish and seafood: 1000 ton
  FRUIT              Fruit: 1000 ton
  VEGETAB            Vegetables: 1000 ton
  WBERRY             Wild berries for consumption: 1000 ton

* -- Livestock tracking
  DCALFM             Male dairy calves: 1000 hd
  DCALFF             Female dairy calves: 1000 hd
  DHEIFER            Female dairy heifers: 1000 hd
  PIGLETS            Piglets: 1000 hd
  GILTS              Gilts: 1000 hd
  EDCALFM            Organic male dairy calves: 1000 hd
  EDCALFF            Organic female dairy calves: 1000 hd
  EDHEIFER           Organic female dairy heifers: 1000 hd
  EPIGLETS           Organic piglets: 1000 hd
  EGILTS             Organic gilts: 1000 hd
  ECOMPMAN           Organic compressed manure
  MINSHEEP           Minimum number of sheep in solution: 1000 hd
  MINDCOW            Minimum number of dairy cows in solution: 1000 hd
  MINBCOW            Minimum number of beef cows in solution: 1000 hd
  MINLFOR            Min acreage of long laying forage: 1000 ha
  MINCACR            Minimal crop acreage: 1000 ha
  MINPAST            Min acreage of permanent pasture at subregional level: 1000 ha
  MINPASTN           Min acreage of permanent pasture at national level: 1000 ha

* -- Organic premiums
  EGRAIN             Organic bread grain additional value: 1000 ton
  ERAPE              Organic rape seed additional value: 1000 ton
  ESUGARB            Organic sugar beet additional value: 1000 ton
  EPOTATOES          Organic potatoes additional value: 1000 ton
  EMILK              Organic farm milk additional value: 1000 ton
  EBEEF              Organic beef additional value: 1000 ton
  EPORK              Organic pork additional value: 1000 ton
  ESHEEPM            Organic sheep meat additional value: 1000 ton
  EEGG               Organic egg additional value: 1000 ton
  MINKONVM           Minimum volume of conventional milk: 1000 ton

* -- Consumption tracking
  ENERGY             Energy in food: TeraJoule
  PROTEIN            Protein in food: 1000 ton
  PROTEINA           Protein with animal origin in food: 1000 ton
  FAT                Fat in food: 1000 ton
  CARBOH             Carbohydrates in food: 1000 ton
  BREADGRC           Bread grains (wheat rye) for consumption: 1000 ton
  COARSGRC           Coarse grains for consumption: 1000 ton
  FLOURC             Flour from bread grains for consumption: 1000 ton
  RAPEOILC           Oil from rape seed for consumption: 1000 ton
  POTATOESC          Potatoes for consumption: 1000 ton
  SUGARC             Sugar for consumption: 1000 ton
  OTHRCROPC          Other crop products for consumption: 1000 ha
  ICRPRC             Industry crop products for consumption: 1000 ha
  SHEEPC             Slaughter sheep for consumption: 1000 ton
  EGGC               Egg for consumption: 1000 ton
  KMILKC             Consumption milk for consumption: 1000 ton
  CHEESEC            Cheese for consumption: 1000 ton
  BUTTERC            Butter for consumption: 1000 ton
  CREAMC             Cream for consumption: 1000 ton
  DRYMILKC           Dry milk for consumption: 1000 ton
  BEEFC              Beef for consumption: 1000 ton
  PORKC              Pork for consumption: 1000 ton
  PLTRYMEATC         Poultry meat for consumption: 1000 ton
  WILDMEATC          Meat from game animals and reindeers for consumption: 1000 ton
  FISHC              Fish and seafood for consumption: 1000 ton
  VEGETABC           Vegetables for consumption: 1000 ton
  FRUITC             Fruit for consumption: 1000 ton
  WBERRYC            Wild berries for consumption: 1000 ton

* Policy variables
* -- Financial balances
  MISCCOST           Miscellaneous cost: Mil SEK
  DPTRANB            Dairy processing transfer balance: Mil SEK
  DPTRANR            Dairy processing transfer receipt: Mil SEK
  DPTRANC            Dairy processing transfer cost: Mil SEK
  MISCRCPT           Miscellaneous receipt
  LAYLAND            Land in set-aside program

* -- General subsidies
  ECOSUB             Subsidy for organic production: Mil SEK
  GACRSUB            General acreage subsidy: Mil SEK
  COMP4SUB           Compensation subsidy for grain etc: Mil SEK
  FORSUB             Acreage subsidy for forage: Mil SEK
  CATTLESUB          Livestock subsidy for cattle: Mil SEK
  SOWHLTSUB          Livestock subsidy for sow health: Mil SEK
  FARMSUB            Tax reduction on sales instead of on diesel: Mil SEK
  NATSUB             National support for less favoured areas: Mil SEK
  COMPSUB            Compensation subsidy base level: Mil SEK
  COMPSUBL           Compensation subsidy added per livestock unit: Mil SEK
  COMPSUBF           Acreage restriction on COMPSUPL: 1000 support units

* -- Eco-schemes
  ES1                Eco scheme 1 (protein): Mil SEK
  ES2                Eco scheme 2: Mil SEK
  ES3                Eco scheme 3 (precision): Mil SEK
  ES4                Eco scheme 4 (cover crop): Mil SEK
  ES5                Eco scheme 5 (catch crop): Mil SEK
  ES6                Eco scheme 6 (spring tilling): Mil SEK

* -- Biodiversity subsidies
  BIODIVSUBL         Land use possible for biodivsub: 1000 ha
  BIODIVSUBH         Land use with high production possible for biodivsub: 1000 ha
  BIODIVSUB          Subsidy for biological diversion at permanent pasture: Mil SEK
  BIODIVSUB2         High subsidy for biological diversion at permanent pasture: Mil SEK
  BIODIVSUB3         Subsidy for biological diversion at top value pasture: Mil SEK
  BIODIVSUBA         Subsidy for biological diversion at permanent pasture on Alvaret: Mil SEK
  BIODIVSUBF         Subsidy for biological diversion at permanent pasture in forest: Mil SEK
  BIODIVSUBM         Subsidy for biological diversion at permanent pasture on mosaik land: Mil SEK
  BIODIVSUBG         Subsidy for biological diversion at permanent pasture on low productive land: Mil SEK
  BIODIVSUBC         Subsidy for biological diversion at permanent chalet pasture: Mil SEK
  BIODIVSUBS         Subsidy for biological diversion at land with hay meadow: Mil SEK

* -- Other policy
  MINFOR             Minimal forage and pasture acreage for livestock subsidies
  SUGARQUOTA         Sugar quota: 1000 ha

* Restrictions on production
* -- Crop rotation: disease risk
  MAXWHEAT           Max 20 percent wheat due to diseases at high land quality
  MAXOILG            Max 20 percent oil grain due to diseases at high land quality
  MAXPEAS            Max 10 percent peas due to diseases at low land quality
  MAXPOTATO          Max 33 percent potatoes due to diseases at high land quality
  MAXPOTACR          Max potatoes related to acreage 1995
  MAXSUGAR           Max 25 percent sugar due to diseases at high land quality
  MAXEWHEAT          Max 20 percent organic wheat due to diseases at high land quality
  MAXEOILG           Max 20 percent organic oil grain due to diseases at high land quality
  MAXEPEAS           Max 10 percent organic peas due to diseases at low land quality
  MAXEPOTATO         Max 33 percent organic potatoes due to diseases at high land quality
  MAXESUGAR          Max 25 percent organic sugar due to diseases at high land quality

* -- Crop rotation: timing and machinery capacity
  MAXWWHEAT          Max acreage available in autumn at high land quality
  MAXWRAY            Max acreage available in autumn for rye
  MAXWOILG           Max acreage available in late summer at high land quality
  MAXCOVER           Max acreage available for cover crops
  MAXCATCH           Max acreage available for catch crops
  MAXLATE            Max acreage available for spring tilling
  MAXEWWHEAT         Max organic acreage available in autumn at high land quality
  MAXEWRAY           Max organic acreage available in autumn for rye
  MAXEWOILG          Max organic acreage available in late summer at high land quality
  MAXECOVER          Max organic acreage available for cover crops
  MAXECATCH          Max organic acreage available for catch crops
  MAXELATE           Max organic acreage available for spring tilling

* -- Forage, pasture and set-aside
  MINNEWFOR          Minimum acreage seeded with forage
  MAXFOR             Max share of forage as main crop: 100 percent
  MINGRAIN           Min share of grain as second crop: 100 percent
  MAXSALIX           Max acreage with salix: 1000 ha
  MINSALIX           Min acreage with salix: 1000 ha
  MINLAY             Min acreage with lay for acreage subsidies
  MAXLAY             Max acreage with lay for acreage subsidies
  MINSILAGE          Min silage that cannot be replaced by feed grain
  MAXCRTOPST         Max croparea converted to high productive pasture: 1000 ha
  MINENEWFOR         Minimum organic acreage seeded with forage
  MINELAY            Min acreage with lay for acreage subsidies (organic)
  MAXELAY            Max acreage with lay for acreage subsidies (organic)

* -- Livestock and manure
  ACRMANURE          Acreage needed for manure: 1000 ha
  MAXMANURE          Max use of conventional manure in organic production
  MAXECAT            Max number of organic beefcattle in relation to other: 1000 hd
  MEDCOW             Max number of organic dairycows: 1000 hd
  MEBEEFCATT         Max number of organic beefcattle: 1000 hd
  MESHEEP            Max number of organic ewes: 1000 hd
  MECOPIG            Max number of organic sows: 1000 hd
  MEPOULTRY          Max number of organic hens: mil hd
  MINEACR            Min acreage with organic production: 1000 ha
  LVSTKBAL1          Livestock balance for regional redistribution: 1000 ton
  LVSTKBAL2          Livestock balance for regional redistribution: 1000 ton

* -- External production limits
  MAXREIND           Max production from raindeers: 1000 ton
  MAXWILDM           Max production from game animals: 1000 ton
  MAXFISH            Max production from fish and seafood: 1000 ton
  MAXFRUIT           Max production of fruit: 1000 ton
  MAXVEGET           Max production of vegetables: 1000 ton
  MAXWBERRY          Max production of wild berries: 1000 ton/;
*---------------------------------------------------------------------------------------------------


Set FERT(IP)  Fertilizers
 /NITROGEN, PHOSPHORUS, POTASSIUM/;
 
Set FERT2(IP)  Fertilizers
 /NITROGEN, PHOSPHORUS, POTASSIUM, ECON, ECOP, ECOK/;

Set DCOWFEEDS(IP) /FEEDGRAIN, GSILAGE, MSILAGE, FPEAS, PPEAS, RAPEMEAL, RAPSKAKA, SILAGE, SILAGEHQ,
HAY, SOJA, BETFOR, HPMASSA, PROTFEED, OTHERFEED/;

Set I(IP)  Inputs
 /CROPLAND,
  PRMPAST, PRMPASTT, PRMPASTN, PRMPASTH, PRMPASTHT, PRMPASTHN,
  PRMALV, PRMFOR, PRMMOS, PRMLOW, PRMCHAL, PRMMEAD,
  PRMPASTUP, PRMPASTHUP,
  POTPAST, POTPASTT, POTPASTN, POTALV, POTFOR, POTMOS, POTLOW, POTCHAL, POTMEAD, ORGCROPL, ORGPASTR,
  ACRCOST, ACRCOSTP, ACRCOSTPB, ACRCOSTPT, ACRCOSTPN, ACRCOSTPH, ACRCOSTPHB, ACRCOSTPHT, ACRCOSTPHN,
  ACRCOSTALV, ACRCOSTFOR, ACRCOSTMOS, ACRCOSTLOW, ACRCOSTCHA, ACRCOSTMEA,  
  PCAPKMILK, PCAPCHEESE, PCAPBUTTER, PCAPDRYMLK, PCAPBEEF, PCAPPORK, PCAPPLTRY, PCAPMILL, PCAPFEED,
  PCAPPOTS, DAIRYFAC, DAIRYFACR, BEEFCFAC, BEEFCFACR, BULLFAC, 
  BULLFACR, SOWFAC, SOWFACR, SWINEFAC, SWINEFACR, PLTRYFAC, PLTRYFACR, PLTRYCAP, CHICKFAC, CHICKFACR, 
  CHICKCAP, HORSEFAC, SHEEPFAC, CAPITAL, LABOR, LABOR2, POWER, DIESEL, NITROGEN, PHOSPHORUS,
  POTASSIUM, PESTICIDES, HERBICIDES, GLYFOSAT, FUNGICIDES, INSECTICID, PLASTIC, OTHRVARCST, SOJA,
  BETFOR, HPMASSA, PROTFEED, OTHERFEED, ENERGYUSE, NLEAKAGE, PLEAKAGE,
  CO2, CH4, N2O, CO2EQ, NH3, YIELDRIRE1, YIELDRIRE2, YIELDRIRE3, PCOST, GRAINSEED, OILGRSEED,
  PEASSEED, POTATOSEED, SUGARBSEED, VEGETSEED, INCONVPRO, INCONVCOV, INCONVCAT, INCONVLAT,
  INCONVEPRO,  INCONVECOV, INCONVECAT, INCONVELAT, MISCCOST, DPTRANC, SUGARQUOTA, MINFOR, ACRMANURE, 
  ECON, ECOP, ECOK, ACRECO, ACRECON,
  CALIBRATION,
  MAXWHEAT, MAXWWHEAT, MAXWRAY, MAXOILG, MAXWOILG, MAXPEAS, MAXPOTATO, MAXPOTACR,
  MAXSUGAR, MINNEWFOR, MAXCOVER, MAXCATCH, MAXLATE, MAXFOR, MINGRAIN, MAXSALIX, MINLAY,
  MAXLAY, MAXEWHEAT, MAXEWWHEAT, MAXEWRAY, MAXEOILG, MAXEWOILG, MAXEPEAS, MAXEPOTATO, MAXESUGAR,
  MINENEWFOR, MAXECOVER, MAXECATCH, MAXELATE, MINELAY, MAXELAY, MAXMANURE, MINSILAGE, MAXCRTOPST,
  LVSTKBAL1, LVSTKBAL2, MAXECAT, MEDCOW, MEBEEFCATT, MESHEEP, MECOPIG, MEPOULTRY, MINEACR,
  MAXREIND, MAXWILDM, MAXFISH, MAXFRUIT, MAXVEGET, MAXWBERRY/;
 
Set IN(I)  National inputs
 /CAPITAL, LABOR2, POWER, DIESEL, PESTICIDES, HERBICIDES, GLYFOSAT, FUNGICIDES, INSECTICID,
  PLASTIC, OTHRVARCST, OTHERFEED, CO2, CH4, N2O, CO2EQ, NH3, YIELDRIRE1, YIELDRIRE2, YIELDRIRE3,
  PCOST, MISCCOST, DPTRANC, CALIBRATION/;

Set IR(I)  Regional inputs
 /PCAPKMILK, PCAPCHEESE, PCAPBUTTER, PCAPDRYMLK, PCAPBEEF, PCAPPORK, PCAPPLTRY, PCAPMILL, PCAPFEED,
  PCAPPOTS, LABOR, NITROGEN, PHOSPHORUS, POTASSIUM, SOJA,
  BETFOR, HPMASSA, PROTFEED, GRAINSEED, OILGRSEED, PEASSEED, POTATOSEED, SUGARBSEED, VEGETSEED,
  INCONVCOV, INCONVCAT, INCONVLAT, INCONVECOV, INCONVECAT, INCONVELAT,
  LVSTKBAL1, LVSTKBAL2, MEDCOW, MEBEEFCATT, MESHEEP, MECOPIG, MEPOULTRY, MINEACR,
  MAXREIND, MAXWILDM, MAXFISH, MAXFRUIT, MAXVEGET, MAXWBERRY/;

Set VARI(I)  Variable inputs
 /LABOR, LABOR2, POWER, DIESEL, NITROGEN, PHOSPHORUS, POTASSIUM, PESTICIDES, HERBICIDES, GLYFOSAT,
  FUNGICIDES, INSECTICID, PLASTIC, SOJA, BETFOR, HPMASSA, PROTFEED, GRAINSEED, OILGRSEED,
  PEASSEED, POTATOSEED, SUGARBSEED, VEGETSEED,
  INCONVPRO, INCONVCOV, INCONVCAT, INCONVLAT,INCONVEPRO,  INCONVECOV, INCONVECAT, INCONVELAT/;

Set emissions(I)
 /CO2, CH4, N2O, NH3, NLEAKAGE, PLEAKAGE/;
 
Set RIR(R,IR)  Regional inputs mapped to regions;
* Map all regional inputs to all regions, then exclude specific combinations which are not needed
  RIR(R,IR) = yes;
  RIR('R1','INCONVCOV')  = no;
  RIR('R1','INCONVCAT')  = no;
  RIR('R1','INCONVLAT')  = no;
  RIR('R1','INCONVECOV') = no;
  RIR('R1','INCONVECAT') = no;
  RIR('R1','INCONVELAT') = no;
*  RIR('R2','INCONVCOV')  = no;
  RIR('R2','INCONVCAT')  = no;
  RIR('R2','INCONVLAT')  = no;
*  RIR('R2','INCONVECOV') = no;
  RIR('R2','INCONVECAT') = no;
  RIR('R2','INCONVELAT') = no;

Set IS(I)  Subregional inputs
  /CROPLAND,
   PRMPAST, PRMPASTT, PRMPASTN, PRMPASTH, PRMPASTHT, PRMPASTHN,
   PRMALV, PRMFOR, PRMMOS, PRMLOW, PRMCHAL, PRMMEAD,
   PRMPASTUP, PRMPASTHUP, POTPAST, POTPASTT, POTPASTN, POTALV, POTFOR, POTMOS, POTLOW, POTCHAL, POTMEAD,
   ORGCROPL, ORGPASTR, ACRCOST, ACRCOSTP, ACRCOSTPB, ACRCOSTPT, ACRCOSTPN, ACRCOSTPH, ACRCOSTPHB, ACRCOSTPHT,
   ACRCOSTPHN, ACRCOSTALV, ACRCOSTFOR, ACRCOSTMOS, ACRCOSTLOW, ACRCOSTCHA, ACRCOSTMEA, 
   DAIRYFAC, DAIRYFACR, BEEFCFAC, BEEFCFACR, BULLFAC, BULLFACR, SOWFAC, SOWFACR, SWINEFAC,
   SWINEFACR, PLTRYFAC, PLTRYFACR, PLTRYCAP, CHICKFAC, CHICKFACR, CHICKCAP, HORSEFAC, SHEEPFAC,
   INCONVPRO, INCONVEPRO, ECON, ECOP, ECOK, ACRECO, ACRECON, ENERGYUSE, NLEAKAGE, PLEAKAGE, 
   SUGARQUOTA, MINFOR, ACRMANURE, MAXWHEAT, MAXWWHEAT,
   MAXWRAY, MAXOILG, MAXWOILG, MAXPEAS, MAXPOTATO, MAXPOTACR, MAXSUGAR, MINNEWFOR, MAXCOVER,
   MAXCATCH, MAXLATE, MAXFOR, MINGRAIN, MAXSALIX, MINLAY, MAXLAY, 
   MAXEWHEAT, MAXEWWHEAT, MAXEWRAY, MAXEOILG, MAXEWOILG, MAXEPEAS, MAXEPOTATO, MAXESUGAR,
   MINENEWFOR, MAXECOVER, MAXECATCH, MAXELATE, MINELAY, MAXELAY, 
   MAXMANURE, MINSILAGE, MAXCRTOPST, MAXECAT/;
   
Set LAND(IS) "Inputs in BISFA measured in 1,000 hectares"
  /CROPLAND, PRMPAST, PRMPASTT, PRMPASTN, PRMPASTH, PRMPASTHT, PRMPASTHN,
   PRMALV, PRMFOR, PRMMOS, PRMLOW, PRMCHAL, PRMMEAD, PRMPASTUP,
   POTPAST, POTPASTT, POTPASTN, POTALV, POTFOR, POTMOS, POTLOW, POTCHAL, POTMEAD /;
 
Set FIXIS(IS)  Fixed subregional inputs
  /DAIRYFAC, BEEFCFAC, BULLFAC, SOWFAC, SWINEFAC, PLTRYFAC, CHICKFAC, SHEEPFAC, 
   SUGARQUOTA, MAXPOTACR, MAXSALIX/;
   
Set FIXIS2(IS)  Partly fixed subregional inputs object for investments
  /DAIRYFACR, BEEFCFACR, BULLFACR, SOWFACR, SWINEFACR, PLTRYFACR, CHICKFACR/;

Set PRODRES(IS) Technical biological and policy restrictions on production
  /ACRMANURE, MAXWHEAT, MAXWWHEAT, MAXWRAY, MAXOILG, MAXWOILG, 
   MAXPEAS, MAXPOTATO, MAXPOTACR, MAXSUGAR, MINNEWFOR, MAXCOVER, MAXCATCH, MAXLATE, MAXFOR,
   MINGRAIN, MINLAY, MAXLAY,  
   MAXEWHEAT, MAXEWWHEAT, MAXEWRAY, MAXEOILG, MAXEWOILG, MAXEPEAS, MAXEPOTATO, MAXESUGAR,
   MINENEWFOR, MAXECOVER, MAXECATCH, MAXELATE, MINELAY, MAXELAY, 
   MAXSALIX, MAXMANURE, MINSILAGE, MAXECAT/;

Set RSRIS(R,SR,IS)  "Subregional inputs mapped to regions and subregions";
* Map all subregional inputs to all region/subregion combinations, then exclude specific
* combinations which are not needed
  RSRIS(R,SR,IS)$(RSR(R,SR)) = yes;
  
  RSRIS(R,SA01TO12 ,'MAXCATCH') = no;
  RSRIS(R,SA01TO12,'MAXLATE')  = no;
  RSRIS(R,SA01TO12,'MAXECATCH')= no;
  RSRIS(R,SA01TO12,'MAXELATE') = no;
 
Set P(IP)  Products
 /BREADGRAIN, COARSGRAIN, FLOUR, FEEDGRAIN, ENERBGR, ENERCGR, GSILAGE, MSILAGE, PEAS, FPEAS, PPEAS,
  OILGRAIN, ENEROILG, RAPEOIL, RAPEMEAL, RAPSKAKA, POTATOES, SUGARBEET, WHITESUGAR, SILAGE, SILAGEHQ,
  HAY, GRASSPASTR, GRASSPASTF, EPEAS, ESILAGE, ESILAGEHQ, EGRASSPAST, EGRASSPASF,
  USEPASTR, OTHRCROPPR, SALIXMJ, ICRPR, UNDEFUSE, MILK, DCALFM, DCALFF, DHEIFER, PIGLETS, GILTS,
  EDCALFM, EDCALFF, EDHEIFER, EPIGLETS, EGILTS, ECOMPMAN,
  SLGHBEEF, SLGHPORK, SLGHPLTRY, SLGHSHEEP, EGG, RIDING, MINSHEEP, MINDCOW, MINBCOW, MINLFOR,
  MINCACR, MINPAST, MINPASTN, SKIMMILK, MILKFAT, KMILK, CHEESE, BUTTER, CREAM, DRYMILK, DRYMILK2,
  BEEF, PORK, PLTRYMEAT, WILDMEAT, FISH, FRUIT, VEGETAB, WBERRY,
  EGRAIN, ERAPE, ESUGARB, EPOTATOES, EMILK, EBEEF, EPORK, ESHEEPM, EEGG, MINKONVM, ENERGY, PROTEIN,
  PROTEINA, FAT, CARBOH, BREADGRC, COARSGRC, FLOURC, RAPEOILC, POTATOESC, SUGARC, OTHRCROPC,
  ICRPRC, SHEEPC, EGGC, KMILKC, CHEESEC, BUTTERC, CREAMC, DRYMILKC, BEEFC, PORKC, PLTRYMEATC,
  WILDMEATC, FISHC, FRUITC, VEGETABC, WBERRYC, CBONDING, MISCRCPT,
  LAYLAND, ECOSUB, GACRSUB, COMP4SUB, FORSUB, CATTLESUB, SOWHLTSUB,
  ES1*ES6, NATSUB, COMPSUB, COMPSUBL, COMPSUBF, 
  BIODIVSUBL, BIODIVSUBH, BIODIVSUB, BIODIVSUB2, BIODIVSUB3, BIODIVSUBA, BIODIVSUBF, BIODIVSUBM,
  BIODIVSUBG, BIODIVSUBC, BIODIVSUBS, MINSALIX, DPTRANR/;
 
Set SUPPORT(P) Subsidies
 /ECOSUB, GACRSUB, FORSUB, CATTLESUB, SOWHLTSUB, ES1*ES6, NATSUB,
  COMP4SUB, COMPSUB, COMPSUBL, COMPSUBF, BIODIVSUB, BIODIVSUB2, BIODIVSUB3, BIODIVSUBA,
  BIODIVSUBF, BIODIVSUBM, BIODIVSUBG, BIODIVSUBC, BIODIVSUBS/;
  
Set FEEDP(P)  Products for feed
 /FEEDGRAIN, GSILAGE, MSILAGE, FPEAS, PPEAS, 
  EPEAS, ESILAGE, ESILAGEHQ, EGRASSPAST, EGRASSPASF, 
  RAPEMEAL, RAPSKAKA, SILAGE, SILAGEHQ, HAY, GRASSPASTR, GRASSPASTF, USEPASTR/;

Set PN(P)  National products
 /ENERBGR, ENERCGR, ENEROILG, MINPASTN, CBONDING, MISCRCPT, MINKONVM, ECOSUB, GACRSUB, FORSUB,
  CATTLESUB, SOWHLTSUB, ES1*ES6, NATSUB, BIODIVSUB, BIODIVSUB2, BIODIVSUB3, BIODIVSUBA,
  BIODIVSUBF, BIODIVSUBM, BIODIVSUBG, BIODIVSUBC, BIODIVSUBS, DPTRANR/;

Set SUPPORTN(PN) National subsidies
 /ECOSUB, GACRSUB, FORSUB, CATTLESUB, SOWHLTSUB, ES1*ES6, NATSUB,
  BIODIVSUB, BIODIVSUB2, BIODIVSUB3, BIODIVSUBA, BIODIVSUBF, BIODIVSUBM,
  BIODIVSUBG, BIODIVSUBC, BIODIVSUBS/;
 
Set PR(P)  Regional products
 /BREADGRAIN, COARSGRAIN, FLOUR, FEEDGRAIN, PEAS, FPEAS, PPEAS, OILGRAIN, RAPEOIL, RAPEMEAL,
  RAPSKAKA, POTATOES, SUGARBEET, WHITESUGAR, MILK,
  DCALFM, DCALFF, PIGLETS, ECOMPMAN, SLGHBEEF, SLGHPORK, SLGHPLTRY, SLGHSHEEP, EGG, RIDING,
  SKIMMILK, MILKFAT, KMILK, CHEESE, BUTTER, CREAM, DRYMILK, DRYMILK2, BEEF, PORK, PLTRYMEAT,
  WILDMEAT, FISH, FRUIT, VEGETAB, WBERRY,
  EPEAS, EGRAIN, ERAPE, ESUGARB, EPOTATOES, EMILK, EBEEF, EPORK, ESHEEPM, EEGG,
  ENERGY, PROTEIN, PROTEINA, FAT, CARBOH,BREADGRC, COARSGRC, FLOURC, RAPEOILC, POTATOESC,
  SUGARC, OTHRCROPC, ICRPRC, SHEEPC, EGGC, KMILKC, CHEESEC, BUTTERC, CREAMC, DRYMILKC,
  BEEFC, PORKC, PLTRYMEATC, WILDMEATC, FISHC, FRUITC, VEGETABC, WBERRYC, LAYLAND/;
  
Set FOODS(PR)  Regional food products
 /BREADGRC, COARSGRC, FLOURC, RAPEOILC, POTATOESC, SUGARC,
  OTHRCROPC, ICRPRC, SHEEPC, EGGC, KMILKC, CHEESEC, BUTTERC, CREAMC, DRYMILKC, BEEFC, PORKC,
  PLTRYMEATC, WILDMEATC, FISHC, FRUITC, VEGETABC, WBERRYC,
  EPEAS, EGRAIN, ERAPE, ESUGARB, EPOTATOES, EMILK, EBEEF, EPORK, ESHEEPM, EEGG/;
  
Set YD (IP) Yield dependent inputs and products
 /BREADGRAIN, COARSGRAIN, PEAS, OILGRAIN, POTATOES, SUGARBEET, SILAGE, SILAGEHQ, GRASSPASTR,
  CBONDING, NITROGEN, PHOSPHORUS, POTASSIUM, PLASTIC/;

Set YDF (IP) Yield dependent inputs and products in forage and pasture
 /SILAGE, SILAGEHQ, GRASSPASTR, GRASSPASTF, NITROGEN, PHOSPHORUS, POTASSIUM,
  LABOR, POWER, PLASTIC, OTHRVARCST, CAPITAL/;
  
Set ECOPROD(P) Organic products
 /EPEAS, EGRAIN, ERAPE, ESUGARB, EPOTATOES, EMILK, EBEEF, EPORK, ESHEEPM, EEGG,
  ESILAGE, ESILAGEHQ, EGRASSPAST, EGRASSPASF, EDCALFM, EDCALFF, EDHEIFER, EPIGLETS, EGILTS/;
  
Set NUTX "Nutrient columns in NUTRIENT" /ENERG, PROT, PROTA, FAT2, CARB/;

Set RPR(R,PR)  Regional products mapped to regions;
* Include all regional products in all regions, then identify excluded products by region
  RPR(R,PR) = yes;
  RPR('R1','OILGRAIN') = no;
  RPR('R2','OILGRAIN') = no;
  RPR('R1','ERAPE') = no;
  RPR('R2','ERAPE') = no;
  RPR('R3','ERAPE') = no;
  RPR('R1','SUGARBEET') = no;
  RPR('R2','SUGARBEET') = no;
*  RPR('R3','SUGARBEET') = no;
*  RPR('R4','SUGARBEET') = no;
 
Set PS(P) Subregional products
 /GSILAGE, MSILAGE, SILAGE, SILAGEHQ, HAY, GRASSPASTR, GRASSPASTF, USEPASTR, OTHRCROPPR, SALIXMJ,
  ICRPR, UNDEFUSE, DHEIFER, GILTS, MINSHEEP, MINLFOR, MINDCOW, MINBCOW, MINCACR, MINPAST,
  ESILAGE, ESILAGEHQ, EGRASSPAST, EGRASSPASF, EDCALFM, EDCALFF, EDHEIFER, EPIGLETS, EGILTS,
  COMP4SUB, COMPSUB, COMPSUBL, COMPSUBF, BIODIVSUBL, BIODIVSUBH, MINSALIX/;

Set SUPPORTS(PS) Subregional subsidies
 /COMP4SUB, COMPSUB, COMPSUBL, COMPSUBF/;
 
Set RSRPS(R,SR,PS)  Subregional products mapped to regions and subregions;
* Map all subregional products to all region/subregion combinations, then exclude specific

* combinations which are not needed
  RSRPS(R,SR,PS) $RSR(R,SR) = yes;
 
Set PEX(P)  Exported products
 /BREADGRAIN, COARSGRAIN, OILGRAIN, RAPEOIL, POTATOES, WHITESUGAR, CHEESE, BUTTER, DRYMILK, DRYMILK2,
  BEEF, PORK, PLTRYMEAT, SLGHSHEEP, EGG/;
 
Set PIM(P)  Imported products
 /BREADGRAIN, COARSGRAIN, PEAS, OILGRAIN, POTATOES, WHITESUGAR,
  CHEESE, BUTTER, DRYMILK, DRYMILK2, BEEF, PORK, PLTRYMEAT, SLGHSHEEP, EGG,
  WILDMEAT, FISH, FRUIT, VEGETAB, WBERRY, EGRAIN, EPEAS/;
 
Set PREX(PR)  Exported regional products;
  PREX(PR) = no;
  PREX(PR) = yes $PEX(PR);

Set RPREX(R,PR)  Exported regional products mapped to regions;
* Include all exported products which occur in each region, then identify excluded products
* by region
  RPREX(R,PR) = no;
  RPREX(R,PR) = RPR(R,PR) $PREX(PR);
* no EXPORTS FROM REGIONS 1 TO 3
  RPREX('R1',PR) = no;
  RPREX('R2',PR) = no;
  RPREX('R3',PR) = no;
 
Set PRIM(PR)  Imported regional products;
  PRIM(PR) = no;
  PRIM(PR) = yes $PIM(PR);
 
Set RPRIM(R,PR)  Imported regional products mapped to regions;

* Include all imported products which occur in each region, then identify excluded products
* by region
  RPRIM(R,PR) = no;
  RPRIM(R,PR) = RPR(R,PR) $PRIM(PR);

* no IMPORTS TO REGIONS 1 TO 3
  RPRIM('R1',PR) = no;
  RPRIM('R2',PR) = no;
  RPRIM('R3',PR) = no;


*** AS Crop and livestock production activities sets

Set AS  Crop and livestock production activities
*---------------------------------------------------------------------------------------------------
* Activity..             Description................................................................
*---------------------------------------------------------------------------------------------------
* Conventional crop production
 /W-WHEAT                Winter wheat: 1000 ha
  W-RAY                  Winter ray: 1000 ha
  W-BARLEY               Winter barley: 1000 ha
  BARLEY                 Barley: 1000 ha
  OATS                   Oats: 1000 ha
  GRAINSIL               Grain used as silage: 1000 ha
  MAJSSIL                Majs used as silage: 1000 ha
  FEEDPEAS               Peas used as feed: 1000 ha
  W-RAPE                 Winter rape seed: 1000 ha
  S-RAPE                 Spring rape seed: 1000 ha
  POTATO                 Potatoes: 1000 ha
  SUGAR                  Sugar-beets: 1000 ha
  FORAGE1                Intensive forage in three year rotation: 1000 ha
  FORAGE2                Intensive forage and pasture in three year rotation: 1000 ha
  FORAGE3                Forage in eight year rotation: 1000 ha
  FORAGE4                Extensive forage: 1000 ha
  PASTURE1               Pasture at crop land: 1000 ha
  PASTURE2               Pasture at crop land: 1000 ha
  NEWFOR                 New forage seeded separately: 1000 ha
  SALIX                  Salix: 1000 ha
  OTHERCROPS             Other crops: 1000 ha
  COVERCROP              Cover crop: 1000 ha
  CATCHCROP              Catch crop: 1000 ha
  SPRINGTILL             Tilling in spring: 1000 ha
  LAY                    Lay land in program: 1000 ha
  LONGLAY                Permanent lay land in program: 1000 ha
  ICR                    Industry crops: 1000 ha
  NOUSE                  Acreage with no known use: 1000 ha

* Conventional livestock production
  DCOW1*DCOW4            Dairy production: 1000 cows
  HEIFER                 Dairy heifers fed to cows (25 month): 1000 hd
  DAIRYBULL1             Dairy bulls fed for beef 18 month (ungtjur): 1000 hd
  DAIRYBULL2             Dairy steers fed for beef 25 month (stut): 1000 hd
  SLGHHEIFER             Heifers fed for beef (25 month): 1000 hd
  BEEFCATTLE             Beef cattle production: 1000 cows + 220 heifers + 660 bulls (ungdjur)
  BEEFCATTL2             Beef cattle production: 1000 cows + 220 heifers + 660 steer (stut)
  SHEEP                  Sheep production: 1000 ewes + 1600 lamb
  SHEEP2                 Sheep production: 1000 ewes without lamb
  SOW1                   Sows for production of piglets: 1000 sows + 40 boars
  GILT                   Gilt for sow production: 1000 hd
  SLGHSWINE1             Slaughter swine: 1000 hd
  POULTRY                Poultry production for egg: Mil hd
  CHICKEN                Poultry production for meat: Mil m2

* Organic crop production
  EW-WHEAT               Winter wheat: 1000 ha
  EW-RAY                 Winter ray: 1000 ha
  EBARLEY                Barley: 1000 ha
  EOATS                  Oats: 1000 ha
  EFEEDPEAS              Feedpeas: 1000 ha
  EW-RAPE                Winter rape seed: 1000 ha
  ES-RAPE                Spring rape seed: 1000 ha
  EPOTATO                Potatoes: 1000 ha
  ESUGAR                 Sugar-beets: 1000 ha
  EFORAGE1               Intensive forage in three year rotation: 1000 ha
  EFORAGE2               Intensive forage and pasture in three year rotation: 1000 ha
  EFORAGE3               Forage in eight year rotation: 1000 ha
  EFORAGE4               Extensive forage: 1000 ha
  EPASTURE1              Pasture at crop land: 1000 ha
  EPASTURE2              Pasture at crop land: 1000 ha
  ENEWFOR                New forage seeded separately: 1000 ha
  EOTHRCROPS             Other crops: 1000 ha
  ECOVERCROP             Cover crop: 1000 ha
  ECATCHCROP             Catch crop: 1000 ha
  ESPRINGTIL             Tilling in spring: 1000 ha
  ENFIX                  Nitrogen fixation: 1000 ha
  ELAY                   Lay land in program: 1000 ha

* Organic livestock production
  EDCOW1*EDCOW3          Dairy production: 1000 cows
  EHEIFER                Dairy heifers fed to cows (25 month): 1000 hd
  EDBULL1                Dairy bulls fed for beef 18 month (ungtjur): 1000 hd
  EDBULL2                Dairy steers fed for beef 25 month (stut): 1000 hd
  ESLGHHEIF              Heifers fed for beef (25 month): 1000 hd
  EBEEFCATT              Beef cattle production: 1000 cows + 200 heifers + 600 bulls
  EBEEFCAT2              Beef cattle production: 1000 cows + 200 heifers + 600 bullocks
  ESHEEP                 Sheep production: 1000 ewes + 1600 lamb
  ECOPIG                 Organic pigs: 1000 sows inkl slghswine
  EPOULTRY               Poultry production for meat: Mil hd

* Permanent pasture
  PPASTR                 Permanent pasture use: 1000 ha
  PPASTRT                Permanent top supported pasture use: 1000 ha
  PPASTRN                Permanent N2000 supported pasture use: 1000 ha
  PPASTRH                Permanent pasture with high production: 1000 ha
  PPASTRHT               Permanent top supported pasture with high production: 1000 ha
  PPASTRHN               Permanent N2000 supported pasture with high production: 1000 ha
  PPASTRALV              Permanent pasture on Alvaret: 1000 ha
  PPASTRFOR              Permanent forest pasture: 1000 ha
  PPASTRMOS              Permanent mosaic pasture: 1000 ha
  PPASTRLOW              Permanent pasture low production (gräsfattig): 1000 ha
  PPASTRCHAL             Permanent chalet pasture (fäbod): 1000 ha
  PPASTRMEAD             Permanent hay meadow (slåtterang): 1000 ha

* Risk reduction buffers
  SPAREFOR               Spare forage for risk reduction: 1000 ha
  SPARESIL               Spare silage for risk reduction: 1000 ton
  SPAPASTR               Spare pasture for risk reduction: 1000 ha
  SPAPASTRT              Spare top supported pasture for risk reduction: 1000 ha
  SPAPASTRH              Spare permanent pasture with high production: 1000 ha
  SPAPASTRHT             Spare top supported permanent pasture with high production: 1000 ha

* Building and capacity investments
  DAIRYFEXR              Dairy facilities remodeled: 1000 fac
  DAIRYFEXN              Dairy facilities expansion: 1000 fac
  BULLFEXR               Bull facilities remodeled: 1000 cows etc.
  BULLFEXN               Bull facilities expansion new: 1000 cows etc.
  BEEFCFEXR              Beef cattle facilities remodeled: 1000 cows etc.
  BEEFCFEXN              Beef cattle facilities expansion new: 1000 cows etc.
  SOWFEXR                Sow facilities remodeled: 1000 sow
  SOWFEXN                Sow facilities expansion new: 1000 sow
  SWINEFEXR              Swine facilities remodeled: 1000 hd
  SWINEFEXN              Swine facilities expansion new: 1000 hd
  PLTRYFEXR              Poultry facilities remodeled: Mil hd
  PLTRYFEXN              Poultry facilities expansion new: Mil hd
  CHICKFEXR              Chicken facilities remodeled: Mil hd
  CHICKFEXN              Chicken facilities expansion new: Mil hd

* Internal bookkeeping and conversion activities (not actual land use or production)
* -- Land balance
  FORHIGH                Forage on high quality land: 1000 ha
  EFORHIGH               Forage on high quality land (organic): 1000 ha
  USEHQLAND              Use high quality land: 1000 ha
  USEHQLANDE             Use high quality land (organic): 1000 ha
  USEORGCL               Use organic crop land: 1000 ha
  USEORGPL               Use organic pasture land: 1000 ha
  PPASTRB                Part of pasture with basic support: 1000 ha
  PPASTRHB               Part of high production pasture with basic support: 1000 ha
* -- Feed conversion and substitution
  MAKEHAY                Change from silage to hay with additional costs: 1000 ton ts
  FGFORSIL               Use feedgrain instead of silage: 1000 ton
  GSFORSIL               Use grain silage instead of silage: 1000 ton
  MSFORSIL               Use majs silage instead of silage: 1000 ton
* -- Manure transfer
  USEMANURE              Use conventional manure
  COMPMAN                Compress manure: 1000 ton
  COMPEMAN               Compress ecologic manure: 1000 ton
  UCOMPMAN               Use compressed manure: 1000 ton
* -- Land conversion
  CONVACR                Convert crop land to organic: 1000 ha
  CROPTOPAST             Transfer cropland to pasture with high production basic support: 1000 ha
  UPGRPAST               Upgrade pasture with low production to top support: 1000 ha
  UPGRPASTH              Upgrade pasture with high production to top support: 1000 ha
* -- Miscellaneous
  LVSTKIN                Incoming livestock for pasture: 1000 ton
  LVSTKOUT               Outgoing livestock for pasture: 1000 ton
  HORSES                 Horses for riding etc: 1000 hd
  RSILSUB                Receive silage subsidy
  RCOMPSUB               Receive compensation subsidy
  LESSDCOW               Reduced number of dairy cows: 1000 hd
  LESSBCOW               Reduced number of beef cows: 1000 hd
  LESSCALF               Early slaughter of young cattle: 1000 hd
  LESSSOW                Reduced number of sows: 1000 hd
  LESSSWINE              Reduced number of slaughter swine: 1000 hd /;
*------------------------------------------------------------------------------------------------
* Notes: hd = "head" = number of animals


Sets
  CROPS(AS)        /W-WHEAT, W-RAY, W-BARLEY, BARLEY, OATS, GRAINSIL, MAJSSIL, FEEDPEAS, 
                    W-RAPE, S-RAPE, POTATO, SUGAR,FORAGE1*FORAGE4, PASTURE1, PASTURE2, NEWFOR, SALIX,
                    OTHERCROPS, COVERCROP, CATCHCROP, SPRINGTILL, LAY, LONGLAY,
                    EW-WHEAT, EW-RAY, EBARLEY, EOATS, EFEEDPEAS, EW-RAPE, ES-RAPE, EPOTATO, ESUGAR,
                    EFORAGE1*EFORAGE4, EPASTURE1, EPASTURE2, ENEWFOR, EOTHRCROPS, ECOVERCROP, 
                    ECATCHCROP, ESPRINGTIL, ELAY, ENFIX, SPAREFOR, ICR, NOUSE/
  CROPS2(AS)       /W-WHEAT, W-RAY, W-BARLEY, BARLEY, OATS, GRAINSIL, MAJSSIL, FEEDPEAS, 
                    W-RAPE, S-RAPE, POTATO, SUGAR,FORAGE1*FORAGE4, PASTURE1, PASTURE2, NEWFOR, SALIX,
                    OTHERCROPS, COVERCROP, CATCHCROP, SPRINGTILL, LAY, LONGLAY,
                    EW-WHEAT, EW-RAY, EBARLEY, EOATS, EFEEDPEAS, EW-RAPE, ES-RAPE, EPOTATO, ESUGAR,
                    EFORAGE1*EFORAGE4, EPASTURE1, EPASTURE2, ENEWFOR, EOTHRCROPS, ECOVERCROP,
                    ECATCHCROP, ESPRINGTIL, ELAY, ENFIX, SPAREFOR, ICR, NOUSE,
                    PPASTR, PPASTRB, PPASTRT, PPASTRN, PPASTRH, PPASTRHB, PPASTRHT, PPASTRHN,
                    PPASTRALV, PPASTRFOR, PPASTRMOS, PPASTRLOW, PPASTRCHAL, PPASTRMEAD,
                    SPAPASTR, SPAPASTRT, SPAPASTRH, SPAPASTRHT/
 CROPS3(AS)        /W-WHEAT, W-RAY, W-BARLEY, BARLEY, OATS, W-RAPE, S-RAPE, POTATO, SUGAR/
 CROPS4(AS)        /W-WHEAT, W-RAY, W-BARLEY, BARLEY, OATS, GRAINSIL, MAJSSIL, FEEDPEAS, 
                    W-RAPE, S-RAPE, POTATO, SUGAR,FORAGE1*FORAGE3, PASTURE1, PASTURE2, NEWFOR, 
                    OTHERCROPS, 
                    EW-WHEAT, EW-RAY, EBARLEY, EOATS, EFEEDPEAS, EW-RAPE, ES-RAPE, EPOTATO, ESUGAR,
                    EFORAGE1*EFORAGE4, EPASTURE1, EPASTURE2, ENEWFOR, EOTHRCROPS, ICR/
  GRAINS(CROPS)    /W-WHEAT, W-RAY, W-BARLEY, BARLEY, OATS, GRAINSIL, MAJSSIL,
                    EW-WHEAT, EW-RAY, EBARLEY, EOATS/
  OILGRAINS(CROPS) /W-RAPE, S-RAPE,
                    EW-RAPE, ES-RAPE/
  FEEDACR(AS)      /FORAGE1*FORAGE4, PASTURE1, PASTURE2, NEWFOR,
                    EFORAGE1*EFORAGE4, EPASTURE1, EPASTURE2, ENEWFOR,
                    SPAREFOR, PPASTR, PPASTRT, PPASTRN, PPASTRH, PPASTRHT, PPASTRHN,
                    PPASTRALV, PPASTRFOR, PPASTRMOS, PPASTRLOW, PPASTRCHAL, PPASTRMEAD/
  FORAGES(AS)      /FORAGE1*FORAGE4, PASTURE1, PASTURE2, 
                    EFORAGE1*EFORAGE4, EPASTURE1, EPASTURE2/
  PASTURES(AS)     /PPASTR, PPASTRT, PPASTRN, PPASTRH, PPASTRHT, PPASTRHN,
                    PPASTRALV, PPASTRFOR, PPASTRMOS, PPASTRLOW, PPASTRCHAL, PPASTRMEAD/ 
*                    SPAPASTR, SPAPASTRT, SPAPASTRH, SPAPASTRHT/
  SPRINGCROP(AS)   /BARLEY, OATS, GRAINSIL, MAJSSIL, FEEDPEAS,
                    S-RAPE, POTATO, SUGAR, EBARLEY, EOATS, EFEEDPEAS, ES-RAPE, EPOTATO, ESUGAR/
  WINTERCROP(AS)   /W-WHEAT, W-RAY, W-BARLEY, W-RAPE, EW-WHEAT, EW-RAY, EW-RAPE/
  LIVESTOCK(AS)    /DCOW1*DCOW4, HEIFER, DAIRYBULL1*DAIRYBULL2, SLGHHEIFER, BEEFCATTLE, BEEFCATTL2,
                    SHEEP, SHEEP2, SOW1, GILT, SLGHSWINE1, POULTRY, CHICKEN,
                    EDCOW1*EDCOW3, EHEIFER, EDBULL1*EDBULL2, ESLGHHEIF, EBEEFCATT, EBEEFCAT2, ESHEEP,
                    ECOPIG, EPOULTRY, HORSES/
  DCOWS(AS)        /DCOW1*DCOW4,
                    EDCOW1*EDCOW3/
  BCOWS(AS)        /BEEFCATTLE, BEEFCATTL2, EBEEFCATT, EBEEFCAT2/        
  BEEFCAT(AS)      /DAIRYBULL1*DAIRYBULL2, SLGHHEIFER, BEEFCATTLE, BEEFCATTL2,
                    EDBULL1*EDBULL2, ESLGHHEIF, EBEEFCATT, EBEEFCAT2/        
  INVEST(AS)       /DAIRYFEXR, DAIRYFEXN, BULLFEXR, BULLFEXN, BEEFCFEXR, BEEFCFEXN, 
                    SOWFEXR, SOWFEXN, SWINEFEXR, SWINEFEXN, PLTRYFEXR, PLTRYFEXN, CHICKFEXR, CHICKFEXN/
  ECO(AS)          /EW-WHEAT, EW-RAY, EBARLEY, EOATS, EFEEDPEAS, EW-RAPE, ES-RAPE, EPOTATO, ESUGAR,
                    EFORAGE1*EFORAGE4, EPASTURE1, EPASTURE2, EFORHIGH, ENEWFOR, EOTHRCROPS, ECOVERCROP,
                    ECATCHCROP, ESPRINGTIL, ELAY, ENFIX, 
                    EDCOW1*EDCOW3, EHEIFER, EDBULL1*EDBULL2, ESLGHHEIF, EBEEFCATT, EBEEFCAT2, ESHEEP,
                    ECOPIG, EPOULTRY, PPASTR, PPASTRB, PPASTRT, PPASTRN, PPASTRH, PPASTRHB, PPASTRHT,
                    PPASTRHN, PPASTRALV, PPASTRFOR, PPASTRMOS, PPASTRLOW, PPASTRCHAL, PPASTRMEAD/
  ECOCROPS(CROPS)  /EW-WHEAT, EW-RAY, EBARLEY, EOATS, EFEEDPEAS, EW-RAPE, ES-RAPE, EPOTATO, ESUGAR,
                    EFORAGE1*EFORAGE4, EPASTURE1, EPASTURE2, ENEWFOR, EOTHRCROPS, ECOVERCROP,
                    ECATCHCROP, ESPRINGTIL, ELAY, ENFIX/
  ECROPS3(AS)       /EW-WHEAT, EW-RAY, EBARLEY, EOATS, EW-RAPE, ES-RAPE, EPOTATO, ESUGAR/;
  
Set RSRAS(R,SR,AS)  Subreg crop and livestock prod activities mapped to regions and subreg;
* Include all activities in all region/subregion combinations, then identify excluded activities
  RSRAS(R,SR,AS) = no;
  RSRAS(R,SR,AS) = yes $RSR(R,SR);
  RSRAS(R,SR,'GRAINSIL') = no;
  RSRAS(R,SR,'MAJSSIL') = no;
  RSRAS(R,SA01TO04a,'W-WHEAT')  = no;
  RSRAS(R,SA01TO04a,'W-RAY')   = no;
  RSRAS(R,SA01TO07b,'W-BARLEY')= no;
  RSRAS(R,SR,'OATS') $ SASR('SA01',SR) = no;
  RSRAS(R,SR,'MAJSSIL')     = no;
  RSRAS(R,SR,'MAJSSIL') $ (RSR(R,SR) and SASR('SA13gmb',SR)) = yes;
  RSRAS(R,SR,'MAJSSIL') $ (RSR(R,SR) and SASR('SA13gss',SR)) = yes;
  RSRAS(R,SA01TO04b,'W-RAPE') = no;
  RSRAS(R,SA01TO05,'S-RAPE') = no;
  RSRAS(R,SR,'SUGAR')       = no;
  RSRAS(R,SR,'SUGAR') $ (RSR(R,SR) and SASR('SA13gsk',SR)) = yes;
  RSRAS(R,SR,'SUGAR') $ (RSR(R,SR) and SASR('SA13gmb',SR)) = yes;
  RSRAS(R,SR,'SUGAR') $ (RSR(R,SR) and SASR('SA13gss',SR)) = yes;
  RSRAS(R,SA01TO07b,'SALIX')    = no;
  RSRAS(R,SA01TO12,'CATCHCROP')    = no;
  RSRAS(R,SA01TO12,'SPRINGTILL')   = no;
  RSRAS(R,SA01TO04a,'EW-WHEAT')  = no;
  RSRAS(R,SA01TO04a,'EW-RAY')   = no;
  RSRAS(R,SR,'EOATS') $ SASR('SA01',SR) = no;
  RSRAS(R,SA01TO04b,'EW-RAPE') = no;
  RSRAS(R,SA01TO05,'ES-RAPE') = no;
  RSRAS(R,SR,'ESUGAR')       = no;
  RSRAS(R,SR,'ESUGAR') $ (RSR(R,SR) and SASR('SA13gsk',SR)) = yes;
  RSRAS(R,SR,'ESUGAR') $ (RSR(R,SR) and SASR('SA13gmb',SR)) = yes;
  RSRAS(R,SR,'ESUGAR') $ (RSR(R,SR) and SASR('SA13gss',SR)) = yes;
  RSRAS(R,SA01TO12,'ECATCHCROP')    = no;
  RSRAS(R,SA01TO12,'ESPRINGTIL')    = no;
  RSRAS(R,SA01TO07a,'ECOPIG')   = no;
  RSRAS(R,SR,'PPASTRALV') = no;
  RSRAS(R,'SR042','PPASTRALV')$RSR(R,'SR042') = yes;
  RSRAS(R,'SR053','PPASTRALV')$RSR(R,'SR053') = yes;
  RSRAS(R,'SR060','PPASTRALV')$RSR(R,'SR060') = yes;
  RSRAS(R,'SR066','PPASTRALV')$RSR(R,'SR066') = yes;
  RSRAS(R,'SR078','PPASTRALV')$RSR(R,'SR078') = yes;
  RSRAS(R,SR,'PPASTRCHAL') = no;
  RSRAS(R,SA01TO05,'PPASTRCHAL')$RSR(R,SA01TO05) = yes;
  RSRAS(R,'SR016','PPASTRCHAL')$RSR(R,'SR016') = yes;
  RSRAS(R,'SR047','PPASTRCHAL')$RSR(R,'SR047') = yes;    
  RSRAS(R,'SR054','PPASTRCHAL')$RSR(R,'SR054') = yes;


*** Acreage cost sets

Alias(IS, IS2);

Set ACRIS(IS) "Acreage cost inputs scaled by cumulative real wage growth"
  /ACRCOST, ACRCOSTP, ACRCOSTPB, ACRCOSTPT, ACRCOSTPN, ACRCOSTPH, ACRCOSTPHB, ACRCOSTPHT,
   ACRCOSTPHN, ACRCOSTALV, ACRCOSTFOR, ACRCOSTMOS, ACRCOSTLOW, ACRCOSTCHA, ACRCOSTMEA/;

Set ACRIS_PAST(IS,IS2) "Mapping from pasture acreage cost inputs to corresponding land type inputs"
  /ACRCOSTP.PRMPAST,   ACRCOSTPT.PRMPASTT,  ACRCOSTPN.PRMPASTN,
   ACRCOSTPH.PRMPASTH, ACRCOSTPHT.PRMPASTHT, ACRCOSTPHN.PRMPASTHN,
   ACRCOSTALV.PRMALV,  ACRCOSTFOR.PRMFOR,   ACRCOSTMOS.PRMMOS,
   ACRCOSTLOW.PRMLOW,  ACRCOSTCHA.PRMCHAL,  ACRCOSTMEA.PRMMEAD/;

Set ACRIS_ACT(IS,AS) "Mapping from pasture acreage cost inputs to corresponding pasture activities"
  /ACRCOSTP.PPASTR,    ACRCOSTPT.PPASTRT,   ACRCOSTPN.PPASTRN,
   ACRCOSTPH.PPASTRH,  ACRCOSTPHT.PPASTRHT, ACRCOSTPHN.PPASTRHN,
   ACRCOSTALV.PPASTRALV, ACRCOSTFOR.PPASTRFOR, ACRCOSTMOS.PPASTRMOS,
   ACRCOSTLOW.PPASTRLOW, ACRCOSTCHA.PPASTRCHAL, ACRCOSTMEA.PPASTRMEAD/;


*** CR Processing activities sets

Set CR  Processing activities regional
*---------------------------------------------------------------------------------------------------
* Activity..     Description........................................................................
*---------------------------------------------------------------------------------------------------
 /P-BGTOFG       Bread grain to feed grain: 1000 ton
  P-CGTOFG       Coarse grain to feed grain: 1000 ton
  P-FLOUR        Flour processing: 1000 ton
  P-GSEED        Grain seed processing: 1000 ton
  P-PSEED        Feed peas seed processing: 1000 ton
  P-POTSEED      Potatoes seed processing: 1000 ton
  P-BGTOEG       Bread grain to energy: 1000 ton
  P-CGTOEG       Coarse grain to energy: 1000 ton
  P-SUGAR        Sugar processing: 1000 ton
  P-PREMILK      Preprocessing milk: 1000 ton
  P-KMILK        Consumption milk processing: 1000 ton
  P-CHEESE       Cheese processing: 1000 ton
  P-BUTTER       Butter processing: 1000 ton
  P-CREAM        Cream processing: 1000 ton
  P-DRYMILK      Dry skim milk processing: 1000 ton
  P-DRYMILK2     Dry full milk processing: 1000 ton
  P-BEEF         Beef processing: 1000 ton
  P-PORK         Pork processing: 1000 ton
  P-POULTRY      Poultry meat processing: 1000 ton
  P-FPEAS        Harvested peas to peas for feed: 1000 ton
  P-PEAS         Processing of peas with heat: 1000 ton
  P-RMEAL        Extraktion of oil from oilgrain: 1000 ton
  P-RKAKA        Cold processing of oil from oilgrain: 1000 ton
  P-RME          Oilgrain processed to energy: 1000 ton
  P-PROTFEED     Rapemeal to protein feed: 1000 ton
  R-BREADGR      Retail sale of breadgrain: 1000 ton
  R-COARSGR      Retail sale of coarsgrain: 1000 ton
  R-FLOUR        Retail sale of flour: 1000 ton
  R-RAPEOIL      Retail sale of rapeoil: 1000 ton
  R-POTATOES     Retail sale of potatoes: 1000 ton
  R-SUGAR        Retail sale of sugar: 1000 ton
  R-OTHRCROP     Retail sale of othercrops: 1000 ton
  R-ICRPR        Retail sale of inductry crops: 1000 ton
  R-SHEEP        Retail sale of sheep meat: 1000 ton
  R-EGG          Retail sale of egg: 1000 ton
  R-KMILK        Retail sale of kmilk: 1000 ton
  R-CHEESE       Retail sale of cheese: 1000 ton
  R-BUTTER       Retail sale of butter: 1000 ton
  R-CREAM        Retail sale of cream: 1000 ton
  R-DRYMILK      Retail sale of drymilk: 1000 ton
  R-BEEF         Retail sale of beef: 1000 ton
  R-PORK         Retail sale of pork: 1000 ton
  R-PLTRYM       Retail sale of poultry meat: 1000 ton
  R-WILDMEAT     Retail sale of meat from game animals and reindeers for consumption: 1000 ton
  R-FISH         Retail sale of fish and seafood for consumption: 1000 ton
  R-VEGETAB      Retail sale of vegetables for consumption: 1000 ton
  R-FRUIT        Retail sale of fruit for consumption: 1000 ton
  R-WBERRY       Retail sale of wild berrys for consumption: 1000 ton
  
  REINDEER       Production from raindeers: 1000 ton
  HUNTING        Production from game animals: 1000 ton
  FISHING        Production of fish and seafood: 1000 ton
  FRUITS         Production of fruit: 1000 ton
  VEGETABLE      Production of vegetables: 1000 ton
  WILDBERRY      Production of wild berries: 1000 ton/;
*---------------------------------------------------------------------------------------------------
 
 
Set RCR(R,CR)  Regional processing activities mapped to regions;
* Assign all regional processing activities to all regions, then identify excluded activities
* by region

  RCR(R,CR) = yes;
  RCR(R,'P-RMEAL') = no;
  RCR(R,'P-RKAKA') = no;
  RCR(R,'P-RME')   = no;
  RCR(R,'P-SUGAR') = no;  
  RCR('R5','P-RMEAL')  = yes;
  RCR('R5','P-RKAKA')  = yes;
  RCR('R5','P-RME')    = yes;
  RCR('R6','P-SUGAR')  = yes;
  

*** Other sets
 
Set T(RS,RD)  Transportation patterns;
  T(RS,RD) = yes;
  T(RS,RS) = no;
 
Set TRP(PR) Transported regional products
  / BREADGRAIN, COARSGRAIN, FEEDGRAIN, FLOUR, PEAS, OILGRAIN, RAPEMEAL, RAPEOIL, RAPSKAKA, POTATOES,
    SUGARBEET, WHITESUGAR, DCALFM, DCALFF, PIGLETS, ECOMPMAN, EPEAS, EGRAIN, ERAPE, ESUGARB, EMILK,
    EBEEF, EPORK, ESHEEPM, EEGG, SLGHBEEF, SLGHPORK, SLGHPLTRY, SLGHSHEEP, EGG, SKIMMILK, MILKFAT,
    KMILK, CHEESE, BUTTER, CREAM, DRYMILK, DRYMILK2, BEEF, PORK, PLTRYMEAT, WILDMEAT, FISH, FRUIT,
    VEGETAB, WBERRY/;

Set TRI(IR) Transported regional inputs
  / GRAINSEED, PEASSEED, POTATOSEED, BETFOR, HPMASSA/;

Set TIP(RS,RD,IP)  Regional inputs and products mapped to transportation patterns;
* Include all inputs and products in both regions, then exclude specific products on specific
* routes
  TIP(RS,RD,IP) = no;
  TIP(RS,RD,PR)$TRP(PR) = RPR(RS,PR)*RPR(RD,PR)*T(RS,RD);
  TIP(RS,RD,IR)$TRI(IR) = RIR(RS,IR)*RIR(RD,IR)*T(RS,RD);
 
Set SDP  Supply and demand parameters  /PBAR, QBAR, ELAS, MIN, MAX, INTERCEPT, SLOPE/;

Set TRD  Trade parameters  /WPRICE, TARIFF, SUBSIDY, MIN, MAX, ADJPRICE/;


* Assignments are made to the following sets based on the values of supply and demand parameters.
* These assignments occur after the corresponding parameter tables
Set INES(IN)       Elastic supply national inputs;
Set INFS(IN)       Fixed supply national inputs;
Set IRES(R,IR)     Elastic supply regional inputs mapped to regions;
Set IRFS(R,IR)     Fixed supply regional inputs mapped to regions;
Set ISES(R,SR,IS)  Elastic supply subregional inputs mapped to regions;
Set ISFS(R,SR,IS)  Fixed supply subregional inputs mapped to regions;

Set PNED(PN)       Elastic demand national products;
Set PNFD(PN)       Fixed demand national products;
Set PRED(R,PR)     Elastic demand regional products mapped to regions;
Set PRFD(R,PR)     Fixed demand regional products mapped to regions;
Set PSED(R,SR,PS)  Elastic demand subregional products mapped to regions;
Set PSFD(R,SR,PS)  Fixed demand subregional products mapped to regions;

*======================================================================


* ------------------------
* 2) DECLARATIONS: PARAMETERS / SCALARS
* ------------------------
Parameter
    LONGRUN             "no for short run analysis. Base year for acreage och buildings is 2021"
    LONGRUN1            "no for analysis without prices changes"
    LONGRUN2            "no for analysis without productivity development"
    prodGrowthYields    "Annual productivity development, yields"
    prodGrowthInputs    "Annual productivity development, inputs"
    prodGrowthLabour    "Annual productivity development, labour"
    prodGrowthPower     "Annual productivity development, power"
    CO2IMP              "no for analysis without climate effects of imported inputs and products";

* Alternative names to consider
*   isLongRun              "Long-run analysis (yes) vs short run (no)"
*   includeYieldGrowth     "Include productivity development"
*   includeCO2Imports      "Include climate effects of imported inputs and products";

Scalar
    YEAR  "Simulation year"
    YR    "Number of years from base year 2025"
    YRA   "Number of years from base year for acreages, 2022"
    YRT   "Number of years from base year for technical coefficients, 2020"
    KPI   "Changed consumer price index from base year"
    KPI2  "Changed consumer price index from 2023"
    KPI3  "Changed all prices from base year to monetary value 2024"
    KURS  "Exchange rate SEK per EUR"
    RED   "Reduction factor in trade and transport (crisis)";

* Alternative names to consider
*    yearsFromBase      "Number of years from base year 2025"
*    yearsForAcreage    "Years from base year for acreages, 2022"
*    yearsForTechCoeff  "Years from base year for technical coefficients, 2020"
*    cpiBase            "Consumer price index change from base year"
*    cpiFrom2023        "Consumer price index change from 2023"
*    priceLevel2024     "Price conversion factor to 2024 monetary value"
*    exchangeRate       "Exchange rate SEK per EUR"
*    transportReduction "Reduction factor in trade and transport";


** 2.1 Overview of SASM data

*---------------------------------------------------------------------------------------------------
*Item.............  Description....................................................................
*---------------------------------------------------------------------------------------------------
*EAS(R,SR,AS,IP)    Unit input and product coefficients for subregional crop and livestock
*                   production activities; reg by subreg by prod act by input/product; subreg,
*                   reg or natl inputs/products; positive implies net use and negative implies
*                   net production
*
*ECR(R,CR,IP)       Unit input and production coefficients for regional processing activities, reg
*                   by proc act by input/product; reg or natl inputs/products; positive implies
*                   net use and negative implies net production
*
*BIN(IN,SDP)        National input supply parameters; input by parameter type;
*                   values determine the elements of dynamic sets INES and INFS
*
*BIR(R,IR,SDP)      Regional input supply parameters; reg by regional input by parameter type;
*                   values determine the elements of dynamic sets IRES and IRFS
*
*BIS(R,SR,IS,SDP)   Subregional input supply parameters; reg by subreg by subregional input by
*                   parameter type; values determine the elements of dynamic sets ISES and ISFS
*
*BPN(PN,SDP)        National product demand parameters; product by parameter type; values
*                   determine the elements of dynamic sets PNED and PNFD
*
*BPR(R,PR,SDP)      Regional product demand parameters; reg by product by parameter type; values
*                   determine the elements of dynamic sets PRED and PRFD
*
*BPS(R,SR,PS,SDP)   Subregional product demand parameters; reg by subreg by product by parameter
*                   type; values determine the elements of dynamic sets PSED and PSFD
*
*CT(RS,RD,IR)       Unit transportation cost; source reg by destination reg by input or product
*
*DT(RS,RD)          Distance from source region to destination region; 1000 km
*
*UT(IP)             Unit transportation cost per 1000 km by regional product
*
*BXR(R,PR,TRD)      Export parameters for regional products; reg by product by parameter
*
*BMR(R,PR,TRD)      Import parameters for regional products; reg by product by parameter
*
*MS(R)              Milk subsidy in Mil SEK per 1000 ton output; by reg
*---------------------------------------------------------------------------------------------------


** 2.2 Declaration of parameters

* Declaration of parameters that are subsequently defined by data.gdx
Parameter
  PRODCOEFC_SA(AS,IP,SA)    "Unit input and product coef for crop prod act by support areas"
  PRODCOEFC2_PO(AS,IP,PO)   "Unit input and product coef for pesticide use by PO8"
  PRODCOEFL_SA(AS,IP,SA)    "Unit input and product coef for livestock prod act by support areas"
  BIN(IN,SDP)               "National input supply parameters"
  BIR(R,IR,SDP)             "Regional input supply parameters"
  BIRF(IR,R)                "Regional supply of fixed inputs"
  BIRI(IR,R)                "Regional prices of inputs with infinite price elasticity"
  BISFA(SR,IS)              "Subregional supply of fixed inputs"
  BMR(R,PR,TRD)             "Import parameters for regional products"
  BPN(PN,SDP)               "National product demand parameters"
  BPRN(PR,SDP)              "National data for regional product demand parameters"
  BPSI_SA(SA,PS)            "Subregional prices of infinite elastic products, by support area SA"
  BXR(R,PR,TRD)             "Export parameters for regional products"
  CONST(IP,AS)              "Constraints on crop rotation etc."
  DT(RS,RD)                 "Distance from source region to destination region"
  ECR(R,CR,IP)              "Unit input and product coef for regional processing activities"
  ECR2(R,CR,IP)             "Unit input and product coef for regional retail activities"
  ECR3(R,CR,IP)             "Unit input and product coef for regional production activities"
  MANURE(AS,IP)
  NSUB(AS,SR)               "Potential for national subsidies"
  NUTRIENT(P,NUTX)          "Content of nutrients in products (KJ per 100g or g per 100g)"
  pricesExport(PR,TIME)
  pricesImport(PR,TIME)
  pricesInputs(R,I,TIME)
  cumWageGrowthReal(TIME)
  POP(R)                    "Population separated in regions"
  UT(IP)                    "Unit transportation cost per 1000 kilometers";

* Declaration of other parameters
Parameter
  BIS(R,SR,IS,SDP)          "Subregional input supply"
  BISF(R,SR,IS)             "Subegional input supply parameters"
  BPR(R,PR,SDP)             "Regional product demand parameters"
  BPS(R,SR,PS,SDP)          "Subregional product demand parameters"
  BPSF(R,SR,PS)             "Subregional demand of products with fixed demand"
  BPSF_BASE(PS)             "Base subregional demand profile for creation of BPSF(R,SR,PS)(template)"
  BPSI(SR,PS)               "Subregional prices of infinite elastic products"
  CT(RS,RD,IP)              "Unit transportation cost"
  DPTC(P)                   "Dairy processing transfer cost"
  EAS(R,SR,AS,IP)           "Unit input and product coef for subregional crop and livestock prod act"
  costCalibration(AS)       "Calibration adjustments (Mil SEK per unit)"
  MS(SR)                    "Milk subsidy per unit"
  PRODCOEFC_SR(AS,IP,SR)    "Unit input and product coef for subregional crop prod act"
  PRODCOEFC2_SR(AS,IP,SR)   "Unit input and product coef for subregional pesticide use"
  PRODCOEFL_SR(AS,IP,SR)    "Unit input and product coef for subregional livestock prod act"
  PRODCOEF(AS,IP,SR)        "Unit input and product coef"
* Flytta till scenario-fil:
  DPTR(P)                   "Dairy processing transfer receipt";
*======================================================================

* 2.3 Declaration of symbols for scenario settings

Parameter supportPct(PN) "Pct change (decimal) for farm payments";
Parameter supportAdd(PN) "Absolute change for farm payments";
Parameter inputPricePct(I)   "Pct change (decimal) for input prices";
Parameter exportPricePct(PR) "Pct change (decimal) for export prices";
Parameter importPricePct(PR) "Pct change (decimal) for import prices";

Scalar areaPaymentScaleFactor "Convert SEK/ha to million SEK per 1000 ha";

* ------------------------
* 3) DECLARATIONS: VARIABLES
* ------------------------
$STITLE Variable declarations, variable bounds and equation declarations
VARIABLES
*---------------------------------------------------------------------------------------------------

* Variable...........  Description..................................................................
*---------------------------------------------------------------------------------------------------
  Z                    Objective function value
  PRODSR(R,SR,AS)      Subregional crop and livestock production activities
  PROCR(R,CR)          Regional processing activities
  SUPPLYIN(IN)         National input supply activities for inputs with elastic supply functions
  SUPPLYIR(R,IR)       Regional input supply activities for inputs with elastic supply functions
  SUPPLYIS(R,SR,IS)    Subregional input supply activities for inputs with elastic supply functions
  DEMANDPN(PN)         National product demand activities for products with elastic demand functions
  DEMANDPR(R,PR)       Regional product demand activities for products with elastic demand functions
  DEMANDPS(R,SR,PS)    Subreg product demand activities for products with elastic demand functions
  EXPORTRP(R,PR)       Export of regional products
  IMPORTPR(R,PR)       Import of regional products
  TRANIP(RS,RD,IP)     Inter-regional transportation of regional inputs and products;
*---------------------------------------------------------------------------------------------------

POSITIVE VARIABLE   PRODSR, PROCR, SUPPLYIN, SUPPLYIR, SUPPLYIS, DEMANDPN, DEMANDPR, DEMANDPS,
                    EXPORTRP, IMPORTPR, TRANIP;
*======================================================================


* ------------------------
* 4) DECLARATIONS: EQUATIONS
* ------------------------
EQUATIONS
*---------------------------------------------------------------------------------------------------


* Equation...........  Description..................................................................
*---------------------------------------------------------------------------------------------------
  OBJECTIVE            Objective function Mil SEK
 
  PRODUCTNE(PN)        National elastic demand product balance
  PRODUCTNF(PN)        National fixed and endogenous demand product balance
  PRODUCTRE(R,PR)      Regional elastic demand product balance
  PRODUCTRF(R,PR)      Regional fixed and endogenous demand product balance
  PRODUCTSE(R,SR,PS)   Subregional elastic demand product balance
  PRODUCTSF(R,SR,PS)   Subregional fixed and endogenous demand product balance
 
  INPUTNE(IN)          National elastic supply input balance
  INPUTNF(IN)          National fixed supply input balance
  INPUTRE(R,IR)        Regional elastic supply input balance
  INPUTRF(R,IR)        Regional fixed supply input balance
  INPUTSE(R,SR,IS)     Subregional elastic supply input balance
  INPUTSF(R,SR,IS)     Subregional fixed supply input balance;

*-------------------------------------------------------------------------------------------------
*======================================================================

* ------------------------
* 6) DEFINITION: PARAMETERS
* ------------------------

$include settings.gms

** 6.1 Define time horizons
YR  = YEAR - 2025;
YRA = YEAR - 2022;
YRT = YEAR - 2025;

areaPaymentScaleFactor = 0.001;

** 6.2 Load data

$set dataGdx output\data.gdx

$call gdxxrw.exe i=data\data.xlsx o=%dataGdx% index=index!A5
$if not exist "%dataGdx%" $abort "data.gdx skapades inte (gdxxrw misslyckades)"

execute_load "%dataGdx%",
  PRODCOEFC_SA, PRODCOEFC2_PO, PRODCOEFL_SA, BIN, BIR, BIRF, BIRI, BISFA, BMR, BPN, BPRN, BPSI_SA,
  BXR, DT, CONST, ECR, ECR2, ECR3, MANURE, NSUB, NUTRIENT, pricesExport, pricesImport, pricesInputs, cumWageGrowthReal, POP, UT;


** 6.3 Calculations of parameters

***TABLE PRODCOEFC
PRODCOEFC_SA(AS,'NLEAKAGE',SA)         = PRODCOEFC_SA(AS,'NLEAKAGE',SA) * 0.85;
* 15 percent of leakage is related to manure: SMED report nr 5 2019

PRODCOEFC_SA(AS,'PLEAKAGE',SA)         = PRODCOEFC_SA(AS,'PLEAKAGE',SA)/1000;

* Higher need for labor (and power) for grains and oilgrains in LFA
PRODCOEFC_SA(GRAINS,'LABOR',SA)$SA_prod_ANC(SA) = PRODCOEFC_SA(GRAINS,'LABOR',SA) * 1.15;
PRODCOEFC_SA(OILGRAINS,'LABOR',SA)$SA_prod_ANC(SA) = PRODCOEFC_SA(OILGRAINS,'LABOR',SA) * 1.15;
*Higher need for labor (and power) for grains and oilgrains in LFA
*PRODCOEFC_SA(GRAINS,'LABOR',SA01TO12)       = PRODCOEFC_SA(GRAINS,'LABOR',SA01TO12)    * 1.15;
*PRODCOEFC_SA(OILGRAINS,'LABOR',SA01TO12)    = PRODCOEFC_SA(OILGRAINS,'LABOR',SA01TO12) * 1.15;

PRODCOEFC_SA(AS,'POWER',SA)             = PRODCOEFC_SA(AS,'LABOR',SA);
PRODCOEFC_SA('POTATO','POWER',SA)       = PRODCOEFC_SA('POTATO','LABOR',SA) * 0.8;
PRODCOEFC_SA(AS,'LABOR',SA)             = PRODCOEFC_SA(AS,'LABOR',SA) * 1.25;

* Change from feed to dry matter (ts)
PRODCOEFC_SA('FORAGE1','SILAGE',SA)     = PRODCOEFC_SA('FORAGE1','SILAGE',SA) * 0.84;
PRODCOEFC_SA('FORAGE2','SILAGE',SA)     = PRODCOEFC_SA('FORAGE2','SILAGE',SA) * 0.84;
PRODCOEFC_SA('FORAGE2','GRASSPASTR',SA) = PRODCOEFC_SA('FORAGE2','GRASSPASTR',SA) * 0.84;

* Reduce to better matching
PRODCOEFC_SA(GRAINS,'BREADGRAIN',SA)     = PRODCOEFC_SA(GRAINS,'BREADGRAIN',SA) * 0.92;
PRODCOEFC_SA(GRAINS,'COARSGRAIN',SA)     = PRODCOEFC_SA(GRAINS,'COARSGRAIN',SA) * 0.92;
PRODCOEFC_SA(OILGRAINS,'OILGRAIN',SA)    = PRODCOEFC_SA(OILGRAINS,'OILGRAIN',SA) * 0.88;
PRODCOEFC_SA('POTATO','POTATOES',SA)     = PRODCOEFC_SA('POTATO','POTATOES',SA) * 0.90;
PRODCOEFC_SA('SUGAR','SUGARBEET',SA)     = PRODCOEFC_SA('SUGAR','SUGARBEET',SA) * 0.88;

PRODCOEFC_SA('FORAGE1','SILAGE',SA)     = PRODCOEFC_SA('FORAGE1','SILAGE',SA) * 0.90;
PRODCOEFC_SA('FORAGE2','SILAGE',SA)     = PRODCOEFC_SA('FORAGE2','SILAGE',SA) * 0.90;
PRODCOEFC_SA('FORAGE2','GRASSPASTR',SA) = PRODCOEFC_SA('FORAGE2','GRASSPASTR',SA) * 0.90;
PRODCOEFC_SA(FORAGES, FERT,SA)          = PRODCOEFC_SA(FORAGES, FERT,SA) * 0.90;
PRODCOEFC_SA(FORAGES,'CAPITAL',SA)      = PRODCOEFC_SA(FORAGES,'CAPITAL',SA) * 0.90;
PRODCOEFC_SA(FORAGES,'OTHRVARCST',SA)   = PRODCOEFC_SA(FORAGES,'OTHRVARCST',SA) * 0.90;

* Include PK fertilizers for other crops than forage, pasture and salix
PRODCOEFC_SA('W-WHEAT','PHOSPHORUS',SA)    = -PRODCOEFC_SA('W-WHEAT','BREADGRAIN',SA)  * 0.0037;
PRODCOEFC_SA('W-WHEAT','POTASSIUM',SA)     = -PRODCOEFC_SA('W-WHEAT','BREADGRAIN',SA)  * 0.0050;
PRODCOEFC_SA('W-RAY','PHOSPHORUS',SA)      = -PRODCOEFC_SA('W-RAY','BREADGRAIN',SA)    * 0.0035;
PRODCOEFC_SA('W-RAY','POTASSIUM',SA)       = -PRODCOEFC_SA('W-RAY','BREADGRAIN',SA)    * 0.0050;
PRODCOEFC_SA('BARLEY','PHOSPHORUS',SA)     = -PRODCOEFC_SA('BARLEY','COARSGRAIN',SA)   * 0.0035;
PRODCOEFC_SA('BARLEY','POTASSIUM',SA)      = -PRODCOEFC_SA('BARLEY','COARSGRAIN',SA)   * 0.0050;
PRODCOEFC_SA('OATS','PHOSPHORUS',SA)       = -PRODCOEFC_SA('OATS','COARSGRAIN',SA)     * 0.0034;
PRODCOEFC_SA('OATS','POTASSIUM',SA)        = -PRODCOEFC_SA('OATS','COARSGRAIN',SA)     * 0.0050;

PRODCOEFC_SA('W-RAPE','PHOSPHORUS',SA)     = -PRODCOEFC_SA('W-RAPE','OILGRAIN',SA)     * 0.0060;
PRODCOEFC_SA('W-RAPE','POTASSIUM',SA)      = -PRODCOEFC_SA('W-RAPE','OILGRAIN',SA)     * 0.0080;
PRODCOEFC_SA('S-RAPE','PHOSPHORUS',SA)     = -PRODCOEFC_SA('S-RAPE','OILGRAIN',SA)     * 0.0060;
PRODCOEFC_SA('S-RAPE','POTASSIUM',SA)      = -PRODCOEFC_SA('S-RAPE','OILGRAIN',SA)     * 0.0080;
PRODCOEFC_SA('W-RAPE','PHOSPHORUS',SA)     = -PRODCOEFC_SA('W-RAPE','BREADGRAIN',SA)   * 0.0037;
PRODCOEFC_SA('W-RAPE','POTASSIUM',SA)      = -PRODCOEFC_SA('W-RAPE','BREADGRAIN',SA)   * 0.0050;
PRODCOEFC_SA('S-RAPE','PHOSPHORUS',SA)     = -PRODCOEFC_SA('S-RAPE','BREADGRAIN',SA)   * 0.0037;
PRODCOEFC_SA('S-RAPE','POTASSIUM',SA)      = -PRODCOEFC_SA('S-RAPE','BREADGRAIN',SA)   * 0.0050;

PRODCOEFC_SA('POTATO','PHOSPHORUS',SA)     = -PRODCOEFC_SA('POTATO','POTATOES',SA)     * 0.00055;
PRODCOEFC_SA('POTATO','POTASSIUM',SA)      = -PRODCOEFC_SA('POTATO','POTATOES',SA)     * 0.00055;
PRODCOEFC_SA('SUGAR','PHOSPHORUS',SA)      = -PRODCOEFC_SA('SUGAR','SUGARBEET',SA)     * 0.0003;
PRODCOEFC_SA('SUGAR','POTASSIUM',SA)       = -PRODCOEFC_SA('SUGAR','SUGARBEET',SA)     * 0.0020;


* Include coef for pasture
PRODCOEFC_SA('FORAGE2','GRASSPASTR',SA) = PRODCOEFC_SA('FORAGE2','GRASSPASTR',SA) * 0.65/0.8;
PRODCOEFC_SA('PASTURE1','GRASSPASTR',SA) = PRODCOEFC_SA('FORAGE1','SILAGE',SA) * 0.65/0.8;
PRODCOEFC_SA('PASTURE2','GRASSPASTR',SA) = PRODCOEFC_SA('PASTURE1','GRASSPASTR',SA)* 0.8;
PRODCOEFC_SA('PPASTR','GRASSPASTR',SA)   = PRODCOEFC_SA('PASTURE1','GRASSPASTR',SA)* 0.5;

PRODCOEFC_SA('PASTURE1','CAPITAL',SA)    = PRODCOEFC_SA('FORAGE1','CAPITAL',SA)  * 0.9;
PRODCOEFC_SA('PASTURE2','CAPITAL',SA)    = PRODCOEFC_SA('PASTURE1','CAPITAL',SA) * 0.63;
PRODCOEFC_SA('PPASTR','CAPITAL',SA)      = PRODCOEFC_SA('PASTURE1','CAPITAL',SA) * 0.75;

* Include coef for Winter barley
PRODCOEFC_SA('W-BARLEY',IP,SA) = PRODCOEFC_SA('W-WHEAT',IP,SA) * 0.9;
PRODCOEFC_SA('W-BARLEY','COARSGRAIN',SA) = PRODCOEFC_SA('W-WHEAT','BREADGRAIN',SA) * 0.85;
PRODCOEFC_SA('W-BARLEY','BREADGRAIN',SA) = 0;
PRODCOEFC_SA('W-BARLEY','NLEAKAGE',SA) = PRODCOEFC_SA('W-WHEAT','NLEAKAGE',SA);
PRODCOEFC_SA('W-BARLEY','PLEAKAGE',SA) = PRODCOEFC_SA('W-WHEAT','PLEAKAGE',SA);

* Include coef for cover crops
PRODCOEFC_SA('COVERCROP','NITROGEN',SA)   =  0.040 - 0.040;
PRODCOEFC_SA('COVERCROP','OTHRVARCST',SA) =  0.500 - 0.500;
PRODCOEFC_SA('COVERCROP','LABOR',SA)      =  0.0015;
PRODCOEFC_SA('COVERCROP','LABOR2',SA)     =  0.0015;
PRODCOEFC_SA('COVERCROP','POWER',SA)      =  0.0015;
PRODCOEFC_SA('COVERCROP','INCONVCOV',SA)  =  1.000;
PRODCOEFC_SA('COVERCROP','NLEAKAGE',SA)  = -PRODCOEFC_SA('BARLEY','NLEAKAGE',SA)   * 0.33/2;
* Leakage reduction assumed half of catchcrop. Othvarcsot are added to INCONVCOV

* Include coef for catch crops (SA13 only)
PRODCOEFC_SA('CATCHCROP','COARSGRAIN',SA)$SA_prod_13(SA) = -PRODCOEFC_SA('BARLEY','COARSGRAIN',SA) * 0.04;
PRODCOEFC_SA('CATCHCROP','NITROGEN',SA)$SA_prod_13(SA) = -PRODCOEFC_SA('CATCHCROP','COARSGRAIN',SA) * 0.0182;
PRODCOEFC_SA('CATCHCROP','PHOSPHORUS',SA)$SA_prod_13(SA) = -PRODCOEFC_SA('CATCHCROP','COARSGRAIN',SA) * 0.0035;
PRODCOEFC_SA('CATCHCROP','POTASSIUM',SA)$SA_prod_13(SA) = -PRODCOEFC_SA('CATCHCROP','COARSGRAIN',SA) * 0.0050;
PRODCOEFC_SA('CATCHCROP','OTHRVARCST',SA)$SA_prod_13(SA) = 0.150;
PRODCOEFC_SA('CATCHCROP','INCONVCAT',SA)$SA_prod_13(SA)  = 1.000;
PRODCOEFC_SA('CATCHCROP','NLEAKAGE',SA)$SA_prod_13(SA) = -PRODCOEFC_SA('BARLEY','NLEAKAGE',SA) * 0.33;
* Leakage data from SMED report nr 5 2019

* Include coef for spring tillage (SA13 only)
PRODCOEFC_SA('SPRINGTILL','INCONVLAT',SA)$SA_prod_13(SA) = 1.000;
PRODCOEFC_SA('SPRINGTILL','NLEAKAGE',SA)$SA_prod_13(SA) = -PRODCOEFC_SA('BARLEY','NLEAKAGE',SA) * 0.02;

* Include coef for catch crops
*PRODCOEFC_SA('CATCHCROP','COARSGRAIN',SA13) =  -PRODCOEFC_SA('BARLEY','COARSGRAIN',SA13) * 0.04;
*PRODCOEFC_SA('CATCHCROP','NITROGEN',SA13)     = -PRODCOEFC_SA('CATCHCROP','COARSGRAIN',SA13)   * 0.0182;
*PRODCOEFC_SA('CATCHCROP','PHOSPHORUS',SA13)   = -PRODCOEFC_SA('CATCHCROP','COARSGRAIN',SA13)   * 0.0035;
*PRODCOEFC_SA('CATCHCROP','POTASSIUM',SA13)    = -PRODCOEFC_SA('CATCHCROP','COARSGRAIN',SA13)   * 0.0050;
*PRODCOEFC_SA('CATCHCROP','OTHRVARCST',SA13) =  0.150;
*PRODCOEFC_SA('CATCHCROP','INCONVCAT',SA13)  =  1.000;
*PRODCOEFC_SA('CATCHCROP','NLEAKAGE',SA13)     = -PRODCOEFC_SA('BARLEY','NLEAKAGE',SA13)   * 0.33;
* Leakage data from SMED report nr 5 2019

* Include coef for spring tillage
*PRODCOEFC_SA('SPRINGTILL','INCONVLAT',SA13) =  1.000;
*PRODCOEFC_SA('SPRINGTILL','NLEAKAGE',SA13) = -PRODCOEFC_SA('BARLEY','NLEAKAGE',SA13)   * 0.02;
* Leakage data from SMED report nr 5 2019


*** TABLE PRODCOEFC2(AS,IP,SR)  Unit input and product coef for subregional crop prod act
PRODCOEFC2_PO(AS,'HERBICIDES',PO) = PRODCOEFC2_PO(AS,'HERBICIDES',PO) * 1.2  * 1.33;
PRODCOEFC2_PO(AS,'GLYFOSAT',PO)   = PRODCOEFC2_PO(AS,'GLYFOSAT',PO)   * 1    * 1.33;
PRODCOEFC2_PO(AS,'FUNGICIDES',PO) = PRODCOEFC2_PO(AS,'FUNGICIDES',PO) * 1    * 1.0;
PRODCOEFC2_PO(AS,'INSECTICID',PO) = PRODCOEFC2_PO(AS,'INSECTICID',PO) * 1.33 * 2.5;
* The first part of the adjustment is to match the use as in SCB, MI 31 SM 1802
* The secund part is to match use with sales as in SCB, MI 31 SM 2101 


*** TABLE PRODCOEFL(AS,IP,SR)  Unit input and product coef for subregional livestock prod act     
* Updated investment costs based on unit costs from SJV. 15% investment sub
PRODCOEFL_SA('DAIRYFEXN','MISCCOST',SA)    = PRODCOEFL_SA('DAIRYFEXN','MISCCOST',SA) * 111000/73000;
PRODCOEFL_SA('BULLFEXN','MISCCOST',SA)     = PRODCOEFL_SA('BULLFEXN','MISCCOST',SA)  *  27200/10000 * 0.85;
PRODCOEFL_SA('BEEFCFEXN','MISCCOST',SA)    = PRODCOEFL_SA('BEEFCFEXN','MISCCOST',SA) *  63400/10000 * 0.85;
PRODCOEFL_SA('SOWFEXN','MISCCOST',SA)      = PRODCOEFL_SA('SOWFEXN','MISCCOST',SA)   *  74100/35000 * 0.85;
PRODCOEFL_SA('SWINEFEXN','MISCCOST',SA)    = PRODCOEFL_SA('SWINEFEXN','MISCCOST',SA) *   9900/4000  * 0.85;
PRODCOEFL_SA('PLTRYFEXN','MISCCOST',SA)    = PRODCOEFL_SA('PLTRYFEXN','MISCCOST',SA) *  2;
PRODCOEFL_SA('CHICKFEXN','MISCCOST',SA)    = PRODCOEFL_SA('CHICKFEXN','MISCCOST',SA) *  2;

PRODCOEFL_SA('DAIRYFEXN','MISCCOST',SA) $ (LONGRUN1) = PRODCOEFL_SA('DAIRYFEXN','MISCCOST',SA)* 1.01**(YR-4);
PRODCOEFL_SA('BULLFEXN','MISCCOST',SA)  $ (LONGRUN1) = PRODCOEFL_SA('BULLFEXN','MISCCOST',SA) * 1.01**(YR-4);
PRODCOEFL_SA('BEEFCFEXN','MISCCOST',SA) $ (LONGRUN1) = PRODCOEFL_SA('BEEFCFEXN','MISCCOST',SA)* 1.01**(YR-4);
PRODCOEFL_SA('SOWFEXN','MISCCOST',SA)   $ (LONGRUN1)  = PRODCOEFL_SA('SOWFEXN','MISCCOST',SA)  * 1.01**(YR-4);
PRODCOEFL_SA('SWINEFEXN','MISCCOST',SA) $ (LONGRUN1) = PRODCOEFL_SA('SWINEFEXN','MISCCOST',SA)* 1.01**(YR-4);
PRODCOEFL_SA('PLTRYFEXN','MISCCOST',SA) $ (LONGRUN1) = PRODCOEFL_SA('PLTRYFEXN','MISCCOST',SA)* 1.01**(YR-4);
PRODCOEFL_SA('CHICKFEXN','MISCCOST',SA) $ (LONGRUN1) = PRODCOEFL_SA('CHICKFEXN','MISCCOST',SA)* 1.01**(YR-4);

*Higer cost for livestock in north
PRODCOEFL_SA(AS,'OTHERFEED','SA01')       = PRODCOEFL_SA(AS,'OTHERFEED','SA01') * 1.25;
PRODCOEFL_SA(AS,'OTHERFEED','SA03')       = PRODCOEFL_SA(AS,'OTHERFEED','SA03') * 1.15;
PRODCOEFL_SA(AS,'OTHERFEED','SA04a')       = PRODCOEFL_SA(AS,'OTHERFEED','SA04a') * 1.10;
PRODCOEFL_SA(AS,'OTHERFEED','SA04b')       = PRODCOEFL_SA(AS,'OTHERFEED','SA04b') * 1.075;
PRODCOEFL_SA(AS,'OTHERFEED','SA05')       = PRODCOEFL_SA(AS,'OTHERFEED','SA05') * 1.05;

PRODCOEFL_SA(AS,'OTHRVARCST','SA01')      = PRODCOEFL_SA(AS,'OTHRVARCST','SA01') * 1.25;
PRODCOEFL_SA(AS,'OTHRVARCST','SA03')      = PRODCOEFL_SA(AS,'OTHRVARCST','SA03') * 1.15;
PRODCOEFL_SA(AS,'OTHRVARCST','SA04a')      = PRODCOEFL_SA(AS,'OTHRVARCST','SA04a') * 1.10;
PRODCOEFL_SA(AS,'OTHRVARCST','SA04b')      = PRODCOEFL_SA(AS,'OTHRVARCST','SA04b') * 1.075;
PRODCOEFL_SA(AS,'OTHRVARCST','SA05')      = PRODCOEFL_SA(AS,'OTHRVARCST','SA05') * 1.05;

PRODCOEFL_SA(AS,'CAPITAL','SA01')         = PRODCOEFL_SA(AS,'CAPITAL','SA01') * 1.25;
PRODCOEFL_SA(AS,'CAPITAL','SA03')         = PRODCOEFL_SA(AS,'CAPITAL','SA03') * 1.15;
PRODCOEFL_SA(AS,'CAPITAL','SA04a')         = PRODCOEFL_SA(AS,'CAPITAL','SA04a') * 1.10;
PRODCOEFL_SA(AS,'CAPITAL','SA04b')         = PRODCOEFL_SA(AS,'CAPITAL','SA04b') * 1.075;
PRODCOEFL_SA(AS,'CAPITAL','SA05')         = PRODCOEFL_SA(AS,'CAPITAL','SA05') * 1.05;

PRODCOEFL_SA(AS,'LABOR','SA01')           = PRODCOEFL_SA(AS,'LABOR','SA01') * 1.25;
PRODCOEFL_SA(AS,'LABOR','SA03')           = PRODCOEFL_SA(AS,'LABOR','SA03') * 1.15;
PRODCOEFL_SA(AS,'LABOR','SA04a')           = PRODCOEFL_SA(AS,'LABOR','SA04a') * 1.10;
PRODCOEFL_SA(AS,'LABOR','SA04b')           = PRODCOEFL_SA(AS,'LABOR','SA04b') * 1.075;
PRODCOEFL_SA(AS,'LABOR','SA05')           = PRODCOEFL_SA(AS,'LABOR','SA05') * 1.05;

PRODCOEFL_SA(AS,'MISCCOST','SA01')        = PRODCOEFL_SA(AS,'MISCCOST','SA01') * 1.25;
PRODCOEFL_SA(AS,'MISCCOST','SA03')        = PRODCOEFL_SA(AS,'MISCCOST','SA03') * 1.15;
PRODCOEFL_SA(AS,'MISCCOST','SA04a')        = PRODCOEFL_SA(AS,'MISCCOST','SA04a') * 1.10;
PRODCOEFL_SA(AS,'MISCCOST','SA04b')        = PRODCOEFL_SA(AS,'MISCCOST','SA04b') * 1.075;
PRODCOEFL_SA(AS,'MISCCOST','SA05')        = PRODCOEFL_SA(AS,'MISCCOST','SA05') * 1.05;

* 6.3a Maybe change to this eventually:
*Set IPnorth(IP) / OTHERFEED, OTHRVARCST, CAPITAL, LABOR, MISCCOST /;
*PRODCOEFL_SA(AS,IPnorth,'SA01')  = PRODCOEFL_SA(AS,IPnorth,'SA01')  * 1.25;
*PRODCOEFL_SA(AS,IPnorth,'SA03')  = PRODCOEFL_SA(AS,IPnorth,'SA03')  * 1.15;
*PRODCOEFL_SA(AS,IPnorth,'SA04a') = PRODCOEFL_SA(AS,IPnorth,'SA04a') * 1.10;
*PRODCOEFL_SA(AS,IPnorth,'SA04b') = PRODCOEFL_SA(AS,IPnorth,'SA04b') * 1.075;
*PRODCOEFL_SA(AS,IPnorth,'SA05')  = PRODCOEFL_SA(AS,IPnorth,'SA05')  * 1.05;


* Increase weigth and age for livestock
PRODCOEFL_SA('DAIRYBULL1',IP,SA)           = PRODCOEFL_SA('DAIRYBULL1',IP,SA) * 1.15;
PRODCOEFL_SA('DAIRYBULL1','DCALFM',SA)     = 1;
PRODCOEFL_SA('DAIRYBULL2',IP,SA)           = PRODCOEFL_SA('DAIRYBULL2',IP,SA) * 1.15;
PRODCOEFL_SA('DAIRYBULL2','DCALFM',SA)     = 1;
PRODCOEFL_SA('BEEFCATTLE',IP,SA)           = PRODCOEFL_SA('BEEFCATTLE',IP,SA) * 1.15;
PRODCOEFL_SA('BEEFCATTLE','BEEFCFAC',SA)   = 1;
* Increase number of calves from beefcattle 10 %. More changes below
PRODCOEFL_SA('BEEFCATTLE',IP,SA)           = PRODCOEFL_SA('BEEFCATTLE',IP,SA) * 1.05;
PRODCOEFL_SA('BEEFCATTLE','SLGHBEEF',SA)   = PRODCOEFL_SA('BEEFCATTLE','SLGHBEEF',SA) * 1.10/1.05;
PRODCOEFL_SA('BEEFCATTLE','BEEFCFAC',SA)   = 1;

*add BEEFCATTL2
PRODCOEFL_SA('BEEFCATTL2',IP,SA)           = PRODCOEFL_SA('BEEFCATTLE',IP,SA);
PRODCOEFL_SA('BEEFCATTL2','SLGHBEEF',SA)   = PRODCOEFL_SA('BEEFCATTLE','SLGHBEEF',SA)   +0.6*0.016;
PRODCOEFL_SA('BEEFCATTL2','SILAGE',SA)     = PRODCOEFL_SA('BEEFCATTLE','SILAGE',SA)     +0.6*0.230;
PRODCOEFL_SA('BEEFCATTL2','GRASSPASTR',SA) = PRODCOEFL_SA('BEEFCATTLE','GRASSPASTR',SA) +0.6*1.300;
PRODCOEFL_SA('BEEFCATTL2','FEEDGRAIN',SA)  = PRODCOEFL_SA('BEEFCATTLE','FEEDGRAIN',SA)  -0.6*0.855;
PRODCOEFL_SA('BEEFCATTL2','OTHERFEED',SA)  = PRODCOEFL_SA('BEEFCATTLE','OTHERFEED',SA)  -0.6*0.088;
PRODCOEFL_SA('BEEFCATTL2','OTHRVARCST',SA) = PRODCOEFL_SA('BEEFCATTLE','OTHRVARCST',SA) +0.6*1.010;
PRODCOEFL_SA('BEEFCATTL2','CAPITAL',SA)    = PRODCOEFL_SA('BEEFCATTLE','CAPITAL',SA)    +0.6*4.000;
PRODCOEFL_SA('BEEFCATTL2','LABOR',SA)      = PRODCOEFL_SA('BEEFCATTLE','LABOR',SA)      +0.6*0.005;
PRODCOEFL_SA('BEEFCATTL2','BULLFAC',SA)    = PRODCOEFL_SA('BEEFCATTLE','BULLFAC',SA)    +0.6*0.67;
PRODCOEFL_SA('BEEFCATTL2','ACRMANURE',SA)  = PRODCOEFL_SA('BEEFCATTLE','ACRMANURE',SA)  +0.6*0.127;
*Feedgrain, other feed and silage are adjusted to avoid negative feed grain and other feed


*add SHEEP2 (Ewes without lambs) 
PRODCOEFL_SA('SHEEP2',IP,SA)          = PRODCOEFL_SA('SHEEP',IP,SA);
PRODCOEFL_SA('SHEEP2','SLGHSHEEP',SA) = 0;
PRODCOEFL_SA('SHEEP2','MISCRCPT',SA)  = 0;
PRODCOEFL_SA('SHEEP2','SILAGE',SA)    = PRODCOEFL_SA('SHEEP','SILAGE',SA) * 0.5;
PRODCOEFL_SA('SHEEP2','FEEDGRAIN',SA) = 0;
PRODCOEFL_SA('SHEEP2','OTHERFEED',SA) = 0;
PRODCOEFL_SA('SHEEP2','OTHRVARCST',SA)= PRODCOEFL_SA('SHEEP','OTHRVARCST',SA) * 0.5;
PRODCOEFL_SA('SHEEP2','CAPITAL',SA)   = PRODCOEFL_SA('SHEEP','CAPITAL',SA)    * 0.75;
PRODCOEFL_SA('SHEEP2','LABOR',SA)     = PRODCOEFL_SA('SHEEP','LABOR',SA)      * 0.5;
PRODCOEFL_SA('SHEEP2','NLEAKAGE',SA)  = PRODCOEFL_SA('SHEEP','NLEAKAGE',SA)  * 0.75;


*add coefficients for methane from livestock digestion (matsmaltningen)
PRODCOEFL_SA(DCOWS ,'CH4',SA)        = 0.1398;
PRODCOEFL_SA('HEIFER','CH4',SA)      = 0.0255 + 0.0637 * 13/12;
PRODCOEFL_SA('DAIRYBULL1','CH4',SA)  = 0.0255 + 0.0578 *  6/12;
PRODCOEFL_SA('DAIRYBULL2','CH4',SA)  = 0.0255 + 0.0637 * 13/12;
PRODCOEFL_SA('BEEFCATTLE','CH4',SA)  = 0.0915 + 0.0255*0.8*1.1 + 0.0637*0.2*1.1 + 0.0578*0.6*1.1* 6/12;
PRODCOEFL_SA('BEEFCATTL2','CH4',SA)  = 0.0915 + 0.0255*0.8*1.1 + 0.0637*0.2*1.1 + 0.0637*0.6*1.1*13/12;
PRODCOEFL_SA('SHEEP','CH4',SA)       = 0.008;
PRODCOEFL_SA('SHEEP2','CH4',SA)       = 0.008;
PRODCOEFL_SA('HORSES','CH4',SA)      = 0.018;
PRODCOEFL_SA('SOW1','CH4',SA)        = 0.0025;
PRODCOEFL_SA('SLGHSWINE1','CH4',SA)  = 0.0015 * 0.38;
PRODCOEFL_SA('ECOPIG','CH4',SA)      = 0.0025 + 0.0015*0.38*16;
PRODCOEFL_SA(AS,'CH4',SA)            = PRODCOEFL_SA(AS,'CH4',SA) * 1.11;

*Adds coefficients for methane from livestock manure
PRODCOEFL_SA(DCOWS ,'CH4',SA)        = PRODCOEFL_SA(DCOWS ,'CH4',SA)        + 0.00852;
PRODCOEFL_SA('HEIFER','CH4',SA)      = PRODCOEFL_SA('HEIFER','CH4',SA)      + 0.003 + 0.00652 * 13/12;
PRODCOEFL_SA('DAIRYBULL1','CH4',SA)  = PRODCOEFL_SA('DAIRYBULL1','CH4',SA)  + 0.003 + 0.00652 *  6/12;
PRODCOEFL_SA('DAIRYBULL2','CH4',SA)  = PRODCOEFL_SA('DAIRYBULL2','CH4',SA)  + 0.003 + 0.00929 * 13/12;
PRODCOEFL_SA('BEEFCATTLE','CH4',SA)  = PRODCOEFL_SA('BEEFCATTLE','CH4',SA)
                                    + 0.00893 + (0.003*0.8 + 0.00652*0.2 + 0.00652*0.6* 6/12)*1.10;
PRODCOEFL_SA('BEEFCATTL2','CH4',SA)  = PRODCOEFL_SA('BEEFCATTL2','CH4',SA)
                                    + 0.00893 + (0.003*0.8 + 0.00652*0.2 + 0.00929*0.6*13/12)*1.10;
PRODCOEFL_SA('SHEEP','CH4',SA)       = PRODCOEFL_SA('SHEEP','CH4',SA)       + 0.00019;
PRODCOEFL_SA('SHEEP2','CH4',SA)       = PRODCOEFL_SA('SHEEP2','CH4',SA)       + 0.00019;
PRODCOEFL_SA('HORSES','CH4',SA)      = PRODCOEFL_SA('HORSES','CH4',SA)      + 0.0014;
PRODCOEFL_SA('SOW1','CH4',SA)        = PRODCOEFL_SA('SOW1','CH4',SA)        + 0.00394;
PRODCOEFL_SA('SLGHSWINE1','CH4',SA)  = PRODCOEFL_SA('SLGHSWINE1','CH4',SA)  + 0.0015 * 0.38;
PRODCOEFL_SA('ECOPIG','CH4',SA)      = PRODCOEFL_SA('ECOPIG','CH4',SA)      + 0.00394 + 0.0015*0.38*16;
PRODCOEFL_SA('POULTRY','CH4',SA)     = PRODCOEFL_SA('POULTRY','CH4',SA)     + 0.08;
PRODCOEFL_SA('EPOULTRY','CH4',SA)    = PRODCOEFL_SA('EPOULTRY','CH4',SA)    + 0.08;
PRODCOEFL_SA('CHICKEN','CH4',SA)     = PRODCOEFL_SA('CHICKEN','CH4',SA)     + 0.04;

* Adds coefficients for nitrous oxide from livestock manure (lustgas)
PRODCOEFL_SA(DCOWS ,'N2O',SA)        = 0.021/1000*36;
PRODCOEFL_SA('HEIFER','N2O',SA)      = (0.017 + 0.018 * 13/12)/1000*11;
PRODCOEFL_SA('DAIRYBULL1','N2O',SA)  = (0.017 + 0.019 *  6/12)/1000*11;
PRODCOEFL_SA('DAIRYBULL2','N2O',SA)  = (0.017 + 0.022 * 13/12)/1000*11;
PRODCOEFL_SA('BEEFCATTLE','N2O',SA)  = (0.017 + (0.017*0.8 + 0.018*0.2 + 0.19*0.6* 6/12))*1.1/1000*11;
PRODCOEFL_SA('BEEFCATTL2','N2O',SA)  = (0.017 + (0.017*0.8 + 0.018*0.2 + 0.022*0.6*13/12))*1.1/1000*11;
PRODCOEFL_SA('SHEEP','N2O',SA)       = 0.024/1000*2;
PRODCOEFL_SA('SHEEP2','N2O',SA)      = 0.024/1000*2*0.75;
PRODCOEFL_SA('HORSES','N2O',SA)      = 0.021/1000*20;
PRODCOEFL_SA('SOW1','N2O',SA)        = 0.024/1000*3.7;
PRODCOEFL_SA('SLGHSWINE1','N2O',SA)  = (0.022 * 0.38)/1000*3.7;
PRODCOEFL_SA('ECOPIG','N2O',SA)      = (0.024 + 0.022*0.38*16)/1000*3.7;
PRODCOEFL_SA('POULTRY','N2O',SA)     = 0.016/1000*1000;
PRODCOEFL_SA('EPOULTRY','N2O',SA)    = 0.016/1000*1000;
PRODCOEFL_SA('CHICKEN','N2O',SA)     = 0.008/1000*1000;
* These data are uncertain. Based on data from Torben (SJV) but adjusted to give a reasonable level
* according to Statistics Sweden.
PRODCOEFL_SA(AS ,'N2O',SA)           = PRODCOEFL_SA(AS ,'N2O',SA)*2;
* Higher loss when using manure than mineral fertilizer

* Adds coefficients for ammonium
PRODCOEFL_SA(DCOWS ,'NH3',SA)        = 0.0377 * 1.051;
PRODCOEFL_SA('HEIFER','NH3',SA)      = (0.0112 + 0.0056 * 13/12);
PRODCOEFL_SA('DAIRYBULL1','NH3',SA)  = (0.0112 + 0.0056 *  6/12);
PRODCOEFL_SA('DAIRYBULL2','NH3',SA)  = (0.0112 + 0.0056 * 13/12);
PRODCOEFL_SA('BEEFCATTLE','NH3',SA)  = (0.0203 + (0.0056*0.8 + 0.0112*0.2 + 0.0112*0.6* 6/12))*1.1;
PRODCOEFL_SA('BEEFCATTL2','NH3',SA)  = (0.0203 + (0.0056*0.8 + 0.0112*0.2 + 0.0112*0.6*13/12))*1.1;
PRODCOEFL_SA('SHEEP','NH3',SA)       = 0.0203*12/63;
PRODCOEFL_SA('SHEEP2','NH3',SA)       = 0.0203*12/63;
PRODCOEFL_SA('HORSES','NH3',SA)      = 0.0203*50/63;
PRODCOEFL_SA('SOW1','NH3',SA)        = 0.0123;
PRODCOEFL_SA('SLGHSWINE1','NH3',SA)  = (0.004 * 0.38);
PRODCOEFL_SA('ECOPIG','NH3',SA)      = (0.0123 + 0.004*0.38*16);
PRODCOEFL_SA('POULTRY','NH3',SA)     = 0.640;
PRODCOEFL_SA('EPOULTRY','NH3',SA)    = 0.640;
PRODCOEFL_SA('CHICKEN','NH3',SA)     = 0.377;
* Data from Magnus Bong (from SCB), "Jordbruksstatistisk sammanstallning"
*   and "Databok driftsplanering 2009"
*PRODCOEFL(AS,'NH3',SR) = PRODCOEFL(AS,'NH3',SR)
*                         + (PRODCOEFL(AS,'NITROGEN',SR)+PRODCOEFL(AS,'ECON',SR)) *  0.0281;
*PRODCOEFC(AS,'NH3',SR) = PRODCOEFC(AS,'NH3',SR)
*                         + (PRODCOEFC(AS,'NITROGEN',SR)+PRODCOEFC(AS,'ECON',SR)) *  0.0281;                         
* Ammoniun from fertilizers (total N - N from manure). Loss of NH3 is 2,81 % of N
* Data from "Jordbruksstatistisk sammanstallning"

PRODCOEFL_SA(DCOWS ,'MILK',SA)        = PRODCOEFL_SA(DCOWS,'MILK',SA) * 1.0825 * 1.05;
PRODCOEFL_SA(DCOWS,'FEEDGRAIN',SA)    = PRODCOEFL_SA(DCOWS,'FEEDGRAIN',SA) * 1.0825 * 1.05;
PRODCOEFL_SA(DCOWS,'OTHERFEED',SA)    = PRODCOEFL_SA(DCOWS,'OTHERFEED',SA) * 1.0825 * 1.05;

*PRODCOEFL_SA('SOW1','PIGLETS',SA)      = PRODCOEFL_SA('SOW1','PIGLETS',SA) * 1.045;
*PRODCOEFL_SA('SOW1','FEEDGRAIN',SA)    = PRODCOEFL_SA('SOW1','FEEDGRAIN',SA) * 1.045;
*PRODCOEFL_SA('SOW1','OTHERFEED',SA)    = PRODCOEFL_SA('SOW1','OTHERFEED',SA) * 1.045;

PRODCOEFL_SA('SLGHSWINE1','SLGHPORK',SA)     = PRODCOEFL_SA('SLGHSWINE1','SLGHPORK',SA)  * 1.036;
PRODCOEFL_SA('SLGHSWINE1','FEEDGRAIN',SA)    = PRODCOEFL_SA('SLGHSWINE1','FEEDGRAIN',SA) * 1.036;
PRODCOEFL_SA('SLGHSWINE1','OTHERFEED',SA)    = PRODCOEFL_SA('SLGHSWINE1','OTHERFEED',SA) * 1.;

PRODCOEFL_SA('BEEFCATTLE','LABOR',SA)    = PRODCOEFL_SA('BEEFCATTLE','LABOR',SA) * 0.8;
PRODCOEFL_SA('BEEFCATTL2','LABOR',SA)    = PRODCOEFL_SA('BEEFCATTL2','LABOR',SA) * 0.8;
* --- END of PRODCOEF calculations



* --- Create missing SA entries in PRODCOEFC_SA (these SAs are not in Excel at all) ---
PRODCOEFC_SA(AS,IP,'SA02') = (2*PRODCOEFC_SA(AS,IP,'SA01') + PRODCOEFC_SA(AS,IP,'SA03'))/3;
PRODCOEFC_SA(AS,IP,'SA06a') = PRODCOEFC_SA(AS,IP,'SA05');
PRODCOEFC_SA(AS,IP,'SA06b') = PRODCOEFC_SA(AS,IP,'SA07b');
PRODCOEFC_SA(AS,IP,'SA10') = (2*PRODCOEFC_SA(AS,IP,'SA07b') + PRODCOEFC_SA(AS,IP,'SA09'))/3;
PRODCOEFC_SA(AS,IP,'SA11') = PRODCOEFC_SA(AS,IP,'SA07b');
PRODCOEFC_SA(AS,IP,'SA12') = PRODCOEFC_SA(AS,IP,'SA07b');
PRODCOEFC_SA(AS,IP,'SA13gsk') = PRODCOEFC_SA(AS,IP,'SA13ssk');

* --- Create missing SA entries in PRODCOEFL_SA (not in Excel at all) ---
PRODCOEFL_SA(AS,IP,'SA02') = (2*PRODCOEFL_SA(AS,IP,'SA01') + PRODCOEFL_SA(AS,IP,'SA03'))/3;
PRODCOEFL_SA(AS,IP,'SA06a') = PRODCOEFL_SA(AS,IP,'SA05');
PRODCOEFL_SA(AS,IP,'SA06b') = PRODCOEFL_SA(AS,IP,'SA07b');
PRODCOEFL_SA(AS,IP,'SA07a') = PRODCOEFL_SA(AS,IP,'SA05');
PRODCOEFL_SA(AS,IP,'SA10') = (2*PRODCOEFL_SA(AS,IP,'SA07b') + PRODCOEFL_SA(AS,IP,'SA09'))/3;
PRODCOEFL_SA(AS,IP,'SA11') = PRODCOEFL_SA(AS,IP,'SA07b');
PRODCOEFL_SA(AS,IP,'SA12') = PRODCOEFL_SA(AS,IP,'SA07b');
PRODCOEFL_SA(AS,IP,'SA13ssk') = PRODCOEFL_SA(AS,IP,'SA13ss');
PRODCOEFL_SA(AS,IP,'SA13gsk') = PRODCOEFL_SA(AS,IP,'SA13ss');
PRODCOEFL_SA(AS,IP,'SA13gns') = PRODCOEFL_SA(AS,IP,'SA13ss');
PRODCOEFL_SA(AS,IP,'SA13gmb') = PRODCOEFL_SA(AS,IP,'SA13gss');



**======================
* Combination of PRODCOEFC, PRODCOEFC2 and PRODCOEFL into a single parameter PRODCOEF

* --- Recode PRODCOEFC_SA, PRODCOEFC2_PO and PRODCOEFL_SA to SR level
PRODCOEFC_SR(AS,IP,SR) = sum(SA$SASR_prod(SA,SR), PRODCOEFC_SA(AS,IP,SA));
PRODCOEFC2_SR(AS,IP,SR) = sum(PO$POSR(PO,SR), PRODCOEFC2_PO(AS,IP,PO));
PRODCOEFL_SR(AS,IP,SR) = sum(SA$SASR_prod(SA,SR), PRODCOEFL_SA(AS,IP,SA));

* --- Combine these to PRODCOEF
PRODCOEF(AS,IP,SR) = PRODCOEFC_SR(AS,IP,SR)
                   + PRODCOEFC2_SR(AS,IP,SR)
                   + PRODCOEFL_SR(AS,IP,SR);

* --- Calculations of PRODCOEF
PRODCOEF('CHICKEN',IP,SR) = PRODCOEF('CHICKEN',IP,'SR001');

* Adjust production data for productivity development från 2017 until year 2025
* Average 2011-2014 divided by average 2005-2008 for milk and piglets milk as EU average
PRODCOEF(CROPS ,'BREADGRAIN',SR)  = PRODCOEF(CROPS,'BREADGRAIN',SR) * prodGrowthYields**8;
PRODCOEF(CROPS ,'COARSGRAIN',SR)  = PRODCOEF(CROPS,'COARSGRAIN',SR) * prodGrowthYields**8;
PRODCOEF(CROPS ,'GSILAGE',SR)     = PRODCOEF(CROPS,'GSILAGE',SR)    * prodGrowthYields**8;
PRODCOEF(CROPS ,'MSILAGE',SR)     = PRODCOEF(CROPS,'MSILAGE',SR)    * prodGrowthYields**8;
PRODCOEF(CROPS ,'OILGRAIN',SR)    = PRODCOEF(CROPS,'OILGRAIN',SR)   * prodGrowthYields**8;
PRODCOEF(CROPS ,'POTATOES',SR)    = PRODCOEF(CROPS,'POTATOES',SR)   * prodGrowthYields**8;
PRODCOEF(CROPS ,'SUGARBEET',SR)   = PRODCOEF(CROPS,'SUGARBEET',SR)  * prodGrowthYields**8;
PRODCOEF(CROPS ,'SILAGE',SR)      = PRODCOEF(CROPS,'SILAGE',SR)     * prodGrowthYields**8;
PRODCOEF(CROPS ,'GRASSPASTR',SR)  = PRODCOEF(CROPS,'GRASSPASTR',SR) * prodGrowthYields**8;
PRODCOEF('SALIX','SALIXMJ',SR)    = PRODCOEF('SALIX','SALIXMJ',SR)  * prodGrowthYields**8;

PRODCOEF(GRAINS ,FERT,SR)  = PRODCOEF(GRAINS,FERT,SR) * prodGrowthYields**8;
PRODCOEF(OILGRAINS, FERT,SR)  = PRODCOEF(OILGRAINS, FERT,SR) * prodGrowthYields**8;
PRODCOEF('POTATO', FERT,SR)  = PRODCOEF('POTATO', FERT,SR) * prodGrowthYields**8;
PRODCOEF('SUGAR', FERT,SR)  = PRODCOEF('SUGAR', FERT,SR) * prodGrowthYields**8;

PRODCOEF(DCOWS ,'MILK',SR)        = PRODCOEF(DCOWS,'MILK',SR) * 1.010**8;
PRODCOEF(DCOWS,'FEEDGRAIN',SR)    = PRODCOEF(DCOWS,'FEEDGRAIN',SR) * 1.010**8;
PRODCOEF(DCOWS,'OTHERFEED',SR)    = PRODCOEF(DCOWS,'OTHERFEED',SR) * 1.010**8;
*PRODCOEF('SOW1','PIGLETS',SR)     = PRODCOEF('SOW1','PIGLETS',SR)* 1.015**8;
PRODCOEF('POULTRY','EGG',SR)     = PRODCOEF('POULTRY','EGG',SR)* 1.010**8;
PRODCOEF('EPOULTRY','EGG',SR)     = PRODCOEF('EPOULTRY','EGG',SR)* 1.010**8;

* Adjust yields to productivity development, 0,5 % per year for yields and 
* average 2011-2014 divided by average 2005-2008 for milk and piglets milk as EU average
PRODCOEF(CROPS ,'BREADGRAIN',SR) $(LONGRUN2) = PRODCOEF(CROPS,'BREADGRAIN',SR) * prodGrowthYields**YRT;
PRODCOEF(CROPS ,'COARSGRAIN',SR) $(LONGRUN2) = PRODCOEF(CROPS,'COARSGRAIN',SR) * prodGrowthYields**YRT;
PRODCOEF(CROPS ,'GSILAGE',SR) $(LONGRUN2)    = PRODCOEF(CROPS,'GSILAGE',SR)    * prodGrowthYields**YRT;
PRODCOEF(CROPS ,'MSILAGE',SR) $(LONGRUN2)    = PRODCOEF(CROPS,'MSILAGE',SR)    * prodGrowthYields**YRT;
PRODCOEF(CROPS ,'OILGRAIN',SR) $(LONGRUN2)   = PRODCOEF(CROPS,'OILGRAIN',SR)   * prodGrowthYields**YRT;
PRODCOEF(CROPS ,'POTATOES',SR) $(LONGRUN2)   = PRODCOEF(CROPS,'POTATOES',SR)   * prodGrowthYields**YRT;
PRODCOEF(CROPS ,'SUGARBEET',SR) $(LONGRUN2)  = PRODCOEF(CROPS,'SUGARBEET',SR)  * prodGrowthYields**YRT;
PRODCOEF(CROPS ,'SILAGE',SR) $(LONGRUN2)     = PRODCOEF(CROPS,'SILAGE',SR)     * prodGrowthYields**YRT;
PRODCOEF(CROPS ,'GRASSPASTR',SR) $(LONGRUN2) = PRODCOEF(CROPS,'GRASSPASTR',SR) * prodGrowthYields**YRT;
PRODCOEF('SALIX','SALIXMJ',SR) $(LONGRUN2)   = PRODCOEF('SALIX','SALIXMJ',SR)  * prodGrowthYields**YRT;

PRODCOEF(GRAINS ,FERT,SR) $(LONGRUN2) = PRODCOEF(GRAINS,FERT,SR) * prodGrowthYields**YRT;
PRODCOEF(OILGRAINS, FERT,SR) $(LONGRUN2) = PRODCOEF(OILGRAINS, FERT,SR) * prodGrowthYields**YRT;
PRODCOEF('POTATO', FERT,SR) $(LONGRUN2) = PRODCOEF('POTATO', FERT,SR) * prodGrowthYields**YRT;
PRODCOEF('SUGAR', FERT,SR) $(LONGRUN2) = PRODCOEF('SUGAR', FERT,SR) * prodGrowthYields**YRT;

PRODCOEF(DCOWS ,'MILK',SR) $(LONGRUN2)       = PRODCOEF(DCOWS,'MILK',SR) * prodGrowthYields**YRT;
PRODCOEF(DCOWS,'FEEDGRAIN',SR) $(LONGRUN2)   = PRODCOEF(DCOWS,'FEEDGRAIN',SR) * prodGrowthYields**YRT;
PRODCOEF(DCOWS,'OTHERFEED',SR) $(LONGRUN2)   = PRODCOEF(DCOWS,'OTHERFEED',SR) * prodGrowthYields**YRT;
PRODCOEF(BEEFCAT,'SLGHBEEF',SR) $(LONGRUN2)  = PRODCOEF(BEEFCAT,'SLGHBEEF',SR) * prodGrowthYields**YRT;
PRODCOEF(BEEFCAT,'FEEDGRAIN',SR) $(LONGRUN2) = PRODCOEF(BEEFCAT,'FEEDGRAIN',SR) * prodGrowthYields**YRT;
PRODCOEF(BEEFCAT,'OTHERFEED',SR) $(LONGRUN2) = PRODCOEF(BEEFCAT,'OTHERFEED',SR) * prodGrowthYields**YRT;
PRODCOEF('SOW1','PIGLETS',SR) $(LONGRUN2)    = PRODCOEF('SOW1','PIGLETS',SR)* 1.015**YRT;
PRODCOEF('POULTRY','EGG',SR) $(LONGRUN2)     = PRODCOEF('POULTRY','EGG',SR)* 1.010**YRT;
PRODCOEF('EPOULTRY','EGG',SR) $(LONGRUN2)    = PRODCOEF('EPOULTRY','EGG',SR)* 1.010**YRT;
* Milk adjusted to OECD

* Adjusts labour in new buildings
PRODCOEF('DAIRYFEXN','LABOR',SR)   = -PRODCOEF('DCOW1','LABOR',SR) * 0.2;
PRODCOEF('DAIRYFEXR','LABOR',SR)   = -PRODCOEF('DCOW1','LABOR',SR) * 0.1;
PRODCOEF('BULLFEXN','LABOR',SR)    = -PRODCOEF('DAIRYBULL1','LABOR',SR) * 0.2 /1.5;
PRODCOEF('BULLFEXR','LABOR',SR)    = -PRODCOEF('DAIRYBULL1','LABOR',SR) * 0.1 /1.5;
PRODCOEF('BEEFCFEXN','LABOR',SR)   = -PRODCOEF('BEEFCATTLE','LABOR',SR) * 0.10;
PRODCOEF('BEEFCFEXR','LABOR',SR)   = -PRODCOEF('BEEFCATTLE','LABOR',SR) * 0.05;
PRODCOEF('SOWFEXN','LABOR',SR)     = -PRODCOEF('SOW1','LABOR',SR) * 0.2;
PRODCOEF('SOWFEXR','LABOR',SR)     = -PRODCOEF('SOW1','LABOR',SR) * 0.1;
PRODCOEF('SWINEFEXN','LABOR',SR)   = -PRODCOEF('SLGHSWINE1','LABOR',SR) * 0.2 /0.38;
PRODCOEF('SWINEFEXR','LABOR',SR)   = -PRODCOEF('SLGHSWINE1','LABOR',SR) * 0.1 /0.38;
PRODCOEF('PLTRYFEXN','LABOR',SR)   = -PRODCOEF('POULTRY','LABOR',SR) * 0.2;
PRODCOEF('PLTRYFEXR','LABOR',SR)   = -PRODCOEF('POULTRY','LABOR',SR) * 0.1;

* Adjusts coef for dairy and beef cattle production, update, lower meat price, capital, feed and livestock 
PRODCOEF(DCOWS,'BETFOR',SR)            = PRODCOEF(DCOWS,'BETFOR',SR) * 0.94;
PRODCOEF(DCOWS,'SOJA',SR)              = PRODCOEF(DCOWS,'SOJA',SR) * 0.94;
PRODCOEF(DCOWS,'RAPEMEAL',SR)          = PRODCOEF(DCOWS,'RAPEMEAL',SR) * 0.94;
PRODCOEF(DCOWS,'OTHERFEED',SR)         = PRODCOEF(DCOWS,'OTHERFEED',SR) * 0.94;
PRODCOEF(DCOWS,'OTHRVARCST',SR)        = PRODCOEF(DCOWS,'OTHRVARCST',SR) * 4;
PRODCOEF(DCOWS,'OTHRVARCST',SR)        = PRODCOEF(DCOWS,'OTHRVARCST',SR) - 4.000;
PRODCOEF(DCOWS,'CAPITAL',SR)           = PRODCOEF(DCOWS,'CAPITAL',SR) + 8.000;

PRODCOEF('HEIFER','OTHRVARCST',SR)     = PRODCOEF('HEIFER','OTHRVARCST',SR) * 1.5;
PRODCOEF('HEIFER','CAPITAL',SR)        = PRODCOEF('HEIFER','CAPITAL',SR)    + 2.000;

PRODCOEF('BEEFCATTLE','SILAGE',SR)     = PRODCOEF('BEEFCATTLE','SILAGE',SR) - 0.800;
PRODCOEF('BEEFCATTLE','OTHERFEED',SR)  = PRODCOEF('BEEFCATTLE','OTHERFEED',SR) * 0;
PRODCOEF('BEEFCATTLE','LABOR',SR)      = PRODCOEF('BEEFCATTLE','LABOR',SR) * 0.75;
PRODCOEF('BEEFCATTL2','SILAGE',SR)     = PRODCOEF('BEEFCATTL2','SILAGE',SR) - 0.800;
PRODCOEF('BEEFCATTL2','OTHERFEED',SR)  = PRODCOEF('BEEFCATTL2','OTHERFEED',SR) * 0;
PRODCOEF('BEEFCATTL2','LABOR',SR)      = PRODCOEF('BEEFCATTL2','LABOR',SR) * 0.75;

PRODCOEF('DAIRYBULL1','LABOR',SR)      = PRODCOEF('DAIRYBULL1','LABOR',SR) * 0.75;
PRODCOEF('DAIRYBULL2','LABOR',SR)      = PRODCOEF('DAIRYBULL2','LABOR',SR) * 0.75;

* High Quality silage needed for dairy cows
PRODCOEF(DCOWS,'SILAGEHQ',SR)     = PRODCOEF(DCOWS,'SILAGE',SR);

* Separate hay from silage for other livestock than dairy cows
PRODCOEF('HEIFER','HAY',SR)       = PRODCOEF('HEIFER','SILAGE',SR)     * 0.25/0.84;
PRODCOEF('HEIFER','SILAGE',SR)    = PRODCOEF('HEIFER','SILAGE',SR)     * 0.75;
PRODCOEF('DAIRYBULL1','HAY',SR)   = PRODCOEF('DAIRYBULL1','SILAGE',SR) * 0.25/0.84;
PRODCOEF('DAIRYBULL1','SILAGE',SR)= PRODCOEF('DAIRYBULL1','SILAGE',SR) * 0.75;
PRODCOEF('DAIRYBULL2','HAY',SR)   = PRODCOEF('DAIRYBULL2','SILAGE',SR) * 0.25/0.84;
PRODCOEF('DAIRYBULL2','SILAGE',SR)= PRODCOEF('DAIRYBULL2','SILAGE',SR) * 0.75;
PRODCOEF('BEEFCATTLE','HAY',SR)   = PRODCOEF('BEEFCATTLE','SILAGE',SR) * 0.25/0.84;
PRODCOEF('BEEFCATTLE','SILAGE',SR)= PRODCOEF('BEEFCATTLE','SILAGE',SR) * 0.75;
PRODCOEF('BEEFCATTL2','HAY',SR)   = PRODCOEF('BEEFCATTL2','SILAGE',SR) * 0.25/0.84;
PRODCOEF('BEEFCATTL2','SILAGE',SR)= PRODCOEF('BEEFCATTL2','SILAGE',SR) * 0.75;
PRODCOEF('SHEEP','HAY',SR)        = PRODCOEF('SHEEP','SILAGE',SR)      * 0.25/0.84;
PRODCOEF('SHEEP','SILAGE',SR)     = PRODCOEF('SHEEP','SILAGE',SR)      * 0.75;
PRODCOEF('SHEEP2','HAY',SR)        = PRODCOEF('SHEEP2','SILAGE',SR)      * 0.25/0.84;
PRODCOEF('SHEEP2','SILAGE',SR)     = PRODCOEF('SHEEP2','SILAGE',SR)      * 0.75;
PRODCOEF('HORSES','HAY',SR)       = PRODCOEF('HORSES','SILAGE',SR)     * 0.75/0.84;
PRODCOEF('HORSES','SILAGE',SR)    = PRODCOEF('HORSES','SILAGE',SR)     * 0.25;

* Change other feed from quantity to value
PRODCOEF('DAIRYBULL1','OTHERFEED',SR) = PRODCOEF('DAIRYBULL1','OTHERFEED',SR) * 2.2;
PRODCOEF('DAIRYBULL2','OTHERFEED',SR) = PRODCOEF('DAIRYBULL2','OTHERFEED',SR) * 2.2;
PRODCOEF('BEEFCATTLE','OTHERFEED',SR) = PRODCOEF('BEEFCATTLE','OTHERFEED',SR) * 2.2;
PRODCOEF('BEEFCATTL2','OTHERFEED',SR) = PRODCOEF('BEEFCATTL2','OTHERFEED',SR) * 2.2;

PRODCOEF('SHEEP','OTHERFEED',SR) = PRODCOEF('SHEEP','OTHERFEED',SR) * 2.9;
PRODCOEF('SHEEP2','OTHERFEED',SR) = PRODCOEF('SHEEP2','OTHERFEED',SR) * 2.9;

* Separate protein feed from otherfeed, back to volyme. Part remines (minerals etc)
PRODCOEF(LIVESTOCK,'PROTFEED',SR)  = PRODCOEF(LIVESTOCK,'OTHERFEED',SR) * 0.67 / 2.2;
PRODCOEF(LIVESTOCK,'OTHERFEED',SR) = PRODCOEF(LIVESTOCK,'OTHERFEED',SR) * 0.33;

*Adjust for over capacity of machinery
PRODCOEF('LAY','OTHRVARCST',SR)        = PRODCOEF('LAY','OTHRVARCST',SR) + 50*0.011;

* Calculate coefficients for feed peas
PRODCOEF('FEEDPEAS','PEAS',SR)      = PRODCOEF('BARLEY','COARSGRAIN',SR)    * 0.70;
PRODCOEF('FEEDPEAS','NITROGEN',SR)  = 0;
PRODCOEF('FEEDPEAS','PHOSPHORUS',SR)= -PRODCOEF('FEEDPEAS','PEAS',SR) * 0.0036;
PRODCOEF('FEEDPEAS','POTASSIUM',SR) = -PRODCOEF('FEEDPEAS','PEAS',SR) * 0.0100;
PRODCOEF('FEEDPEAS','PESTICIDES',SR)= PRODCOEF('BARLEY','PESTICIDES',SR) * 2;
PRODCOEF('FEEDPEAS','POWER',SR)     = PRODCOEF('BARLEY','POWER',SR) + 0.002;
PRODCOEF('FEEDPEAS','OTHRVARCST',SR)= PRODCOEF('BARLEY','OTHRVARCST',SR) + 1.950 - 0.200;
PRODCOEF('FEEDPEAS','CAPITAL',SR)   = PRODCOEF('BARLEY','CAPITAL',SR);
PRODCOEF('FEEDPEAS','LABOR',SR)     = PRODCOEF('BARLEY','LABOR',SR) + 0.002;
PRODCOEF('FEEDPEAS','NLEAKAGE',SR)  = PRODCOEF('BARLEY','NLEAKAGE',SR);
PRODCOEF('FEEDPEAS','PLEAKAGE',SR)  = PRODCOEF('BARLEY','PLEAKAGE',SR);
PRODCOEF('FEEDPEAS','INCONVPRO',SR) = 1;


* Separates grazing on arable land from permanent pasture
PRODCOEF(DCOWS,'GRASSPASTF',SR)        = PRODCOEF(DCOWS,'GRASSPASTR',SR)        * 0.75;
PRODCOEF('HEIFER','GRASSPASTF',SR)     = PRODCOEF('HEIFER','GRASSPASTR',SR)     * 0.25;
PRODCOEF('DAIRYBULL1','GRASSPASTF',SR) = PRODCOEF('DAIRYBULL1','GRASSPASTR',SR) * 0.4;
PRODCOEF('DAIRYBULL2','GRASSPASTF',SR) = PRODCOEF('DAIRYBULL2','GRASSPASTR',SR) * 0.4;
PRODCOEF('BEEFCATTLE','GRASSPASTF',SR) = PRODCOEF('BEEFCATTLE','GRASSPASTR',SR) * 0.2;
PRODCOEF('BEEFCATTL2','GRASSPASTF',SR) = PRODCOEF('BEEFCATTL2','GRASSPASTR',SR) * 0.15;
PRODCOEF('SHEEP','GRASSPASTF',SR)      = PRODCOEF('SHEEP','GRASSPASTR',SR)      * 0.2;
PRODCOEF('SHEEP2','GRASSPASTF',SR)      = PRODCOEF('SHEEP2','GRASSPASTR',SR)      * 0;
PRODCOEF('HORSES','GRASSPASTF',SR)     = PRODCOEF('HORSES','GRASSPASTR',SR)     * 0.5;

* Makes 25 percent of rye production into feed grain
* and includes the price difference compared to wheat
PRODCOEF('W-RAY','COARSGRAIN',SR) = PRODCOEF('W-RAY','BREADGRAIN',SR) * 0.25;  
PRODCOEF('W-RAY','BREADGRAIN',SR) = PRODCOEF('W-RAY','BREADGRAIN',SR) * 0.75;  
PRODCOEF('W-RAY','MISCCOST',SR)  = PRODCOEF('W-RAY','MISCCOST',SR) 
        -PRODCOEF('W-RAY','BREADGRAIN',SR) * 0.35 -PRODCOEF('W-RAY','COARSGRAIN',SR) * 0.10;  

* Separates seed from other variable costs
PRODCOEF('W-RAPE','OILGRSEED',SR)  = 0.00033;
PRODCOEF('W-RAPE','OTHRVARCST',SR) = PRODCOEF('W-RAPE','OTHRVARCST',SR) - 0.766;
PRODCOEF('S-RAPE','OILGRSEED',SR)  = 0.00071;
PRODCOEF('S-RAPE','OTHRVARCST',SR) = PRODCOEF('S-RAPE','OTHRVARCST',SR) - 1.714;
PRODCOEF('FEEDPEAS','PEASSEED',SR) = 0.015;
PRODCOEF('FEEDPEAS','OTHRVARCST',SR) = PRODCOEF('FEEDPEAS','OTHRVARCST',SR) - 1.950;
PRODCOEF('SUGAR','SUGARBSEED',SR)   = 0.00104;
PRODCOEF('SUGAR','OTHRVARCST',SR) = PRODCOEF('SUGAR','OTHRVARCST',SR) - 2.602;
PRODCOEF('POTATO','POTATOSEED',SR)  = 2.500/ 0.995**YRT;
*PRODCOEF('POTATO','OTHRVARCST',SR) = PRODCOEF('POTATO','OTHRVARCST',SR) - 18.975 ;
* Data from Hush 2023. SEED seems not to be included in other costs for potatoes
* 0.300 added to feed peas to avoid negative "other costs"
 
* Adds wheat in subreg 4a
PRODCOEF('W-WHEAT',IP, 'SR009') = PRODCOEF('W-WHEAT',IP,'SR010');  

* Makes acreage of long laying forage standard in subreg 1, 2, 3, 4a and 7b
PRODCOEF('FORAGE1','SILAGE',SA01TO04a)     = PRODCOEF('FORAGE1','SILAGE',SA01TO04a)     /0.80;
PRODCOEF('FORAGE2','SILAGE',SA01TO04a)     = PRODCOEF('FORAGE2','SILAGE',SA01TO04a)     /0.80;
PRODCOEF('FORAGE2','GRASSPASTR',SA01TO04a) = PRODCOEF('FORAGE2','GRASSPASTR',SA01TO04a) /0.80;
PRODCOEF('PASTURE1','GRASSPASTR',SA01TO04a)= PRODCOEF('PASTURE1','GRASSPASTR',SA01TO04a)/0.80;
PRODCOEF('PASTURE2','GRASSPASTR',SA01TO04a)= PRODCOEF('PASTURE2','GRASSPASTR',SA01TO04a)/0.80;
PRODCOEF('PPASTR','GRASSPASTR',SA01TO04a)  = PRODCOEF('PPASTR','GRASSPASTR',SA01TO04a)  /0.80;

PRODCOEF('FORAGE1','SILAGE',SR)$SASR_prod('SA07b',SR) = PRODCOEF('FORAGE1','SILAGE',SR)            / 0.90;
PRODCOEF('FORAGE2','SILAGE',SR)$SASR_prod('SA07b',SR) = PRODCOEF('FORAGE2','SILAGE',SR)            / 0.90;
PRODCOEF('FORAGE2','GRASSPASTR',SR)$SASR_prod('SA07b',SR) = PRODCOEF('FORAGE2','GRASSPASTR',SR)    / 0.90;
PRODCOEF('PASTURE1','GRASSPASTR',SR)$SASR_prod('SA07b',SR) = PRODCOEF('PASTURE1','GRASSPASTR',SR)  / 0.90;
PRODCOEF('PASTURE2','GRASSPASTR',SR)$SASR_prod('SA07b',SR) = PRODCOEF('PASTURE2','GRASSPASTR',SR)  / 0.90;
PRODCOEF('PPASTR','GRASSPASTR',SR)$SASR_prod('SA07b',SR) = PRODCOEF('PPASTR','GRASSPASTR',SR)      / 0.90;

*PRODCOEF('FORAGE1','SILAGE',SR07b)       = PRODCOEF('FORAGE1','SILAGE',SR07b)     /0.90;
*PRODCOEF('FORAGE2','SILAGE',SR07b)       = PRODCOEF('FORAGE2','SILAGE',SR07b)     /0.90;
*PRODCOEF('FORAGE2','GRASSPASTR',SR07b)   = PRODCOEF('FORAGE2','GRASSPASTR',SR07b) /0.90;
*PRODCOEF('PASTURE1','GRASSPASTR',SR07b  )= PRODCOEF('PASTURE1','GRASSPASTR',SR07b)/0.90;
*PRODCOEF('PASTURE2','GRASSPASTR',SR07b)  = PRODCOEF('PASTURE2','GRASSPASTR',SR07b)/0.90;
*PRODCOEF('PPASTR','GRASSPASTR',SR07b)    = PRODCOEF('PPASTR','GRASSPASTR',SR07b)  /0.90;

* Calculate coefficients for long laying forage, extensive forage and new forage
PRODCOEF('FORAGE3',IP,SR)          = PRODCOEF('FORAGE1',IP,SR);
PRODCOEF('FORAGE3','SILAGE',SR)    = PRODCOEF('FORAGE1','SILAGE',SR)    * 0.80;
PRODCOEF('FORAGE3','LABOR',SR)     = PRODCOEF('FORAGE1','LABOR',SR)     * 0.80;
PRODCOEF('FORAGE3','POWER',SR)     = PRODCOEF('FORAGE1','POWER',SR)     * 0.80;
PRODCOEF('FORAGE3','OTHRVARCST',SR)= PRODCOEF('FORAGE1','OTHRVARCST',SR)* 0.80;
PRODCOEF('FORAGE3','CAPITAL',SR)   = PRODCOEF('FORAGE1','CAPITAL',SR)   * 0.80;
PRODCOEF('FORAGE3','NLEAKAGE',SR) = PRODCOEF('PASTURE2','NLEAKAGE',SR);
PRODCOEF('FORAGE3','PLEAKAGE',SR) = PRODCOEF('PASTURE2','PLEAKAGE',SR);

PRODCOEF('FORAGE4',IP,SR)          = PRODCOEF('FORAGE1',IP,SR);
PRODCOEF('FORAGE4','SILAGE',SR)    = PRODCOEF('FORAGE1','SILAGE',SR)    * 0.50;
PRODCOEF('FORAGE4','LABOR',SR)     = PRODCOEF('FORAGE1','LABOR',SR)     * 0.50;
PRODCOEF('FORAGE4','POWER',SR)     = PRODCOEF('FORAGE1','POWER',SR)     * 0.50;
PRODCOEF('FORAGE4','OTHRVARCST',SR)= PRODCOEF('FORAGE1','OTHRVARCST',SR)* 0.50;
PRODCOEF('FORAGE4','CAPITAL',SR)   = PRODCOEF('FORAGE1','CAPITAL',SR)   * 0.50;
PRODCOEF('FORAGE4','NLEAKAGE',SR) = PRODCOEF('PPASTR','NLEAKAGE',SR);
PRODCOEF('FORAGE4','PLEAKAGE',SR) = PRODCOEF('PPASTR','PLEAKAGE',SR);

PRODCOEF('NEWFOR','LABOR',SR)      = PRODCOEF('BARLEY','LABOR',SR) * 0.5;
PRODCOEF('NEWFOR','POWER',SR)      = PRODCOEF('BARLEY','POWER',SR) * 0.5;
PRODCOEF('NEWFOR','NLEAKAGE',SR)  = PRODCOEF('FORAGE1','NLEAKAGE',SR);
PRODCOEF('NEWFOR','PLEAKAGE',SR)  = PRODCOEF('FORAGE1','PLEAKAGE',SR);

* Adjust forage and pasture grass yields for losses
PRODCOEF(CROPS,'SILAGE',SR)          = PRODCOEF(CROPS,'SILAGE',SR)    * 0.85;
PRODCOEF(CROPS,'GSILAGE',SR)         = PRODCOEF(CROPS,'GSILAGE',SR)   * 0.85;
PRODCOEF(CROPS,'MSILAGE',SR)         = PRODCOEF(CROPS,'MSILAGE',SR)   * 0.85;
PRODCOEF(CROPS,'GRASSPASTR',SR)      = PRODCOEF(CROPS,'GRASSPASTR',SR)* 0.85;
PRODCOEF('PPASTR','GRASSPASTR',SR)   = PRODCOEF('PPASTR','GRASSPASTR',SR)* 0.85;

* Make forage1 and 2 produce high quality
PRODCOEF('FORAGE1','SILAGEHQ',SR)          = PRODCOEF('FORAGE1','SILAGE',SR);
PRODCOEF('FORAGE2','SILAGEHQ',SR)          = PRODCOEF('FORAGE2','SILAGE',SR);

* Include fertilizers for forage, pasture and salix
PRODCOEF(FEEDACR,'NITROGEN',SR)    = -PRODCOEF(FEEDACR,'SILAGE',SR)  * 0.022 + 0.010;
PRODCOEF('SPAREFOR','NITROGEN',SR) = 0;
PRODCOEF(PASTURES,'NITROGEN',SR)   = 0;
PRODCOEF(FEEDACR,'PHOSPHORUS',SR)  = -PRODCOEF(FEEDACR,'SILAGE',SR)  * 0.0030;
PRODCOEF(FEEDACR,'POTASSIUM',SR)   = -PRODCOEF(FEEDACR,'SILAGE',SR)  * 0.025;
PRODCOEF('SALIX'   ,'NITROGEN',SR) = 0.070/3 - PRODCOEF('SALIX','SALIXMJ',SR)/4.4 * 0.005;
PRODCOEF('SALIX'   ,'PHOSPHORUS',SR) = -PRODCOEF('SALIX','SALIXMJ',SR)/4.4  * 0.00083;
PRODCOEF('SALIX'   ,'POTASSIUM',SR) = -PRODCOEF('SALIX','SALIXMJ',SR)/4.4  * 0.0027;

* Include differences due to land quality
PRODCOEF('PPASTRH',IP,SR) = PRODCOEF('PPASTR',IP,SR);
PRODCOEF('PPASTR','GRASSPASTR',SR) = PRODCOEF('PPASTR','GRASSPASTR',SR) * 0.5;

PRODCOEF('PPASTR','USEPASTR',SR)   = -PRODCOEF('PPASTR','GRASSPASTR',SR) -0.001;
PRODCOEF('PPASTRH','USEPASTR',SR)  = -PRODCOEF('PPASTRH','GRASSPASTR',SR) -0.001;

PRODCOEF('PPASTRT',IP,SR)   = PRODCOEF('PPASTR',IP,SR);
PRODCOEF('PPASTRHT',IP,SR)  = PRODCOEF('PPASTRH',IP,SR);

* Adds costs for environmental support
PRODCOEF('PPASTRB','LABOR',SR)    = PRODCOEF('PPASTRB','LABOR',SR)  + 0.002;
PRODCOEF('PPASTRHB','LABOR',SR)   = PRODCOEF('PPASTRHB','LABOR',SR) + 0.002;
PRODCOEF('PPASTRB','POWER',SR)    = PRODCOEF('PPASTRB','POWER',SR)  + 0.001;
PRODCOEF('PPASTRHB','POWER',SR)   = PRODCOEF('PPASTRHB','POWER',SR) + 0.001;
PRODCOEF('PPASTRB','OTHRVARCST',SR)  = PRODCOEF('PPASTRB','OTHRVARCST',SR)  + 0.375;
PRODCOEF('PPASTRHB','OTHRVARCST',SR) = PRODCOEF('PPASTRHB','OTHRVARCST',SR) + 0.750;
*375 (750) SEK per hectare for reduced growth etc., half in case of low yield due to fewer animals 

PRODCOEF('PPASTRT','LABOR',SR)    = PRODCOEF('PPASTRT','LABOR',SR)  + 0.004;
PRODCOEF('PPASTRHT','LABOR',SR)   = PRODCOEF('PPASTRHT','LABOR',SR) + 0.004;
PRODCOEF('PPASTRT','POWER',SR)    = PRODCOEF('PPASTRT','POWER',SR)  + 0.002;
PRODCOEF('PPASTRHT','POWER',SR)   = PRODCOEF('PPASTRHT','POWER',SR) + 0.002;
PRODCOEF('PPASTRT','OTHRVARCST',SR)    = PRODCOEF('PPASTRT','OTHRVARCST',SR)  + 0.750;
PRODCOEF('PPASTRHT','OTHRVARCST',SR)   = PRODCOEF('PPASTRHT','OTHRVARCST',SR) + 1.500;
*750 (1 500) SEK per hectare for reduced growth etc., half in case of low yield due to fewer animals 
PRODCOEF('PPASTRFOR','LABOR',SA01TO04a)  = PRODCOEF('PPASTRFOR','LABOR',SA01TO04a)  - 0.001;
PRODCOEF('PPASTRFOR','POWER',SA01TO04a)  = PRODCOEF('PPASTRFOR','POWER',SA01TO04a)  - 0.001;

*Include top values (difference only if more requirements are placed on land with high values) 
PRODCOEF('PPASTRN',IP,SR) = PRODCOEF('PPASTRT',IP,SR);
*PRODCOEF('PPASTRN','LABOR',SR)  = PRODCOEF('PPASTRN','LABOR',SR) + 0.002;
*PRODCOEF('PPASTRN','LABOR2',SR) = PRODCOEF('PPASTRN','LABOR2',SR)+ 0.002;
*PRODCOEF('PPASTRN','POWER',SR)  = PRODCOEF('PPASTRN','POWER',SR) + 0.0005;
PRODCOEF('PPASTRHN',IP,SR) = PRODCOEF('PPASTRHT',IP,SR);
*PRODCOEF('PPASTRHN','LABOR',SR)  = PRODCOEF('PPASTRHN','LABOR',SR) + 0.002;
*PRODCOEF('PPASTRHN','LABOR2',SR) = PRODCOEF('PPASTRHN','LABOR2',SR)+ 0.002;
*PRODCOEF('PPASTRHN','POWER',SR)  = PRODCOEF('PPASTRHN','POWER',SR) + 0.0005;

* Include special classes
PRODCOEF('PPASTRFOR',IP,SR)  = PRODCOEF('PPASTRT',IP,SR) * 0.5;
PRODCOEF('PPASTRMOS',IP,SR)  = PRODCOEF('PPASTRT',IP,SR) * 0.5;
PRODCOEF('PPASTRLOW',IP,SR)  = PRODCOEF('PPASTRT',IP,SR) * 0.5;
PRODCOEF('PPASTRMEAD',IP,SR) = PRODCOEF('PPASTRT',IP,SR) * 0.5;
PRODCOEF('PPASTRALV',IP,SR)  = PRODCOEF('PPASTRT',IP,SR) * 0.1;
PRODCOEF('PPASTRCHAL',IP,SR) = PRODCOEF('PPASTRT',IP,SR) * 0.1;

PRODCOEF('PPASTRFOR','GRASSPASTR',SR)  = PRODCOEF('PPASTRT','GRASSPASTR',SR)*1.5/4;
PRODCOEF('PPASTRMOS','GRASSPASTR',SR)  = PRODCOEF('PPASTRT','GRASSPASTR',SR)*1.5/3;
PRODCOEF('PPASTRLOW','GRASSPASTR',SR)  = PRODCOEF('PPASTRT','GRASSPASTR',SR)*1.5/5;
PRODCOEF('PPASTRMEAD','GRASSPASTR',SR) = PRODCOEF('PPASTRT','GRASSPASTR',SR)*1.5/4;
PRODCOEF('PPASTRALV','GRASSPASTR',SR)  = PRODCOEF('PPASTRT','GRASSPASTR',SR)*1.5/6;
PRODCOEF('PPASTRCHAL','GRASSPASTR',SR) = PRODCOEF('PPASTRT','GRASSPASTR',SR)*1.5/5;
* Coef 1.5 is for making it average between high and low

PRODCOEF('PPASTRFOR','USEPASTR',SR)   = -PRODCOEF('PPASTRFOR','GRASSPASTR',SR)  -0.001;
PRODCOEF('PPASTRMOS','USEPASTR',SR)   = -PRODCOEF('PPASTRMOS','GRASSPASTR',SR)  -0.001;
PRODCOEF('PPASTRLOW','USEPASTR',SR)   = -PRODCOEF('PPASTRLOW','GRASSPASTR',SR)  -0.001;
PRODCOEF('PPASTRMEAD','USEPASTR',SR)  = -PRODCOEF('PPASTRMEAD','GRASSPASTR',SR) -0.001;
PRODCOEF('PPASTRALV','USEPASTR',SR)   = -PRODCOEF('PPASTRALV','GRASSPASTR',SR)  -0.001;
PRODCOEF('PPASTRCHAL','USEPASTR',SR)  = -PRODCOEF('PPASTRCHAL','GRASSPASTR',SR) -0.001;

PRODCOEF('PPASTRFOR','OTHRVARCST',SR)  = PRODCOEF('PPASTRT','OTHRVARCST',SR)  - 0.375*3/4;
PRODCOEF('PPASTRMOS','OTHRVARCST',SR)  = PRODCOEF('PPASTRT','OTHRVARCST',SR)  - 0.375*2/3;
PRODCOEF('PPASTRLOW','OTHRVARCST',SR)  = PRODCOEF('PPASTRT','OTHRVARCST',SR)  - 0.375*4/5;
PRODCOEF('PPASTRMEAD','OTHRVARCST',SR) = PRODCOEF('PPASTRT','OTHRVARCST',SR)  - 0.375*3/4;
PRODCOEF('PPASTRALV','OTHRVARCST',SR)  = PRODCOEF('PPASTRT','OTHRVARCST',SR)  - 0.075*5/6;
PRODCOEF('PPASTRCHAL','OTHRVARCST',SR) = PRODCOEF('PPASTRT','OTHRVARCST',SR)  - 0.075*4/5;
* The cost increase for reduced growth is partially offset by fewer animals

PRODCOEF('PPASTR','OTHRVARCST',SR)     = PRODCOEF('PPASTR','OTHRVARCST',SR)    + 0.250;
PRODCOEF('PPASTRB','OTHRVARCST',SR)    = PRODCOEF('PPASTRB','OTHRVARCST',SR)   - 0.300;
PRODCOEF('PPASTRT','OTHRVARCST',SR)    = PRODCOEF('PPASTRT','OTHRVARCST',SR)   + 0.300;
PRODCOEF('PPASTRN','OTHRVARCST',SR)    = PRODCOEF('PPASTRN','OTHRVARCST',SR)   + 0.300;
PRODCOEF('PPASTRH','OTHRVARCST',SR)    = PRODCOEF('PPASTRH','OTHRVARCST',SR)   + 0.800;
PRODCOEF('PPASTRHB','OTHRVARCST',SR)   = PRODCOEF('PPASTRHB','OTHRVARCST',SR)  - 0.600;
PRODCOEF('PPASTRHT','OTHRVARCST',SR)   = PRODCOEF('PPASTRHT','OTHRVARCST',SR)  + 0.100;
PRODCOEF('PPASTRHN','OTHRVARCST',SR)   = PRODCOEF('PPASTRHN','OTHRVARCST',SR)  + 0.100;
PRODCOEF('PPASTRFOR','OTHRVARCST',SR)  = PRODCOEF('PPASTRFOR','OTHRVARCST',SR) + 0.540;
PRODCOEF('PPASTRMOS','OTHRVARCST',SR)  = PRODCOEF('PPASTRMOS','OTHRVARCST',SR) - 0.275;
PRODCOEF('PPASTRLOW','OTHRVARCST',SR)  = PRODCOEF('PPASTRLOW','OTHRVARCST',SR) - 0.100;
PRODCOEF('PPASTRMEAD','OTHRVARCST',SR) = PRODCOEF('PPASTRMEAD','OTHRVARCST',SR)+ 0.020;
PRODCOEF('PPASTRALV','OTHRVARCST',SR)  = PRODCOEF('PPASTRALV','OTHRVARCST',SR) - 0.440;
PRODCOEF('PPASTRCHAL','OTHRVARCST',SR) = PRODCOEF('PPASTRCHAL','OTHRVARCST',SR)+ 0.080;
* PPM factor included based on scenario 2021

PRODCOEF('PPASTRMEAD','SILAGE',SR)     = PRODCOEF('PPASTR','GRASSPASTR',SR);
PRODCOEF('PPASTRMEAD','LABOR',SR) = -PRODCOEF('PPASTRMEAD','SILAGE',SR) * 40/1000;
PRODCOEF('PPASTRMEAD','GRASSPASTR',SR) = 0;
PRODCOEF('PPASTRMEAD','USEPASTR',SR)   = 0;

* Reduced demand on grazing for farm support (25%) and 90% with basic environmental support
PRODCOEF('PPASTRB','USEPASTR',SR)   = PRODCOEF('PPASTR','USEPASTR',SR) * 0.65;
PRODCOEF('PPASTRHB','USEPASTR',SR)  = PRODCOEF('PPASTRH','USEPASTR',SR) * 0.65;
PRODCOEF('PPASTR','USEPASTR',SR)   = PRODCOEF('PPASTR','USEPASTR',SR) * 0.25;
PRODCOEF('PPASTRH','USEPASTR',SR)  = PRODCOEF('PPASTRH','USEPASTR',SR) * 0.25;

PRODCOEF(CROPS,'GRASSPASTF',SR) = PRODCOEF(CROPS,'GRASSPASTR',SR);

*Make it possible to move livestock within regions
PRODCOEF('LVSTKIN','USEPASTR',SR)   = -1;
PRODCOEF('LVSTKIN','GRASSPASTR',SR) =  1;
PRODCOEF('LVSTKIN','LVSTKBAL1',SR)  =  1;
PRODCOEF('LVSTKIN','LVSTKBAL2',SR)  = -1;
PRODCOEF('LVSTKIN','LABOR',SR)   = 0.001;
PRODCOEF('LVSTKIN','LABOR2',SR)  = 0.001;
PRODCOEF('LVSTKIN','POWER',SR)   = 0.0005;
PRODCOEF('LVSTKOUT','USEPASTR',SR)  =  1;
PRODCOEF('LVSTKOUT','GRASSPASTR',SR)= -1;
PRODCOEF('LVSTKOUT','LVSTKBAL1',SR) = -1;
PRODCOEF('LVSTKOUT','LVSTKBAL2',SR) =  1;

* Include land use
PRODCOEF(CROPS,'CROPLAND',SR) = 1;  
PRODCOEF('COVERCROP','CROPLAND',SR) = 0;  
PRODCOEF('CATCHCROP','CROPLAND',SR) = 0;  
PRODCOEF('SPRINGTILL','CROPLAND',SR) = 0;  

PRODCOEF('PPASTR','PRMPAST',SR) = 1;  
PRODCOEF('PPASTR','BIODIVSUBL',SR) = -1;  
PRODCOEF('PPASTRB','BIODIVSUBL',SR) = 1;  
PRODCOEF('PPASTRT','PRMPASTT',SR) = 1;  
PRODCOEF('PPASTRN','PRMPASTN',SR) = 1;  
PRODCOEF('PPASTRH','PRMPASTH',SR) = 1;  
PRODCOEF('PPASTRH','BIODIVSUBH',SR) = -1;  
PRODCOEF('PPASTRHB','BIODIVSUBH',SR) = 1;  
PRODCOEF('PPASTRHT','PRMPASTHT',SR) = 1;  
PRODCOEF('PPASTRHN','PRMPASTHN',SR) = 1;  

PRODCOEF('PPASTRALV','PRMALV',SR)   = 1;  
PRODCOEF('PPASTRFOR','PRMFOR',SR)   = 1;  
PRODCOEF('PPASTRMOS','PRMMOS',SR)   = 1;  
PRODCOEF('PPASTRLOW','PRMLOW',SR)   = 1;  
PRODCOEF('PPASTRCHAL','PRMCHAL',SR) = 1;  
PRODCOEF('PPASTRMEAD','PRMMEAD',SR) = 1;  

PRODCOEF('SPAPASTR','PRMPAST',SR) = 1; 
PRODCOEF('SPAPASTRT','PRMPASTT',SR) = 1; 
PRODCOEF('SPAPASTRH','PRMPASTH',SR) = 1; 
PRODCOEF('SPAPASTRHT','PRMPASTHT',SR) = 1; 

*Make it possible to upgrade pasture to top support
PRODCOEF('UPGRPAST','PRMPAST',SR)     =  1;  
PRODCOEF('UPGRPAST','PRMPASTN',SR)    = -1;  
PRODCOEF('UPGRPAST','ACRCOSTP',SR)    =  1;  
PRODCOEF('UPGRPAST','ACRCOSTPN',SR)   = -1;  
PRODCOEF('UPGRPAST','PRMPASTUP',SR)   =  1;
PRODCOEF('UPGRPAST','OTHRVARCST',SR)  =  0.001;  
  
PRODCOEF('UPGRPASTH','PRMPASTH',SR)   =  1;  
PRODCOEF('UPGRPASTH','PRMPASTHN',SR)  = -1;  
PRODCOEF('UPGRPASTH','ACRCOSTPH',SR)  =  1;  
PRODCOEF('UPGRPASTH','ACRCOSTPHN',SR) = -1;
PRODCOEF('UPGRPASTH','PRMPASTHUP',SR) =  1;
PRODCOEF('UPGRPASTH','OTHRVARCST',SR) =  0.001;   

*Transfer cropland to pasture with high production and basic support
PRODCOEF('CROPTOPAST','CROPLAND',SR)    =  1;  
PRODCOEF('CROPTOPAST','PRMPASTH',SR)    = -1;  
PRODCOEF('CROPTOPAST','MAXCRTOPST',SR)  =  1;  
PRODCOEF('CROPTOPAST','ACRCOSTPH',SR)   = -1;
PRODCOEF('CROPTOPAST','OTHRVARCST',SR)  = 0.001;

*Carbon bonding in soil
PRODCOEF(CROPS,'CBONDING',SR)       = -0.100;
PRODCOEF(GRAINS,'CBONDING',SR)      = -0.150 + 0.025;
PRODCOEF('BARLEY','CBONDING',SR)    = -0.100 + 0.025;
PRODCOEF('OATS','CBONDING',SR)      = -0.050 + 0.025;
PRODCOEF('W-RAPE','CBONDING',SR)    = -0.150;
PRODCOEF('S-RAPE','CBONDING',SR)    = -0.100;
PRODCOEF('FEEDPEAS','CBONDING',SR)  = -0.200;
PRODCOEF('POTATO','CBONDING',SR)    = -0.100;
PRODCOEF('SUGAR','CBONDING',SR)     = -0.150;
PRODCOEF('OTHERCROPS','CBONDING',SR)= -0.100;
PRODCOEF('ICR','CBONDING',SR)       = -0.100;
PRODCOEF('FORAGE1','CBONDING',SR)   = -0.450; 
PRODCOEF('FORAGE2','CBONDING',SR)   = -0.450;
PRODCOEF('FORAGE3','CBONDING',SR)   = -0.250;
PRODCOEF('FORAGE4','CBONDING',SR)   = -0.050;
PRODCOEF('PASTURE1','CBONDING',SR)  = -0.450;
PRODCOEF('PASTURE2','CBONDING',SR)  = -0.250;
PRODCOEF('NEWFOR','CBONDING',SR)    = -0.428;
PRODCOEF('SPAREFOR','CBONDING',SR)  = -0.050;
PRODCOEF('LAY','CBONDING',SR)       = -0.250;
PRODCOEF('LONGLAY','CBONDING',SR)   = -0.050;
PRODCOEF('NOUSE','CBONDING',SR)     = -0.050;
PRODCOEF(PASTURES,'CBONDING',SR)    = -0.050;
PRODCOEF('COVERCROP','CBONDING',SR) = -0.300;
PRODCOEF('CATCHCROP','CBONDING',SR) = -0.200;

* Emissions from organic land
PRODCOEF(CROPS,'ORGCROPL',SR)      = PRODCOEF(CROPS,'CROPLAND',SR) * 0.06;
PRODCOEF('USEORGCL','ORGCROPL',SR) = -1;
PRODCOEF('USEORGCL','CO2',SR)      = 6.1 * 3.67;
PRODCOEF('USEORGCL','N2O',SR)      = 0.012;
PRODCOEF('USEORGCL','CH4',SR)      = 0.0596;

PRODCOEF(PASTURES,'ORGPASTR',SR)   = 0.06;
PRODCOEF('USEORGPL','ORGPASTR',SR) = -1;
PRODCOEF('USEORGPL','CO2',SR)      = 2.6 * 3.67;
PRODCOEF('USEORGPL','N2O',SR)      = 0.0028;
PRODCOEF('USEORGPL','CH4',SR)      = 0.0079;
 
* Include needed acreage for manure, adjusted for inefficient distribution
PRODCOEF(CROPS,'ACRMANURE',SR)      = -1 * 0.5;  
PRODCOEF('LONGLAY','ACRMANURE',SR)  =  0;  
PRODCOEF('NOUSE','ACRMANURE',SR)  =  0;  
PRODCOEF('COVERCROP','ACRMANURE',SR)  =  0;  
PRODCOEF('CATCHCROP','ACRMANURE',SR)  =  0;  
PRODCOEF('SPRINGTILL','ACRMANURE',SR) =  0;  
PRODCOEF(PASTURES,'ACRMANURE',SR)   = -1 * 0.5;

* Include land quality differences (not enabled on arable land)
*PRODCOEF(AS,'ACRCOST',SR)  = PRODCOEF(AS,'CROPLAND',SR);  
*PRODCOEF('LONGLAY','ACRCOST',SR) = 0;
*PRODCOEF('SPAREFOR','ACRCOST',SR) = 0;
PRODCOEF('PPASTR','ACRCOSTP',SR)       = 1;
PRODCOEF('PPASTRT','ACRCOSTPT',SR)     = 1;
PRODCOEF('PPASTRN','ACRCOSTPN',SR)     = 1;
PRODCOEF('PPASTRH','ACRCOSTPH',SR)     = 1;
PRODCOEF('PPASTRHT','ACRCOSTPHT',SR)   = 1;
PRODCOEF('PPASTRHN','ACRCOSTPHN',SR)   = 1;
PRODCOEF('PPASTRALV','ACRCOSTALV',SR)  = 1;
PRODCOEF('PPASTRFOR','ACRCOSTFOR',SR)  = 1;
PRODCOEF('PPASTRMOS','ACRCOSTMOS',SR)  = 1;
PRODCOEF('PPASTRLOW','ACRCOSTLOW',SR)  = 1;
PRODCOEF('PPASTRCHAL','ACRCOSTCHA',SR) = 1;
PRODCOEF('PPASTRMEAD','ACRCOSTMEA',SR) = 1;

* Include other crops, industry crops, land with undefined use and min number of sheep
PRODCOEF('OTHERCROPS','OTHRCROPPR',SR) = -1;  
PRODCOEF('OTHERCROPS',I,SR) = PRODCOEF('BARLEY',I,SR);  
PRODCOEF('OTHERCROPS','NLEAKAGE',SR) = PRODCOEF('BARLEY','NLEAKAGE',SR);  
PRODCOEF('OTHERCROPS','PLEAKAGE',SR) = PRODCOEF('BARLEY','PLEAKAGE',SR);  

PRODCOEF('ICR','ICRPR',SR) = -1;  
PRODCOEF('ICR',I,SR) = PRODCOEF('BARLEY',I,SR);  
PRODCOEF('ICR','NLEAKAGE',SR) = PRODCOEF('BARLEY','NLEAKAGE',SR);  
PRODCOEF('ICR','PLEAKAGE',SR) = PRODCOEF('BARLEY','PLEAKAGE',SR);  

PRODCOEF('NOUSE','UNDEFUSE',SR) = -1;  
PRODCOEF('NOUSE','OTHRVARCST',SR) = 0.500;  
PRODCOEF('NOUSE','NLEAKAGE',SR) = PRODCOEF('LONGLAY','NLEAKAGE',SR);  
PRODCOEF('NOUSE','PLEAKAGE',SR) = PRODCOEF('LONGLAY','PLEAKAGE',SR);  

PRODCOEF('SHEEP','MINSHEEP',SR) = -1;
PRODCOEF('SHEEP2','MINSHEEP',SR) = -1;
PRODCOEF(BCOWS,'MINBCOW',SR)    = -1;  

* Make slaughter heifers equal to dairybull2 except bull subsidies
PRODCOEF('SLGHHEIFER',IP,SR) = PRODCOEF('DAIRYBULL2',IP,SR);
PRODCOEF('SLGHHEIFER','DCALFF',SR) = PRODCOEF('DAIRYBULL2','DCALFM',SR);
PRODCOEF('SLGHHEIFER','DCALFM',SR) = 0;

* Needed sugar quota.
PRODCOEF('SUGAR','SUGARQUOTA',SR) = 1;

* Calculate coefficients for yield risk reduction
PRODCOEF(LIVESTOCK,'YIELDRIRE1',SR) = 
          (PRODCOEF(LIVESTOCK,'SILAGE',SR) + PRODCOEF(LIVESTOCK,'GRASSPASTR',SR))*0.1; 
PRODCOEF(LIVESTOCK,'YIELDRIRE2',SR) = 
          (PRODCOEF(LIVESTOCK,'SILAGE',SR) + PRODCOEF(LIVESTOCK,'GRASSPASTR',SR))*0.2; 

PRODCOEF('SPAREFOR','YIELDRIRE1',SR)   = PRODCOEF('PASTURE2','GRASSPASTR',SR);
PRODCOEF('SPAREFOR','YIELDRIRE2',SR)   = PRODCOEF('PASTURE2','GRASSPASTR',SR);
PRODCOEF('SPAPASTR','YIELDRIRE1',SR)   = PRODCOEF('PPASTR','GRASSPASTR',SR);
PRODCOEF('SPAPASTRT','YIELDRIRE1',SR)  = PRODCOEF('PPASTRT','GRASSPASTR',SR);
PRODCOEF('SPAPASTRH','YIELDRIRE1',SR)  = PRODCOEF('PPASTRH','GRASSPASTR',SR);
PRODCOEF('SPAPASTRHT','YIELDRIRE1',SR) = PRODCOEF('PPASTRHT','GRASSPASTR',SR);
PRODCOEF('SPARESIL','YIELDRIRE1',SR)   = -1;
PRODCOEF('SPARESIL','YIELDRIRE2',SR)   = -1;
PRODCOEF('SPARESIL','SILAGE',SR)       = 1;

* Max 20 percent yieldrisk with subsidies etc.
PRODCOEF(AS,'YIELDRIRE3',SR) = -PRODCOEF(AS,'YIELDRIRE2',SR);

PRODCOEF('SPAREFOR','NLEAKAGE',SR)   = PRODCOEF('PASTURE2','NLEAKAGE',SR);
PRODCOEF('SPAREFOR','PLEAKAGE',SR)   = PRODCOEF('PASTURE2','PLEAKAGE',SR);
*PRODCOEF('SPAPASTR','NLEAKAGE',SR) = PRODCOEF('PASTURE2','NLEAKAGE',SR);
*PRODCOEF('SPAPASTRT','NLEAKAGE',SR) = PRODCOEF('PASTURE2','NLEAKAGE',SR);
*PRODCOEF('SPAPASTRH','NLEAKAGE',SR) = PRODCOEF('PASTURE2','NLEAKAGE',SR);
*PRODCOEF('SPAPASTRHT','NLEAKAGE',SR) = PRODCOEF('PASTURE2','NLEAKAGE',SR);
 
* Potential for general acreage subsidies
PRODCOEF(CROPS,'GACRSUB',SR)            = -1;  
PRODCOEF('COVERCROP','GACRSUB',SR)      = 0;  
PRODCOEF('CATCHCROP','GACRSUB',SR)      = 0;  
PRODCOEF('SPRINGTILL','GACRSUB',SR)     = 0;  
PRODCOEF('ECOPIG','GACRSUB',SR)         = -0.4;  
PRODCOEF('EPOULTRY','GACRSUB',SR)       = -2;  
PRODCOEF('PPASTR','GACRSUB',SR)     = -1;  
PRODCOEF('PPASTRT','GACRSUB',SR)    = -1;  
PRODCOEF('PPASTRH','GACRSUB',SR)    = -1;  
PRODCOEF('PPASTRN','GACRSUB',SR)    = -1;  
PRODCOEF('PPASTRHT','GACRSUB',SR)   = -1;  
PRODCOEF('PPASTRHN','GACRSUB',SR)   = -1;  
PRODCOEF('PPASTRALV','GACRSUB',SR)  = 0;  
PRODCOEF('PPASTRFOR','GACRSUB',SR)  = 0;  
PRODCOEF('PPASTRMOS','GACRSUB',SR)  = 0;  
PRODCOEF('PPASTRLOW','GACRSUB',SR)  = 0;  
PRODCOEF('PPASTRCHAL','GACRSUB',SR) = 0;  
PRODCOEF('PPASTRMEAD','GACRSUB',SR) = -1;  

PRODCOEF(GRAINS,'COMP4SUB',SA01TO12)      = -1;  
PRODCOEF(OILGRAINS,'COMP4SUB',SA01TO12)   = -1;  
PRODCOEF('POTATO','COMP4SUB',SA01TO12)    = -1;  
PRODCOEF('FEEDPEAS','COMP4SUB',SA01TO12)  = -1;  
PRODCOEF(FORAGES,'FORSUB',SR)       = -1*0;  
PRODCOEF(FORAGES,'FORSUB',SA01TO12)  =  0;  

PRODCOEF('PPASTRB','BIODIVSUB',SR)   = -1;  
PRODCOEF('PPASTRT','BIODIVSUB',SR)   = -1;  
PRODCOEF('PPASTRT','BIODIVSUB2',SR)  = -1;  
PRODCOEF('PPASTRN','BIODIVSUB3',SR)  = -1;  
PRODCOEF('PPASTRHB','BIODIVSUB',SR)  = -1;  
PRODCOEF('PPASTRHT','BIODIVSUB',SR)  = -1;  
PRODCOEF('PPASTRHT','BIODIVSUB2',SR) = -1;  
PRODCOEF('PPASTRHN','BIODIVSUB3',SR) = -1;  
PRODCOEF('PPASTRFOR','BIODIVSUBF',SR) = -1;  
PRODCOEF('PPASTRMOS','BIODIVSUBM',SR) = -1;  
PRODCOEF('PPASTRLOW','BIODIVSUBG',SR) = -1;  
PRODCOEF('PPASTRMEAD','BIODIVSUBS',SR)= -1;  
PRODCOEF('PPASTRALV','BIODIVSUBA',SR) = -1;  
PRODCOEF('PPASTRCHAL','BIODIVSUBC',SR)= -1;  

* Potential for general livestock subsidies
PRODCOEF(DCOWS,'CATTLESUB',SR)           = -1;  
PRODCOEF('HEIFER','CATTLESUB',SR)        = -1.395;  
PRODCOEF('DAIRYBULL1','CATTLESUB',SR)    = -0.725;  
PRODCOEF('DAIRYBULL2','CATTLESUB',SR)    = -1.395;  
PRODCOEF('SLGHHEIFER','CATTLESUB',SR)    = -1.395;  
PRODCOEF('BEEFCATTLE','CATTLESUB',SR)    = -1.725; 
PRODCOEF('BEEFCATTL2','CATTLESUB',SR)    = -1.725 -0.6*8/12; 
PRODCOEF('SOW1','SOWHLTSUB',SR)          = -1;  

* Potential for regional compensation subsidies
PRODCOEF(DCOWS,'COMPSUBL',SA01TO12)        = -1.0 - 0.33*1.8*0.6;  
PRODCOEF('DAIRYBULL1','COMPSUBL',SA01TO12) = -0.6 * 1.225;  
PRODCOEF('DAIRYBULL2','COMPSUBL',SA01TO12) = -0.6 * 1.9;  
PRODCOEF('SLGHHEIFER','COMPSUBL',SA01TO12) = -0.6 * 1.9;  
PRODCOEF('BEEFCATTLE','COMPSUBL',SA01TO12) = -1.0 - 0.2*1.1*1.8*0.6 - 0.6*1.1*1.225*0.6;
PRODCOEF('BEEFCATTL2','COMPSUBL',SA01TO12) = -1.0 - 0.2*1.1*1.8*0.6 - 0.6*1.1*1.225*0.6;
PRODCOEF('SHEEP','COMPSUBL',SA01TO12)      = -0.20;
PRODCOEF('SHEEP2','COMPSUBL',SA01TO12)      = -0.20;
PRODCOEF(FEEDACR,'COMPSUB',SA01TO12)       = -1;
PRODCOEF('PPASTRFOR','COMPSUB',SA01TO12)     = 0;
PRODCOEF('PPASTRMOS','COMPSUB',SA01TO12)     = 0;
PRODCOEF('PPASTRLOW','COMPSUB',SA01TO12)     = 0;
PRODCOEF('PPASTRALV','COMPSUB',SA01TO12)     = 0;
PRODCOEF('PPASTRCHAL','COMPSUB',SA01TO12)    = 0;
PRODCOEF('PPASTRMEAD','COMPSUB',SA01TO12)    = 0;
PRODCOEF('GRAINSIL','COMPSUB',SA01TO12)      = -1;
PRODCOEF('MAJSSIL','COMPSUB',SA01TO12)       = -1;

* Potential for national subsidies
*** TABLE NSUB(AS,SR) 

PRODCOEF(AS,'NATSUB',SA01TO05) = PRODCOEF(AS,'NATSUB',SA01TO05) + NSUB(AS,SA01TO05);

* Include Eco Schemes
PRODCOEF('FEEDPEAS','ES1',SR)      = -1;
PRODCOEF(CROPS4,'ES3',SR) $ sum(SA$SA_prod_13(SA), SASR_prod(SA,SR)) = -0.90;

* Include Eco Schemes
PRODCOEF(CROPS4,'ES3',SR)$SASR('SA13',SR)        = -0.90;
PRODCOEF(CROPS4,'OTHRVARCST',SR)$SASR('SA13',SR) = PRODCOEF(CROPS4,'OTHRVARCST',SR) + 0.100*0.90; 
PRODCOEF(CROPS4,FERT,SR)$SASR('SA13',SR)         = PRODCOEF(CROPS4,FERT,SR) * (1-0.01*0.90);
PRODCOEF(CROPS4,'NLEAKAGE',SR)$SASR('SA13',SR)   = PRODCOEF(CROPS4,'NLEAKAGE',SR) * (1-0.01*0.90);
PRODCOEF(CROPS4,'PLEAKAGE',SR)$SASR('SA13',SR)   = PRODCOEF(CROPS4,'PLEAKAGE',SR) * (1-0.01*0.90);
* 75 % areage are asumed to apply. Extra cost 100 SEK per hektar. N,P & K reduced 1 %.

PRODCOEF('COVERCROP','ES4',SR)                  = -1;  
PRODCOEF('COVERCROP',IP,SA01TO05)               =  0;  
PRODCOEF('CATCHCROP','ES5',SR)$SASR('SA13',SR)  = -1;  
PRODCOEF('SPRINGTILL','ES6',SR)$SASR('SA13',SR) = -1;  

* Adjust to general productivity development from 2017 until 2025 by 0,5 % for all inputs,
* 1,5 % for labor and 1,5 % for power
PRODCOEF(AS,VARI,SR)  = PRODCOEF(AS,VARI,SR) * prodGrowthInputs**8;
PRODCOEF(AS,'LABOR',SR)  = PRODCOEF(AS,'LABOR',SR) * prodGrowthLabour**8/prodGrowthInputs**8;
PRODCOEF(AS,'LABOR2',SR) = PRODCOEF(AS,'LABOR2',SR)* prodGrowthLabour**8/prodGrowthInputs**8;
PRODCOEF(AS,'POWER',SR)  = PRODCOEF(AS,'POWER',SR) * prodGrowthPower**8/prodGrowthInputs**8;

PRODCOEF(LIVESTOCK,FEEDP,SR)  = PRODCOEF(LIVESTOCK,FEEDP,SR) * prodGrowthInputs**8;

*Less productivity development in LFA regions, more in other until year 2025
PRODCOEF(AS,VARI,SR)  = PRODCOEF(AS,VARI,SR) * 0.9997**8;
PRODCOEF(LIVESTOCK,FEEDP,SR)  = PRODCOEF(LIVESTOCK,FEEDP,SR) * 0.9997**8;
PRODCOEF(AS,VARI,LFAHIGH)  = PRODCOEF(AS,VARI,LFAHIGH) * 1.002**8;
PRODCOEF(LIVESTOCK,FEEDP,LFAHIGH)  = PRODCOEF(LIVESTOCK,FEEDP,LFAHIGH) * 1.002**8;
PRODCOEF(AS,VARI,SA9TO10)  = PRODCOEF(AS,VARI,SA9TO10) * 1.001**8;
PRODCOEF(LIVESTOCK,FEEDP,SA9TO10)  = PRODCOEF(LIVESTOCK,FEEDP,SA9TO10) * 1.001**8;

* Adjust to general productivity development by 0,5 % for all inputs, 1,5 % for 
* labor and 1,5 % for power
*PRODCOEF('SALIX','OTHRVARCST',SR) $(LONGRUN2)= PRODCOEF('SALIX','OTHRVARCST',SR) * 0.90 - 0.265;
PRODCOEF(AS,VARI,SR) $(LONGRUN2) = PRODCOEF(AS,VARI,SR) * prodGrowthInputs**YRT;
PRODCOEF(AS,'LABOR',SR) $(LONGRUN2) = PRODCOEF(AS,'LABOR',SR) * prodGrowthLabour**YRT/prodGrowthInputs**YRT;
PRODCOEF(AS,'LABOR2',SR) $(LONGRUN2)= PRODCOEF(AS,'LABOR2',SR)* prodGrowthLabour**YRT/prodGrowthInputs**YRT;
PRODCOEF(AS,'POWER',SR) $(LONGRUN2) = PRODCOEF(AS,'POWER',SR) * prodGrowthPower**YRT/prodGrowthInputs**YRT;

PRODCOEF(LIVESTOCK,FEEDP,SR) $(LONGRUN2) = PRODCOEF(LIVESTOCK,FEEDP,SR) * prodGrowthInputs**YRT;

*Less productivity development in LFA regions, more in other
PRODCOEF(AS,VARI,SR) $(LONGRUN2) = PRODCOEF(AS,VARI,SR) * 0.9997**YRT;
PRODCOEF(LIVESTOCK,FEEDP,SR) $(LONGRUN2) = PRODCOEF(LIVESTOCK,FEEDP,SR) * 0.9997**YRT;
PRODCOEF(AS,VARI,LFAHIGH) $(LONGRUN2) = PRODCOEF(AS,VARI,LFAHIGH) * 1.002**YRT;
PRODCOEF(LIVESTOCK,FEEDP,LFAHIGH) $(LONGRUN2) = PRODCOEF(LIVESTOCK,FEEDP,LFAHIGH) * 1.002**YRT;
PRODCOEF(AS,VARI,SA9TO10) $(LONGRUN2) = PRODCOEF(AS,VARI,SA9TO10) * 1.001**YRT;
PRODCOEF(LIVESTOCK,FEEDP,SA9TO10) $(LONGRUN2) = PRODCOEF(LIVESTOCK,FEEDP,SA9TO10) * 1.001**YRT;

* Organic production coefficients
PRODCOEF('EW-WHEAT',IP,SR) = PRODCOEF('W-WHEAT',IP,SR);
PRODCOEF('EW-WHEAT',YD,SR) = PRODCOEF('EW-WHEAT',YD,SR)*0.65;
PRODCOEF('EW-RAY',IP,SR) = PRODCOEF('W-RAY',IP,SR);
PRODCOEF('EW-RAY',YD,SR) = PRODCOEF('EW-RAY',YD,SR)*0.65;
PRODCOEF('EBARLEY',IP,SR) = PRODCOEF('BARLEY',IP,SR);
PRODCOEF('EBARLEY',YD,SR) = PRODCOEF('EBARLEY',YD,SR)*0.65;
PRODCOEF('EOATS',IP,SR) = PRODCOEF('OATS',IP,SR);
PRODCOEF('EOATS',YD,SR) = PRODCOEF('EOATS',YD,SR)*0.65;
PRODCOEF('EFEEDPEAS',IP,SR) = PRODCOEF('FEEDPEAS',IP,SR);
PRODCOEF('EFEEDPEAS',YD,SR) = PRODCOEF('EFEEDPEAS',YD,SR)*0.75;
PRODCOEF('EFEEDPEAS','EPEAS',SR) = PRODCOEF('EFEEDPEAS','PEAS',SR);
PRODCOEF('EFEEDPEAS','INCONVPRO',SR)  = 0;
PRODCOEF('EFEEDPEAS','INCONVEPRO',SR) = 1;
PRODCOEF('EW-RAPE',IP,SR) = PRODCOEF('W-RAPE',IP,SR);
PRODCOEF('EW-RAPE',YD,SR) = PRODCOEF('EW-RAPE',YD,SR)*0.60;
PRODCOEF('EW-RAPE',YD,SR) $ SASR('SA13s',SR) = PRODCOEF('EW-RAPE',YD,SR) * 0.50 / 0.60 ;
PRODCOEF('EW-RAPE','ERAPE',SR) = PRODCOEF('EW-RAPE','OILGRAIN',SR);
PRODCOEF('EW-RAPE','OTHRVARCST',SR) = PRODCOEF('EW-RAPE','OTHRVARCST',SR) +1.100;
PRODCOEF('EW-RAPE','OTHRVARCST',SR) $ SASR('SA13s',SR) = PRODCOEF('EW-RAPE','OTHRVARCST',SR) +1.500;
PRODCOEF('ES-RAPE',IP,SR) = PRODCOEF('S-RAPE',IP,SR);
PRODCOEF('ES-RAPE',YD,SR) = PRODCOEF('ES-RAPE',YD,SR)*0.60;
PRODCOEF('ES-RAPE','ERAPE',SR) = PRODCOEF('ES-RAPE','OILGRAIN',SR);
PRODCOEF('ES-RAPE','OTHRVARCST',SR) = PRODCOEF('ES-RAPE','OTHRVARCST',SR) +1.100;
PRODCOEF('EPOTATO',IP,SR) = PRODCOEF('POTATO',IP,SR);
PRODCOEF('EPOTATO',YD,SR) = PRODCOEF('EPOTATO',YD,SR)*0.45;
PRODCOEF('EPOTATO','LABOR',SR) = PRODCOEF('EPOTATO','LABOR',SR)
        +0.0015*(PRODCOEF('POTATO','POTATOES',SR)-PRODCOEF('EPOTATO','POTATOES',SR));
PRODCOEF('EPOTATO','POWER',SR) = PRODCOEF('EPOTATO','POWER',SR)
        +0.00003*(PRODCOEF('POTATO','POTATOES',SR)-PRODCOEF('EPOTATO','POTATOES',SR));
PRODCOEF('EPOTATO','EPOTATOES',SR) = PRODCOEF('EPOTATO','POTATOES',SR);
PRODCOEF('ESUGAR',IP,SR) = PRODCOEF('SUGAR',IP,SR);
PRODCOEF('ESUGAR',YD,SR) = PRODCOEF('ESUGAR',YD,SR)*0.76;
PRODCOEF('ESUGAR','SUGARQUOTA',SR) = 0.76;
PRODCOEF('ESUGAR','LABOR',SR)$(PRODCOEF('ESUGAR','LABOR',SR) GT 0) = 
                               PRODCOEF('ESUGAR','LABOR',SR)+0.070;
PRODCOEF('ESUGAR','ESUGARB',SR) = PRODCOEF('ESUGAR','SUGARBEET',SR);
PRODCOEF('EFORAGE1',IP,SR) = PRODCOEF('FORAGE1',IP,SR);
PRODCOEF('EFORAGE1',YDF,SR) = PRODCOEF('EFORAGE1',YDF,SR)*0.90;
PRODCOEF('EFORAGE2',IP,SR) = PRODCOEF('FORAGE2',IP,SR);
PRODCOEF('EFORAGE2',YDF,SR) = PRODCOEF('EFORAGE2',YDF,SR)*0.90;
PRODCOEF('EFORAGE3',IP,SR) = PRODCOEF('FORAGE3',IP,SR);
PRODCOEF('EFORAGE3',YDF,SR) = PRODCOEF('EFORAGE3',YDF,SR)*0.90;
PRODCOEF('EFORAGE4',IP,SR) = PRODCOEF('FORAGE4',IP,SR);
PRODCOEF('EPASTURE1',IP,SR) = PRODCOEF('PASTURE1',IP,SR);
PRODCOEF('EPASTURE1',YDF,SR) = PRODCOEF('EPASTURE1',YDF,SR)*0.90;
PRODCOEF('EPASTURE2',IP,SR) = PRODCOEF('PASTURE2',IP,SR);
PRODCOEF('ENEWFOR',IP,SR) = PRODCOEF('NEWFOR',IP,SR);
PRODCOEF('ELAY',IP,SR) = PRODCOEF('LAY',IP,SR);
PRODCOEF('EOTHRCROPS',IP,SR) = PRODCOEF('OTHERCROPS',IP,SR);
PRODCOEF('ECOVERCROP',IP,SR) = PRODCOEF('COVERCROP',IP,SR);
PRODCOEF('ECOVERCROP',YD,SR) = PRODCOEF('COVERCROP',YD,SR)*0.65;
PRODCOEF('ECATCHCROP',IP,SR) = PRODCOEF('CATCHCROP',IP,SR);
PRODCOEF('ECATCHCROP',YD,SR) = PRODCOEF('ECATCHCROP',YD,SR)*0.65;
PRODCOEF('ESPRINGTIL',IP,SR) = PRODCOEF('SPRINGTILL',IP,SR);
PRODCOEF(ECO,'PESTICIDES',SR) = 0;
PRODCOEF(ECO,'HERBICIDES',SR) = 0;
PRODCOEF(ECO,'GLYFOSAT',SR)   = 0;
PRODCOEF(ECO,'FUNGICIDES',SR) = 0;
PRODCOEF(ECO,'INSECTICID',SR) = 0;

PRODCOEF(ECOCROPS,'ECON',SR) = PRODCOEF(ECOCROPS,'NITROGEN',SR) * 1.25;
PRODCOEF(ECOCROPS,'ECOP',SR) = PRODCOEF(ECOCROPS,'PHOSPHORUS',SR)* 1.00; 
PRODCOEF(ECOCROPS,'ECOK',SR) = PRODCOEF(ECOCROPS,'POTASSIUM',SR) *1.00; 
PRODCOEF(ECOCROPS,'NITROGEN',SR) = 0; 
PRODCOEF(ECOCROPS,'PHOSPHORUS',SR) = 0; 
PRODCOEF(ECOCROPS,'POTASSIUM',SR) = 0;

PRODCOEF(ECO,'NLEAKAGE',SR) = PRODCOEF(ECO,'NLEAKAGE',SR) * 0.7;
PRODCOEF('ECOPIG','NLEAKAGE',SR) = PRODCOEF('ECOPIG','NLEAKAGE',SR) / 0.7;
PRODCOEF('EPOULTRY','NLEAKAGE',SR) = PRODCOEF('EPOULTRY','NLEAKAGE',SR) / 0.7;
* Estimated difference in organic production based on nutrient balances in Greppa Naringen
* Pigs and poultry are already differentiated

PRODCOEF('EFORAGE1','ECON',SR)  = (PRODCOEF('EFORAGE1','ECON',SR)/1.25)  * 0.75;
PRODCOEF('EFORAGE2','ECON',SR)  = (PRODCOEF('EFORAGE2','ECON',SR)/1.25)  * 0.75;
PRODCOEF('EFORAGE3','ECON',SR)  = (PRODCOEF('EFORAGE3','ECON',SR)/1.25)  * 0.75;
PRODCOEF('EPASTURE1','ECON',SR) = (PRODCOEF('EPASTURE1','ECON',SR)/1.25) * 0.75;
PRODCOEF('EPASTURE2','ECON',SR) = (PRODCOEF('EPASTURE2','ECON',SR)/1.25) * 0.75;

PRODCOEF('ENFIX','ECON',SR)      = -0.090;
PRODCOEF('ENFIX','LABOR',SR)     = PRODCOEF('EBARLEY','LABOR',SR)/2;
PRODCOEF('ENFIX','POWER',SR)     = PRODCOEF('EBARLEY','POWER',SR)/2;
PRODCOEF('ENFIX','OTHRVARCST',SR)= PRODCOEF('EBARLEY','OTHRVARCST',SR)/2;
PRODCOEF('ENFIX','CAPITAL',SR)   = PRODCOEF('EBARLEY','CAPITAL',SR)/2;
PRODCOEF('ENFIX','NLEAKAGE',SR) = PRODCOEF('EFORAGE1','NLEAKAGE',SR);
PRODCOEF('ENFIX','PLEAKAGE',SR) = PRODCOEF('EFORAGE1','PLEAKAGE',SR);

PRODCOEF('EDCOW1',IP,SR) = PRODCOEF('DCOW1',IP,SR);
PRODCOEF('EDCOW2',IP,SR) = PRODCOEF('DCOW2',IP,SR);
PRODCOEF('EDCOW3',IP,SR) = PRODCOEF('DCOW3',IP,SR);
PRODCOEF('EDCOW1','MILK',SR) = PRODCOEF('DCOW1','MILK',SR)*0.9;
PRODCOEF('EDCOW2','MILK',SR) = PRODCOEF('DCOW2','MILK',SR)*0.9;
PRODCOEF('EDCOW3','MILK',SR) = PRODCOEF('DCOW3','MILK',SR)*0.9;
PRODCOEF('EDCOW1','FEEDGRAIN',SR) = PRODCOEF('DCOW1','FEEDGRAIN',SR)*0.85;
PRODCOEF('EDCOW2','FEEDGRAIN',SR) = PRODCOEF('DCOW2','FEEDGRAIN',SR)*0.85;
PRODCOEF('EDCOW3','FEEDGRAIN',SR) = PRODCOEF('DCOW3','FEEDGRAIN',SR)*0.85;
PRODCOEF('EDCOW1','LABOR',SR) = PRODCOEF('EDCOW1','LABOR',SR)+0.002;
PRODCOEF('EDCOW2','LABOR',SR) = PRODCOEF('EDCOW2','LABOR',SR)+0.002;
PRODCOEF('EDCOW3','LABOR',SR) = PRODCOEF('EDCOW3','LABOR',SR)+0.002;
PRODCOEF('EDCOW1','EMILK',SR) = PRODCOEF('EDCOW1','MILK',SR);
PRODCOEF('EDCOW2','EMILK',SR) = PRODCOEF('EDCOW2','MILK',SR);
PRODCOEF('EDCOW3','EMILK',SR) = PRODCOEF('EDCOW3','MILK',SR);
PRODCOEF('EDCOW1','MEDCOW',SR) = 1;  
PRODCOEF('EDCOW2','MEDCOW',SR) = 1;  
PRODCOEF('EDCOW3','MEDCOW',SR) = 1;  
PRODCOEF('DCOW1','MINKONVM',SR) = PRODCOEF('DCOW1','MILK',SR);
PRODCOEF('DCOW2','MINKONVM',SR) = PRODCOEF('DCOW2','MILK',SR);
PRODCOEF('DCOW3','MINKONVM',SR) = PRODCOEF('DCOW3','MILK',SR);
PRODCOEF('DCOW4','MINKONVM',SR) = PRODCOEF('DCOW4','MILK',SR);
PRODCOEF('EHEIFER',IP,SR) = PRODCOEF('HEIFER',IP,SR);
PRODCOEF('EDBULL1',IP,SR) = PRODCOEF('DAIRYBULL1',IP,SR);
PRODCOEF('EDBULL1','LABOR',SR) = PRODCOEF('EDBULL1','LABOR',SR)+0.0005;
PRODCOEF('EDBULL2',IP,SR) = PRODCOEF('DAIRYBULL2',IP,SR);
PRODCOEF('EDBULL2','LABOR',SR) = PRODCOEF('EDBULL2','LABOR',SR)+0.0005;
PRODCOEF('ESLGHHEIF',IP,SR) = PRODCOEF('SLGHHEIFER',IP,SR);
PRODCOEF('EBEEFCATT',IP,SR) = PRODCOEF('BEEFCATTLE',IP,SR);
PRODCOEF('EBEEFCATT','SLGHBEEF',SR) = PRODCOEF('EBEEFCATT','SLGHBEEF',SR)+0.6*0.045;
PRODCOEF('EBEEFCATT','SILAGE',SR) = PRODCOEF('EBEEFCATT','SILAGE',SR)+0.6*0.350;
PRODCOEF('EBEEFCATT','FEEDGRAIN',SR) = PRODCOEF('EBEEFCATT','FEEDGRAIN',SR)-0.6*0.500;
PRODCOEF('EBEEFCATT','LABOR',SR) = PRODCOEF('EBEEFCATT','LABOR',SR)+0.6*0.002;
PRODCOEF('EBEEFCAT2',IP,SR) = PRODCOEF('BEEFCATTL2',IP,SR);
PRODCOEF('EBEEFCAT2','LABOR',SR) = PRODCOEF('EBEEFCAT2','LABOR',SR)+0.6*0.002;
PRODCOEF(LIVESTOCK,'EBEEF',SR) $ECO(LIVESTOCK) = PRODCOEF(LIVESTOCK,'SLGHBEEF',SR);
*PRODCOEF('EBEEFCATT','MAXECAT',SR)  = 1;  
*PRODCOEF('BEEFCATTLE','MAXECAT',SR) = -1;  
*PRODCOEF('EBEEFCAT2','MAXECAT',SR)  = 1;  
*PRODCOEF('BEEFCATTL2','MAXECAT',SR) = -1;  
PRODCOEF('EBEEFCATT','MEBEEFCATT',SR) = 1;  
PRODCOEF('EBEEFCAT2','MEBEEFCATT',SR) = 1;  

PRODCOEF('ESHEEP',IP,SR) = PRODCOEF('SHEEP',IP,SR);
PRODCOEF('ESHEEP','OTHERFEED',SR) = PRODCOEF('SHEEP','OTHERFEED',SR) * 2;
PRODCOEF('ESHEEP','ESHEEPM',SR) = PRODCOEF('ESHEEP','SLGHSHEEP',SR);
PRODCOEF('ESHEEP','MESHEEP',SR) = 1;  

PRODCOEF('ECOPIG','EPORK',SR) = PRODCOEF('ECOPIG','SLGHPORK',SR);
PRODCOEF('ECOPIG','MECOPIG',SR) = 1;  
PRODCOEF('EPOULTRY','EEGG',SR) = PRODCOEF('EPOULTRY','EGG',SR);
PRODCOEF('EPOULTRY','MEPOULTRY',SR) = 1;  

PRODCOEF(ECO,'ACRECO',SR) = PRODCOEF(ECO,'CROPLAND',SR);
PRODCOEF(ECOCROPS,'LABOR',SR) = PRODCOEF(ECOCROPS,'LABOR',SR)*1.1;
PRODCOEF(ECOCROPS,'POWER',SR) = PRODCOEF(ECOCROPS,'POWER',SR)*1.1;
PRODCOEF('CONVACR','ACRECO',SR) = -1;
PRODCOEF('CONVACR','ACRECON',SR) = 1;

PRODCOEF(ECO,'INCONVECOV',SR) = PRODCOEF(ECO,'INCONVCOV',SR);
PRODCOEF(ECO,'INCONVCOV',SR) = 0;
PRODCOEF(ECO,'INCONVECAT',SR) = PRODCOEF(ECO,'INCONVCAT',SR);
PRODCOEF(ECO,'INCONVCAT',SR) = 0;
PRODCOEF(ECO,'INCONVELAT',SR) = PRODCOEF(ECO,'INCONVLAT',SR);
PRODCOEF(ECO,'INCONVLAT',SR) = 0;

PRODCOEF(ECO,'EGRAIN',SR) = PRODCOEF(ECO,'BREADGRAIN',SR) + PRODCOEF(ECO,'COARSGRAIN',SR)
                            + PRODCOEF(ECO,'FEEDGRAIN',SR);
PRODCOEF(ECO,'EPEAS',SR) = PRODCOEF(ECO,'PEAS',SR) + PRODCOEF(ECO,'FPEAS',SR);
PRODCOEF(ECO,'ESILAGE',SR) = PRODCOEF(ECO,'SILAGE',SR)+PRODCOEF(ECO,'HAY',SR)/1.19;
*Eco hay is added as Esilage since it is converted from silage by factor 1.19
PRODCOEF(ECO,'ESILAGEHQ',SR) = PRODCOEF(ECO,'SILAGEHQ',SR);
PRODCOEF(ECO,'EGRASSPAST',SR) = PRODCOEF(ECO,'GRASSPASTR',SR);
PRODCOEF(ECO,'EGRASSPASF',SR) = PRODCOEF(ECO,'GRASSPASTF',SR);
PRODCOEF('PPASTR','EGRASSPAST',SR)  = PRODCOEF('PPASTR','GRASSPASTR',SR);
PRODCOEF('PPASTRB','EGRASSPAST',SR) = PRODCOEF('PPASTRB','GRASSPASTR',SR);
PRODCOEF('PPASTRT','EGRASSPAST',SR) = PRODCOEF('PPASTRT','GRASSPASTR',SR);
PRODCOEF('PPASTRN','EGRASSPAST',SR) = PRODCOEF('PPASTRN','GRASSPASTR',SR);
PRODCOEF('PPASTRH','EGRASSPAST',SR) = PRODCOEF('PPASTRH','GRASSPASTR',SR);
PRODCOEF('PPASTRHB','EGRASSPAST',SR)= PRODCOEF('PPASTRHB','GRASSPASTR',SR);
PRODCOEF('PPASTRHT','EGRASSPAST',SR)= PRODCOEF('PPASTRHT','GRASSPASTR',SR);
PRODCOEF('PPASTRHN','EGRASSPAST',SR)= PRODCOEF('PPASTRHN','GRASSPASTR',SR);
PRODCOEF('PPASTRALV','EGRASSPAST',SR)= PRODCOEF('PPASTRALV','GRASSPASTR',SR);
PRODCOEF('PPASTRFOR','EGRASSPAST',SR)= PRODCOEF('PPASTRFOR','GRASSPASTR',SR);
PRODCOEF('PPASTRMOS','EGRASSPAST',SR)= PRODCOEF('PPASTRMOS','GRASSPASTR',SR);
PRODCOEF('PPASTRLOW','EGRASSPAST',SR)= PRODCOEF('PPASTRLOW','GRASSPASTR',SR);
PRODCOEF('PPASTRCHAL','EGRASSPAST',SR)= PRODCOEF('PPASTRCHAL','GRASSPASTR',SR);
PRODCOEF('PPASTRMEAD','EGRASSPAST',SR)= PRODCOEF('PPASTRMEAD','GRASSPASTR',SR);

PRODCOEF(ECO,'EDCALFM',SR)  = PRODCOEF(ECO,'DCALFM',SR);
PRODCOEF(ECO,'EDCALFF',SR)  = PRODCOEF(ECO,'DCALFF',SR);
PRODCOEF(ECO,'EDHEIFER',SR) = PRODCOEF(ECO,'DHEIFER',SR);

PRODCOEF(CROPS,'ECOSUB',SR) $ECOCROPS(CROPS)= -0.162;  
PRODCOEF('EPOTATO','ECOSUB',SR) = -0.541;
PRODCOEF(FEEDACR,'ECOSUB',SR) = 0;
PRODCOEF('ELAY','ECOSUB',SR)  = 0;
PRODCOEF('ENFIX','ECOSUB',SR) = 0;
PRODCOEF('ECOVERCROP','ECOSUB',SR) = 0;
PRODCOEF('ECATCHCROP','ECOSUB',SR) = 0;
PRODCOEF('ESPRINGTIL','ECOSUB',SR) = 0;
PRODCOEF('EDCOW1','ECOSUB',SR)   = -0.177;
PRODCOEF('EDCOW2','ECOSUB',SR)   = -0.177;
PRODCOEF('EDCOW3','ECOSUB',SR)   = -0.177;
PRODCOEF('EHEIFER','ECOSUB',SR)  = -0.98*0.177;
PRODCOEF('EDBULL1','ECOSUB',SR)  = -1.225*0.6*0.177;
PRODCOEF('EDBULL2','ECOSUB',SR)  = -0.98*0.177;
PRODCOEF('ESLGHHEIF','ECOSUB',SR)= -0.98*0.177;
PRODCOEF('EBEEFCATT','ECOSUB',SR)= -(1+0.4*1.225*0.6+0.4*0.98)*0.177;
PRODCOEF('EBEEFCAT2','ECOSUB',SR)= -(1+0.4*0.98+0.4*0.98)*0.177;
PRODCOEF('ESHEEP','ECOSUB',SR)   = -0.15*0.177;
PRODCOEF('ECOPIG','ECOSUB',SR)   = -5.15*0.177;
PRODCOEF('EPOULTRY','ECOSUB',SR) = -14*0.177;
* Amounts in Euro

*PRODCOEF(ECOCROPS,'ES1',SR)   = 0;  
PRODCOEF(ECOCROPS,'ES2',SR)   = 0;  

PRODCOEF('GSFORSIL','SILAGE',SR)    = -1;
PRODCOEF('GSFORSIL','SILAGEHQ',SR)  = -1;
PRODCOEF('GSFORSIL','GSILAGE',SR)   =  1;
PRODCOEF('GSFORSIL','SOJA',SR)      = 0.05;
PRODCOEF('MSFORSIL','SILAGE',SR)    = -1;
PRODCOEF('MSFORSIL','SILAGEHQ',SR)  = -1;
PRODCOEF('MSFORSIL','MSILAGE',SR)   =  1;
PRODCOEF('MSFORSIL','SOJA',SR)      = 0.10;

PRODCOEF('FGFORSIL','SILAGE',SR)    = -1;
PRODCOEF('FGFORSIL','FEEDGRAIN',SR) = 1;
PRODCOEF(CROPS,'MINSILAGE',SR)      = PRODCOEF(CROPS,'SILAGE',SR);
PRODCOEF(LIVESTOCK,'MINSILAGE',SR)  = PRODCOEF(LIVESTOCK,'SILAGE',SR) *0.9;

* Include plastic for silage. 0,3 ton/bale, 16 bales/roll, 1 000 SEK/Roll, only half reduced
PRODCOEF(CROPS,'PLASTIC',SR)        = -PRODCOEF(CROPS,'SILAGE',SR)/0.3/16;
*PRODCOEF(CROPS,'OTHRVARCST',SR)     =
*          PRODCOEF(CROPS,'OTHRVARCST',SR)-PRODCOEF(CROPS,'PLASTIC',SR) * 1.000/2;
* Only cost for storage include for now, plastic is part of Other var cost but to low


*** TABLE MANURE(AS,IP) 
*Reduce nitrogen for manure spread in autumn.
MANURE(AS,'NITROGEN')= MANURE(AS,'NITROGEN')*0.75;
MANURE(AS,'ECON')= MANURE(AS,'ECON')*0.90;

*Reduce potassium for better matching.
MANURE(AS,'POTASSIUM')= MANURE(AS,'POTASSIUM')*0.80;
MANURE(AS,'ECOK')= MANURE(AS,'ECOK')*0.80;

MANURE('BEEFCATTL2',IP)=MANURE('BEEFCATTLE',IP) * 1.05 * 1.05;
MANURE('EBEEFCAT2',IP)=MANURE('EBEEFCATT',IP) * 1.05 * 1.05;

PRODCOEF(AS,'NITROGEN',SR)   = PRODCOEF(AS,'NITROGEN',SR)   + MANURE(AS,'NITROGEN');
PRODCOEF(AS,'PHOSPHORUS',SR) = PRODCOEF(AS,'PHOSPHORUS',SR) + MANURE(AS,'PHOSPHORUS');
PRODCOEF(AS,'POTASSIUM',SR)  = PRODCOEF(AS,'POTASSIUM',SR)  + MANURE(AS,'POTASSIUM');
PRODCOEF(AS,'ECON',SR)   = PRODCOEF(AS,'ECON',SR)   + MANURE(AS,'ECON');
PRODCOEF(AS,'ECOP',SR)   = PRODCOEF(AS,'ECOP',SR)   + MANURE(AS,'ECOP');
PRODCOEF(AS,'ECOK',SR)   = PRODCOEF(AS,'ECOK',SR)   + MANURE(AS,'ECOK');
PRODCOEF(AS,'OTHRVARCST',SR) = PRODCOEF(AS,'OTHRVARCST',SR) + MANURE(AS,'OTHRVARCST');

*In case of crisis, organic and conventional plant nutrition can be combined
*PRODCOEF(AS,'NITROGEN',SR)   = PRODCOEF(AS,'NITROGEN',SR)   + PRODCOEF(AS,'ECON',SR);
*PRODCOEF(AS,'PHOSPHORUS',SR) = PRODCOEF(AS,'PHOSPHORUS',SR) + PRODCOEF(AS,'ECOP',SR);
*PRODCOEF(AS,'POTASSIUM',SR)  = PRODCOEF(AS,'POTASSIUM',SR)  + PRODCOEF(AS,'ECOK',SR);

*PRODCOEF(AS,'ECON',SR) = 0;
*PRODCOEF(AS,'ECOP',SR) = 0;
*PRODCOEF(AS,'ECOK',SR) = 0;

PRODCOEF(LIVESTOCK,'NITROGEN',SR) $ECO(LIVESTOCK)   = 0;
PRODCOEF(LIVESTOCK,'PHOSPHORUS',SR) $ECO(LIVESTOCK) = 0;
PRODCOEF(LIVESTOCK,'POTASSIUM',SR) $ECO(LIVESTOCK)  = 0;

PRODCOEF('USEMANURE','NITROGEN',SR)  = 1.5;
PRODCOEF('USEMANURE','PHOSPHORUS',SR)= 1;
PRODCOEF('USEMANURE','POTASSIUM',SR) = 2;
PRODCOEF('USEMANURE','ECON',SR)  = -1.5;
PRODCOEF('USEMANURE','ECOP',SR)  = -1;
PRODCOEF('USEMANURE','ECOK',SR)  = -2;
PRODCOEF('USEMANURE','MAXMANURE',SR) = 1;
PRODCOEF('USEMANURE','OTHRVARCST',SR) = 20;

$ONTEXT
PRODCOEF('COMPEMAN','ECON',SR)  = 0.015;
PRODCOEF('COMPEMAN','ECOP',SR)  = 0.006;
PRODCOEF('COMPEMAN','ECOK',SR)  = 0.025;
PRODCOEF('COMPEMAN','OTHRVARCST',SR)= 0.61/1.28;
PRODCOEF('COMPEMAN','ECOMPMAN',SR)  = -1;
PRODCOEF('COMPEMAN','ACRMANURE',SR) = -6/30;

PRODCOEF('COMPMAN','NITROGEN',SR)  = 0.015;
PRODCOEF('COMPMAN','PHOSPHORUS',SR)= 0.006;
PRODCOEF('COMPMAN','POTASSIUM',SR) = 0.025;
PRODCOEF('COMPMAN','MAXMANURE',SR) = 0.006;
PRODCOEF('COMPMAN','OTHRVARCST',SR)= 0.61/1.28;
PRODCOEF('COMPMAN','ECOMPMAN',SR)  = -1;
PRODCOEF('COMPMAN','ACRMANURE',SR) = -6/30;

PRODCOEF('UCOMPMAN','ECON',SR)  = -0.015;
PRODCOEF('UCOMPMAN','ECOP',SR)  = -0.006;
PRODCOEF('UCOMPMAN','ECOK',SR)  = -0.025;
PRODCOEF('UCOMPMAN','ECOMPMAN',SR)  = 1;
PRODCOEF('UCOMPMAN','ACRMANURE',SR) = 6/30;
$OFFTEXT

*Spridningsarealer
PRODCOEF('DCOW1','MAXMANURE',SR) = PRODCOEF('DCOW1','PHOSPHORUS',SR)*0.5;
PRODCOEF('DCOW2','MAXMANURE',SR) = PRODCOEF('DCOW2','PHOSPHORUS',SR)*0.5;
PRODCOEF('DCOW3','MAXMANURE',SR) = PRODCOEF('DCOW3','PHOSPHORUS',SR)*0.5;
PRODCOEF('DCOW4','MAXMANURE',SR) = PRODCOEF('DCOW4','PHOSPHORUS',SR)*0.5;
PRODCOEF('HEIFER','MAXMANURE',SR)= PRODCOEF('HEIFER','PHOSPHORUS',SR)*0.5;
PRODCOEF('DAIRYBULL1','MAXMANURE',SR) = PRODCOEF('DAIRYBULL1','PHOSPHORUS',SR)*0.0;
PRODCOEF('DAIRYBULL2','MAXMANURE',SR) = PRODCOEF('DAIRYBULL2','PHOSPHORUS',SR)*0.5;
PRODCOEF('SLGHHEIFER','MAXMANURE',SR) = PRODCOEF('SLGHHEIFER','PHOSPHORUS',SR)*0.5;
PRODCOEF('BEEFCATTLE','MAXMANURE',SR) = PRODCOEF('BEEFCATTLE','PHOSPHORUS',SR)*0.8*1.05;
PRODCOEF('BEEFCATTL2','MAXMANURE',SR) = PRODCOEF('BEEFCATTL2','PHOSPHORUS',SR)*0.8*1.05;
PRODCOEF('SHEEP','MAXMANURE',SR) = PRODCOEF('SHEEP','PHOSPHORUS',SR)*0.8;
PRODCOEF('SHEEP2','MAXMANURE',SR) = PRODCOEF('SHEEP2','PHOSPHORUS',SR)*0.8*0.75;
PRODCOEF('SOW1','MAXMANURE',SR) = PRODCOEF('SOW1','PHOSPHORUS',SR)*0.2;
PRODCOEF('GILT','MAXMANURE',SR) = PRODCOEF('GILT','PHOSPHORUS',SR)*0.2;
PRODCOEF('SLGHSWINE1','MAXMANURE',SR) = PRODCOEF('SLGHSWINE1','PHOSPHORUS',SR)*0.2;
PRODCOEF('POULTRY','MAXMANURE',SR) = PRODCOEF('POULTRY','PHOSPHORUS',SR)*0.5;
PRODCOEF('CHICKEN','MAXMANURE',SR) = PRODCOEF('CHICKEN','PHOSPHORUS',SR)*0.8;
*PRODCOEF(LIVESTOCK,'MAXMANURE',SR) = 0;

*Lägre krav på timlön, ffa dikor
PRODCOEF(DCOWS,'LABOR2',SR) = PRODCOEF(DCOWS,'LABOR',SR);
PRODCOEF('HEIFER','LABOR2',SR) = PRODCOEF('HEIFER','LABOR',SR);
PRODCOEF('DAIRYBULL1','LABOR2',SR) = PRODCOEF('DAIRYBULL1','LABOR',SR);
PRODCOEF('DAIRYBULL2','LABOR2',SR) = PRODCOEF('DAIRYBULL2','LABOR',SR);
PRODCOEF('SLGHHEIFER','LABOR2',SR) = PRODCOEF('SLGHHEIFER','LABOR',SR);
PRODCOEF('SOW1','LABOR2',SR) = PRODCOEF('SOW1','LABOR',SR);
PRODCOEF('GILT','LABOR2',SR) = PRODCOEF('GILT','LABOR',SR);
PRODCOEF('SLGHSWINE1','LABOR2',SR) = PRODCOEF('SLGHSWINE1','LABOR',SR);
PRODCOEF('POULTRY','LABOR2',SR) = PRODCOEF('POULTRY','LABOR',SR);
PRODCOEF('CHICKEN','LABOR2',SR) = PRODCOEF('CHICKEN','LABOR',SR);
PRODCOEF('EHEIFER','LABOR2',SR) = PRODCOEF('EHEIFER','LABOR',SR);
PRODCOEF('EDBULL1','LABOR2',SR) = PRODCOEF('EDBULL1','LABOR',SR);
PRODCOEF('EDBULL2','LABOR2',SR) = PRODCOEF('EDBULL2','LABOR',SR);
PRODCOEF('ESLGHHEIF','LABOR2',SR)=PRODCOEF('ESLGHHEIF','LABOR',SR);
PRODCOEF('ECOPIG','LABOR2',SR)  = PRODCOEF('ECOPIG','LABOR',SR);
PRODCOEF('EPOULTRY','LABOR2',SR)= PRODCOEF('EPOULTRY','LABOR',SR);

PRODCOEF('DAIRYFEXN','LABOR2',SR) = PRODCOEF('DAIRYFEXN','LABOR',SR);
PRODCOEF('BULLFEXN','LABOR2',SR)  = PRODCOEF('BULLFEXN','LABOR',SR);
PRODCOEF('BEEFCFEXN','LABOR2',SR) = PRODCOEF('BEEFCATTLE','LABOR',SR)+ PRODCOEF('BEEFCFEXN','LABOR',SR);
PRODCOEF('SOWFEXN','LABOR2',SR)   = PRODCOEF('SOWFEXN','LABOR',SR);
PRODCOEF('SWINEFEXN','LABOR2',SR) = PRODCOEF('SWINEFEXN','LABOR',SR);
PRODCOEF('PLTRYFEXN','LABOR2',SR) = PRODCOEF('PLTRYFEXN','LABOR',SR);
PRODCOEF('DAIRYFEXR','LABOR2',SR) = PRODCOEF('DAIRYFEXR','LABOR',SR);
PRODCOEF('BULLFEXR','LABOR2',SR)  = PRODCOEF('BULLFEXR','LABOR',SR);
PRODCOEF('SOWFEXR','LABOR2',SR)   = PRODCOEF('SOWFEXR','LABOR',SR);
PRODCOEF('SWINEFEXR','LABOR2',SR) = PRODCOEF('SWINEFEXR','LABOR',SR);
PRODCOEF('PLTRYFEXR','LABOR2',SR) = PRODCOEF('PLTRYFEXR','LABOR',SR);

*PRODCOEF(CROPS,'LABOR2',SR) = PRODCOEF(CROPS,'LABOR',SR);

* Reduce environmental impact over time
PRODCOEF(CROPS,emissions,SR) $ (LONGRUN2)     = PRODCOEF(CROPS,emissions,SR) * 0.995**YRT;
PRODCOEF(LIVESTOCK,emissions,SR) $ (LONGRUN2) = PRODCOEF(LIVESTOCK,emissions,SR) * 0.995**YRT;

* Separate diesel from POWER as 15 l/h
PRODCOEF(AS,'DIESEL',SR) = PRODCOEF(AS,'POWER',SR)*15;
PRODCOEF(AS,'DIESEL',SR) $(LONGRUN2) = PRODCOEF(AS,'DIESEL',SR)* 0.995**YRT/0.985**YRT;

* Include more climate effects
PRODCOEF(AS,'CO2',SR)    = PRODCOEF(AS,'CO2',SR)
                                + PRODCOEF(AS,'DIESEL',SR) * (2.736 + 0.216 $CO2IMP);
PRODCOEF(CROPS,'N2O',SR) = (PRODCOEF(CROPS,'NITROGEN',SR) + PRODCOEF(CROPS,'ECON',SR)) * 0.02;
*PRODCOEF(AS,'CO2',SR) $CO2IMP = PRODCOEF(AS,'CO2',SR) + PRODCOEF(AS,'NITROGEN',SR) * 3.65;

* Conversion to carbon dioxide equivalents
PRODCOEF(AS,'CO2EQ',SR) = PRODCOEF(AS,'CO2EQ',SR) + PRODCOEF(AS,'CH4',SR)*25
    + PRODCOEF(AS,'N2O',SR)*298 + PRODCOEF(AS,'CO2',SR)*1 + PRODCOEF(AS,'CBONDING',SR)*3.67 ;


***TILL SCENARIO-FIL 
* No leakage calculated in optimisation
*PRODCOEF(AS,'NLEAKAGE',SR)        = 0;
*PRODCOEF(AS,'PLEAKAGE',SR)        = 0;


*** TABLE CONST(IP,AS) Constraints on crop rotation etc.
CONST('MAXPOTACR','POTATO') =  1;
CONST('MINLFOR','FORAGE3') =  -1;
CONST('MINLFOR','FORAGE4') =  -1;
CONST('MINLFOR','PASTURE2') =  -1;
CONST('MINLFOR','SPAREFOR') =  -1;

*CONST('MINCACR',CROPS)     =  -1;
*CONST('MINCACR','ECOPIG')  =  -0.4;
*CONST('MINCACR','EPOULTRY')=  -2;
CONST('MINPAST',PASTURES)  =  -1;
CONST('MINPASTN',PASTURES) =  -1;

*CONST('MINLAY',CROPS)     =  0.05;
*CONST('MINLAY','FORAGE4') =  0;
*CONST('MINLAY','FORAGE3') =  0;
*CONST('MINLAY','PASTURE2')=  0;
*CONST('MINLAY','SPAREFOR')=  0;
*CONST('MINLAY','LAY')     = -0.93;
*CONST('MINLAY','LONGLAY') = -0.95;
*CONST('MAXLAY','LONGLAY') = 0.5;

*CONST('MAXFOR','FORAGE4')     =  0.30;
*CONST('MAXFOR','SPAREFOR')    =  0.30;
*CONST('MAXFOR','ICR')         = -0.70;
*CONST('MAXFOR','NOUSE')       = -0.70;
*CONST('MINGRAIN','FORAGE4')     =  0.10;
*CONST('MINGRAIN','SPAREFOR')    =  0.10;
*CONST('MINGRAIN','ICR')         =  0.10;
*CONST('MINGRAIN','NOUSE')       =  0.10;
*CONST('MINGRAIN','LONGLAY')     =  0.10;
*CONST('MINLAY','FEEDPEAS')    =  0.10;
*CONST('MAXLAY','FEEDPEAS')    = -0.5;
CONST('MAXSALIX','SALIX')     = 1;
CONST('MINSALIX','SALIX')     = -1;

CONST('MINNEWFOR','CATCHCROP') = 1;
*CONST('MAXCOVER','CATCHCROP') = 1;
*CONST('MAXCATCH','CATCHCROP') = 1;
CONST('MAXLATE','SPRINGTILL') = 1;
CONST('MINENEWFOR','ECATCHCROP') = 1;
*CONST('MAXECOVER','ECATCHCROP') = 1;
*CONST('MAXECATCH','ECATCHCROP') = 1;
CONST('MAXELATE','ESPRINGTIL') = 1;

*=============================
* Combine PRODCOEF and CONST into EAS

* PARAMETER EAS(R,SR,AS,IP)  Unit input and product coef for subregional crop and livestock prod act;
EAS(R,SR,AS,IP)$RSRAS(R,SR,AS) = PRODCOEF(AS,IP,SR) + CONST(IP,AS);

* Regional differences in crop rotations
EAS(R,SA01TO05,'COVERCROP','MINNEWFOR') = 0;
EAS(R,SA01TO05,'ECOVERCROP','MINENEWFOR') = 0;
EAS(R,SA01TO12,'CATCHCROP','MINNEWFOR') = 0;
EAS(R,SA01TO12,'ECATCHCROP','MINENEWFOR') = 0;
EAS(R,SR,'W-RAPE','MAXOILG')     $ (RSR(R,SR) and SASR('SA13gss',SR)) = 0.5;
EAS(R,SR,'S-RAPE','MAXOILG')     $ (RSR(R,SR) and SASR('SA13gss',SR)) = 0.5;
EAS(R,SR,'FORAGE1','MAXOILG')    $ (RSR(R,SR) and SA01TO12(SR))       = 0;
EAS(R,SR,'FORAGE2','MAXOILG')    $ (RSR(R,SR) and SA01TO12(SR))       = 0;
EAS(R,SR,'FORAGE1','MAXWOILG')   $ (RSR(R,SR) and SA01TO12(SR))       = 0;
EAS(R,SR,'FORAGE2','MAXWOILG')   $ (RSR(R,SR) and SA01TO12(SR))       = 0;
EAS(R,SR,'EFORAGE1','MAXEOILG')  $ (RSR(R,SR) and SA01TO12(SR))       = 0;
EAS(R,SR,'EFORAGE2','MAXEOILG')  $ (RSR(R,SR) and SA01TO12(SR))       = 0;
EAS(R,SR,'EFORAGE1','MAXEWOILG') $ (RSR(R,SR) and SA01TO12(SR))       = 0;
EAS(R,SR,'EFORAGE2','MAXEWOILG') $ (RSR(R,SR) and SA01TO12(SR))       = 0;
EAS(R,SR,'BARLEY','MAXWWHEAT')   $ (RSR(R,SR) and SASR('SA13s',SR))   = -1;
EAS(R,SR,'OATS','MAXWWHEAT')     $ (RSR(R,SR) and SASR('SA13s',SR))   = -1;
EAS(R,SR,'W-RAY','MAXWWHEAT')    $ (RSR(R,SR) and SASR('SA13s',SR))   =  1;
*EAS(R,SR0s,'W-BARLEY','MAXWWHEAT') $RSR(R,SR0s) = 0.5;
 
* Make it possible to seed forage in lay in subregions 1, 2, 3, 4a and 7b
EAS(R,SR,'LAY','MINNEWFOR')      $ (RSR(R,SR) and SA01TO04a(SR))      = -1; 
EAS(R,SR,'LAY','MINNEWFOR')      $ (RSR(R,SR) and SASR('SA07b',SR))   = -1; 
 
EAS(R,SR,'ELAY','MINENEWFOR')    $ (RSR(R,SR) and SA01TO04a(SR))      = -1; 
EAS(R,SR,'ELAY','MINENEWFOR')    $ (RSR(R,SR) and SASR('SA07b',SR))   = -1; 
 
*EAS(R,SA01TO12,AS,'MINLAY')  = 0;
*EAS(R,SA01TO12,AS,'EMINLAY') = 0;

* Calculate needed pasturing
EAS(R,SR,LIVESTOCK,'USEPASTR') = EAS(R,SR,LIVESTOCK,'GRASSPASTF')-EAS(R,SR,LIVESTOCK,'GRASSPASTR');

*================================= 
*REGIONAL
*==================================

*** TABLE ECR(R,CR,IP)  Unit input and product coef for regional processing activities
*** TABLE ECR2(R,CR,IP)  Unit input and product coef for regional retail activities
*** TABLE ECR3(R,CR,IP)  Unit input and product coef for regional production activities
ECR(R,CR,IP) = ECR('R1',CR,IP) + ECR2('R1',CR,IP)+ ECR3('R1',CR,IP);


*** TABLE NUTRIENT(P,*)  Content of nutrients in products (KJ per 100g or g per 100g)


* Calculate the nutrient content of produced food
ECR(R,CR,'ENERGY') = SUM(P $(NUTRIENT(P,'ENERG') GT 0), ECR(R,CR,P)*NUTRIENT(P,'ENERG'))*10/1000000;
ECR(R,CR,'PROTEIN')= SUM(P $(NUTRIENT(P,'PROT') GT 0),  ECR(R,CR,P)*NUTRIENT(P,'PROT')) *10/1000;
ECR(R,CR,'PROTEINA')=SUM(P $(NUTRIENT(P,'PROTA') GT 0), ECR(R,CR,P)*NUTRIENT(P,'PROTA'))*10/1000;
ECR(R,CR,'FAT')    = SUM(P $(NUTRIENT(P,'FAT2') GT 0),  ECR(R,CR,P)*NUTRIENT(P,'FAT2')) *10/1000;
ECR(R,CR,'CARBOH') = SUM(P $(NUTRIENT(P,'CARB') GT 0),  ECR(R,CR,P)*NUTRIENT(P,'CARB')) *10/1000;


*** TABLE BIN(IN,SDP)  National input supply parameters
BIN('POWER','PBAR')           = BIN('POWER','PBAR')  / 2;
BIN('POWER','PBAR')$LONGRUN   = BIN('POWER','PBAR')  * 2;
* Low cost for power in short term analyses

*EAS(R,SR,PASTURES,'OTHRVARCST')$LONGRUN  = EAS(R,SR,PASTURES,'OTHRVARCST')
*           - EAS(R,SR,PASTURES,'POWER')* BIN('POWER','PBAR') / 2;
* Reduce cost for power in long run analyses. Costs added as acr cost

BIN('POWER','PBAR')$LONGRUN1  = BIN('POWER','PBAR')  * 1.02**(YR-4);
BIN('POWER','PBAR')$LONGRUN2  = BIN('POWER','PBAR')  * 1.0037**YRT;
* Larger but more expensive machines. Extra productivity development introduced above.
* Diesel adjusted above.
BIN('DIESEL','PBAR')$LONGRUN1 = (BIN('DIESEL','PBAR')+ 1.700) * 1.066 - 3.844/KPI2;
* Tax refund 2017 added. Calculated with real price increase from Outlook. Tax refund 2023 subtracted.

* Inputs follows world price predicted by OECD 
BIN('PESTICIDES','PBAR')$LONGRUN1 = BIN('PESTICIDES','PBAR') * 1;
BIN('LABOR2','PBAR')$LONGRUN1 = BIN('LABOR2','PBAR') * 1.032 * 2;
* Extra increase of salary due to inflation
BIN(IN,'PBAR') = BIN(IN,'PBAR') * KPI3; 
BIN('DPTRANC','PBAR') = BIN('DPTRANC','PBAR') / KPI3; 

*** TABLE BIRF(IR,R)  Regional supply of fixed inputs
* Add 25 % overcapacity
BIRF('PCAPKMILK',R)  = (BIRF('PCAPKMILK',R))  * 1.25;
BIRF('PCAPCHEESE',R) = (BIRF('PCAPCHEESE',R)) * 1.25;
BIRF('PCAPBUTTER',R) = (BIRF('PCAPBUTTER',R)) * 1.25;
BIRF('PCAPDRYMLK',R) = (BIRF('PCAPDRYMLK',R)) * 1.25;

* Convert share in procent to weight and add 25 % overcapacity
BIRF('PCAPBEEF',R) = (BIRF('PCAPBEEF',R)/100) * 130 * 1.25;
BIRF('PCAPPORK',R) = (BIRF('PCAPPORK',R)/100) * 235 * 1.25;
BIRF('PCAPPLTRY',R)= (BIRF('PCAPPLTRY',R)/100)* 156 * 1.25;
BIRF('PCAPMILL',R) = (BIRF('PCAPMILL',R)/100) * 450 * 1.25;
BIRF('PCAPFEED',R) = (BIRF('PCAPFEED',R)/100) * 1.2 * 2900 * 1.25;


*** TABLE BIRI(IR,R)  Regional prices of inputs with infinite price elasticity
BIRI(IR,'R2') = BIRI(IR,'R2') *1.1;
BIRI(IR,'R1') = BIRI(IR,'R1') *1.2;
BIRI('PROTFEED','R2') = BIRI('PROTFEED','R2') /1.1;
BIRI('PROTFEED','R1') = BIRI('PROTFEED','R1') /1.2;

* Replaced by year-indexed price tables (pricesInputs):
*BIRI('SOJA',R)      = BIRI('SOJA',R)      * 1.198 * 1.2;
*BIRI('LABOR',R)$LONGRUN1      = BIRI('LABOR',R)      * 1.032;
*BIRI('NITROGEN',R)$LONGRUN1   = BIRI('NITROGEN',R)   * 1.100;
*BIRI('PHOSPHORUS',R)$LONGRUN1 = BIRI('PHOSPHORUS',R) * 1.100 * 1.3;
*BIRI('POTASSIUM',R)$LONGRUN1  = BIRI('POTASSIUM',R)  * 1.100 * 1.3;
*BIRI('SOJA',R)$LONGRUN1      = BIRI('SOJA',R)       * 0.800 * 0.743;
*BIRI('BETFOR',R)$LONGRUN1     = BIRI('BETFOR',R)     * 0.978;
*BIRI('HPMASSA',R)$LONGRUN1   = BIRI('HPMASSA',R)   * 0.978;


*** TABLE BIR(R,IR,SDP)  Regional input supply parameters
BIR(R,IR,'MAX') $(BIRF(IR,R) GT 0) = BIRF(IR,R);
BIR(R,IR,'PBAR')$(BIRI(IR,R) GT 0) = BIRI(IR,R);
BIR(R,IR,'MAX') $(BIRI(IR,R) GT 0) = INF;
BIR(R,IR,'ELAS')$(BIRI(IR,R) GT 0) = 999;

BIR(R,'HPMASSA','MAX') = 0.001;
BIR('R1','HPMASSA','MAX') = 0;
BIR('R2','HPMASSA','MAX') = 0;
BIR('R3','HPMASSA','MAX') = 0;
BIR('R4','HPMASSA','MAX') = 0.001;
BIR('R5','HPMASSA','MAX') = 0.001;
BIR('R6','HPMASSA','MAX') = 0.001;

BIR(R,IR,'PBAR') = BIR(R,IR,'PBAR') * KPI3;
BIR(R,'OILGRSEED','PBAR') = BIR(R,'OILGRSEED','PBAR') / KPI3;
BIR(R,'POTATOSEED','PBAR') = BIR(R,'POTATOSEED','PBAR') / KPI3;
BIR(R,'SUGARBSEED','PBAR') = BIR(R,'SUGARBSEED','PBAR') / KPI3;

* Load PBAR from year-indexed price tables for IR inputs (already in 2024 nominal prices)
BIR(R,IR,'PBAR')$(sum(TIME$(TIME.val eq YEAR), pricesInputs('R6',IR,TIME)) gt 0)
    = sum(TIME$(TIME.val eq YEAR), pricesInputs('R6',IR,TIME));
* Override with region-specific values where available (e.g. HPMASSA R4/R5)
BIR(R,IR,'PBAR')$(sum(TIME$(TIME.val eq YEAR), pricesInputs(R,IR,TIME)) gt 0
                  and not sameas(R,'R6'))
    = sum(TIME$(TIME.val eq YEAR), pricesInputs(R,IR,TIME));
* Re-apply northern regional surcharges
BIR('R2',IR,'PBAR')$(sum(TIME$(TIME.val eq YEAR), pricesInputs('R6',IR,TIME)) gt 0)
    = BIR('R2',IR,'PBAR') * 1.1;
BIR('R1',IR,'PBAR')$(sum(TIME$(TIME.val eq YEAR), pricesInputs('R6',IR,TIME)) gt 0)
    = BIR('R1',IR,'PBAR') * 1.2;
* PROTFEED has no regional surcharge
BIR('R2','PROTFEED','PBAR') = BIR('R2','PROTFEED','PBAR') / 1.1;
BIR('R1','PROTFEED','PBAR') = BIR('R1','PROTFEED','PBAR') / 1.2;

* Load PBAR from year-indexed price tables for IN inputs (R6 value is national base)
BIN(IN,'PBAR')$(sum(TIME$(TIME.val eq YEAR), pricesInputs('R6',IN,TIME)) gt 0)
    = sum(TIME$(TIME.val eq YEAR), pricesInputs('R6',IN,TIME));

* Apply price adjustments from settings.gms (section 7)
BIR(R,IR,'PBAR')$(BIR(R,IR,'PBAR') gt 0 and inputPricePct(IR) ne 0)
    = BIR(R,IR,'PBAR') * (1 + inputPricePct(IR));
BIN(IN,'PBAR')$(BIN(IN,'PBAR') gt 0 and inputPricePct(IN) ne 0)
    = BIN(IN,'PBAR') * (1 + inputPricePct(IN));


*** TABLE BISFA(SR,IS)  Subregional supply of fixed inputs
BISFA(SR,'SUGARQUOTA') $ SASR('SA13s',SR) = BISFA(SR,'CROPLAND') * 0.06;
BISFA(SR,'MAXPOTACR')   = BISFA(SR,'CROPLAND')   * 0.05;


** PARAMETER BISF(R,SR,IS)  Subegional input supply parameters;
BISF(R,SR,IS)$RSR(R,SR) = BISFA(SR,IS);

BISF(R,SR,'PLTRYFAC')$RSR(R,SR) = BISF(R,SR,'PLTRYFAC')/1000;
BISF(R,SR,'CHICKFAC')$RSR(R,SR) = BISF(R,SR,'CHICKFAC')/1000;
BISF(R,SR,'CHICKFAC')$RSR(R,SR) = BISF(R,SR,'CHICKFAC')*1.33*1.10;
* One quarter of facilities are empty for cleaning and not reported in statistics
* Increased 10 % for production level of 2023

BISF(R,SR,'SOWFAC')$RSR(R,SR) = BISF(R,SR,'SOWFAC')*0.975;
BISF(R,SR,'SWINEFAC')$RSR(R,SR) = BISF(R,SR,'SWINEFAC')*0.975;
* No facilities for organic pigs

* The potential sheep facilities have been doubled as there is free capacity
BISF(R,SR,'SHEEPFAC')$RSR(R,SR) = BISF(R,SR,'SHEEPFAC')*2;

*BISF(R,SR,'MAXPOTACR')$RSR(R,SR) = BISF(R,SR,'MAXPOTACR')*1.25;

* Reduce acreage for roads etc (not active for calqulations 2020)
* Data from "Metodbeskrivning klimatrapportering"
BISF(R,SR,'CROPLAND')$LONGRUN  = BISF(R,SR,'CROPLAND')  * 0.9973**YRA; 
BISF(R,SR,'PRMPAST')$LONGRUN   = BISF(R,SR,'PRMPAST')   * 0.998**YRA; 
BISF(R,SR,'PRMPASTT')$LONGRUN  = BISF(R,SR,'PRMPASTT')  * 0.998**YRA; 
BISF(R,SR,'PRMPASTN')$LONGRUN  = BISF(R,SR,'PRMPASTN')  * 0.998**YRA; 
BISF(R,SR,'PRMALV')$LONGRUN    = BISF(R,SR,'PRMALV')    * 0.998**YRA; 
BISF(R,SR,'PRMFOR')$LONGRUN    = BISF(R,SR,'PRMFOR')    * 0.998**YRA; 
BISF(R,SR,'PRMMOS')$LONGRUN    = BISF(R,SR,'PRMMOS')    * 0.998**YRA; 
BISF(R,SR,'PRMLOW')$LONGRUN    = BISF(R,SR,'PRMLOW')    * 0.998**YRA; 
BISF(R,SR,'PRMCHAL')$LONGRUN   = BISF(R,SR,'PRMCHAL')   * 0.998**YRA; 
BISF(R,SR,'PRMMEAD')$LONGRUN   = BISF(R,SR,'PRMMEAD')   * 0.998**YRA; 
BISF(R,SR,'PRMPASTUP')$LONGRUN = BISF(R,SR,'PRMPASTUP') * 0.998**YRA; 
BISF(R,SR,'POTPAST')$LONGRUN   = BISF(R,SR,'POTPAST')   * 0.998**YRA; 
BISF(R,SR,'POTPASTT')$LONGRUN  = BISF(R,SR,'POTPASTT')  * 0.998**YRA; 
BISF(R,SR,'POTPASTN')$LONGRUN  = BISF(R,SR,'POTPASTN')  * 0.998**YRA; 
BISF(R,SR,'POTALV')$LONGRUN    = BISF(R,SR,'POTALV')    * 0.998**YRA; 
BISF(R,SR,'POTFOR')$LONGRUN    = BISF(R,SR,'POTFOR')    * 0.998**YRA; 
BISF(R,SR,'POTMOS')$LONGRUN    = BISF(R,SR,'POTMOS')    * 0.998**YRA; 
BISF(R,SR,'POTLOW')$LONGRUN    = BISF(R,SR,'POTLOW')    * 0.998**YRA; 
BISF(R,SR,'POTCHAL')$LONGRUN   = BISF(R,SR,'POTCHAL')   * 0.998**YRA; 
BISF(R,SR,'POTMEAD')$LONGRUN   = BISF(R,SR,'POTMEAD')   * 0.998**YRA; 

* Board of Agriculture has limited the conversion of cropland to pasture since 2023,
* therefore YRA is replaced by 2 years below.
* BISF(R,SR,'MAXCRTOPST')$LONGRUN= BISF(R,SR,'CROPLAND')  * 0.004*YRA;
BISF(R,SR,'MAXCRTOPST')$LONGRUN= BISF(R,SR,'CROPLAND')  * 0.004*2;

* adjust to lover level after deregulation
BISF(R,SR,'SUGARQUOTA') = BISF(R,SR,'SUGARQUOTA')  * 0.8; 
* increase quota since system is abandoned. Limit expansion to 5 percent. Adjust for yield increase
BISF(R,SR,'SUGARQUOTA')$LONGRUN = BISF(R,SR,'SUGARQUOTA')  * 1.05 / 1.005**YRT; 

* Limits salix to maximum X percent of acreage
BISF(R,SR,'MAXSALIX') = BISF(R,SR,'CROPLAND') * 0.007; 
*BISF('R5',SR0s,'MAXSALIX') = BISF('R5',SR0s,'CROPLAND') * 0.20; 
*BISF('R4',SR0s,'MAXSALIX') = BISF('R4',SR0s,'CROPLAND') * 0.30; 
BISF(R,SA01TO07b,'MAXSALIX') = 0; 

* Include bull facilities and adds 25 percent extra for regional redistribution
BISF(R,SR,'BULLFAC') = BISF(R,SR,'BEEFCFAC') + BISF(R,SR,'DAIRYFAC')*0.775;
BISF(R,SR,'BULLFAC') = BISF(R,SR,'BULLFAC') * 1.25; 
BISF(R,SR,'ECON') = 0;
BISF(R,SR,'ECOP') = 0;
BISF(R,SR,'ECOK') = 0;
BISF(R,SR,'MAXMANURE') = 0;

* Regional share of cropland in organic production 2016 
BISF('R1',SR,'ACRECO')  = BISF('R1',SR,'CROPLAND') * 0.098 * 1.18;
BISF('R2',SR,'ACRECO')  = BISF('R2',SR,'CROPLAND') * 0.230 * 1.18;
BISF('R3',SR,'ACRECO')  = BISF('R3',SR,'CROPLAND') * 0.145 * 1.13;
BISF('R4',SR,'ACRECO')  = BISF('R4',SR,'CROPLAND') * 0.220 * 1.13;
BISF('R5',SR,'ACRECO')  = BISF('R5',SR,'CROPLAND') * 0.100 * 1.18;
BISF('R6',SR,'ACRECO')  = BISF('R6',SR,'CROPLAND') * 0.047 * 1.18;

* Regional share of livestock in organic production 2016 
BIR('R1','MEDCOW','MAX')  = SUM(SR $RSR('R1',SR), BISF('R1',SR,'DAIRYFAC') * 0.10);
BIR('R2','MEDCOW','MAX')  = SUM(SR $RSR('R2',SR), BISF('R2',SR,'DAIRYFAC') * 0.20);
BIR('R3','MEDCOW','MAX')  = SUM(SR $RSR('R3',SR), BISF('R3',SR,'DAIRYFAC') * 0.30);
BIR('R4','MEDCOW','MAX')  = SUM(SR $RSR('R4',SR), BISF('R4',SR,'DAIRYFAC') * 0.25);
BIR('R5','MEDCOW','MAX')  = SUM(SR $RSR('R5',SR), BISF('R5',SR,'DAIRYFAC') * 0.09);
BIR('R6','MEDCOW','MAX')  = SUM(SR $RSR('R6',SR), BISF('R6',SR,'DAIRYFAC') * 0.09);

BIR('R1','MEBEEFCATT','MAX')  = SUM(SR $RSR('R1',SR), BISF('R1',SR,'BEEFCFAC') * 0.40);
BIR('R2','MEBEEFCATT','MAX')  = SUM(SR $RSR('R2',SR), BISF('R2',SR,'BEEFCFAC') * 0.52);
BIR('R3','MEBEEFCATT','MAX')  = SUM(SR $RSR('R3',SR), BISF('R3',SR,'BEEFCFAC') * 0.50);
BIR('R4','MEBEEFCATT','MAX')  = SUM(SR $RSR('R4',SR), BISF('R4',SR,'BEEFCFAC') * 0.50);
BIR('R5','MEBEEFCATT','MAX')  = SUM(SR $RSR('R5',SR), BISF('R5',SR,'BEEFCFAC') * 0.23);
BIR('R6','MEBEEFCATT','MAX')  = SUM(SR $RSR('R6',SR), BISF('R6',SR,'BEEFCFAC') * 0.14);

BIR('R1','MESHEEP','MAX')  = SUM(SR $RSR('R1',SR), BISF('R1',SR,'SHEEPFAC') * 0.25)/2;
BIR('R2','MESHEEP','MAX')  = SUM(SR $RSR('R2',SR), BISF('R2',SR,'SHEEPFAC') * 0.28)/2;
BIR('R3','MESHEEP','MAX')  = SUM(SR $RSR('R3',SR), BISF('R3',SR,'SHEEPFAC') * 0.22)/2;
BIR('R4','MESHEEP','MAX')  = SUM(SR $RSR('R4',SR), BISF('R4',SR,'SHEEPFAC') * 0.24)/2;
BIR('R5','MESHEEP','MAX')  = SUM(SR $RSR('R5',SR), BISF('R5',SR,'SHEEPFAC') * 0.20)/2;
BIR('R6','MESHEEP','MAX')  = SUM(SR $RSR('R6',SR), BISF('R6',SR,'SHEEPFAC') * 0.16)/2;

BIR('R1','MECOPIG','MAX')  = SUM(SR $RSR('R1',SR), BISF('R1',SR,'SOWFAC') * 0.01);
BIR('R2','MECOPIG','MAX')  = SUM(SR $RSR('R2',SR), BISF('R2',SR,'SOWFAC') * 0.02);
BIR('R3','MECOPIG','MAX')  = SUM(SR $RSR('R3',SR), BISF('R3',SR,'SOWFAC') * 0.03);
BIR('R4','MECOPIG','MAX')  = SUM(SR $RSR('R4',SR), BISF('R4',SR,'SOWFAC') * 0.03);
BIR('R5','MECOPIG','MAX')  = SUM(SR $RSR('R5',SR), BISF('R5',SR,'SOWFAC') * 0.02);
BIR('R6','MECOPIG','MAX')  = SUM(SR $RSR('R6',SR), BISF('R6',SR,'SOWFAC') * 0.02);

BIR(R,'MEPOULTRY','MAX')  = SUM(SR $RSR(R,SR), BISF(R,SR,'PLTRYFAC') * 0.16);
BIR(R,'MINEACR','MIN')    = SUM(SR $RSR(R,SR), BISF(R,SR,'ACRECO'));

* Regional capacity for potato seed production 
BIR('R1','PCAPPOTS','MAX') = SUM(SR $RSR('R1',SR), BISF('R1',SR,'CROPLAND') * 0.01 * 2.500 * 0.33);
BIR('R2','PCAPPOTS','MAX') = SUM(SR $RSR('R2',SR), BISF('R2',SR,'CROPLAND') * 0.01 * 2.500 * 0.33);
BIR('R3','PCAPPOTS','MAX') = SUM(SR $RSR('R3',SR), BISF('R3',SR,'CROPLAND') * 0.01 * 2.500 * 0.33);
BIR('R4','PCAPPOTS','MAX') = SUM(SR $RSR('R4',SR), BISF('R4',SR,'CROPLAND') * 0.01 * 2.500 * 0.33);
BIR('R5','PCAPPOTS','MAX') = SUM(SR $RSR('R5',SR), BISF('R5',SR,'CROPLAND') * 0.01 * 2.500 * 0.33);
BIR('R6','PCAPPOTS','MAX') = SUM(SR $RSR('R6',SR), BISF('R6',SR,'CROPLAND') * 0.01 * 2.500 * 0.33);
* 1 percent of the area with potatoes, 2,500 SEK/ha, 1/3 from Sweden

* Separates permanent pasture area by productivity
BISF(R,SR,'PRMPASTH')  = BISF(R,SR,'PRMPAST')   * 0.5;
BISF(R,SR,'PRMPAST')   = BISF(R,SR,'PRMPAST')   * 0.5;
BISF(R,SR,'PRMPASTHT') = BISF(R,SR,'PRMPASTT')  * 0.5;
BISF(R,SR,'PRMPASTT')  = BISF(R,SR,'PRMPASTT')  * 0.5;
BISF(R,SR,'PRMPASTHN') = BISF(R,SR,'PRMPASTN')  * 0.5;
BISF(R,SR,'PRMPASTN')  = BISF(R,SR,'PRMPASTN')  * 0.5;
BISF(R,SR,'PRMPASTHUP')= BISF(R,SR,'PRMPASTUP') * 0.5;
BISF(R,SR,'PRMPASTUP') = BISF(R,SR,'PRMPASTUP') * 0.5;

BISF(R,SR,'SWINEFAC')  = BISF(R,SR,'SWINEFAC')*1.20;
* Swinefac is adjusted for expected underestimation (empty facilities between groups)


** PARAMETER BIS(R,SR,IS,SDP)  Subregional input supply;
BIS(R,SR,IS,'MAX')$RSR(R,SR) = BISF(R,SR,IS);
BIS(R,SR,'NLEAKAGE','MAX')$RSR(R,SR) = INF;
BIS(R,SR,'NLEAKAGE','PBAR')$RSR(R,SR) = 0.0001;
*BIS(R,SR,'NLEAKAGE','PBAR')$RSR(R,SR) = 31;
BIS(R,SR,'PLEAKAGE','MAX')$RSR(R,SR) = INF;
BIS(R,SR,'PLEAKAGE','PBAR')$RSR(R,SR) = 0.0001;
*BIS(R,SR,'PLEAKAGE','PBAR')$RSR(R,SR) = 1023;
BIS(R,SR,'ECON','MAX')$RSR(R,SR) = INF;
*BIS(R,SR,'ECON','MAX')$RSR(R,SR) = 15.652*BISF(R,SR,'ACRECO')/412.505*1;
BIS(R,SR,'ECON','PBAR')$RSR(R,SR) = 30;
BIS(R,SR,'ECOP','MAX')$RSR(R,SR) = INF;
*BIS(R,SR,'ECOP','MAX')$RSR(R,SR) =  0.217*BISF(R,SR,'ACRECO')/412.505*1*2;
BIS(R,SR,'ECOP','PBAR')$RSR(R,SR) = 20;
BIS(R,SR,'ECOK','MAX')$RSR(R,SR) = INF;
*BIS(R,SR,'ECOK','MAX')$RSR(R,SR) =  1.133*BISF(R,SR,'ACRECO')/412.505*1;
BIS(R,SR,'ECOK','PBAR')$RSR(R,SR) = 10;

$ONTEXT
BIS(R,SR,'ACRCOST','ELAS')$RSR(R,SR) = 1;
BIS(R,SR,'ACRCOST','PBAR')$RSR(R,SR) = 0.009*25 + EAS(R,SR,'BARLEY','LABOR')*30;
BIS(R,SR,'ACRCOST','PBAR')$(RSR(R,SR) $LONGRUN) = 0.009*100 + EAS(R,SR,'BARLEY','LABOR')*30;
BIS(R,SR,'ACRCOST','PBAR')$(RSR(R,SR) $LONGRUN2)= 0.009*0.985**YRT*100*1.0 
                                                   + EAS(R,SR,'BARLEY','LABOR')*1.0037**YRT*30;
BIS(R,SR,'ACRCOST','QBAR')$RSR(R,SR) = BISF(R,SR,'CROPLAND');
BIS(R,SR,'ACRCOST','MAX')$RSR(R,SR)  = BIS(R,SR,'ACRCOST','QBAR')$RSR(R,SR)+0.001;
$OFFTEXT
* Other variable costs are reduced and re entered as average for increasing acreage costs


* Increasing marginal cost for using pasture (set-based, replaces 12 individual blocks)
EAS(R,SR,AS,'OTHRVARCST')$(RSRAS(R,SR,AS) and sum(IS$ACRIS_ACT(IS,AS), 1))
    = EAS(R,SR,AS,'OTHRVARCST') - 1.000;

BIS(R,SR,IS,'ELAS')$(RSR(R,SR) and sum(IS2$ACRIS_PAST(IS,IS2), 1)) = 1;
BIS(R,SR,IS,'PBAR')$(RSR(R,SR) and sum(IS2$ACRIS_PAST(IS,IS2), 1)) = 1.000;
BIS(R,SR,IS,'PBAR')$(RSR(R,SR) and sum(IS2$ACRIS_PAST(IS,IS2), 1) and LONGRUN2)
    = BIS(R,SR,IS,'PBAR') * 0.985**YRT;
BIS(R,SR,IS,'QBAR')$(RSR(R,SR) and sum(IS2$ACRIS_PAST(IS,IS2), 1))
    = sum(IS2$ACRIS_PAST(IS,IS2), BISF(R,SR,IS2));
BIS(R,SR,IS,'MAX')$(RSR(R,SR) and sum(IS2$ACRIS_PAST(IS,IS2), 1))
    = BIS(R,SR,IS,'QBAR') + 0.001;

* Scale acreage cost prices by cumulative real wage growth (replaces LONGRUN1 * 1.032)
BIS(R,SR,IS,'PBAR')$(RSR(R,SR) and sum(IS2$ACRIS_PAST(IS,IS2), 1) and BIS(R,SR,IS,'PBAR') gt 0)
    = BIS(R,SR,IS,'PBAR') * sum(TIME$(TIME.val eq YEAR), cumWageGrowthReal(TIME));

*Add extra potential acreage of pasture

BIS(R,SR,'PRMPAST','MAX')    $LONGRUN = BIS(R,SR,'PRMPAST','MAX')   + BIS(R,SR,'POTPAST','MAX')*0.80;
BIS(R,SR,'ACRCOSTP','MAX')   $LONGRUN = BIS(R,SR,'ACRCOSTP','MAX')  + BIS(R,SR,'POTPAST','MAX')*0.80;
BIS(R,SR,'PRMPASTH','MAX')   $LONGRUN = BIS(R,SR,'PRMPASTH','MAX')  + BIS(R,SR,'POTPAST','MAX')*0.20;
BIS(R,SR,'ACRCOSTPH','MAX')  $LONGRUN = BIS(R,SR,'ACRCOSTPH','MAX') + BIS(R,SR,'POTPAST','MAX')*0.20;

BIS(R,SR,'PRMPASTT','MAX')   $LONGRUN = BIS(R,SR,'PRMPASTT','MAX')  + BIS(R,SR,'POTPASTT','MAX')*0.80;
BIS(R,SR,'ACRCOSTPT','MAX')  $LONGRUN = BIS(R,SR,'ACRCOSTPT','MAX') + BIS(R,SR,'POTPASTT','MAX')*0.80;
BIS(R,SR,'PRMPASTHT','MAX')  $LONGRUN = BIS(R,SR,'PRMPASTHT','MAX') + BIS(R,SR,'POTPASTT','MAX')*0.20;
BIS(R,SR,'ACRCOSTPHT','MAX') $LONGRUN = BIS(R,SR,'ACRCOSTPHT','MAX')+ BIS(R,SR,'POTPASTT','MAX')*0.20;

BIS(R,SR,'PRMPASTN','MAX')   $LONGRUN = BIS(R,SR,'PRMPASTN','MAX')  + BIS(R,SR,'POTPASTN','MAX')*0.80;
BIS(R,SR,'ACRCOSTPN','MAX')  $LONGRUN = BIS(R,SR,'ACRCOSTPN','MAX') + BIS(R,SR,'POTPASTN','MAX')*0.80;
BIS(R,SR,'PRMPASTHN','MAX')  $LONGRUN = BIS(R,SR,'PRMPASTHN','MAX') + BIS(R,SR,'POTPASTN','MAX')*0.20;
BIS(R,SR,'ACRCOSTPHN','MAX') $LONGRUN = BIS(R,SR,'ACRCOSTPHN','MAX')+ BIS(R,SR,'POTPASTN','MAX')*0.20;
* 80 % of potential acreage are asumed to hav low production, 20 % high

BIS(R,SR,'PRMALV','MAX')    $LONGRUN = BIS(R,SR,'PRMALV','MAX')     + BIS(R,SR,'POTALV','MAX');
BIS(R,SR,'ACRCOSTALV','MAX')$LONGRUN = BIS(R,SR,'ACRCOSTALV','MAX') + BIS(R,SR,'POTALV','MAX');
BIS(R,SR,'PRMFOR','MAX')    $LONGRUN = BIS(R,SR,'PRMFOR','MAX')     + BIS(R,SR,'POTFOR','MAX');
BIS(R,SR,'ACRCOSTFOR','MAX')$LONGRUN = BIS(R,SR,'ACRCOSTFOR','MAX') + BIS(R,SR,'POTFOR','MAX');
BIS(R,SR,'PRMMOS','MAX')    $LONGRUN = BIS(R,SR,'PRMMOS','MAX')     + BIS(R,SR,'POTMOS','MAX');
BIS(R,SR,'ACRCOSTMOS','MAX')$LONGRUN = BIS(R,SR,'ACRCOSTMOS','MAX') + BIS(R,SR,'POTMOS','MAX');
BIS(R,SR,'PRMLOW','MAX')    $LONGRUN = BIS(R,SR,'PRMLOW','MAX')     + BIS(R,SR,'POTLOW','MAX');
BIS(R,SR,'ACRCOSTLOW','MAX')$LONGRUN = BIS(R,SR,'ACRCOSTLOW','MAX') + BIS(R,SR,'POTLOW','MAX');
BIS(R,SR,'PRMCHAL','MAX')   $LONGRUN = BIS(R,SR,'PRMCHAL','MAX')    + BIS(R,SR,'POTCHAL','MAX');
BIS(R,SR,'ACRCOSTCHA','MAX')$LONGRUN = BIS(R,SR,'ACRCOSTCHA','MAX') + BIS(R,SR,'POTCHAL','MAX');
BIS(R,SR,'PRMMEAD','MAX')   $LONGRUN = BIS(R,SR,'PRMMEAD','MAX')    + BIS(R,SR,'POTMEAD','MAX');
BIS(R,SR,'ACRCOSTMEA','MAX')$LONGRUN = BIS(R,SR,'ACRCOSTMEA','MAX') + BIS(R,SR,'POTMEAD','MAX');

BIS(R,SR,'POTPAST' ,'MAX')$RSR(R,SR) = 0;
BIS(R,SR,'POTPASTT','MAX')$RSR(R,SR) = 0;
BIS(R,SR,'POTPASTN','MAX')$RSR(R,SR) = 0;
BIS(R,SR,'POTALV'  ,'MAX')$RSR(R,SR) = 0;
BIS(R,SR,'POTFOR'  ,'MAX')$RSR(R,SR) = 0;
BIS(R,SR,'POTMOS'  ,'MAX')$RSR(R,SR) = 0;
BIS(R,SR,'POTLOW'  ,'MAX')$RSR(R,SR) = 0;
BIS(R,SR,'POTCHAL' ,'MAX')$RSR(R,SR) = 0;
BIS(R,SR,'POTMEAD' ,'MAX')$RSR(R,SR) = 0;

*Decreasing marginal profitability of organic production area (technically, increassing marg cost)
BIS(R,SR,'ACRECON','ELAS')$RSR(R,SR) = 2;
BIS(R,SR,'ACRECON','PBAR')$RSR(R,SR) = 2.000;
BIS(R,SR,'ACRECON','QBAR')$RSR(R,SR) = (BISF(R,SR,'CROPLAND')-BISF(R,SR,'ACRECO')) * 0.25;
BIS(R,SR,'ACRECON','QBAR')$(RSR(R,SR) $LONGRUN) = (BISF(R,SR,'CROPLAND')-BISF(R,SR,'ACRECO')) * 1;
BIS(R,SR,'ACRECON','MAX')$RSR(R,SR)  = BIS(R,SR,'ACRECON','QBAR')$RSR(R,SR)+0.001;

* No new organic production in this version. 
*BIS(R,SR,'ACRECON','MAX')$RSR(R,SR)  = 0;

BIS(R,SR,'INCONVPRO','ELAS')$RSR(R,SR) = 1;
BIS(R,SR,'INCONVPRO','PBAR')$RSR(R,SR) = 0.350;
BIS(R,SR,'INCONVPRO','QBAR')$RSR(R,SR)   = (BISF(R,SR,'CROPLAND') -BISF(R,SR,'ACRECO'))  * 0.008;
BIS(R,SR,'INCONVPRO','QBAR')$(RSR(R,SR) $POSR('GSS',SR)) = (BISF(R,SR,'CROPLAND')-BISF(R,SR,'ACRECO')) * 0.005;
BIS(R,SR,'INCONVPRO','QBAR')$(RSR(R,SR) $POSR('GMB',SR))  = (BISF(R,SR,'CROPLAND')-BISF(R,SR,'ACRECO')) * 0.03;
BIS(R,SR,'INCONVPRO','QBAR')$(RSR(R,SR) $POSR('GNS',SR))  = (BISF(R,SR,'CROPLAND')-BISF(R,SR,'ACRECO')) * 0.03;
BIS(R,SR,'INCONVPRO','QBAR')$(RSR(R,SR) $POSR('SS',SR))   = (BISF(R,SR,'CROPLAND') -BISF(R,SR,'ACRECO'))  * 0.03;
BIS(R,SR,'INCONVPRO','MAX')$RSR(R,SR)    = (BISF(R,SR,'CROPLAND') -BISF(R,SR,'ACRECO'));
BIS(R,SR,'INCONVEPRO','ELAS')$RSR(R,SR) = 1;
BIS(R,SR,'INCONVEPRO','PBAR')$RSR(R,SR) = 2.500;
BIS(R,SR,'INCONVEPRO','QBAR')$RSR(R,SR) = (BISF(R,SR,'ACRECO'))  * 0.02;
BIS(R,SR,'INCONVEPRO','QBAR')$(RSR(R,SR) $POSR('GMB',SR)) = (BISF(R,SR,'ACRECO')) * 0.05;
BIS(R,SR,'INCONVEPRO','QBAR')$(RSR(R,SR) $POSR('GNS',SR)) = (BISF(R,SR,'ACRECO')) * 0.05;
BIS(R,SR,'INCONVEPRO','QBAR')$(RSR(R,SR) $POSR('SS',SR))  = (BISF(R,SR,'ACRECO')) * 0.05;
BIS(R,SR,'INCONVEPRO','MAX')$RSR(R,SR)    = (BISF(R,SR,'ACRECO'));

* Parameters for depreciation (reduces number of heads the building can keep annually, unless investment is made)
BIS(R,SR,'DAIRYFAC','MAX')  $LONGRUN = BIS(R,SR,'DAIRYFAC','MAX')  * (1-0.05*MIN(YR,20));
BIS(R,SR,'BULLFAC','MAX')   $LONGRUN = BIS(R,SR,'BULLFAC','MAX')   * (1-0.05*MIN(YR,20));
BIS(R,SR,'SOWFAC','MAX')    $LONGRUN = BIS(R,SR,'SOWFAC','MAX')    * (1-0.05*MIN(YR,20));
BIS(R,SR,'SWINEFAC','MAX')  $LONGRUN = BIS(R,SR,'SWINEFAC','MAX')  * (1-0.05*MIN(YR,20));
BIS(R,SR,'PLTRYFAC','MAX')  $LONGRUN = BIS(R,SR,'PLTRYFAC','MAX')  * (1-0.05*MIN(YR,20));
BIS(R,SR,'CHICKFAC','MAX')  $LONGRUN = BIS(R,SR,'CHICKFAC','MAX')  * (1-0.05*MIN(YR,20));
BIS(R,SR,'BEEFCFAC','MAX')  $LONGRUN = BIS(R,SR,'BEEFCFAC','MAX') * (1-0.025*MIN(YR,40))
                                          +BISF(R,SR,'DAIRYFAC')*(0.0125*MIN(YR,20));
* Makes one quarter of old dairy facilities possible to use for beefcattle

* Parameters for investment activities, R = remodel, N = new building
BIS(R,SR,'DAIRYFACR','SLOPE') $(BISF(R,SR,'DAIRYFAC')*YR GT 0)
                            = EAS(R,SR,'DAIRYFEXN','MISCCOST')/((0.04*MIN(YR,20))*BISF(R,SR,'DAIRYFAC'));
BIS(R,SR,'DAIRYFACR','PBAR') $(BISF(R,SR,'DAIRYFAC') GT 0) = EAS(R,SR,'DAIRYFEXN','MISCCOST');
BIS(R,SR,'DAIRYFACR','QBAR') $(BISF(R,SR,'DAIRYFAC') GT 0) = (0.04*MIN(YR,20))* BISF(R,SR,'DAIRYFAC');
BIS(R,SR,'DAIRYFACR','MAX') $(BISF(R,SR,'DAIRYFAC') GT 0) = (0.04*MIN(YR,20))* BISF(R,SR,'DAIRYFAC') * 1;

BIS(R,SR,'BULLFACR','SLOPE') $(BISF(R,SR,'BULLFAC')*YR GT 0)
                              = EAS(R,SR,'BULLFEXN','MISCCOST')/((0.04*MIN(YR,20))*BISF(R,SR,'BULLFAC'));
BIS(R,SR,'BULLFACR','PBAR') $(BISF(R,SR,'BULLFAC') GT 0) = EAS(R,SR,'BULLFEXN','MISCCOST');
BIS(R,SR,'BULLFACR','QBAR') $(BISF(R,SR,'BULLFAC') GT 0) = (0.04*MIN(YR,20))* BISF(R,SR,'BULLFAC');
BIS(R,SR,'BULLFACR','MAX') $(BISF(R,SR,'BULLFAC') GT 0) = (0.04*MIN(YR,20))* BISF(R,SR,'BULLFAC') * 1;

BIS(R,SR,'BEEFCFACR','SLOPE') $(BISF(R,SR,'BEEFCFAC')*YR GT 0)
                            = EAS(R,SR,'BEEFCFEXN','MISCCOST')/((0.02*MIN(YR,20))*BISF(R,SR,'BEEFCFAC'));
BIS(R,SR,'BEEFCFACR','PBAR') $(BISF(R,SR,'BEEFCFAC') GT 0) = EAS(R,SR,'BEEFCFEXN','MISCCOST');
BIS(R,SR,'BEEFCFACR','QBAR') $(BISF(R,SR,'BEEFCFAC') GT 0) = (0.02*MIN(YR,20))* BISF(R,SR,'BEEFCFAC');
BIS(R,SR,'BEEFCFACR','MAX') $(BISF(R,SR,'BEEFCFAC') GT 0) = (0.02*MIN(YR,20))* BISF(R,SR,'BEEFCFAC') * 1;

BIS(R,SR,'SOWFACR','SLOPE') $(BISF(R,SR,'SOWFAC')*YR GT 0)
                              = EAS(R,SR,'SOWFEXN','MISCCOST')/((0.04*MIN(YR,20))*BISF(R,SR,'SOWFAC'));
BIS(R,SR,'SOWFACR','PBAR') $(BISF(R,SR,'SOWFAC') GT 0) = EAS(R,SR,'SOWFEXN','MISCCOST');
BIS(R,SR,'SOWFACR','QBAR') $(BISF(R,SR,'SOWFAC') GT 0) = (0.04*MIN(YR,20))* BISF(R,SR,'SOWFAC');
BIS(R,SR,'SOWFACR','MAX') $(BISF(R,SR,'SOWFAC') GT 0) = (0.04*MIN(YR,20))* BISF(R,SR,'SOWFAC') * 1;

BIS(R,SR,'SWINEFACR','SLOPE') $(BISF(R,SR,'SWINEFAC')*YR GT 0)
                           = EAS(R,SR,'SWINEFEXN','MISCCOST')/((0.04*MIN(YR,20))*BISF(R,SR,'SWINEFAC'));
BIS(R,SR,'SWINEFACR','PBAR') $(BISF(R,SR,'SWINEFAC') GT 0) = EAS(R,SR,'SWINEFEXN','MISCCOST');
BIS(R,SR,'SWINEFACR','QBAR') $(BISF(R,SR,'SWINEFAC') GT 0) = (0.04*MIN(YR,20))* BISF(R,SR,'SWINEFAC');
BIS(R,SR,'SWINEFACR','MAX') $(BISF(R,SR,'SWINEFAC') GT 0) = (0.04*MIN(YR,20))* BISF(R,SR,'SWINEFAC') * 1;

BIS(R,SR,'PLTRYFACR','SLOPE') $(BISF(R,SR,'PLTRYFAC')*YR GT 0)
                           = EAS(R,SR,'PLTRYFEXN','MISCCOST')/((0.04*MIN(YR,20))*BISF(R,SR,'PLTRYFAC'));
BIS(R,SR,'PLTRYFACR','PBAR') $(BISF(R,SR,'PLTRYFAC') GT 0) = EAS(R,SR,'PLTRYFEXN','MISCCOST');
BIS(R,SR,'PLTRYFACR','QBAR') $(BISF(R,SR,'PLTRYFAC') GT 0) = (0.04*MIN(YR,20))* BISF(R,SR,'PLTRYFAC');
BIS(R,SR,'PLTRYFACR','MAX') $(BISF(R,SR,'PLTRYFAC') GT 0) = (0.04*MIN(YR,20))* BISF(R,SR,'PLTRYFAC') * 1;

BIS(R,SR,'CHICKFACR','SLOPE') $(BISF(R,SR,'CHICKFAC')*YR GT 0)
                           = EAS(R,SR,'CHICKFEXN','MISCCOST')/((0.04*MIN(YR,20))*BISF(R,SR,'CHICKFAC'));
BIS(R,SR,'CHICKFACR','PBAR') $(BISF(R,SR,'CHICKFAC') GT 0) = EAS(R,SR,'CHICKFEXN','MISCCOST');
BIS(R,SR,'CHICKFACR','QBAR') $(BISF(R,SR,'CHICKFAC') GT 0) = (0.04*MIN(YR,20))* BISF(R,SR,'CHICKFAC');
BIS(R,SR,'CHICKFACR','MAX') $(BISF(R,SR,'CHICKFAC') GT 0) = (0.04*MIN(YR,20))* BISF(R,SR,'CHICKFAC') * 1;

BIS(R,SR,'HORSEFAC','ELAS')$RSR(R,SR) = 1;
BIS(R,SR,'HORSEFAC','QBAR')$RSR(R,SR) = 363*BISF(R,SR,'CROPLAND')/2549.525;
BIS(R,SR,'HORSEFAC','QBAR')$(LONGRUN) = BIS(R,SR,'HORSEFAC','QBAR') * 1.01**YR/0.997**YR;
BIS(R,SR,'HORSEFAC','PBAR')$RSR(R,SR)  = 1;
BIS(R,SR,'HORSEFAC','MAX')$RSR(R,SR)  = BIS(R,SR,'HORSEFAC','QBAR')$RSR(R,SR)*5;

BIS(R,SR,IS,'PBAR') = BIS(R,SR,IS,'PBAR') *KPI3;

* Explanation of demand data: A product is classified as an elastic demand product if PBAR is
* positive. For elastic demand products, demand is considered infinitely elastic if ELAS is less
* than -99. INTERCEPT is set equal to PBAR and SLOPE is set equal to zero in this case. For
* elastic demand products with an elasticity of greater than -99, INTERCEPT and SLOPE are taken as
* given if SLOPE is negative. If SLOPE is zero, INTERCEPT and SLOPE are calculated using PBAR,

* QBAR and ELAS. MAX is the upper bound on the demand activities for elastic demand products.  If
* PBAR is zero (unassigned), the product demand is classified as fixed. No demand activity is
* generated and the righthand side of the product constraint is set equal to MIN.
 

*** TABLE BPN(PN,SDP)  National product demand parameters
*Change from EURO to SEK 
BPN('GACRSUB','PBAR')    = BPN('GACRSUB','PBAR')    * KURS;
BPN('CATTLESUB','PBAR')  = BPN('CATTLESUB','PBAR')  * KURS;
BPN('ECOSUB','PBAR')     = BPN('ECOSUB','PBAR')     * KURS;
BPN('ES3','PBAR')        = BPN('ES3','PBAR')        * KURS;
BPN('ES4','PBAR')        = BPN('ES4','PBAR')        * KURS;
BPN('ES5','PBAR')        = BPN('ES5','PBAR')        * KURS;
BPN('ES6','PBAR')        = BPN('ES6','PBAR')        * KURS;

* Scenario settings for farm payments
BPN(PN,SDP) = BPN(PN,SDP) * (1 + supportPct(PN)) + areaPaymentScaleFactor * supportAdd(PN);

*Adjust for inflation in long run calculations
BPN(SUPPORTN,'PBAR') $(LONGRUN1)  = BPN(SUPPORTN,'PBAR')  / KPI3;

BPN(PN,'PBAR')        = BPN(PN,'PBAR') *KPI3;
BPN('DPTRANR','PBAR') = BPN('DPTRANR','PBAR') /KPI3;     
 
*** TABLE BPRN(PR,SDP)  National data for regional product demand parameters
BPRN(PR,'PBAR') = BPRN(PR,'PBAR') / KPI3;
* Recalculation back occurs further down. Added that way so it won't be forgotten.
* Organic becomes slightly miscalculated

* Adjusts quantities to increased population based on prognos from SCB
BPRN(PR,'QBAR') $(LONGRUN) = BPRN(PR,'QBAR') * 1.01**YR;
* Adjust milk to reduced consumption
BPRN('KMILKC','QBAR') $(LONGRUN) = BPRN('KMILKC','QBAR') * 0.985**YR;
BPRN('CREAMC','QBAR') $(LONGRUN) = BPRN('CREAMC','QBAR') * 0.985**YR;
BPRN('BUTTERC','QBAR') $(LONGRUN) = BPRN('BUTTERC','QBAR') * 0.985**YR;

* Adjust ecoprice for inflation
BPRN('EPEAS','PBAR') $(LONGRUN1)  = BPRN('EPEAS','PBAR')  / KPI;
BPRN('EGRAIN','PBAR') $(LONGRUN1) = BPRN('EGRAIN','PBAR') / KPI;
BPRN('ERAPE','PBAR') $(LONGRUN1)  = BPRN('ERAPE','PBAR')  / KPI;
BPRN('ESUGARB','PBAR') $(LONGRUN1)= BPRN('ESUGARB','PBAR')/ KPI;
BPRN('EPOTATOES','PBAR') $(LONGRUN1)  = BPRN('EPOTATOES','PBAR') / KPI;
BPRN('EMILK','PBAR') $(LONGRUN1)  = BPRN('EMILK','PBAR')  / KPI;
BPRN('EBEEF','PBAR') $(LONGRUN1)  = BPRN('EBEEF','PBAR')  / KPI;
BPRN('EPORK','PBAR') $(LONGRUN1)  = BPRN('EPORK','PBAR')  / KPI;
BPRN('ESHEEPM','PBAR') $(LONGRUN1)= BPRN('ESHEEPM','PBAR')/ KPI;
BPRN('EEGG','PBAR') $(LONGRUN1)   = BPRN('EEGG','PBAR')   / KPI;


** PARAMETER POP(R) Population separated in regions 


** PARAMETER BPR(R,PR,SDP)  Regional product demand parameters;
* Calculate regional demand in proportion to population
BPR(R,PR,'PBAR') = BPRN(PR,'PBAR');
BPR(R,PR,'QBAR') = BPRN(PR,'QBAR')*POP(R)/9408;
BPR(R,PR,'ELAS') = BPRN(PR,'ELAS');
BPR(R,PR,'MIN')  = BPRN(PR,'MIN') *POP(R)/9408;
BPR(R,PR,'MAX')  = BPRN(PR,'MAX') *POP(R)/9408;

BPR(R,PR,'PBAR') = BPR(R,PR,'PBAR') * KPI3;


*** TABLE BPSF(R,SR,PS)  Subregional demand of products with fixed demand
*Restriction for minimum pasture
BPSF(R,SR,'MINPAST') = BIS(R,SR,'PRMPAST','MAX') + BIS(R,SR,'PRMPASTT','MAX') +
                        BIS(R,SR,'PRMPASTN','MAX') + BIS(R,SR,'PRMPASTH','MAX') +
                        BIS(R,SR,'PRMPASTHT','MAX')+ BIS(R,SR,'PRMPASTHN','MAX') +
                        BIS(R,SR,'PRMALV','MAX')   + BIS(R,SR,'PRMFOR','MAX') +
                        BIS(R,SR,'PRMMOS','MAX')   + BIS(R,SR,'PRMLOW','MAX') +
                        BIS(R,SR,'PRMCHAL','MAX')  + BIS(R,SR,'PRMMEAD','MAX');
                       
BPSF(R,SR,'MINPAST') = BPSF(R,SR,'MINPAST')*0.67968*0;
*Inactive, as *0
*Number of sheep cannot fall below present level (SHEEPFAC), which was doubled above
BPSF(R,SR,'MINSHEEP') = BISF(R,SR,'SHEEPFAC') * 0.5;

*Minimum share of cropland to be used for other crops, industrial crops and undefined land use
BPSF(R,SR,'OTHRCROPPR') = BISF(R,SR,'CROPLAND') * 0.0105;
BPSF(R,SR,'ICRPR') = BISF(R,SR,'CROPLAND') * 0.0022;
BPSF(R,SR,'UNDEFUSE') = BISF(R,SR,'CROPLAND')     * 0.0043;

*Area willow fixed, because data is old and acreage therefore difficult to calibrate
BPSF(R,SR,'MINSALIX') = BISF(R,SR,'MAXSALIX')     *0.999; 


*** TABLE BPSI(SR,PS)  Subregional prices of infinite elastic products
**Define Parameter BPSI(SR,PS) using data from BPSI_SA
BPSI(SR,PS) = sum(SA$SASR(SA,SR), BPSI_SA(SA,PS));

* omit ANC supports, for specific scenario (instead of changing table)
*BPSI(SR,'COMP4SUB') = 0;
*BPSI(SR,'COMPSUB')  = 0;
*BPSI(SR,'COMPSUBL') = 0;

BPSI(SR,SUPPORTS)$LONGRUN1 = BPSI(SR,SUPPORTS) / KPI2;


** PARAMETER BPS(R,SR,PS,SDP)  Subregional product demand parameters;
BPS(R,SR,PS,'PBAR')$RSR(R,SR) = BPSI(SR,PS);
BPS(R,SR,PS,'ELAS')$(RSR(R,SR)$(BPSI(SR,PS) GT 0)) = -999;
BPS(R,SR,PS,'MAX') $(RSR(R,SR)$(BPSI(SR,PS) GT 0)) = INF;
BPS(R,SR,PS,'MIN') $RSR(R,SR) = BPSF(R,SR,PS);

BPS(R,SR,'ICRPR','MAX') $RSR(R,SR) = BPSF(R,SR,'ICRPR')*2;

BPS(R,SR,PS,'PBAR') = BPS(R,SR,PS,'PBAR') * KPI3;


*** TABLE DT(RS,RD)  Distance from source region to destination region
*** PARAMETER UT(IP)  Unit transportation cost per 1000 kilometers
UT(TRP) = UT(TRP) + 0.001;
* Adds cost for all transport activities to avoid different patterns with same cost
UT(TRP) = UT(TRP) * KPI3;


*** TABLE BXR(R,PR,TRD)  Export parameters for regional products
*** TABLE BMR(R,PR,TRD)  Import parameters for regional products
BXR(R,PR,'MAX')         $RPREX(R,PR)          = 9999.9;
BMR(R,PR,'MAX')         $RPRIM(R,PR)          = 9999.9;
* Capping import och cheese and poultry to match trade data.
BMR(R,'CHEESE','MAX')   $RPRIM(R,'CHEESE')    = 180.0;
BMR(R,'PLTRYMEAT','MAX')$RPRIM(R,'PLTRYMEAT') =  68.6;

BXR(R,PR,'MAX')$RPREX(R,PR) = BXR(R,PR,'MAX')/3;
BMR(R,PR,'MAX')$RPRIM(R,PR) = BMR(R,PR,'MAX')/3;

* Load WPRICE from year-indexed price tables
BXR(R,PR,'WPRICE')$RPREX(R,PR) = sum(TIME$(TIME.val eq YEAR), pricesExport(PR,TIME));
BMR(R,PR,'WPRICE')$RPRIM(R,PR) = sum(TIME$(TIME.val eq YEAR), pricesImport(PR,TIME));

* Price for beef, pork and poultry converted from live animals (in slaughter weight) to carcasses
BXR(R,'BEEF','WPRICE')     $RPREX(R,'BEEF')     = BXR(R,'BEEF','WPRICE')     + 1.23;
BMR(R,'BEEF','WPRICE')     $RPRIM(R,'BEEF')     = BMR(R,'BEEF','WPRICE')     + 1.23;
BXR(R,'PORK','WPRICE')     $RPREX(R,'PORK')     = BXR(R,'PORK','WPRICE')     + 2.55;
BMR(R,'PORK','WPRICE')     $RPRIM(R,'PORK')     = BMR(R,'PORK','WPRICE')     + 2.55;
BXR(R,'PLTRYMEAT','WPRICE')$RPREX(R,'PLTRYMEAT')= BXR(R,'PLTRYMEAT','WPRICE')+ 15.39;
BMR(R,'PLTRYMEAT','WPRICE')$RPRIM(R,'PLTRYMEAT')= BMR(R,'PLTRYMEAT','WPRICE')+ 15.39;

* The below block is replaced by year-indexed price tables that retrieve prices for YEAR (pricesExport, pricesImport):
*BXR(R,'BREADGRAIN','WPRICE') $LONGRUN1 = BXR(R,'BREADGRAIN','WPRICE') * 0.914 - 0.05;
*BMR(R,'BREADGRAIN','WPRICE') $LONGRUN1 = BMR(R,'BREADGRAIN','WPRICE') * 0.914 - 0.05;
*BXR(R,'COARSGRAIN','WPRICE') $LONGRUN1 = BXR(R,'COARSGRAIN','WPRICE') * 0.953 - 0.15;
*BMR(R,'COARSGRAIN','WPRICE') $LONGRUN1 = BMR(R,'COARSGRAIN','WPRICE') * 0.953 - 0.15;
*BMR(R,'PEAS','WPRICE')       $LONGRUN1 = BMR(R,'PEAS','WPRICE')       * 1.025;
*BMR(R,'EPEAS','WPRICE')      $LONGRUN1 = BMR(R,'EPEAS','WPRICE')      * 1.025;
*BXR(R,'OILGRAIN','WPRICE')   $LONGRUN1 = BXR(R,'OILGRAIN','WPRICE')   * 0.884;
*BMR(R,'OILGRAIN','WPRICE')   $LONGRUN1 = BMR(R,'OILGRAIN','WPRICE')   * 0.884;
*BXR(R,'RAPEOIL','WPRICE')    $LONGRUN1 = BXR(R,'RAPEOIL','WPRICE')    * 0.951;
*BXR(R,'CHEESE','WPRICE')     $LONGRUN1 = BXR(R,'CHEESE','WPRICE')     * 0.986 * 1.3;
*BMR(R,'CHEESE','WPRICE')     $LONGRUN1 = BMR(R,'CHEESE','WPRICE')     * 0.986 * 1.3;
*BXR(R,'BUTTER','WPRICE')     $LONGRUN1 = BXR(R,'BUTTER','WPRICE')     * 0.890 * 1.2;
*BMR(R,'BUTTER','WPRICE')     $LONGRUN1 = BMR(R,'BUTTER','WPRICE')     * 0.890 * 1.2;
*BXR(R,'DRYMILK','WPRICE')    $LONGRUN1 = BXR(R,'DRYMILK','WPRICE')    * 1.020 * 1.2;
*BMR(R,'DRYMILK','WPRICE')    $LONGRUN1 = BMR(R,'DRYMILK','WPRICE')    * 1.020 * 1.2;
*BXR(R,'DRYMILK2','WPRICE')   $LONGRUN1 = BXR(R,'DRYMILK2','WPRICE')   * 1.020 * 1.2;
*BMR(R,'DRYMILK2','WPRICE')   $LONGRUN1 = BMR(R,'DRYMILK2','WPRICE')   * 1.020 * 1.2;
*BXR(R,'BEEF','WPRICE')       $LONGRUN1 = BXR(R,'BEEF','WPRICE')       + 1.422 + 2.000;
*BMR(R,'BEEF','WPRICE')       $LONGRUN1 = BMR(R,'BEEF','WPRICE')       + 1.422 + 2.000;
*BXR(R,'PORK','WPRICE')       $LONGRUN1 = BXR(R,'PORK','WPRICE')       - 0.208;
*BMR(R,'PORK','WPRICE')       $LONGRUN1 = BMR(R,'PORK','WPRICE')       - 0.208;
*BXR(R,'PLTRYMEAT','WPRICE')  $LONGRUN1 = BXR(R,'PLTRYMEAT','WPRICE')  - 0.245;
*BMR(R,'PLTRYMEAT','WPRICE')  $LONGRUN1 = BMR(R,'PLTRYMEAT','WPRICE')  - 0.245;
*BXR(R,'SLGHSHEEP','WPRICE')  $LONGRUN1 = BXR(R,'SLGHSHEEP','WPRICE')  * 0.987;
*BMR(R,'SLGHSHEEP','WPRICE')  $LONGRUN1 = BMR(R,'SLGHSHEEP','WPRICE')  * 0.987;
*BXR(R,'EGG','WPRICE')        $LONGRUN1 = BXR(R,'EGG','WPRICE')        * 0.987;
*BMR(R,'EGG','WPRICE')        $LONGRUN1 = BMR(R,'EGG','WPRICE')        * 0.987;

*BXR(R,PR,'WPRICE')       = BXR(R,PR,'WPRICE') * KPI3;
*BMR(R,PR,'WPRICE')       = BMR(R,PR,'WPRICE') * KPI3;

* Apply scenario price adjustments from settings.gms, if any (section 7)
BXR(R,PR,'WPRICE')$(RPREX(R,PR) and exportPricePct(PR) ne 0)  = BXR(R,PR,'WPRICE') * (1 + exportPricePct(PR));
BMR(R,PR,'WPRICE')$(RPRIM(R,PR) and importPricePct(PR) ne 0)  = BMR(R,PR,'WPRICE') * (1 + importPricePct(PR));

** PARAMETER MS(SR)    Milk subsidy per unit;
MS(SR) $ SASR('SA01',SR) = 1.64;
MS(SR) $ SASR('SA02',SR) = 1.33;
MS(SR) $ SASR('SA03',SR) = 1.08;
MS(SR) $ SASR('SA04a',SR) = 0.73;
MS(SR) $ SASR('SA04b',SR) = 0.73;
MS(SR) $ SASR('SA05',SR) = 0.48;

** PARAMETER DPTR(P)  Dairy processing transfer receipt
DPTR('MILK') = 0.615;

** PARAMETER DPTC(P)  Dairy processing transfer cost
DPTC('KMILK') = 1.000;
DPTC('CHEESE') = 0.000;
DPTC('CREAM') = 8.000;
DPTC('BUTTER') = 0.000;

DPTR('MILK') $LONGRUN1 = 0.510;
DPTC('KMILK') $LONGRUN1 = 1.0;
DPTC('CREAM') $LONGRUN1 = 8.000;
MS(SR)  $LONGRUN1 = MS(SR)  * 1.000/KPI2 ;

DPTR('MILK') = DPTR('MILK') * KPI3;
DPTC(P)      = DPTC(P)      * KPI3;
MS(SR)       = MS(SR)       * KPI3;


* Calculate regional subsidies
  EAS(R,SR,DCOWS,'NATSUB') = EAS(R,SR,DCOWS,'NATSUB') + MS(SR)*EAS(R,SR,DCOWS,'MILK');

* Calculate transfers for dairy production and processing activities
  EAS(R,SR,DCOWS,'DPTRANR')$RSRAS(R,SR,DCOWS) = -DPTR('MILK')*(-EAS(R,SR,DCOWS,'MILK'));
  ECR(R,'P-KMILK','DPTRANC') $RCR(R,'P-KMILK') = DPTC('KMILK');
  ECR(R,'P-CHEESE','DPTRANC') $RCR(R,'P-CHEESE') = DPTC('CHEESE');
  ECR(R,'P-CREAM','DPTRANC') $RCR(R,'P-CREAM') = DPTC('CREAM');
  ECR(R,'P-BUTTER','DPTRANC') $RCR(R,'P-BUTTER') = DPTC('BUTTER');


** PARAMETER CT(RS,RD,IP)  Unit transportation cost;
  CT(RS,RD,IP) $TIP(RS,RD,IP) = DT(RS,RD) * UT(IP);


*===============================================================================
* 6.3b CALIBRATION
*===============================================================================
* CALIBRATION is the PMP calibration cost (Mil SEK per activity unit).
* Positive values reduce profitability and output of the activity.
* Negative values increase profitability and output of the activity.


* -- Conventional crops
costCalibration('W-WHEAT')    = 0;
costCalibration('W-BARLEY')   = 0;
costCalibration('BARLEY')     = 0;
costCalibration('OATS')       = 0;
costCalibration('W-RAPE')     = 0;
costCalibration('S-RAPE')     = 0;
costCalibration('POTATO')     = 0;
costCalibration('SUGAR')      = 0;
costCalibration('FEEDPEAS')   = 0;
costCalibration('LAY')        = 0;

* -- Forage crops
costCalibration('FORAGE1')    = 0;
costCalibration('FORAGE2')    = 0;
costCalibration('FORAGE3')    = 0;
costCalibration('FORAGE4')    = 0;
costCalibration('PASTURE1')   = 0;
costCalibration('PASTURE2')   = 0;

* -- Conventional livestock
costCalibration('DCOW1')      = 0;
costCalibration('DCOW3')      = 0;
costCalibration('DAIRYBULL1') = 0;
costCalibration('DAIRYBULL2') = 0;
costCalibration('SLGHHEIFER') = 0;
costCalibration('BEEFCATTLE') = 0;
costCalibration('BEEFCATTL2') = 0;

* -- Organic beef cattle
costCalibration('EBEEFCATT') = 0;
costCalibration('EBEEFCAT2') = 0;

* -- Sheep
costCalibration('SHEEP')      = 0;
costCalibration('SHEEP2')     = -0.25;

* -- Pigs
costCalibration('SOW1')       = 0;
costCalibration('SLGHSWINE1') = 0;

* -- Poultry
costCalibration('POULTRY')    = 0;
costCalibration('CHICKEN')    = 0;

EAS(R,SR,AS,'CALIBRATION')$(RSRAS(R,SR,AS) and costCalibration(AS) ne 0)
    = EAS(R,SR,AS,'CALIBRATION') + costCalibration(AS);

*===============================================================================



* 6.4 Supply and demand functions

* Assign sets INES, INFS, IRES, IRFS, ISES, ISFS, PNED, PNFD, PRED, PRFD, PSED AND PSFD
  INES(IN) $(BIN(IN,'PBAR') GT 0) = yes;
  INFS(IN) = yes $(NOT INES(IN));
  IRES(R,IR) = RIR(R,IR) $(BIR(R,IR,'PBAR') GT 0);
  IRFS(R,IR) = RIR(R,IR) - IRES(R,IR);
  ISES(R,SR,IS) = RSRIS(R,SR,IS) $(BIS(R,SR,IS,'PBAR') GT 0);
  ISFS(R,SR,IS) = RSRIS(R,SR,IS) - ISES(R,SR,IS);
 
  PNED(PN) $(BPN(PN,'PBAR') GT 0) = yes;
  PNFD(PN) = yes $(NOT PNED(PN));
  PRED(R,PR) = RPR(R,PR) $(BPR(R,PR,'PBAR') GT 0);
  PRFD(R,PR) = RPR(R,PR) - PRED(R,PR);
  PSED(R,SR,PS) = RSRPS(R,SR,PS) $(BPS(R,SR,PS,'PBAR') GT 0);
  PSFD(R,SR,PS) = RSRPS(R,SR,PS) - PSED(R,SR,PS);

* Calculate input supply and product demand intercepts and slopes
*input supply national 
  BIN(IN,'SLOPE') $(INES(IN)$(BIN(IN,'ELAS') GE 99)) = 0.0;
  BIN(IN,'INTERCEPT') $(INES(IN)$(BIN(IN,'ELAS') GE 99)) = BIN(IN,'PBAR');
  BIN(IN,'SLOPE') $(INES(IN)$((BIN(IN,'ELAS') LT 99) AND (BIN(IN,'SLOPE') EQ 0)))
                   = BIN(IN,'PBAR')/(BIN(IN,'ELAS')*BIN(IN,'QBAR'));
  BIN(IN,'INTERCEPT') $(INES(IN)$((BIN(IN,'ELAS') LT 99) AND (BIN(IN,'INTERCEPT') EQ 0)))
                       = BIN(IN,'PBAR') - BIN(IN,'SLOPE')*BIN(IN,'QBAR');
*input supply regional
  BIR(R,IR,'SLOPE') $(IRES(R,IR)$(BIR(R,IR,'ELAS') GE 99)) = 0.0;
  BIR(R,IR,'INTERCEPT') $(IRES(R,IR)$(BIR(R,IR,'ELAS') GE 99)) = BIR(R,IR,'PBAR');
  BIR(R,IR,'SLOPE') $(IRES(R,IR)$((BIR(R,IR,'ELAS') LT 99) AND (BIR(R,IR,'SLOPE') EQ 0) AND
      (BIR(R,IR,'QBAR') GT 0)))
                   = BIR(R,IR,'PBAR')/(BIR(R,IR,'ELAS')*BIR(R,IR,'QBAR'));
  BIR(R,IR,'INTERCEPT') $(IRES(R,IR)$((BIR(R,IR,'ELAS') LT 99) AND (BIR(R,IR,'INTERCEPT') EQ 0)))
                       = BIR(R,IR,'PBAR') - BIR(R,IR,'SLOPE')*BIR(R,IR,'QBAR');
*input supply subregional
  BIS(R,SR,IS,'SLOPE') $(ISES(R,SR,IS)$(BIS(R,SR,IS,'ELAS') GE 99)) = 0.0;
  BIS(R,SR,IS,'INTERCEPT') $(ISES(R,SR,IS)$(BIS(R,SR,IS,'ELAS') GE 99)) = BIS(R,SR,IS,'PBAR');
  BIS(R,SR,IS,'SLOPE')
      $(ISES(R,SR,IS)$((BIS(R,SR,IS,'ELAS') LT 99) AND (BIS(R,SR,IS,'SLOPE') EQ 0) AND
          (BIS(R,SR,IS,'QBAR') GT 0)))
                       = BIS(R,SR,IS,'PBAR')/(BIS(R,SR,IS,'ELAS')*BIS(R,SR,IS,'QBAR'));
  BIS(R,SR,IS,'INTERCEPT')
      $(ISES(R,SR,IS)$((BIS(R,SR,IS,'ELAS') LT 99) AND (BIS(R,SR,IS,'INTERCEPT') EQ 0)))
                           = BIS(R,SR,IS,'PBAR') - BIS(R,SR,IS,'SLOPE')*BIS(R,SR,IS,'QBAR');
*product demand national
  BPN(PN,'SLOPE') $(PNED(PN)$(BPN(PN,'ELAS') LE -99)) = 0.0;
  BPN(PN,'INTERCEPT') $(PNED(PN)$(BPN(PN,'ELAS') LE -99)) = BPN(PN,'PBAR');
  BPN(PN,'SLOPE') $(PNED(PN)$((BPN(PN,'ELAS') GT -99) AND (BPN(PN,'SLOPE') EQ 0)))
                  = BPN(PN,'PBAR')/(BPN(PN,'ELAS')*BPN(PN,'QBAR'));
  BPN(PN,'INTERCEPT') $(PNED(PN)$((BPN(PN,'ELAS') GT -99) AND (BPN(PN,'INTERCEPT') EQ 0)))
                      = BPN(PN,'PBAR') - BPN(PN,'SLOPE')*BPN(PN,'QBAR');
*product demand regional
  BPR(R,PR,'SLOPE') $(PRED(R,PR)$(BPR(R,PR,'ELAS') LE -99)) = 0.0;
  BPR(R,PR,'INTERCEPT') $(PRED(R,PR)$(BPR(R,PR,'ELAS') LE -99)) = BPR(R,PR,'PBAR');
  BPR(R,PR,'SLOPE') $(PRED(R,PR)$((BPR(R,PR,'ELAS') GT -99) AND (BPR(R,PR,'SLOPE') EQ 0)))
                   = BPR(R,PR,'PBAR')/(BPR(R,PR,'ELAS')*BPR(R,PR,'QBAR'));
  BPR(R,PR,'INTERCEPT') $(PRED(R,PR)$((BPR(R,PR,'ELAS') GT -99) AND (BPR(R,PR,'INTERCEPT') EQ 0)))
                       = BPR(R,PR,'PBAR') - BPR(R,PR,'SLOPE')*BPR(R,PR,'QBAR');
*product demand subregional
  BPS(R,SR,PS,'SLOPE') $(PSED(R,SR,PS)$(BPS(R,SR,PS,'ELAS') LE -99)) = 0.0;
  BPS(R,SR,PS,'INTERCEPT') $(PSED(R,SR,PS)$(BPS(R,SR,PS,'ELAS') LE -99)) = BPS(R,SR,PS,'PBAR');
  BPS(R,SR,PS,'SLOPE')
      $(PSED(R,SR,PS)$((BPS(R,SR,PS,'ELAS') GT -99) AND (BPS(R,SR,PS,'SLOPE') EQ 0)))
                       = BPS(R,SR,PS,'PBAR')/(BPS(R,SR,PS,'ELAS')*BPS(R,SR,PS,'QBAR'));
  BPS(R,SR,PS,'INTERCEPT')
      $(PSED(R,SR,PS)$((BPS(R,SR,PS,'ELAS') GT -99) AND (BPS(R,SR,PS,'INTERCEPT') EQ 0)))
                           = BPS(R,SR,PS,'PBAR') - BPS(R,SR,PS,'SLOPE')*BPS(R,SR,PS,'QBAR');
 

* Calculate adjusted export and import prices WPRICE, TARIFF, SUBSIDY, MIN, MAX, ADJPRICE

  BXR(R,PREX,'ADJPRICE') $RPREX(R,PREX)
                        = BXR(R,PREX,'WPRICE') - BXR(R,PREX,'TARIFF') + BXR(R,PREX,'SUBSIDY');
  BMR(R,PRIM,'ADJPRICE') $RPRIM(R,PRIM)
                        = BMR(R,PRIM,'WPRICE') + BMR(R,PRIM,'TARIFF') - BMR(R,PRIM,'SUBSIDY');


DISPLAY $OC('DSETS') PNED, PNFD, PRED, PRFD, PSED, PSFD, INES, INFS, IRES, IRFS, ISES, ISFS, RIR, RSR, RSRIS, RPR, RSRPS, PREX, PRIM, RPREX, RPRIM, RSRAS, T, TIP;
DISPLAY $OC('PARAM') BIN, BIR, BIS, BISF, BISFA, BPN, BPR, BPS, BXR, BMR;
DISPLAY $OC('PRODIO') EAS, ECR;
DISPLAY $OC('CONST') CONST;
DISPLAY $OC('UTCOST') CT, DT, UT;
DISPLAY $OC('DATA') MANURE, NSUB, NUTRIENT, POP, DPTR, DPTC, MS;


** 6.5 Variable bounds & initial levels

$stitle 6.5 Variable bounds and initial levels

SUPPLYIN.lo(IN)$INES(IN)          = BIN(IN,'MIN');
SUPPLYIN.up(IN)$INES(IN)          = BIN(IN,'MAX');

SUPPLYIR.lo(R,IR)$IRES(R,IR)      = BIR(R,IR,'MIN');
SUPPLYIR.up(R,IR)$IRES(R,IR)      = BIR(R,IR,'MAX');

SUPPLYIS.lo(R,SR,IS)$ISES(R,SR,IS)= BIS(R,SR,IS,'MIN');
SUPPLYIS.up(R,SR,IS)$ISES(R,SR,IS)= BIS(R,SR,IS,'MAX');

DEMANDPN.lo(PN)$PNED(PN)          = BPN(PN,'MIN');
DEMANDPN.up(PN)$PNED(PN)          = BPN(PN,'MAX');

DEMANDPR.lo(R,PR)$PRED(R,PR)      = BPR(R,PR,'MIN');
DEMANDPR.up(R,PR)$PRED(R,PR)      = BPR(R,PR,'MAX');

DEMANDPS.lo(R,SR,PS)$PSED(R,SR,PS)= BPS(R,SR,PS,'MIN');
DEMANDPS.up(R,SR,PS)$PSED(R,SR,PS)= BPS(R,SR,PS,'MAX');

EXPORTRP.lo(R,PREX)$RPREX(R,PREX) = BXR(R,PREX,'MIN');
EXPORTRP.up(R,PREX)$RPREX(R,PREX) = BXR(R,PREX,'MAX');

IMPORTPR.lo(R,PRIM)$RPRIM(R,PRIM) = BMR(R,PRIM,'MIN');
IMPORTPR.up(R,PRIM)$RPRIM(R,PRIM) = BMR(R,PRIM,'MAX');

* Initial levels (optional but often good)
SUPPLYIS.l(R,SR,IS)$ISES(R,SR,IS) = BIS(R,SR,IS,'QBAR');
SUPPLYIR.l(R,IR)$IRES(R,IR)       = BIR(R,IR,'QBAR');
DEMANDPS.l(R,SR,PS)$PSED(R,SR,PS) = BPS(R,SR,PS,'QBAR');
DEMANDPR.l(R,PR)$PRED(R,PR)       = BPR(R,PR,'QBAR');


* Investment caps (per year)
* Limit investments in new facilities to quarter amount in 2010 addition of 1 is to avoid 0 no limit
PRODSR.UP(R,SR,'DAIRYFEXN') $RSRAS(R,SR,'DAIRYFEXN') = BISF(R,SR,'DAIRYFAC')* (0.03*YR) + 0.001;
PRODSR.UP(R,SR,'BEEFCFEXN') $RSRAS(R,SR,'BEEFCFEXN') = BISF(R,SR,'BEEFCFAC')* (0.03*YR) + 0.001;
PRODSR.UP(R,SR,'BULLFEXN')  $RSRAS(R,SR,'BULLFEXN')  = BISF(R,SR,'BULLFAC') * (0.03*YR) + 0.001;
PRODSR.UP(R,SR,'SOWFEXN')   $RSRAS(R,SR,'SOWFEXN')   = BISF(R,SR,'SOWFAC')  * (0.03*YR) + 0.001;
PRODSR.UP(R,SR,'SWINEFEXN') $RSRAS(R,SR,'SWINEFEXN') = BISF(R,SR,'SWINEFAC')* (0.03*YR) + 0.019;
PRODSR.UP(R,SR,'PLTRYFEXN') $RSRAS(R,SR,'PLTRYFEXN') = BISF(R,SR,'PLTRYFAC')* (0.03*YR) + 0.001;
PRODSR.UP(R,SR,'CHICKFEXN') $RSRAS(R,SR,'CHICKFEXN') = BISF(R,SR,'CHICKFAC')* (0.03*YR) + 0.001;

* Initial levels in longrun
PRODSR.L(R,SR,'DAIRYFEXN')$((LONGRUN) $RSRAS(R,SR,'DAIRYFEXN')) = BISF(R,SR,'DAIRYFAC')*(0.03*YR);
PRODSR.L(R,SR,'BEEFCFEXN')$((LONGRUN) $RSRAS(R,SR,'BEEFCFEXN')) = BISF(R,SR,'BEEFCFAC')*(0.03*YR);
PRODSR.L(R,SR,'BULLFEXN') $((LONGRUN) $RSRAS(R,SR,'BULLFEXN'))  = BISF(R,SR,'BULLFAC')*(0.03*YR);
PRODSR.L(R,SR,'SOWFEXN')  $((LONGRUN) $RSRAS(R,SR,'SOWFEXN'))   = BISF(R,SR,'SOWFAC')*(0.03*YR);
PRODSR.L(R,SR,'SWINEFEXN')$((LONGRUN) $RSRAS(R,SR,'SWINEFEXN')) = BISF(R,SR,'SWINEFAC')*(0.03*YR);
PRODSR.L(R,SR,'PLTRYFEXN')$((LONGRUN) $RSRAS(R,SR,'PLTRYFEXN')) = BISF(R,SR,'PLTRYFAC')*(0.03*YR);

PRODSR.L(R,SR,'DAIRYFEXR')$((LONGRUN) $RSRAS(R,SR,'DAIRYFEXN')) = BISF(R,SR,'DAIRYFAC')*(0.03*YR);
*PRODSR.L(R,SR,'BEEFCFEXN')$((LONGRUN) $RSRAS(R,SR,'BEEFCFEXN')) = BISF(R,SR,'BEEFCFAC')*0.4;
PRODSR.L(R,SR,'BULLFEXR') $((LONGRUN) $RSRAS(R,SR,'BULLFEXN'))  = BISF(R,SR,'BULLFAC')*(0.03*YR);
PRODSR.L(R,SR,'SOWFEXR')  $((LONGRUN) $RSRAS(R,SR,'SOWFEXN'))   = BISF(R,SR,'SOWFAC')*(0.03*YR);
PRODSR.L(R,SR,'SWINEFEXR')$((LONGRUN) $RSRAS(R,SR,'SWINEFEXN')) = BISF(R,SR,'SWINEFAC')*(0.03*YR);
PRODSR.L(R,SR,'PLTRYFEXR')$((LONGRUN) $RSRAS(R,SR,'PLTRYFEXN')) = BISF(R,SR,'PLTRYFAC')*(0.03*YR);

* Minimum investment?
PRODSR.LO(R,SR,AS) $RSRAS(R,SR,AS) = 0.001;
PRODSR.LO(R,SR,'POULTRY') $RSRAS(R,SR,'POULTRY') = BISF(R,SR,'PLTRYFAC') * 0.33;

* Shut down investments if not longrun
PRODSR.UP(R,SR,INVEST) $(NOT LONGRUN) = 0;
PRODSR.LO(R,SR,INVEST) $(NOT LONGRUN) = 0;

* Upper bounds based on land etc.
PRODSR.UP(R,SR,'ICR') = BPSF(R,SR,'ICRPR')*1.5;
PRODSR.UP(R,SR,'NOUSE') = BISF(R,SR,'CROPLAND')*0.0044;
*PRODSR.UP(R,SR,'ECOPIG') = BISF(R,SR,'SOWFAC')*0.15;

* Explicit zeros
PRODSR.UP(R,SR,'GRAINSIL') = 0;
PRODSR.UP(R,SR,'MAJSSIL') = 0;
PRODSR.LO(R,SR,'GRAINSIL') = 0;
PRODSR.LO(R,SR,'MAJSSIL') = 0;

* Herd initial levels
PRODSR.L(R,SR,'DCOW3') $RSRAS(R,SR,'DCOW3') = BISF(R,SR,'DAIRYFAC');
PRODSR.L(R,SA01TO04b,'DCOW3') = 0;
PRODSR.L(R,SA01TO04b,'DCOW1') $RSRAS(R,SA01TO04b,'DCOW1') = BISF(R,SA01TO04b,'DAIRYFAC');
PRODSR.L(R,SR,'HEIFER') $RSRAS(R,SR,'HEIFER') = BISF(R,SR,'DAIRYFAC') * 0.333;
PRODSR.L(R,SR,'DAIRYBULL1') $RSRAS(R,SR,'DAIRYBULL1') = BISF(R,SR,'DAIRYFAC') * 0.425;
PRODSR.L(R,SR,'SLGHHEIFER') $RSRAS(R,SR,'SLGHHEIFER') = BISF(R,SR,'DAIRYFAC') * (0.425-0.333);
PRODSR.L(R,SR,'BEEFCATTLE') $RSRAS(R,SR,'BEEFCATTLE') = BISF(R,SR,'BEEFCFAC');
PRODSR.L(R,SR,'SOW1') $RSRAS(R,SR,'SOW1') = BISF(R,SR,'SOWFAC');
PRODSR.L(R,SR,'GILT') $RSRAS(R,SR,'GILT') = BISF(R,SR,'SOWFAC')* 0.4/0.66;
PRODSR.L(R,SR,'SLGHSWINE1') $RSRAS(R,SR,'SLGHSWINE1') = BISF(R,SR,'SWINEFAC');
PRODSR.L(R,SR,'POULTRY') $RSRAS(R,SR,'POULTRY') = BISF(R,SR,'PLTRYFAC');
PRODSR.L(R,SR,'CHICKEN') $RSRAS(R,SR,'CHICKEN') = BISF(R,SR,'CHICKFAC');

* Horses
PRODSR.LO(R,SR,'HORSES') $RSRAS(R,SR,'HORSES') = BISF(R,SR,'CROPLAND') * 0.1;
PRODSR.L(R,SR,'HORSES')  $RSRAS(R,SR,'HORSES') = BISF(R,SR,'CROPLAND') * 0.15;
PRODSR.UP(R,SR,'HORSES') $RSRAS(R,SR,'HORSES') = BISF(R,SR,'CROPLAND') * 0.25;
*======================================================================


* ------------------------
* 7) DEFINITIONS: EQUATIONS
* ------------------------
$STITLE Equation definitions, model and solve statements
OBJECTIVE..
  - SUM(R, SUM(IR $IRES(R,IR), (BIR(R,IR,'INTERCEPT')*SUPPLYIR(R,IR))+(0.5*BIR(R,IR,'SLOPE')
                               *(SUPPLYIR(R,IR)**2)))
         + SUM(SR $RSR(R,SR), SUM(IS $ISES(R,SR,IS), (BIS(R,SR,IS,'INTERCEPT')*SUPPLYIS(R,SR,IS))
                                  +(0.5*BIS(R,SR,IS,'SLOPE')*(SUPPLYIS(R,SR,IS)**2)))))
  + SUM(R, SUM(PR $PRED(R,PR), (BPR(R,PR,'INTERCEPT')*DEMANDPR(R,PR))+(0.5*BPR(R,PR,'SLOPE')
                              *(DEMANDPR(R,PR)**2)))
+ SUM(SR $RSR(R,SR), SUM(PS $PSED(R,SR,PS), (BPS(R,SR,PS,'INTERCEPT')*DEMANDPS(R,SR,PS))
                                  +(0.5*BPS(R,SR,PS,'SLOPE')*(DEMANDPS(R,SR,PS)**2)))))
  - SUM(RS, SUM(RD, SUM(IP $TIP(RS,RD,IP), CT(RS,RD,IP)*TRANIP(RS,RD,IP))))
  - SUM(IN $INES(IN), (BIN(IN,'INTERCEPT')*SUPPLYIN(IN))+(0.5*BIN(IN,'SLOPE')*(SUPPLYIN(IN)**2)))
  + SUM(PN $PNED(PN), (BPN(PN,'INTERCEPT')*DEMANDPN(PN))+(0.5*BPN(PN,'SLOPE')*(DEMANDPN(PN)**2)))
  + SUM(R, SUM(PREX $RPREX(R,PREX), BXR(R,PREX,'ADJPRICE')*EXPORTRP(R,PREX)))
  - SUM(R, SUM(PRIM $RPRIM(R,PRIM), BMR(R,PRIM,'ADJPRICE')*IMPORTPR(R,PRIM))) =E= Z;

PRODUCTNE(PN) $PNED(PN)..
  SUM(R, SUM(SR $RSR(R,SR), SUM(AS $RSRAS(R,SR,AS), -EAS(R,SR,AS,PN)*PRODSR(R,SR,AS)))
         + SUM(CR $RCR(R,CR), -ECR(R,CR,PN)*PROCR(R,CR))) - DEMANDPN(PN) =E= 0;
 
PRODUCTNF(PN) $PNFD(PN)..
  SUM(R, SUM(SR $RSR(R,SR), SUM(AS $RSRAS(R,SR,AS), -EAS(R,SR,AS,PN)*PRODSR(R,SR,AS)))
         + SUM(CR$RCR(R,CR), -ECR(R,CR,PN)*PROCR(R,CR))) =G= BPN(PN,'MIN');
 
PRODUCTRE(R,PR) $PRED(R,PR)..
  SUM(SR $RSR(R,SR), SUM(AS $RSRAS(R,SR,AS),-EAS(R,SR,AS,PR)*PRODSR(R,SR,AS)))
  + SUM(CR $RCR(R,CR),-ECR(R,CR,PR)*PROCR(R,CR))
  - DEMANDPR(R,PR) - SUM(RD $TIP(R,RD,PR),TRANIP(R,RD,PR)) + SUM(RS $TIP(RS,R,PR),TRANIP(RS,R,PR))
  - EXPORTRP(R,PR) $RPREX(R,PR) + IMPORTPR(R,PR) $RPRIM(R,PR) =G= 0;
 
PRODUCTRF(R,PR) $PRFD(R,PR)..
  SUM(SR $RSR(R,SR), SUM(AS $RSRAS(R,SR,AS),-EAS(R,SR,AS,PR)*PRODSR(R,SR,AS)))
  + SUM(CR $RCR(R,CR),-ECR(R,CR,PR)*PROCR(R,CR))
  - SUM(RD $TIP(R,RD,PR),TRANIP(R,RD,PR)) + SUM(RS $TIP(RS,R,PR),TRANIP(RS,R,PR))
  - EXPORTRP(R,PR) $RPREX(R,PR) + IMPORTPR(R,PR) $RPRIM(R,PR) =G= BPR(R,PR,'MIN');
 
PRODUCTSE(R,SR,PS) $PSED(R,SR,PS)..
  SUM(AS $RSRAS(R,SR,AS), - EAS(R,SR,AS,PS)*PRODSR(R,SR,AS)) - DEMANDPS(R,SR,PS) =G= 0;
 
PRODUCTSF(R,SR,PS) $PSFD(R,SR,PS)..
  SUM(AS $RSRAS(R,SR,AS), - EAS(R,SR,AS,PS)*PRODSR(R,SR,AS)) =G= BPS(R,SR,PS,'MIN');
 
INPUTNE(IN) $INES(IN)..
  SUM(R, SUM(SR $RSR(R,SR), SUM(AS $RSRAS(R,SR,AS), EAS(R,SR,AS,IN)*PRODSR(R,SR,AS)))
         + SUM(CR $RCR(R,CR), ECR(R,CR,IN)*PROCR(R,CR))) - SUPPLYIN(IN) =E= 0;
 
INPUTNF(IN) $INFS(IN)..
  SUM(R, SUM(SR $RSR(R,SR), SUM(AS $RSRAS(R,SR,AS), EAS(R,SR,AS,IN)*PRODSR(R,SR,AS)))
         + SUM(CR $RCR(R,CR), ECR(R,CR,IN)*PROCR(R,CR))) =L= BIN(IN,'MAX');

INPUTRE(R,IR) $IRES(R,IR)..
  SUM(SR $RSR(R,SR), SUM(AS $RSRAS(R,SR,AS), EAS(R,SR,AS,IR)*PRODSR(R,SR,AS)))
  + SUM(CR $RCR(R,CR), ECR(R,CR,IR)*PROCR(R,CR)) - SUPPLYIR(R,IR) 
  + SUM(RD $TIP(R,RD,IR),TRANIP(R,RD,IR)) - SUM(RS $TIP(RS,R,IR),TRANIP(RS,R,IR)) =L= 0;
 
INPUTRF(R,IR) $IRFS(R,IR)..
  SUM(SR $RSR(R,SR), SUM(AS $RSRAS(R,SR,AS), EAS(R,SR,AS,IR)*PRODSR(R,SR,AS)))
  + SUM(CR $RCR(R,CR), ECR(R,CR,IR)*PROCR(R,CR))
  + SUM(RD $TIP(R,RD,IR),TRANIP(R,RD,IR))
  - SUM(RS $TIP(RS,R,IR),TRANIP(RS,R,IR)) =L= BIR(R,IR,'MAX');

INPUTSE(R,SR,IS) $ISES(R,SR,IS)..
  SUM(AS $RSRAS(R,SR,AS), EAS(R,SR,AS,IS)*PRODSR(R,SR,AS)) - SUPPLYIS(R,SR,IS) =L= 0.0;
 
INPUTSF(R,SR,IS) $ISFS(R,SR,IS)..
  SUM(AS $RSRAS(R,SR,AS), EAS(R,SR,AS,IS)*PRODSR(R,SR,AS)) =L= BIS(R,SR,IS,'MAX');
*======================================================================


* ------------------------
* 8) MODEL + SOLVE
* ------------------------
MODEL SASM /ALL/;
 

SOLVE SASM USING NLP MAXIMIZING Z;

PRODSR.LO(R,SR,AS) $RSRAS(R,SR,AS) = 0.000;

SOLVE SASM USING NLP MAXIMIZING Z;
PRODSR.LO(R,SR,'HORSES') $RSRAS(R,SR,'HORSES') = BISF(R,SR,'CROPLAND') * 0.1;
PRODSR.LO(R,SR,'POULTRY') $RSRAS(R,SR,'POULTRY') = BISF(R,SR,'PLTRYFAC') * 0.33;
*PRODSR.UP(R,SR,PASTURES) $RSRAS(R,SR,PASTURES) = 0.000;

SOLVE SASM USING NLP MAXIMIZING Z;

EAS(R,SR,DCOWS,'DPTRANR')$RSRAS(R,SR,DCOWS) =  EAS(R,SR,DCOWS,'DPTRANR') *
    (1-(1-SUPPLYIN.L('DPTRANC')/DEMANDPN.L('DPTRANR'))*0.90);

SOLVE SASM USING NLP MAXIMIZING Z;

EAS(R,SR,DCOWS,'DPTRANR')$RSRAS(R,SR,DCOWS) =  EAS(R,SR,DCOWS,'DPTRANR') *
    (1-(1-SUPPLYIN.L('DPTRANC')/DEMANDPN.L('DPTRANR'))*0.90);

SOLVE SASM USING NLP MAXIMIZING Z;

EAS(R,SR,DCOWS,'DPTRANR')$RSRAS(R,SR,DCOWS) =  EAS(R,SR,DCOWS,'DPTRANR') *
    (1-(1-SUPPLYIN.L('DPTRANC')/DEMANDPN.L('DPTRANR'))*0.90);

SOLVE SASM USING NLP MAXIMIZING Z;

EAS(R,SR,DCOWS,'DPTRANR')$RSRAS(R,SR,DCOWS) =  EAS(R,SR,DCOWS,'DPTRANR') *
    (1-(1-SUPPLYIN.L('DPTRANC')/DEMANDPN.L('DPTRANR'))*0.90);
    
SOLVE SASM USING NLP MAXIMIZING Z;

EAS(R,SR,DCOWS,'DPTRANR')$RSRAS(R,SR,DCOWS) =  EAS(R,SR,DCOWS,'DPTRANR') *
    (1-(1-SUPPLYIN.L('DPTRANC')/DEMANDPN.L('DPTRANR'))*0.90);
    
SOLVE SASM USING NLP MAXIMIZING Z;
*======================================================================

$ifthen "%tradeReduction%" == "yes"
$include Trade_reduction.gms
$endif

* ------------------------
* 9) Reporting (optional)
* ------------------------
$include report.gms
