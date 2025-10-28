$TITLE SASM 2025, 2025 based on Outlook 2024, Bas 2025.
$OFFSYMXREF
$OFFSYMLIST
$ONTEXT

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

$OFFTEXT
 
OPTION LIMROW=0, LIMCOL=0, SOLPRINT=OFF, ITERLIM=2000000, RESLIM=900000;
*OPTION LIMROW=0, LIMCOL=0, SOLPRINT=OFF, ITERLIM=1000, RESLIM=900000;
 
SET OCI  Output control items
 /DSETS     Display of dynamic sets
  SPARM     Display of supply parameters
  DPARM     Display of demand parameters
  PRODIO    Display of prod act coef
  UTCOST    Display of unit trans costs
  PRODUCTS  Display product summaries
  PPRICES   Display product price summaries
  INPUTS    Display input summaries
  IPRICES   Display input price summaries
  PRODACT   Display production activity summaries
  VARS      Display results for all variables
  EQNS      Display results for all equations/;
 
SET OC(OCI)  Output control set;
  OC('DSETS')    =  NO;
  OC('SPARM')    =  NO; 
  OC('DPARM')    =  NO;
  OC('PRODIO')   =  NO;
  OC('UTCOST')   =  NO;
  OC('PRODUCTS') =  YES;
  OC('PPRICES')  =  YES;
  OC('INPUTS')   =  YES;
  OC('IPRICES')  =  YES;
  OC('PRODACT')  =  YES;
  OC('VARS')     =  YES;
  OC('EQNS')     =  NO;

* The variable and equation results (VARS and EQNS) do not include solutions (marginals) for
* non-optimal transportation activities.  Otherwise, the variable and equation results are the same
* as those generated with the solve statement. Therefore, if SOLPRINT=ON (see option statement
* above), VARS and EQNS should not be displayed.

PARAMETER LONGRUN;
LONGRUN = NO;
* Make LONGRUN equal to NO for short run analysis. Base year for acreage och buildings is 2021.

PARAMETER LONGRUN1;
LONGRUN1 = YES;

PARAMETER LONGRUN2;
LONGRUN2 = YES;
* Make LONGRUN2 equal to NO for analysis without productivity development.

PARAMETER CO2IMP;
CO2IMP = yes;
* Make CO2IMP equal to NO for analysis without climate effects of imported inputs and products.

SCALAR KPI changed consumer price index from base year /1.267/;
SCALAR KPI2 changed consumer price index from 2023 /1.034/;
SCALAR KPI3 changed all prices from base year to monetary value 2024 /1.248/;
* Make LONGRUN1 equal to NO for analysis without price development.

SCALAR YR number of years from base year /0/;
SCALAR YRA number of years from base year for acreages /3/;
* Data on available acreages are from 2022
SCALAR YRT number of years from base year for technical coef /5/;
* Technical coef are for 2014 but adjusted to 2020

SCALAR KURS exchange rate SEK per EURO /11.2/;
*SCALAR KURS exchange rate SEK per EURO /10.0/;
SCALAR RED Reduction in trade and transport /1.00/;

$STITLE SET DECLARATIONS AND ASSIGNMENTS
$ONTEXT
Overview of sets
---------------------------------------------------------------------------------------------------
Set..............  Description....................................................................
---------------------------------------------------------------------------------------------------
R                  Regions (markets)
RS                 Source regions, alias R
RD                 Destination regions, alias R
SR                 Subregions for production
RSR(R,SR)          Subregions mapped to regions **
PR                 Production regions for production data
PRSR(PR,SR)        Subregions mapped to production regions **

IP                 Inputs and products

I(IP)              Inputs
IN(I)              National inputs
IR(I)              Regional inputs
RIR(R,IR)          Regional inputs mapped to regions **
IS(I)              Subregional inputs
RSRIS(R,SR,IS)     Subregional inputs mapped to regions and subregions **

P(IP)              Products
PN(P)              National products
PR(P)              Regional products
PS(P)              Subregional products
RSRPS(R,SR,PS)     Subregional products mapped to regions and subregions **
RPR(R,PR)          Regional products mapped to regions **
PEX(P)             Exported products
PIM(P)             Imported products
PREX(PR)           Exported regional products **
PRIM(PR)           Imported regional products **

RPREX(R,PR)        Exported regional products mapped to regions **
RPRIM(R,PR)        Imported regional products mapped to regions **

AS                 Crop and livestock production activities, subregional 
RSRAS(R,SR,AS)     Crop and livestock production activities mapped to regions and subregions **

CR                 Processing activities, regional 
RCR(R,CR)          Processing activities mapped to regions **

T(RS,RD)           Transportation patterns **
TIP(RS,RD,IP)      Regional inputs and products mapped to shipping patterns RS to RD **

SDP                Supply and demand parameters

INES(IN)           Elastic supply national inputs **
INFS(IN)           Fixed supply national inputs **
IRES(R,IR)         Elastic supply regional inputs mapped to regions **
IRFS(R,IR)         Fixed supply regional inputs mapped to regions **
ISES(R,SR,IS)      Elastic supply subregional inputs mapped to regions and subregions **
ISFS(R,SR,IS)      Fixed supply subregional inputs mapped to regions and subregions **

PNED(PN)           Elastic demand national products **
PNFD(PN)           Fixed demand national products **
PRED(R,PR)         Elastic demand regional products mapped to regions **
PRFD(R,PR)         Fixed demand regional products mapped to regions **
PSED(R,SR,PS)      Elastic demand subregional products mapped to regions and subregions **
PSFD(R,SR,PS)      Fixed demand subregional products mapped to regions and subregions **

TRD                Trade parameters;
---------------------------------------------------------------------------------------------------
** This set is dynamic in that its elements are assigned. Such assignments are based on the
   elements of other sets or the values of certain parameters. Once membership has been assigned,
   it is useful to exclude elements from certain sets in order to manage model size. For example,
   all regional inputs are assigned to all regions. However, if some inputs are not used in some
   regions, the number of constraints may be reduced by excluding the inputs from those regions.
   Elements should be removed from the following sets when it is appropriate to do so: RIR, RPR,
   RPREX, RPRIM, RAR, RCR, T.
$OFFTEXT 
 
SET R  Regions (markets)
*---------------------------------------------------------------------------------------------------
* Region....     Description........................................................................
*---------------------------------------------------------------------------------------------------
 /R1             North:      AC-BD
  R2             Middle:     W-X-Y-Z
  R3             Stockholm:  AB-C-D-E-T-U               
  R4             Gothenburg: O-S 
  R5             Smaland:    F-G-H-I-K-N
  R6             Skane:      LM /;
*---------------------------------------------------------------------------------------------------
* Marketregions are chosen to match market regions of existing dairy processing companies.

ALIAS (R,RS);
ALIAS (R,RD);

SETS
  R1TO2(R)  /R1*R2/ 
  R3TO6(R)  /R3*R6/;
  
SET SR  Subregions for production /SR001*SR081/;
* Production regions are chosen to match municipal and support areas.

SETS
  SR01(SR)   /SR001*SR002/
  SR02(SR)   /SR003*SR005/
  SR03(SR)   /SR006*SR008/
  SR04(SR)   /SR009*SR011/
  SR04a(SR)  /SR009/
  SR04b(SR)  /SR010*SR011/
  SR05(SR)   /SR012*SR015/
  SR06(SR)   /SR016*SR023/
  SR06a(SR)  /SR016*SR020,SR022*SR023/
  SR06b(SR)  /SR021/
  SR07(SR)   /SR024*SR032/
  SR07a(SR)  /SR024*SR028,SR030*SR032/
  SR07b(SR)  /SR029/
  SR08(SR)   /SR033*SR042/
  SR09(SR)   /SR043*SR053/
  SR10(SR)   /SR054*SR060/
  SR11(SR)   /SR061*SR067/
  SR12(SR)   /SR068/
  SR0ssk(SR) /SR069/
  SR0gsk(SR) /SR070*SR073/
  SR0ss(SR)  /SR074*SR075/
  SR0gns(SR) /SR076*SR077/
  SR0gmb(SR) /SR078*SR079/
  SR0gss(SR) /SR080*SR081/
  SR0m(SR)   /SR069,SR074*SR077/
  SR0s(SR)   /SR070*SR073,SR078*SR081/;

SETS
  SR1TO4a(SR)  /SR001*SR009/
  SR1TO4b(SR)  /SR001*SR011/
  SR1TO5(SR)   /SR001*SR015/
  SR1TO7a(SR)  /SR001*SR028,SR030*SR032/
  SR1TO7b(SR)  /SR001*SR032/
  SR1TO12(SR)  /SR001*SR068/
  SR6TO12(SR)  /SR016*SR068/
  LFAHIGH(SR)  /SR001*SR042,SR061*SR068/
  SR9TO10(SR)  /SR043*SR060/
  SR0(SR)      /SR069*SR081/;

SETS
  RSR1(SR)   /SR001,SR003,SR006,SR009/
  RSR2(SR)   /SR002,SR004,SR005,SR007,SR008,SR010,SR012,SR014,SR016,SR024/
  RSR3(SR)   /SR017,SR019,SR022,SR025,SR027,SR030,SR033,SR035,SR039,SR043,SR045,SR049,
              SR051,SR054,SR058,SR061,SR064,SR068*SR070,SR074,SR076/
  RSR4(SR)   /SR011,SR013,SR015,SR018,SR020,SR023,SR026,SR028,SR031,SR032,SR034,SR036,
              SR040,SR041,SR044,SR046,SR050,SR052,SR055,SR059,SR062,SR065,SR071,SR075,SR077/
  RSR5(SR)   /SR021,SR029,SR037,SR042,SR047,SR053,SR056,SR060,SR063,SR066,SR072,SR078,SR080/
  RSR6(SR)   /SR038,SR048,SR057,SR067,SR073,SR079,SR081/;

SETS
  NOO(SR)    /SR001*SR004,SR006*SR007,SR009/
  NN(SR)     /SR005,SR008,SR010*SR013/
  SSK(SR)    /SR014*SR018,SR024*SR026,SR033*SR034,SR043*SR044,SR061,SR069/
  GSK(SR)    /SR019*SR021,SR027*SR029,SR035*SR038,SR045*SR048,SR054*SR057,SR062*SR063,SR070*SR073/
  SS(SR)     /SR022,SR030*SR031,SR039*SR040,SR049*SR050,SR058,SR064,SR068,SR074*SR075/
  GNS(SR)    /SR023,SR032,SR041,SR051,SR052,SR059,SR065,SR076*SR077/
  GMB(SR)    /SR042,SR053,SR060,SR066,SR078*SR079/
  GSS(SR)    /SR067,SR080*SR081/;
  
SET RSR(R,SR)  Subregions mapped to regions;
  RSR(R,SR) = NO;
  RSR('R1',RSR1) = YES;
  RSR('R2',RSR2) = YES;
  RSR('R3',RSR3) = YES;
  RSR('R4',RSR4) = YES;
  RSR('R5',RSR5) = YES;
  RSR('R6',RSR6) = YES;

SET UPR  Output-regions /UPR01*UPR08/;
SET UPRSR(UPR,SR)  Production regions mapped to subregions;
  UPRSR(UPR,SR) = NO;
  UPRSR('UPR01',GSS) = YES;
  UPRSR('UPR02',GMB) = YES;
  UPRSR('UPR03',GNS) = YES;
  UPRSR('UPR04',SS)= YES;
  UPRSR('UPR05',GSK)= YES;
  UPRSR('UPR06',SSK) = YES;
  UPRSR('UPR07',NN)= YES;
  UPRSR('UPR08',NOO)= YES;
$ONTEXT
  UPRSR('UPR01',SR01) = YES;
  UPRSR('UPR02',SR02) = YES;
  UPRSR('UPR03',SR03) = YES;
  UPRSR('UPR04',SR04a)= YES;
  UPRSR('UPR04',SR04b)= YES;
  UPRSR('UPR05',SR05) = YES;
  UPRSR('UPR06',SR06a)= YES;
  UPRSR('UPR06',SR06b)= YES;
  UPRSR('UPR07',SR07a)= YES;
  UPRSR('UPR07',SR07b)= YES;
  UPRSR('UPR08',SR08) = YES;
  UPRSR('UPR09',SR09) = YES;
  UPRSR('UPR10',SR10) = YES;
  UPRSR('UPR11',SR11) = YES;
  UPRSR('UPR12',SR12) = YES;
  UPRSR('UPR13',SR0ss) = YES;
  UPRSR('UPR13',SR0ssk) = YES;
  UPRSR('UPR13',SR0gns) = YES;
  UPRSR('UPR14',SR0gsk) = YES;
  UPRSR('UPR14',SR0gmb) = YES;
  UPRSR('UPR14',SR0gss) = YES;
$OFFTEXT 
SET NPR  Natural Production Regions /NPR01*NPR08/;
SET NPRSR(NPR,SR)  Natural Production Regions mapped to subregions;
  NPRSR(NPR,SR) = NO;
  NPRSR('NPR01',GSS) = YES;
  NPRSR('NPR02',GMB) = YES;
  NPRSR('NPR03',GNS) = YES;
  NPRSR('NPR04',SS)= YES;
  NPRSR('NPR05',GSK)= YES;
  NPRSR('NPR06',SSK)= YES;
  NPRSR('NPR07',NN)= YES;
  NPRSR('NPR08',NOO) = YES;
  
SET IP  Inputs and products

*---------------------------------------------------------------------------------------------------
* Item......     Description........................................................................
*---------------------------------------------------------------------------------------------------
*Fixed inputs
 /CROPLAND       Tillable crop land: 1000 ha
  PRMPAST        Permanent pasture: 1000 ha
  PRMPASTB       Permanent pasture with basic values: 1000 ha (not used)
  PRMPASTT       Permanent pasture with high values: 1000 ha
  PRMPASTN       Permanent pasture with top values: 1000 ha
  PRMPASTH       Part of permanent pasture with high production: 1000 ha
  PRMPASTHB      Part of permanent pasture with high production and basic values: 1000 ha
  PRMPASTHT      Part of permanent pasture with high production and high values: 1000 ha
  PRMPASTHN      Part of permanent pasture with high production and top values: 1000 ha
  PRMALV         Permanent pasture on Alvaret: 1000 ha
  PRMFOR         Permanent forest pasture: 1000 ha
  PRMMOS         Permanent pasture mosaik: 1000 ha
  PRMLOW         Permanent pasture low production (grasfattig): 1000 ha
  PRMCHAL        Permanent chalet pasture (fabod): 1000 ha
  PRMMEAD        Permanent hay meadow (slatterang): 1000 ha
  PRMPASTUP      Part of permanent pasture that can be upgraded to top support: 1000 ha
  PRMPASTHUP     Part of permanent high productive pasture that can be upgraded: 1000 ha
  POTPAST        Potential permanent pasture: 1000 ha
  POTPASTT       Potential permanent pasture with high values: 1000 ha
  POTPASTN       Potential permanent pasture with top values: 1000 ha
  POTALV         Potential permanent pasture on Alvaret: 1000 ha
  POTFOR         Potential permanent forest pasture: 1000 ha
  POTMOS         Potential permanent pasture mosaik: 1000 ha
  POTLOW         Potential permanent pasture low production (grasfattig): 1000 ha
  POTCHAL        Potential permanent chalet pasture (fabod): 1000 ha
  POTMEAD        Potential permanent hay meadow (slatterang): 1000 ha
  ORGCROPL       Organic crop land: 1000 ha
  ORGPASTR       Organic pasture land: 1000 ha
  ACRCOST        Various cost for crop acreage: 1000 ha
  ACRCOSTP       Various cost for permanent pasture: 1000 ha
  ACRCOSTPB      Various cost for permanent pasture with basic support: 1000 ha (not used)
  ACRCOSTPT      Various cost for permanent pasture with top support: 1000 ha
  ACRCOSTPN      Various cost for permanent pasture with N2000 support: 1000 ha
  ACRCOSTPH      Various cost for permanent pasture with high production: 1000 ha
  ACRCOSTPHB     Various cost for permanent pasture high prod basic support: 1000 ha (not used)
  ACRCOSTPHT     Various cost for permanent pasture with high production and top support: 1000 ha
  ACRCOSTPHN     Various cost for permanent pasture with high production and N2000 supp: 1000 ha
  ACRCOSTALV     Various cost for pasture at Alvaret: 1000 ha
  ACRCOSTFOR     Various cost for pasture at forestpasture: 1000 ha
  ACRCOSTMOS     Various cost for pasture at mosaik land: 1000 ha
  ACRCOSTLOW     Various cost for pasture at low productive land: 1000 ha
  ACRCOSTCHA     Various cost for pasture at chalet land: 1000 ha    
  ACRCOSTMEA     Various cost for hay meadow: 1000 ha
  ACRECO         Tillable ecologic crop land: 1000 ha
  ACRECON        Various cost convert to ecological production: 1000 ha
  PCAPKMILK      Consumption milk processing capacity: 1000 ton
  PCAPCHEESE     Cheese processing capacity: 1000 ton
  PCAPBUTTER     Butter processing capacity: 1000 ton
  PCAPDRYMLK     Dry milk processing capacity: 1000 ton
  PCAPBEEF       Beef slaughtering capacity: 1000 ton
  PCAPPORK       Pork slaughtering capacity: 1000 ton
  PCAPPLTRY      Poultry slaughtering capacity: 1000 ton
  PCAPMILL       Milling processing capacity: 1000 ton
  PCAPFEED       Feed processing capacity: 1000 ton
  PCAPPOTS       Potato seed processing capacity: 1000 ton
  DAIRYFAC       Dairy production facilities: 1000 fac
  DAIRYFACR      Dairy prod facilities remodelable: 1000 fac
  BULLFAC        Bull production facilities: 1000 bulls
  BULLFACR       Bull production facilities remodelable: 1000 bulls
  BEEFCFAC       Beef cattle production facilities: 1000 cows
  BEEFCFACR      Beef cattle production facilities remodelable: 1000 cows
  SOWFAC         Production facilities for sows: 1000 sow
  SOWFACR        Production facilities for sows remodelable: 1000 sow
  SWINEFAC       Production facilities for slaughter swine: 1000 hd
  SWINEFACR      Production facilities for slaughter swine remodelable: 1000 hd
  PLTRYFAC       Poultry production facilities: Mil hd
  PLTRYFACR      Poultry production facilities remodelable: Mil hd
  PLTRYCAP       Poultry production capacity: Mil hd
  CHICKFAC       Chicken production facilities: Mil hd
  CHICKFACR      Chicken production facilities remodelable: Mil hd
  CHICKCAP       Chicken production capacity: Mil hd
  HORSEFAC       Production facilities for horses: 1000 horses
  SHEEPFAC       Production facilities for sheep: 1000 ewes
*Variable inputs
  CAPITAL        Operating capital costs: Mil SEK
  LABOR          Labor: Mil hours
  LABOR2         Additional labor cost livestock : Mil hours
  POWER          Use of tractors etc: Mil hours
  DIESEL         Diesel: 1000 m3
  NITROGEN       Nitrogen fertiliser: ton nitrogen
  PHOSPHORUS     Phosphorus fertiliser: ton phosphorus
  POTASSIUM      Potassium fertiliser: ton potassium 
  ECON           Nitrogen in ecological rotation: ton nitrogen
  ECOP           Phosphorus in ecological rotation: ton phosphorus
  ECOK           Potassium in ecological rotation: ton potassium 
  PESTICIDES     Pesticide costs: Mil SEK
  HERBICIDES     Herbicides: ton active substance
  GLYFOSAT       Herbicides: ton active substance
  FUNGICIDES     Fungicides: ton active substance
  INSECTICID     Insecticides: ton active substance
  PLASTIC        Plastic for bales of silage: 1000 rolls
  OTHRVARCST     Other variable costs: Mil SEK
  SOJA           Meal from soybean: 1000 ton
  BETFOR         Betfor: 1000 ton
  HP-MASSA       HP-massa: 1000 ton ts
  PROTFEED       Protein feed: 1000 ton
  OTHERFEED      Other feed costs: Mil SEK
  ENERGYUSE      Energy use: TWh
  N-LEAKAGE      Loss of nitrogen trough soil: 1000 tons
  P-LEAKAGE      Loss of phosphorus trough soil: 1000 tons
*  CLIMATE        Climate costs: Mil SEK
*  CLIMATE2       Climate costs livestock: Mil SEK
  N-PROD         Production of nitrogen: 1000 tons
  P-PROD         Production of phosphorous: 1000 tons
  CO2            Loss of CO2 (carbon dioxide): 1000 tons 
  CH4            Loss of CH4 (methane): 1000 tons
  N2O            Loss of N2O (laughing gas): 1000 tons
  CO2EQ          Loss of CO2 equivalents: 1000 tons
  NH3            Loss of NH3 (ammonia): 1000 tons
  YIELDRIRE1     Yield risk reduction for forage and pasture: 1000 ton     
  YIELDRIRE2     Yield risk reduction for forage and pasture: 1000 ton     
  YIELDRIRE3     Max yield risk reduction for forage and pasture: 1000 ton     
  P-COST         Processing cost: Mil SEK
  GRAINSEED      Grain seed: 1000 ton
  OILGRSEED      Oilgrain seed: milj units (1 unit = 10 kg)
  PEASSEED       Feed peas seed: milj units (1 unit = 17.5 kg)
  POTATOSEED     Potatoes seed: 1000 ton
  SUGARBSEED     Sugar-beet seed: milj units   
  VEGETSEED      Seed for vegetables: 1000 ha
  INCONVCOV      Inconveaniens of cover crops: 1000 ha
  INCONVCAT      Inconveaniens of catch crops: 1000 ha
  INCONVLAT      Inconveaniens of late or spring tillage: 1000 ha
  INCONVECOV     Inconveaniens of ecologic cover crops: 1000 ha
  INCONVECAT     Inconveaniens of ecologic catch crops: 1000 ha
  INCONVELAT     Inconveaniens of ecologic late or spring tillage: 1000 ha
*Products
  BREADGRAIN     Bread grains (wheat rye): 1000 ton
  COARSGRAIN     Coarse grains (barley oats mixed): 1000 ton
  FLOUR          Flour from bread grains (wheat rye): 1000 ton
  FEEDGRAIN      Bread and coarse grains used for feed: 1000 ton
  ENERBGR        Breadgrains used for energy: 1000 ton
  ENERCGR        Coarse grains used for energy: 1000 ton
  GSILAGE        Grain silage: 1000 ton
  MSILAGE        Majs silage: 1000 ton
  PEAS           Feed peas hanvested: 1000 ton
  FPEAS          Feed peas for feed: 1000 ton
  PPEAS          Processed feed peas: 1000 ton
  EPEAS          Ecologic feed peas: 1000 ton	
  OILGRAIN       Oil grains (rape turnip. rape other): 1000 ton
  ENEROILG       Oil grains used for energy: 1000 ton
  RAPEOIL        Oil from rape seed: 1000 ton
  RAPEMEAL       Meal from extraction of oil: 1000 ton
  RAPSKAKA       Cake from cold processing of oil: 1000 ton
  POTATOES       Potatoes: 1000 ton  
  SUGARBEET      Sugar-beet: 1000 ton
  WHITESUGAR     Processed white sugar: 1000 ton
  SILAGE         Silage: 1000 ton ts
  SILAGEHQ       Silage with high quality: 1000 ton ts
  HAY            Hay for dairy cows: 1000 ton
  GRASSPASTR     Pasture grass: 1000 ton
  GRASSPASTF     Pasture grass from forage: 1000 ton
  ESILAGE        Ecoligical silage and hay: 1000 ton
  ESILAGEHQ      Ecoligical silage with high quality: 1000 ton
  EGRASSPAST     Ecoligical pasture grass: 1000 ton
  EGRASSPASF     Ecoligical pasture grass from forage: 1000 ton
  USEPASTR       Required use of pasture grass: 1000 ton
  OTHRCROPPR     Other crop products: 1000 ha
  ICRPR          Industry crop products: 1000 ha
  SALIXMJ        Energy from Salix: 1000 MWh
  UNDEFUSE       acreage with undefined use: 1000 ha
  MILK           Farm milk: 1000 ton
  DCALFM         Male dairy calves: 1000 hd
  DCALFF         Female dairy calves: 1000 hd
  DHEIFER        Female dairy heifers: 1000 hd
  PIGLETS        Piglets: 1000 hd
  GILTS          Gilts: 1000 hd
  EDCALFM        Ecoligical male dairy calves: 1000 hd
  EDCALFF        Ecoligical female dairy calves: 1000 hd
  EDHEIFER       Ecoligical female dairy heifers: 1000 hd
  EPIGLETS       Ecoligical piglets: 1000 hd
  EGILTS         Ecoligical gilts: 1000 hd
  ECOMPMAN       Ecological compressed manure: 
  SLGHBEEF       Slaughter beef including culls and dairy: 1000 ton
  SLGHPORK       Slaughter hogs: 1000 ton
  SLGHPLTRY      Slaughter poultry: 1000 ton
  SLGHSHEEP      Slaughter sheep: 1000 ton
  EGG            Egg. 1000 ton
  RIDING         Horses for riding: 1000 hd
  MINSHEEP       Minimum number of sheep in solution: 1000 hd
  MINDCOW        Minimum number of dairy cows in solution: 1000 hd  
  MINBCOW        Minimum number of beef cows in solution: 1000 hd
  MINLFOR        Min acreage of long laying forage: 1000 ha
  MINCACR        Minimal crop acreage: 1000 ha
  MINPAST        Min acreage of permanent pasture at subregional level: 1000 ha
  MINPASTN       Min acreage of permanent pasture at national level: 1000 ha
  SKIMMILK       Skim milk: 1000 ton
  MILKFAT        Milk fat: 1000 ton
  KMILK          Consumption milk: 1000 ton
  CHEESE         Cheese: 1000 ton
  BUTTER         Butter: 1000 ton
  CREAM          Cream: 1000 ton
  DRYMILK        Dry skim milk: 1000 ton
  DRYMILK2       Dry full milk: 1000 ton  
  BEEF           Beef: 1000 ton
  PORK           Pork: 1000 ton
  PLTRYMEAT      Poultry meat: 1000 ton
  WILDMEAT       Meat from game animals and reindeers: 1000 ton
  FISH           Fish and seafood: 1000 ton
  FRUIT          Fruit: 1000 ton
  VEGETAB        Vegetables: 1000 ton
  WBERRY         Wild berrys for consumption: 1000 ton
  EGRAIN         Ecological bread grain additional value: 1000 ton
  ERAPE          Ecological rape seed additional value: 1000 ton
  ESUGARB        Ecological sugar beet additional value: 1000 ton
  EPOTATOES      Ecological potatoes additional value: 1000 ton
  EMILK          Ecological farm milk additional value: 1000 ton
  EBEEF          Ecological beef additional value: 1000 ton
  EPORK          Ecological pork additional value: 1000 ton
  ESHEEPM        Ecological sheep beet additional value: 1000 ton
  EEGG           Ecological egg additional value: 1000 ton
  MINKONVM       Minimum volume of conventional milk: 1000 ton
  ENERGY         Energy in food: TeraJoule
  PROTEIN        Protein in food: 1000 ton
  PROTEINA       Protein with animal origin in food: 1000 ton
  FAT            Fat in food: 1000 ton
  CARBOH         Carbohydrates in food: 1000 ton
  BREADGRC       Bread grains (wheat rye)for consumption: 1000 ton
  COARSGRC       Coarse grains for consumption: 1000 ton
  FLOURC         Flour from bread grains for consumption: 1000 ton		
  RAPEOILC       Oil from rape seed for consumption: 1000 ton
  POTATOESC      Potatoes for consumption: 1000 ton  
  SUGARC         Sugar for consumption: 1000 ton
  OTHRCROPC      Other crop products for consumption: 1000 ha
  ICRPRC         Industry crop products for consumption: 1000 ha
  SHEEPC         Slaughter sheep for consumption: 1000 ton
  EGGC           Egg for consumption: 1000 ton
  KMILKC         Consumption milk for consumption: 1000 ton
  CHEESEC        Cheese for consumption: 1000 ton
  BUTTERC        Butter for consumption: 1000 ton
  CREAMC         Cream for consumption: 1000 ton
  DRYMILKC       Dry milk for consumption: 1000 ton
  BEEFC          Beef for consumption: 1000 ton
  PORKC          Pork for consumption: 1000 ton
  PLTRYMEATC     Poultry meat for consumption: 1000 ton
  WILDMEATC      Meat from game animals and reindeers for consumption: 1000 ton
  FISHC          Fish and seafood for consumption: 1000 ton
  VEGETABC       Vegetables for consumption: 1000 ton
  FRUITC         Fruit for consumption: 1000 ton
  WBERRYC        Wild berrys for consumption: 1000 ton
  CBONDING       Changed bonding of carbon in the soil: 1000 tons
*Policy variables
  MISCCOST       Miscellaneous cost: Mil SEK
  DPTRANB        Dairy processing transfer balance: Mil SEK
  DPTRANR        Dairy processing transfer receipt: Mil SEK
  DPTRANC        Dairy processing transfer cost: Mil SEK
  MISCRCPT       Miscellaneous receipt
  SUGARQUOTA     Sugar quota: 1000 ha
  LAYLAND        Land in set-aside program
  ECOSUB         Subsidy for ecological production: Mil SEK
  GACRSUB        General acreage subsidy: Mil SEK
  COMP4SUB       Compensation subsidy for grain etc: Mil SEK
  FORSUB         Acreage subsidy for forage: Mil SEK
  CATTLESUB      Livestock subsidy for cattle: Mil SEK
  SOWHLTSUB      Livestock subsidy for sow health: Mil SEK
  ES1            Eco scheme 1: Mil SEK
  ES2            Eco scheme 2: Mil SEK
  ES3            Eco scheme 3 (pricision): Mil SEK
  ES4            Eco scheme 4 (cover crop): Mil SEK
  ES5            Eco scheme 5 (catch crop): Mil SEK
  ES6            Eco scheme 6 (spring tilling): Mil SEK
  FARMSUB        Tax reduction on sales instead of on diesel: Mil SEK
  NATSUB         National support for less favoured areas: Mil SEK
  COMPSUB        Compensation subsidy base level: Mil SEK
  COMPSUBL       Compensation subsidy added per livestock unit: Mil SEK 
  COMPSUBF       (Acreage restriction on COMPSUPL: 1000 support units)
  BIODIVSUBL     Land use possible for biodivsub: 1000 ha
  BIODIVSUBH     Land use with high production possible for biodivsub: 1000 ha
  BIODIVSUB      Subsidy for biological diversion at permanent pasture: Mil SEK
  BIODIVSUB2     High subsidy for biological diversion at permanent pasture: Mil SEK
  BIODIVSUB3     Subsidy for biological diversion at top value pasture: Mil SEK
  BIODIVSUBA     Subsidy for biological diversion at permanent pasture on Alvaret: Mil SEK
  BIODIVSUBF     Subsidy for biological diversion at permanent pasture in forest: Mil SEK
  BIODIVSUBM     Subsidy for biological diversion at permanent pasture on mosaik land: Mil SEK
  BIODIVSUBG     Subsidy for biological diversion at permanent pasture on low productive land (grasfattig): Mil SEK
  BIODIVSUBC     Subsidy for biological diversion at permanent chalet pasture: Mil SEK
  BIODIVSUBS     Subsidy for biological diversion at land with hay mesdow: Mil SEK
  MINFOR         Minimal forage and pasture acreage for livestock subsidies
*Technical biological and policy restrictions on production
  ACRMANURE      Acreage needed for manure: 1000 ha
  MAXWHEAT       Max 20 percent wheat due to diseases at high land quality
  MAXWWHEAT      Max acreage available in autumn at high land quality
  MAXWRAY        Max acreage available in autumn for ray
  MAXOILG        Max 20 percent oil grain due to diseases at high land quality 
  MAXWOILG       Max acreage available in late summer at high land quality
  MAXPEAS        Max 10 percent peas due to diseases at low land quality 
  MAXPOTATO      Max 33 percent potatoes due to diseases at high land quality
  MAXPOTACR      Max potatoes related to acreage 1995.
  MAXSUGAR       Max 25 percent sugar due to diseases at high land quality
  MINNEWFOR      Minimum acreage seeded with forage
  MAXCOVER       Max acreage available for cover crops
  MAXCATCH       Max acreage available for catch crops
  MAXLATE        Max acreage available for spring tilling
  MAXFOR         Max share of forage as main crop: 100 percent
  MINGRAIN       Min share of grain as second crop: 100 percent
  MAXSALIX       Max acreage with salix: 1000 ha
  MINSALIX       Min acreage with salix: 1000 ha
  MINLAY         Min acreage with lay for acreage subsidies
  MAXLAY         Max acreage with lay for acreage subsidies
  MAXEWHEAT      Max 20 percent ecological wheat due to diseases at high land quality
  MAXEWWHEAT     Max ecological acreage available in autumn at high land quality
  MAXEWRAY       Max acreage available in autumn for ecological ray
  MAXEOILG       Max 20 percent ecological oil grain due to diseases at high land quality 
  MAXEWOILG      Max ecological acreage available in late summer at high land quality
  MAXEPEAS       Max 10 percent peas due to diseases at low land quality 
  MAXEPOTATO     Max 33 percent ecological potatoes due to diseases at high land quality
  MAXESUGAR      Max 25 percent ecological sugar due to diseases at high land quality
  MINENEWFOR     Minimum ecological acreage seeded with forage
  MAXECOVER      Max ecological acreage available for cover crops
  MAXECATCH      Max ecological acreage available for catch crops
  MAXELATE       Max ecological acreage available for spring tilling
  MINELAY        Min acreage with lay for acreage subsidies
  MAXELAY        Max acreage with lay for acreage subsidies
  MAXMANURE      Max use of conventional manure in eko production
  MINSILAGE      Min silage that cannot be replaced by feed grain
  MAXCRTOPST     Max croparea converted to high productive pasture: 1000 ha
  LVSTKBAL1      Livestock balance for regional redistribution: 1000 ton
  LVSTKBAL2      Livestock balance for regional redistribution: 1000 ton
  MAXECAT        Max number of ecological beefcattle in relation to other: 1000 hd
  MEDCOW         Max number of ecological dairycows:  1000 hd
  MEBEEFCATT     Max number of ecological beefcattle: 1000 hd
  MESHEEP        Max number of ecological ows: 1000 hd
  MECOPIG        Max number of ecological sows: 1000 hd
  MEPOULTRY      Max number of ecological hens: mil hd
  MINEACR        Min acreage with ecological production: 1000 ha
  MAXREIND       Max production from raindeers: 1000 ton
  MAXWILDM       Max production from game animals: 1000 ton
  MAXFISH        Max production from fish and seafood: 1000 ton
  MAXFRUIT       Max production of fruit: 1000 ton
  MAXVEGET       Max production of vegetables: 1000 ton
  MAXWBERRY      Max production of wild berries: 1000 ton/;
*---------------------------------------------------------------------------------------------------


SET FERT(IP)  Fertilizers
 /NITROGEN, PHOSPHORUS, POTASSIUM/;
 
SET FERT2(IP)  Fertilizers
 /NITROGEN, PHOSPHORUS, POTASSIUM, ECON, ECOP, ECOK/;

SET DCOWFEEDS(IP) /FEEDGRAIN, GSILAGE, MSILAGE, FPEAS, PPEAS, RAPEMEAL, RAPSKAKA, SILAGE, SILAGEHQ,
                   HAY,SOJA, BETFOR, HP-MASSA, PROTFEED, OTHERFEED/;

SET I(IP)  Inputs
 /CROPLAND, PRMPAST, PRMPASTB, PRMPASTT, PRMPASTN, PRMPASTH, PRMPASTHB, PRMPASTHT, PRMPASTHN, PRMALV, 
  PRMFOR, PRMMOS, PRMLOW, PRMCHAL, PRMMEAD, PRMPASTUP, PRMPASTHUP, POTPAST, POTPASTT,
  POTPASTN, POTALV, POTFOR, POTMOS, POTLOW, POTCHAL, POTMEAD, ORGCROPL, ORGPASTR,
  ACRCOST, ACRCOSTP, ACRCOSTPB, ACRCOSTPT, ACRCOSTPN, ACRCOSTPH, ACRCOSTPHB, ACRCOSTPHT, ACRCOSTPHN,
  ACRCOSTALV, ACRCOSTFOR, ACRCOSTMOS, ACRCOSTLOW, ACRCOSTCHA, ACRCOSTMEA,  
  PCAPKMILK, PCAPCHEESE, PCAPBUTTER, PCAPDRYMLK, PCAPBEEF, PCAPPORK, PCAPPLTRY, PCAPMILL, PCAPFEED,
  PCAPPOTS, DAIRYFAC, DAIRYFACR, BEEFCFAC, BEEFCFACR, BULLFAC, 
  BULLFACR, SOWFAC, SOWFACR, SWINEFAC, SWINEFACR, PLTRYFAC, PLTRYFACR, PLTRYCAP, CHICKFAC, CHICKFACR, 
  CHICKCAP, HORSEFAC, SHEEPFAC, CAPITAL, LABOR, LABOR2, POWER, DIESEL, NITROGEN, PHOSPHORUS,
  POTASSIUM, PESTICIDES, HERBICIDES, GLYFOSAT, FUNGICIDES, INSECTICID, PLASTIC, OTHRVARCST, SOJA,
  BETFOR, HP-MASSA, PROTFEED, OTHERFEED, ENERGYUSE, N-PROD, P-PROD, N-LEAKAGE, P-LEAKAGE,
  CO2, CH4, N2O, CO2EQ, NH3, YIELDRIRE1, YIELDRIRE2, YIELDRIRE3, P-COST, GRAINSEED, OILGRSEED,
  PEASSEED, POTATOSEED, SUGARBSEED, VEGETSEED, INCONVCOV, INCONVCAT, INCONVLAT, INCONVECOV,
  INCONVECAT, INCONVELAT, MISCCOST, DPTRANC, SUGARQUOTA, MINFOR, ACRMANURE, 
  ECON, ECOP, ECOK, ACRECO, ACRECON, 
  MAXWHEAT, MAXWWHEAT, MAXWRAY, MAXOILG, MAXWOILG, MAXPEAS, MAXPOTATO, MAXPOTACR,
  MAXSUGAR, MINNEWFOR, MAXCOVER, MAXCATCH, MAXLATE, MAXFOR, MINGRAIN, MAXSALIX, MINLAY,
  MAXLAY, MAXEWHEAT, MAXEWWHEAT, MAXEWRAY, MAXEOILG, MAXEWOILG, MAXEPEAS, MAXEPOTATO, MAXESUGAR,
  MINENEWFOR, MAXECOVER, MAXECATCH, MAXELATE, MINELAY, MAXELAY, MAXMANURE, MINSILAGE, MAXCRTOPST,
  LVSTKBAL1, LVSTKBAL2, MAXECAT, MEDCOW, MEBEEFCATT, MESHEEP, MECOPIG, MEPOULTRY, MINEACR,
  MAXREIND, MAXWILDM, MAXFISH, MAXFRUIT, MAXVEGET, MAXWBERRY/;
 
SET IN(I)  National inputs
 /CAPITAL, LABOR2, POWER, DIESEL, PESTICIDES, HERBICIDES, GLYFOSAT, FUNGICIDES, INSECTICID,
  PLASTIC, OTHRVARCST, OTHERFEED, CO2, CH4, N2O, CO2EQ, NH3, YIELDRIRE1, YIELDRIRE2, YIELDRIRE3,
  P-COST, MISCCOST, DPTRANC/;

SET IR(I)  Regional inputs
 /PCAPKMILK, PCAPCHEESE, PCAPBUTTER, PCAPDRYMLK, PCAPBEEF, PCAPPORK, PCAPPLTRY, PCAPMILL, PCAPFEED,
  PCAPPOTS, LABOR, NITROGEN, PHOSPHORUS, POTASSIUM, SOJA,
  BETFOR, HP-MASSA, PROTFEED, GRAINSEED, OILGRSEED, PEASSEED, POTATOSEED, SUGARBSEED, VEGETSEED,
  INCONVCOV, INCONVCAT, INCONVLAT, INCONVECOV, INCONVECAT, INCONVELAT,
  LVSTKBAL1, LVSTKBAL2, MEDCOW, MEBEEFCATT, MESHEEP, MECOPIG, MEPOULTRY, MINEACR,
  MAXREIND, MAXWILDM, MAXFISH, MAXFRUIT, MAXVEGET, MAXWBERRY/;

SET VARI(I)  Variable inputs
 /LABOR, LABOR2, POWER, DIESEL, NITROGEN, PHOSPHORUS, POTASSIUM, PESTICIDES, HERBICIDES, GLYFOSAT,
  FUNGICIDES, INSECTICID, PLASTIC, SOJA, BETFOR, HP-MASSA, PROTFEED, GRAINSEED, OILGRSEED,
  PEASSEED, POTATOSEED, SUGARBSEED, VEGETSEED,
  INCONVCOV, INCONVCAT, INCONVLAT, INCONVECOV, INCONVECAT, INCONVELAT/;
 
SET RIR(R,IR)  Regional inputs mapped to regions;
* Map all regional inputs to all regions, then exclude specific combinations which are not needed
  RIR(R,IR) = YES;
  RIR('R1','INCONVCOV')  = NO;
  RIR('R1','INCONVCAT')  = NO;
  RIR('R1','INCONVLAT')  = NO;
  RIR('R1','INCONVECOV') = NO;
  RIR('R1','INCONVECAT') = NO;
  RIR('R1','INCONVELAT') = NO;
*  RIR('R2','INCONVCOV')  = NO;
  RIR('R2','INCONVCAT')  = NO;
  RIR('R2','INCONVLAT')  = NO;
*  RIR('R2','INCONVECOV') = NO;
  RIR('R2','INCONVECAT') = NO;
  RIR('R2','INCONVELAT') = NO;

SET IS(I)  Subregional inputs
  /CROPLAND, PRMPAST, PRMPASTB, PRMPASTT, PRMPASTN, PRMPASTH, PRMPASTHB, PRMPASTHT, PRMPASTHN,
   PRMALV, PRMFOR, PRMMOS, PRMLOW, PRMCHAL, PRMMEAD, PRMPASTUP, PRMPASTHUP, 
   POTPAST, POTPASTT, POTPASTN, POTALV, POTFOR, POTMOS, POTLOW, POTCHAL, POTMEAD, ORGCROPL,
   ORGPASTR, ACRCOST, ACRCOSTP, ACRCOSTPB, ACRCOSTPT, ACRCOSTPN, ACRCOSTPH, ACRCOSTPHB, ACRCOSTPHT,
   ACRCOSTPHN, ACRCOSTALV, ACRCOSTFOR, ACRCOSTMOS, ACRCOSTLOW, ACRCOSTCHA, ACRCOSTMEA, 
   DAIRYFAC, DAIRYFACR, BEEFCFAC, BEEFCFACR, BULLFAC, BULLFACR, SOWFAC, SOWFACR, SWINEFAC,
   SWINEFACR, PLTRYFAC, PLTRYFACR, PLTRYCAP, CHICKFAC, CHICKFACR, CHICKCAP, HORSEFAC, SHEEPFAC,
   ECON, ECOP, ECOK, ACRECO, ACRECON, ENERGYUSE, N-PROD, P-PROD, N-LEAKAGE, P-LEAKAGE, 
   SUGARQUOTA, MINFOR, ACRMANURE, MAXWHEAT, MAXWWHEAT,
   MAXWRAY, MAXOILG, MAXWOILG, MAXPEAS, MAXPOTATO, MAXPOTACR, MAXSUGAR, MINNEWFOR, MAXCOVER,
   MAXCATCH, MAXLATE, MAXFOR, MINGRAIN, MAXSALIX, MINLAY, MAXLAY, 
   MAXEWHEAT, MAXEWWHEAT, MAXEWRAY, MAXEOILG, MAXEWOILG, MAXEPEAS, MAXEPOTATO, MAXESUGAR,
   MINENEWFOR, MAXECOVER, MAXECATCH, MAXELATE, MINELAY, MAXELAY, 
   MAXMANURE, MINSILAGE, MAXCRTOPST, MAXECAT/;
 
SET FIXIS(IS)  Fixed subregional inputs
  /DAIRYFAC, BEEFCFAC, BULLFAC, SOWFAC, SWINEFAC, PLTRYFAC, CHICKFAC, SHEEPFAC, 
   SUGARQUOTA, MAXPOTACR, MAXSALIX/;
   
SET FIXIS2(IS)  Partly fixed subregional inputs object for investments
  /DAIRYFACR, BEEFCFACR, BULLFACR, SOWFACR, SWINEFACR, PLTRYFACR, CHICKFACR/;

SET PRODRES(IS) Technical biological and policy restrictions on production
  /ACRMANURE, MAXWHEAT, MAXWWHEAT, MAXWRAY, MAXOILG, MAXWOILG, 
   MAXPEAS, MAXPOTATO, MAXPOTACR, MAXSUGAR, MINNEWFOR, MAXCOVER, MAXCATCH, MAXLATE, MAXFOR,
   MINGRAIN, MINLAY, MAXLAY,  
   MAXEWHEAT, MAXEWWHEAT, MAXEWRAY, MAXEOILG, MAXEWOILG, MAXEPEAS, MAXEPOTATO, MAXESUGAR,
   MINENEWFOR, MAXECOVER, MAXECATCH, MAXELATE, MINELAY, MAXELAY, 
   MAXSALIX, MAXMANURE, MINSILAGE, MAXECAT/;

SET RSRIS(R,SR,IS)  Subregional inputs mapped to regions and subregions;
* Map all subregional inputs to all region/subregion combinations, then exclude specific
* combinations which are not needed
  RSRIS(R,SR,IS) $RSR(R,SR) = YES;
  RSRIS(R,SR1TO12,'MAXCATCH') = NO;
  RSRIS(R,SR1TO12,'MAXLATE')  = NO;
  RSRIS(R,SR1TO12,'MAXECATCH')= NO;
  RSRIS(R,SR1TO12,'MAXELATE') = NO;
 
SET P(IP)  Products
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
  ES1*ES6, FARMSUB, NATSUB, COMPSUB, COMPSUBL, COMPSUBF, 
  BIODIVSUBL, BIODIVSUBH, BIODIVSUB, BIODIVSUB2, BIODIVSUB3, BIODIVSUBA, BIODIVSUBF, BIODIVSUBM,
  BIODIVSUBG, BIODIVSUBC, BIODIVSUBS, MINSALIX, DPTRANR/;
 
SET SUPPORT(P) Subsidies
 /ECOSUB, GACRSUB, FORSUB, CATTLESUB, SOWHLTSUB, ES1*ES6, FARMSUB, NATSUB,
  COMP4SUB, COMPSUB, COMPSUBL, COMPSUBF, BIODIVSUB, BIODIVSUB2, BIODIVSUB3, BIODIVSUBA,
  BIODIVSUBF, BIODIVSUBM, BIODIVSUBG, BIODIVSUBC, BIODIVSUBS/;
  
SET FEEDP(P)  Products for feed
 /FEEDGRAIN, GSILAGE, MSILAGE, FPEAS, PPEAS, 
  EPEAS, ESILAGE, ESILAGEHQ, EGRASSPAST, EGRASSPASF, 
  RAPEMEAL, RAPSKAKA, SILAGE, SILAGEHQ, HAY, GRASSPASTR, GRASSPASTF, USEPASTR/;

SET PN(P)  National products
 /ENERBGR, ENERCGR, ENEROILG, MINPASTN, CBONDING, MISCRCPT, MINKONVM, ECOSUB, GACRSUB, FORSUB,
  CATTLESUB, SOWHLTSUB, ES1*ES6, FARMSUB, NATSUB, BIODIVSUB, BIODIVSUB2, BIODIVSUB3, BIODIVSUBA,
  BIODIVSUBF, BIODIVSUBM, BIODIVSUBG, BIODIVSUBC, BIODIVSUBS, DPTRANR/;

SET SUPPORTN(PN) National subsidies
 /ECOSUB, GACRSUB, FORSUB, CATTLESUB, SOWHLTSUB, ES1*ES6, FARMSUB, NATSUB,
  BIODIVSUB, BIODIVSUB2, BIODIVSUB3, BIODIVSUBA, BIODIVSUBF, BIODIVSUBM,
  BIODIVSUBG, BIODIVSUBC, BIODIVSUBS/;
 
SET PR(P)  Regional products
 /BREADGRAIN, COARSGRAIN, FLOUR, FEEDGRAIN, PEAS, FPEAS, PPEAS, OILGRAIN, RAPEOIL, RAPEMEAL,
  RAPSKAKA, POTATOES, SUGARBEET, WHITESUGAR, MILK,
  DCALFM, DCALFF, PIGLETS, ECOMPMAN, SLGHBEEF, SLGHPORK, SLGHPLTRY, SLGHSHEEP, EGG, RIDING,
  SKIMMILK, MILKFAT, KMILK, CHEESE, BUTTER, CREAM, DRYMILK, DRYMILK2, BEEF, PORK, PLTRYMEAT,
  WILDMEAT, FISH, FRUIT, VEGETAB, WBERRY,
  EPEAS, EGRAIN, ERAPE, ESUGARB, EPOTATOES, EMILK, EBEEF, EPORK, ESHEEPM, EEGG,
  ENERGY, PROTEIN, PROTEINA, FAT, CARBOH,BREADGRC, COARSGRC, FLOURC, RAPEOILC, POTATOESC,
  SUGARC, OTHRCROPC, ICRPRC, SHEEPC, EGGC, KMILKC, CHEESEC, BUTTERC, CREAMC, DRYMILKC,
  BEEFC, PORKC, PLTRYMEATC, WILDMEATC, FISHC, FRUITC, VEGETABC, WBERRYC, LAYLAND/;
  
SET FOODS(PR)  Regional food products
 /BREADGRC, COARSGRC, FLOURC, RAPEOILC, POTATOESC, SUGARC,
  OTHRCROPC, ICRPRC, SHEEPC, EGGC, KMILKC, CHEESEC, BUTTERC, CREAMC, DRYMILKC, BEEFC, PORKC,
  PLTRYMEATC, WILDMEATC, FISHC, FRUITC, VEGETABC, WBERRYC,
  EPEAS, EGRAIN, ERAPE, ESUGARB, EPOTATOES, EMILK, EBEEF, EPORK, ESHEEPM, EEGG/;
  
SET ECOPROD(P) Ecological products
 /EPEAS, EGRAIN, ERAPE, ESUGARB, EPOTATOES, EMILK, EBEEF, EPORK, ESHEEPM, EEGG,
  ESILAGE, ESILAGEHQ, EGRASSPAST, EGRASSPASF, EDCALFM, EDCALFF, EDHEIFER, EPIGLETS, EGILTS/;

SET RPR(R,PR)  Regional products mapped to regions;
* Include all regional products in all regions, then identify excluded products by region
  RPR(R,PR) = YES;
  RPR('R1','OILGRAIN') = NO;
  RPR('R2','OILGRAIN') = NO;
  RPR('R1','ERAPE') = NO;
  RPR('R2','ERAPE') = NO;
  RPR('R3','ERAPE') = NO;
  RPR('R1','SUGARBEET') = NO;
  RPR('R2','SUGARBEET') = NO;
*  RPR('R3','SUGARBEET') = NO;
*  RPR('R4','SUGARBEET') = NO;
 
SET PS(P) Subregional products
 /GSILAGE, MSILAGE, SILAGE, SILAGEHQ, HAY, GRASSPASTR, GRASSPASTF, USEPASTR, OTHRCROPPR, SALIXMJ,
  ICRPR, UNDEFUSE, DHEIFER, GILTS, MINSHEEP, MINLFOR, MINDCOW, MINBCOW, MINCACR, MINPAST,
  ESILAGE, ESILAGEHQ, EGRASSPAST, EGRASSPASF, EDCALFM, EDCALFF, EDHEIFER, EPIGLETS, EGILTS,
  COMP4SUB, COMPSUB, COMPSUBL, COMPSUBF, BIODIVSUBL, BIODIVSUBH, MINSALIX/;

SET SUPPORTS(PS) Subregional subsidies
 /COMP4SUB, COMPSUB, COMPSUBL, COMPSUBF/;
 
SET RSRPS(R,SR,PS)  Subregional products mapped to regions and subregions;
* Map all subregional products to all region/subregion combinations, then exclude specific

* combinations which are not needed
  RSRPS(R,SR,PS) $RSR(R,SR) = YES;
 
SET PEX(P)  Exported products
 /BREADGRAIN, COARSGRAIN, OILGRAIN, RAPEOIL, POTATOES, WHITESUGAR, CHEESE, BUTTER, DRYMILK, DRYMILK2,
  BEEF, PORK, PLTRYMEAT, SLGHSHEEP, EGG/;
 
SET PIM(P)  Imported products
 /BREADGRAIN, COARSGRAIN, PEAS, OILGRAIN, POTATOES, WHITESUGAR,
  CHEESE, BUTTER, DRYMILK, DRYMILK2, BEEF, PORK, PLTRYMEAT, SLGHSHEEP, EGG,
  WILDMEAT, FISH, FRUIT, VEGETAB, WBERRY, EGRAIN, EPEAS/;
 
SET PREX(PR)  Exported regional products;
  PREX(PR) = NO;
  PREX(PR) = YES $PEX(PR);

SET RPREX(R,PR)  Exported regional products mapped to regions;
* Include all exported products which occur in each region, then identify excluded products
* by region
  RPREX(R,PR) = NO;
  RPREX(R,PR) = RPR(R,PR) $PREX(PR);
* NO EXPORTS FROM REGIONS 1 TO 3
  RPREX('R1',PR) = NO;
  RPREX('R2',PR) = NO;
  RPREX('R3',PR) = NO;
 
SET PRIM(PR)  Imported regional products;
  PRIM(PR) = NO;
  PRIM(PR) = YES $PIM(PR);
 
SET RPRIM(R,PR)  Imported regional products mapped to regions;

* Include all imported products which occur in each region, then identify excluded products
* by region
  RPRIM(R,PR) = NO;
  RPRIM(R,PR) = RPR(R,PR) $PRIM(PR);

* NO IMPORTS TO REGIONS 1 TO 3
  RPRIM('R1',PR) = NO;
  RPRIM('R2',PR) = NO;
  RPRIM('R3',PR) = NO;


SET AS  Crop and livestock production activities
*---------------------------------------------------------------------------------------------------
* Activity..             Description................................................................

*---------------------------------------------------------------------------------------------------
* Traditional production
 /W-WHEAT                Winter wheat: 1000 ha
  W-RAY                  Winter ray: 1000 ha
  W-BARLEY               Winter barley: 1000 ha
  BARLEY                 Barley: 1000 ha
  OATS                   Oats: 1000 ha
  GRAINSIL               Grain used as silage: 1000 ha
  MAJSSIL                Majs used as silage: 1000 ha
  FEEDPEAS               Peas used as feed: 1000 ha
  FEEDPEASH              Peas used as feed on land with high quality: 1000 ha
  W-RAPE                 Winter rape seed: 1000 ha
  S-RAPE                 Spring rape seed: 1000 ha
  POTATO                 Potatoes: 1000 ha
  SUGAR                  Sugar-beets: 1000 ha
  FORAGE1                Intensive forage in three year rotation: 1000 ha
  FORAGE2                Intensive forage and pasture in three year rotation: 1000 ha
  FORAGE3                Forage in eight year rotation: 1000 ha
  FORAGE4                Extensive forage : 1000 ha
  PASTURE1               Pasture at crop land: 1000 ha
  PASTURE2               Pasture at crop land: 1000 ha
  FORHIGH                Forage on high quality land: 1000 ha
  NEWFOR                 New forage seeded separately: 1000 ha
  MAKEHAY                Change from silage to hay with additional costs: 1000 ton ts
  SALIX                  Salix: 1000 ha
  OTHERCROPS             Other crops: 1000 ha
  COVERCROP              Cover crop: 1000 ha
  CATCHCROP              Catch crop: 1000 ha
  SPRINGTILL             Tilling in spring: 1000 ha
  LAY                    Lay land in program: 1000 ha
  LONGLAY                Permanent lay land in program: 1000 ha
  USEHQLAND              Use high quality land: 1000 ha
  DCOW1*DCOW4            Dairy production: 1000 cows
  HEIFER                 Dairy heifers fed to cows (25 month): 1000 hd
  DAIRYBULL1             Dairy bulls fed for beef 18 month (ungtjur): 1000 hd
  DAIRYBULL2             Dairy bulls fed for beef 25 month (stut): 1000 hd
  SLGHHEIFER             Heifers fed for beef (25 month): 1000 hd
  BEEFCATTLE             Beef cattle production: 1000 cows + 220 heifers + 660 bulls
  BEEFCATTL2             Beef cattle production: 1000 cows + 220 heifers + 660 bullocks
  SHEEP                  Sheep production: 1000 ewes + 1600 lamb
  SOW1                   Sows for production of piglets: 1000 sows + 40 boars
  GILT                   Gilt for sow production: 1000 hd
  SLGHSWINE1             Slaughter swine: 1000 hd
  POULTRY                Poultry production for egg: Mil hd
  CHICKEN                Poultry production for meat: Mil m2
* Ecological production
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
  EFORAGE4               Extensive forage : 1000 ha
  EPASTURE1              Pasture at crop land: 1000 ha
  EPASTURE2              Pasture at crop land: 1000 ha
  EFORHIGH               Forage on high quality land: 1000 ha
  ENEWFOR                New forage seeded separately: 1000 ha
  EOTHRCROPS             Other crops: 1000 ha
  ECOVERCROP             Cover crop: 1000 ha
  ECATCHCROP             Catch crop: 1000 ha
  ESPRINGTIL             Tilling in spring: 1000 ha
  ENFIX                  Nitrogen fixation: 1000 ha
  ELAY                   Lay land in program: 1000 ha
  USEHQLANDE             Use high quality land: 1000 ha
  EDCOW1*EDCOW3          Dairy production: 1000 cows
  EHEIFER                Dairy heifers fed to cows (25 month): 1000 hd
  EDBULL1                Dairy bulls fed for beef 18 month (ungtjur): 1000 hd
  EDBULL2                Dairy bulls fed for beef 25 month (stut): 1000 hd
  ESLGHHEIF              Heifers fed for beef (25 month): 1000 hd
  EBEEFCATT              Beef cattle production: 1000 cows + 200 heifers + 600 bulls
  EBEEFCAT2              Beef cattle production: 1000 cows + 200 heifers + 600 bullocks
  ESHEEP                 Sheep production: 1000 ewes + 1600 lamb
*  ESOW1                  Sows for production of piglets: 1000 sows + 40 boars
*  EGILT                  Gilt for sow production: 1000 hd
*  ESLGHSWINE             Slaughter swine: 1000 hd
  ECOPIG                 Ecological pigs: 1000 sows inkl slghswine
  EPOULTRY               Poultry production for meat: Mil hd
  USEMANURE              Use conventional manure
  COMPMAN                Compress manure: 1000 ton
  COMPEMAN               Compress ecologic manure: 1000 ton
  UCOMPMAN               Use compressed manure: 1000 ton
  CONVACR                Convert crop land to ecological: 1000 ha
* Common activities
  SPAREFOR               Spare forage for risk reduction: 1000 ha
  SPARESIL               Spare silage for risk reduction: 1000 ton
  FGFORSIL               Use feedgrain instead of silage: 1000 ton
  GSFORSIL               Use grain silage instead of silage: 1000 ton
  MSFORSIL               Use majs silage instead of silage: 1000 ton
  ICR                    Industry cops: 1000 ha
  NOUSE                  Acreage with no known use: 1000 ha
  PPASTR                 Permanent pasture use: 1000 ha
  PPASTRB                Part of pasture with basic support: 1000 ha
  PPASTRT                Permanent top supported pasture use: 1000 ha
  PPASTRN                Permanent N2000 supported pasture use: 1000 ha
  PPASTRH                Permanent pasture with high production: 1000 ha
  PPASTRHB               Part of high production pasture with basic support: 1000 ha
  PPASTRHT               Permanent top supported pasture with high production: 1000 ha
  PPASTRHN               Permanent N2000 supported pasture with high production: 1000 ha
  PPASTRALV              Permanent pasture on Alvaret: 1000 ha
  PPASTRFOR              Permanent forest pasture: 1000 ha
  PPASTRMOS              Permanent pasture mosaik: 1000 ha
  PPASTRLOW              Permanent pasture low production (grasfattig): 1000 ha
  PPASTRCHAL             Permanent chalet pasture (fabod): 1000 ha
  PPASTRMEAD             Permanent hay meadow (slatterang): 1000 ha
  SPAPASTR               Spare pasture for risk reduction: 1000 ha
  SPAPASTRB              Spare basic supported pasture for risk reduction: 1000 ha
  SPAPASTRT              Spare top supported pasture for risk reduction: 1000 ha
  SPAPASTRH              Spare permanent pasture with high production: 1000 ha
  SPAPASTRHB             Spare basic supported permanent pasture with high production: 1000 ha
  SPAPASTRHT             Spare top supported permanent pasture with high production: 1000 ha
  UPGRPAST               Upgrade pasture with low production to top support: 1000 ha
  UPGRPASTH              Upgrade pasture with high production to top support: 1000 ha
  CROPTOPAST             Transfere cropland to pasture with high production basic support: 1000 ha
  USEORGCL               Use organic crop land: 1000 ha
  USEORGPL               Use organic psture land: 1000 ha
  LVSTKIN                Incoming livestock for pasture: 1000 ton
  LVSTKOUT               Outgoing livestock for pasture: 1000 ton
  HORSES                 Horses for riding etc: 1000 hd
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
  RSILSUB                Receive silage subsidy
  RCOMPSUB               Receive compensation subsidy
  LESSDCOW               Reduced number of dairy cows: 1000 hd
  LESSBCOW               Reduced number of beef cows: 1000 hd
  LESSCALF               Early slsughter of young cattle: 1000 hd
  LESSSOW                Reduced number of sows: 1000 hd
  LESSSWINE              Reduced number of slaughter swine: 1000 hd /;
*------------------------------------------------------------------------------------------------
* Notes: hd = "head" = number of animals


SETS
  CROPS(AS)        /W-WHEAT, W-RAY, W-BARLEY, BARLEY, OATS, GRAINSIL, MAJSSIL, FEEDPEAS, FEEDPEASH,
                    W-RAPE, S-RAPE, POTATO, SUGAR,FORAGE1*FORAGE4, PASTURE1, PASTURE2, NEWFOR, SALIX,
                    OTHERCROPS, COVERCROP, CATCHCROP, SPRINGTILL, LAY, LONGLAY,
                    EW-WHEAT, EW-RAY, EBARLEY, EOATS, EFEEDPEAS, EW-RAPE, ES-RAPE, EPOTATO, ESUGAR,
                    EFORAGE1*EFORAGE4, EPASTURE1, EPASTURE2, ENEWFOR, EOTHRCROPS, ECOVERCROP, 
                    ECATCHCROP, ESPRINGTIL, ELAY, ENFIX, SPAREFOR, ICR, NOUSE/
  CROPS2(AS)       /W-WHEAT, W-RAY, W-BARLEY, BARLEY, OATS, GRAINSIL, MAJSSIL, FEEDPEAS, FEEDPEASH,
                    W-RAPE, S-RAPE, POTATO, SUGAR,FORAGE1*FORAGE4, PASTURE1, PASTURE2, NEWFOR, SALIX,
                    OTHERCROPS, COVERCROP, CATCHCROP, SPRINGTILL, LAY, LONGLAY,
                    EW-WHEAT, EW-RAY, EBARLEY, EOATS, EFEEDPEAS, EW-RAPE, ES-RAPE, EPOTATO, ESUGAR,
                    EFORAGE1*EFORAGE4, EPASTURE1, EPASTURE2, ENEWFOR, EOTHRCROPS, ECOVERCROP,
                    ECATCHCROP, ESPRINGTIL, ELAY, ENFIX, SPAREFOR, ICR, NOUSE,
                    PPASTR, PPASTRB, PPASTRT, PPASTRN, PPASTRH, PPASTRHB, PPASTRHT, PPASTRHN,
                    PPASTRALV, PPASTRFOR, PPASTRMOS, PPASTRLOW, PPASTRCHAL, PPASTRMEAD,
                    SPAPASTR, SPAPASTRB, SPAPASTRT, SPAPASTRH, SPAPASTRHB, SPAPASTRHT/
 CROPS3(AS)        /W-WHEAT, W-RAY, W-BARLEY, BARLEY, OATS, W-RAPE, S-RAPE, POTATO, SUGAR/
 CROPS4(AS)        /W-WHEAT, W-RAY, W-BARLEY, BARLEY, OATS, GRAINSIL, MAJSSIL, FEEDPEAS, FEEDPEASH,
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
  SPRINGCROP(AS)   /BARLEY, OATS, GRAINSIL, MAJSSIL, FEEDPEAS, FEEDPEASH,
                    S-RAPE, POTATO, SUGAR, EBARLEY, EOATS, EFEEDPEAS, ES-RAPE, EPOTATO, ESUGAR/
  WINTERCROP(AS)   /W-WHEAT, W-RAY, W-BARLEY, W-RAPE, EW-WHEAT, EW-RAY, EW-RAPE/
  LIVESTOCK(AS)    /DCOW1*DCOW4, HEIFER, DAIRYBULL1*DAIRYBULL2, SLGHHEIFER, BEEFCATTLE, BEEFCATTL2,
                    SHEEP, SOW1, GILT, SLGHSWINE1, POULTRY, CHICKEN,
    EDCOW1*EDCOW3, EHEIFER, EDBULL1*EDBULL2, ESLGHHEIF, EBEEFCATT, EBEEFCAT2, ESHEEP, ECOPIG, EPOULTRY,
                    HORSES/
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
  
SET RSRAS(R,SR,AS)  Subreg crop and livestock prod activities mapped to regions and subreg;
* Include all activities in all region/subregion combinations, then identify excluded activities
  RSRAS(R,SR,AS) = NO;
  RSRAS(R,SR,AS) = YES $RSR(R,SR);
  RSRAS(R,SR,'GRAINSIL') = NO;
  RSRAS(R,SR,'MAJSSIL') = NO;
  RSRAS(R,SR1TO4a,'W-WHEAT')  = NO;
  RSRAS(R,SR1TO4a,'W-RAY')   = NO;
  RSRAS(R,SR1TO7b,'W-BARLEY')= NO;
  RSRAS(R,SR01,'OATS')     = NO;
  RSRAS(R,SR,'MAJSSIL')     = NO;
  RSRAS(R,SR0gmb,'MAJSSIL')$RSR(R,SR0gmb)  = YES;
  RSRAS(R,SR0gss,'MAJSSIL')$RSR(R,SR0gss)  = YES;
  RSRAS(R,SR1TO4b,'W-RAPE') = NO;
  RSRAS(R,SR1TO5,'S-RAPE') = NO;
  RSRAS(R,SR,'SUGAR')       = NO;
  RSRAS(R,SR0gsk,'SUGAR')$RSR(R,SR0gsk) = YES;
  RSRAS(R,SR0gmb,'SUGAR')$RSR(R,SR0gmb) = YES;
  RSRAS(R,SR0gss,'SUGAR')$RSR(R,SR0gss) = YES;
  RSRAS(R,SR1TO7b,'SALIX')    = NO;
  RSRAS(R,SR1TO12,'CATCHCROP')    = NO;
  RSRAS(R,SR1TO12,'SPRINGTILL')   = NO;
  RSRAS(R,SR1TO4a,'EW-WHEAT')  = NO;
  RSRAS(R,SR1TO4a,'EW-RAY')   = NO;
  RSRAS(R,SR01,'EOATS')     = NO;
  RSRAS(R,SR1TO4b,'EW-RAPE') = NO;
  RSRAS(R,SR1TO5,'ES-RAPE') = NO;
  RSRAS(R,SR,'ESUGAR')       = NO;
  RSRAS(R,SR0gsk,'ESUGAR')$RSR(R,SR0gsk) = YES;
  RSRAS(R,SR0gmb,'ESUGAR')$RSR(R,SR0gmb) = YES;
  RSRAS(R,SR0gss,'ESUGAR')$RSR(R,SR0gss) = YES;
  RSRAS(R,SR1TO12,'ECATCHCROP')    = NO;
  RSRAS(R,SR1TO12,'ESPRINGTIL')    = NO;
  RSRAS(R,SR1TO7a,'ECOPIG')   = NO;
  RSRAS(R,SR,'PPASTRALV') = NO;
  RSRAS(R,'SR042','PPASTRALV')$RSR(R,'SR042') = YES;
  RSRAS(R,'SR053','PPASTRALV')$RSR(R,'SR053') = YES;
  RSRAS(R,'SR060','PPASTRALV')$RSR(R,'SR060') = YES;
  RSRAS(R,'SR066','PPASTRALV')$RSR(R,'SR066') = YES;
  RSRAS(R,'SR078','PPASTRALV')$RSR(R,'SR078') = YES;
  RSRAS(R,SR,'PPASTRCHAL') = NO;
  RSRAS(R,SR1TO5,'PPASTRCHAL')$RSR(R,SR1TO5) = YES;
  RSRAS(R,'SR016','PPASTRCHAL')$RSR(R,'SR016') = YES;
  RSRAS(R,'SR047','PPASTRCHAL')$RSR(R,'SR047') = YES;    
  RSRAS(R,'SR054','PPASTRCHAL')$RSR(R,'SR054') = YES;
  
  
SET CR  Processing activities regional
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
*  P-DPTRANR      Dairy processing transfer receipt: Mil SEK
*  P-DPTRANC      Dairy processing transfer cost: Mil SEK
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
 
 
SET RCR(R,CR)  Regional processing activities mapped to regions;
* Assign all regional processing activities to all regions, then identify excluded activities
* by region

  RCR(R,CR) = YES;
*  RCR(R,'P-BGTOEG')= NO;
*  RCR(R,'P-CGTOEG')= NO;
  RCR(R,'P-RMEAL') = NO;
  RCR(R,'P-RKAKA') = NO;
  RCR(R,'P-RME')   = NO;
  RCR(R,'P-SUGAR') = NO;  
*  RCR('R3','P-BGTOEG') = YES;
*  RCR('R3','P-CGTOEG') = YES;
  RCR('R5','P-RMEAL')  = YES;
  RCR('R5','P-RKAKA')  = YES;
  RCR('R5','P-RME')    = YES;
  RCR('R6','P-SUGAR')  = YES;
 
SET T(RS,RD)  Transportation patterns;
  T(RS,RD) = YES;
  T(RS,RS) = NO;
 
SET TRP(PR) Transported regional products
  / BREADGRAIN, COARSGRAIN, FEEDGRAIN, FLOUR, PEAS, OILGRAIN, RAPEMEAL, RAPEOIL, RAPSKAKA, POTATOES,
    SUGARBEET, WHITESUGAR, DCALFM, DCALFF, PIGLETS, ECOMPMAN, EPEAS, EGRAIN, ERAPE, ESUGARB, EMILK,
    EBEEF, EPORK, ESHEEPM, EEGG, SLGHBEEF, SLGHPORK, SLGHPLTRY, SLGHSHEEP, EGG, SKIMMILK, MILKFAT,
    KMILK, CHEESE, BUTTER, CREAM, DRYMILK, DRYMILK2, BEEF, PORK, PLTRYMEAT, WILDMEAT, FISH, FRUIT,
    VEGETAB, WBERRY/;

SET TRI(IR) Transported regional inputs
  / GRAINSEED, PEASSEED, POTATOSEED, BETFOR, HP-MASSA/;

SET TIP(RS,RD,IP)  Regional inputs and products mapped to transportation patterns;
* Include all inputs and products in both regions, then exclude specific products on specific
* routes
  TIP(RS,RD,IP) = NO;
  TIP(RS,RD,PR)$TRP(PR) = RPR(RS,PR)*RPR(RD,PR)*T(RS,RD);
  TIP(RS,RD,IR)$TRI(IR) = RIR(RS,IR)*RIR(RD,IR)*T(RS,RD);
 
SET SDP  Supply and demand parameters  /PBAR, QBAR, ELAS, MIN, MAX, INTERCEPT, SLOPE/;
 
* Assignments are made to the following sets based on the values of supply and demand parameters.
* These assignments occur after the corresponding parameter tables
SET INES(IN)       Elastic supply national inputs;
SET INFS(IN)       Fixed supply national inputs;
SET IRES(R,IR)     Elastic supply regional inputs mapped to regions;
SET IRFS(R,IR)     Fixed supply regional inputs mapped to regions;
SET ISES(R,SR,IS)  Elastic supply subregional inputs mapped to regions;
SET ISFS(R,SR,IS)  Fixed supply subregional inputs mapped to regions;


SET PNED(PN)       Elastic demand national products;
SET PNFD(PN)       Fixed demand national products;
SET PRED(R,PR)     Elastic demand regional products mapped to regions;
SET PRFD(R,PR)     Fixed demand regional products mapped to regions;
SET PSED(R,SR,PS)  Elastic demand subregional products mapped to regions;
SET PSFD(R,SR,PS)  Fixed demand subregional products mapped to regions;

SET TRD  Trade parameters  /WPRICE, TARIFF, SUBSIDY, MIN, MAX, ADJPRICE/;


$STITLE DATA DECLARATIONS AND ASSIGNMENTS
$ONTEXT
Overview of SASM data:
---------------------------------------------------------------------------------------------------
Item.............  Description....................................................................
---------------------------------------------------------------------------------------------------
EAS(R,SR,AS,IP)    Unit input and product coefficients for subregional crop and livestock
                   production activities; reg by subreg by prod act by input/product; subreg,
                   reg or natl inputs/products; positive implies net use and negative implies
                   net production

ECR(R,CR,IP)       Unit input and production coefficients for regional processing activities, reg
                   by proc act by input/product; reg or natl inputs/products; positive implies
                   net use and negative implies net production

BIN(IN,SDP)        National input supply parameters; input by parameter type;
                   values determine the elements of dynamic sets INES and INFS

BIR(R,IR,SDP)      Regional input supply parameters; reg by regional input by parameter type;
                   values determine the elements of dynamic sets IRES and IRFS

BIS(R,SR,IS,SDP)   Subregional input supply parameters; reg by subreg by subregional input by
                   parameter type; values determine the elements of dynamic sets ISES and ISFS

BPN(PN,SDP)        National product demand parameters; product by parameter type; values
                   determine the elements of dynamic sets PNED and PNFD

BPR(R,PR,SDP)      Regional product demand parameters; reg by product by parameter type; values
                   determine the elements of dynamic sets PRED and PRFD

BPS(R,SR,PS,SDP)   Subregional product demand parameters; reg by subreg by product by parameter
                   type; values determine the elements of dynamic sets PSED and PSFD

CT(RS,RD,IR)       Unit transportation cost; source reg by destination reg by input or product

DT(RS,RD)          Distance from source region to destination region; 1000 km

UT(IP)             Unit transportation cost per 1000 km by regional product

BXR(R,PR,TRD)      Export parameters for regional products; reg by product by parameter

BMR(R,PR,TRD)      Import parameters for regional products; reg by product by parameter

MS(R)              Milk subsidy in Mil SEK per 1000 ton output; by reg
---------------------------------------------------------------------------------------------------
$OFFTEXT 


TABLE PRODCOEFC(AS,IP,SR)  Unit input and product coef for subregional crop prod act	


* Yield in ton per hectare (Standard yield)
*				R1a	R2a	R2b	R3a	R4a	R4b	R5a	R5b	R5c	R5m
*				SR01	SR03	SR04a	SR04b	SR05	SR07a	SR07b	SR08	SR09	0ssk
				SR001	SR006	SR009	SR010	SR012	SR026	SR061	SR033	SR043	SR069
*----------------------------------------------------------------------------------------------------
W-WHEAT 	.BREADGRAIN				-4.538	-5.386	-5.990	-5.565	-6.118	-5.751	-6.669
W-RAY		.BREADGRAIN				-4.082	-4.846	-5.392	-5.010	-5.454	-5.152	-5.607
BARLEY		.COARSGRAIN	-2.410	-2.500	-2.600	-2.728	-3.140	-3.500	-3.801	-4.000	-4.200	-4.344
OATS		.COARSGRAIN	-2.052	-2.200	-2.300	-2.437	-3.105	-3.490	-3.780	-3.980	-4.180	-4.038
*GRAINSIL	.GSILAGE   	-3.507	-3.810	-3.830	-4.256	-5.138	-4.822	-5.652	-5.724	-6.666	-6.733
*MAJSSIL 	.MSILAGE   										-8.000
W-RAPE		.OILGRAIN					-3.357	-3.437	-3.403	-3.612	-3.524	-4.134
W-RAPE		.BREADGRAIN					-0.500	-0.500	-0.500	-0.500	-0.500	-0.500
S-RAPE		.OILGRAIN						-2.300	-2.428	-2.395	-2.412	-2.313
S-RAPE		.BREADGRAIN						-0.500	-0.500	-0.500	-0.500	-0.500
POTATO		.POTATOES	-18.43	-20.95	-24.81	-26.97	-28.79	-40.50	-36.97	-34.87	-36.35	-39.93
SUGAR		.SUGARBEET										-54.92
FORAGE1 	.SILAGE 	-5.283	-5.437	-5.576	-5.580	-5.591	-5.762	-6.251	-6.773	-7.059	-6.884
FORAGE2 	.SILAGE 	-4.597	-4.310	-4.542	-4.560	-4.128	-4.490	-3.998	-4.358	-4.375	-4.686
FORAGE2 	.GRASSPASTR	-0.686	-1.127	-1.034	-1.020	-1.463	-1.272	-2.253	-2.415	-2.684	-2.198
LAY		.COARSGRAIN	0.047	0.051	0.051	0.057	0.069	0.069	0.064	0.075	0.076	0.076
*SALIX          .SALIXMJ 							-26.40	-26.40	-30.80	-41.80
* Data from SJV. The bread grain part of rape is for crop rotation.
			
											
* Seed in ton per hectare											
*				R1a	R2a	R2b	R3a	R4a	R4b	R5a	R5b	R5c	R5m
*----------------------------------------------------------------------------------------------------
W-WHEAT 	.GRAINSEED				0.235	0.237	0.241	0.235	0.240	0.239	0.247
W-RAY		.GRAINSEED				0.199	0.197	0.194	0.211	0.212	0.206	0.223
BARLEY		.GRAINSEED	0.211	0.211	0.211	0.215	0.227	0.241	0.223	0.230	0.233	0.241
OATS		.GRAINSEED	0.217	0.217	0.217	0.221	0.232	0.241	0.235	0.238	0.238	0.247
*GRAINSIL	.GRAINSEED	0.175	0.175	0.175	0.178	0.191	0.185	0.193	0.189	0.199	0.199
* Data from SJV 

											
* Fertilizer in ton per hectare										
*				R1a	R2a	R2b	R3a	R4a	R4b	R5a	R5b	R5c	R5m
*----------------------------------------------------------------------------------------------------
W-WHEAT 	.NITROGEN				0.120	0.136	0.150	0.140	0.153	0.147	0.163
*W-WHEAT 	.PHOSPHORUS				0.017	0.020	0.022	0.021	0.023	0.022	0.025
*W-WHEAT 	.POTASSIUM				0.032	0.038	0.043	0.040	0.044	0.041	0.048
											
W-RAY		.NITROGEN				0.085	0.100	0.114	0.105	0.115	0.110	0.120
*W-RAY		.PHOSPHORUS				0.014	0.017	0.019	0.017	0.019	0.018	0.020
*W-RAY		.POTASSIUM				0.027	0.032	0.036	0.033	0.036	0.034	0.037
											
BARLEY		.NITROGEN	0.040	0.042	0.042	0.045	0.052	0.060	0.068	0.070	0.074	0.075
*BARLEY		.PHOSPHORUS	0.008	0.010	0.010	0.011	0.013	0.018	0.013	0.015	0.015	0.018
*BARLEY		.POTASSIUM	0.016	0.019	0.019	0.020	0.025	0.034	0.025	0.029	0.028	0.034
											
OATS		.NITROGEN	0.030	0.033	0.035	0.036	0.041	0.050	0.058	0.060	0.062	0.060
*OATS		.PHOSPHORUS	0.008	0.009	0.008	0.010	0.012	0.015	0.013	0.014	0.014	0.016
*OATS		.POTASSIUM	0.015	0.018	0.016	0.020	0.023	0.029	0.026	0.028	0.028	0.030
											
*GRAINSIL	.NITROGEN	0.050	0.053	0.053	0.058	0.068	0.065	0.074	0.075	0.086	0.086
*GRAINSIL	.PHOSPHORUS	0.008	0.009	0.009	0.010	0.012	0.011	0.013	0.013	0.015	0.016
*GRAINSIL	.POTASSIUM	0.016	0.017	0.017	0.019	0.023	0.021	0.025	0.025	0.030	0.030
											
*MAJSSIL 	.NITROGEN										0.150
*MAJSSIL 	.PHOSPHORUS										0.047
*MAJSSIL 	.POTASSIUM										0.170
											
W-RAPE		.NITROGEN					0.152	0.154	0.153	0.157	0.155	0.168
*W-RAPE		.PHOSPHORUS					0.019	0.020	0.020	0.021	0.020	0.024
*W-RAPE		.POTASSIUM					0.037	0.038	0.037	0.040	0.039	0.045
											
S-RAPE		.NITROGEN						0.116	0.118	0.118	0.118	0.116
*S-RAPE		.PHOSPHORUS						0.013	0.014	0.014	0.014	0.013
*S-RAPE		.POTASSIUM						0.025	0.027	0.026	0.026	0.025
											
POTATO		.NITROGEN	0.060	0.065	0.080	0.085	0.090	0.125	0.115	0.110	0.115	0.125
*POTATO		.PHOSPHORUS	0.039	0.044	0.052	0.057	0.060	0.085	0.078	0.073	0.076	0.084
*POTATO		.POTASSIUM	0.074	0.084	0.099	0.108	0.115	0.162	0.148	0.140	0.146	0.160

SUGAR		.NITROGEN										0.110
*SUGAR		.PHOSPHORUS										0.019
*SUGAR		.POTASSIUM										0.035
							
LAY		.NITROGEN	-0.050	-0.050	-0.050	-0.050	-0.050	-0.050	-0.050	-0.050	-0.050	-0.050
* Data from SJV 

											
* Other inputs											
*				R1a	R2a	R2b	R3a	R4a	R4b	R5a	R5b	R5c	R5m
*----------------------------------------------------------------------------------------------------
W-WHEAT 	.PESTICIDES				0.121	0.158	0.211	0.204	0.292	0.225	0.417
W-RAY		.PESTICIDES				0.090	0.536	0.564	0.389	0.486	0.479	0.498
BARLEY		.PESTICIDES	0.046	0.046	0.046	0.063	0.101	0.192	0.125	0.173	0.156	0.186
OATS		.PESTICIDES	0.090	0.090	0.090	0.139	0.139	0.140	0.133	0.175	0.143	0.216
*GRAINSIL	.PESTICIDES	0.127	0.127	0.127	0.127	0.127	0.112	0.155	0.119	0.126	0.234
*MAJSSIL 	.PESTICIDES										0.587
W-RAPE		.PESTICIDES					0.133	0.639	0.133	0.508	0.299	0.789
S-RAPE		.PESTICIDES						0.188	0.105	0.226	0.164	0.312
POTATO		.PESTICIDES	0.822	0.822	0.822	0.957	1.365	1.447	1.805	1.895	1.902	2.216
SUGAR		.PESTICIDES										2.264
*SALIX		.PESTICIDES							0.500	0.500	0.500	0.500
LAY		.PESTICIDES	0.269	0.269	0.269	0.269	0.269	0.269	0.270	0.305	0.284	0.466
* Data from SJV
									
*W-WHEAT 	.POWER     		0.017		0.016	0.014	0.015	0.014	0.014	0.012	0.010
*W-RAY		.POWER     					0.014	0.015	0.014	0.014	0.012	0.010
*BARLEY		.POWER     	0.017	0.017	0.016	0.016	0.014	0.015	0.014	0.014	0.012	0.010
*OATS		.POWER     	0.017	0.017	0.016	0.016	0.014	0.015	0.014	0.014	0.012	0.010
*GRAINSIL	.POWER     	0.017	0.017	0.016	0.016	0.014	0.015	0.014	0.014	0.012	0.010
*MAJSSIL 	.POWER     										0.008
*W-RAPE		.POWER     						0.015	0.014	0.014	0.012	0.010
*S-RAPE		.POWER    					0.014	0.015	0.014	0.014	0.012	0.010
*POTATO		.POWER		0.034	0.034	0.034	0.034	0.034	0.034	0.034	0.034	0.034	0.034
*SUGAR		.POWER     										0.015
*FORAGE1 	.POWER     	0.020	0.019	0.018	0.016	0.014	0.015	0.012	0.012	0.009	0.009
*FORAGE2 	.POWER     	0.020	0.019	0.018	0.016	0.014	0.015	0.012	0.012	0.009	0.009
*PASTURE1	.POWER     	0.007	0.006	0.005	0.005	0.004	0.004	0.003	0.003	0.002	0.002
*PASTURE2	.POWER		0.006	0.005	0.004	0.004	0.003	0.003	0.002	0.002	0.001	0.001
*PPASTR		.POWER		0.006	0.005	0.004	0.004	0.003	0.003	0.002	0.002	0.001	0.001	
*SALIX      	.POWER								0.010	0.010	0.010	0.010
*LAY		.POWER     	0.006	0.006	0.005	0.005	0.003	0.004	0.003	0.003	0.002	0.002
*LONGLAY  	.POWER     	0.002	0.002	0.002	0.002	0.001	0.0015	0.001	0.001	0.0005	0.0005
* Data from SJV
											
W-WHEAT 	.LABOR    				0.008	0.007	0.006	0.008	0.007	0.006	0.006
W-RAY		.LABOR    				0.008	0.007	0.006	0.008	0.007	0.006	0.006
BARLEY		.LABOR    	0.008	0.008	0.008	0.008	0.007	0.006	0.008	0.007	0.006	0.006
OATS		.LABOR    	0.008	0.008	0.008	0.008	0.007	0.006	0.008	0.007	0.006	0.006
*GRAINSIL	.LABOR    	0.022	0.022	0.022	0.022	0.018	0.020	0.017	0.017	0.013	0.011
*MAJSSIL 	.LABOR    										0.009
W-RAPE		.LABOR    					0.007	0.006	0.008	0.007	0.006	0.006
S-RAPE		.LABOR    						0.006	0.008	0.007	0.006	0.006
POTATO		.LABOR    	0.050	0.050	0.050	0.050	0.048	0.045	0.048	0.047	0.046	0.045
SUGAR		.LABOR    										0.013
FORAGE1 	.LABOR    	0.015	0.012	0.012	0.011	0.009	0.006	0.010	0.008	0.007	0.005
FORAGE2 	.LABOR    	0.015	0.012	0.012	0.011	0.009	0.006	0.010	0.008	0.007	0.005
PASTURE1	.LABOR    	0.008	0.007	0.007	0.006	0.005	0.003	0.005	0.004	0.004	0.003
PASTURE2	.LABOR    	0.007	0.006	0.006	0.005	0.004	0.002	0.004	0.003	0.003	0.002
PPASTR		.LABOR    	0.004	0.004	0.004	0.004	0.003	0.002	0.004	0.003	0.003	0.002
*SALIX 		.LABOR    							0.012	0.012	0.012	0.012
LAY		.LABOR    	0.006	0.006	0.005	0.005	0.004	0.003	0.004	0.004	0.003	0.003
LONGLAY  	.LABOR    	0.003	0.003	0.0025	0.0025	0.002	0.0015	0.002	0.002	0.0025	0.0025
* Data from LES, permpastr from SLU-Info

W-WHEAT 	.OTHRVARCST				0.971	1.142	1.263	1.175	1.290	1.214	1.404
W-RAY		.OTHRVARCST				0.877	1.030	1.139	1.060	1.153	1.090	1.184
BARLEY		.OTHRVARCST	0.536	0.617	0.632	0.662	0.797	1.073	0.791	0.917	0.907	1.070
OATS		.OTHRVARCST	0.509	0.605	0.533	0.664	0.765	0.935	0.839	0.902	0.902	0.978
*GRAINSIL	.OTHRVARCST	0.380	0.381	0.377	0.376	0.370	0.367	0.367	0.368	0.367	0.367
*MAJSSIL 	.OTHRVARCST										3.106
W-RAPE		.OTHRVARCST					0.606	0.606	0.604	0.616	0.611	0.643
S-RAPE		.OTHRVARCST						0.686	0.693	0.691	0.692	0.687
POTATO		.OTHRVARCST	2.993	2.993	2.984	3.054	3.133	3.207	3.130	3.122	3.096	3.121
SUGAR		.OTHRVARCST										2.915
FORAGE1 	.OTHRVARCST	0.962	0.961	0.937	0.940	0.920	0.877	0.927	0.903	0.892	0.876
FORAGE2 	.OTHRVARCST	0.962	0.961	0.937	0.940	0.920	0.877	0.927	0.903	0.892	0.876
PASTURE1	.OTHRVARCST	0.603	0.602	0.562	0.563	0.546	0.515	0.550	0.533	0.525	0.514
PASTURE2	.OTHRVARCST	0.315	0.315	0.315	0.315	0.315	0.315	0.315	0.315	0.315	0.315
PPASTR		.OTHRVARCST	0.945	0.945	0.945	0.945	0.945	0.945	0.945	0.945	0.945	0.945
*SALIX 		.OTHRVARCST 							2.923	2.923	3.161	3.757
LAY		.OTHRVARCST	0.140	0.140	0.140	0.140	0.140	0.140	0.140	0.140	0.140	0.140									
* Data from SJV
											
W-WHEAT 	.CAPITAL    				2.500	2.650	2.815	2.737	2.895	2.740	3.045
W-RAY		.CAPITAL    				2.246	2.608	2.722	2.612	2.732	2.610	2.735
BARLEY		.CAPITAL    	0.942	0.993	0.980	0.996	1.057	1.251	1.075	1.147	1.123	1.223
OATS		.CAPITAL    	0.948	1.010	0.943	1.036	1.066	1.161	1.131	1.161	1.136	1.203
*GRAINSIL	.CAPITAL    	0.514	0.526	0.529	0.645	0.670	0.643	0.684	0.688	0.726	0.727
*MAJSSIL 	.CAPITAL    										2.154
W-RAPE		.CAPITAL    					1.766	2.133	1.880	2.110	1.933	2.332
S-RAPE		.CAPITAL    						0.998	1.026	1.031	1.000	1.006
POTATO		.CAPITAL    	13.43	13.74	14.12	14.43	14.89	16.55	16.13	15.92	16.03	16.73
SUGAR		.CAPITAL    										3.610
FORAGE1 	.CAPITAL    	1.459	1.452	1.360	1.363	1.390	1.424	1.452	1.472	1.473	1.460
FORAGE2 	.CAPITAL    	1.459	1.452	1.360	1.363	1.390	1.424	1.452	1.472	1.473	1.460
*SALIX 		.CAPITAL 							4.000	4.000	4.000	4.000
LAY		.CAPITAL    	0.311	0.315	0.303	0.299	0.269	0.244	0.283	0.277	0.262	0.301
* Data from SJV
												
* Additional costs for hay instead of silage
*				R1a	R2a	R2b	R3a	R4a	R4b	R5a	R5b	R5c	R5m
*----------------------------------------------------------------------------------------------------
MAKEHAY  	.SILAGE 	1.000	1.000	1.000	1.000	1.000	1.000	1.000	1.000	1.000	1.000
MAKEHAY  	.HAY    	-1.19	-1.19	-1.19	-1.19	-1.19	-1.19	-1.19	-1.19	-1.19	-1.19
MAKEHAY  	.OTHRVARCST	0.200	0.200	0.200	0.200	0.200	0.200	0.200	0.200	0.200	0.200

* Environmental parameters											
*				R1a	R2a	R2b	R3a	R4a	R4b	R5a	R5b	R5c	R5m
*----------------------------------------------------------------------------------------------------
W-WHEAT  	.N-LEAKAGE	0.026	0.026	0.025	0.029	0.029	0.030	0.032	0.029	0.014	0.023
W-RAY     	.N-LEAKAGE	0.026	0.026	0.025	0.029	0.029	0.030	0.032	0.029	0.014	0.023
BARLEY  	.N-LEAKAGE	0.025	0.026	0.025	0.029	0.030	0.029	0.036	0.030	0.014	0.025
OATS	  	.N-LEAKAGE	0.025	0.026	0.025	0.029	0.030	0.029	0.036	0.030	0.014	0.025
W-RAPE	 	.N-LEAKAGE	0.026	0.026	0.025	0.029	0.029	0.035	0.031	0.028	0.011	0.024
S-RAPE	 	.N-LEAKAGE	0.025	0.026	0.023	0.026	0.027	0.027	0.031	0.030	0.014	0.023
POTATO  	.N-LEAKAGE	0.040	0.040	0.040	0.040	0.040	0.040	0.053	0.048	0.025	0.042
SUGAR	  	.N-LEAKAGE							0.030	0.030	0.030	0.030
FORAGE1 	.N-LEAKAGE	0.010	0.009	0.006	0.006	0.006	0.006	0.015	0.013	0.003	0.008
FORAGE2  	.N-LEAKAGE	0.010	0.009	0.006	0.006	0.006	0.006	0.015	0.013	0.003	0.008
PASTURE1	.N-LEAKAGE	0.010	0.009	0.006	0.006	0.006	0.006	0.015	0.013	0.003	0.008
PASTURE2  	.N-LEAKAGE	0.006	0.005	0.003	0.004	0.004	0.005	0.010	0.007	0.003	0.007
PPASTR		.N-LEAKAGE	0.003	0.001	0.001	0.002	0.002	0.004	0.004	0.001	0.003	0.006
LAY		.N-LEAKAGE	0.012	0.011	0.011	0.012	0.015	0.017	0.024	0.024	0.09	0.015
LONGLAY  	.N-LEAKAGE	0.010	0.009	0.006	0.006	0.006	0.006	0.015	0.013	0.003	0.008

W-WHEAT  	.P-LEAKAGE	0.88	0.88	1.10	0.99	0.86	0.75	0.62	0.47	0.55	0.28
W-RAY     	.P-LEAKAGE	0.88	0.88	1.10	0.99	0.86	0.75	0.62	0.47	0.55	0.28
BARLEY  	.P-LEAKAGE	0.86	0.88	1.10	1.18	0.93	0.83	0.74	0.54	0.61	0.31
OATS	  	.P-LEAKAGE	0.86	0.88	1.10	1.18	0.93	0.83	0.74	0.54	0.61	0.31
W-RAPE	 	.P-LEAKAGE	0.88	0.88	1.10	0.99	0.86	0.73	0.62	0.51	0.56	0.17
S-RAPE	 	.P-LEAKAGE	0.86	0.88	1.10	1.10	0.96	0.86	0.67	0.57	0.61	0.20
POTATO  	.P-LEAKAGE	1.01	1.01	1.01	1.01	1.01	1.01	0.99	0.74	0.77	0.40
SUGAR	  	.P-LEAKAGE							0.48	0.48	0.48	0.48
FORAGE1 	.P-LEAKAGE	0.39	0.49	0.45	0.52	0.54	0.53	0.44	0.38	0.46	0.22
FORAGE2  	.P-LEAKAGE	0.39	0.49	0.45	0.52	0.54	0.53	0.44	0.38	0.46	0.22
PASTURE1	.P-LEAKAGE	0.39	0.49	0.45	0.52	0.54	0.53	0.44	0.38	0.46	0.22
PASTURE2  	.P-LEAKAGE	0.39	0.49	0.45	0.52	0.54	0.53	0.44	0.38	0.46	0.22
PPASTR		.P-LEAKAGE	0.39	0.49	0.45	0.52	0.54	0.53	0.44	0.38	0.46	0.22
LAY		.P-LEAKAGE	0.48	0.52	0.71	0.76	0.68	0.66	0.52	0.44	0.51	0.21
LONGLAY  	.P-LEAKAGE	0.39	0.49	0.45	0.52	0.54	0.53	0.44	0.38	0.46	0.22


* Yield in ton per hectare (Standard yield)
*				R9ss	R9gns	R9gmb	R9gss
*				0ss	0gns	0gmb	0gss
+				SR074	SR076	SR078	SR080
*----------------------------------------------------------------------------------------------------
W-WHEAT 	.BREADGRAIN	-6.535	-7.208	-8.095	-9.116
W-RAY		.BREADGRAIN	-5.805	-6.530	-7.271	-7.965
BARLEY		.COARSGRAIN	-4.344	-4.922	-4.560	-5.807
OATS		.COARSGRAIN	-4.037	-4.572	-4.085	-5.277
*GRAINSIL	.GSILAGE   	-5.652	-5.724	-6.666	-6.733
*MAJSSIL 	.MSILAGE   				-8.000
W-RAPE		.OILGRAIN	-3.755	-3.500	-4.564	-4.748
W-RAPE		.BREADGRAIN	-0.500	-0.500	-0.500	-0.500
S-RAPE		.OILGRAIN	-2.535	-2.397	-2.629	-2.341
S-RAPE		.BREADGRAIN	-0.500	-0.500	-0.500	-0.500
POTATO		.POTATOES	-32.05	-42.81	-44.65	-47.79
SUGAR		.SUGARBEET			-66.14	-69.90
FORAGE1 	.SILAGE 	-7.496	-8.423	-8.573	-8.656
FORAGE2 	.SILAGE 	-4.732	-5.367	-5.167	-4.762
FORAGE2 	.GRASSPASTR	-2.773	-3.056	-3.406	-3.894
LAY		.COARSGRAIN	0.086	0.087	0.089	0.090
*SALIX          .SALIXMJ 	-26.40	-26.40	-30.80	-41.80
* Data from SJV. The bread grain part of rape is for crop rotation.
* Data for ray are adjusted in region 5a, 5b and 6s											
											
* Seed in ton per hectare											
*				R9ss	R9gns	R9gmb	R9gss
*----------------------------------------------------------------------------------------------------
W-WHEAT 	.GRAINSEED	0.241	0.241	0.247	0.247
W-RAY		.GRAINSEED	0.193	0.211	0.213	0.213
BARLEY		.GRAINSEED	0.241	0.235	0.247	0.247
OATS		.GRAINSEED	0.241	0.241	0.241	0.241
*GRAINSIL	.GRAINSEED	0.193	0.189	0.199	0.199
* Data from SJV

											
* Fertilizer in ton per hectare										
*				R9ss	R9gns	R9gmb	R9gss
*----------------------------------------------------------------------------------------------------
W-WHEAT 	.NITROGEN	0.160	0.175	0.190	0.210
*W-WHEAT 	.PHOSPHORUS	0.024	0.027	0.030	0.034
*W-WHEAT 	.POTASSIUM	0.047	0.051	0.058	0.065
											
W-RAY		.NITROGEN	0.120	0.133	0.130	0.140
*W-RAY		.PHOSPHORUS	0.020	0.023	0.025	0.028
*W-RAY		.POTASSIUM	0.039	0.043	0.048	0.053
											
BARLEY		.NITROGEN	0.075	0.090	0.073	0.095
*BARLEY		.PHOSPHORUS	0.017	0.018	0.018	0.021
*BARLEY		.POTASSIUM	0.032	0.035	0.035	0.040
											
OATS		.NITROGEN	0.060	0.070	0.070	0.076
*OATS		.PHOSPHORUS	0.018	0.020	0.020	0.023
*OATS		.POTASSIUM	0.034	0.038	0.038	0.043
											
*GRAINSIL	.NITROGEN	0.074	0.075	0.086	0.086
*GRAINSIL	.PHOSPHORUS	0.013	0.013	0.015	0.016
*GRAINSIL	.POTASSIUM	0.025	0.025	0.030	0.030
											
*MAJSSIL 	.NITROGEN				0.150
*MAJSSIL 	.PHOSPHORUS				0.047
*MAJSSIL 	.POTASSIUM				0.170
											
W-RAPE		.NITROGEN	0.160	0.155	0.180	0.185
*W-RAPE		.PHOSPHORUS	0.022	0.023	0.026	0.027
*W-RAPE		.POTASSIUM	0.041	0.044	0.050	0.052
											
S-RAPE		.NITROGEN	0.120	0.118	0.125	0.118
*S-RAPE		.PHOSPHORUS	0.015	0.014	0.015	0.013
*S-RAPE		.POTASSIUM	0.028	0.026	0.029	0.026
											
POTATO		.NITROGEN	0.100	0.130	0.140	0.150
*POTATO		.PHOSPHORUS	0.067	0.090	0.094	0.100
*POTATO		.POTASSIUM	0.128	0.172	0.179	0.192

SUGAR		.NITROGEN			0.110	0.110
*SUGAR		.PHOSPHORUS			0.020	0.021
*SUGAR		.POTASSIUM			0.038	0.039
													
LAY		.NITROGEN	-0.050	-0.050	-0.050	-0.050
* Data from SJV

											
* Other inputs											
*				R9ss	R9gns	R9gmb	R9gss
*----------------------------------------------------------------------------------------------------
W-WHEAT 	.PESTICIDES	0.188	0.226	0.417	0.623
W-RAY		.PESTICIDES	0.536	0.564	0.355	1.400
BARLEY		.PESTICIDES	0.140	0.135	0.216	0.240
OATS		.PESTICIDES	0.159	0.164	0.186	0.441
*GRAINSIL	.PESTICIDES	0.155	0.119	0.126	0.234
*MAJSSIL 	.PESTICIDES				0.587
W-RAPE		.PESTICIDES	0.639	0.639	0.790	0.769
S-RAPE		.PESTICIDES		0.188	0.312	0.315
POTATO		.PESTICIDES	1.422	2.019	2.122	2.544
SUGAR		.PESTICIDES			2.264	2.264
*SALIX		.PESTICIDES	0.500	0.500	0.500	0.500
LAY		.PESTICIDES	0.269	0.269	0.466	0.466
* Data from SJV
											
*W-WHEAT 	.POWER     	0.014	0.014	0.012	0.010
*W-RAY		.POWER     	0.014	0.014	0.012	0.010
*BARLEY		.POWER     	0.014	0.014	0.012	0.010
*OATS		.POWER     	0.014	0.014	0.012	0.010
*GRAINSIL	.POWER     	0.014	0.014	0.012	0.010
*MAJSSIL 	.POWER     				0.008
*W-RAPE		.POWER     	0.014	0.014	0.012	0.010
*S-RAPE		.POWER    	0.014	0.014	0.012	0.010
*POTATO		.POWER		0.034	0.034	0.034	0.034
*SUGAR		.POWER     			0.016	0.016
*FORAGE1 	.POWER     	0.012	0.012	0.009	0.009
*FORAGE2 	.POWER     	0.012	0.012	0.009	0.009
*PASTURE1	.POWER     	0.003	0.003	0.002	0.002
*PASTURE2	.POWER		0.002	0.002	0.001	0.001
*PPASTR		.POWER		0.002	0.002	0.001	0.001	
*SALIX      	.POWER		0.010	0.010	0.010	0.010
*LAY		.POWER     	0.003	0.003	0.002	0.002
*LONGLAY  	.POWER     	0.001	0.001	0.0005	0.0005
* Data from SJV
											
W-WHEAT 	.LABOR    	0.005	0.005	0.005	0.005
W-RAY		.LABOR    	0.005	0.005	0.005	0.005
BARLEY		.LABOR    	0.005	0.005	0.005	0.005
OATS		.LABOR    	0.005	0.005	0.005	0.005
*GRAINSIL	.LABOR    	0.017	0.017	0.013	0.011
*MAJSSIL 	.LABOR    				0.009
W-RAPE		.LABOR    	0.005	0.005	0.005	0.005
S-RAPE		.LABOR    	0.005	0.005	0.005	0.005
POTATO		.LABOR    	0.045	0.043	0.042	0.042
SUGAR		.LABOR    			0.013	0.013
FORAGE1 	.LABOR    	0.005	0.005	0.005	0.005
FORAGE2 	.LABOR    	0.005	0.005	0.005	0.005
PASTURE1	.LABOR    	0.003	0.003	0.002	0.002
PASTURE2	.LABOR    	0.003	0.003	0.002	0.002
PPASTR		.LABOR    	0.003	0.003	0.002	0.002
*SALIX 		.LABOR    	0.012	0.012	0.012	0.012
LAY		.LABOR    	0.003	0.003	0.003	0.003
LONGLAY  	.LABOR    	0.0015	0.0015	0.0015	0.0015
* Data from SJV

W-WHEAT 	.OTHRVARCST	1.376	1.516	1.700	1.911
W-RAY		.OTHRVARCST	1.225	1.375	1.529	1.673
BARLEY		.OTHRVARCST	1.033	1.146	1.136	1.314
OATS		.OTHRVARCST	1.078	1.203	1.203	1.376
*GRAINSIL	.OTHRVARCST	0.367	0.368	0.367	0.367
*MAJSSIL 	.OTHRVARCST				3.106
W-RAPE		.OTHRVARCST	0.623	0.637	0.666	0.676
S-RAPE		.OTHRVARCST	0.699	0.691	0.704	0.688
POTATO		.OTHRVARCST	3.085	3.156	3.032	3.007
SUGAR		.OTHRVARCST			3.023	3.100
FORAGE1 	.OTHRVARCST	0.871	0.864	0.853	0.844
FORAGE2 	.OTHRVARCST	0.871	0.864	0.853	0.844
PASTURE1	.OTHRVARCST	0.411	0.405	0.384	0.391
PASTURE2	.OTHRVARCST	0.315	0.315	0.315	0.315
PPASTR		.OTHRVARCST	0.945	0.945	0.945	0.945
*SALIX 		.OTHRVARCST 	2.923	2.923	3.161	3.757
LAY		.OTHRVARCST	0.140	0.140	0.140	0.140									
* Data from SJV
											
W-WHEAT 	.CAPITAL    	2.869	3.111	3.364	3.735
W-RAY		.CAPITAL    	2.727	3.009	2.974	3.753
BARLEY		.CAPITAL    	1.118	1.146	1.136	1.314
OATS		.CAPITAL    	1.205	1.302	1.269	1.438
*GRAINSIL	.CAPITAL    	0.684	0.688	0.726	0.727
*MAJSSIL 	.CAPITAL    				2.154
W-RAPE		.CAPITAL    	1.758	2.258	2.385	2.408
S-RAPE		.CAPITAL    	0.946	1.000	1.034	0.975
POTATO		.CAPITAL    	15.21	17.01	16.96	17.51
SUGAR		.CAPITAL    			3.892	4.100	
FORAGE1 	.CAPITAL    	1.435	1.515	1.459	1.469
FORAGE2 	.CAPITAL    	1.152	1.204	1.160	1.133
*SALIX 		.CAPITAL 	4.000	4.000	4.000	4.000
LAY		.CAPITAL    	0.239	0.244	0.298	0.300
* Data from SJV
												
* Additional costs for hay instead of silage
*				R9ss	R9gns	R9gmb	R9gss
*----------------------------------------------------------------------------------------------------
MAKEHAY  	.SILAGE 	1.000	1.000	1.000	1.000	
MAKEHAY  	.HAY    	-1.19	-1.19	-1.19	-1.19	
MAKEHAY  	.OTHRVARCST	0.200	0.200	0.200	0.200

* Environmental parameters											
*				R9ss	R9gns	R9gmb	R9gss
*----------------------------------------------------------------------------------------------------
W-WHEAT  	.N-LEAKAGE	0.025	0.025	0.040	0.040
W-RAY     	.N-LEAKAGE	0.025	0.025	0.040	0.040
BARLEY  	.N-LEAKAGE	0.023	0.023	0.045	0.045
OATS	  	.N-LEAKAGE	0.023	0.023	0.045	0.045
W-RAPE	 	.N-LEAKAGE	0.025	0.025	0.056	0.056
S-RAPE	 	.N-LEAKAGE	0.025	0.025	0.056	0.056
POTATO  	.N-LEAKAGE	0.043	0.043	0.070	0.070
SUGAR	  	.N-LEAKAGE	0.030	0.030	0.030	0.030
FORAGE1 	.N-LEAKAGE	0.006	0.006	0.019	0.019
FORAGE2  	.N-LEAKAGE	0.006	0.006	0.019	0.019
PASTURE1	.N-LEAKAGE	0.006	0.006	0.019	0.019
PASTURE2  	.N-LEAKAGE	0.004	0.003	0.010	0.010
PPASTR		.N-LEAKAGE	0.003	0.001	0.001	0.002
LAY		.N-LEAKAGE	0.017	0.017	0.040	0.040
LONGLAY  	.N-LEAKAGE	0.006	0.006	0.019	0.019

W-WHEAT  	.P-LEAKAGE	0.62	0.62	0.27	0.27
W-RAY     	.P-LEAKAGE	0.62	0.62	0.27	0.27
BARLEY  	.P-LEAKAGE	0.69	0.69	0.45	0.45
OATS	  	.P-LEAKAGE	0.69	0.69	0.45	0.45
W-RAPE	 	.P-LEAKAGE	0.62	0.62	0.40	0.40
S-RAPE	 	.P-LEAKAGE	0.71	0.71	0.36	0.36
POTATO  	.P-LEAKAGE	1.28	1.28	0.55	0.55
SUGAR	  	.P-LEAKAGE	0.48	0.48	0.48	0.48
FORAGE1 	.P-LEAKAGE	0.52	0.52	0.30	0.30
FORAGE2  	.P-LEAKAGE	0.52	0.52	0.30	0.30
PASTURE1	.P-LEAKAGE	0.52	0.52	0.30	0.30
PASTURE2  	.P-LEAKAGE	0.52	0.52	0.30	0.30
PPASTR		.P-LEAKAGE	0.52	0.52	0.30	0.30
LAY		.P-LEAKAGE	0.59	0.59	0.41	0.41
LONGLAY  	.P-LEAKAGE	0.52	0.52	0.30	0.30;
* Data from SOIL-NDB

PRODCOEFC(AS,'N-LEAKAGE',SR)         = PRODCOEFC(AS,'N-LEAKAGE',SR) * 0.85;
* 15 percent of leakage is related to manure: SMED report nr 5 2019

PRODCOEFC(AS,'P-LEAKAGE',SR)         = PRODCOEFC(AS,'P-LEAKAGE',SR)/1000;

*Higher need for labor (and power) for grains and oilgrains in LFA
PRODCOEFC(GRAINS,'LABOR',SR1TO12)       = PRODCOEFC(GRAINS,'LABOR',SR1TO12)    * 1.15;
PRODCOEFC(OILGRAINS,'LABOR',SR1TO12)    = PRODCOEFC(OILGRAINS,'LABOR',SR1TO12) * 1.15;

PRODCOEFC(AS,'POWER',SR)             = PRODCOEFC(AS,'LABOR',SR);
PRODCOEFC('POTATO','POWER',SR)       = PRODCOEFC('POTATO','LABOR',SR) * 0.8;
PRODCOEFC(AS,'LABOR',SR)             = PRODCOEFC(AS,'LABOR',SR) * 1.25;

* Change from feed to dry matter (ts)
PRODCOEFC('FORAGE1','SILAGE',SR)     = PRODCOEFC('FORAGE1','SILAGE',SR) * 0.84;
PRODCOEFC('FORAGE2','SILAGE',SR)     = PRODCOEFC('FORAGE2','SILAGE',SR) * 0.84;
PRODCOEFC('FORAGE2','GRASSPASTR',SR) = PRODCOEFC('FORAGE2','GRASSPASTR',SR) * 0.84;

* Reduce to better matching
PRODCOEFC(GRAINS,'BREADGRAIN',SR)     = PRODCOEFC(GRAINS,'BREADGRAIN',SR) * 0.92;
PRODCOEFC(GRAINS,'COARSGRAIN',SR)     = PRODCOEFC(GRAINS,'COARSGRAIN',SR) * 0.92;
PRODCOEFC(OILGRAINS,'OILGRAIN',SR)    = PRODCOEFC(OILGRAINS,'OILGRAIN',SR) * 0.88;
PRODCOEFC('POTATO','POTATOES',SR)     = PRODCOEFC('POTATO','POTATOES',SR) * 0.90;
PRODCOEFC('SUGAR','SUGARBEET',SR)     = PRODCOEFC('SUGAR','SUGARBEET',SR) * 0.88;

PRODCOEFC('FORAGE1','SILAGE',SR)     = PRODCOEFC('FORAGE1','SILAGE',SR) * 0.90;
PRODCOEFC('FORAGE2','SILAGE',SR)     = PRODCOEFC('FORAGE2','SILAGE',SR) * 0.90;
PRODCOEFC('FORAGE2','GRASSPASTR',SR) = PRODCOEFC('FORAGE2','GRASSPASTR',SR) * 0.90;
PRODCOEFC(FORAGES, FERT,SR)          = PRODCOEFC(FORAGES, FERT,SR) * 0.90;
PRODCOEFC(FORAGES,'CAPITAL',SR)      = PRODCOEFC(FORAGES,'CAPITAL',SR) * 0.90;
PRODCOEFC(FORAGES,'OTHRVARCST',SR)   = PRODCOEFC(FORAGES,'OTHRVARCST',SR) * 0.90;

* Include PK fertilizers for other crops than forage, pasture and salix
PRODCOEFC('W-WHEAT','PHOSPHORUS',SR)    = -PRODCOEFC('W-WHEAT','BREADGRAIN',SR)  * 0.0037;
PRODCOEFC('W-WHEAT','POTASSIUM',SR)     = -PRODCOEFC('W-WHEAT','BREADGRAIN',SR)  * 0.0050;
PRODCOEFC('W-RAY','PHOSPHORUS',SR)      = -PRODCOEFC('W-RAY','BREADGRAIN',SR)    * 0.0035;
PRODCOEFC('W-RAY','POTASSIUM',SR)       = -PRODCOEFC('W-RAY','BREADGRAIN',SR)    * 0.0050;
PRODCOEFC('BARLEY','PHOSPHORUS',SR)     = -PRODCOEFC('BARLEY','COARSGRAIN',SR)   * 0.0035;
PRODCOEFC('BARLEY','POTASSIUM',SR)      = -PRODCOEFC('BARLEY','COARSGRAIN',SR)   * 0.0050;
PRODCOEFC('OATS','PHOSPHORUS',SR)       = -PRODCOEFC('OATS','COARSGRAIN',SR)     * 0.0034;
PRODCOEFC('OATS','POTASSIUM',SR)        = -PRODCOEFC('OATS','COARSGRAIN',SR)     * 0.0050;

PRODCOEFC('W-RAPE','PHOSPHORUS',SR)     = -PRODCOEFC('W-RAPE','OILGRAIN',SR)     * 0.0060;
PRODCOEFC('W-RAPE','POTASSIUM',SR)      = -PRODCOEFC('W-RAPE','OILGRAIN',SR)     * 0.0080;
PRODCOEFC('S-RAPE','PHOSPHORUS',SR)     = -PRODCOEFC('S-RAPE','OILGRAIN',SR)     * 0.0060;
PRODCOEFC('S-RAPE','POTASSIUM',SR)      = -PRODCOEFC('S-RAPE','OILGRAIN',SR)     * 0.0080;
PRODCOEFC('W-RAPE','PHOSPHORUS',SR)     = -PRODCOEFC('W-RAPE','BREADGRAIN',SR)   * 0.0037;
PRODCOEFC('W-RAPE','POTASSIUM',SR)      = -PRODCOEFC('W-RAPE','BREADGRAIN',SR)   * 0.0050;
PRODCOEFC('S-RAPE','PHOSPHORUS',SR)     = -PRODCOEFC('S-RAPE','BREADGRAIN',SR)   * 0.0037;
PRODCOEFC('S-RAPE','POTASSIUM',SR)      = -PRODCOEFC('S-RAPE','BREADGRAIN',SR)   * 0.0050;

PRODCOEFC('POTATO','PHOSPHORUS',SR)     = -PRODCOEFC('POTATO','POTATOES',SR)     * 0.00055;
PRODCOEFC('POTATO','POTASSIUM',SR)      = -PRODCOEFC('POTATO','POTATOES',SR)     * 0.00055;
PRODCOEFC('SUGAR','PHOSPHORUS',SR)      = -PRODCOEFC('SUGAR','SUGARBEET',SR)     * 0.0003;
PRODCOEFC('SUGAR','POTASSIUM',SR)       = -PRODCOEFC('SUGAR','SUGARBEET',SR)     * 0.0020;


* Include coef for pasture
PRODCOEFC('FORAGE2','GRASSPASTR',SR) = PRODCOEFC('FORAGE2','GRASSPASTR',SR) * 0.65/0.8;
PRODCOEFC('PASTURE1','GRASSPASTR',SR) = PRODCOEFC('FORAGE1','SILAGE',SR) * 0.65/0.8;
PRODCOEFC('PASTURE2','GRASSPASTR',SR) = PRODCOEFC('PASTURE1','GRASSPASTR',SR)* 0.8;
PRODCOEFC('PPASTR','GRASSPASTR',SR)   = PRODCOEFC('PASTURE1','GRASSPASTR',SR)* 0.5;

PRODCOEFC('PASTURE1','CAPITAL',SR)    = PRODCOEFC('FORAGE1','CAPITAL',SR)  * 0.9;
PRODCOEFC('PASTURE2','CAPITAL',SR)    = PRODCOEFC('PASTURE1','CAPITAL',SR) * 0.63;
PRODCOEFC('PPASTR','CAPITAL',SR)      = PRODCOEFC('PASTURE1','CAPITAL',SR) * 0.75;

* Include coef for Winter barley
PRODCOEFC('W-BARLEY',IP,SR) = PRODCOEFC('W-WHEAT',IP,SR) * 0.9;
PRODCOEFC('W-BARLEY','COARSGRAIN',SR) = PRODCOEFC('W-WHEAT','BREADGRAIN',SR) * 0.85;
PRODCOEFC('W-BARLEY','BREADGRAIN',SR) = 0;
PRODCOEFC('W-BARLEY','N-LEAKAGE',SR) = PRODCOEFC('W-WHEAT','N-LEAKAGE',SR);
PRODCOEFC('W-BARLEY','P-LEAKAGE',SR) = PRODCOEFC('W-WHEAT','P-LEAKAGE',SR);

* Include coef for cover crops
PRODCOEFC('COVERCROP','NITROGEN',SR)   =  0.040 - 0.040;
PRODCOEFC('COVERCROP','OTHRVARCST',SR) =  0.500 - 0.500;
PRODCOEFC('COVERCROP','LABOR',SR)      =  0.0015;
PRODCOEFC('COVERCROP','LABOR2',SR)     =  0.0015;
PRODCOEFC('COVERCROP','POWER',SR)      =  0.0015;
PRODCOEFC('COVERCROP','INCONVCOV',SR)  =  1.000;
PRODCOEFC('COVERCROP','N-LEAKAGE',SR)  = -PRODCOEFC('BARLEY','N-LEAKAGE',SR)   * 0.33/2;
* Leakage reduction assumed half of catchcrop. Othvarcsot are added to INCONVCOV

* Include coef for catch crops
PRODCOEFC('CATCHCROP','COARSGRAIN',SR0) =  -PRODCOEFC('BARLEY','COARSGRAIN',SR0) * 0.04;
PRODCOEFC('CATCHCROP','NITROGEN',SR0)     = -PRODCOEFC('CATCHCROP','COARSGRAIN',SR0)   * 0.0182;
PRODCOEFC('CATCHCROP','PHOSPHORUS',SR0)   = -PRODCOEFC('CATCHCROP','COARSGRAIN',SR0)   * 0.0035;
PRODCOEFC('CATCHCROP','POTASSIUM',SR0)    = -PRODCOEFC('CATCHCROP','COARSGRAIN',SR0)   * 0.0050;
PRODCOEFC('CATCHCROP','OTHRVARCST',SR0) =  0.150;
PRODCOEFC('CATCHCROP','INCONVCAT',SR0)  =  1.000;
PRODCOEFC('CATCHCROP','N-LEAKAGE',SR0)     = -PRODCOEFC('BARLEY','N-LEAKAGE',SR0)   * 0.33;
* Leakage data from SMED report nr 5 2019

* Include coef for spring tillage
PRODCOEFC('SPRINGTILL','INCONVLAT',SR0) =  1.000;
PRODCOEFC('SPRINGTILL','N-LEAKAGE',SR0) = -PRODCOEFC('BARLEY','N-LEAKAGE',SR0)   * 0.02;
* Leakage data from SMED report nr 5 2019


TABLE PRODCOEFC2(AS,IP,SR)  Unit input and product coef for subregional crop prod act

*				NOO	NN	SSK	GSK	SS	GNS	GMB	GSS
				SR001	SR005	SR014	SR019	SR050	SR076	SR078	SR080
*----------------------------------------------------------------------------------------------------
W-WHEAT 	.HERBICIDES	       0.155  0.155	0.302	0.191	0.208	0.810	0.940
W-RAY   	.HERBICIDES	       0.187  0.187	0.365	0.231	0.252	0.979	1.198
W-BARLEY 	.HERBICIDES	       0.155  0.155	0.302	0.191	0.208	0.810	0.940
BARLEY  	.HERBICIDES	0.128  0.128  0.202	0.205	0.296	0.299	0.411	0.510
OATS    	.HERBICIDES	0.115  0.115  0.181	0.184	0.265	0.269	0.369	0.473
W-RAPE  	.HERBICIDES	       0.139  0.139	0.673	0.149	0.440	0.785	1.010
S-RAPE  	.HERBICIDES	       0.054  0.054	0.261	0.058	0.170	0.304	0.391
POTATO  	.HERBICIDES	0.252  0.252  0.457	0.438	0.668	0.676	0.930	1.400
SUGAR   	.HERBICIDES	          		2.930			2.930	2.930
FEEDPEAS   	.HERBICIDES	0.217  0.217  0.343	0.349	0.502	0.443	0.999	0.719

W-WHEAT 	.GLYFOSAT	       0.016  0.092	0.125	0.162	0.187	0.261	0.312
W-RAY   	.GLYFOSAT	       0.016  0.092	0.125	0.162	0.187	0.261	0.312
W-BARLEY 	.GLYFOSAT	       0.016  0.092	0.125	0.162	0.187	0.261	0.312
BARLEY  	.GLYFOSAT	0.016  0.016  0.092	0.125	0.162	0.187	0.261	0.312
OATS    	.GLYFOSAT	0.016  0.016  0.092	0.125	0.162	0.187	0.261	0.312
W-RAPE  	.GLYFOSAT	       0.016  0.092	0.125	0.162	0.187	0.261	0.312
S-RAPE  	.GLYFOSAT	       0.016  0.092	0.125	0.162	0.187	0.261	0.312
LAY     	.GLYFOSAT	0.202  0.202  0.202	0.202	0.202	0.202	0.202	0.202
SUGAR   	.GLYFOSAT	          		0.280			0.280	0.280
FORAGE1   	.GLYFOSAT	0.020  0.020	0.046	0.108	0.056	0.119	0.113	0.104
FORAGE2   	.GLYFOSAT	0.020  0.020	0.046	0.108	0.056	0.119	0.113	0.104
FORAGE3   	.GLYFOSAT	0.020  0.020	0.046	0.108	0.056	0.119	0.113	0.104
PASTURE1   	.GLYFOSAT	0.020  0.020	0.046	0.108	0.056	0.119	0.113	0.104
PASTURE2   	.GLYFOSAT	0.020  0.020	0.046	0.108	0.056	0.119	0.113	0.104

W-WHEAT 	.FUNGICIDES			0.064	0.101	0.082	0.129	0.261	0.293
W-RAY   	.FUNGICIDES	          	0.036	0.058	0.047	0.073	0.149	0.167
W-BARLEY 	.FUNGICIDES			0.064	0.101	0.082	0.129	0.261	0.293
BARLEY  	.FUNGICIDES	0.000  0.000  0.030	0.016	0.061	0.052	0.073	0.119
OATS    	.FUNGICIDES	0.000  0.000  0.004	0.002	0.009	0.008	0.011	0.017
W-RAPE  	.FUNGICIDES	       0.000  0.020	0.033	0.027	0.041	0.084	0.121
S-RAPE  	.FUNGICIDES	       0.000  0.000	0.000	0.000	0.000	0.000	0.000
POTATO  	.FUNGICIDES	0.792  0.792  0.792	2.044	0.831	1.309	2.657	3.069
SUGAR   	.FUNGICIDES	          		0.110			0.110	0.110
FEEDPEAS   	.FUNGICIDES	0.000  0.000  0.000	0.003	0.000	0.001	0.005	0.017

W-WHEAT 	.INSECTICID	       0.000 	0.000	0.002	0.000	0.001	0.011	0.018
W-RAY   	.INSECTICID	       0.000 	0.000	0.004	0.000	0.001	0.017	0.028
W-BARLEY 	.INSECTICID	       0.000 	0.000	0.002	0.000	0.001	0.011	0.018
BARLEY  	.INSECTICID	0.000  0.000 	0.000	0.001	0.000	0.001	0.007	0.015
OATS    	.INSECTICID	0.000  0.000	0.000	0.000	0.000	0.000	0.002	0.004
W-RAPE  	.INSECTICID	       0.000	0.000	0.024	0.013	0.010	0.035	0.050
S-RAPE  	.INSECTICID	       0.000	0.000	0.025	0.014	0.011	0.037	0.050
POTATO  	.INSECTICID	0.000  0.000	0.000	0.000	0.000	0.000	0.018	0.000
SUGAR   	.INSECTICID	       0.000	0.000	0.000			0.000	0.000
FEEDPEAS   	.INSECTICID	0.000  0.000  0.000	0.000	0.000	0.005	0.000	0.025;

PRODCOEFC2(AS,'HERBICIDES',SR) = PRODCOEFC2(AS,'HERBICIDES',SR) * 1.2  * 1.33;
PRODCOEFC2(AS,'GLYFOSAT',SR)   = PRODCOEFC2(AS,'GLYFOSAT',SR)   * 1    * 1.33;
PRODCOEFC2(AS,'FUNGICIDES',SR) = PRODCOEFC2(AS,'FUNGICIDES',SR) * 1    * 1.0;
PRODCOEFC2(AS,'INSECTICID',SR) = PRODCOEFC2(AS,'INSECTICID',SR) * 1.33 * 2.5;
* The first part of the adjustment is to match the use as in SCB, MI 31 SM 1802
* The secund part is to match use with sales as in SCB, MI 31 SM 2101 

TABLE PRODCOEFL(AS,IP,SR)  Unit input and product coef for subregional livestock prod act	

* DAIRY COWS												
*				R1a	R2a	R2b	R3a	R4a	R5a	R5b	R5c	R9ss	R9gss
				SR001	SR006	SR009	SR010	SR012	SR061	SR033	SR043	SR074	SR080
*----------------------------------------------------------------------------------------------------
DCOW1	 	.MILK   	-8.138	-8.138	-8.138	-8.138	
DCOW2	 	.MILK   					-7.826	-7.826	-7.826	-7.826	-7.826	-7.826
DCOW3	 	.MILK   					-8.112	-8.112	-8.112
DCOW4	 	.MILK   						-8.033	-8.033	-8.033		-8.033
DCOW1	 	.MINDCOW   	-1.000	-1.000	-1.000	-1.000	
DCOW2	 	.MINDCOW   					-1.000	-1.000	-1.000	-1.000	-1.000	-1.000
DCOW3	 	.MINDCOW   					-1.000	-1.000	-1.000
DCOW4	 	.MINDCOW   						-1.000	-1.000	-1.000		-1.000
DCOW1*DCOW4	.SLGHBEEF	-0.085	-0.085	-0.085	-0.085	-0.085	-0.085	-0.085	-0.085	-0.085	-0.085
DCOW1*DCOW4	.DCALFM  	-0.460	-0.460	-0.460	-0.460	-0.460	-0.460	-0.460	-0.460	-0.460	-0.460
DCOW1*DCOW4	.DCALFF  	-0.460	-0.460	-0.460	-0.460	-0.460	-0.460	-0.460	-0.460	-0.460	-0.460
DCOW1*DCOW4	.DHEIFER  	0.333	0.333	0.333	0.333	0.333	0.333	0.333	0.333	0.333	0.333

DCOW1		.HAY	 	0.231	0.231	0.231	0.231
DCOW1		.SILAGE 	2.297	2.297	2.297	2.297
DCOW1		.GRASSPASTR 	0.643	0.643	0.643	0.643
DCOW1		.FEEDGRAIN	1.876	1.876	1.876	1.876
DCOW1		.BETFOR  	0.052	0.052	0.052	0.052	
DCOW1		.SOJA		0.320	0.320	0.320	0.320
DCOW1		.RAPEMEAL	0.390	0.390	0.390	0.390	
DCOW1		.OTHERFEED	3.161	3.161	3.161	3.161

DCOW2		.HAY     					0.323	0.323	0.323	0.323	0.323	0.323
DCOW2		.SILAGE 					2.115	2.115	2.115	2.115	2.115	2.115
DCOW2		.GRASSPASTR 					0.848	0.848	0.848	0.848	0.848	0.848
DCOW2		.FEEDGRAIN					1.805	1.805	1.805	1.805	1.805	1.805
DCOW2		.BETFOR 					0.104	1.805	1.805	1.805	1.805	1.805
DCOW2		.FPEAS	 					0.007	0.007	0.007	0.007	0.007	0.007
DCOW2		.SOJA						0.298	0.298	0.298	0.298	0.298	0.298
DCOW2		.RAPEMEAL					0.374	0.374	0.374	0.374	0.374	0.374
DCOW2		.OTHERFEED					2.620	2.620	2.620	2.620	2.620	2.620

DCOW3		.HAY     					0.529	0.529	0.529
DCOW3		.SILAGE 					2.025	2.025	2.025
DCOW3		.GRASSPASTR 					0.739	0.739	0.739
DCOW3		.FEEDGRAIN					1.513	1.513	1.513
DCOW3		.BETFOR 					0.194	0.194	0.194
DCOW3		.FPEAS	 					0.015	0.015	0.015
DCOW3		.SOJA						0.414	0.414	0.414
DCOW3		.RAPEMEAL					0.509	0.509	0.509
DCOW3		.OTHERFEED					3.497	3.497	3.497

DCOW4		.HAY     					0.266	0.266	0.266	0.266	0.266	0.266
DCOW4		.SILAGE 					2.161	2.161	2.161	2.161	2.161	2.161
DCOW4		.GRASSPASTR 					0.655	0.655	0.655	0.655	0.655	0.655
DCOW4		.FEEDGRAIN					1.380	1.380	1.380	1.380	1.380	1.380
DCOW4		.HP-MASSA 					0.717	0.717	0.717	0.717	0.717	0.717
DCOW4		.FPEAS	 					0.008	0.008	0.008	0.008	0.008	0.008
DCOW4		.SOJA						0.346	0.346	0.346	0.346	0.346	0.346
DCOW4		.RAPEMEAL					0.411	0.411	0.411	0.411	0.411	0.411
DCOW4		.OTHERFEED					2.834	2.834	2.834	2.834	2.834	2.834


DCOW1*DCOW4	.OTHRVARCST	2.345	2.325	2.287	2.263	2.187	2.082	2.083	2.082	2.083	2.082
DCOW1*DCOW4	.CAPITAL	1.027	0.995	0.967	0.892	0.851	0.810	0.789	0.802	0.802	0.753
DCOW1*DCOW4	.LABOR  	0.070	0.065	0.063	0.060	0.055	0.055	0.050	0.050	0.045	0.045
DCOW1*DCOW4	.DAIRYFAC   	1.000	1.000 	1.000	1.000	1.000	1.000	1.000	1.000	1.000	1.000

DCOW1*DCOW4	.N-LEAKAGE	0.009	0.009	0.009	0.009	0.009	0.011	0.012	0.009	0.008	0.011
DCOW1*DCOW4	.N-PROD 	0.139	0.139	0.139	0.139	0.139	0.139	0.139	0.139	0.139	0.139
DCOW1*DCOW4	.P-PROD 	0.0196	0.0196	0.0196	0.0196	0.0196	0.0196	0.0196	0.0196	0.0196	0.0196
*DCOW1*DCOW4	.CO2		0.0318	0.0318	0.0318	0.0318	0.0318	0.0318	0.0318	0.0318	0.0318	0.0318
*DCOW1*DCOW4	.CH4		0.173	0.173	0.173	0.173	0.173	0.173	0.173	0.173	0.173	0.173
DCOW1*DCOW4	.ACRMANURE	0.625	0.625	0.625	0.625	0.625	0.625	0.625	0.625	0.625	0.625



* Dairy heifers												
*				R1a	R2a	R2b	R3a	R4a	R5a	R5b	R5c	R9ss	R9gss
*----------------------------------------------------------------------------------------------------
HEIFER		.DHEIFER	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1	
HEIFER		.DCALFF 	1	1	1	1	1	1	1	1	1	1	
HEIFER		.SILAGE 	1.798	1.798	1.798	1.798	1.798	1.798	1.798	1.798	1.798	1.798
HEIFER		.GRASSPASTR	1.365	1.365	1.365	1.365	1.365	1.365	1.365	1.365	1.365	1.365
HEIFER		.FEEDGRAIN	1.061	1.061	1.061	1.061	1.061	1.061	1.061	1.061	1.061	1.061
HEIFER		.RAPEMEAL	0.072	0.072	0.072	0.072	0.072	0.072	0.072	0.072	0.072	0.072
HEIFER		.BETFOR  	0.055	0.055	0.055	0.055	0.055	0.055	0.055	0.055	0.055	0.055
HEIFER		.SOJA   	0.039	0.039	0.039	0.039	0.039	0.039	0.039	0.039	0.039	0.039
HEIFER		.OTHERFEED	0.106	0.106	0.106	0.106	0.106	0.106	0.106	0.106	0.106	0.106
HEIFER		.OTHRVARCST	1.031	1.035	1.013	1.002	0.990	0.996	0.994	1.000	0.996	0.995	
HEIFER		.CAPITAL	10.139	9.823	9.933	9.011	8.553	7.512	7.222	7.421	7.602	6.745	
HEIFER		.LABOR  	0.034	0.029	0.028	0.025	0.022	0.023	0.021	0.022	0.020	0.020	
HEIFER		.ACRMANURE	0.408	0.408	0.408	0.408	0.408	0.408	0.408	0.408	0.408	0.408
*Data from dbull2 buildings and environmental effects are included in dcows


* Dairy bulls												
*				R1a	R2a	R2b	R3a	R4a	R5a	R5b	R5c	R9ss	R9gss
*----------------------------------------------------------------------------------------------------
DAIRYBULL1	.SLGHBEEF	-0.275	-0.275	-0.275	-0.275	-0.275	-0.275	-0.275	-0.275	-0.275	-0.275	
DAIRYBULL1	.DCALFM  	1	1	1	1	1	1	1	1	1	1	
DAIRYBULL1	.SILAGE  	1.991	1.972	1.952	1.876	1.852	1.799	1.784	1.799	1.801	1.739	
DAIRYBULL1	.GRASSPASTR	0.469	0.498	0.529	0.649	0.687	0.770	0.794	0.770	0.767	0.864	
DAIRYBULL1	.FEEDGRAIN	1.330	1.317	1.304	1.253	1.237	1.202	1.191	1.201	1.203	1.161	
DAIRYBULL1	.OTHERFEED	0.121	0.120	0.119	0.114	0.112	0.109	0.108	0.109	0.109	0.106	
DAIRYBULL1	.OTHRVARCST	1.069	1.075	1.052	1.043	1.028	1.033	1.027	1.032	1.026	1.026	
DAIRYBULL1	.CAPITAL	7.420	7.257	7.276	6.822	6.553	6.032	5.855	5.933	6.054	5.611	
DAIRYBULL1	.LABOR  	0.026	0.021	0.021	0.019	0.016	0.017	0.016	0.016	0.015	0.015	
DAIRYBULL1	.BULLFAC	1.5	1.5	1.5	1.5	1.5	1.5	1.5	1.5	1.5	1.5	
DAIRYBULL1	.N-LEAKAGE	0.0049	0.0049	0.0049	0.0049	0.0049	0.0060	0.0065	0.0049	0.0044	0.0060
DAIRYBULL1	.N-PROD 	0.059	0.059	0.059	0.059	0.059	0.059	0.059	0.059	0.059	0.059
DAIRYBULL1	.P-PROD 	0.0083	0.0083	0.0083	0.0083	0.0083	0.0083	0.0083	0.0083	0.0083	0.0083
*DAIRYBULL1	.CO2		0.016	0.016	0.016	0.016	0.016	0.016	0.016	0.016	0.016	0.016
*DAIRYBULL1	.CH4		0.099	0.099	0.099	0.099	0.099	0.099	0.099	0.099	0.099	0.099
DAIRYBULL1	.ACRMANURE	0.281	0.281	0.281	0.281	0.281	0.281	0.281	0.281	0.281	0.281
												
DAIRYBULL2	.SLGHBEEF	-0.250	-0.250	-0.250	-0.250	-0.250	-0.250	-0.250	-0.250	-0.250	-0.250	
DAIRYBULL2	.DCALFM  	1	1	1	1	1	1	1	1	1	1	
DAIRYBULL2	.SILAGE 	2.912	2.912	2.912	2.912	2.465	2.465	2.465	2.465	2.477	2.465
DAIRYBULL2	.GRASSPASTR	1.845	1.845	1.845	1.845	2.703	2.703	2.703	2.703	2.682	2.703
DAIRYBULL2	.FEEDGRAIN	0.140	0.140	0.140	0.140	0.119	0.119	0.119	0.119	0.119	0.119	
DAIRYBULL2	.OTHERFEED	0.073	0.073	0.073	0.073	0.062	0.062	0.062	0.062	0.062	0.062	
DAIRYBULL2	.OTHRVARCST	1.031	1.035	1.013	1.002	0.990	0.996	0.994	1.000	0.996	0.995	
DAIRYBULL2	.CAPITAL	10.139	9.823	9.933	9.011	8.553	7.512	7.222	7.421	7.602	6.745	
DAIRYBULL2	.LABOR  	0.034	0.029	0.028	0.025	0.022	0.023	0.021	0.022	0.020	0.020	
DAIRYBULL2	.BULLFAC 	1	1	1	1	1	1	1	1	1	1	
DAIRYBULL2	.N-LEAKAGE	0.0065	0.0065	0.0065	0.0065	0.0065	0.008	0.0087	0.0065	0.0058	0.0080
DAIRYBULL2	.N-PROD 	0.093	0.093	0.093	0.093	0.093	0.093	0.093	0.093	0.093	0.093
DAIRYBULL2	.P-PROD 	0.0131	0.0131	0.0131	0.0131	0.0131	0.0131	0.0131	0.0131	0.0131	0.0131
*DAIRYBULL2	.CO2		0.0223	0.0223	0.0223	0.0223	0.0223	0.0223	0.0223	0.0223	0.0223	0.0223
*DAIRYBULL2	.CH4		0.132	0.132	0.132	0.132	0.132	0.132	0.132	0.132	0.132	0.132
DAIRYBULL2	.ACRMANURE	0.408	0.408	0.408	0.408	0.408	0.408	0.408	0.408	0.408	0.408
												
* Beef cattle												
*				R1a	R2a	R2b	R3a	R4a	R5a	R5b	R5c	R9ss	R9gss
*----------------------------------------------------------------------------------------------------
BEEFCATTLE	.SLGHBEEF	-0.246	-0.246	-0.246	-0.246	-0.246	-0.246	-0.246	-0.246	-0.246	-0.246
BEEFCATTLE	.SILAGE 	3.988	3.918	3.843	3.557	3.467	3.269	3.211	3.269	3.275	3.043	
BEEFCATTLE	.GRASSPASTR	1.699	1.770	1.846	2.137	2.228	2.430	2.489	2.430	2.423	2.659	
BEEFCATTLE	.FEEDGRAIN	0.629	0.621	0.612	0.576	0.565	0.541	0.534	0.541	0.542	0.513	
BEEFCATTLE	.OTHERFEED	0.415	0.418	0.421	0.429	0.431	0.433	0.433	0.433	0.433	0.433	
BEEFCATTLE	.OTHRVARCST	1.459	1.475	1.468	1.441	1.425	1.403	1.387	1.413	1.413	1.384	
BEEFCATTLE	.CAPITAL	4.198	4.027	3.938	3.681	3.486	3.314	3.234	3.277	3.259	3.095	
BEEFCATTLE	.LABOR  	0.044	0.039	0.038	0.036	0.033	0.036	0.033	0.034	0.031	0.032	
BEEFCATTLE	.BEEFCFAC	1	1	1	1	1	1	1	1	1	1	
BEEFCATTLE	.BULLFAC	1	1	1	1	1	1	1	1	1	1	
BEEFCATTLE	.N-LEAKAGE	0.0083	0.0083	0.0083	0.0083	0.0083	0.0101	0.0110	0.0083	0.0073	0.0101
BEEFCATTLE	.N-PROD 	0.108	0.108	0.108	0.108	0.108	0.108	0.108	0.108	0.108	0.108
BEEFCATTLE	.P-PROD 	0.0158	0.0158	0.0158	0.0158	0.0158	0.0158	0.0158	0.0158	0.0158	0.0158
*BEEFCATTLE	.CO2		0.0295	0.0295	0.0295	0.0295	0.0295	0.0295	0.0295	0.0295	0.0295	0.0295
*BEEFCATTLE	.CH4		0.150	0.150	0.150	0.150	0.150	0.150	0.150	0.150	0.150	0.150
BEEFCATTLE	.ACRMANURE	0.681	0.681	0.681	0.681	0.681	0.681	0.681	0.681	0.681	0.681
												
* Sheep												
*----------------------------------------------------------------------------------------------------
SHEEP		.SLGHSHEEP	-0.030	-0.030	-0.030	-0.030	-0.030	-0.030	-0.030	-0.030	-0.030	-0.030	
SHEEP		.MISCRCPT	-0.009	-0.009	-0.009	-0.009	-0.009	-0.009	-0.009	-0.009	-0.009	-0.009	
SHEEP		.SILAGE  	0.366	0.361	0.355	0.332	0.325	0.309	0.305	0.309	0.310	0.291	
SHEEP		.GRASSPASTR	0.257	0.273	0.290	0.356	0.376	0.422	0.435	0.422	0.420	0.474	
SHEEP		.FEEDGRAIN	0.051	0.050	0.050	0.046	0.045	0.043	0.043	0.043	0.043	0.041
SHEEP		.OTHERFEED	0.027	0.027	0.026	0.025	0.024	0.023	0.022	0.023	0.023	0.022	
SHEEP		.OTHRVARCST	0.268	0.266	0.266	0.261	0.256	0.249	0.247	0.249	0.251	0.245	
SHEEP		.CAPITAL	0.434	0.417	0.410	0.392	0.372	0.354	0.347	0.348	0.348	0.335	
SHEEP		.LABOR  	0.014	0.014	0.014	0.014	0.014	0.014	0.014	0.014	0.014	0.014	
SHEEP		.SHEEPFAC    	1	1	1	1	1	1	1	1	1	1	
SHEEP		.N-LEAKAGE	0.0004	0.0004	0.0004	0.0004	0.0004	0.0005	0.0005	0.0004	0.0004	0.0005
SHEEP		.N-PROD 	0.012	0.012	0.012	0.012	0.012	0.012	0.012	0.012	0.012	0.012
SHEEP		.P-PROD 	0.002	0.002	0.002	0.002	0.002	0.002	0.002	0.002	0.002	0.002
*SHEEP		.CO2		0.0059	0.0059	0.0059	0.0059	0.0059	0.0059	0.0059	0.0059	0.0059	0.0059
*SHEEP		.CH4		0.017	0.017	0.017	0.017	0.017	0.017	0.017	0.017	0.017	0.017
SHEEP		.ACRMANURE	0.067	0.067	0.067	0.067	0.067	0.067	0.067	0.067	0.067	0.067
												
* Swine												
*				R1a	R2a	R2b	R3a	R4a	R5a	R5b	R5c	R9ss	R9gss
*----------------------------------------------------------------------------------------------------
SOW1		.PIGLETS	-19	-19	-19	-19	-19	-19	-19	-19	-19	-19
SOW1		.SLGHPORK	-0.052	-0.052	-0.052	-0.052	-0.052	-0.052	-0.052	-0.052	-0.052	-0.052
SOW1		.GILTS   	0.4	0.4	0.4	0.4	0.4	0.4	0.4	0.4	0.4	0.4
SOW1		.FEEDGRAIN	1.561	1.561	1.561	1.561	1.561	1.561	1.561	1.561	1.561	1.561
SOW1		.OTHERFEED	1.730	1.730	1.730	1.730	1.730	1.730	1.730	1.730	1.730	1.730
SOW1		.OTHRVARCST	1.688	1.688	1.688	1.688	1.688	1.688	1.688	1.688	1.688	1.688
SOW1		.CAPITAL	0.794	0.794	0.794	0.794	0.794	0.794	0.794	0.794	0.794	0.794
SOW1		.LABOR		0.015	0.015	0.015	0.015	0.015	0.015	0.015	0.015	0.015	0.015
SOW1		.SOWFAC    	1	1	1	1	1	1	1	1	1	1	
SOW1		.N-LEAKAGE	0.0172	0.0172	0.0172	0.0172	0.0172	0.0210	0.0229	0.0172	0.0153	0.0210
SOW1		.N-PROD 	0.029	0.029	0.029	0.029	0.029	0.029	0.029	0.029	0.029	0.029
SOW1		.P-PROD 	0.011	0.011	0.011	0.011	0.011	0.011	0.011	0.011	0.011	0.011
*SOW1		.CO2		0.0104	0.0104	0.0104	0.0104	0.0104	0.0104	0.0104	0.0104	0.0104	0.0104
*SOW1		.CH4		0.015	0.015	0.015	0.015	0.015	0.015	0.015	0.015	0.015	0.015
SOW1		.ACRMANURE	0.455	0.455	0.455	0.455	0.455	0.455	0.455	0.455	0.455	0.455

GILT		.GILTS   	-0.66	-0.66	-0.66	-0.66	-0.66	-0.66	-0.66	-0.66	-0.66	-0.66
GILT		.SLGHPORK	-0.025	-0.025	-0.025	-0.025	-0.025	-0.025	-0.025	-0.025	-0.025	-0.025
GILT		.PIGLETS	1	1	1	1	1	1	1	1	1	1	
GILT		.FEEDGRAIN	0.188	0.188	0.188	0.188	0.188	0.188	0.188	0.188	0.188	0.188	
GILT		.OTHERFEED	0.239	0.239	0.243	0.243	0.240	0.208	0.208	0.208	0.208	0.208
GILT		.OTHRVARCST	0.087	0.087	0.087	0.087	0.087	0.085	0.085	0.085	0.087	0.085	
GILT		.CAPITAL	0.725	0.725	0.724	0.724	0.639	0.631	0.631	0.631	0.631	0.631
GILT		.LABOR		0.002	0.002	0.002	0.002	0.002	0.002	0.002	0.002	0.002	0.002	
GILT		.N-PROD 	0.010	0.010	0.010	0.010	0.010	0.010	0.010	0.010	0.010	0.010
GILT		.P-PROD 	0.004	0.004	0.004	0.004	0.004	0.004	0.004	0.004	0.004	0.004
GILT		.ACRMANURE	0.076	0.076	0.076	0.076	0.076	0.076	0.076	0.076	0.076	0.076

SLGHSWINE1	.SLGHPORK	-0.083	-0.083	-0.083	-0.083	-0.083	-0.083	-0.083	-0.083	-0.083	-0.083	
SLGHSWINE1	.PIGLETS	1	1	1	1	1	1	1	1	1	1	
SLGHSWINE1	.FEEDGRAIN	0.231	0.231	0.231	0.231	0.231	0.231	0.231	0.231	0.231	0.231	
SLGHSWINE1	.OTHERFEED	0.173	0.173	0.173	0.173	0.173	0.173	0.173	0.173	0.173	0.173	
SLGHSWINE1	.OTHRVARCST	0.060	0.060	0.060	0.060	0.060	0.060	0.060	0.060	0.060	0.060	
SLGHSWINE1	.CAPITAL	0.220	0.220	0.220	0.220	0.220	0.220	0.220	0.220	0.220	0.220	
SLGHSWINE1	.LABOR  	0.0003	0.0003	0.0003	0.0003	0.0003	0.0003	0.0003	0.0003	0.0003	0.0003	
SLGHSWINE1	.SWINEFAC	0.38	0.38	0.38	0.38	0.38	0.38	0.38	0.38	0.38	0.38	
SLGHSWINE1	.N-LEAKAGE	0.0007	0.0007	0.0007	0.0007	0.0007	0.0008	0.0010	0.0008	0.0006	0.0009
SLGHSWINE1	.N-PROD 	0.003	0.003	0.003	0.003	0.003	0.003	0.003	0.003	0.003	0.003
SLGHSWINE1	.P-PROD 	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001
*SLGHSWINE1	.CO2		0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001
SLGHSWINE1	.ACRMANURE	0.036	0.036	0.036	0.036	0.036	0.036	0.036	0.036	0.036	0.036

ECOPIG		.SLGHPORK						-1.333	-1.333	-1.333	-1.333	-1.333 
ECOPIG		.FEEDGRAIN						5.608	5.608	5.608	5.608	5.608
ECOPIG		.FPEAS    						1.323	1.323	1.323	1.323	1.323
ECOPIG		.OTHERFEED						8.618	8.618	8.618	8.618	8.618
ECOPIG		.SILAGE   						0.588	0.588	0.588	0.588	0.588
ECOPIG		.CROPLAND						0.400	0.400	0.400	0.400	0.400
ECOPIG		.OTHRVARCST						5.725	5.725	5.725	5.725	5.725
ECOPIG		.CAPITAL						7.978	7.978	7.978	7.978	7.978
ECOPIG		.LABOR							0.045	0.045	0.045	0.045	0.045
ECOPIG		.N-LEAKAGE	0.020	0.020	0.020	0.020	0.020	0.020	0.020	0.020	0.020	0.020
ECOPIG		.N-PROD 	0.089	0.089	0.089	0.089	0.089	0.089	0.089	0.089	0.089	0.089
ECOPIG		.P-PROD 	0.031	0.031	0.031	0.031	0.031	0.031	0.031	0.031	0.031	0.031
*ECOPIG		.CO2		0.054	0.054	0.054	0.054	0.054	0.054	0.054	0.054	0.054	0.054
*ECOPIG		.CH4		0.015	0.015	0.015	0.015	0.015	0.015	0.015	0.015	0.015	0.015
*ECOPIG		.ECON							-0.040	-0.040	-0.040	-0.040	-0.040
*ECOPIG		.ECOP							-0.031	-0.031	-0.031	-0.031	-0.031
*ECOPIG		.ECOK							-0.058	-0.058	-0.058	-0.058	-0.058
ECOPIG		.ACRMANURE	1.100	1.100	1.100	1.100	1.100	1.100	1.100	1.100	1.100	1.100
											
* Poultry												
*				R1a	R2a	R2b	R3a	R4a	R5a	R5b	R5c	R9ss	R9gss
*----------------------------------------------------------------------------------------------------
POULTRY 	.EGG    	-15.5	-15.5	-15.5	-15.5	-15.5	-15.5	-15.5	-15.5	-15.5	-15.5
*POULTRY 	.SLGHPLTRY	-1.2	-1.2	-1.2	-1.2	-1.2	-1.2	-1.2	-1.2	-1.2	-1.2
POULTRY 	.MISCCOST	8.3	8.3	8.3	8.3	8.3	8.3	8.3	8.3	8.3	8.3
POULTRY 	.FEEDGRAIN	27.8	27.8	27.8	27.8	27.8	27.8	27.8	27.8	27.8	27.8
POULTRY 	.OTHERFEED	35.4	35.4	34.0	34.0	33.6	32.6	32.6	32.6	32.6	32.6
POULTRY 	.OTHRVARCST	35.2	35.2	35.2	35.2	35.2	35.2	35.2	35.2	35.2	35.2
POULTRY 	.CAPITAL	23.1	23.1	22.8	22.8	22.7	22.6	22.6	22.6	22.6	22.6
POULTRY 	.LABOR  	0.17	0.17	0.17	0.17	0.17	0.17	0.17	0.17	0.17	0.17
POULTRY 	.PLTRYFAC	1.00	1.0	1.00	1.00	1.00	1.00	1.00	1.00	1.00	1.00
POULTRY  	.N-LEAKAGE	0.115	0.115	0.115	0.115	0.115	0.140	0.153	0.115	0.102	0.140
POULTRY 	.N-PROD 	0.270	0.270	0.270	0.270	0.270	0.270	0.270	0.270	0.270	0.270
POULTRY 	.P-PROD 	0.160	0.160	0.160	0.160	0.160	0.160	0.160	0.160	0.160	0.160
*POULTRY  	.CO2		0.212	0.212	0.212	0.212	0.212	0.212	0.212	0.212	0.212	0.212
*POULTRY  	.CH4		0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000
POULTRY  	.ACRMANURE	10.00	10.00	10.00	10.00	10.00	10.00	10.00	10.00	10.00	10.00

EPOULTRY 	.EGG    	-15.5	-15.5	-15.5	-15.5	-15.5	-15.5	-15.5	-15.5	-15.5	-15.5
*EPOULTRY 	.SLGHPLTRY	-0.9	-0.9	-0.9	-0.9	-0.9	-0.9	-0.9	-0.9	-0.9	-0.9	
EPOULTRY 	.MISCCOST	8.3	8.3	8.3	8.3	8.3	8.3	8.3	8.3	8.3	8.3	
EPOULTRY 	.FEEDGRAIN	31.0	31.0	31.0	31.0	31.0	31.0	31.0	31.0	31.0	31.0	
EPOULTRY 	.SILAGE  	4.0	4.0	4.0	4.0	4.0	4.0	4.0	4.0	4.0	4.0
EPOULTRY 	.OTHERFEED	85.2	85.2	85.2	85.2	85.2	85.2	85.2	85.2	85.2	85.2	
EPOULTRY 	.OTHRVARCST	46.4	46.4	46.4	46.4	46.4	46.4	46.4	46.4	46.4	46.4	
EPOULTRY 	.CAPITAL	35.0	35.0	35.0	35.0	35.0	35.0	35.0	35.0	35.0	35.0
EPOULTRY 	.LABOR  	0.34	0.34	0.34	0.34	0.34	0.34	0.34	0.34	0.34	0.34	
EPOULTRY 	.PLTRYFAC	1.00	1.0	1.00	1.00	1.00	1.00	1.00	1.00	1.00	1.00
EPOULTRY 	.CROPLAND	2.0	2.0	2.0	2.0	2.0	2.0	2.0	2.0	2.0	2.0	
EPOULTRY  	.N-LEAKAGE	0.070	0.070	0.070	0.070	0.070	0.070	0.070	0.070	0.070	0.070
EPOULTRY 	.N-PROD 	0.270	0.270	0.270	0.270	0.270	0.270	0.270	0.270	0.270	0.270
EPOULTRY 	.P-PROD 	0.160	0.160	0.160	0.160	0.160	0.160	0.160	0.160	0.160	0.160
*EPOULTRY  	.CO2		0.100	0.100	0.100	0.100	0.100	0.100	0.100	0.100	0.100	0.100
*EPOULTRY  	.CH4		0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000
*EPOULTRY 	.ECON		-0.25	-0.25	-0.25	-0.25	-0.25	-0.25	-0.25	-0.25	-0.25	-0.25
*EPOULTRY 	.ECOP		-0.15	-0.15	-0.15	-0.15	-0.15	-0.15	-0.15	-0.15	-0.15	-0.15
*EPOULTRY 	.ECOK		-0.15	-0.15	-0.15	-0.15	-0.15	-0.15	-0.15	-0.15	-0.15	-0.15
EPOULTRY  	.ACRMANURE	10.00	10.00	10.00	10.00	10.00	10.00	10.00	10.00	10.00	10.00

* Chicken												
*				R1a	
*----------------------------------------------------------------------------------------------------
CHICKEN 	.SLGHPLTRY	-35.6
*CHICKEN 	.MISCCOST	
CHICKEN 	.FEEDGRAIN	38.8
CHICKEN 	.OTHERFEED	122.1
CHICKEN 	.OTHRVARCST	78
CHICKEN 	.LABOR  	0.05
CHICKEN 	.CHICKFAC	3.15
CHICKEN  	.N-LEAKAGE	0.320
CHICKEN 	.N-PROD 	0.690
CHICKEN 	.P-PROD 	0.171
*CHICKEN  	.CO2		
*CHICKEN  	.CH4		
CHICKEN 	.ACRMANURE	6.38


*Horses
*				R1a	R2a	R2b	R3a	R4a	R5a	R5b	R5c	R9ss	R9gss
*----------------------------------------------------------------------------------------------------
HORSES    	.RIDING 	-1.000	-1.000	-1.000	-1.000	-1.000	-1.000	-1.000	-1.000	-1.000	-1.000
HORSES    	.SILAGE 	1.800	1.800	1.800	1.800	1.800	1.800	1.800	1.800	1.800	1.800
HORSES    	.GRASSPASTR	0.390	0.390	0.390	0.390	0.390	0.390	0.390	0.390	0.390	0.390
HORSES    	.FEEDGRAIN	1.095	1.095	1.095	1.095	1.095	1.095	1.095	1.095	1.095	1.095
HORSES    	.HORSEFAC	1.00	1.0	1.00	1.00	1.00	1.00	1.00	1.00	1.00	1.00
HORSES   	.N-LEAKAGE	0.0033	0.0033	0.0033	0.0033	0.0033	0.0040	0.0044	0.0033	0.0029	0.0040
HORSES   	.N-PROD 	0.050	0.050	0.050	0.050	0.050	0.050	0.050	0.050	0.050	0.050
HORSES   	.P-PROD 	0.011	0.011	0.011	0.011	0.011	0.011	0.011	0.011	0.011	0.011
*HORSES		.CO2		0.0125	0.0125	0.0125	0.0125	0.0125	0.0125	0.0125	0.0125	0.0125	0.0125
*HORSES		.CH4		0.098	0.098	0.098	0.098	0.098	0.098	0.098	0.098	0.098	0.098
HORSES		.ACRMANURE	0.333	0.333	0.333	0.333	0.333	0.333	0.333	0.333	0.333	0.333


*Investments
*				R1a	R2a	R2b	R3a	R4a	R5a	R5b	R5c	R9ss	R9gss
*----------------------------------------------------------------------------------------------------
DAIRYFEXR    .DAIRYFAC  	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1
DAIRYFEXR    .DAIRYFACR 	 1	 1	 1	 1	 1	 1	 1	 1	 1	 1
DAIRYFEXN    .DAIRYFAC  	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1
DAIRYFEXN    .MISCCOST  	6.1	6.0	5.8	5.6	5.4	5.2	5.1	5.1	5.1	5.1

BULLFEXR     .BULLFAC   	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1
BULLFEXR     .BULLFACR  	 1	 1	 1	 1	 1	 1	 1	 1	 1	 1
BULLFEXN     .BULLFAC   	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1
BULLFEXN     .MISCCOST  	0.864	0.792	0.792	0.792	0.720	0.720	0.720	0.720	0.720	0.720

BEEFCFEXR    .BEEFCFAC  	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1
BEEFCFEXR    .BEEFCFACR 	 1	 1	 1	 1	 1	 1	 1	 1	 1	 1
BEEFCFEXN    .BEEFCFAC  	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1
BEEFCFEXN    .MISCCOST  	0.864	0.792	0.792	0.792	0.720	0.720	0.720	0.720	0.720	0.720

SOWFEXR      .SOWFAC    	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1
SOWFEXR      .SOWFACR   	 1	 1	 1	 1	 1	 1	 1	 1	 1	 1
SOWFEXN      .SOWFAC    	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1
SOWFEXN      .MISCCOST  	3.990	3.658	3.658	3.658	3.325	3.325	3.325	3.325	3.325	3.325

SWINEFEXR    .SWINEFAC  	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1
SWINEFEXR    .SWINEFACR 	 1	 1	 1	 1	 1	 1	 1	 1	 1	 1
SWINEFEXN    .SWINEFAC  	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1
SWINEFEXN    .MISCCOST  	0.456	0.418	0.418	0.418	0.308	0.308	0.308	0.308	0.308	0.308

PLTRYFEXR    .PLTRYFAC  	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1
PLTRYFEXR    .PLTRYFACR 	1	 1	 1	 1	 1	 1	 1	 1	 1	 1
PLTRYFEXN    .PLTRYFAC  	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1
PLTRYFEXN    .MISCCOST  	25.1	23.0	23.0	23.0	20.9	20.9	20.9	20.9	20.9	20.9

CHICKFEXR    .CHICKFAC  	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1
CHICKFEXR    .CHICKFACR 	1	 1	 1	 1	 1	 1	 1	 1	 1	 1
CHICKFEXN    .CHICKFAC  	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1
CHICKFEXN    .MISCCOST  	5.7	5.7	5.7	5.7	5.7	5.7	5.7	5.7	5.7	5.7;
*----------------------------------------------------------------------------------------------------
* DAIRYFAC cost 73000 SEK/cow, inv sub 15 % interest rate 3 % on 60 %, depreciation of equipment 10 %
* and building 4 %, equipment takes 40 % of construction cost. 20 % higher in north.
* BEEFCFAC cost 10000 SEK/cow, interest rate 4 % on half, depreciation of equipment 10 %
* and building 2 %, equipment takes 40 % of construction cost.
* SOWFAC3 cost 35000 SEK/sow (50 sows) and SWINEFAC cost 4000 SEK, interest rate 4 % on half,
* depreciation of equipment 10 % and building 5 %, equipment takes 50 % of construction cost. 
* PLTRYFAC3 cost 220000 SEK/1000, interest rate 4 % on half, depreciation of equipment 10 %
* and building 5 %, equipment takes 50 % of construction cost.
* Costs in northern Sweden are up to 25 % higher than in southern Sweden.
* PLTRY data from SLU-Info, other data from LES.

* Updated investment costs based on unit costs from SJV. 15% investment sub
PRODCOEFL('DAIRYFEXN','MISCCOST',SR)    = PRODCOEFL('DAIRYFEXN','MISCCOST',SR) * 111000/73000;
PRODCOEFL('BULLFEXN','MISCCOST',SR)     = PRODCOEFL('BULLFEXN','MISCCOST',SR)  *  27200/10000 * 0.85;
PRODCOEFL('BEEFCFEXN','MISCCOST',SR)    = PRODCOEFL('BEEFCFEXN','MISCCOST',SR) *  63400/10000 * 0.85;
PRODCOEFL('SOWFEXN','MISCCOST',SR)      = PRODCOEFL('SOWFEXN','MISCCOST',SR)   *  74100/35000 * 0.85;
PRODCOEFL('SWINEFEXN','MISCCOST',SR)    = PRODCOEFL('SWINEFEXN','MISCCOST',SR) *   9900/4000  * 0.85;
PRODCOEFL('PLTRYFEXN','MISCCOST',SR)    = PRODCOEFL('PLTRYFEXN','MISCCOST',SR) *  2;
PRODCOEFL('CHICKFEXN','MISCCOST',SR)    = PRODCOEFL('CHICKFEXN','MISCCOST',SR) *  2;

PRODCOEFL('DAIRYFEXN','MISCCOST',SR) $(LONGRUN1)= PRODCOEFL('DAIRYFEXN','MISCCOST',SR)* 1.01**(YR-4);
PRODCOEFL('BULLFEXN','MISCCOST',SR) $(LONGRUN1) = PRODCOEFL('BULLFEXN','MISCCOST',SR) * 1.01**(YR-4);
PRODCOEFL('BEEFCFEXN','MISCCOST',SR) $(LONGRUN1)= PRODCOEFL('BEEFCFEXN','MISCCOST',SR)* 1.01**(YR-4);
PRODCOEFL('SOWFEXN','MISCCOST',SR) $(LONGRUN1)  = PRODCOEFL('SOWFEXN','MISCCOST',SR)  * 1.01**(YR-4);
PRODCOEFL('SWINEFEXN','MISCCOST',SR) $(LONGRUN1)= PRODCOEFL('SWINEFEXN','MISCCOST',SR)* 1.01**(YR-4);
PRODCOEFL('PLTRYFEXN','MISCCOST',SR) $(LONGRUN1)= PRODCOEFL('PLTRYFEXN','MISCCOST',SR)* 1.01**(YR-4);
PRODCOEFL('CHICKFEXN','MISCCOST',SR) $(LONGRUN1)= PRODCOEFL('CHICKFEXN','MISCCOST',SR)* 1.01**(YR-4);

*Higer cost for livestock in north
PRODCOEFL(AS,'OTHERFEED','SR001')       = PRODCOEFL(AS,'OTHERFEED','SR001') * 1.25;
PRODCOEFL(AS,'OTHERFEED','SR006')       = PRODCOEFL(AS,'OTHERFEED','SR006') * 1.15;
PRODCOEFL(AS,'OTHERFEED','SR009')       = PRODCOEFL(AS,'OTHERFEED','SR009') * 1.10;
PRODCOEFL(AS,'OTHERFEED','SR010')       = PRODCOEFL(AS,'OTHERFEED','SR010') * 1.075;
PRODCOEFL(AS,'OTHERFEED','SR012')       = PRODCOEFL(AS,'OTHERFEED','SR012') * 1.05;

PRODCOEFL(AS,'OTHRVARCST','SR001')      = PRODCOEFL(AS,'OTHRVARCST','SR001') * 1.25;
PRODCOEFL(AS,'OTHRVARCST','SR006')      = PRODCOEFL(AS,'OTHRVARCST','SR006') * 1.15;
PRODCOEFL(AS,'OTHRVARCST','SR009')      = PRODCOEFL(AS,'OTHRVARCST','SR009') * 1.10;
PRODCOEFL(AS,'OTHRVARCST','SR010')      = PRODCOEFL(AS,'OTHRVARCST','SR010') * 1.075;
PRODCOEFL(AS,'OTHRVARCST','SR012')      = PRODCOEFL(AS,'OTHRVARCST','SR012') * 1.05;

PRODCOEFL(AS,'CAPITAL','SR001')         = PRODCOEFL(AS,'CAPITAL','SR001') * 1.25;
PRODCOEFL(AS,'CAPITAL','SR006')         = PRODCOEFL(AS,'CAPITAL','SR006') * 1.15;
PRODCOEFL(AS,'CAPITAL','SR009')         = PRODCOEFL(AS,'CAPITAL','SR009') * 1.10;
PRODCOEFL(AS,'CAPITAL','SR010')         = PRODCOEFL(AS,'CAPITAL','SR010') * 1.075;
PRODCOEFL(AS,'CAPITAL','SR012')         = PRODCOEFL(AS,'CAPITAL','SR012') * 1.05;

PRODCOEFL(AS,'LABOR','SR001')           = PRODCOEFL(AS,'LABOR','SR001') * 1.25;
PRODCOEFL(AS,'LABOR','SR006')           = PRODCOEFL(AS,'LABOR','SR006') * 1.15;
PRODCOEFL(AS,'LABOR','SR009')           = PRODCOEFL(AS,'LABOR','SR009') * 1.10;
PRODCOEFL(AS,'LABOR','SR010')           = PRODCOEFL(AS,'LABOR','SR010') * 1.075;
PRODCOEFL(AS,'LABOR','SR012')           = PRODCOEFL(AS,'LABOR','SR012') * 1.05;

PRODCOEFL(AS,'MISCCOST','SR001')        = PRODCOEFL(AS,'MISCCOST','SR001') * 1.25;
PRODCOEFL(AS,'MISCCOST','SR006')        = PRODCOEFL(AS,'MISCCOST','SR006') * 1.15;
PRODCOEFL(AS,'MISCCOST','SR009')        = PRODCOEFL(AS,'MISCCOST','SR009') * 1.10;
PRODCOEFL(AS,'MISCCOST','SR010')        = PRODCOEFL(AS,'MISCCOST','SR010') * 1.075;
PRODCOEFL(AS,'MISCCOST','SR012')        = PRODCOEFL(AS,'MISCCOST','SR012') * 1.05;

* Increase weigth and age for livestock
PRODCOEFL('DAIRYBULL1',IP,SR)           = PRODCOEFL('DAIRYBULL1',IP,SR) * 1.15;
PRODCOEFL('DAIRYBULL1','DCALFM',SR)     = 1;
PRODCOEFL('DAIRYBULL2',IP,SR)           = PRODCOEFL('DAIRYBULL2',IP,SR) * 1.15;
PRODCOEFL('DAIRYBULL2','DCALFM',SR)     = 1;
PRODCOEFL('BEEFCATTLE',IP,SR)           = PRODCOEFL('BEEFCATTLE',IP,SR) * 1.15;
PRODCOEFL('BEEFCATTLE','BEEFCFAC',SR)   = 1;
* Increase number of calves from beefcattle 10 %. More changes below
PRODCOEFL('BEEFCATTLE',IP,SR)           = PRODCOEFL('BEEFCATTLE',IP,SR) * 1.05;
PRODCOEFL('BEEFCATTLE','SLGHBEEF',SR)   = PRODCOEFL('BEEFCATTLE','SLGHBEEF',SR) * 1.10/1.05;
PRODCOEFL('BEEFCATTLE','BEEFCFAC',SR)   = 1;

*add BEEFCATTL2
PRODCOEFL('BEEFCATTL2',IP,SR)           = PRODCOEFL('BEEFCATTLE',IP,SR);
PRODCOEFL('BEEFCATTL2','SLGHBEEF',SR)   = PRODCOEFL('BEEFCATTLE','SLGHBEEF',SR)   +0.6*0.016;
PRODCOEFL('BEEFCATTL2','SILAGE',SR)     = PRODCOEFL('BEEFCATTLE','SILAGE',SR)     +0.6*0.230;
PRODCOEFL('BEEFCATTL2','GRASSPASTR',SR) = PRODCOEFL('BEEFCATTLE','GRASSPASTR',SR) +0.6*1.300;
PRODCOEFL('BEEFCATTL2','FEEDGRAIN',SR)  = PRODCOEFL('BEEFCATTLE','FEEDGRAIN',SR)  -0.6*0.855;
PRODCOEFL('BEEFCATTL2','OTHERFEED',SR)  = PRODCOEFL('BEEFCATTLE','OTHERFEED',SR)  -0.6*0.088;
PRODCOEFL('BEEFCATTL2','OTHRVARCST',SR) = PRODCOEFL('BEEFCATTLE','OTHRVARCST',SR) +0.6*1.010;
PRODCOEFL('BEEFCATTL2','CAPITAL',SR)    = PRODCOEFL('BEEFCATTLE','CAPITAL',SR)    +0.6*4.000;
PRODCOEFL('BEEFCATTL2','LABOR',SR)      = PRODCOEFL('BEEFCATTLE','LABOR',SR)      +0.6*0.005;
PRODCOEFL('BEEFCATTL2','BULLFAC',SR)    = PRODCOEFL('BEEFCATTLE','BULLFAC',SR)    +0.6*0.67;
PRODCOEFL('BEEFCATTL2','N-PROD',SR)     = PRODCOEFL('BEEFCATTLE','N-PROD',SR)    *1.05;
PRODCOEFL('BEEFCATTL2','P-PROD',SR)     = PRODCOEFL('BEEFCATTLE','P-PROD',SR)    *1.05;
PRODCOEFL('BEEFCATTL2','ACRMANURE',SR)  = PRODCOEFL('BEEFCATTLE','ACRMANURE',SR)  +0.6*0.127;
*Feedgrain, other feed and silage are adjusted to avoid negative feed grain and otter feed

*add methane from digestion livestock (matsmaltningen)
PRODCOEFL(DCOWS ,'CH4',SR)        = 0.1398;
PRODCOEFL('HEIFER','CH4',SR)      = 0.0255 + 0.0637 * 13/12;
PRODCOEFL('DAIRYBULL1','CH4',SR)  = 0.0255 + 0.0578 *  6/12;
PRODCOEFL('DAIRYBULL2','CH4',SR)  = 0.0255 + 0.0637 * 13/12;
PRODCOEFL('BEEFCATTLE','CH4',SR)  = 0.0915 + 0.0255*0.8*1.1 + 0.0637*0.2*1.1 + 0.0578*0.6*1.1* 6/12;
PRODCOEFL('BEEFCATTL2','CH4',SR)  = 0.0915 + 0.0255*0.8*1.1 + 0.0637*0.2*1.1 + 0.0637*0.6*1.1*13/12;
PRODCOEFL('SHEEP','CH4',SR)       = 0.008;
PRODCOEFL('HORSES','CH4',SR)      = 0.018;
PRODCOEFL('SOW1','CH4',SR)        = 0.0025;
PRODCOEFL('SLGHSWINE1','CH4',SR)  = 0.0015 * 0.38;
PRODCOEFL('ECOPIG','CH4',SR)      = 0.0025 + 0.0015*0.38*16;
PRODCOEFL(AS,'CH4',SR)            = PRODCOEFL(AS,'CH4',SR) * 1.11;

*add methane from manure livestock

PRODCOEFL(DCOWS ,'CH4',SR)        = PRODCOEFL(DCOWS ,'CH4',SR)        + 0.00852;
PRODCOEFL('HEIFER','CH4',SR)      = PRODCOEFL('HEIFER','CH4',SR)      + 0.003 + 0.00652 * 13/12;
PRODCOEFL('DAIRYBULL1','CH4',SR)  = PRODCOEFL('DAIRYBULL1','CH4',SR)  + 0.003 + 0.00652 *  6/12;
PRODCOEFL('DAIRYBULL2','CH4',SR)  = PRODCOEFL('DAIRYBULL2','CH4',SR)  + 0.003 + 0.00929 * 13/12;
PRODCOEFL('BEEFCATTLE','CH4',SR)  = PRODCOEFL('BEEFCATTLE','CH4',SR)
                                    + 0.00893 + (0.003*0.8 + 0.00652*0.2 + 0.00652*0.6* 6/12)*1.10;
PRODCOEFL('BEEFCATTL2','CH4',SR)  = PRODCOEFL('BEEFCATTL2','CH4',SR)
                                    + 0.00893 + (0.003*0.8 + 0.00652*0.2 + 0.00929*0.6*13/12)*1.10;
PRODCOEFL('SHEEP','CH4',SR)       = PRODCOEFL('SHEEP','CH4',SR)       + 0.00019;
PRODCOEFL('HORSES','CH4',SR)      = PRODCOEFL('HORSES','CH4',SR)      + 0.0014;
PRODCOEFL('SOW1','CH4',SR)        = PRODCOEFL('SOW1','CH4',SR)        + 0.00394;
PRODCOEFL('SLGHSWINE1','CH4',SR)  = PRODCOEFL('SLGHSWINE1','CH4',SR)  + 0.0015 * 0.38;
PRODCOEFL('ECOPIG','CH4',SR)      = PRODCOEFL('ECOPIG','CH4',SR)      + 0.00394 + 0.0015*0.38*16;
PRODCOEFL('POULTRY','CH4',SR)     = PRODCOEFL('POULTRY','CH4',SR)     + 0.08;
PRODCOEFL('EPOULTRY','CH4',SR)    = PRODCOEFL('EPOULTRY','CH4',SR)    + 0.08;
PRODCOEFL('CHICKEN','CH4',SR)     = PRODCOEFL('CHICKEN','CH4',SR)     + 0.04;

*add laughing gas from manure
PRODCOEFL(DCOWS ,'N2O',SR)        = 0.021/1000*36;
PRODCOEFL('HEIFER','N2O',SR)      = (0.017 + 0.018 * 13/12)/1000*11;
PRODCOEFL('DAIRYBULL1','N2O',SR)  = (0.017 + 0.019 *  6/12)/1000*11;
PRODCOEFL('DAIRYBULL2','N2O',SR)  = (0.017 + 0.022 * 13/12)/1000*11;
PRODCOEFL('BEEFCATTLE','N2O',SR)  = (0.017 + (0.017*0.8 + 0.018*0.2 + 0.19*0.6* 6/12))*1.1/1000*11;
PRODCOEFL('BEEFCATTL2','N2O',SR)  = (0.017 + (0.017*0.8 + 0.018*0.2 + 0.022*0.6*13/12))*1.1/1000*11;
PRODCOEFL('SHEEP','N2O',SR)       = 0.024/1000*2;
PRODCOEFL('HORSES','N2O',SR)      = 0.021/1000*20;
PRODCOEFL('SOW1','N2O',SR)        = 0.024/1000*3.7;
PRODCOEFL('SLGHSWINE1','N2O',SR)  = (0.022 * 0.38)/1000*3.7;
PRODCOEFL('ECOPIG','N2O',SR)      = (0.024 + 0.022*0.38*16)/1000*3.7;
PRODCOEFL('POULTRY','N2O',SR)     = 0.016/1000*1000;
PRODCOEFL('EPOULTRY','N2O',SR)    = 0.016/1000*1000;
PRODCOEFL('CHICKEN','N2O',SR)     = 0.008/1000*1000;
* dessa dat ar osakra. Bygger pa data fran Torben men uppraknade for rimlig niva enl SCB
PRODCOEFL(AS ,'N2O',SR)           = PRODCOEFL(AS ,'N2O',SR)*2;
* Higher loss at use for manure than for fertilizer

*add ammonium
PRODCOEFL(DCOWS ,'NH3',SR)        = 0.0377 * 1.051;
PRODCOEFL('HEIFER','NH3',SR)      = (0.0112 + 0.0056 * 13/12);
PRODCOEFL('DAIRYBULL1','NH3',SR)  = (0.0112 + 0.0056 *  6/12);
PRODCOEFL('DAIRYBULL2','NH3',SR)  = (0.0112 + 0.0056 * 13/12);
PRODCOEFL('BEEFCATTLE','NH3',SR)  = (0.0203 + (0.0056*0.8 + 0.0112*0.2 + 0.0112*0.6* 6/12))*1.1;
PRODCOEFL('BEEFCATTL2','NH3',SR)  = (0.0203 + (0.0056*0.8 + 0.0112*0.2 + 0.0112*0.6*13/12))*1.1;
PRODCOEFL('SHEEP','NH3',SR)       = 0.0203*12/63;
PRODCOEFL('HORSES','NH3',SR)      = 0.0203*50/63;
PRODCOEFL('SOW1','NH3',SR)        = 0.0123;
PRODCOEFL('SLGHSWINE1','NH3',SR)  = (0.004 * 0.38);
PRODCOEFL('ECOPIG','NH3',SR)      = (0.0123 + 0.004*0.38*16);
PRODCOEFL('POULTRY','NH3',SR)     = 0.640;
PRODCOEFL('EPOULTRY','NH3',SR)    = 0.640;
PRODCOEFL('CHICKEN','NH3',SR)     = 0.377;
* Data from Magnus Bong (from SCB), "Jordbruksstatistisk sammanstallning"
*   and "Databok driftsplanering 2009"
*PRODCOEFL(AS,'NH3',SR) = PRODCOEFL(AS,'NH3',SR)
*                         + (PRODCOEFL(AS,'NITROGEN',SR)+PRODCOEFL(AS,'ECON',SR)) *  0.0281;
*PRODCOEFC(AS,'NH3',SR) = PRODCOEFC(AS,'NH3',SR)
*                         + (PRODCOEFC(AS,'NITROGEN',SR)+PRODCOEFC(AS,'ECON',SR)) *  0.0281;                         
* Ammoniun from fertilizers (total N - N from manure). Loss of NH3 is 2,81 % of N
* Data from "Jordbruksstatistisk sammanstallning"

PRODCOEFL(DCOWS ,'MILK',SR)        = PRODCOEFL(DCOWS,'MILK',SR) * 1.0825 * 1.05;
PRODCOEFL(DCOWS,'FEEDGRAIN',SR)    = PRODCOEFL(DCOWS,'FEEDGRAIN',SR) * 1.0825 * 1.05;
PRODCOEFL(DCOWS,'OTHERFEED',SR)    = PRODCOEFL(DCOWS,'OTHERFEED',SR) * 1.0825 * 1.05;

*PRODCOEFL('SOW1','PIGLETS',SR)      = PRODCOEFL('SOW1','PIGLETS',SR) * 1.045;
*PRODCOEFL('SOW1','FEEDGRAIN',SR)    = PRODCOEFL('SOW1','FEEDGRAIN',SR) * 1.045;
*PRODCOEFL('SOW1','OTHERFEED',SR)    = PRODCOEFL('SOW1','OTHERFEED',SR) * 1.045;

PRODCOEFL('SLGHSWINE1','SLGHPORK',SR)     = PRODCOEFL('SLGHSWINE1','SLGHPORK',SR)  * 1.036;
PRODCOEFL('SLGHSWINE1','FEEDGRAIN',SR)    = PRODCOEFL('SLGHSWINE1','FEEDGRAIN',SR) * 1.036;
PRODCOEFL('SLGHSWINE1','OTHERFEED',SR)    = PRODCOEFL('SLGHSWINE1','OTHERFEED',SR) * 1.;

PRODCOEFL('BEEFCATTLE','LABOR',SR)    = PRODCOEFL('BEEFCATTLE','LABOR',SR) * 0.8;
PRODCOEFL('BEEFCATTL2','LABOR',SR)    = PRODCOEFL('BEEFCATTL2','LABOR',SR) * 0.8;

PRODCOEFC(AS,IP,SR01)     = PRODCOEFC(AS,IP,'SR001');
PRODCOEFC(AS,IP,SR02)     =(PRODCOEFC(AS,IP,'SR001')+PRODCOEFC(AS,IP,'SR001')+PRODCOEFC(AS,IP,'SR006'))/3;
PRODCOEFC(AS,IP,SR03)     = PRODCOEFC(AS,IP,'SR006');
PRODCOEFC(AS,IP,SR04a)    = PRODCOEFC(AS,IP,'SR009');
PRODCOEFC(AS,IP,SR04b)    = PRODCOEFC(AS,IP,'SR010');
PRODCOEFC(AS,IP,SR05)     = PRODCOEFC(AS,IP,'SR012');
PRODCOEFC(AS,IP,SR06a)    = PRODCOEFC(AS,IP,'SR012');
PRODCOEFC(AS,IP,SR06b)    = PRODCOEFC(AS,IP,'SR061');
PRODCOEFC(AS,IP,SR07a)    = PRODCOEFC(AS,IP,'SR026');
PRODCOEFC(AS,IP,SR07b)    = PRODCOEFC(AS,IP,'SR061');
PRODCOEFC(AS,IP,SR08)     = PRODCOEFC(AS,IP,'SR033');
PRODCOEFC(AS,IP,SR09)     = PRODCOEFC(AS,IP,'SR043');
PRODCOEFC(AS,IP,SR10)     =(PRODCOEFC(AS,IP,'SR061')+PRODCOEFC(AS,IP,'SR061')+PRODCOEFC(AS,IP,'SR043'))/3;
PRODCOEFC(AS,IP,SR11)     = PRODCOEFC(AS,IP,'SR061');
PRODCOEFC(AS,IP,SR12)     = PRODCOEFC(AS,IP,'SR061');
PRODCOEFC(AS,IP,SR0ssk)   = PRODCOEFC(AS,IP,'SR069');
PRODCOEFC(AS,IP,SR0gsk)   = PRODCOEFC(AS,IP,'SR069');
PRODCOEFC(AS,IP,SR0ss)    = PRODCOEFC(AS,IP,'SR074');
PRODCOEFC(AS,IP,SR0gns)   = PRODCOEFC(AS,IP,'SR076');
PRODCOEFC(AS,IP,SR0gmb)   = PRODCOEFC(AS,IP,'SR078');
PRODCOEFC(AS,IP,SR0gss)   = PRODCOEFC(AS,IP,'SR080');

PRODCOEFC2(AS,IP,NOO)   = PRODCOEFC2(AS,IP,'SR080');
PRODCOEFC2(AS,IP,NN)   = PRODCOEFC2(AS,IP,'SR078');
PRODCOEFC2(AS,IP,SSK)   = PRODCOEFC2(AS,IP,'SR076');
PRODCOEFC2(AS,IP,GSK)   = PRODCOEFC2(AS,IP,'SR050');
PRODCOEFC2(AS,IP,SS)   = PRODCOEFC2(AS,IP,'SR019');
PRODCOEFC2(AS,IP,GNS)   = PRODCOEFC2(AS,IP,'SR014');
PRODCOEFC2(AS,IP,GSK)   = PRODCOEFC2(AS,IP,'SR005');
PRODCOEFC2(AS,IP,GSS)   = PRODCOEFC2(AS,IP,'SR001');

PRODCOEFL(AS,IP,SR01)     = PRODCOEFL(AS,IP,'SR001');
PRODCOEFL(AS,IP,SR02)     =(PRODCOEFL(AS,IP,'SR001')+PRODCOEFL(AS,IP,'SR001')+PRODCOEFL(AS,IP,'SR006'))/3;
PRODCOEFL(AS,IP,SR03)     = PRODCOEFL(AS,IP,'SR006');
PRODCOEFL(AS,IP,SR04a)    = PRODCOEFL(AS,IP,'SR009');
PRODCOEFL(AS,IP,SR04b)    = PRODCOEFL(AS,IP,'SR010');
PRODCOEFL(AS,IP,SR05)     = PRODCOEFL(AS,IP,'SR012');
PRODCOEFL(AS,IP,SR06a)    = PRODCOEFL(AS,IP,'SR012');
PRODCOEFL(AS,IP,SR06b)    = PRODCOEFL(AS,IP,'SR061');
PRODCOEFL(AS,IP,SR07a)    = PRODCOEFL(AS,IP,'SR012');
PRODCOEFL(AS,IP,SR07b)    = PRODCOEFL(AS,IP,'SR061');
PRODCOEFL(AS,IP,SR08)     = PRODCOEFL(AS,IP,'SR033');
PRODCOEFL(AS,IP,SR09)     = PRODCOEFL(AS,IP,'SR043');
PRODCOEFL(AS,IP,SR10)     =(PRODCOEFL(AS,IP,'SR061')+PRODCOEFL(AS,IP,'SR061')+PRODCOEFL(AS,IP,'SR043'))/3;
PRODCOEFL(AS,IP,SR11)     = PRODCOEFL(AS,IP,'SR061');
PRODCOEFL(AS,IP,SR12)     = PRODCOEFL(AS,IP,'SR061');
PRODCOEFL(AS,IP,SR0ssk)   = PRODCOEFL(AS,IP,'SR074');
PRODCOEFL(AS,IP,SR0gsk)   = PRODCOEFL(AS,IP,'SR074');
PRODCOEFL(AS,IP,SR0ss)    = PRODCOEFL(AS,IP,'SR074');
PRODCOEFL(AS,IP,SR0gns)   = PRODCOEFL(AS,IP,'SR074');
PRODCOEFL(AS,IP,SR0gmb)   = PRODCOEFL(AS,IP,'SR080');
PRODCOEFL(AS,IP,SR0gss)   = PRODCOEFL(AS,IP,'SR080');

PARAMETER PRODCOEF(AS,IP,SR);
PRODCOEF(AS,IP,SR) = PRODCOEFC(AS,IP,SR) + PRODCOEFC2(AS,IP,SR) +PRODCOEFL(AS,IP,SR);

PRODCOEF('CHICKEN',IP,SR) = PRODCOEF('CHICKEN',IP,'SR001');

* Adjust production data for productivity development until year 2021 
* Average 2011-2014 divided by average 2005-2008 for milk and piglets milk as EU avgerage
PRODCOEF(CROPS ,'BREADGRAIN',SR)  = PRODCOEF(CROPS,'BREADGRAIN',SR) * 1.005**4;
PRODCOEF(CROPS ,'COARSGRAIN',SR)  = PRODCOEF(CROPS,'COARSGRAIN',SR) * 1.005**4;
PRODCOEF(CROPS ,'GSILAGE',SR)     = PRODCOEF(CROPS,'GSILAGE',SR)    * 1.005**4;
PRODCOEF(CROPS ,'MSILAGE',SR)     = PRODCOEF(CROPS,'MSILAGE',SR)    * 1.005**4;
PRODCOEF(CROPS ,'OILGRAIN',SR)    = PRODCOEF(CROPS,'OILGRAIN',SR)   * 1.005**4;
PRODCOEF(CROPS ,'POTATOES',SR)    = PRODCOEF(CROPS,'POTATOES',SR)   * 1.005**4;
PRODCOEF(CROPS ,'SUGARBEET',SR)   = PRODCOEF(CROPS,'SUGARBEET',SR)  * 1.005**4;
PRODCOEF(CROPS ,'SILAGE',SR)      = PRODCOEF(CROPS,'SILAGE',SR)     * 1.005**4;
PRODCOEF(CROPS ,'GRASSPASTR',SR)  = PRODCOEF(CROPS,'GRASSPASTR',SR) * 1.005**4;
PRODCOEF('SALIX','SALIXMJ',SR)    = PRODCOEF('SALIX','SALIXMJ',SR)  * 1.005**4;

PRODCOEF(GRAINS ,FERT,SR)  = PRODCOEF(GRAINS,FERT,SR) * 1.005**4;
PRODCOEF(OILGRAINS, FERT,SR)  = PRODCOEF(OILGRAINS, FERT,SR) * 1.005**4;
PRODCOEF('POTATO', FERT,SR)  = PRODCOEF('POTATO', FERT,SR) * 1.005**4;
PRODCOEF('SUGAR', FERT,SR)  = PRODCOEF('SUGAR', FERT,SR) * 1.005**4;

PRODCOEF(DCOWS ,'MILK',SR)        = PRODCOEF(DCOWS,'MILK',SR) * 1.010**4;
PRODCOEF(DCOWS,'FEEDGRAIN',SR)    = PRODCOEF(DCOWS,'FEEDGRAIN',SR) * 1.010**4;
PRODCOEF(DCOWS,'OTHERFEED',SR)    = PRODCOEF(DCOWS,'OTHERFEED',SR) * 1.010**4;
PRODCOEF('SOW1','PIGLETS',SR)     = PRODCOEF('SOW1','PIGLETS',SR)* 1.015**4;
PRODCOEF('POULTRY','EGG',SR)     = PRODCOEF('POULTRY','EGG',SR)* 1.010**4;
PRODCOEF('EPOULTRY','EGG',SR)     = PRODCOEF('EPOULTRY','EGG',SR)* 1.010**4;


* Adjust yields to productivity development, 0,5 % per year for yields and 
* Average 2011-2014 divided by average 2005-2008 for milk and piglets milk as EU avgerage
PRODCOEF(CROPS ,'BREADGRAIN',SR) $(LONGRUN2) = PRODCOEF(CROPS,'BREADGRAIN',SR) * 1.005**YRT;
PRODCOEF(CROPS ,'COARSGRAIN',SR) $(LONGRUN2) = PRODCOEF(CROPS,'COARSGRAIN',SR) * 1.005**YRT;
PRODCOEF(CROPS ,'GSILAGE',SR) $(LONGRUN2)    = PRODCOEF(CROPS,'GSILAGE',SR)    * 1.005**YRT;
PRODCOEF(CROPS ,'MSILAGE',SR) $(LONGRUN2)    = PRODCOEF(CROPS,'MSILAGE',SR)    * 1.005**YRT;
PRODCOEF(CROPS ,'OILGRAIN',SR) $(LONGRUN2)   = PRODCOEF(CROPS,'OILGRAIN',SR)   * 1.005**YRT;
PRODCOEF(CROPS ,'POTATOES',SR) $(LONGRUN2)   = PRODCOEF(CROPS,'POTATOES',SR)   * 1.005**YRT;
PRODCOEF(CROPS ,'SUGARBEET',SR) $(LONGRUN2)  = PRODCOEF(CROPS,'SUGARBEET',SR)  * 1.005**YRT;
PRODCOEF(CROPS ,'SILAGE',SR) $(LONGRUN2)     = PRODCOEF(CROPS,'SILAGE',SR)     * 1.005**YRT;
PRODCOEF(CROPS ,'GRASSPASTR',SR) $(LONGRUN2) = PRODCOEF(CROPS,'GRASSPASTR',SR) * 1.005**YRT;
PRODCOEF('SALIX','SALIXMJ',SR) $(LONGRUN2)   = PRODCOEF('SALIX','SALIXMJ',SR)  * 1.005**YRT;

PRODCOEF(GRAINS ,FERT,SR) $(LONGRUN2) = PRODCOEF(GRAINS,FERT,SR) * 1.005**YRT;
PRODCOEF(OILGRAINS, FERT,SR) $(LONGRUN2) = PRODCOEF(OILGRAINS, FERT,SR) * 1.005**YRT;
PRODCOEF('POTATO', FERT,SR) $(LONGRUN2) = PRODCOEF('POTATO', FERT,SR) * 1.005**YRT;
PRODCOEF('SUGAR', FERT,SR) $(LONGRUN2) = PRODCOEF('SUGAR', FERT,SR) * 1.005**YRT;

PRODCOEF(DCOWS ,'MILK',SR) $(LONGRUN2)       = PRODCOEF(DCOWS,'MILK',SR) * 1.005**YRT;
PRODCOEF(DCOWS,'FEEDGRAIN',SR) $(LONGRUN2)   = PRODCOEF(DCOWS,'FEEDGRAIN',SR) * 1.005**YRT;
PRODCOEF(DCOWS,'OTHERFEED',SR) $(LONGRUN2)   = PRODCOEF(DCOWS,'OTHERFEED',SR) * 1.005**YRT;
PRODCOEF(BEEFCAT,'SLGHBEEF',SR) $(LONGRUN2)  = PRODCOEF(BEEFCAT,'SLGHBEEF',SR) * 1.005**YRT;
PRODCOEF(BEEFCAT,'FEEDGRAIN',SR) $(LONGRUN2) = PRODCOEF(BEEFCAT,'FEEDGRAIN',SR) * 1.005**YRT;
PRODCOEF(BEEFCAT,'OTHERFEED',SR) $(LONGRUN2) = PRODCOEF(BEEFCAT,'OTHERFEED',SR) * 1.005**YRT;
PRODCOEF('SOW1','PIGLETS',SR) $(LONGRUN2)    = PRODCOEF('SOW1','PIGLETS',SR)* 1.015**YRT;
PRODCOEF('POULTRY','EGG',SR) $(LONGRUN2)     = PRODCOEF('POULTRY','EGG',SR)* 1.010**YRT;
PRODCOEF('EPOULTRY','EGG',SR) $(LONGRUN2)    = PRODCOEF('EPOULTRY','EGG',SR)* 1.010**YRT;
* Milk adjusted to OECD

*Adjust labour in new buildings
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



*Adjust coef for dairy and beef cattle production, update, lower meat price, capital feed and livestock, 
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
*PRODCOEF('BEEFCATTLE','OTHRVARCST',SR) = PRODCOEF('BEEFCATTLE','OTHRVARCST',SR) * 0.5;
PRODCOEF('BEEFCATTLE','LABOR',SR)      = PRODCOEF('BEEFCATTLE','LABOR',SR) * 0.75;
PRODCOEF('BEEFCATTL2','SILAGE',SR)     = PRODCOEF('BEEFCATTL2','SILAGE',SR) - 0.800;
PRODCOEF('BEEFCATTL2','OTHERFEED',SR)  = PRODCOEF('BEEFCATTL2','OTHERFEED',SR) * 0;
*PRODCOEF('BEEFCATTL2','OTHRVARCST',SR) = PRODCOEF('BEEFCATTL2','OTHRVARCST',SR) * 0.5;
PRODCOEF('BEEFCATTL2','LABOR',SR)      = PRODCOEF('BEEFCATTL2','LABOR',SR) * 0.75;
*PRODCOEF('BEEFCFEXN','MISCCOST',SR)    = PRODCOEF('BEEFCFEXN','MISCCOST',SR) * 2;

PRODCOEF('DAIRYBULL1','LABOR',SR)      = PRODCOEF('DAIRYBULL1','LABOR',SR) * 0.75;
PRODCOEF('DAIRYBULL2','LABOR',SR)      = PRODCOEF('DAIRYBULL2','LABOR',SR) * 0.75;


*PRODCOEF('FORAGE1','CAPITAL',SR)        = PRODCOEF('FORAGE1','CAPITAL',SR)  * 3.000;
*PRODCOEF('FORAGE2','CAPITAL',SR)        = PRODCOEF('FORAGE2','CAPITAL',SR)  * 3.000;
*PRODCOEF('FORAGE1','OTHRVARCST',SR)     = PRODCOEF('FORAGE1','OTHRVARCST',SR)  * 3.000;
*PRODCOEF('FORAGE2','OTHRVARCST',SR)     = PRODCOEF('FORAGE2','OTHRVARCST',SR)  * 3.000;
*PRODCOEF('FORAGE1','OTHRVARCST',SR)     = PRODCOEF('FORAGE1','OTHRVARCST',SR)  
*                                             - 0.200 * PRODCOEF('FORAGE1','SILAGE',SR);
*PRODCOEF('FORAGE2','OTHRVARCST',SR)     = PRODCOEF('FORAGE2','OTHRVARCST',SR)  
*                                             - 0.200 * PRODCOEF('FORAGE1','SILAGE',SR);
*PRODCOEF('FORAGE1','LABOR',SR)          = PRODCOEF('FORAGE1','LABOR',SR)  + 0.003;
*PRODCOEF('FORAGE2','LABOR',SR)          = PRODCOEF('FORAGE2','LABOR',SR)  + 0.003;

*PRODCOEF('GRAINSIL','GSILAGE',SR)       = PRODCOEF('GRAINSIL','GSILAGE',SR)  * 0.667;
*PRODCOEF('GRAINSIL','OTHRVARCST',SR)    = PRODCOEF('GRAINSIL','OTHRVARCST',SR)  * 3;
*PRODCOEF('GRAINSIL','LABOR',SR)         = PRODCOEF('GRAINSIL','LABOR',SR)  + 0.003;
*PRODCOEF('GRAINSIL','CAPITAL',SR)       = PRODCOEF('GRAINSIL','CAPITAL',SR)  * 3;

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
PRODCOEF('HORSES','HAY',SR)       = PRODCOEF('HORSES','SILAGE',SR)     * 0.75/0.84;
PRODCOEF('HORSES','SILAGE',SR)    = PRODCOEF('HORSES','SILAGE',SR)     * 0.25;

* Change other feed from quantity to value
*PRODCOEF(DCOWS,'OTHERFEED',SR)        = PRODCOEF(DCOWS,'OTHERFEED',SR)        * 2.2;
PRODCOEF('DAIRYBULL1','OTHERFEED',SR) = PRODCOEF('DAIRYBULL1','OTHERFEED',SR) * 2.2;
PRODCOEF('DAIRYBULL2','OTHERFEED',SR) = PRODCOEF('DAIRYBULL2','OTHERFEED',SR) * 2.2;
PRODCOEF('BEEFCATTLE','OTHERFEED',SR) = PRODCOEF('BEEFCATTLE','OTHERFEED',SR) * 2.2;
PRODCOEF('BEEFCATTL2','OTHERFEED',SR) = PRODCOEF('BEEFCATTL2','OTHERFEED',SR) * 2.2;

PRODCOEF('SHEEP','OTHERFEED',SR) = PRODCOEF('SHEEP','OTHERFEED',SR) * 2.9;

* Separate protein feed from otherfeed, back to volyme. Part remines (minerals etc)
PRODCOEF(LIVESTOCK,'PROTFEED',SR)  = PRODCOEF(LIVESTOCK,'OTHERFEED',SR) * 0.67 / 2.2;
PRODCOEF(LIVESTOCK,'OTHERFEED',SR) = PRODCOEF(LIVESTOCK,'OTHERFEED',SR) * 0.33;

*Adjust for over capacity of machinery
PRODCOEF('LAY','OTHRVARCST',SR)        = PRODCOEF('LAY','OTHRVARCST',SR) + 50*0.011;
*PRODCOEF('LONGLAY','OTHRVARCST',SR)    = PRODCOEF('LONGLAY','OTHRVARCST',SR) + 50*0.013;

* Make long lay a five year crop
*PRODCOEF('LONGLAY',IP,SR)    = PRODCOEF('LONGLAY',IP,SR)*0.8 + PRODCOEF('LAY',IP,SR)*0.2;

* Calculate coefficients for feed peas
PRODCOEF('FEEDPEAS','PEAS',SR)      = PRODCOEF('BARLEY','COARSGRAIN',SR)    * 0.70;
PRODCOEF('FEEDPEAS','NITROGEN',SR)  = 0;
PRODCOEF('FEEDPEAS','PHOSPHORUS',SR)= -PRODCOEF('FEEDPEAS','PEAS',SR) * 0.0036;
PRODCOEF('FEEDPEAS','POTASSIUM',SR) = -PRODCOEF('FEEDPEAS','PEAS',SR) * 0.0100;
PRODCOEF('FEEDPEAS','PESTICIDES',SR)= PRODCOEF('BARLEY','PESTICIDES',SR) * 2;
PRODCOEF('FEEDPEAS','POWER',SR)     = PRODCOEF('BARLEY','POWER',SR) + 0.002;
PRODCOEF('FEEDPEAS','OTHRVARCST',SR)= PRODCOEF('BARLEY','OTHRVARCST',SR) + 1.200;
PRODCOEF('FEEDPEAS','CAPITAL',SR)   = PRODCOEF('BARLEY','CAPITAL',SR);
PRODCOEF('FEEDPEAS','LABOR',SR)     = PRODCOEF('BARLEY','LABOR',SR) + 0.002;
PRODCOEF('FEEDPEAS','N-LEAKAGE',SR) = PRODCOEF('BARLEY','N-LEAKAGE',SR);
PRODCOEF('FEEDPEAS','P-LEAKAGE',SR) = PRODCOEF('BARLEY','P-LEAKAGE',SR);
PRODCOEF('FEEDPEASH',IP,SR)         = PRODCOEF('FEEDPEAS',IP,SR);
PRODCOEF('FEEDPEASH','PEAS',SR)     = PRODCOEF('FEEDPEAS','PEAS',SR) * 1.05;

* Separate pasture at forage from permanent pasture land
PRODCOEF(DCOWS,'GRASSPASTF',SR)        = PRODCOEF(DCOWS,'GRASSPASTR',SR)        * 0.75;
PRODCOEF('HEIFER','GRASSPASTF',SR)     = PRODCOEF('HEIFER','GRASSPASTR',SR)     * 0.25;
PRODCOEF('DAIRYBULL1','GRASSPASTF',SR) = PRODCOEF('DAIRYBULL1','GRASSPASTR',SR) * 0.4;
PRODCOEF('DAIRYBULL2','GRASSPASTF',SR) = PRODCOEF('DAIRYBULL2','GRASSPASTR',SR) * 0.4;
PRODCOEF('BEEFCATTLE','GRASSPASTF',SR) = PRODCOEF('BEEFCATTLE','GRASSPASTR',SR) * 0.2;
PRODCOEF('BEEFCATTL2','GRASSPASTF',SR) = PRODCOEF('BEEFCATTL2','GRASSPASTR',SR) * 0.15;
PRODCOEF('SHEEP','GRASSPASTF',SR)      = PRODCOEF('SHEEP','GRASSPASTR',SR)      * 0.2;
PRODCOEF('HORSES','GRASSPASTF',SR)     = PRODCOEF('HORSES','GRASSPASTR',SR)     * 0.5;


* Make 25 percent of ray to feed grain quality and include price difference to wheat
PRODCOEF('W-RAY','COARSGRAIN',SR) = PRODCOEF('W-RAY','BREADGRAIN',SR) * 0.25;  
PRODCOEF('W-RAY','BREADGRAIN',SR) = PRODCOEF('W-RAY','BREADGRAIN',SR) * 0.75;  
PRODCOEF('W-RAY','MISCCOST',SR)  = PRODCOEF('W-RAY','MISCCOST',SR) 
        -PRODCOEF('W-RAY','BREADGRAIN',SR) * 0.35 -PRODCOEF('W-RAY','COARSGRAIN',SR) * 0.10;  

* Separate seed from other variable costs
PRODCOEF('W-RAPE','OILGRSEED',SR)  = 0.00033;
PRODCOEF('W-RAPE','OTHRVARCST',SR) = PRODCOEF('W-RAPE','OTHRVARCST',SR) - 0.766;
PRODCOEF('S-RAPE','OILGRSEED',SR)  = 0.00071;
PRODCOEF('S-RAPE','OTHRVARCST',SR) = PRODCOEF('S-RAPE','OTHRVARCST',SR) - 1.714;
PRODCOEF('FEEDPEAS','PEASSEED',SR) = 0.015;
PRODCOEF('FEEDPEAS','OTHRVARCST',SR) = PRODCOEF('FEEDPEAS','OTHRVARCST',SR) - 1.800 + 0.300;
PRODCOEF('FEEDPEASH','PEASSEED',SR) = 0.015;
PRODCOEF('FEEDPEASH','OTHRVARCST',SR) = PRODCOEF('FEEDPEASH','OTHRVARCST',SR) - 1.800 + 0.300;
PRODCOEF('SUGAR','SUGARBSEED',SR)   = 0.00104;
PRODCOEF('SUGAR','OTHRVARCST',SR) = PRODCOEF('SUGAR','OTHRVARCST',SR) - 2.602;
PRODCOEF('POTATO','POTATOSEED',SR)  = 2.500/ 0.995**YRT;
*PRODCOEF('POTATO','OTHRVARCST',SR) = PRODCOEF('POTATO','OTHRVARCST',SR) - 18.975 ;
* Data from Hush 2023. SEED seemes not to be included in other costs for potatoes
* 0.300 added to feedpeas to aviod negetive "other costs"
 
* Include wheat in subreg 4a
PRODCOEF('W-WHEAT',IP,SR04a) = PRODCOEF('W-WHEAT',IP,'SR010');  

* Make acreage of long laying forage standard in subreg 1, 2, 3, 4a and 7b
PRODCOEF('FORAGE1','SILAGE',SR1TO4a)    = PRODCOEF('FORAGE1','SILAGE',SR1TO4a)    /0.80;
*PRODCOEF('FORAGE1','NITROGEN',SR1TO4a)  = PRODCOEF('FORAGE1','NITROGEN',SR1TO4a)  /0.80;
*PRODCOEF('FORAGE1','PHOSPHORUS',SR1TO4a)= PRODCOEF('FORAGE1','PHOSPHORUS',SR1TO4a)/0.80;
*PRODCOEF('FORAGE1','POTASSIUM',SR1TO4a) = PRODCOEF('FORAGE1','POTASSIUM',SR1TO4a) /0.80;

PRODCOEF('FORAGE2','SILAGE',SR1TO4a)    = PRODCOEF('FORAGE2','SILAGE',SR1TO4a)    /0.80;
PRODCOEF('FORAGE2','GRASSPASTR',SR1TO4a)= PRODCOEF('FORAGE2','GRASSPASTR',SR1TO4a)/0.80;
*PRODCOEF('FORAGE2','NITROGEN',SR1TO4a)  = PRODCOEF('FORAGE2','NITROGEN',SR1TO4a)  /0.80;
*PRODCOEF('FORAGE2','PHOSPHORUS',SR1TO4a)= PRODCOEF('FORAGE2','PHOSPHORUS',SR1TO4a)/0.80;
*PRODCOEF('FORAGE2','POTASSIUM',SR1TO4a) = PRODCOEF('FORAGE2','POTASSIUM',SR1TO4a) /0.80;

PRODCOEF('PASTURE1','GRASSPASTR',SR1TO4a)= PRODCOEF('PASTURE1','GRASSPASTR',SR1TO4a)/0.80;
PRODCOEF('PASTURE2','GRASSPASTR',SR1TO4a)= PRODCOEF('PASTURE2','GRASSPASTR',SR1TO4a)/0.80;
PRODCOEF('PPASTR','GRASSPASTR',SR1TO4a)  = PRODCOEF('PPASTR','GRASSPASTR',SR1TO4a)  /0.80;

PRODCOEF('FORAGE1','SILAGE',SR07b)    = PRODCOEF('FORAGE1','SILAGE',SR07b)    /0.90;
*PRODCOEF('FORAGE1','NITROGEN',SR07b)  = PRODCOEF('FORAGE1','NITROGEN',SR07b)  /0.90;
*PRODCOEF('FORAGE1','PHOSPHORUS',SR07b)= PRODCOEF('FORAGE1','PHOSPHORUS',SR07b)/0.90;
*PRODCOEF('FORAGE1','POTASSIUM',SR07b) = PRODCOEF('FORAGE1','POTASSIUM',SR07b) /0.90;

PRODCOEF('FORAGE2','SILAGE',SR07b)    = PRODCOEF('FORAGE2','SILAGE',SR07b)    /0.90;
PRODCOEF('FORAGE2','GRASSPASTR',SR07b)= PRODCOEF('FORAGE2','GRASSPASTR',SR07b)/0.90;
*PRODCOEF('FORAGE2','NITROGEN',SR07b)  = PRODCOEF('FORAGE2','NITROGEN',SR07b)  /0.90;
*PRODCOEF('FORAGE2','PHOSPHORUS',SR07b)= PRODCOEF('FORAGE2','PHOSPHORUS',SR07b)/0.90;
*PRODCOEF('FORAGE2','POTASSIUM',SR07b) = PRODCOEF('FORAGE2','POTASSIUM',SR07b) /0.90;

PRODCOEF('PASTURE1','GRASSPASTR',SR07b)= PRODCOEF('PASTURE1','GRASSPASTR',SR07b)/0.90;
PRODCOEF('PASTURE2','GRASSPASTR',SR07b)= PRODCOEF('PASTURE2','GRASSPASTR',SR07b)/0.90;
PRODCOEF('PPASTR','GRASSPASTR',SR07b)  = PRODCOEF('PPASTR','GRASSPASTR',SR07b)  /0.90;

* Calculate coefficients for long laying forage, extensive forage and new forage
PRODCOEF('FORAGE3',IP,SR)          = PRODCOEF('FORAGE1',IP,SR);
PRODCOEF('FORAGE3','SILAGE',SR)    = PRODCOEF('FORAGE1','SILAGE',SR)    * 0.80;
*PRODCOEF('FORAGE3','NITROGEN',SR)  = PRODCOEF('FORAGE1','NITROGEN',SR)  * 0.80;
*PRODCOEF('FORAGE3','PHOSPHORUS',SR)= PRODCOEF('FORAGE1','PHOSPHORUS',SR)* 0.80;
*PRODCOEF('FORAGE3','POTASSIUM',SR) = PRODCOEF('FORAGE1','POTASSIUM',SR) * 0.80;
PRODCOEF('FORAGE3','LABOR',SR)     = PRODCOEF('FORAGE1','LABOR',SR)     * 0.80;
PRODCOEF('FORAGE3','POWER',SR)     = PRODCOEF('FORAGE1','POWER',SR)     * 0.80;
PRODCOEF('FORAGE3','OTHRVARCST',SR)= PRODCOEF('FORAGE1','OTHRVARCST',SR)* 0.80;
PRODCOEF('FORAGE3','CAPITAL',SR)   = PRODCOEF('FORAGE1','CAPITAL',SR)   * 0.80;
PRODCOEF('FORAGE3','N-LEAKAGE',SR) = PRODCOEF('PASTURE2','N-LEAKAGE',SR);
PRODCOEF('FORAGE3','P-LEAKAGE',SR) = PRODCOEF('PASTURE2','P-LEAKAGE',SR);

PRODCOEF('FORAGE4',IP,SR)          = PRODCOEF('FORAGE1',IP,SR);
PRODCOEF('FORAGE4','SILAGE',SR)    = PRODCOEF('FORAGE1','SILAGE',SR)    * 0.50;
*PRODCOEF('FORAGE4','NITROGEN',SR)  = PRODCOEF('FORAGE1','NITROGEN',SR)  * 0.50;
*PRODCOEF('FORAGE4','PHOSPHORUS',SR)= PRODCOEF('FORAGE1','PHOSPHORUS',SR)* 0.50;
*PRODCOEF('FORAGE4','POTASSIUM',SR) = PRODCOEF('FORAGE1','POTASSIUM',SR) * 0.50;
PRODCOEF('FORAGE4','LABOR',SR)     = PRODCOEF('FORAGE1','LABOR',SR)     * 0.50;
PRODCOEF('FORAGE4','POWER',SR)     = PRODCOEF('FORAGE1','POWER',SR)     * 0.50;
PRODCOEF('FORAGE4','OTHRVARCST',SR)= PRODCOEF('FORAGE1','OTHRVARCST',SR)* 0.50;
PRODCOEF('FORAGE4','CAPITAL',SR)   = PRODCOEF('FORAGE1','CAPITAL',SR)   * 0.50;
PRODCOEF('FORAGE4','N-LEAKAGE',SR) = PRODCOEF('PPASTR','N-LEAKAGE',SR);
PRODCOEF('FORAGE4','P-LEAKAGE',SR) = PRODCOEF('PPASTR','P-LEAKAGE',SR);

PRODCOEF('NEWFOR','LABOR',SR)      = PRODCOEF('BARLEY','LABOR',SR) * 0.5;
PRODCOEF('NEWFOR','POWER',SR)      = PRODCOEF('BARLEY','POWER',SR) * 0.5;
PRODCOEF('NEWFOR','N-LEAKAGE',SR)  = PRODCOEF('FORAGE1','N-LEAKAGE',SR);
PRODCOEF('NEWFOR','P-LEAKAGE',SR)  = PRODCOEF('FORAGE1','P-LEAKAGE',SR);

* Increase costs for silage compared to LES data
*PRODCOEF(FORAGES,'OTHRVARCST',SR) = PRODCOEF(FORAGES,'OTHRVARCST',SR) -
*                                      0.200 * PRODCOEF(FORAGES,'SILAGE',SR);
*PRODCOEF('GRAINSIL','OTHRVARCST',SR) = PRODCOEF('GRAINSIL','OTHRVARCST',SR) -
*                                      0.200 * PRODCOEF('GRAINSIL','GSILAGE',SR);

* Include extra labor for feeding with silage
*PRODCOEF(FORAGES,'LABOR',SR) = PRODCOEF(FORAGES,'LABOR',SR) -
*                                      0.001 * PRODCOEF(FORAGES,'SILAGE',SR);
*PRODCOEF('GRAINSIL','LABOR',SR) = PRODCOEF('GRAINSIL','LABOR',SR) -
*                                      0.001 * PRODCOEF('GRAINSIL','GSILAGE',SR);
*PRODCOEF('MAJSSIL','LABOR',SR) = PRODCOEF('MAJSSIL','LABOR',SR) -
*                                      0.001 * PRODCOEF('MAJSSIL','MSILAGE',SR);
*PRODCOEF(FORAGES,'LABOR2',SR)    = -0.001 * PRODCOEF(FORAGES,'SILAGE',SR);
*PRODCOEF('GRAINSIL','LABOR2',SR) = -0.001 * PRODCOEF('GRAINSIL','GSILAGE',SR);
*PRODCOEF('MAJSSIL','LABOR2',SR)  = -0.001 * PRODCOEF('MAJSSIL','MSILAGE',SR);

* Adjust milk, forage and pasture grass yields for losses
*PRODCOEF(DCOWS,'MILK',SR)            = PRODCOEF(DCOWS,'MILK',SR)      * 0.965;
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
*PRODCOEF(FEEDACR,'NITROGEN',SR)$LONGRUN2    = PRODCOEF(FEEDACR,'NITROGEN',SR) ;
*PRODCOEF(FEEDACR,'PHOSPHORUS',SR)$LONGRUN2  = PRODCOEF(FEEDACR,'PHOSPHORUS',SR) ;
*PRODCOEF(FEEDACR,'POTASSIUM',SR)$LONGRUN2   = PRODCOEF(FEEDACR,'POTASSIUM',SR) ;
PRODCOEF('SALIX'   ,'NITROGEN',SR) = 0.070/3 - PRODCOEF('SALIX','SALIXMJ',SR)/4.4 * 0.005;
PRODCOEF('SALIX'   ,'PHOSPHORUS',SR) = -PRODCOEF('SALIX','SALIXMJ',SR)/4.4  * 0.00083;
PRODCOEF('SALIX'   ,'POTASSIUM',SR) = -PRODCOEF('SALIX','SALIXMJ',SR)/4.4  * 0.0027;

* Increase use of potassium for better matching, inefficient use
*PRODCOEF(FEEDACR,'POTASSIUM',SR)   = PRODCOEF(FEEDACR,'POTASSIUM',SR)  * 1.25;

* Include differences due to land quality
PRODCOEF('PPASTRH',IP,SR) = PRODCOEF('PPASTR',IP,SR);
PRODCOEF('PPASTR','GRASSPASTR',SR) = PRODCOEF('PPASTR','GRASSPASTR',SR) * 0.5;

PRODCOEF('PPASTR','USEPASTR',SR)   = -PRODCOEF('PPASTR','GRASSPASTR',SR) -0.001;
PRODCOEF('PPASTRH','USEPASTR',SR)  = -PRODCOEF('PPASTRH','GRASSPASTR',SR) -0.001;

*PRODCOEF('PPASTRB',IP,SR)   = PRODCOEF('PPASTR',IP,SR);
PRODCOEF('PPASTRT',IP,SR)   = PRODCOEF('PPASTR',IP,SR);
*PRODCOEF('PPASTRHB',IP,SR)  = PRODCOEF('PPASTRH',IP,SR);
PRODCOEF('PPASTRHT',IP,SR)  = PRODCOEF('PPASTRH',IP,SR);

* Ad costs for environmental support
PRODCOEF('PPASTRB','LABOR',SR)    = PRODCOEF('PPASTRB','LABOR',SR)  + 0.002;
PRODCOEF('PPASTRHB','LABOR',SR)   = PRODCOEF('PPASTRHB','LABOR',SR) + 0.002;
*PRODCOEF('PPASTRB','LABOR2',SR)   = PRODCOEF('PPASTRB','LABOR2',SR) + 0.002;
*PRODCOEF('PPASTRHB','LABOR2',SR)  = PRODCOEF('PPASTRHB','LABOR2',SR)+ 0.002;
PRODCOEF('PPASTRB','POWER',SR)    = PRODCOEF('PPASTRB','POWER',SR)  + 0.001;
PRODCOEF('PPASTRHB','POWER',SR)   = PRODCOEF('PPASTRHB','POWER',SR) + 0.001;
PRODCOEF('PPASTRB','OTHRVARCST',SR)  = PRODCOEF('PPASTRB','OTHRVARCST',SR)  + 0.375;
PRODCOEF('PPASTRHB','OTHRVARCST',SR) = PRODCOEF('PPASTRHB','OTHRVARCST',SR) + 0.750;
*375 (750) kr per hektar for minskad tillvaxt mm, half vid lag avk pga farre djur 

PRODCOEF('PPASTRT','LABOR',SR)    = PRODCOEF('PPASTRT','LABOR',SR)  + 0.004;
PRODCOEF('PPASTRHT','LABOR',SR)   = PRODCOEF('PPASTRHT','LABOR',SR) + 0.004;
*PRODCOEF('PPASTRT','LABOR2',SR)   = PRODCOEF('PPASTRT','LABOR2',SR) + 0.004;
*PRODCOEF('PPASTRHT','LABOR2',SR)  = PRODCOEF('PPASTRHT','LABOR2',SR)+ 0.004;
PRODCOEF('PPASTRT','POWER',SR)    = PRODCOEF('PPASTRT','POWER',SR)  + 0.002;
PRODCOEF('PPASTRHT','POWER',SR)   = PRODCOEF('PPASTRHT','POWER',SR) + 0.002;
PRODCOEF('PPASTRT','OTHRVARCST',SR)    = PRODCOEF('PPASTRT','OTHRVARCST',SR)  + 0.750;
PRODCOEF('PPASTRHT','OTHRVARCST',SR)   = PRODCOEF('PPASTRHT','OTHRVARCST',SR) + 1.500;
*750 (1 500) kr per hektar for minskad tillvaxt mm, half vid lag avk pga farre djur 
PRODCOEF('PPASTRFOR','LABOR',SR1TO4a)    = PRODCOEF('PPASTRFOR','LABOR',SR1TO4a)  - 0.001;
*PRODCOEF('PPASTRFOR','LABOR2',SR1TO4a)   = PRODCOEF('PPASTRFOR','LABOR2',SR1TO4a) - 0.001;
PRODCOEF('PPASTRFOR','POWER',SR1TO4a)    = PRODCOEF('PPASTRFOR','POWER',SR1TO4a)  - 0.001;

*Include top values
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
* Aterlagd kostnadsokning for minskad tillvaxt pga farre djur

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
* PPM factor inkluded based on sscenario 2021

PRODCOEF('PPASTRMEAD','SILAGE',SR)     = PRODCOEF('PPASTR','GRASSPASTR',SR);
PRODCOEF('PPASTRMEAD','LABOR',SR) = -PRODCOEF('PPASTRMEAD','SILAGE',SR) * 40/1000;
PRODCOEF('PPASTRMEAD','GRASSPASTR',SR) = 0;
PRODCOEF('PPASTRMEAD','USEPASTR',SR)   = 0;

* Reduced demand on grazing for farm support
PRODCOEF('PPASTRB','USEPASTR',SR)   = PRODCOEF('PPASTR','USEPASTR',SR) * 0.65;
PRODCOEF('PPASTRHB','USEPASTR',SR)  = PRODCOEF('PPASTRH','USEPASTR',SR) * 0.65;
PRODCOEF('PPASTR','USEPASTR',SR)   = PRODCOEF('PPASTR','USEPASTR',SR) * 0.25;
PRODCOEF('PPASTRH','USEPASTR',SR)  = PRODCOEF('PPASTRH','USEPASTR',SR) * 0.25;
*PRODCOEF('PPASTRT','USEPASTR',SR)   = PRODCOEF('PPASTRT','USEPASTR',SR) * 0.5;
*PRODCOEF('PPASTRHT','USEPASTR',SR)  = PRODCOEF('PPASTRHT','USEPASTR',SR) * 0.5;

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
*PRODCOEF('SPAPASTRB','PRMPASTB',SR) = 1; 
PRODCOEF('SPAPASTRT','PRMPASTT',SR) = 1; 
PRODCOEF('SPAPASTRH','PRMPASTH',SR) = 1; 
*PRODCOEF('SPAPASTRHB','PRMPASTHB',SR) = 1; 
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

*Transfere cropland to pasture with high production and basic support
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
PRODCOEF('FEEDPEASH','CBONDING',SR) = -0.200;
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

* Include land quality differences
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
PRODCOEF('OTHERCROPS','N-LEAKAGE',SR) = PRODCOEF('BARLEY','N-LEAKAGE',SR);  
PRODCOEF('OTHERCROPS','P-LEAKAGE',SR) = PRODCOEF('BARLEY','P-LEAKAGE',SR);  

PRODCOEF('ICR','ICRPR',SR) = -1;  
PRODCOEF('ICR',I,SR) = PRODCOEF('BARLEY',I,SR);  
PRODCOEF('ICR','N-LEAKAGE',SR) = PRODCOEF('BARLEY','N-LEAKAGE',SR);  
PRODCOEF('ICR','P-LEAKAGE',SR) = PRODCOEF('BARLEY','P-LEAKAGE',SR);  


PRODCOEF('NOUSE','UNDEFUSE',SR) = -1;  
PRODCOEF('NOUSE','OTHRVARCST',SR) = 0.500;  
PRODCOEF('NOUSE','N-LEAKAGE',SR) = PRODCOEF('LONGLAY','N-LEAKAGE',SR);  
PRODCOEF('NOUSE','P-LEAKAGE',SR) = PRODCOEF('LONGLAY','P-LEAKAGE',SR);  

PRODCOEF('SHEEP','MINSHEEP',SR) = -1;
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
*PRODCOEF('SPAPASTRB','YIELDRIRE1',SR)  = PRODCOEF('PPASTRB','GRASSPASTR',SR);
PRODCOEF('SPAPASTRT','YIELDRIRE1',SR)  = PRODCOEF('PPASTRT','GRASSPASTR',SR);
PRODCOEF('SPAPASTRH','YIELDRIRE1',SR)  = PRODCOEF('PPASTRH','GRASSPASTR',SR);
*PRODCOEF('SPAPASTRHB','YIELDRIRE1',SR) = PRODCOEF('PPASTRHB','GRASSPASTR',SR);
PRODCOEF('SPAPASTRHT','YIELDRIRE1',SR) = PRODCOEF('PPASTRHT','GRASSPASTR',SR);
PRODCOEF('SPARESIL','YIELDRIRE1',SR)   = -1;
PRODCOEF('SPARESIL','YIELDRIRE2',SR)   = -1;
PRODCOEF('SPARESIL','SILAGE',SR)       = 1;

* Max 20 percent yieldrisk with subsidies etc.
PRODCOEF(AS,'YIELDRIRE3',SR) = -PRODCOEF(AS,'YIELDRIRE2',SR);

PRODCOEF('SPAREFOR','N-LEAKAGE',SR)   = PRODCOEF('PASTURE2','N-LEAKAGE',SR);
PRODCOEF('SPAREFOR','P-LEAKAGE',SR)   = PRODCOEF('PASTURE2','P-LEAKAGE',SR);
*PRODCOEF('SPAPASTR','N-LEAKAGE',SR) = PRODCOEF('PASTURE2','N-LEAKAGE',SR);
*PRODCOEF('SPAPASTRB','N-LEAKAGE',SR) = PRODCOEF('PASTURE2','N-LEAKAGE',SR);
*PRODCOEF('SPAPASTRT','N-LEAKAGE',SR) = PRODCOEF('PASTURE2','N-LEAKAGE',SR);
*PRODCOEF('SPAPASTRH','N-LEAKAGE',SR) = PRODCOEF('PASTURE2','N-LEAKAGE',SR);
*PRODCOEF('SPAPASTRHB','N-LEAKAGE',SR) = PRODCOEF('PASTURE2','N-LEAKAGE',SR);
*PRODCOEF('SPAPASTRHT','N-LEAKAGE',SR) = PRODCOEF('PASTURE2','N-LEAKAGE',SR);
 
* Potential for general acreage subsidies

PRODCOEF(CROPS,'GACRSUB',SR)            = -1;  
PRODCOEF('COVERCROP','GACRSUB',SR)      = 0;  
PRODCOEF('CATCHCROP','GACRSUB',SR)      = 0;  
PRODCOEF('SPRINGTILL','GACRSUB',SR)     = 0;  
PRODCOEF('ECOPIG','GACRSUB',SR)         = -0.4;  
PRODCOEF('EPOULTRY','GACRSUB',SR)       = -2;  
PRODCOEF('PPASTR','GACRSUB',SR)     = -1;  
*PRODCOEF('PPASTRB','GACRSUB',SR)    = -1;  
PRODCOEF('PPASTRT','GACRSUB',SR)    = -1;  
PRODCOEF('PPASTRH','GACRSUB',SR)    = -1;  
PRODCOEF('PPASTRN','GACRSUB',SR)    = -1;  
*PRODCOEF('PPASTRHB','GACRSUB',SR)   = -1;  
PRODCOEF('PPASTRHT','GACRSUB',SR)   = -1;  
PRODCOEF('PPASTRHN','GACRSUB',SR)   = -1;  
PRODCOEF('PPASTRALV','GACRSUB',SR)  = 0;  
PRODCOEF('PPASTRFOR','GACRSUB',SR)  = 0;  
PRODCOEF('PPASTRMOS','GACRSUB',SR)  = 0;  
PRODCOEF('PPASTRLOW','GACRSUB',SR)  = 0;  
PRODCOEF('PPASTRCHAL','GACRSUB',SR) = 0;  
PRODCOEF('PPASTRMEAD','GACRSUB',SR) = -1;  


PRODCOEF(GRAINS,'COMP4SUB',SR1TO12)      = -1;  
PRODCOEF(OILGRAINS,'COMP4SUB',SR1TO12)   = -1;  
PRODCOEF('POTATO','COMP4SUB',SR1TO12)    = -1;  
PRODCOEF('FEEDPEAS','COMP4SUB',SR1TO12)  = -1;  
PRODCOEF('FEEDPEASH','COMP4SUB',SR1TO12) = -1;  
PRODCOEF(FORAGES,'FORSUB',SR)       = -1*0;  
PRODCOEF(FORAGES,'FORSUB',SR1TO12)  =  0;  

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
PRODCOEF(DCOWS,'COMPSUBL',SR1TO12)        = -1.0 - 0.33*1.8*0.6;  
PRODCOEF('DAIRYBULL1','COMPSUBL',SR1TO12) = -0.6 * 1.225;  
PRODCOEF('DAIRYBULL2','COMPSUBL',SR1TO12) = -0.6 * 1.9;  
PRODCOEF('SLGHHEIFER','COMPSUBL',SR1TO12) = -0.6 * 1.9;  
PRODCOEF('BEEFCATTLE','COMPSUBL',SR1TO12) = -1.0 - 0.2*1.1*1.8*0.6 - 0.6*1.1*1.225*0.6;
PRODCOEF('BEEFCATTL2','COMPSUBL',SR1TO12) = -1.0 - 0.2*1.1*1.8*0.6 - 0.6*1.1*1.225*0.6;
PRODCOEF('SHEEP','COMPSUBL',SR1TO12)      = -0.20;
PRODCOEF(FEEDACR,'COMPSUB',SR1TO12)       = -1;
PRODCOEF('PPASTRFOR','COMPSUB',SR1TO12)     = 0;
PRODCOEF('PPASTRMOS','COMPSUB',SR1TO12)     = 0;
PRODCOEF('PPASTRLOW','COMPSUB',SR1TO12)     = 0;
PRODCOEF('PPASTRALV','COMPSUB',SR1TO12)     = 0;
PRODCOEF('PPASTRCHAL','COMPSUB',SR1TO12)    = 0;
PRODCOEF('PPASTRMEAD','COMPSUB',SR1TO12)    = 0;
PRODCOEF('GRAINSIL','COMPSUB',SR1TO12)      = -1;
PRODCOEF('MAJSSIL','COMPSUB',SR1TO12)       = -1;

* Potential for national subsidies
TABLE NSUB(AS,SR) 
*----------------------------------------------------------------------------------------------------

* Activity.. Suport region...........................................................................
*----------------------------------------------------------------------------------------------------
*                SR01          SR02          SR03          SR04          SR05
              SR001*SR002   SR003*SR005   SR006*SR008   SR009*SR011   SR012*SR015
*----------------------------------------------------------------------------------------------------
SOW1           -0.930        -0.930        -0.930        -0.860        -0.850
SLGHSWINE1     -0.200        -0.200        -0.190        -0.180        -0.160
POULTRY        -21.30        -21.30        -21.30        -15.90        -7.300
POTATO         -4.400        -4.100        -3.900        -3.200        -2.100;
*----------------------------------------------------------------------------------------------------
PRODCOEF(AS,'NATSUB',SR1TO5) = PRODCOEF(AS,'NATSUB',SR1TO5) + NSUB(AS,SR1TO5);


* Include Eco Schemes
*PRODCOEF('W-WHEAT','ES1',SR0)   = -1;  
*PRODCOEF('W-RAPE','ES1',SR0)    = -1;  
*PRODCOEF('W-BARLEY','ES1',SR0)  = -1;  
*PRODCOEF('BARLEY','ES1',SR0)    = -1;  
*PRODCOEF('OATS','ES1',SR0)      = -1;  

*PRODCOEF(GRAINS,'ES2',SR0)      = -1;  
*PRODCOEF(OILGRAINS,'ES2',SR0)   = -1;  
*PRODCOEF('GRAINSIL','ES2',SR0)  = 0;  
*PRODCOEF('MAJSSIL','ES2',SR0)   = 0;  

PRODCOEF(CROPS4,'ES3',SR0)      = -0.90;
PRODCOEF(CROPS4,'OTHRVARCST',SR0) = PRODCOEF(CROPS4,'OTHRVARCST',SR0) + 0.100*0.90; 
PRODCOEF(CROPS4,FERT,SR0) = PRODCOEF(CROPS4,FERT,SR0) * (1-0.01*0.90);
PRODCOEF(CROPS4,'N-LEAKAGE',SR0) = PRODCOEF(CROPS4,'N-LEAKAGE',SR0) * (1-0.01*0.90);
PRODCOEF(CROPS4,'P-LEAKAGE',SR0) = PRODCOEF(CROPS4,'P-LEAKAGE',SR0) * (1-0.01*0.90);
* 75 % areage are asumed to apply. Extra cost 100 SEK per hektar. N,P & K reduced 1 %.

PRODCOEF('COVERCROP','ES4',SR) = -1;  
*PRODCOEF('ECOVERCROP','ES4',SR)= -1;  
PRODCOEF('COVERCROP',IP,SR1TO5) =  0;  
*PRODCOEF('ECOVERCROP',IP,SR1TO5)=  0;
PRODCOEF('CATCHCROP','ES5',SR0)  = -1;  
*PRODCOEF('ECATCHCROP','ES5',SR0) = -1;  
PRODCOEF('SPRINGTILL','ES6',SR0) = -1;  
*PRODCOEF('ESPRINGTIL','ES6',SR0) = -1;  

* Adjust to general productivity development until 2021 for all inputs, 1,5 % for 
* labor and 1,5 % for power
PRODCOEF(AS,VARI,SR)  = PRODCOEF(AS,VARI,SR) * 0.995**4;
PRODCOEF(AS,'LABOR',SR)  = PRODCOEF(AS,'LABOR',SR) * 0.985**4/0.995**4;
PRODCOEF(AS,'LABOR2',SR) = PRODCOEF(AS,'LABOR2',SR)* 0.985**4/0.995**4;
PRODCOEF(AS,'POWER',SR)  = PRODCOEF(AS,'POWER',SR) * 0.985**4/0.995**4;

PRODCOEF(LIVESTOCK,FEEDP,SR)  = PRODCOEF(LIVESTOCK,FEEDP,SR) * 0.995**4;

*Less productivity development in LFA regions, more in other until year 2021
PRODCOEF(AS,VARI,SR)  = PRODCOEF(AS,VARI,SR) * 0.9997**4;
PRODCOEF(LIVESTOCK,FEEDP,SR)  = PRODCOEF(LIVESTOCK,FEEDP,SR) * 0.9997**4;
PRODCOEF(AS,VARI,LFAHIGH)  = PRODCOEF(AS,VARI,LFAHIGH) * 1.002**4;
PRODCOEF(LIVESTOCK,FEEDP,LFAHIGH)  = PRODCOEF(LIVESTOCK,FEEDP,LFAHIGH) * 1.002**4;
PRODCOEF(AS,VARI,SR9TO10)  = PRODCOEF(AS,VARI,SR9TO10) * 1.001**4;
PRODCOEF(LIVESTOCK,FEEDP,SR9TO10)  = PRODCOEF(LIVESTOCK,FEEDP,SR9TO10) * 1.001**4;


* Adjust to general productivity development 0,5 % for all inputs, 1,5 % for 
* labor and 1,5 % for power
*PRODCOEF('SALIX','OTHRVARCST',SR) $(LONGRUN2)= PRODCOEF('SALIX','OTHRVARCST',SR) * 0.90 - 0.265;
PRODCOEF(AS,VARI,SR) $(LONGRUN2) = PRODCOEF(AS,VARI,SR) * 0.995**YRT;
PRODCOEF(AS,'LABOR',SR) $(LONGRUN2) = PRODCOEF(AS,'LABOR',SR) * 0.985**YRT/0.995**YRT;
PRODCOEF(AS,'LABOR2',SR) $(LONGRUN2)= PRODCOEF(AS,'LABOR2',SR)* 0.985**YRT/0.995**YRT;
PRODCOEF(AS,'POWER',SR) $(LONGRUN2) = PRODCOEF(AS,'POWER',SR) * 0.985**YRT/0.995**YRT;

PRODCOEF(LIVESTOCK,FEEDP,SR) $(LONGRUN2) = PRODCOEF(LIVESTOCK,FEEDP,SR) * 0.995**YRT;

*Less productivity development in LFA regions, more in other
PRODCOEF(AS,VARI,SR) $(LONGRUN2) = PRODCOEF(AS,VARI,SR) * 0.9997**YRT;
PRODCOEF(LIVESTOCK,FEEDP,SR) $(LONGRUN2) = PRODCOEF(LIVESTOCK,FEEDP,SR) * 0.9997**YRT;
PRODCOEF(AS,VARI,LFAHIGH) $(LONGRUN2) = PRODCOEF(AS,VARI,LFAHIGH) * 1.002**YRT;
PRODCOEF(LIVESTOCK,FEEDP,LFAHIGH) $(LONGRUN2) = PRODCOEF(LIVESTOCK,FEEDP,LFAHIGH) * 1.002**YRT;
PRODCOEF(AS,VARI,SR9TO10) $(LONGRUN2) = PRODCOEF(AS,VARI,SR9TO10) * 1.001**YRT;
PRODCOEF(LIVESTOCK,FEEDP,SR9TO10) $(LONGRUN2) = PRODCOEF(LIVESTOCK,FEEDP,SR9TO10) * 1.001**YRT;

* Adjust production in crisis
PRODCOEF(CROPS3,'POWER',SR) = PRODCOEF(CROPS3,'POWER',SR) * (1-(1-RED)*0.5);
PRODCOEF(CROPS3,'LABOR',SR) = PRODCOEF(CROPS3,'LABOR',SR) * (1-(1-RED)*0.4);
PRODCOEF(CROPS3,PR,SR) = PRODCOEF(CROPS3,PR,SR) * (1-(1-RED)*0.2);

* Ecological production coefficients
SET YD (IP) Yield dependent inputs and products
 /BREADGRAIN, COARSGRAIN, OILGRAIN, POTATOES, SUGARBEET, SILAGE, SILAGEHQ, GRASSPASTR,
  CBONDING, NITROGEN, PHOSPHORUS, POTASSIUM, PLASTIC/;

SET YDF (IP) Yield dependent inputs and products in forage and pasture
 /SILAGE, SILAGEHQ, GRASSPASTR, GRASSPASTF, NITROGEN, PHOSPHORUS, POTASSIUM,
  LABOR, POWER, PLASTIC, OTHRVARCST, CAPITAL/;

PRODCOEF('EW-WHEAT',IP,SR) = PRODCOEF('W-WHEAT',IP,SR);
PRODCOEF('EW-WHEAT',YD,SR) = PRODCOEF('EW-WHEAT',YD,SR)*0.65;
PRODCOEF('EW-RAY',IP,SR) = PRODCOEF('W-RAY',IP,SR);
PRODCOEF('EW-RAY',YD,SR) = PRODCOEF('EW-RAY',YD,SR)*0.65;
PRODCOEF('EBARLEY',IP,SR) = PRODCOEF('BARLEY',IP,SR);
PRODCOEF('EBARLEY',YD,SR) = PRODCOEF('EBARLEY',YD,SR)*0.65;
PRODCOEF('EOATS',IP,SR) = PRODCOEF('OATS',IP,SR);
PRODCOEF('EOATS',YD,SR) = PRODCOEF('EOATS',YD,SR)*0.65;
PRODCOEF('EFEEDPEAS',IP,SR) = PRODCOEF('FEEDPEAS',IP,SR);
PRODCOEF('EFEEDPEAS',YD,SR) = PRODCOEF('EFEEDPEAS',YD,SR)*0.90;
PRODCOEF('EFEEDPEAS','EPEAS',SR) = PRODCOEF('EFEEDPEAS','PEAS',SR);
PRODCOEF('EW-RAPE',IP,SR) = PRODCOEF('W-RAPE',IP,SR);
PRODCOEF('EW-RAPE',YD,SR) = PRODCOEF('EW-RAPE',YD,SR)*0.60;
PRODCOEF('EW-RAPE',YD,SR0s) = PRODCOEF('EW-RAPE',YD,SR0s)*0.50/0.60;
PRODCOEF('EW-RAPE','ERAPE',SR) = PRODCOEF('EW-RAPE','OILGRAIN',SR);
PRODCOEF('EW-RAPE','OTHRVARCST',SR) = PRODCOEF('EW-RAPE','OTHRVARCST',SR) +1.100;
PRODCOEF('EW-RAPE','OTHRVARCST',SR0s) = PRODCOEF('EW-RAPE','OTHRVARCST',SR0s) +1.500;
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

PRODCOEF(ECO,'N-LEAKAGE',SR) = PRODCOEF(ECO,'N-LEAKAGE',SR) * 0.7;
PRODCOEF('ECOPIG','N-LEAKAGE',SR) = PRODCOEF('ECOPIG','N-LEAKAGE',SR) / 0.7;
PRODCOEF('EPOULTRY','N-LEAKAGE',SR) = PRODCOEF('EPOULTRY','N-LEAKAGE',SR) / 0.7;
* Estimated difference in organic production based on nutrient balances in Greppa Naringen
* Pigs and poultry are already differentiated

PRODCOEF('EFORAGE1','ECON',SR)  = (PRODCOEF('EFORAGE1','ECON',SR)/1.25)  * 0.75;
PRODCOEF('EFORAGE2','ECON',SR)  = (PRODCOEF('EFORAGE2','ECON',SR)/1.25)  * 0.75;
PRODCOEF('EFORAGE3','ECON',SR)  = (PRODCOEF('EFORAGE3','ECON',SR)/1.25)  * 0.75;
PRODCOEF('EPASTURE1','ECON',SR) = (PRODCOEF('EPASTURE1','ECON',SR)/1.25) * 0.75;
PRODCOEF('EPASTURE2','ECON',SR) = (PRODCOEF('EPASTURE2','ECON',SR)/1.25) * 0.75;
*PRODCOEF('EFORAGE1','ECON',SR)  = -0.030;
*PRODCOEF('EFORAGE2','ECON',SR)  = -0.030;
*PRODCOEF('EFORAGE3','ECON',SR)  = -0.011;
*PRODCOEF('EPASTURE1','ECON',SR) = -0.030;
*PRODCOEF('EPASTURE2','ECON',SR) = -0.011;
PRODCOEF('ENFIX','ECON',SR)     = -0.090;
PRODCOEF('ENFIX','LABOR',SR) = PRODCOEF('EBARLEY','LABOR',SR)/2;
PRODCOEF('ENFIX','POWER',SR) = PRODCOEF('EBARLEY','POWER',SR)/2;
PRODCOEF('ENFIX','OTHRVARCST',SR) = PRODCOEF('EBARLEY','OTHRVARCST',SR)/2;
PRODCOEF('ENFIX','CAPITAL',SR) = PRODCOEF('EBARLEY','CAPITAL',SR)/2;
PRODCOEF('ENFIX','N-LEAKAGE',SR) = PRODCOEF('EFORAGE1','N-LEAKAGE',SR);
PRODCOEF('ENFIX','P-LEAKAGE',SR) = PRODCOEF('EFORAGE1','P-LEAKAGE',SR);

PRODCOEF('EDCOW1',IP,SR) = PRODCOEF('DCOW1',IP,SR);
PRODCOEF('EDCOW2',IP,SR) = PRODCOEF('DCOW2',IP,SR);
PRODCOEF('EDCOW3',IP,SR) = PRODCOEF('DCOW3',IP,SR);
PRODCOEF('EDCOW1','MILK',SR) = PRODCOEF('DCOW1','MILK',SR)*0.9;
PRODCOEF('EDCOW2','MILK',SR) = PRODCOEF('DCOW2','MILK',SR)*0.9;
PRODCOEF('EDCOW3','MILK',SR) = PRODCOEF('DCOW3','MILK',SR)*0.9;
PRODCOEF('EDCOW1','FEEDGRAIN',SR) = PRODCOEF('DCOW1','FEEDGRAIN',SR)*0.85;
PRODCOEF('EDCOW2','FEEDGRAIN',SR) = PRODCOEF('DCOW2','FEEDGRAIN',SR)*0.85;
PRODCOEF('EDCOW3','FEEDGRAIN',SR) = PRODCOEF('DCOW3','FEEDGRAIN',SR)*0.85;
*PRODCOEF('EDCOW1','OTHERFEED',SR) = PRODCOEF('DCOW1','OTHERFEED',SR)*0.85;
*PRODCOEF('EDCOW2','OTHERFEED',SR) = PRODCOEF('DCOW2','OTHERFEED',SR)*0.85;
*PRODCOEF('EDCOW3','OTHERFEED',SR) = PRODCOEF('DCOW3','OTHERFEED',SR)*0.85;
PRODCOEF('EDCOW1','LABOR',SR) = PRODCOEF('EDCOW1','LABOR',SR)+0.002;
PRODCOEF('EDCOW2','LABOR',SR) = PRODCOEF('EDCOW2','LABOR',SR)+0.002;
PRODCOEF('EDCOW3','LABOR',SR) = PRODCOEF('EDCOW3','LABOR',SR)+0.002;
*PRODCOEF('EDCOW1','ECOSUB',SR) = -1;  
*PRODCOEF('EDCOW2','ECOSUB',SR) = -1;  
*PRODCOEF('EDCOW3','ECOSUB',SR) = -1;  
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
*PRODCOEF('EBEEFCATT','ECOSUB',SR) = -0.67;  
PRODCOEF(LIVESTOCK,'EBEEF',SR) $ECO(LIVESTOCK) = PRODCOEF(LIVESTOCK,'SLGHBEEF',SR);
*PRODCOEF('EBEEFCATT','MAXECAT',SR)  = 1;  
*PRODCOEF('BEEFCATTLE','MAXECAT',SR) = -1;  
*PRODCOEF('EBEEFCAT2','MAXECAT',SR)  = 1;  
*PRODCOEF('BEEFCATTL2','MAXECAT',SR) = -1;  
PRODCOEF('EBEEFCATT','MEBEEFCATT',SR) = 1;  
PRODCOEF('EBEEFCAT2','MEBEEFCATT',SR) = 1;  

PRODCOEF('ESHEEP',IP,SR) = PRODCOEF('SHEEP',IP,SR);
PRODCOEF('ESHEEP','OTHERFEED',SR) = PRODCOEF('SHEEP','OTHERFEED',SR) * 2;
*PRODCOEF('ESHEEP','ECOSUB',SR) = -1/8;  
PRODCOEF('ESHEEP','ESHEEPM',SR) = PRODCOEF('ESHEEP','SLGHSHEEP',SR);
PRODCOEF('ESHEEP','MESHEEP',SR) = 1;  

*PRODCOEF('ECOPIG','ECOSUB',SR) = -1/2;  
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
*PRODCOEF(ECO,'EPIGLETS',SR) = PRODCOEF(ECO,'PIGLETS',SR);
*PRODCOEF(ECO,'EGILTS',SR)   = PRODCOEF(ECO,'GILTS',SR);

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
*Amonts in Euro

PRODCOEF(ECOCROPS,'ES1',SR)   = 0;  
PRODCOEF(ECOCROPS,'ES2',SR)   = 0;  

*PRODCOEF('SUGAR','ACRCOST',SR) = 2;
*PRODCOEF('LAY','ACRCOST',SR) = 0.5;
*PRODCOEF('ESUGAR','ACRCOST',SR) = 2;
*PRODCOEF('ELAY','ACRCOST',SR) = 0.5;

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
* Only cost for storage include for now, plastic is part of Oteher var cost but to low

* Include farmsub (tax reduction), prod times price in base run. Later reduced with sice of reduction
PRODCOEF(CROPS,'FARMSUB',SR) = PRODCOEF(CROPS,'BREADGRAIN',SR) * 1.654
 + PRODCOEF(CROPS,'COARSGRAIN',SR) * 1.557 * 0.8
 + PRODCOEF(CROPS,'PEAS',SR)       * 1.714
 + PRODCOEF(CROPS,'OILGRAIN',SR)   * 4.610
 + PRODCOEF(CROPS,'POTATOES',SR)   * 0.827
 + PRODCOEF(CROPS,'SUGARBEET',SR)  * 0.320
 + PRODCOEF(CROPS,'SILAGE',SR)     * 1.515 * 0.1
 + PRODCOEF(CROPS,'OTHRCROPPR',SR) * 5.447
 + PRODCOEF(CROPS,'ICRPR',SR)      * 7.528
 + PRODCOEF(CROPS,'UNDEFUSE',SR)   * 1.220;
 
 PRODCOEF(AS,'FARMSUB',SR) = PRODCOEF(AS,'FARMSUB',SR)
 + PRODCOEF(AS,'MILK',SR)       *(3.188 + 0.85)
 + PRODCOEF(AS,'DCALFM',SR)     * 1.901 * 0.8
 + PRODCOEF(AS,'DCALFF',SR)     * 1.085 * 0.3
 + PRODCOEF(AS,'PIGLETS',SR)    * 0.702 * 0.8
 + PRODCOEF(AS,'GILTS',SR)      * 2.193 * 0.5
 + PRODCOEF(AS,'SLGHBEEF',SR)   *40.871
 + PRODCOEF(AS,'SLGHPORK',SR)   *17.970
 + PRODCOEF(AS,'SLGHPLTRY',SR)  *11.045
 + PRODCOEF(AS,'SLGHSHEEP',SR)  *45.868
 + PRODCOEF(AS,'EGG',SR)        *17.078
 + PRODCOEF(AS,'EGRAIN',SR)     * 0.800
 + PRODCOEF(AS,'ERAPE',SR)      * 4.770
 + PRODCOEF(AS,'EPOTATOES',SR)  * 0.196
 + PRODCOEF(AS,'EMILK',SR)      * 0.851
 + PRODCOEF(AS,'EBEEF',SR)      * 1.684
 + PRODCOEF(AS,'EPORK',SR)      *17.089
 + PRODCOEF(AS,'ESHEEPM',SR)    * 3.201
 + PRODCOEF(AS,'EEGG',SR)       * 8.937
 + PRODCOEF(AS,'ECOSUB',SR)     * 1.500
 + PRODCOEF(AS,'GACRSUB',SR)    * 2.038
 + PRODCOEF(AS,'COMP4SUB',SR)   * 1.200
 + PRODCOEF(AS,'FORSUB',SR)     * 0.500
 + PRODCOEF(AS,'CATTLESUB',SR)  * 0.919
 + PRODCOEF(AS,'SOWHLTSUB',SR)  * 1.000
 + PRODCOEF(AS,'ES5',SR)        * 1.100
 + PRODCOEF(AS,'ES6',SR)        * 0.600
 + PRODCOEF(AS,'NATSUB',SR)     * 1.000
 + PRODCOEF(AS,'COMPSUB',SR)    * 0.054
 + PRODCOEF(AS,'COMPSUBL',SR)   * 1.381
 + PRODCOEF(AS,'BIODIVSUB',SR)  * 1.300
 + PRODCOEF(AS,'BIODIVSUB2',SR) * 1.800
 + PRODCOEF(AS,'BIODIVSUB3',SR) * 3.200
 + PRODCOEF(AS,'BIODIVSUBA',SR) * 1.400
 + PRODCOEF(AS,'BIODIVSUBF',SR) * 3.500
 + PRODCOEF(AS,'BIODIVSUBM',SR) * 2.700
 + PRODCOEF(AS,'BIODIVSUBG',SR) * 2.700
 + PRODCOEF(AS,'BIODIVSUBC',SR) * 1.000
 + PRODCOEF(AS,'BIODIVSUBS',SR) * 1.300;
* Data for farmsub not uppdated
 
PRODCOEF(AS,'FARMSUB',SR) = PRODCOEF(AS,'FARMSUB',SR)*0.07*0.3827/(1-0.3827);
* 7 percent of revenue times tax rate adjusted to untaxed amount.
PRODCOEF(AS,'FARMSUB',SR) = 0;
* Adjust production in crisis
PRODCOEF(CROPS3,'NITROGEN',SR) = PRODCOEF(CROPS3,'NITROGEN',SR) * (1-(1-RED)*0.5);
PRODCOEF(CROPS3,'PHOSPHORUS',SR) = PRODCOEF(CROPS3,'PHOSPHORUS',SR) * (1-(1-RED)*0.8);
PRODCOEF(CROPS3,'POTASSIUM',SR) = PRODCOEF(CROPS3,'POTASSIUM',SR) * (1-(1-RED)*0.5);
PRODCOEF(CROPS3,'PESTICIDES',SR) = PRODCOEF(CROPS3,'PESTICIDES',SR) * (1-(1-RED)*0.5);
PRODCOEF(CROPS3,'HERBICIDES',SR) = PRODCOEF(CROPS3,'HERBICIDES',SR) * (1-(1-RED)*0.5);
PRODCOEF(CROPS3,'GLYFOSAT',SR)   = PRODCOEF(CROPS3,'GLYFOSAT',SR)   * (1-(1-RED)*0.5);
PRODCOEF(CROPS3,'FUNGICIDES',SR) = PRODCOEF(CROPS3,'FUNGICIDES',SR) * (1-(1-RED)*0.5);
PRODCOEF(CROPS3,'INSECTICID',SR) = PRODCOEF(CROPS3,'INSECTICID',SR) * (1-(1-RED)*0.5);
PRODCOEF(CROPS3,PR,SR) = PRODCOEF(CROPS3,PR,SR) * (1-(1-RED)*0.2);
PRODCOEF(ECROPS3,'ECON',SR) = PRODCOEF(ECROPS3,'ECON',SR) * (1-(1-RED)*0.25);
PRODCOEF(ECROPS3,'ECOP',SR) = PRODCOEF(ECROPS3,'ECOP',SR) * (1-(1-RED)*0.40);
PRODCOEF(ECROPS3,'ECOK',SR) = PRODCOEF(ECROPS3,'ECOK',SR) * (1-(1-RED)*0.25);
PRODCOEF(ECROPS3,PR,SR) = PRODCOEF(ECROPS3,PR,SR) * (1-(1-RED)*0.1);

TABLE MANURE(AS,IP) 
*----------------------------------------------------------------------------------------------------

* Activity.. Fertiliser...........................................................................
*----------------------------------------------------------------------------------------------------
          NITROGEN PHOSPHORUS POTASSIUM    ECON      ECOP      ECOK   OTHRVARCST
DCOW1      -0.026    -0.015    -0.114                                   0.488
DCOW2      -0.026    -0.015    -0.114                                   0.488
DCOW3      -0.026    -0.015    -0.114                                   0.488
DCOW4      -0.026    -0.015    -0.114                                   0.488
HEIFER     -0.014    -0.011    -0.080                                   0.520
DAIRYBULL1 -0.011    -0.009    -0.050                                   0.520
DAIRYBULL2 -0.014    -0.011    -0.080                                   0.520
SLGHHEIFER -0.014    -0.011    -0.080                                   0.520
BEEFCATTLE -0.013    -0.014    -0.092                                   0.313
SHEEP      -0.001    -0.002    -0.019                                   0.032
SOW1       -0.025    -0.0067   -0.013                                   0.500
SLGHSWINE1 -0.0023   -0.0005   -0.0013                                  0.050
POULTRY    -0.140    -0.130    -0.170                                   0.500
CHICKEN    -0.050    -0.040    -0.075                                   0.500
HORSES     -0.004    -0.008    -0.050                                   0.500

*         NITROGEN PHOSPHORUS POTASSIUM    ECON      ECOP      ECOK   OTHRVARCST
EDCOW1                                   -0.023    -0.014    -0.103     0.440
EDCOW2                                   -0.023    -0.014    -0.103     0.440
EDCOW3                                   -0.023    -0.014    -0.103     0.440
EHEIFER                                  -0.014    -0.011    -0.080     0.520
EDBULL1                                  -0.011    -0.009    -0.050     0.520
EDBULL2                                  -0.014    -0.011    -0.080     0.520
ESLGHHEIF                                -0.013    -0.014    -0.092     0.520
EBEEFCATT                                -0.027    -0.011    -0.061     0.313
ESHEEP                                   -0.001    -0.002    -0.019     0.032
ECOPIG                                   -0.062    -0.015    -0.033     1.300
EPOULTRY                                 -0.140    -0.130    -0.170     0.500;
*----------------------------------------------------------------------------------------------------
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

*PRODCOEF(AS,'NITROGEN',SR)   = PRODCOEF(AS,'NITROGEN',SR)   + PRODCOEF(AS,'ECON',SR);
*PRODCOEF(AS,'PHOSPHORUS',SR) = PRODCOEF(AS,'PHOSPHORUS',SR) + PRODCOEF(AS,'ECOP',SR);
*PRODCOEF(AS,'POTASSIUM',SR)  = PRODCOEF(AS,'POTASSIUM',SR)  + PRODCOEF(AS,'ECOK',SR);

*PRODCOEF(AS,'ECON',SR) = 0;
*PRODCOEF(AS,'ECOP',SR) = 0;
*PRODCOEF(AS,'ECOK',SR) = 0;

$ONTEXT
* Calculate manure as replacement of table manure
PRODCOEF(LIVESTOCK,'NITROGEN',SR) = -(PRODCOEF(LIVESTOCK,'SILAGE',SR)*0.022 + 
 PRODCOEF(LIVESTOCK,'FEEDGRAIN',SR)*0.018 +PRODCOEF(LIVESTOCK,'OTHERFEED',SR)*0.04/3 + 
 PRODCOEF(LIVESTOCK,'HAY',SR)*0.020 + 
 PRODCOEF(LIVESTOCK,'MILK',SR)*0.0053 + PRODCOEF(LIVESTOCK,'SLGHBEEF',SR)*0.025 + 
 PRODCOEF(LIVESTOCK,'SLGHSHEEP',SR)*0.025 + PRODCOEF(LIVESTOCK,'SLGHPORK',SR)*0.026 +
 PRODCOEF(LIVESTOCK,'EGG',SR)*0.019 + PRODCOEF(LIVESTOCK,'SLGHPLTRY',SR)*0.027) * 0.375;

PRODCOEF(LIVESTOCK,'PHOSPHORUS',SR) = -(0.001+PRODCOEF(LIVESTOCK,'SILAGE',SR)*0.0026 + 
 PRODCOEF(LIVESTOCK,'FEEDGRAIN',SR)*0.0036 +PRODCOEF(LIVESTOCK,'OTHERFEED',SR)*0.005/3 + 
 PRODCOEF(LIVESTOCK,'MILK',SR)*0.001 + PRODCOEF(LIVESTOCK,'SLGHBEEF',SR)*0.0074 + 
 PRODCOEF(LIVESTOCK,'SLGHSHEEP',SR)*0.0074 + PRODCOEF(LIVESTOCK,'SLGHPORK',SR)*0.0046 +
 PRODCOEF(LIVESTOCK,'EGG',SR)*0.002 + PRODCOEF(LIVESTOCK,'SLGHPLTRY',SR)*0.006);
 
PRODCOEF(LIVESTOCK,'POTASSIUM',SR) = -(PRODCOEF(LIVESTOCK,'SILAGE',SR)*0.021 + 
 PRODCOEF(LIVESTOCK,'FEEDGRAIN',SR)*0.005 +PRODCOEF(LIVESTOCK,'OTHERFEED',SR)*0.012/3 + 
 PRODCOEF(LIVESTOCK,'MILK',SR)*0.0016 + PRODCOEF(LIVESTOCK,'SLGHBEEF',SR)*0.0017 + 
 PRODCOEF(LIVESTOCK,'SLGHSHEEP',SR)*0.0017 + PRODCOEF(LIVESTOCK,'SLGHPORK',SR)*0.0022 +
 PRODCOEF(LIVESTOCK,'EGG',SR)*0.0016 + PRODCOEF(LIVESTOCK,'SLGHPLTRY',SR)*0.0029);

PRODCOEF(LIVESTOCK,'ECON',SR) $ECO(LIVESTOCK) = PRODCOEF(LIVESTOCK,'NITROGEN',SR);
PRODCOEF(LIVESTOCK,'ECOP',SR) $ECO(LIVESTOCK) = PRODCOEF(LIVESTOCK,'PHOSPHORUS',SR);
PRODCOEF(LIVESTOCK,'ECOK',SR) $ECO(LIVESTOCK) = PRODCOEF(LIVESTOCK,'POTASSIUM',SR);
$OFFTEXT
*$ONTEXT
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
PRODCOEF('SOW1','MAXMANURE',SR) = PRODCOEF('SOW1','PHOSPHORUS',SR)*0.2;
PRODCOEF('GILT','MAXMANURE',SR) = PRODCOEF('GILT','PHOSPHORUS',SR)*0.2;
PRODCOEF('SLGHSWINE1','MAXMANURE',SR) = PRODCOEF('SLGHSWINE1','PHOSPHORUS',SR)*0.2;
PRODCOEF('POULTRY','MAXMANURE',SR) = PRODCOEF('POULTRY','PHOSPHORUS',SR)*0.5;
PRODCOEF('CHICKEN','MAXMANURE',SR) = PRODCOEF('CHICKEN','PHOSPHORUS',SR)*0.8;
*PRODCOEF(LIVESTOCK,'MAXMANURE',SR) = 0;

* Reduce use of power to higher productivity in 2006
*PRODCOEF(AS,'POWER',SR) = PRODCOEF(AS,'POWER',SR) * 0.70;

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

* Reduce environmental impact ofer time
PRODCOEF(CROPS,'CO2',SR) $(LONGRUN2) = PRODCOEF(CROPS,'CO2',SR) * 0.995**YRT;
PRODCOEF(CROPS,'N2O',SR) $(LONGRUN2) = PRODCOEF(CROPS,'N2O',SR) * 0.995**YRT;
PRODCOEF(CROPS,'CH4',SR) $(LONGRUN2) = PRODCOEF(CROPS,'CH4',SR) * 0.995**YRT;
PRODCOEF(CROPS,'NH3',SR) $(LONGRUN2) = PRODCOEF(CROPS,'NH3',SR) * 0.995**YRT;
PRODCOEF(CROPS,'N-LEAKAGE',SR) $(LONGRUN2) = PRODCOEF(CROPS,'N-LEAKAGE',SR) * 0.995**YRT;
PRODCOEF(CROPS,'P-LEAKAGE',SR) $(LONGRUN2) = PRODCOEF(CROPS,'P-LEAKAGE',SR) * 0.995**YRT;
PRODCOEF(LIVESTOCK,'CO2',SR) $(LONGRUN2) = PRODCOEF(LIVESTOCK,'CO2',SR) * 0.995**YRT;
PRODCOEF(LIVESTOCK,'N2O',SR) $(LONGRUN2) = PRODCOEF(LIVESTOCK,'N2O',SR) * 0.995**YRT;
PRODCOEF(LIVESTOCK,'CH4',SR) $(LONGRUN2) = PRODCOEF(LIVESTOCK,'CH4',SR) * 0.995**YRT;
PRODCOEF(LIVESTOCK,'NH3',SR) $(LONGRUN2) = PRODCOEF(LIVESTOCK,'NH3',SR) * 0.995**YRT;
PRODCOEF(LIVESTOCK,'N-LEAKAGE',SR) $(LONGRUN2) = PRODCOEF(LIVESTOCK,'N-LEAKAGE',SR) * 0.995**YRT;
PRODCOEF(LIVESTOCK,'P-LEAKAGE',SR) $(LONGRUN2) = PRODCOEF(LIVESTOCK,'P-LEAKAGE',SR) * 0.995**YRT;

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

 
* No leakage in optimisation
*PRODCOEF(AS,'N-LEAKAGE',SR)        = 0;
*PRODCOEF(AS,'P-LEAKAGE',SR)        = 0;
*PRODCOEF(AS,'CLIMATE',SR)          = 0;
*PRODCOEF(AS,'CLIMATE2',SR)         = 0;
PRODCOEF(AS,'N-PROD',SR)        = 0;
PRODCOEF(AS,'P-PROD',SR)        = 0;



TABLE CONST(IP,AS) Constraints on crop rotation etc.
*----------------------------------------------------------------------------------------------------
*   Constraint...  Activity..........................................................................
*----------------------------------------------------------------------------------------------------
           W-WHEAT  W-RAY W-BARLEY BARLEY  OATS MAJSSIL W-RAPE   S-RAPE   POTATO    SUGAR 
MAXWHEAT      0.75  -0.25    -0.25  -0.25 -0.25          -0.25    -0.25    -0.25    -0.25         
MAXWWHEAT        1               1                          -1    
MAXWRAY                 1              -1    -1
MAXOILG      -0.07  -0.07    -0.07  -0.07 -0.07    0.93   0.93     0.93    -0.07    -0.07         
MAXWOILG                                                     1                        
MAXPEAS                      -0.10  -0.10  -0.1
MAXPOTATO    -0.15  -0.15    -0.15  -0.15 -0.15   -0.15  -0.15    -0.15     0.85    -0.15
MAXSUGAR     -0.20  -0.20    -0.20  -0.20 -0.20   -0.20                    -0.20     0.80         
MINNEWFOR                              -1    -1                                     
*MAXCOVER                               -1    -1                      -1    
*MAXCATCH                               -1    -1                          
MAXLATE                                -1    -1                      -1     
*MAXFOR        -0.7   -0.7     -0.7   -0.7  -0.7    -0.7   -0.7     -0.7     -0.7     -0.7   
*MINGRAIN     -0.90  -0.90    -0.90  -0.90 -0.90    0.10   0.10     0.10     0.10     0.10  
*MINLAY        0.05   0.05     0.05   0.05  0.05    0.05   0.05     0.05     0.05     0.05
*MAXLAY        -0.5   -0.5     -0.5   -0.5  -0.5    -0.5   -0.5     -0.5


    +      FORAGE1  FORAGE2  FORAGE3 PASTURE1 PASTURE2  NEWFOR OTHERCROPS    LAY  COVERCROP
MAXWHEAT     -0.25    -0.25             -0.00                     -0.25    -0.25            
MAXWWHEAT   -0.165   -0.165                                        -0.8       -1        
MAXWRAY                                                                            
MAXOILG     -0.023   -0.023             -0.00                     -0.07    -0.07            
MAXWOILG    -0.165   -0.165             -0.00                      -0.2       -1   
MAXPEAS      -0.10    -0.10    -0.10    -0.00    -0.00   -0.10    -0.10    -0.10
MAXPOTATO                                                         -0.15    -0.15   
MAXSUGAR                                                          -0.20    -0.20            
MINNEWFOR    0.333    0.333    0.125    0.333    0.125      -1                            1  
*MAXCOVER     0.333    0.333    0.125    0.333    0.125      -1                            1
*MAXCATCH     0.333    0.333    0.125    0.333    0.125      -1                            1
MAXLATE                                          
*MAXFOR         0.3      0.3      0.3      0.3      0.3     0.3     -0.7     -0.7    
*MINGRAIN      0.10     0.10     0.10     0.10     0.10    0.10     0.10     0.10   
*MINLAY        0.05     0.05     0.05     0.05     0.05    0.05     0.05     0.05
*MAXLAY                                                                       0.5


    +      EW-WHEAT   EW-RAY  EBARLEY    EOATS  EW-RAPE  ES-RAPE  EPOTATO   ESUGAR    ENFIX
MAXEWHEAT      0.75    -0.25    -0.25    -0.25    -0.25    -0.25    -0.25    -0.25    -0.25
MAXEWWHEAT        1                                  -1
MAXEWRAY                   1       -1       -1
MAXEOILG      -0.07    -0.07    -0.07    -0.07     0.93     0.93    -0.07    -0.07    -0.07         
MAXEWOILG                                             1                        
MAXEPEAS                        -0.10    -0.10
MAXEPOTATO    -0.15    -0.15    -0.15    -0.15    -0.15    -0.15     0.85    -0.15    -0.15
MAXESUGAR     -0.20    -0.20    -0.20    -0.20    -0.20    -0.20    -0.20     0.80    -0.20
MINENEWFOR                         -1       -1                       
*MAXECOVER                          -1       -1                -1    
*MAXECATCH                          -1       -1                    
MAXELATE                           -1       -1                -1     
*MINELAY       0.05      0.05     0.05     0.05                      0.05     0.05     0.05
*MAXELAY       -0.5      -0.5     -0.5     -0.5                                         0.5


     +     EFORAGE1 EFORAGE2 EFORAGE3 EPASTURE1 EPASTURE2 ENEWFOR EOTHRCROPS  ELAY ECOVERCROP
MAXEWHEAT     -0.25    -0.25             -0.00                      -0.25    -0.25          
MAXEWWHEAT   -0.165   -0.165                                        -0.8       -1         
MAXEWRAY                                                                           
MAXEOILG     -0.023   -0.023             -0.00                      -0.07    -0.07           
MAXEWOILG    -0.165   -0.165             -0.00                      -0.2       -1   
MAXEPEAS      -0.10    -0.10    -0.10    -0.00    -0.00    -0.10    -0.10    -0.10
MAXEPOTATO                                                          -0.15    -0.15        
MAXESUGAR                                                           -0.20    -0.20               
MINENEWFOR    0.333    0.333    0.125    0.333    0.125       -1                           1   
*MAXECOVER     0.333    0.333    0.125    0.333    0.125       -1                           1
*MAXECATCH     0.333    0.333    0.125    0.333    0.125       -1                           
*MINELAY        0.05     0.05     0.05     0.05     0.05     0.05     0.05     0.05
*MAXELAY                                                                        0.5
;


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

CONST('MAXWHEAT','FEEDPEASH')  = -0.25;
CONST('MAXWWHEAT','FEEDPEASH') = -1;
CONST('MAXWRAY','FEEDPEASH')   = -1;
CONST('MAXOILG','FEEDPEASH')   = -0.07;
CONST('MAXSUGAR','FEEDPEASH')  = -0.20;
*CONST('MINLAY','FEEDPEASH')    =  0.07;
*CONST('MAXLAY','FEEDPEASH')    = -0.5;
CONST('MAXPEAS','FEEDPEAS')   =  0.90;

CONST('MAXEWHEAT','EFEEDPEAS')  = -0.25;
CONST('MAXEWWHEAT','EFEEDPEAS') = -1;
CONST('MAXEWRAY','EFEEDPEAS')   = -1;
CONST('MAXEOILG','EFEEDPEAS')   = -0.07;
CONST('MAXESUGAR','EFEEDPEAS')  = -0.20;
*CONST('MINLAY','EFEEDPEAS')    =  0.07;
*CONST('MAXLAY','EFEEDPEAS')    = -0.5;
CONST('MAXEPEAS','EFEEDPEAS') =  0.90;

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



PARAMETER EAS(R,SR,AS,IP)  Unit input and product coef for subregional crop and livestock prod act;
EAS(R,SR,AS,IP)$RSRAS(R,SR,AS) = PRODCOEF(AS,IP,SR) + CONST(IP,AS);

* Regional differences in crop rotations

EAS(R,SR1TO5,'COVERCROP','MINNEWFOR') = 0;
EAS(R,SR1TO5,'ECOVERCROP','MINENEWFOR') = 0;
EAS(R,SR1TO12,'CATCHCROP','MINNEWFOR') = 0;
EAS(R,SR1TO12,'ECATCHCROP','MINENEWFOR') = 0;
EAS(R,SR0gss,'W-RAPE','MAXOILG') $RSR(R,SR0gss)   = 0.5;
EAS(R,SR0gss,'S-RAPE','MAXOILG') $RSR(R,SR0gss)   = 0.5;
EAS(R,SR1TO12,'FORAGE1','MAXOILG') $RSR(R,SR1TO12) = 0;
EAS(R,SR1TO12,'FORAGE2','MAXOILG') $RSR(R,SR1TO12) = 0;
EAS(R,SR1TO12,'FORAGE1','MAXWOILG') $RSR(R,SR1TO12) = 0;
EAS(R,SR1TO12,'FORAGE2','MAXWOILG') $RSR(R,SR1TO12) = 0;
EAS(R,SR1TO12,'EFORAGE1','MAXEOILG') $RSR(R,SR1TO12) = 0;
EAS(R,SR1TO12,'EFORAGE2','MAXEOILG') $RSR(R,SR1TO12) = 0;
EAS(R,SR1TO12,'EFORAGE1','MAXEWOILG') $RSR(R,SR1TO12) = 0;
EAS(R,SR1TO12,'EFORAGE2','MAXEWOILG') $RSR(R,SR1TO12) = 0;
EAS(R,SR0s,'BARLEY','MAXWWHEAT') $RSR(R,SR0s) = -1;
EAS(R,SR0s,'OATS','MAXWWHEAT') $RSR(R,SR0s)   = -1;
EAS(R,SR0s,'W-RAY','MAXWWHEAT') $RSR(R,SR0s)  =  1;
*EAS(R,SR0s,'W-BARLEY','MAXWWHEAT') $RSR(R,SR0s) = 0.5;
 
* Make it possible to seed forage in lay in subregions 1, 2, 3, 4a and 7b
EAS(R,SR1TO4a,'LAY','MINNEWFOR') $RSR(R,SR1TO4a)   = -1; 
EAS(R,SR07b,'LAY','MINNEWFOR') $RSR(R,SR07b)   = -1; 
 
EAS(R,SR1TO4a,'ELAY','MINENEWFOR') $RSR(R,SR1TO4a)   = -1; 
EAS(R,SR07b,'ELAY','MINENEWFOR') $RSR(R,SR07b)   = -1; 
 
*EAS(R,SR1TO12,AS,'MINLAY')  = 0;
*EAS(R,SR1TO12,AS,'EMINLAY') = 0;

* Calculate needed pasturing
EAS(R,SR,LIVESTOCK,'USEPASTR') = EAS(R,SR,LIVESTOCK,'GRASSPASTF')-EAS(R,SR,LIVESTOCK,'GRASSPASTR');
 

TABLE ECR(R,CR,IP)  Unit input and product coef for regional processing activities
*---------------------------------------------------------------------------------------------------

* REG.ACTIVITY..  ITEM/UNITS........................................................................
*---------------------------------------------------------------------------------------------------
                  PCAPKMILK  PCAPCHEESE  PCAPBUTTER  PCAPDRYMLK      P-COST
*                    1000 T      1000 T      1000 T      1000 T     Mil SEK
R1   .P-BGTOFG                                                        0.200
R1   .P-CGTOFG                                                        0.200
R1   .P-GSEED                                                         1.900
R1   .P-PSEED                                                         62.95
R1   .P-POTSEED                                                       4.500
R1   .P-PREMILK                                                       0.001
R1   .P-KMILK           1.0                                           1.375
R1   .P-CHEESE                      1.0                               8.136
R1   .P-BUTTER                                  1.0                   2.320
R1   .P-CREAM           1.0                                           3.906
R1   .P-DRYMILK                                             1.0       3.899
R1   .P-DRYMILK2                                            1.0       3.899
R1   .P-BEEF                                                          1.230
R1   .P-PORK                                                          2.550
R1   .P-POULTRY                                                       15.39
R1   .P-FPEAS                                                         0.400
R1   .P-PEAS                                                          0.100
R1   .P-RMEAL                                                         1.120
R1   .P-RKAKA                                                         1.120
R1   .P-FLOUR                                                         2.000
R1   .P-SUGAR                                                         2.936
R1   .P-PROTFEED                                                      1.500

     +             PCAPBEEF  PCAPPORK  PCAPPLTRY PCAPMILL PCAPPOTS POTATOES POTATOSEED PEASSEED    
*                    1000 T    1000 T     1000 T   1000 T   1000 T   1000 T     1000 T MiljUnit  
R1   .P-BEEF            1.0                                             
R1   .P-PORK                      1.0
R1   .P-POULTRY                              1.0
R1   .P-FLOUR                                         1.0
R1   .P-POTSEED                                                1.0      1.0       -1.0
R1   .P-PSEED                                                                              -1.0
  
     +            SUGARBEET WHITESUGAR    BETFOR HP-MASSA  PROTFEED    
*                    1000 T    1000 T     1000 T   1000 T    1000 T
R1   .P-PROTFEED                                               -1.0    
R1   .P-SUGAR          6.41       -1.0     -0.61   -0.052
* utbyte socker 16,5 % melass 2,5 %. Melass blir Betfor och HP-massa.
* betfor har 10 % melass, HP-massa 4 %. Tillverkas 60 000 ton HP-massa. resten betfor
* Totalt utbyte lite hogt. Beta har 75 % vatten. Betfor 9%. HP-massa 73 % anges i TS
* Mangd betfor efter mangd TS                           

     +                 MILK  SKIMMILK   MILKFAT   KMILK  CHEESE  BUTTER   CREAM DRYMILK DRYMILK2
*                    1000 T    1000 T    1000 T  1000 T  1000 T  1000 T  1000 T  1000 T  1000 T
R1   .P-PREMILK       1.015    -0.961    -0.039
R1   .P-KMILK                 0.97768   0.02318    -1.0
R1   .P-CHEESE               10.94000   0.28024            -1.0
R1   .P-BUTTER                1.35570   0.81340                    -1.0
R1   .P-CREAM                 0.67772   0.32276                            -1.0
R1   .P-DRYMILK              10.90000   0.00000                                    -1.0
R1   .P-DRYMILK2             10.47490   0.42510                                            -1.0
  
           +       SLGHBEEF  SLGHPORK SLGHPLTRY      BEEF      PORK  PLTRYMEAT
*                    1000 T    1000 T    1000 T    1000 T    1000 T     1000 T
R1   .P-BEEF            1.0                          -1.0
R1   .P-PORK                      1.0                          -1.0
R1   .P-POULTRY                             1.0                           -1.0

           +       OILGRAIN   RAPEOIL  RAPEMEAL  RAPSKAKA  ENEROILG     PEAS    FPEAS    PPEAS
*                    1000 T    1000 T    1000 T    1000 T    1000 T   1000 T   1000 T   1000 T
R1   .P-FPEAS                                                            1.0     -1.0
R1   .P-PEAS                                                                      1.0     -1.0
R1   .P-RMEAL           1.0    -0.41      -0.56
R1   .P-RKAKA           1.0    -0.31                -0.64
R1   .P-RME             1.0                                    -1.0
R1   .P-PSEED                                                           17.5
R1   .P-PROTFEED                            1.0

     +             GRAINSEED BREADGRAIN COARSGRAIN FEEDGRAIN  ENERBGR   ENERCGR PCAPFEED    FLOUR
*                     1000 T     1000 T     1000 T    1000 T   1000 T    1000 T   1000 T   1000 T
R1   .P-BGTOFG                     0.95                 -1.0                         1.0
R1   .P-CGTOFG                                 1.0      -1.0                         1.0
R1   .P-GSEED           -1.0                             1.0                        -1.0
R1   .P-FLOUR                     1.333                                                      -1.0
R1   .P-BGTOEG                      1.0                          -1.0
R1   .P-CGTOEG                                 1.0                         -1.0;

*     +             MISCCOST     DPTRANB     DPTRANR     DPTRANC    MISCRCPT
*                   Mil SEK     Mil SEK     Mil SEK     Mil SEK     Mil SEK
*R1   .P-DPTRANR                     1.0         1.0                    -1.0
*R1   .P-DPTRANC         1.0        -1.0                   -1.0;
*---------------------------------------------------------------------------------------------------
* Notes: Data for oil grain are from JEM 1990:12; P-COST is the difference between
* sales value and the cost of oil grain; P-COST for dairy products are ATC from Hans Andersson
* 	Wheat for feed gives 5 percent higher yield than wheat for bread
 
TABLE ECR2(R,CR,IP)  Unit input and product coef for regional retail activities
*---------------------------------------------------------------------------------------------------

* REG.ACTIVITY..  ITEM/UNITS........................................................................
*---------------------------------------------------------------------------------------------------
                 BREADGRAIN    BREADGRC  COARSGRAIN    COARSGRC       FLOUR      FLOURC
*                    1000 T      1000 T      1000 T      1000 T      1000 T      1000 T
R1   .R-BREADGR         1.0        -1.0
R1   .R-COARSGR                                 1.0        -1.0
R1   .R-FLOUR                                                           1.0        -1.0 

     +              RAPEOIL    RAPEOILC    POTATOES   POTATOESC  WHITESUGAR      SUGARC
*                    1000 T      1000 T      1000 T      1000 T      1000 T      1000 T
R1   .R-RAPEOIL         1.0        -1.0
R1   .R-POTATOES                                1.0        -1.0
R1   .R-SUGAR                                                           1.0        -1.0

     +            SLGHSHEEP      SHEEPC         EGG        EGGC       KMILK      KMILKC
*                    1000 T      1000 T      1000 T      1000 T      1000 T      1000 T
R1   .R-SHEEP           1.0        -1.0
R1   .R-EGG                                     1.0        -1.0
R1   .R-KMILK                                                           1.0        -1.0

     +               CHEESE     CHEESEC      BUTTER     BUTTERC       CREAM      CREAMC
*                    1000 T      1000 T      1000 T      1000 T      1000 T      1000 T
R1   .R-CHEESE          1.0        -1.0
R1   .R-BUTTER                                  1.0        -1.0
R1   .R-CREAM                                                           1.0        -1.0 

     +              DRYMILK    DRYMILK2    DRYMILKC    WILDMEAT   WILDMEATC        FISH       FISHC  
*                    1000 T      1000 T      1000 T      1000 T      1000 T      1000 T      1000 T 
R1   .R-DRYMILK         0.5         0.5        -1.0
R1   .R-WILDMEAT                                            1.0        -1.0
R1   .R-FISH                                                                        2.0        -1.0

     +                 BEEF       BEEFC        PORK       PORKC   PLTRYMEAT  PLTRYMEATC
*                    1000 T      1000 T      1000 T      1000 T      1000 T      1000 T
R1   .R-BEEF            1.0        -1.0
R1   .R-PORK                                    1.0        -1.0
R1   .R-PLTRYM                                                          1.0        -1.0

     +                FRUIT      FRUITC     VEGETAB    VEGETABC      WBERRY     WBERRYC   VEGETSEED
*                    1000 T      1000 T      1000 T      1000 T      1000 T      1000 T     1000 HA
R1   .R-FRUIT           1.0        -1.0
R1   .R-VEGETAB                                 1.0        -1.0                             
R1   .R-WBERRY                                                          1.0        -1.0;


TABLE ECR3(R,CR,IP)  Unit input and product coef for regional production activities
*---------------------------------------------------------------------------------------------------

* REG.ACTIVITY..  ITEM/UNITS........................................................................
*---------------------------------------------------------------------------------------------------
                               MAXREIND    MAXWILDM    WILDMEAT     MAXFISH        FISH  
*                                1000 T      1000 T      1000 T      1000 T      1000 T 
R1   .REINDEER                      1.0                    -1.0
R1   .HUNTING                                   1.0        -1.0
R1   .FISHING                                                           1.0        -1.0

     +             MAXFRUIT       FRUIT    MAXVEGET     VEGETAB   MAXWBERRY      WBERRY
*                    1000 T      1000 T      1000 T      1000 T      1000 T      1000 T
R1   .FRUITS            1.0        -1.0
R1   .VEGETABLE                                 1.0        -1.0
R1   .WILDBERRY                                                         1.0        -1.0;

ECR(R,CR,IP) = ECR('R1',CR,IP) + ECR2('R1',CR,IP)+ ECR3('R1',CR,IP);


TABLE NUTRIENT(P,*)  Content of nutrients in products (KJ per 100g or g per 100g)
*---------------------------------------------------------------------------------------------------
* Product.....	Nutrinets............................................................................
*---------------------------------------------------------------------------------------------------
		ENERG	PROT	PROTA	FAT2	CARB	
BREADGRC	1404	10.7	0	2.00	61.0	
COARSGRC	1428	9.20	0	3.00	64.7
FLOURC     	1473	8.47	0	1.88	72.4   		
*FLOURC     	1859	13.4	0	3.41	80.9
RAPEOILC  	3700	0	0	100	0	
POTATOESC	 329	1.74	0	0.10	16.4	
*SUGARBEETC   	 264	0	0	0	15.5	
SUGARC    	1693	0	0	0	99.6
*OTHRCROPPR 	 0	0	0	0	0	
*ICRPR    	 0	0	0	0	0	
SHEEPC    	 850	18.5	18.5	14.2	0.17	
EGGC        	 575	12.3	12.3	9.73	0.40	
KMILKC    	 210	3.50	3.50	1.9	4.8	
CHEESEC    	1377	20.0	20.0	27.3	1.7	
BUTTERC   	3049	0.40	0.40	82.0	0.50
CREAMC    	1319	2.4	2.4	33.0	3.3
*DRYMILKC    	1527	36.2	36.2	0.77	52.0	
DRYMILKC    	1570	36.2	36.2	1.92	52.0
*Uppskattad andring om halva ar fullmjolk
BEEFC    	 789	19.6	19.6	12.2	0.21	
PORKC    	1029	16.2	16.2	20.3	0.14	
PLTRYMEATC  	 426	11.5	11.5	 6.2	0.10
WILDMEATC  	 548	18.1	18.1	 6.5	0.99
FISHC   	 685	16.0	16.0	10.5	4.85
FRUITC  	 387	 1.7	 0	 2.6	14.3
VEGETABC  	 102	 1.0	 0	 0.1	4.14
WBERRYC  	 221	 0.7	 0	 0.8	9.10;
*---------------------------------------------------------------------------------------------------
* Not: Data from SJV and Swedish food Agency (Livsmedelsverket)

* Calculate the nutrient content of produced food
ECR(R,CR,'ENERGY') = SUM(P $(NUTRIENT(P,'ENERG') GT 0), ECR(R,CR,P)*NUTRIENT(P,'ENERG'))*10/1000000;
ECR(R,CR,'PROTEIN')= SUM(P $(NUTRIENT(P,'PROT') GT 0),  ECR(R,CR,P)*NUTRIENT(P,'PROT')) *10/1000;
ECR(R,CR,'PROTEINA')=SUM(P $(NUTRIENT(P,'PROTA') GT 0), ECR(R,CR,P)*NUTRIENT(P,'PROTA'))*10/1000;
ECR(R,CR,'FAT')    = SUM(P $(NUTRIENT(P,'FAT2') GT 0),  ECR(R,CR,P)*NUTRIENT(P,'FAT2')) *10/1000;
ECR(R,CR,'CARBOH') = SUM(P $(NUTRIENT(P,'CARB') GT 0),  ECR(R,CR,P)*NUTRIENT(P,'CARB')) *10/1000;

TABLE BIN(IN,SDP)  National input supply parameters
*---------------------------------------------------------------------------------------------------
* Reg.Input...   Parameter.........................................................................

*---------------------------------------------------------------------------------------------------
                 PBAR       QBAR       ELAS        MAX
CAPITAL          0.05                   999        INF
LABOR2            20                    999        INF
POWER            155                    999        INF
DIESEL          10.65                   999        INF
*DIESEL          10.65      213.052    0.00001      INF
PESTICIDES     0.0001                   999        INF
HERBICIDES      0.700                   999        INF
*HERBICIDES      0.700      769.876    0.00001      INF
GLYFOSAT        0.400                   999        INF
*GLYFOSAT        0.400      389.649    0.00001      INF
FUNGICIDES      1.830                   999        INF
*FUNGICIDES      1.830      113.625    0.00001      INF
INSECTICID      2.612                   999        INF
*INSECTICID      2.612       22.056    0.00001      INF
PLASTIC        0.0001                   999        INF
OTHRVARCST       1.28                   999        INF
OTHERFEED        1.30                   999        INF 
*OTHERFEED        1.30     2733.040    0.00001      INF 
CO2            0.0001                   999        INF
CH4            0.0001                   999        INF
N2O            0.0001                   999        INF
CO2EQ          0.0001                   999        INF
NH3            0.0001                   999        INF
YIELDRIRE1       0.10                   999        INF
YIELDRIRE2       0.10                   999        INF
P-COST           1.0                    999        INF
MISCCOST         1.0                    999        INF
DPTRANC          1.0                    999        INF;
*---------------------------------------------------------------------------------------------------
* Labor2 V-Gotaland kalk 2023.
* Diesel from Lst V-goltland kalk 2019. Price reduced by 1,70 kr/l for tax repayment
* Plastic is include in otehr var cost. only storage calcukated for now

BIN('DIESEL','QBAR')    = BIN('DIESEL','QBAR')    * RED;
BIN('HERBICIDES','QBAR')= BIN('HERBICIDES','QBAR')* RED;
BIN('GLYFOSAT','QBAR')  = BIN('GLYFOSAT','QBAR')  * RED;
BIN('FUNGICIDES','QBAR')= BIN('FUNGICIDES','QBAR')* RED;
BIN('INSECTICID','QBAR')= BIN('INSECTICID','QBAR')* RED;
BIN('OTHERFEED','QBAR') = BIN('OTHERFEED','QBAR') * RED;

BIN('POWER','PBAR')           = BIN('POWER','PBAR')  / 2;
BIN('POWER','PBAR')$LONGRUN   = BIN('POWER','PBAR')  * 2;
* Low cost for power in short term analyses

*EAS(R,SR,PASTURES,'OTHRVARCST')$LONGRUN  = EAS(R,SR,PASTURES,'OTHRVARCST')
*           - EAS(R,SR,PASTURES,'POWER')* BIN('POWER','PBAR') / 2;
* Reduce cost for power in long run analyses. Costs added as acr cost

BIN('POWER','PBAR')$LONGRUN1  = BIN('POWER','PBAR')  * 1.02**(YR-4);
BIN('POWER','PBAR')$LONGRUN2  = BIN('POWER','PBAR')  * 1.0037**YRT;
* Larger but more expensive machins. Extra prod develop introduced above. Diesel adjusted above.
BIN('DIESEL','PBAR')$LONGRUN1 = (BIN('DIESEL','PBAR')+ 1.700) * 1.066 - 3.844/KPI2;
* Skatteatebet 2017 tillagd. Uppr?knad med real pris?kning Outlook. Skatte?terbet 2023 bortdragen.
*BIN('POWER','PBAR')$LONGRUN2 = BIN('POWER','PBAR')  + 15*(1.179-3.271);
* Power cost adjusted for CO2 and tax
* Inputs follows world price predicted by OECD 
BIN('PESTICIDES','PBAR')$LONGRUN1 = BIN('PESTICIDES','PBAR') * 1;
BIN('LABOR2','PBAR')$LONGRUN1 = BIN('LABOR2','PBAR') * 1.032 * 2;
* Extra increase of salery due to inflation
BIN(IN,'PBAR') = BIN(IN,'PBAR') * KPI3; 

TABLE BIRF(IR,R)  Regional supply of fixed inputs
*---------------------------------------------------------------------------------------------------
* Input.....	Region............................................................................
*---------------------------------------------------------------------------------------------------
		R1	R2	R3	R4	R5	R6
PCAPKMILK	90	76	338	83	242	224
PCAPCHEESE	5.6	9.0	0	21	34	12
PCAPBUTTER	4.6	3.0	0	26	0	4.7
PCAPDRYMLK	0	0	0	2.4	74.6	0
PCAPBEEF	1.9	7.1	31.2	22.2	20.5	10.6
PCAPPORK	2.0	2.2	1.2	36.7	20.5	36.9
PCAPPLTRY	0	0	43.2	0	53.5	1.2
PCAPMILL	0	4.5	13.4	13.4	10.4	56.7
PCAPFEED	0.5	0.5	11.0	11.0	49.6	11.0
PCAPPOTS
LVSTKBAL1  	1	1	1	1	1	1
MAXREIND	0.8	0.4
MAXWILDM  	3.4	3.4	3.4	3.4	3.4	3.4
MAXFISH  	12  	12  	12  	12  	12  	12
MAXFRUIT  	1	1	5	5	5	32
MAXVEGET  	15	15	50	50	50	200
MAXWBERRY  	26	5	1	1	1	1;
*---------------------------------------------------------------------------------------------------
* Data from "Karta f?r?dling o handel SASMREG.xlsx" and "N?ringsinneh?ll livsmedel V7"
* Regional f?rdelningav vilt, fisk och gr?nt beh?ver kollas.

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

BIRF('MAXFISH',R)  = (BIRF('MAXFISH',R))  * (1-(1-RED)*0.75);
BIRF('MAXFRUIT',R) = (BIRF('MAXFRUIT',R)) * (1-(1-RED)*0.95);
BIRF('MAXVEGET',R) = (BIRF('MAXVEGET',R)) * (1-(1-RED)*0.90);

TABLE BIRI(IR,R)  Regional prices of inputs with infinite price elasticity
*---------------------------------------------------------------------------------------------------
* Input.....	Region............................................................................
*---------------------------------------------------------------------------------------------------
		R1	R2	R3	R4	R5	R6
LABOR    	230	230	230	230	230	230
OILGRSEED	2320	2320	2320	2320	2320	2320 
POTATOSEED	7.59	7.59	7.59	7.59	7.59	7.59 
SUGARBSEED	2502	2502	2502	2502	2502	2502 
VEGETSEED	1.00	1.00	1.00	1.00	1.00	1.00     
NITROGEN	10.93	10.93	10.93	10.93	10.93	10.93
PHOSPHORUS	20.60	20.60	20.60	20.60	20.60	20.60
POTASSIUM	7.45	7.45	7.45	7.45	7.45	7.45
SOJA		3.30	3.30	3.20	3.20	3.10	3.10
BETFOR  	2.11	2.11	2.11	2.11	2.11	2.11
HP-MASSA				1.71	1.71	1.51
PROTFEED 	2.50	2.50	2.50	2.50	2.50	2.50;
*---------------------------------------------------------------------------------------------------
* Data labor V-Gotaland kalk 2023 and NPK V-Gotaland kalk 2019. 

BIRI(IR,'R2') = BIRI(IR,'R2') *1.1;
BIRI(IR,'R1') = BIRI(IR,'R1') *1.2;
BIRI('PROTFEED','R2') = BIRI('PROTFEED','R2') /1.1;
BIRI('PROTFEED','R1') = BIRI('PROTFEED','R1') /1.2;


* Adjust for price changes 2013-2017 to 2019
BIRI('SOJA',R)      = BIRI('SOJA',R)      * 1.198 * 1.2;

*BIRI(IR,R) = BIRI(IR,'R1');

* Fertilizers and feed follows world price predicted by OECD 
BIRI('LABOR',R)$LONGRUN1      = BIRI('LABOR',R)      * 1.032;
BIRI('NITROGEN',R)$LONGRUN1   = BIRI('NITROGEN',R)   * 1.100;
BIRI('PHOSPHORUS',R)$LONGRUN1 = BIRI('PHOSPHORUS',R) * 1.100;
BIRI('POTASSIUM',R)$LONGRUN1  = BIRI('POTASSIUM',R)  * 1.100;
*BIRI('SOJA',R)$LONGRUN1      = BIRI('SOJA',R)       * 0.800 * 0.743;
BIRI('BETFOR',R)$LONGRUN1     = BIRI('BETFOR',R)     * 0.978;
BIRI('HP-MASSA',R)$LONGRUN1   = BIRI('HP-MASSA',R)   * 0.978;
*BIRI(IR,R) = BIRI(IR,R) * KPI3;

TABLE BIR(R,IR,SDP)  Regional input supply parameters
*---------------------------------------------------------------------------------------------------
* Reg.Input...   Parameter.........................................................................

*---------------------------------------------------------------------------------------------------
                 PBAR       QBAR       ELAS        MIN        MAX
R2.INCONVCOV     1.200       0.3       1.0                    0.6
R3.INCONVCOV     1.200       2.9       1.0                    5.8
R4.INCONVCOV     1.200      26.2       1.0                    52
R5.INCONVCOV     1.200      10.2       1.0                    20
R6.INCONVCOV     1.200      18.8       1.0                    37

R2.INCONVECOV    1.200       0.1       1.0                    0.2
R3.INCONVECOV    1.200       0.6       1.0                    1.2
R4.INCONVECOV    1.200       8.8       1.0                    17
R5.INCONVECOV    1.200       1.1       1.0                    2.2
R6.INCONVECOV    1.200       1.2       1.0                    2.4

R3.INCONVCAT     0.700       2.9       1.0                    5.8
R4.INCONVCAT     0.700      26.2       1.0                    52
R5.INCONVCAT     0.700      10.2       1.0                    20
R6.INCONVCAT     0.700      18.8       1.0                    37

R3.INCONVECAT    0.700       0.6       1.0                    1.2
R4.INCONVECAT    0.700       8.8       1.0                    17
R5.INCONVECAT    0.700       1.1       1.0                    2.2
R6.INCONVECAT    0.700       1.2       1.0                    2.4

R3.INCONVLAT     0.600       7.0       1.0                    14
R4.INCONVLAT     0.600      20.2       1.0                    40
R5.INCONVLAT     0.600      12.6       1.0                    25
R6.INCONVLAT     0.600      15.0       1.0                    30

R3.INCONVELAT    0.600       1.4       1.0                    2.8
R4.INCONVELAT    0.600       6.8       1.0                    13
R5.INCONVELAT    0.600       1.4       1.0                    2.8
R6.INCONVELAT    0.600       1.0       1.0                    2.0;

*---------------------------------------------------------------------------------------------------
* acreage 2018, eco in proportion to schare of arable land
* INCONVCOV & INCONVECOV are 0.700 + 0.500 from Other variable costs

BIR(R,IR,'MAX') $(BIRF(IR,R) GT 0) = BIRF(IR,R);
BIR(R,IR,'PBAR')$(BIRI(IR,R) GT 0) = BIRI(IR,R);
BIR(R,IR,'MAX') $(BIRI(IR,R) GT 0) = INF;
BIR(R,IR,'ELAS')$(BIRI(IR,R) GT 0) = 999;

BIR(R,'HP-MASSA','MAX') = 0.001;
BIR('R1','HP-MASSA','MAX') = 0;
BIR('R2','HP-MASSA','MAX') = 0;
BIR('R3','HP-MASSA','MAX') = 0;
BIR('R4','HP-MASSA','MAX') = 0.001;
BIR('R5','HP-MASSA','MAX') = 0.001;
BIR('R6','HP-MASSA','MAX') = 0.001;

$ontext
BIR('R1','LABOR','MAX') =  2.390 * (1-(1-RED)*0.1);
BIR('R2','LABOR','MAX') =  4.843 * (1-(1-RED)*0.1);
BIR('R3','LABOR','MAX') = 12.462 * (1-(1-RED)*0.1);
BIR('R4','LABOR','MAX') = 10.735 * (1-(1-RED)*0.1);
BIR('R5','LABOR','MAX') = 15.422 * (1-(1-RED)*0.1);
BIR('R6','LABOR','MAX') =  8.441 * (1-(1-RED)*0.1);

BIR('R1','NITROGEN','MAX') = 1.205*1.072*RED;
BIR('R2','NITROGEN','MAX') = 4.436*1.072*RED;
BIR('R3','NITROGEN','MAX') = 51.396*1.072*RED;
BIR('R4','NITROGEN','MAX') = 30.950*1.072*RED;
BIR('R5','NITROGEN','MAX') = 37.056*1.072*RED;
BIR('R6','NITROGEN','MAX') = 50.651*1.072*RED;

BIR('R1','PHOSPHORUS','MAX') = 0.131*1.122*RED;
BIR('R2','PHOSPHORUS','MAX') = 0.490*1.122*RED;
BIR('R3','PHOSPHORUS','MAX') = 7.647*1.122*RED;
BIR('R4','PHOSPHORUS','MAX') = 4.410*1.122*RED;
BIR('R5','PHOSPHORUS','MAX') = 4.915*1.122*RED;
BIR('R6','PHOSPHORUS','MAX') = 6.983*1.122*RED;

BIR('R1','POTASSIUM','MAX') = 1.079*1.206*RED;
BIR('R2','POTASSIUM','MAX') = 3.623*1.206*RED;
BIR('R3','POTASSIUM','MAX') = 18.764*1.206*RED;
BIR('R4','POTASSIUM','MAX') = 14.145*1.206*RED;
BIR('R5','POTASSIUM','MAX') = 20.379*1.206*RED;
BIR('R6','POTASSIUM','MAX') = 17.035*1.206*RED;
* Tillaggen 1.072, 1.122 o 1.206 ar for ekologisk inkopt godning
$offtext
* Notes: Cream production draws from kmilk capacity. Processing capacity is first set to 
* 1994 production levels (above), then increased ten times.

*BIR(R,'PCAPKMILK','MAX')  = BIR(R,'PCAPKMILK','MAX') *10;
*BIR(R,'PCAPCHEESE','MAX') = BIR(R,'PCAPCHEESE','MAX')*10;
*BIR(R,'PCAPBUTTER','MAX') = BIR(R,'PCAPBUTTER','MAX')*10;
*BIR(R,'PCAPDRYMLK','MAX') = BIR(R,'PCAPDRYMLK','MAX')*10;

BIR(R,IR,'PBAR') = BIR(R,IR,'PBAR') * KPI3;
BIR(R,'OILGRSEED','PBAR') = BIR(R,'OILGRSEED','PBAR') / KPI3;
BIR(R,'POTATOSEED','PBAR') = BIR(R,'POTATOSEED','PBAR') / KPI3;
BIR(R,'SUGARBSEED','PBAR') = BIR(R,'SUGARBSEED','PBAR') / KPI3;
 
TABLE BISFA(SR,IS)  Subregional supply of fixed inputs

*---------------------------------------------------------------------------------------------------
*Reg.Sub   Input..........................................................................
*---------------------------------------------------------------------------------------------------
       CROPLAND  PRMPAST PRMPASTT PRMPASTN   PRMALV   PRMFOR   PRMMOS   PRMLOW  PRMCHAL  PRMMEAD
SR001   002.140  000.309  000.020  000.105  000.000  000.149  000.000  000.000  000.000  003.067
SR002   002.428  000.522  000.037  000.076  000.000  000.573  000.000  000.000  002.136  000.039
SR003   010.712  000.598  000.041  000.057  000.000  000.177  000.000  000.000  000.181  004.009
SR004   003.308  000.471  000.004  000.013  000.000  000.201  000.000  000.000  005.373  000.009
SR005   028.595  002.262  000.067  000.112  000.000  000.105  000.000  000.000  003.028  000.026
SR006   079.047  000.989  000.330  000.251  000.000  000.115  000.000  000.000  000.001  002.308
SR007   000.757  000.090  000.004  000.004  000.000  000.000  000.000  000.000  000.937  000.003
SR008   024.315  000.922  000.045  000.069  000.000  000.010  000.000  000.000  000.681  000.024
SR009   007.059  000.071  000.037  000.081  000.000  000.002  000.000  000.000  000.000  000.000
SR010   054.723  002.327  000.464  000.677  000.000  000.029  000.000  000.013  002.389  000.083
SR011   001.134  000.090  000.055  000.017  000.000  000.000  000.000  000.000  000.027  000.021
SR012   033.847  001.738  000.294  000.427  000.000  000.029  000.000  000.000  001.093  000.063
SR013   002.945  000.063  000.030  000.005  000.000  000.002  000.000  000.000  000.035  000.005
SR014   005.477  000.282  000.041  000.025  000.000  000.000  000.000  000.000  000.202  000.004
SR015   024.346  002.160  000.167  000.098  000.000  000.006  000.000  000.006  000.000  000.052
SR016   047.407  002.108  000.715  000.457  000.000  000.123  000.000  000.005  000.036  000.328
SR017   009.243  000.940  000.205  000.242  000.000  000.081  000.005  000.001  000.000  000.043
SR018   018.158  001.227  000.284  000.202  000.000  000.007  000.000  000.014  000.000  000.061
SR019   001.109  000.518  000.478  000.292  000.000  000.001  000.000  000.000  000.000  000.003
SR020   026.526  008.504  002.205  001.197  000.000  000.089  000.000  000.030  000.000  000.030
SR021   055.322  017.634  006.741  003.497  000.000  000.192  000.000  000.020  000.000  000.102
SR022   028.840  002.762  000.768  000.988  000.000  001.078  000.034  000.024  000.000  000.096
SR023   006.671  000.984  000.141  000.075  000.000  000.000  000.000  000.001  000.000  000.006
SR024   009.042  000.278  000.065  000.112  000.000  000.003  000.000  000.015  000.000  000.005
SR025   020.900  001.798  000.534  000.685  000.000  000.015  000.002  000.006  000.000  000.027
SR026   010.785  000.631  000.189  000.127  000.000  000.014  000.000  000.001  000.000  000.021
SR027   005.309  002.039  001.394  001.713  000.000  000.046  000.000  000.025  000.000  000.024
SR028   030.452  005.556  001.679  000.703  000.000  000.077  000.000  000.007  000.000  000.042
SR029   044.229  015.952  004.899  002.582  000.000  000.166  000.000  000.026  000.000  000.099
SR030   067.517  004.217  001.367  001.410  000.000  000.558  000.026  000.029  000.000  000.627
SR031   032.703  001.293  000.366  000.181  000.000  000.001  000.000  000.054  000.000  000.009
SR032   012.090  001.672  000.774  000.384  000.000  000.036  000.000  000.032  000.000  000.004
SR033   000.852  000.063  000.055  000.088  000.000  000.000  000.000  000.002  000.000  000.002
SR034   000.936  000.064  000.030  000.006  000.000  000.000  000.000  000.000  000.000  000.000
SR035   000.744  000.143  000.158  000.160  000.000  000.000  000.000  000.001  000.000  000.002
SR036   004.307  000.492  000.092  000.028  000.000  000.011  000.001  000.001  000.000  000.007
SR037   021.193  008.298  001.326  000.756  000.000  000.020  000.002  000.014  000.000  000.092
SR038   001.634  000.659  000.180  000.112  000.000  000.003  000.000  000.000  000.000  000.000
SR039   025.655  002.013  000.632  000.933  000.000  000.184  000.098  000.015  000.000  000.077
SR040   010.549  000.352  000.178  000.112  000.000  000.002  000.001  000.010  000.000  000.017
SR041   025.647  001.367  001.002  000.670  000.000  000.037  000.000  000.034  000.000  000.148
SR042   000.436  000.114  000.000  000.000  000.003  000.013  000.000  000.007  000.000  000.003
SR043   010.125  001.400  000.384  000.331  000.000  000.027  000.000  000.005  000.000  000.005
SR044   002.297  000.375  000.157  000.054  000.000  000.033  000.000  000.000  000.000  000.036
SR045   015.408  003.079  001.998  001.050  000.000  000.282  000.019  000.075  000.000  000.011
SR046   032.550  003.322  000.717  000.437  000.000  000.064  000.098  000.021  000.000  000.028
SR047   044.772  016.322  003.619  002.063  000.000  000.413  000.004  000.036  000.001  000.147
SR048   009.062  004.084  000.410  000.403  000.000  000.011  000.000  000.000  000.000  000.073
SR049   047.866  003.956  001.622  001.506  000.000  000.327  000.042  000.071  000.000  000.036
SR050   009.382  000.488  000.353  000.354  000.000  000.038  000.000  000.047  000.000  000.042
SR051   004.235  000.930  000.600  000.412  000.000  000.054  000.001  000.033  000.000  000.001
SR052   045.259  002.895  001.111  000.808  000.000  000.064  000.002  000.011  000.000  000.149
SR053   032.012  003.970  002.168  006.096  005.199  002.154  000.000  000.090  000.000  000.188
SR054   006.455  000.779  000.794  000.691  000.000  000.885  000.160  000.048  000.001  000.014
SR055   028.278  003.220  000.809  000.755  000.000  000.110  001.208  000.040  000.000  000.060
SR056   016.437  002.644  000.995  000.557  000.000  000.848  000.026  000.010  000.000  000.023
SR057   008.961  003.270  000.254  000.226  000.000  000.031  000.000  000.000  000.000  000.009
SR058   000.542  000.138  000.008  000.027  000.000  000.005  000.000  000.003  000.000  000.000
SR059   008.203  000.285  000.145  000.104  000.000  000.013  000.000  000.001  000.000  000.000
SR060   019.652  002.490  002.811  007.875  004.783  000.094  000.135  000.011  000.000  000.268
SR061   002.452  000.152  000.084  000.053  000.000  000.010  000.004  000.001  000.000  000.005
SR062   007.123  000.974  000.397  000.381  000.000  000.018  001.395  000.001  000.000  000.026
SR063   003.025  000.719  000.163  000.137  000.000  000.000  000.146  000.000  000.000  000.006
SR064   005.427  000.367  000.068  000.078  000.000  000.003  000.000  000.000  000.000  000.001
SR065   000.999  000.079  000.031  000.003  000.000  000.000  000.002  000.000  000.000  000.006
SR066   000.816  000.175  000.182  000.400  000.010  000.063  000.000  000.000  000.000  000.000
SR067   000.657  000.172  000.006  000.002  000.000  000.000  000.000  000.000  000.000  000.000
SR068   003.317  000.307  000.644  001.530  000.000  000.715  001.608  000.088  000.000  000.020
SR069   020.118  001.744  000.618  000.783  000.000  000.022  000.010  000.002  000.000  000.021
SR070   007.758  001.545  001.422  001.212  000.000  000.059  000.003  000.009  000.000  000.014
SR071   009.893  001.447  000.456  000.297  000.000  000.028  000.003  000.010  000.000  000.005
SR072   034.950  006.081  002.101  001.838  000.000  000.135  000.091  000.011  000.000  000.121
SR073   032.724  007.130  000.971  001.500  000.000  000.038  000.000  000.000  000.000  000.101
SR074   347.262  013.330  005.927  006.597  000.000  000.409  000.058  000.218  000.000  000.376
SR075   009.114  000.219  000.079  000.074  000.000  000.001  000.002  000.001  000.000  000.000
SR076   133.067  006.622  004.349  003.670  000.000  000.385  000.021  000.067  000.000  000.252
SR077   200.265  006.055  002.841  002.060  000.000  000.220  000.010  000.126  000.000  000.255
SR078   125.880  009.213  004.443  009.381  016.286  002.092  000.076  000.174  000.000  000.385
SR079   132.608  015.039  003.542  004.261  000.000  000.002  000.015  000.006  000.000  000.827
SR080   070.660  003.261  000.726  000.737  000.000  000.000  000.027  000.001  000.000  000.003
SR081   249.355  006.947  001.708  002.393  000.000  000.012  000.003  000.014  000.000  000.518
*---------------------------------------------------------------------------------------------------


*---------------------------------------------------------------------------------------------------
*Reg.Sub   Input..........................................................................
*---------------------------------------------------------------------------------------------------
 +    PRMPASTUP  POTPAST POTPASTT POTPASTN   POTALV   POTFOR   POTMOS   POTLOW  POTCHAL  POTMEAD
SR001   000.023  003.665  000.178  000.304  000.000  000.000  000.000  000.000  000.000  000.350
SR002   000.057  001.369  000.182  000.201  000.000  000.030  000.000  000.000  000.288  000.003
SR003   000.009  001.677  000.531  000.049  000.000  000.013  000.000  000.000  000.000  000.160
SR004   000.050  001.625  000.136  000.083  000.000  000.044  000.000  000.000  000.465  000.001
SR005   000.225  003.495  000.232  000.309  000.000  000.033  000.000  000.000  000.367  000.003
SR006   000.055  001.951  000.305  000.128  000.000  000.009  000.000  000.000  000.000  000.194
SR007   000.009  000.734  000.122  000.032  000.000  000.007  000.000  000.000  000.110  000.000
SR008   000.057  001.141  000.093  000.081  000.000  000.000  000.000  000.000  000.000  000.008
SR009   000.002  000.146  000.011  000.020  000.000  000.000  000.000  000.000  000.000  000.001
SR010   000.262  003.815  000.409  000.334  000.000  000.002  000.000  000.000  000.292  000.006
SR011   000.009  000.645  000.129  000.026  000.000  000.000  000.000  000.000  000.010  000.002
SR012   000.170  001.743  000.434  000.157  000.000  000.000  000.000  000.000  000.042  000.002
SR013   000.001  000.143  000.052  000.008  000.000  000.000  000.000  000.000  000.001  000.000
SR014   000.028  000.378  000.069  000.029  000.000  000.000  000.000  000.000  000.001  000.000
SR015   000.075  001.289  000.253  000.079  000.000  000.000  000.000  000.000  000.000  000.007
SR016   000.164  002.031  000.261  000.239  000.000  000.000  000.000  000.000  000.007  000.006
SR017   000.099  000.709  000.038  000.154  000.000  000.000  000.000  000.000  000.000  000.012
SR018   000.051  000.882  000.225  000.057  000.000  000.000  000.000  000.000  000.000  000.002
SR019   000.028  000.090  000.017  000.019  000.000  000.000  000.000  000.000  000.000  000.000
SR020   000.309  002.876  000.238  000.271  000.000  000.008  000.000  000.001  000.000  000.002
SR021   000.860  006.506  000.848  000.766  000.000  000.016  000.000  000.007  000.000  000.010
SR022   000.275  002.308  000.398  000.644  000.000  000.181  000.001  000.000  000.000  000.008
SR023   000.036  000.224  000.044  000.027  000.000  000.000  000.000  000.000  000.000  000.000
SR024   000.014  000.195  000.051  000.024  000.000  000.000  000.000  000.000  000.000  000.000
SR025   000.161  001.315  000.224  000.260  000.000  000.000  000.000  000.000  000.000  000.002
SR026   000.036  000.497  000.081  000.053  000.000  000.000  000.000  000.000  000.000  000.000
SR027   000.219  001.124  000.254  000.319  000.000  000.003  000.000  000.000  000.000  000.004
SR028   000.183  002.344  000.406  000.150  000.000  000.001  000.000  000.003  000.000  000.003
SR029   000.625  006.246  000.719  000.596  000.000  000.005  000.000  000.006  000.000  000.011
SR030   000.421  002.955  000.661  000.749  000.000  000.010  000.000  000.005  000.000  000.004
SR031   000.033  000.729  000.145  000.023  000.000  000.001  000.001  000.001  000.000  000.000
SR032   000.074  000.617  000.083  000.076  000.000  000.001  000.000  000.016  000.000  000.004
SR033   000.004  000.067  000.024  000.011  000.000  000.000  000.000  000.000  000.000  000.000
SR034   000.006  000.057  000.003  000.002  000.000  000.000  000.000  000.001  000.000  000.000
SR035   000.009  000.087  000.041  000.016  000.000  000.000  000.000  000.000  000.000  000.000
SR036   000.024  000.353  000.013  000.020  000.000  000.000  000.000  000.000  000.000  000.001
SR037   000.252  002.647  000.204  000.198  000.000  000.008  000.000  000.003  000.000  000.010
SR038   000.023  000.316  000.056  000.022  000.000  000.000  000.000  000.000  000.000  000.000
SR039   000.259  001.345  000.367  000.526  000.000  000.010  000.002  000.000  000.000  000.000
SR040   000.022  000.187  000.058  000.117  000.000  000.000  000.000  000.000  000.000  000.000
SR041   000.090  000.796  000.598  000.109  000.000  000.021  000.000  000.013  000.000  000.004
SR042   000.005  000.043  000.008  000.043  000.000  000.000  000.000  000.000  000.000  000.000
SR043   000.056  000.888  000.143  000.103  000.000  000.006  000.000  000.000  000.000  000.000
SR044   000.033  000.132  000.022  000.013  000.000  000.000  000.000  000.000  000.000  000.000
SR045   000.108  001.263  000.233  000.160  000.000  000.009  000.000  000.003  000.000  000.000
SR046   000.129  002.615  000.361  000.268  000.000  000.000  000.000  000.001  000.000  000.001
SR047   000.550  007.150  000.853  000.765  000.000  000.019  000.000  000.000  000.000  000.017
SR048   000.137  001.962  000.137  000.147  000.000  000.004  000.000  000.000  000.000  000.000
SR049   000.287  002.113  000.407  000.432  000.000  000.039  000.010  000.002  000.000  000.005
SR050   000.011  000.326  000.107  000.052  000.000  000.000  000.000  000.004  000.000  000.000
SR051   000.028  000.221  000.061  000.031  000.000  000.002  000.000  000.000  000.000  000.000
SR052   000.113  001.421  000.292  000.219  000.000  000.007  000.000  000.009  000.000  000.001
SR053   000.695  010.710  003.550  009.356  000.223  000.138  000.000  000.001  000.000  000.012
SR054   000.052  000.811  000.103  000.203  000.000  000.025  000.006  000.002  000.000  000.000
SR055   000.182  002.814  000.515  001.090  000.000  000.015  000.068  000.008  000.000  000.001
SR056   000.080  001.658  000.165  000.157  000.000  000.044  000.006  000.002  000.000  000.001
SR057   000.089  001.727  000.158  000.076  000.000  000.000  000.000  000.000  000.000  000.001
SR058   000.023  000.114  000.027  000.006  000.000  000.000  000.000  000.000  000.000  000.001
SR059   000.008  000.160  000.036  000.022  000.000  000.000  000.000  000.000  000.000  000.000
SR060   000.322  003.508  000.405  001.988  000.039  000.031  000.011  000.010  000.000  000.001
SR061   000.016  000.196  000.016  000.040  000.000  000.000  000.000  000.000  000.000  000.000
SR062   000.095  001.237  000.437  000.589  000.000  000.000  000.065  000.000  000.000  000.001
SR063   000.046  000.568  000.176  000.155  000.000  000.001  000.004  000.000  000.000  000.002
SR064   000.040  000.320  000.038  000.047  000.000  000.002  000.000  000.000  000.000  000.000
SR065   000.003  000.088  000.007  000.006  000.000  000.000  000.000  000.000  000.000  000.000
SR066   000.020  000.276  000.048  000.146  000.008  000.002  000.000  000.000  000.000  000.000
SR067   000.004  000.155  000.011  000.013  000.000  000.000  000.000  000.000  000.000  000.000
SR068   000.053  001.202  000.253  001.085  000.000  000.036  000.074  000.003  000.000  000.004
SR069   000.133  000.899  000.118  000.168  000.000  000.001  000.001  000.000  000.000  000.003
SR070   000.114  001.100  000.315  000.240  000.000  000.007  000.000  000.000  000.000  000.000
SR071   000.084  000.538  000.081  000.077  000.000  000.000  000.000  000.002  000.000  000.000
SR072   000.326  003.562  000.405  000.725  000.000  000.007  000.004  000.001  000.000  000.000
SR073   000.377  003.307  000.381  000.378  000.000  000.002  000.000  000.000  000.000  000.009
SR074   001.243  008.971  001.651  002.435  000.000  000.044  000.004  000.003  000.000  000.011
SR075   000.006  000.194  000.028  000.012  000.000  000.000  000.000  000.000  000.000  000.000
SR076   000.325  003.199  000.660  000.648  000.000  000.032  000.004  000.008  000.000  000.005
SR077   000.355  003.413  000.543  000.427  000.000  000.010  000.001  000.010  000.000  000.003
SR078   000.815  008.417  002.255  004.761  000.041  000.057  000.004  000.007  000.000  000.010
SR079   000.917  004.492  000.535  000.877  000.000  000.000  000.000  000.000  000.000  000.001
SR080   000.062  001.740  000.173  000.221  000.000  000.000  000.001  000.000  000.000  000.000
SR081   000.449  002.985  000.745  000.767  000.000  000.000  000.000  000.000  000.000  000.005
*---------------------------------------------------------------------------------------------------



*---------------------------------------------------------------------------------------------------
*Reg.Sub   Input..........................................................................
*---------------------------------------------------------------------------------------------------
 +       DAIRYFAC    BEEFCFAC      SOWFAC    SWINEFAC    SHEEPFAC    PLTRYFAC    CHICKFAC 
SR001     000.652     000.168     000.030     000.112     000.542     000.147     000.000
SR002     001.382     000.502     000.016     000.000     000.957     000.055     000.000
SR003     001.980     000.416     000.004     000.000     001.288     046.773     000.050
SR004     001.382     001.027     000.024     000.000     000.589     000.062     000.000
SR005     002.831     003.248     000.116     000.543     003.214     005.560     000.050
SR006     012.841     002.371     002.281     018.550     006.010     038.079     000.016
SR007     000.077     000.132     000.008     000.000     000.143     000.102     000.000
SR008     004.281     001.992     000.075     000.807     002.047     026.206     000.727
SR009     001.128     000.107     000.004     000.000     000.569     036.959     000.000
SR010     007.503     005.673     000.478     005.315     006.595     022.225     000.100
SR011     000.034     000.136     000.006     000.000     000.637     000.116     000.024
SR012     003.953     003.912     000.024     003.945     004.742     029.427     000.677
SR013     000.174     000.237     000.190     001.142     000.234     000.084     000.062
SR014     000.317     000.645     000.013     000.036     000.856     000.243     000.677
SR015     001.871     003.550     000.164     001.710     002.149     001.261     000.511
SR016     003.946     003.646     001.254     002.867     004.187     080.718     000.050
SR017     000.528     001.398     000.007     003.354     001.482     050.655     004.364
SR018     001.026     001.982     000.060     001.287     001.754     001.117     000.237
SR019     000.366     000.470     000.000     000.000     000.785     000.025     000.000
SR020     006.446     004.863     000.236     003.497     004.498     001.230     000.049
SR021     015.434     011.940     000.115     000.294     008.153     052.996     009.500
SR022     002.312     002.025     000.267     001.190     002.560     000.630     000.050
SR023     000.984     000.761     000.160     004.436     000.222     000.116     000.000
SR024     000.402     000.650     000.000     000.000     001.328     032.044     000.000
SR025     001.795     001.567     000.400     003.407     003.033     001.005     006.809
SR026     001.150     000.646     001.053     001.623     001.061     038.304     478.060
SR027     001.955     001.071     000.009     000.024     002.283     075.136     000.000
SR028     007.128     004.264     000.670     002.438     003.663     000.961     000.000
SR029     012.578     009.953     000.401     002.929     009.555     123.654     014.621
SR030     005.530     002.922     000.789     007.663     006.683     001.646     000.004
SR031     001.805     002.214     000.325     007.771     002.092     019.088     000.061
SR032     002.407     001.799     001.765     013.863     001.045     000.181     000.000
SR033     000.157     000.093     000.000     000.000     000.155     000.057     000.000
SR034     000.057     000.100     000.000     001.225     000.065     000.030     000.002
SR035     000.449     000.029     000.000     000.000     000.244     000.000     000.000
SR036     000.145     000.502     000.000     000.000     000.267     006.208     000.000
SR037     005.398     004.975     001.315     003.810     004.675     075.972     099.192
SR038     000.175     000.644     000.004     000.000     000.318     000.057     000.000
SR039     001.618     001.127     000.053     001.728     002.378     056.757     036.000
SR040     000.322     000.764     000.002     000.000     000.517     000.646     000.000
SR041     003.359     001.508     002.816     002.678     002.376     020.076     000.048
SR042     000.361     000.155     000.000     000.000     000.029     000.000     000.000
SR043     001.989     001.182     000.004     000.000     001.584     000.196     000.000
SR044     000.388     000.286     000.035     000.167     000.118     000.030     000.000
SR045     003.357     002.683     000.005     000.000     004.115     001.154     062.902
SR046     002.903     003.103     000.766     004.590     005.188     027.825     003.544
SR047     014.809     009.053     000.454     000.946     009.713     222.736     558.871
SR048     002.314     003.203     000.428     002.007     001.902     039.694     006.614
SR049     002.654     003.342     000.256     010.615     004.817     043.274     600.063
SR050     000.934     001.146     000.652     006.565     000.860     000.099     000.000
SR051     000.836     000.877     000.000     000.000     000.699     000.025     000.000
SR052     006.878     003.726     000.410     012.351     002.882     099.687     744.826
SR053     007.594     003.070     000.705     009.312     017.511     034.812     000.000
SR054     000.670     000.905     000.005     000.000     001.320     000.079     000.000
SR055     002.577     003.325     000.866     003.012     005.636     015.928     000.057
SR056     001.607     002.128     000.613     003.315     001.490     000.300     051.010
SR057     001.086     003.354     001.478     006.112     002.075     168.822     006.541
SR058     000.035     000.082     000.002     000.000     000.364     000.056     000.000
SR059     002.238     000.177     000.160     000.000     000.356     000.257     000.000
SR060     009.231     001.714     001.262     003.384     004.026     094.665     066.486
SR061     000.000     000.263     000.002     000.000     000.347     000.124     001.356
SR062     000.687     001.334     000.002     000.000     001.138     005.197     000.000
SR063     000.158     000.627     001.096     002.709     001.461     023.707     000.000
SR064     000.254     000.256     000.000     000.000     000.600     001.617     000.050
SR065     000.000     000.015     000.000     000.000     000.035     000.000     000.000
SR066     000.372     000.138     000.000     000.000     000.636     009.300     000.000
SR067     000.391     000.150     000.000     000.000     000.120     000.046     000.000
SR068     000.114     000.421     000.013     000.840     001.334     029.591     000.050
SR069     001.555     001.489     000.007     002.925     002.124     082.490     344.200
SR070     001.696     001.385     000.881     003.008     002.162     188.463     031.671
SR071     003.417     000.909     000.410     003.860     001.160     000.160     000.000
SR072     007.501     004.909     001.883     009.733     008.350     179.286     175.518
SR073     006.384     007.133     002.664     025.664     004.467     001.080     023.885
SR074     012.858     010.684     016.882     098.176     018.337     861.637    1186.154
SR075     000.691     000.548     000.060     005.395     000.525     000.021     000.000
SR076     009.790     005.640     006.336     052.810     005.524    1549.450     395.100
SR077     012.816     006.851     020.042     134.773     007.662     422.589    1250.962
SR078     022.044     009.214     007.635     068.751     020.325    1606.969    3093.252
SR079     018.252     014.466     011.411     107.600     013.350     161.261     567.614
SR080     017.819     002.858     009.975     077.378     005.197     793.745     104.900
SR081     006.252     008.121     027.355     111.678     007.879     890.445     851.947;
*---------------------------------------------------------------------------------------------------
* Data from Jordbruksverket for 2020

BISFA(SR0s,'SUGARQUOTA')= BISFA(SR0s,'CROPLAND') * 0.06;
BISFA(SR,'MAXPOTACR')   = BISFA(SR,'CROPLAND')   * 0.05;

PARAMETER BISF(R,SR,IS)  Subegional input supply parameters;
BISF(R,SR,IS)$RSR(R,SR) = BISFA(SR,IS);
BISF(R,SR,'PLTRYFAC')$RSR(R,SR) = BISF(R,SR,'PLTRYFAC')/1000;
BISF(R,SR,'CHICKFAC')$RSR(R,SR) = BISF(R,SR,'CHICKFAC')/1000;
BISF(R,SR,'CHICKFAC')$RSR(R,SR) = BISF(R,SR,'CHICKFAC')*1.33*1.10;
* One quarter of facilities are empty for cleaning and not reported in statistics
* Increased 10 % for production level of 2023

BISF(R,SR,'SOWFAC')$RSR(R,SR) = BISF(R,SR,'SOWFAC')*0.975;
BISF(R,SR,'SWINEFAC')$RSR(R,SR) = BISF(R,SR,'SWINEFAC')*0.975;
* No facilities for ecological pigs

* The potential facilitis for sheep is dubbled for spare capacity
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

BISF(R,SR,'MAXCRTOPST')$LONGRUN= BISF(R,SR,'CROPLAND')  * 0.004*YRA;

* adjust to lover level after deregulation
BISF(R,SR,'SUGARQUOTA') = BISF(R,SR,'SUGARQUOTA')  * 0.8; 
* increase quota since system is abandoned. Limit expansion to 5 percent. Adjust for yield increase
BISF(R,SR,'SUGARQUOTA')$LONGRUN = BISF(R,SR,'SUGARQUOTA')  * 1.05 / 1.005**YRT; 

* Limit salix to maximum X percent of acreage
BISF(R,SR,'MAXSALIX') = BISF(R,SR,'CROPLAND') * 0.007; 
*BISF('R5',SR0s,'MAXSALIX') = BISF('R5',SR0s,'CROPLAND') * 0.20; 
*BISF('R4',SR0s,'MAXSALIX') = BISF('R4',SR0s,'CROPLAND') * 0.30; 
BISF(R,SR1TO7b,'MAXSALIX') = 0; 

* Include bull facilities and ad 25 percent extra for regional redistribution
BISF(R,SR,'BULLFAC') = BISF(R,SR,'BEEFCFAC') + BISF(R,SR,'DAIRYFAC')*0.775;
BISF(R,SR,'BULLFAC') = BISF(R,SR,'BULLFAC') * 1.25; 
BISF(R,SR,'ECON') = 0;
BISF(R,SR,'ECOP') = 0;
BISF(R,SR,'ECOK') = 0;
BISF(R,SR,'MAXMANURE') = 0;


* Regional chare of cropland in ecological production 2016 
BISF('R1',SR,'ACRECO')  = BISF('R1',SR,'CROPLAND') * 0.098 * 1.18;
BISF('R2',SR,'ACRECO')  = BISF('R2',SR,'CROPLAND') * 0.230 * 1.18;
BISF('R3',SR,'ACRECO')  = BISF('R3',SR,'CROPLAND') * 0.145 * 1.13;
BISF('R4',SR,'ACRECO')  = BISF('R4',SR,'CROPLAND') * 0.220 * 1.13;
BISF('R5',SR,'ACRECO')  = BISF('R5',SR,'CROPLAND') * 0.100 * 1.18;
BISF('R6',SR,'ACRECO')  = BISF('R6',SR,'CROPLAND') * 0.047 * 1.18;

* Regional chare of livestock in ecological production 2016 
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

* Regional capacity for production of potatoes seed 
BIR('R1','PCAPPOTS','MAX') = SUM(SR $RSR('R1',SR), BISF('R1',SR,'CROPLAND') * 0.01 * 2.500 * 0.33);
BIR('R2','PCAPPOTS','MAX') = SUM(SR $RSR('R2',SR), BISF('R2',SR,'CROPLAND') * 0.01 * 2.500 * 0.33);
BIR('R3','PCAPPOTS','MAX') = SUM(SR $RSR('R3',SR), BISF('R3',SR,'CROPLAND') * 0.01 * 2.500 * 0.33);
BIR('R4','PCAPPOTS','MAX') = SUM(SR $RSR('R4',SR), BISF('R4',SR,'CROPLAND') * 0.01 * 2.500 * 0.33);
BIR('R5','PCAPPOTS','MAX') = SUM(SR $RSR('R5',SR), BISF('R5',SR,'CROPLAND') * 0.01 * 2.500 * 0.33);
BIR('R6','PCAPPOTS','MAX') = SUM(SR $RSR('R6',SR), BISF('R6',SR,'CROPLAND') * 0.01 * 2.500 * 0.33);
* 1 percent ov acreage potaties, 2 500 kr/ha, 1/3 from Sweden

* Separate acreage with permanent pasture after productivity 
BISF(R,SR,'PRMPASTH')  = BISF(R,SR,'PRMPAST')   * 0.5;
BISF(R,SR,'PRMPAST')   = BISF(R,SR,'PRMPAST')   * 0.5;
BISF(R,SR,'PRMPASTHT') = BISF(R,SR,'PRMPASTT')  * 0.5;
BISF(R,SR,'PRMPASTT')  = BISF(R,SR,'PRMPASTT')  * 0.5;
BISF(R,SR,'PRMPASTHN') = BISF(R,SR,'PRMPASTN')  * 0.5;
BISF(R,SR,'PRMPASTN')  = BISF(R,SR,'PRMPASTN')  * 0.5;
BISF(R,SR,'PRMPASTHUP')= BISF(R,SR,'PRMPASTUP') * 0.5;
BISF(R,SR,'PRMPASTUP') = BISF(R,SR,'PRMPASTUP') * 0.5;


*BISF(R,SR,'SOWFAC')    = BISF(R,SR,'SOWFAC') * 0.85 + 0.0001;
BISF(R,SR,'SWINEFAC')  = BISF(R,SR,'SWINEFAC')*1.20;
* Milk quota is converted from fat to milk. It is also adjusted for quota that is not distributed
* among subregions; Sowfac is adjusted for expected overestimation in statistics; 
* Swinefac is adjusted for expected underestimation (empty fac between groups)


PARAMETER BIS(R,SR,IS,SDP)  Subregional input supply;
BIS(R,SR,IS,'MAX')$RSR(R,SR) = BISF(R,SR,IS);
BIS(R,SR,'N-LEAKAGE','MAX')$RSR(R,SR) = INF;
BIS(R,SR,'N-LEAKAGE','PBAR')$RSR(R,SR) = 0.0001;
*BIS(R,SR,'N-LEAKAGE','PBAR')$RSR(R,SR) = 31;
BIS(R,SR,'P-LEAKAGE','MAX')$RSR(R,SR) = INF;
BIS(R,SR,'P-LEAKAGE','PBAR')$RSR(R,SR) = 0.0001;
*BIS(R,SR,'P-LEAKAGE','PBAR')$RSR(R,SR) = 1023;
*BIS(R,SR,'CLIMATE','MAX')$RSR(R,SR) = INF;
*BIS(R,SR,'CLIMATE','PBAR')$RSR(R,SR) = 0.0001;
*BIS(R,SR,'CLIMATE2','MAX')$RSR(R,SR) = INF;
*BIS(R,SR,'CLIMATE2','PBAR')$RSR(R,SR) = 0.0001;
*BIS(R,SR,'N-PROD','MAX')$RSR(R,SR) = INF;
*BIS(R,SR,'P-PROD','MAX')$RSR(R,SR) = INF;
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
* Other variable costs are reduced and reentered as average for increasing acrcosts
*---------------------------------------------------------------------------------------------------
EAS(R,SR,'PPASTR','OTHRVARCST')$(RSRAS(R,SR,'PPASTR'))  =
                                           EAS(R,SR,'PPASTR','OTHRVARCST') - 1.000;
BIS(R,SR,'ACRCOSTP','ELAS')$RSR(R,SR) = 1;
BIS(R,SR,'ACRCOSTP','PBAR')$RSR(R,SR) = 1.000;
*BIS(R,SR,'ACRCOSTP','PBAR')$(RSR(R,SR) $LONGRUN) = BIS(R,SR,'ACRCOSTP','PBAR')*2;
BIS(R,SR,'ACRCOSTP','PBAR')$(RSR(R,SR) $LONGRUN1)= BIS(R,SR,'ACRCOSTP','PBAR')*1.032;
BIS(R,SR,'ACRCOSTP','PBAR')$(RSR(R,SR) $LONGRUN2)= BIS(R,SR,'ACRCOSTP','PBAR')*0.985**YRT;
* productivity and price development for labor is used
BIS(R,SR,'ACRCOSTP','QBAR')$RSR(R,SR) = BISF(R,SR,'PRMPAST');
BIS(R,SR,'ACRCOSTP','MAX')$RSR(R,SR)  = BIS(R,SR,'ACRCOSTP','QBAR')+0.001;

EAS(R,SR,'PPASTRT','OTHRVARCST')$(RSRAS(R,SR,'PPASTRT'))  =
                                            EAS(R,SR,'PPASTRT','OTHRVARCST') - 1.000;
BIS(R,SR,'ACRCOSTPT','ELAS')$RSR(R,SR) = 1;
BIS(R,SR,'ACRCOSTPT','PBAR')$RSR(R,SR) = 1.000;
*BIS(R,SR,'ACRCOSTPT','PBAR')$(RSR(R,SR) $LONGRUN) = BIS(R,SR,'ACRCOSTPT','PBAR')*2;
BIS(R,SR,'ACRCOSTPT','PBAR')$(RSR(R,SR) $LONGRUN1)= BIS(R,SR,'ACRCOSTPT','PBAR')*1.032;
BIS(R,SR,'ACRCOSTPT','PBAR')$(RSR(R,SR) $LONGRUN2)= BIS(R,SR,'ACRCOSTPT','PBAR')*0.985**YRT;
BIS(R,SR,'ACRCOSTPT','QBAR')$RSR(R,SR) = BISF(R,SR,'PRMPASTT');
BIS(R,SR,'ACRCOSTPT','MAX')$RSR(R,SR)  = BIS(R,SR,'ACRCOSTPT','QBAR')+0.001;

EAS(R,SR,'PPASTRN','OTHRVARCST')$(RSRAS(R,SR,'PPASTRN'))  =
                                              EAS(R,SR,'PPASTRN','OTHRVARCST') - 1.000;
BIS(R,SR,'ACRCOSTPN','ELAS')$RSR(R,SR) = 1;
BIS(R,SR,'ACRCOSTPN','PBAR')$RSR(R,SR) = 1.000;
*BIS(R,SR,'ACRCOSTPN','PBAR')$(RSR(R,SR) $LONGRUN) = BIS(R,SR,'ACRCOSTPN','PBAR')*2;
BIS(R,SR,'ACRCOSTPN','PBAR')$(RSR(R,SR) $LONGRUN1)= BIS(R,SR,'ACRCOSTPN','PBAR')*1.032;
BIS(R,SR,'ACRCOSTPN','PBAR')$(RSR(R,SR) $LONGRUN2)= BIS(R,SR,'ACRCOSTPN','PBAR')*0.985**YRT;
BIS(R,SR,'ACRCOSTPN','QBAR')$RSR(R,SR) = BISF(R,SR,'PRMPASTN');
BIS(R,SR,'ACRCOSTPN','MAX')$RSR(R,SR)  = BIS(R,SR,'ACRCOSTPN','QBAR')+0.001;

EAS(R,SR,'PPASTRH','OTHRVARCST')$(RSRAS(R,SR,'PPASTRH'))  =
                                              EAS(R,SR,'PPASTRH','OTHRVARCST') - 1.000;
BIS(R,SR,'ACRCOSTPH','ELAS')$RSR(R,SR) = 1;
BIS(R,SR,'ACRCOSTPH','PBAR')$RSR(R,SR) = 1.000;
*BIS(R,SR,'ACRCOSTPH','PBAR')$(RSR(R,SR) $LONGRUN) = BIS(R,SR,'ACRCOSTPH','PBAR')*2;
BIS(R,SR,'ACRCOSTPH','PBAR')$(RSR(R,SR) $LONGRUN1)= BIS(R,SR,'ACRCOSTPH','PBAR')*1.032;
BIS(R,SR,'ACRCOSTPH','PBAR')$(RSR(R,SR) $LONGRUN2)= BIS(R,SR,'ACRCOSTPH','PBAR')*0.985**YRT;
BIS(R,SR,'ACRCOSTPH','QBAR')$RSR(R,SR) = BISF(R,SR,'PRMPASTH');
BIS(R,SR,'ACRCOSTPH','MAX')$RSR(R,SR)  = BIS(R,SR,'ACRCOSTPH','QBAR')+0.001;

EAS(R,SR,'PPASTRHT','OTHRVARCST')$(RSRAS(R,SR,'PPASTRHT'))  =
                                               EAS(R,SR,'PPASTRHT','OTHRVARCST') - 1.000;
BIS(R,SR,'ACRCOSTPHT','ELAS')$RSR(R,SR) = 1;
BIS(R,SR,'ACRCOSTPHT','PBAR')$RSR(R,SR) = 1.000;
*BIS(R,SR,'ACRCOSTPHT','PBAR')$(RSR(R,SR) $LONGRUN) = BIS(R,SR,'ACRCOSTPHT','PBAR')*2;
BIS(R,SR,'ACRCOSTPHT','PBAR')$(RSR(R,SR) $LONGRUN1)= BIS(R,SR,'ACRCOSTPHT','PBAR')*1.032;
BIS(R,SR,'ACRCOSTPHT','PBAR')$(RSR(R,SR) $LONGRUN2)= BIS(R,SR,'ACRCOSTPHT','PBAR')*0.985**YRT;
BIS(R,SR,'ACRCOSTPHT','QBAR')$RSR(R,SR) = BISF(R,SR,'PRMPASTHT');
BIS(R,SR,'ACRCOSTPHT','MAX')$RSR(R,SR)  = BIS(R,SR,'ACRCOSTPHT','QBAR')+0.001;

EAS(R,SR,'PPASTRHN','OTHRVARCST')$(RSRAS(R,SR,'PPASTRHN'))  =
                                               EAS(R,SR,'PPASTRHN','OTHRVARCST') - 1.000;
BIS(R,SR,'ACRCOSTPHN','ELAS')$RSR(R,SR) = 1;
BIS(R,SR,'ACRCOSTPHN','PBAR')$RSR(R,SR) = 1.000;
*BIS(R,SR,'ACRCOSTPHN','PBAR')$(RSR(R,SR) $LONGRUN) = BIS(R,SR,'ACRCOSTPHN','PBAR')*2;
BIS(R,SR,'ACRCOSTPHN','PBAR')$(RSR(R,SR) $LONGRUN1)= BIS(R,SR,'ACRCOSTPHN','PBAR')*1.032;
BIS(R,SR,'ACRCOSTPHN','PBAR')$(RSR(R,SR) $LONGRUN2)= BIS(R,SR,'ACRCOSTPHN','PBAR')*0.985**YRT;
BIS(R,SR,'ACRCOSTPHN','QBAR')$RSR(R,SR) = BISF(R,SR,'PRMPASTHN');
BIS(R,SR,'ACRCOSTPHN','MAX')$RSR(R,SR)  = BIS(R,SR,'ACRCOSTPHN','QBAR')+0.001;

EAS(R,SR,'PPASTRALV','OTHRVARCST')$(RSRAS(R,SR,'PPASTRALV'))  =
                                                EAS(R,SR,'PPASTRALV','OTHRVARCST') - 1.000;
BIS(R,SR,'ACRCOSTALV','ELAS')$RSR(R,SR) = 1;
BIS(R,SR,'ACRCOSTALV','PBAR')$RSR(R,SR) = 1.000;
*BIS(R,SR,'ACRCOSTALV','PBAR')$(RSR(R,SR) $LONGRUN) = BIS(R,SR,'ACRCOSTALV','PBAR')*2;
BIS(R,SR,'ACRCOSTALV','PBAR')$(RSR(R,SR) $LONGRUN1)= BIS(R,SR,'ACRCOSTALV','PBAR')*1.032;
BIS(R,SR,'ACRCOSTALV','PBAR')$(RSR(R,SR) $LONGRUN2)= BIS(R,SR,'ACRCOSTALV','PBAR')*0.985**YRT;
BIS(R,SR,'ACRCOSTALV','QBAR')$RSR(R,SR) = BISF(R,SR,'PRMALV');
BIS(R,SR,'ACRCOSTALV','MAX')$RSR(R,SR)  = BIS(R,SR,'ACRCOSTALV','QBAR')+0.001;

EAS(R,SR,'PPASTRFOR','OTHRVARCST')$(RSRAS(R,SR,'PPASTRFOR'))  =
                                                EAS(R,SR,'PPASTRFOR','OTHRVARCST') - 1.000;
BIS(R,SR,'ACRCOSTFOR','ELAS')$RSR(R,SR) = 1;
BIS(R,SR,'ACRCOSTFOR','PBAR')$RSR(R,SR) = 1.000;
*BIS(R,SR,'ACRCOSTFOR','PBAR')$(RSR(R,SR) $LONGRUN) = BIS(R,SR,'ACRCOSTFOR','PBAR')*2;
BIS(R,SR,'ACRCOSTFOR','PBAR')$(RSR(R,SR) $LONGRUN1)= BIS(R,SR,'ACRCOSTFOR','PBAR')*1.032;
BIS(R,SR,'ACRCOSTFOR','PBAR')$(RSR(R,SR) $LONGRUN2)= BIS(R,SR,'ACRCOSTFOR','PBAR')*0.985**YRT;
BIS(R,SR,'ACRCOSTFOR','QBAR')$RSR(R,SR) = BISF(R,SR,'PRMFOR');
BIS(R,SR,'ACRCOSTFOR','MAX')$RSR(R,SR)  = BIS(R,SR,'ACRCOSTFOR','QBAR')+0.001;

EAS(R,SR,'PPASTRMOS','OTHRVARCST')$(RSRAS(R,SR,'PPASTRMOS'))  =
                                                EAS(R,SR,'PPASTRMOS','OTHRVARCST') - 1.000;
BIS(R,SR,'ACRCOSTMOS','ELAS')$RSR(R,SR) = 1;
BIS(R,SR,'ACRCOSTMOS','PBAR')$RSR(R,SR) = 1.000;
*BIS(R,SR,'ACRCOSTMOS','PBAR')$(RSR(R,SR) $LONGRUN) = BIS(R,SR,'ACRCOSTMOS','PBAR')*2;
BIS(R,SR,'ACRCOSTMOS','PBAR')$(RSR(R,SR) $LONGRUN1)= BIS(R,SR,'ACRCOSTMOS','PBAR')*1.032;
BIS(R,SR,'ACRCOSTMOS','PBAR')$(RSR(R,SR) $LONGRUN2)= BIS(R,SR,'ACRCOSTMOS','PBAR')*0.985**YRT;
BIS(R,SR,'ACRCOSTMOS','QBAR')$RSR(R,SR) = BISF(R,SR,'PRMMOS');
BIS(R,SR,'ACRCOSTMOS','MAX')$RSR(R,SR)  = BIS(R,SR,'ACRCOSTMOS','QBAR')+0.001;

EAS(R,SR,'PPASTRLOW','OTHRVARCST')$(RSRAS(R,SR,'PPASTRLOW'))  =
                                                EAS(R,SR,'PPASTRLOW','OTHRVARCST') - 1.000;
BIS(R,SR,'ACRCOSTLOW','ELAS')$RSR(R,SR) = 1;
BIS(R,SR,'ACRCOSTLOW','PBAR')$RSR(R,SR) = 1.000;
*BIS(R,SR,'ACRCOSTLOW','PBAR')$(RSR(R,SR) $LONGRUN) = BIS(R,SR,'ACRCOSTLOW','PBAR')*2;
BIS(R,SR,'ACRCOSTLOW','PBAR')$(RSR(R,SR) $LONGRUN1)= BIS(R,SR,'ACRCOSTLOW','PBAR')*1.032;
BIS(R,SR,'ACRCOSTLOW','PBAR')$(RSR(R,SR) $LONGRUN2)= BIS(R,SR,'ACRCOSTLOW','PBAR')*0.985**YRT;
BIS(R,SR,'ACRCOSTLOW','QBAR')$RSR(R,SR) = BISF(R,SR,'PRMLOW');
BIS(R,SR,'ACRCOSTLOW','MAX')$RSR(R,SR)  = BIS(R,SR,'ACRCOSTLOW','QBAR')+0.001;

EAS(R,SR,'PPASTRCHAL','OTHRVARCST')$(RSRAS(R,SR,'PPASTRCHAL'))  =
                                                 EAS(R,SR,'PPASTRCHAL','OTHRVARCST') - 1.000;
BIS(R,SR,'ACRCOSTCHA','ELAS')$RSR(R,SR) = 1;
BIS(R,SR,'ACRCOSTCHA','PBAR')$RSR(R,SR) = 1.000;
*BIS(R,SR,'ACRCOSTCHA','PBAR')$(RSR(R,SR) $LONGRUN) = BIS(R,SR,'ACRCOSTCHA','PBAR')*2;
BIS(R,SR,'ACRCOSTCHA','PBAR')$(RSR(R,SR) $LONGRUN1)= BIS(R,SR,'ACRCOSTCHA','PBAR')*1.032;
BIS(R,SR,'ACRCOSTCHA','PBAR')$(RSR(R,SR) $LONGRUN2)= BIS(R,SR,'ACRCOSTCHA','PBAR')*0.985**YRT;
BIS(R,SR,'ACRCOSTCHA','QBAR')$RSR(R,SR) = BISF(R,SR,'PRMCHAL');
BIS(R,SR,'ACRCOSTCHA','MAX')$RSR(R,SR)  = BIS(R,SR,'ACRCOSTCHA','QBAR')+0.001;

EAS(R,SR,'PPASTRMEAD','OTHRVARCST')$(RSRAS(R,SR,'PPASTRMEAD'))  =
                                                 EAS(R,SR,'PPASTRMEAD','OTHRVARCST') - 1.000;
BIS(R,SR,'ACRCOSTMEA','ELAS')$RSR(R,SR) = 1;
BIS(R,SR,'ACRCOSTMEA','PBAR')$RSR(R,SR) = 1.000;
*BIS(R,SR,'ACRCOSTMEA','PBAR')$(RSR(R,SR) $LONGRUN) = BIS(R,SR,'ACRCOSTMEA','PBAR')*2;
BIS(R,SR,'ACRCOSTMEA','PBAR')$(RSR(R,SR) $LONGRUN1)= BIS(R,SR,'ACRCOSTMEA','PBAR')*1.032;
BIS(R,SR,'ACRCOSTMEA','PBAR')$(RSR(R,SR) $LONGRUN2)= BIS(R,SR,'ACRCOSTMEA','PBAR')*0.985**YRT;
BIS(R,SR,'ACRCOSTMEA','QBAR')$RSR(R,SR) = BISF(R,SR,'PRMMEAD');
BIS(R,SR,'ACRCOSTMEA','MAX')$RSR(R,SR)  = BIS(R,SR,'ACRCOSTMEA','QBAR')+0.001;


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

BIS(R,SR,'ACRECON','ELAS')$RSR(R,SR) = 2;
BIS(R,SR,'ACRECON','PBAR')$RSR(R,SR) = 2.000;
BIS(R,SR,'ACRECON','QBAR')$RSR(R,SR) = (BISF(R,SR,'CROPLAND')-BISF(R,SR,'ACRECO')) * 0.25;
BIS(R,SR,'ACRECON','QBAR')$(RSR(R,SR) $LONGRUN) = (BISF(R,SR,'CROPLAND')-BISF(R,SR,'ACRECO')) * 1;

BIS(R,SR,'ACRECON','MAX')$RSR(R,SR)  = BIS(R,SR,'ACRECON','QBAR')$RSR(R,SR)+0.001;
* No new ecologocal production in this version. 
*BIS(R,SR,'ACRECON','MAX')$RSR(R,SR)  = 0;

* Parameters for depreciation 
BIS(R,SR,'DAIRYFAC','MAX')  $LONGRUN = BIS(R,SR,'DAIRYFAC','MAX')  * (1-0.05*MIN(YR,20));
BIS(R,SR,'BULLFAC','MAX')   $LONGRUN = BIS(R,SR,'BULLFAC','MAX')   * (1-0.05*MIN(YR,20));
BIS(R,SR,'SOWFAC','MAX')    $LONGRUN = BIS(R,SR,'SOWFAC','MAX')    * (1-0.05*MIN(YR,20));
BIS(R,SR,'SWINEFAC','MAX')  $LONGRUN = BIS(R,SR,'SWINEFAC','MAX')  * (1-0.05*MIN(YR,20));
BIS(R,SR,'PLTRYFAC','MAX')  $LONGRUN = BIS(R,SR,'PLTRYFAC','MAX')  * (1-0.05*MIN(YR,20));
BIS(R,SR,'CHICKFAC','MAX')  $LONGRUN = BIS(R,SR,'CHICKFAC','MAX')  * (1-0.05*MIN(YR,20));

BIS(R,SR,'BEEFCFAC','MAX')  $LONGRUN = BIS(R,SR,'BEEFCFAC','MAX') * (1-0.025*MIN(YR,40))
                                          +BISF(R,SR,'DAIRYFAC')*(0.0125*MIN(YR,20));
* Makes one quarter of old dairy facilities possible to use for beefcattle

* Parameters for investment activities 
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
 

TABLE BPN(PN,SDP)  National product demand parameters
*---------------------------------------------------------------------------------------------------
* Reg.Product...  Parameter.........................................................................

*---------------------------------------------------------------------------------------------------
                 PBAR       QBAR       ELAS        MIN        MAX
ENERBGR                                            700        INF
ENERCGR                                            100        INF
ENEROILG                                            40        INF
MISCRCPT        1.000                  -999                   INF
DPTRANR         1.000                  -999                   INF
*MINPASTN        0.001                  -999                   INF
CBONDING       0.0001                  -999                   INF
*MINKONVM        0.001                  -999                   INF
ECOSUB          1.000                  -999                   INF
GACRSUB         0.138                  -999                   INF
FORSUB          0.500                  -999                   INF
CATTLESUB       0.091                  -999                   INF
SOWHLTSUB       2.100                  -999                   INF
*ES1             0.500                  -999                   INF
*ES2             0.500                  -999                   INF
ES3             0.025                  -999                   INF
ES4             0.128                  -999                   INF
ES5             0.147                  -999                   INF
ES6             0.069                  -999                   INF
NATSUB          1.000                  -999                   INF
BIODIVSUB       1.850                  -999                   INF
BIODIVSUB2      2.100                  -999                   INF
BIODIVSUB3      3.950                  -999                   INF
BIODIVSUBA      1.400                  -999                   INF
BIODIVSUBF      3.500                  -999                   INF
BIODIVSUBM      2.700                  -999                   INF
BIODIVSUBG      2.700                  -999                   INF
BIODIVSUBC      2.000                  -999                   INF
BIODIVSUBS      5.500                  -999                   INF;
*---------------------------------------------------------------------------------------------------
* Lagt till 1.000 p? fabod for faboden. Antagit 20 ha per fabod
*Change from EURO to SEK 
BPN('GACRSUB','PBAR')    = BPN('GACRSUB','PBAR')    * KURS;
BPN('CATTLESUB','PBAR')  = BPN('CATTLESUB','PBAR')  * KURS;
BPN('ECOSUB','PBAR')     = BPN('ECOSUB','PBAR')     * KURS;
BPN('ES3','PBAR')        = BPN('ES3','PBAR')        * KURS;
BPN('ES4','PBAR')        = BPN('ES4','PBAR')        * KURS;
BPN('ES5','PBAR')        = BPN('ES5','PBAR')        * KURS;
BPN('ES6','PBAR')        = BPN('ES6','PBAR')        * KURS;

*BPN('NATSUB','PBAR')      = BPN('NATSUB','PBAR')      * 1.04;
*BPN('SOWHLTSUB','PBAR')   = BPN('SOWHLTSUB','PBAR')   * 0.70;
*BPN('BIODIVSUB','PBAR')   = BPN('BIODIVSUB','PBAR')   * 0.91;
*BPN('BIODIVSUB2','PBAR')  = BPN('BIODIVSUB2','PBAR')  * 0.91;
*BPN('BIODIVSUB3','PBAR')  = BPN('BIODIVSUB3','PBAR')  * 0.91;
*BPN('BIODIVSUBA','PBAR')  = BPN('BIODIVSUBA','PBAR')  * 1.01;
*BPN('BIODIVSUBF','PBAR')  = BPN('BIODIVSUBF','PBAR')  * 1.01;
*BPN('BIODIVSUBM','PBAR')  = BPN('BIODIVSUBM','PBAR')  * 1.01;
*BPN('BIODIVSUBG','PBAR')  = BPN('BIODIVSUBG','PBAR')  * 1.1;
*BPN('BIODIVSUBC','PBAR')  = BPN('BIODIVSUBC','PBAR')  * 0.88;
*BPN('BIODIVSUBS','PBAR')  = BPN('BIODIVSUBS','PBAR')  * 1.40;

*Ad green sub 
*BPN('GACRSUB','PBAR')    = BPN('GACRSUB','PBAR')    * 1.5405;

*Adjust for inflation in long run calculations
BPN(SUPPORTN,'PBAR') $(LONGRUN1)  = BPN(SUPPORTN,'PBAR')  / KPI2;

BPN(PN,'PBAR')        = BPN(PN,'PBAR') *KPI3;
     
 
TABLE BPRN(PR,SDP)  National data for regional product demand parameters
*---------------------------------------------------------------------------------------------------
* Reg.Product...  Parameter.........................................................................

*---------------------------------------------------------------------------------------------------
                 PBAR       QBAR       ELAS        MIN        MAX
BREADGRC         1.89        162       -0.9                  1000
COARSGRC         1.79        222       -0.9                  1000
FLOURC           5.02        450       -0.9                  1000
FPEAS                                              170
*RAPEMEAL
RAPEOILC        14.60        175       -0.9                   300
RAPSKAKA                                            49
POTATOESC        1.35        850       -0.9                  2000 
*SUGARBEETC       0.40       2575       -0.9                  3000
SUGARC           5.45        402       -0.9                   500
EGGC            16.13        152       -0.9                   200
RIDING                                             363        400
KMILKC           6.33        923       -0.9                  1500
CHEESEC         46.07        200       -0.9                   300
BUTTERC         49.47         62       -0.9                   100
CREAMC          36.02         67       -0.9                   120
DRYMILKC        36.47         15       -0.9                    40
BEEFC           54.81        240       -0.9                   275
PORKC           25.98        295       -0.9                   500
PLTRYMEATC      33.62        250       -0.9                   500
SHEEPC          64.87         17       -0.9                    20
WILDMEATC       56.95         20       -0.9                   500
FISHC           37.48        180       -0.9                   300
FRUITC          12.64        940       -0.9                  2000
VEGETABC        12.64        845       -0.9                  2000
WBERRYC          0.15         10       -0.9                   100   	 
EPEAS            1.75                  -999                  1000
EGRAIN           0.80         50       -999                  5000
ERAPE            5.20          9       -999                  1000
ESUGARB          0.00                  -999                     0
EPOTATOES        2.20         35       -0.1                   100
EMILK            0.70        460       -0.5                  1000
EBEEF            3.00         22       -0.5                   100
EPORK           14.00        4.3       -0.5                    20
ESHEEPM          2.50        2.0       -0.5                    20
EEGG            10.50       20.0       -0.5                   100
ENERGY          0.001                  -999       38.83       400
PROTEIN         0.001                  -999         228      2000
PROTEINA        0.001                  -999         114      2000
FAT             0.001                  -999         262      2000
CARBOH          0.001                  -999        1028      8000;
*---------------------------------------------------------------------------------------------------
* Notes: Elasticities are taken from USMP. Values rounded to the nearest tenth.  Dry milk
* elasticity is assumed. Elasticities are assumed equal across regions and are assumed
* to hold at the prices and quantities shown.
* Livestock subsidies are in Euro and later changed to SEK.
* Prices for sugar, egg and eco are updated to 2019
* Volum wild breey estimated, withdran from fruit
* Consumption uppdated to 2023/2022. Data from SJV

BPRN(PR,'PBAR') = BPRN(PR,'PBAR') / KPI3;
*Omr�kning tillbaka sker l�ngre ner. Inlags s� f�r att inte gl�mmas bort. Eko blir lite fel

*Kostkrav LV medel. Nedan minskat med import annat an SASM.
*All import i syd. Korrigeras langre ner med regionala transporter

*BPRN('ENERGY','MIN')  = BPRN('ENERGY','MIN')  -(11.4)*RED;
*BPRN('PROTEIN','MIN') = BPRN('PROTEIN','MIN') -  (52)*RED;
*BPRN('FAT','MIN')     = BPRN('FAT','MIN')     -  (82)*RED;
*BPRN('CARBOH','MIN')  = BPRN('CARBOH','MIN')  - (304)*RED;
* Langre ner minskat med halv prod annat ?n SASM

* Adjust quantities to increased population baserat pa prognos fran SCB
BPRN(PR,'QBAR') $(LONGRUN) = BPRN(PR,'QBAR') * 1.01**YR;
* Adjust milk to reduced consumption
BPRN('KMILKC','QBAR') $(LONGRUN) = BPRN('KMILKC','QBAR') * 0.985**YR;
BPRN('CREAMC','QBAR') $(LONGRUN) = BPRN('CREAMC','QBAR') * 0.985**YR;
BPRN('BUTTERC','QBAR') $(LONGRUN) = BPRN('BUTTERC','QBAR') * 0.985**YR;

* Adjust sugar beets to long run prices
*BPRN('SUGARC','PBAR') $(LONGRUN1) = BPRN('SUGARC','PBAR') * 1.350;

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


PARAMETER POP(R) Population separated in regions 

   /R1    507
    R2    923
    R3   3619
    R4   1853
    R5   1264
    R6   1242/;


PARAMETER BPR(R,PR,SDP)  Regional product demand parameters;

* Calculate regional demand in proportion to population
BPR(R,PR,'PBAR') = BPRN(PR,'PBAR');
BPR(R,PR,'QBAR') = BPRN(PR,'QBAR')*POP(R)/9408;
BPR(R,PR,'ELAS') = BPRN(PR,'ELAS');
BPR(R,PR,'MIN')  = BPRN(PR,'MIN') *POP(R)/9408;
BPR(R,PR,'MAX')  = BPRN(PR,'MAX') *POP(R)/9408;

* Kostkrav reduceras for prod utanfor SASM. Halverad i syd.
* Prod annat fordelas lika i de sex regionerna. Battre an fordelning efter befolkning
*BPR(R1TO2,'ENERGY','MIN')  = BPR(R1TO2,'ENERGY','MIN')  - 0.982/6;
*BPR(R1TO2,'PROTEIN','MIN') = BPR(R1TO2,'PROTEIN','MIN') - 14.2/6;
*BPR(R1TO2,'FAT','MIN')     = BPR(R1TO2,'FAT','MIN')     -  6.0/6;
*BPR(R1TO2,'CARBOH','MIN')  = BPR(R1TO2,'CARBOH','MIN')  - 26.8/6;

*BPR(R3TO6,'ENERGY','MIN')  = BPR(R3TO6,'ENERGY','MIN')  - 0.982/6*RED;
*BPR(R3TO6,'PROTEIN','MIN') = BPR(R3TO6,'PROTEIN','MIN') - 14.2/6*RED;
*BPR(R3TO6,'FAT','MIN')     = BPR(R3TO6,'FAT','MIN')     -  6.0/6*RED;
*BPR(R3TO6,'CARBOH','MIN')  = BPR(R3TO6,'CARBOH','MIN')  - 26.8/6*RED;

BPR(R,PR,'PBAR') = BPR(R,PR,'PBAR') * KPI3;


TABLE BPSF(R,SR,PS)  Subregional demand of products with fixed demand
*---------------------------------------------------------------------------------------------------
*Sub.   Product..........................................................................
*---------------------------------------------------------------------------------------------------
          OTHRCROPPR   ICRPR   MINSHEEP   MINLFOR  MINPAST
R1.SR001     0.207     0.023     2.585     9.958    4.018; 
*---------------------------------------------------------------------------------------------------
BPSF(R,SR,PS) $RSR(R,SR)= BPSF('R1','SR001',PS);


BPSF(R,SR,'MINLFOR') = 0;
*BPSF(R,SR,'MINCACR') = BIS(R,SR,'CROPLAND','MAX')-0.0001;
BPSF(R,SR,'MINPAST') = 0;
BPSF(R,SR,'MINPAST') = BIS(R,SR,'PRMPAST','MAX') + BIS(R,SR,'PRMPASTT','MAX') +
                        BIS(R,SR,'PRMPASTN','MAX') + BIS(R,SR,'PRMPASTH','MAX') +
                        BIS(R,SR,'PRMPASTHT','MAX')+ BIS(R,SR,'PRMPASTHN','MAX') +
                        BIS(R,SR,'PRMALV','MAX')   + BIS(R,SR,'PRMFOR','MAX') +
                        BIS(R,SR,'PRMMOS','MAX')   + BIS(R,SR,'PRMLOW','MAX') +
                        BIS(R,SR,'PRMCHAL','MAX')  + BIS(R,SR,'PRMMEAD','MAX');
                       
BPSF(R,SR,'MINPAST') = BPSF(R,SR,'MINPAST')*0.67968*0;

BPSF(R,SR,'MINSHEEP') = BISF(R,SR,'SHEEPFAC') * 0.5;
BPSF(R,SR,'OTHRCROPPR') = BISF(R,SR,'CROPLAND') * 0.0105;
BPSF(R,SR,'ICRPR') = BISF(R,SR,'CROPLAND') * 0.0022;
BPSF(R,SR,'UNDEFUSE') = BISF(R,SR,'CROPLAND')     * 0.0043;
BPSF(R,SR,'MINSALIX') = BISF(R,SR,'MAXSALIX')     *0.999; 

* Adjust to data for 2010 from agricultural yearbook
*BPSF(R,SR,'OTHRCROPPR') = BPSF(R,SR,'OTHRCROPPR') *0.605;
*BPSF(R,SR,'ICRPR') = BPSF(R,SR,'ICRPR')           *0.589;
*BPSF(R,SR,'MINSHEEP') = BPSF(R,SR,'MINSHEEP')     *1.302;
*BPSF(R,SR,'UNDEFUSE') = BISF(R,SR,'CROPLAND')     * 0.008;
*BPSF(R,SR,'MINSALIX') = BISF(R,SR,'MAXSALIX')     *0.999; 


TABLE BPSI(SR,PS)  Subregional prices of infinite elastic products
*---------------------------------------------------------------------------------------------------
*Sub.   Product..........................................................................
*---------------------------------------------------------------------------------------------------
           COMP4SUB  COMPSUB  COMPSUBL  ICRPR
SR001*SR002   1.900  0.374      5.561     
SR003*SR005   1.900  0.377      4.444     
SR006*SR008   1.900  0.358      3.792     
SR009*SR011   1.900  0.106      3.504     
SR012*SR015   1.900  0.015      3.097     
SR016*SR023   0.800  0.000      1.813     
SR024*SR032   0.800  0.000      1.304     0.300
SR033*SR042   0.800  0.008      1.160     0.300
SR043*SR053   0.800  0.000      0.852     0.300
SR054*SR060   0.800  0.000      0.793     0.300
SR061*SR067   0.800  0.000      1.080     0.300
SR068         0.800  0.000      1.490     0.300
SR069*SR073                               0.300
SR074*SR077                               0.600
SR078*SR081                               0.700;
*---------------------------------------------------------------------------------------------------
* COMPSUB is kompensationsbidraget (LFA). Is is uppdated to 2023. Regression kompstod 2023.xls


* omit supports
*BPSI(SR,'COMP4SUB') = 0;
*BPSI(SR,'COMPSUB')  = 0;
*BPSI(SR,'COMPSUBL') = 0;

BPSI(SR,SUPPORTS)$LONGRUN1 = BPSI(SR,SUPPORTS) / KPI2;

PARAMETER BPS(R,SR,PS,SDP)  Subregional product demand parameters;

BPS(R,SR,PS,'PBAR')$RSR(R,SR) = BPSI(SR,PS);
BPS(R,SR,PS,'ELAS')$(RSR(R,SR)$(BPSI(SR,PS) GT 0)) = -999;
BPS(R,SR,PS,'MAX') $(RSR(R,SR)$(BPSI(SR,PS) GT 0)) = INF;
BPS(R,SR,PS,'MIN') $RSR(R,SR) = BPSF(R,SR,PS);

BPS(R,SR,'ICRPR','MAX') $RSR(R,SR) = BPSF(R,SR,'ICRPR')*2;

BPS(R,SR,PS,'PBAR') = BPS(R,SR,PS,'PBAR') * KPI3;


TABLE DT(RS,RD)  Distance from source region to destination region
*---------------------------------------------------------------------------------------------------
* From region  to region............................................................................
*---------------------------------------------------------------------------------------------------
                      R1         R2         R3         R4         R5         R6
           R1                 0.422      0.693      0.985      1.034      1.197
           R2      0.422                 0.268      0.614      0.662      0.826
           R3      0.693      0.268                 0.472      0.441      0.605
           R4      0.985      0.614      0.472                 0.235      0.264
           R5      1.034      0.662      0.441      0.235                 0.182
           R6      1.197      0.826      0.605      0.264      0.182           ;
*---------------------------------------------------------------------------------------------------
* Notes: Distances measured from the following cities: R1: Umea, R2:Bollnas, R3:Stockholm,
* R4:Goteborg, R5:Vaxjo, R6:Lund
 
 
PARAMETER UT(IP)  Unit transportation cost per 1000 kilometers

 /GRAINSEED  0.440,  PEASSEED   0.440,  POTATOSEED 0.440,  BETFOR     0.200,  HP-MASSA   0.200,
  BREADGRAIN 0.200,  COARSGRAIN 0.100,  FEEDGRAIN  0.100,  OILGRAIN   0.200,
  POTATOES   0.400,  RAPEMEAL   0.200,  RAPSKAKA   0.200,  PEAS       0.200,  WHITESUGAR 0.200,
  DCALFM     0.250,  DCALFF     0.250,  PIGLETS    0.100,  SLGHSHEEP  0.480,  EGG        0.480,
  SKIMMILK   0.480,  MILKFAT    0.480,  KMILK      0.480,  CHEESE     0.480,  BUTTER     0.480,
  CREAM      0.480,  DRYMILK    0.480,  BEEF       0.480,  PORK       0.480,  PLTRYMEAT  0.480
  FLOUR      0.200,  DRYMILK2   0.480,  SLGHBEEF   0.960,  SLGHPORK   0.960,  SLGHPLTRY  0.960
  WILDMEAT   0.480,  FISH       0.480,  FRUIT      0.480,  VEGETAB    0.480,  WBERRY     0.480/;
* Notes: Data are based on information from VASTAB, a transport company. Livestock are based on
*        fees from slaughter companies.
 
UT(TRP) = UT(TRP) + 0.001;
* Adds cost for all transport activities to avoid different patterns with same cost
UT(TRP) = UT(TRP) * KPI3;


TABLE BXR(R,PR,TRD)  Export parameters for regional products
*---------------------------------------------------------------------------------------------------
* Reg.Product...  Parameter.........................................................................
*---------------------------------------------------------------------------------------------------
                     WPRICE     TARIFF    SUBSIDY        MIN        MAX
R4*R6.BREADGRAIN      1.650                                      782.707
R4*R6.COARSGRAIN      1.470                                          0
R4*R6.OILGRAIN        3.960                                       80.275
R4*R6.RAPEOIL         9.028                                          0
R4*R6.WHITESUGAR      3.870                                          0
R4*R6.CHEESE         31.946                                          0
R4*R6.BUTTER         43.942                                          0
R4*R6.DRYMILK        20.863                                       52.825
R4*R6.DRYMILK2       35.863                                       52.825
R4*R6.BEEF           42.070                                          0
R4*R6.PORK           17.870                                          0
R4*R6.PLTRYMEAT       8.350                                          0
R4*R6.SLGHSHEEP      52.040                                          0
R4*R6.EGG            12.570                                          0;
*---------------------------------------------------------------------------------------------------
* Export price for grain and oilgrain is Swedish average producer price 2017-2021, SJV.
* Export price for rapeseed oil is EU market price 2017-2021 from OECD minus transport 1000 km.
* Export price for cheese, butter and drymilk is EU market price 2017-2021 from OECD.
* Export price egg, beef, sheep, poutry and pork is import price minus transport 1000 km
* Slaughter marginal is added below for beef and pork.

 
TABLE BMR(R,PR,TRD)  Import parameters for regional products
*---------------------------------------------------------------------------------------------------
* Reg.Product...  Parameter.........................................................................

*---------------------------------------------------------------------------------------------------

                     WPRICE     TARIFF    SUBSIDY        MIN        MAX
R4*R6.BREADGRAIN      1.850                                           0
R4*R6.COARSGRAIN      1.570                                           0
R4*R6.PEAS            2.100                                           0
R4*R6.EPEAS           1.500                                           0
R4*R6.OILGRAIN        4.160                                           0
R4*R6.RAPEOIL         9.508                                           0
R4*R6.POTATOES        2.860                                           0
R4*R6.WHITESUGAR      4.350                                         616.653
R4*R6.CHEESE         32.426                                         180.0
R4*R6.BUTTER         44.422                                           2.239
R4*R6.DRYMILK        21.343                                           0
R4*R6.DRYMILK2       36.343                                           0
R4*R6.BEEF           42.550                                          96.358
R4*R6.PORK           18.350                                          66.586
R4*R6.PLTRYMEAT       9.830                                         112.8
R4*R6.SLGHSHEEP      52.520                                           7.112
R4*R6.EGG            13.050                                          14.806
R4*R6.WILDMEAT        50.00                                           3.396
R4*R6.FISH            15.00                                         287.674
R4*R6.FRUIT           10.00                                         921.679
R4*R6.VEGETAB         10.00                                         503.888
R4*R6.WBERRY          30.00                                           0
R4*R6.EGRAIN          1.000                                           0;
*---------------------------------------------------------------------------------------------------
* Import price for grain and oilgrain is export price plus transport cost 1000 km
* Import price for rapeseed oil is EU market price 2017-2021 from OECD.
* Import price for cheese, butter and drymilk is EU market price 2017-2021 from OECD  plus
* transport cost 1000 km.
* Import price egg, beef, sheep, poutry and pork is market price 2017-2021 in Sweden. Data from
* LRF Uppfoljning

BXR(R,PR,'MAX') = 9999.9;
BMR(R,PR,'MAX') = 9999.9;
BMR(R,'CHEESE','MAX')    = 180.0;
BMR(R,'PLTRYMEAT','MAX') = 112.8;

BXR(R,PR,'MAX') = BXR(R,PR,'MAX')/3*RED;
BMR(R,PR,'MAX') = BMR(R,PR,'MAX')/3*RED;

* Nominal price change in EU 2013-2017 to 2019. In euro (meats in SEK with fixed exchange rate)
* Oligrain and dairy are adjusted for exchange rate (partly for oilgrain)
$ontext
BXR(R,'BREADGRAIN','WPRICE') = BXR(R,'BREADGRAIN','WPRICE') * 1.045;
BMR(R,'BREADGRAIN','WPRICE') = BMR(R,'BREADGRAIN','WPRICE') * 1.045;
BXR(R,'COARSGRAIN','WPRICE') = BXR(R,'COARSGRAIN','WPRICE') * 1.121;
BMR(R,'COARSGRAIN','WPRICE') = BMR(R,'COARSGRAIN','WPRICE') * 1.121;
BXR(R,'OILGRAIN','WPRICE')   = BXR(R,'OILGRAIN','WPRICE')   * 1.073 * 1.075;
BMR(R,'OILGRAIN','WPRICE')   = BMR(R,'OILGRAIN','WPRICE')   * 1.073 * 1.075;
BXR(R,'RAPEOIL','WPRICE')    = BXR(R,'RAPEOIL','WPRICE')    * 0.989 * 1.075;
BMR(R,'RAPEOIL','WPRICE')    = BMR(R,'RAPEOIL','WPRICE')    * 0.989 * 1.075;
BXR(R,'CHEESE','WPRICE')     = BXR(R,'CHEESE','WPRICE')     * 1.030 * 1.15;
BMR(R,'CHEESE','WPRICE')     = BMR(R,'CHEESE','WPRICE')     * 1.030 * 1.15;
BXR(R,'BUTTER','WPRICE')     = BXR(R,'BUTTER','WPRICE')     * 1.034;
BMR(R,'BUTTER','WPRICE')     = BMR(R,'BUTTER','WPRICE')     * 1.034;
BXR(R,'DRYMILK','WPRICE')    = BXR(R,'DRYMILK','WPRICE')    * 0.933 * 1.15;
BMR(R,'DRYMILK','WPRICE')    = BMR(R,'DRYMILK','WPRICE')    * 0.933 * 1.15;
BXR(R,'BEEF','WPRICE')       = BXR(R,'BEEF','WPRICE')       - 1.802;
BMR(R,'BEEF','WPRICE')       = BMR(R,'BEEF','WPRICE')       - 1.802;
BXR(R,'PORK','WPRICE')       = BXR(R,'PORK','WPRICE')       + 0.996;
BMR(R,'PORK','WPRICE')       = BMR(R,'PORK','WPRICE')       + 0.996;
BXR(R,'PLTRYMEAT','WPRICE')  = BXR(R,'PLTRYMEAT','WPRICE')  + 1.250;
BMR(R,'PLTRYMEAT','WPRICE')  = BMR(R,'PLTRYMEAT','WPRICE')  + 1.250;
BXR(R,'SLGHSHEEP','WPRICE')  = BXR(R,'SLGHSHEEP','WPRICE')  * 0.982;
BMR(R,'SLGHSHEEP','WPRICE')  = BMR(R,'SLGHSHEEP','WPRICE')  * 0.982;
BXR(R,'EGG','WPRICE')        = BXR(R,'EGG','WPRICE')        * 0.500;
BMR(R,'EGG','WPRICE')        = BMR(R,'EGG','WPRICE')        * 0.929;
$offtext
BXR(R,'BEEF','WPRICE')     = BXR(R,'BEEF','WPRICE')     + 1.23;
BMR(R,'BEEF','WPRICE')     = BMR(R,'BEEF','WPRICE')     + 1.23;
BXR(R,'PORK','WPRICE')     = BXR(R,'PORK','WPRICE')     + 2.55;
BMR(R,'PORK','WPRICE')     = BMR(R,'PORK','WPRICE')     + 2.55;
BXR(R,'PLTRYMEAT','WPRICE')= BXR(R,'PLTRYMEAT','WPRICE')+ 15.39;
BMR(R,'PLTRYMEAT','WPRICE')= BMR(R,'PLTRYMEAT','WPRICE')+ 15.39;

* Changes to 2025 from (2017-2021) based on Outlook 2024
BXR(R,'BREADGRAIN','WPRICE') $LONGRUN1 = BXR(R,'BREADGRAIN','WPRICE') * 0.914;
BMR(R,'BREADGRAIN','WPRICE') $LONGRUN1 = BMR(R,'BREADGRAIN','WPRICE') * 0.914;
BXR(R,'COARSGRAIN','WPRICE') $LONGRUN1 = BXR(R,'COARSGRAIN','WPRICE') * 0.953;
BMR(R,'COARSGRAIN','WPRICE') $LONGRUN1 = BMR(R,'COARSGRAIN','WPRICE') * 0.953;
BXR(R,'OILGRAIN','WPRICE')   $LONGRUN1 = BXR(R,'OILGRAIN','WPRICE')   * 0.884;
BMR(R,'OILGRAIN','WPRICE')   $LONGRUN1 = BMR(R,'OILGRAIN','WPRICE')   * 0.884;
BXR(R,'RAPEOIL','WPRICE')    $LONGRUN1 = BXR(R,'RAPEOIL','WPRICE')    * 0.951;
BXR(R,'CHEESE','WPRICE')     $LONGRUN1 = BXR(R,'CHEESE','WPRICE')     * 0.986 * 1.1;
BMR(R,'CHEESE','WPRICE')     $LONGRUN1 = BMR(R,'CHEESE','WPRICE')     * 0.986 * 1.1;
BXR(R,'BUTTER','WPRICE')     $LONGRUN1 = BXR(R,'BUTTER','WPRICE')     * 0.890;
BMR(R,'BUTTER','WPRICE')     $LONGRUN1 = BMR(R,'BUTTER','WPRICE')     * 0.890;
BXR(R,'DRYMILK','WPRICE')    $LONGRUN1 = BXR(R,'DRYMILK','WPRICE')    * 1.020;
BMR(R,'DRYMILK','WPRICE')    $LONGRUN1 = BMR(R,'DRYMILK','WPRICE')    * 1.020;
BXR(R,'DRYMILK2','WPRICE')   $LONGRUN1 = BXR(R,'DRYMILK2','WPRICE')   * 1.020;
BMR(R,'DRYMILK2','WPRICE')   $LONGRUN1 = BMR(R,'DRYMILK2','WPRICE')   * 1.020;
*BXR(R,'BEEF','WPRICE')       $LONGRUN1 = BXR(R,'BEEF','WPRICE')       + 1.422;
*BMR(R,'BEEF','WPRICE')       $LONGRUN1 = BMR(R,'BEEF','WPRICE')       + 1.422;
BXR(R,'PORK','WPRICE')       $LONGRUN1 = BXR(R,'PORK','WPRICE')       - 0.208;
BMR(R,'PORK','WPRICE')       $LONGRUN1 = BMR(R,'PORK','WPRICE')       - 0.208;
BXR(R,'PLTRYMEAT','WPRICE')  $LONGRUN1 = BXR(R,'PLTRYMEAT','WPRICE')  - 0.245;
BMR(R,'PLTRYMEAT','WPRICE')  $LONGRUN1 = BMR(R,'PLTRYMEAT','WPRICE')  - 0.245;
BXR(R,'SLGHSHEEP','WPRICE')  $LONGRUN1 = BXR(R,'SLGHSHEEP','WPRICE')  * 0.987;
BMR(R,'SLGHSHEEP','WPRICE')  $LONGRUN1 = BMR(R,'SLGHSHEEP','WPRICE')  * 0.987;
BXR(R,'EGG','WPRICE')        $LONGRUN1 = BXR(R,'EGG','WPRICE')        * 0.987;
BMR(R,'EGG','WPRICE')        $LONGRUN1 = BMR(R,'EGG','WPRICE')        * 0.987;
* Milk products are reduced i price compared to Outlook to make level more realistic.

BXR(R,PR,'WPRICE')       = BXR(R,PR,'WPRICE') * KPI3;
BMR(R,PR,'WPRICE')       = BMR(R,PR,'WPRICE') * KPI3;

PARAMETER MS(SR)    Milk subsidy per unit;
MS(SR01) = 1.64; 
MS(SR02) = 1.33; 
MS(SR03) = 1.08; 
MS(SR04a)= 0.73; 
MS(SR04b)= 0.73; 
MS(SR05) = 0.48; 

PARAMETER DPTR(P)  Dairy processing transfer receipt  /MILK 0.615/;

PARAMETER DPTC(P)  Diary processing transfer cost 
 /KMILK 1.000, CHEESE  0.000, CREAM 8.000, BUTTER  0.000/;

DPTR('MILK') $LONGRUN1 = 0.530;
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
 

* Calculate unit transportation costs
PARAMETER CT(RS,RD,IP)  Unit transportation cost;
  CT(RS,RD,IP) $TIP(RS,RD,IP) = DT(RS,RD) * UT(IP);

* Assign sets INES, INFS, IRES, IRFS, ISES, ISFS, PNED, PNFD, PRED, PRFD, PSED AND PSFD 
  INES(IN) $(BIN(IN,'PBAR') GT 0) = YES;
  INFS(IN) = YES $(NOT INES(IN));
  IRES(R,IR) = RIR(R,IR) $(BIR(R,IR,'PBAR') GT 0);
  IRFS(R,IR) = RIR(R,IR) - IRES(R,IR);
  ISES(R,SR,IS) = RSRIS(R,SR,IS) $(BIS(R,SR,IS,'PBAR') GT 0);
  ISFS(R,SR,IS) = RSRIS(R,SR,IS) - ISES(R,SR,IS);
 
  PNED(PN) $(BPN(PN,'PBAR') GT 0) = YES;
  PNFD(PN) = YES $(NOT PNED(PN));
  PRED(R,PR) = RPR(R,PR) $(BPR(R,PR,'PBAR') GT 0);
  PRFD(R,PR) = RPR(R,PR) - PRED(R,PR);
  PSED(R,SR,PS) = RSRPS(R,SR,PS) $(BPS(R,SR,PS,'PBAR') GT 0);
  PSFD(R,SR,PS) = RSRPS(R,SR,PS) - PSED(R,SR,PS);

* Calculate input supply and product demand intercepts and slopes
 
  BIN(IN,'SLOPE') $(INES(IN)$(BIN(IN,'ELAS') GE 99)) = 0.0;
  BIN(IN,'INTERCEPT') $(INES(IN)$(BIN(IN,'ELAS') GE 99)) = BIN(IN,'PBAR');
  BIN(IN,'SLOPE') $(INES(IN)$((BIN(IN,'ELAS') LT 99) AND (BIN(IN,'SLOPE') EQ 0)))
                   = BIN(IN,'PBAR')/(BIN(IN,'ELAS')*BIN(IN,'QBAR'));
  BIN(IN,'INTERCEPT') $(INES(IN)$((BIN(IN,'ELAS') LT 99) AND (BIN(IN,'INTERCEPT') EQ 0)))
                       = BIN(IN,'PBAR') - BIN(IN,'SLOPE')*BIN(IN,'QBAR');
  BIR(R,IR,'SLOPE') $(IRES(R,IR)$(BIR(R,IR,'ELAS') GE 99)) = 0.0;
  BIR(R,IR,'INTERCEPT') $(IRES(R,IR)$(BIR(R,IR,'ELAS') GE 99)) = BIR(R,IR,'PBAR');
  BIR(R,IR,'SLOPE') $(IRES(R,IR)$((BIR(R,IR,'ELAS') LT 99) AND (BIR(R,IR,'SLOPE') EQ 0)))
                   = BIR(R,IR,'PBAR')/(BIR(R,IR,'ELAS')*BIR(R,IR,'QBAR'));
  BIR(R,IR,'INTERCEPT') $(IRES(R,IR)$((BIR(R,IR,'ELAS') LT 99) AND (BIR(R,IR,'INTERCEPT') EQ 0)))
                       = BIR(R,IR,'PBAR') - BIR(R,IR,'SLOPE')*BIR(R,IR,'QBAR');
  BIS(R,SR,IS,'SLOPE') $(ISES(R,SR,IS)$(BIS(R,SR,IS,'ELAS') GE 99)) = 0.0;
  BIS(R,SR,IS,'INTERCEPT') $(ISES(R,SR,IS)$(BIS(R,SR,IS,'ELAS') GE 99)) = BIS(R,SR,IS,'PBAR');
  BIS(R,SR,IS,'SLOPE')
      $(ISES(R,SR,IS)$((BIS(R,SR,IS,'ELAS') LT 99) AND (BIS(R,SR,IS,'SLOPE') EQ 0) AND
          (BIS(R,SR,IS,'QBAR') GT 0)))
                       = BIS(R,SR,IS,'PBAR')/(BIS(R,SR,IS,'ELAS')*BIS(R,SR,IS,'QBAR'));
  BIS(R,SR,IS,'INTERCEPT')
      $(ISES(R,SR,IS)$((BIS(R,SR,IS,'ELAS') LT 99) AND (BIS(R,SR,IS,'INTERCEPT') EQ 0)))
                           = BIS(R,SR,IS,'PBAR') - BIS(R,SR,IS,'SLOPE')*BIS(R,SR,IS,'QBAR');
  BPN(PN,'SLOPE') $(PNED(PN)$(BPN(PN,'ELAS') LE -99)) = 0.0;
  BPN(PN,'INTERCEPT') $(PNED(PN)$(BPN(PN,'ELAS') LE -99)) = BPN(PN,'PBAR');
  BPN(PN,'SLOPE') $(PNED(PN)$((BPN(PN,'ELAS') GT -99) AND (BPN(PN,'SLOPE') EQ 0)))
                  = BPN(PN,'PBAR')/(BPN(PN,'ELAS')*BPN(PN,'QBAR'));
  BPN(PN,'INTERCEPT') $(PNED(PN)$((BPN(PN,'ELAS') GT -99) AND (BPN(PN,'INTERCEPT') EQ 0)))
                      = BPN(PN,'PBAR') - BPN(PN,'SLOPE')*BPN(PN,'QBAR');
  BPR(R,PR,'SLOPE') $(PRED(R,PR)$(BPR(R,PR,'ELAS') LE -99)) = 0.0;
  BPR(R,PR,'INTERCEPT') $(PRED(R,PR)$(BPR(R,PR,'ELAS') LE -99)) = BPR(R,PR,'PBAR');
  BPR(R,PR,'SLOPE') $(PRED(R,PR)$((BPR(R,PR,'ELAS') GT -99) AND (BPR(R,PR,'SLOPE') EQ 0)))
                   = BPR(R,PR,'PBAR')/(BPR(R,PR,'ELAS')*BPR(R,PR,'QBAR'));
  BPR(R,PR,'INTERCEPT') $(PRED(R,PR)$((BPR(R,PR,'ELAS') GT -99) AND (BPR(R,PR,'INTERCEPT') EQ 0)))
                       = BPR(R,PR,'PBAR') - BPR(R,PR,'SLOPE')*BPR(R,PR,'QBAR');
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

DISPLAY $OC('DSETS') PRED, PRFD, PSED, PSFD, IRES, IRFS, ISES, ISFS,
                     RIR, RSR, RSRIS, RPR, RSRPS, PREX, PRIM, RPREX, RPRIM, RSRAS, T, TIP;
 
OPTION BIS:3:3:1 DISPLAY $OC('SPARM') BIN;
OPTION BIR:3:2:1 DISPLAY $OC('SPARM') BIR;
OPTION BIS:3:3:1 DISPLAY $OC('SPARM') BIS;
 
OPTION BPR:3:2:1 DISPLAY $OC('DPARM') BPN;
OPTION BPR:3:2:1 DISPLAY $OC('DPARM') BPR;
OPTION BPS:3:3:1 DISPLAY $OC('DPARM') BPS;
 
DISPLAY $OC('PRODIO') EAS;
 
DISPLAY $OC('UTCOST') CT;
 
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

SUPPLYIN.LO(IN) $INES(IN) = BIN(IN,'MIN');
SUPPLYIN.UP(IN) $INES(IN) = BIN(IN,'MAX');
SUPPLYIR.LO(R,IR) $IRES(R,IR) = BIR(R,IR,'MIN');
SUPPLYIR.UP(R,IR) $IRES(R,IR) = BIR(R,IR,'MAX');
SUPPLYIS.LO(R,SR,IS) $ISES(R,SR,IS) = BIS(R,SR,IS,'MIN');
SUPPLYIS.UP(R,SR,IS) $ISES(R,SR,IS) = BIS(R,SR,IS,'MAX');
DEMANDPN.LO(PN) $PNED(PN) = BPN(PN,'MIN');
DEMANDPN.UP(PN) $PNED(PN) = BPN(PN,'MAX');
DEMANDPR.LO(R,PR) $PRED(R,PR) = BPR(R,PR,'MIN');
DEMANDPR.UP(R,PR) $PRED(R,PR) = BPR(R,PR,'MAX');
DEMANDPS.LO(R,SR,PS) $PSED(R,SR,PS) = BPS(R,SR,PS,'MIN');
DEMANDPS.UP(R,SR,PS) $PSED(R,SR,PS) = BPS(R,SR,PS,'MAX');
EXPORTRP.LO(R,PREX) $RPREX(R,PREX) = BXR(R,PREX,'MIN');
EXPORTRP.UP(R,PREX) $RPREX(R,PREX) = BXR(R,PREX,'MAX');
IMPORTPR.LO(R,PRIM) $RPRIM(R,PRIM) = BMR(R,PRIM,'MIN');
IMPORTPR.UP(R,PRIM) $RPRIM(R,PRIM) = BMR(R,PRIM,'MAX');

SUPPLYIS.L(R,SR,IS) $ISES(R,SR,IS) = BIS(R,SR,IS,'QBAR');
SUPPLYIR.L(R,IR) $IRES(R,IR) = BIR(R,IR,'QBAR');
DEMANDPS.L(R,SR,PS) $PSED(R,SR,PS) = BPS(R,SR,PS,'QBAR');
DEMANDPR.L(R,PR) $PRED(R,PR) = BPR(R,PR,'QBAR');

$ontext
* Limit transports from south to half
TRANIP.UP(RS,'R1',IP)=0;
TRANIP.UP(RS,'R2',IP)=0;
TRANIP.UP('R1',RD,IP)=0;
TRANIP.UP('R2',RD,IP)=0;
TRANIP.UP('R1','R2',IP)= 1000;
TRANIP.UP('R2','R1',IP)=1000;
TRANIP.UP('R3','R2','RAPSKAKA')=1000;
TRANIP.UP('R2','R3','DCALFM')=8.468;
TRANIP.UP('R2','R3','DCALFF')=2.586;
TRANIP.UP('R3','R2','BEEF')=13.498;
TRANIP.UP('R3','R2','BREADGRAIN')=42.114;
TRANIP.UP('R3','R2','BUTTER')=1.507;
TRANIP.UP('R3','R2','CHEESE')=6.326;
TRANIP.UP('R3','R2','COARSGRAIN')=118.742;
TRANIP.UP('R3','R2','EGG')=6.891;
TRANIP.UP('R3','R2','MILKFAT')=1.342;
TRANIP.UP('R3','R2','PEAS')=10.082;
TRANIP.UP('R3','R2','PIGLETS')=4.7;
TRANIP.UP('R3','R2','PLTRYMEAT')=17.340;
TRANIP.UP('R3','R2','PORK')=19.315;
TRANIP.UP('R3','R2','POTATOES')=62.284;
TRANIP.UP('R3','R2','RAPEMEAL')=12.304;
TRANIP.UP('R3','R2','SLGHSHEEP')=0.237;
TRANIP.UP('R6','R2','SUGARBEET')=152.916;

TRANIP.UP('R3','R2','ENERGY') =   3.143 - 0.459;
TRANIP.UP('R3','R2','PROTEIN')=  22.518 - 5.474;
TRANIP.UP('R3','R2','FAT')    =  25.745 - 9.276;
TRANIP.UP('R3','R2','CARBOH') = 103.600 - 1.683;

TRANIP.UP(RS,RD,IP) = TRANIP.UP(RS,RD,IP)*2*RED;
$offtext
* Nutrients are calculated for maximum products.
* Transport of nutrients are reduced for part of import that is applyed in north.
* In SASM import is in South and transported to North


* Limit investments in new facilities to quarter amount in 2010 addition of 1 is to avoid 0 no limit
PRODSR.UP(R,SR,'DAIRYFEXN') $RSRAS(R,SR,'DAIRYFEXN') = BISF(R,SR,'DAIRYFAC')* (0.03*YR) + 0.001;
PRODSR.UP(R,SR,'BEEFCFEXN') $RSRAS(R,SR,'BEEFCFEXN') = BISF(R,SR,'BEEFCFAC')* (0.03*YR) + 0.001;
PRODSR.UP(R,SR,'BULLFEXN')  $RSRAS(R,SR,'BULLFEXN')  = BISF(R,SR,'BULLFAC') * (0.03*YR) + 0.001;
PRODSR.UP(R,SR,'SOWFEXN')   $RSRAS(R,SR,'SOWFEXN')   = BISF(R,SR,'SOWFAC')  * (0.03*YR) + 0.001;
PRODSR.UP(R,SR,'SWINEFEXN') $RSRAS(R,SR,'SWINEFEXN') = BISF(R,SR,'SWINEFAC')* (0.03*YR) + 0.019;
PRODSR.UP(R,SR,'PLTRYFEXN') $RSRAS(R,SR,'PLTRYFEXN') = BISF(R,SR,'PLTRYFAC')* (0.03*YR) + 0.001;
PRODSR.UP(R,SR,'CHICKFEXN') $RSRAS(R,SR,'CHICKFEXN') = BISF(R,SR,'CHICKFAC')* (0.03*YR) + 0.001;

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

PRODSR.UP(R,SR,INVEST) $(NOT LONGRUN) = 0;

PRODSR.UP(R,SR,'ICR') = BPSF(R,SR,'ICRPR')*1.5;
PRODSR.UP(R,SR,'NOUSE') = BISF(R,SR,'CROPLAND')*0.0044;
*PRODSR.UP(R,SR,'ECOPIG') = BISF(R,SR,'SOWFAC')*0.15;

PRODSR.UP(R,SR,'GRAINSIL') = 0;
PRODSR.UP(R,SR,'MAJSSIL') = 0;

PRODSR.L(R,SR,'DCOW3') $RSRAS(R,SR,'DCOW3') = BISF(R,SR,'DAIRYFAC');
PRODSR.L(R,SR1TO4b,'DCOW3') = 0;
PRODSR.L(R,SR1TO4b,'DCOW1') $RSRAS(R,SR1TO4b,'DCOW1') = BISF(R,SR1TO4b,'DAIRYFAC');
PRODSR.L(R,SR,'HEIFER') $RSRAS(R,SR,'HEIFER') = BISF(R,SR,'DAIRYFAC') * 0.333;
PRODSR.L(R,SR,'DAIRYBULL1') $RSRAS(R,SR,'DAIRYBULL1') = BISF(R,SR,'DAIRYFAC') * 0.425;
PRODSR.L(R,SR,'SLGHHEIFER') $RSRAS(R,SR,'SLGHHEIFER') = BISF(R,SR,'DAIRYFAC') * (0.425-0.333);
PRODSR.L(R,SR,'BEEFCATTLE') $RSRAS(R,SR,'BEEFCATTLE') = BISF(R,SR,'BEEFCFAC');
PRODSR.L(R,SR,'SOW1') $RSRAS(R,SR,'SOW1') = BISF(R,SR,'SOWFAC');
PRODSR.L(R,SR,'GILT') $RSRAS(R,SR,'GILT') = BISF(R,SR,'SOWFAC')* 0.4/0.66;
PRODSR.L(R,SR,'SLGHSWINE1') $RSRAS(R,SR,'SLGHSWINE1') = BISF(R,SR,'SWINEFAC');
PRODSR.L(R,SR,'POULTRY') $RSRAS(R,SR,'POULTRY') = BISF(R,SR,'PLTRYFAC');
PRODSR.L(R,SR,'CHICKEN') $RSRAS(R,SR,'CHICKEN') = BISF(R,SR,'CHICKFAC');

PRODSR.LO(R,SR,'HORSES') $RSRAS(R,SR,'HORSES') = BISF(R,SR,'CROPLAND') * 0.1;
PRODSR.L(R,SR,'HORSES')  $RSRAS(R,SR,'HORSES') = BISF(R,SR,'CROPLAND') * 0.15;
PRODSR.UP(R,SR,'HORSES') $RSRAS(R,SR,'HORSES') = BISF(R,SR,'CROPLAND') * 0.25;
PRODSR.LO(R,SR,'POULTRY') $RSRAS(R,SR,'POULTRY') = BISF(R,SR,'PLTRYFAC') * 0.33;

PRODSR.LO(R,SR,AS) $RSRAS(R,SR,AS) = 0.001;
PRODSR.LO(R,SR,INVEST) $(NOT LONGRUN) = 0;
PRODSR.LO(R,SR,'GRAINSIL') = 0;
PRODSR.LO(R,SR,'MAJSSIL') = 0;
PRODSR.LO(R,SR,'HORSES') $RSRAS(R,SR,'HORSES') = BISF(R,SR,'CROPLAND') * 0.1;
PRODSR.LO(R,SR,'POULTRY') $RSRAS(R,SR,'POULTRY') = BISF(R,SR,'PLTRYFAC') * 0.33;

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
 
 
MODEL SASM /ALL/;
 

SOLVE SASM USING NLP MAXIMIZING Z;

PRODSR.LO(R,SR,AS) $RSRAS(R,SR,AS) = 0.000;
PRODSR.LO(R,SR,'HORSES') $RSRAS(R,SR,'HORSES') = BISF(R,SR,'CROPLAND') * 0.1;
PRODSR.LO(R,SR,'POULTRY') $RSRAS(R,SR,'POULTRY') = BISF(R,SR,'PLTRYFAC') * 0.33;
*PRODSR.UP(R,SR,PASTURES) $RSRAS(R,SR,PASTURES) = 0.000;

SOLVE SASM USING NLP MAXIMIZING Z;
* Base year

$ONTEXT
RED = 1.00;
 
EAS(R,SR,ECO,'ACRECO')$RSRAS(R,SR,ECO) = 0;
EAS(R,SR,'EDCOW1','MEDCOW')$RSRAS(R,SR,'EDCOW1') = 0;
EAS(R,SR,'EDCOW2','MEDCOW')$RSRAS(R,SR,'EDCOW2') = 0;
EAS(R,SR,'EDCOW3','MEDCOW')$RSRAS(R,SR,'EDCOW3') = 0;
EAS(R,SR,'EBEEFCATT','MEBEEFCATT')$RSRAS(R,SR,'EBEEFCATT') = 0;
EAS(R,SR,'EBEEFCAT2','MEBEEFCATT')$RSRAS(R,SR,'EBEEFCAT2') = 0;
EAS(R,SR,'ECOPIG','MECOPIG')$RSRAS(R,SR,'ECOPIG') = 0;
EAS(R,SR,'ESHEEP','MESHEEP')$RSRAS(R,SR,'ESHEEP') = 0;
EAS(R,SR,'EPOULTRY','MEPOULTRY')$RSRAS(R,SR,'EPOULTRY') = 0;

EAS(R,SR,CROPS3,'POWER')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'POWER')* (1-(1-RED)*0.5);
EAS(R,SR,CROPS3,'DIESEL')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'DIESEL')* (1-(1-RED)*0.5);
EAS(R,SR,CROPS3,'LABOR')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'LABOR')* (1-(1-RED)*0.4);
EAS(R,SR,CROPS3,PR)$RSRAS(R,SR,CROPS3)      = EAS(R,SR,CROPS3,PR)     * (1-(1-RED)*0.2);
EAS(R,SR,CROPS3,'NITROGEN')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'NITROGEN')* (1-(1-RED)*0.5);
EAS(R,SR,CROPS3,'PHOSPHORUS')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'PHOSPHORUS')* (1-(1-RED)*0.8);
EAS(R,SR,CROPS3,'POTASSIUM')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'POTASSIUM')* (1-(1-RED)*0.5);
EAS(R,SR,CROPS3,'PESTICIDES')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'PESTICIDES')* (1-(1-RED)*0.5);
EAS(R,SR,CROPS3,'HERBICIDES')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'HERBICIDES')* (1-(1-RED)*0.5);
EAS(R,SR,CROPS3,'FUNGICIDES')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'FUNGICIDES')* (1-(1-RED)*0.5);
EAS(R,SR,CROPS3,'INSECTICID')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'INSECTICID')* (1-(1-RED)*0.5);
EAS(R,SR,CROPS3,'GLYFOSAT')$RSRAS(R,SR,CROPS3)   = EAS(R,SR,CROPS3,'GLYFOSAT')  * (1-(1-RED)*0.5);
EAS(R,SR,CROPS3,PR)$RSRAS(R,SR,CROPS3)      = EAS(R,SR,CROPS3,PR)     * (1-(1-RED)*0.2);

EAS(R,SR,ECROPS3,'POWER')$RSRAS(R,SR,ECROPS3) = EAS(R,SR,ECROPS3,'POWER')* (1-(1-RED)*0.5);
EAS(R,SR,ECROPS3,'DIESEL')$RSRAS(R,SR,ECROPS3) = EAS(R,SR,ECROPS3,'DIESEL')* (1-(1-RED)*0.5);
EAS(R,SR,ECROPS3,'LABOR')$RSRAS(R,SR,ECROPS3) = EAS(R,SR,ECROPS3,'LABOR')* (1-(1-RED)*0.4);
EAS(R,SR,ECROPS3,PR)$RSRAS(R,SR,ECROPS3)      = EAS(R,SR,ECROPS3,PR)     * (1-(1-RED)*0.2);
EAS(R,SR,ECROPS3,'ECON')$RSRAS(R,SR,ECROPS3) = EAS(R,SR,ECROPS3,'ECON')* (1-(1-RED)*0.25);
EAS(R,SR,ECROPS3,'ECOP')$RSRAS(R,SR,ECROPS3) = EAS(R,SR,ECROPS3,'ECOP')* (1-(1-RED)*0.40);
EAS(R,SR,ECROPS3,'ECOK')$RSRAS(R,SR,ECROPS3) = EAS(R,SR,ECROPS3,'ECOK')* (1-(1-RED)*0.25);
EAS(R,SR,ECROPS3,PR)$RSRAS(R,SR,ECROPS3) = EAS(R,SR,ECROPS3,PR)* (1-(1-RED)*0.1);

EAS(R,SR,AS,'NITROGEN')$RSRAS(R,SR,AS)   = EAS(R,SR,AS,'NITROGEN')   + EAS(R,SR,AS,'ECON');
EAS(R,SR,AS,'PHOSPHORUS')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'PHOSPHORUS') + EAS(R,SR,AS,'ECOP');
EAS(R,SR,AS,'POTASSIUM')$RSRAS(R,SR,AS)  = EAS(R,SR,AS,'POTASSIUM')  + EAS(R,SR,AS,'ECOK');

EAS(R,SR,AS,'ECON') = 0;
EAS(R,SR,AS,'ECOP') = 0;
EAS(R,SR,AS,'ECOK') = 0;
EAS(R,SR,AS,ECOPROD) = 0;
EAS(R,SR,AS,'ACRECO') = 0;

EAS(R,SR,AS,'MAXWHEAT')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'MAXWHEAT') + EAS(R,SR,AS,'MAXEWHEAT');
EAS(R,SR,AS,'MAXEWHEAT')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'MAXWWHEAT')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'MAXWWHEAT') + EAS(R,SR,AS,'MAXEWWHEAT');
EAS(R,SR,AS,'MAXEWWHEAT')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'MAXWRAY')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'MAXWRAY') + EAS(R,SR,AS,'MAXEWRAY');
EAS(R,SR,AS,'MAXEWRAY')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'MAXOILG')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'MAXOILG') + EAS(R,SR,AS,'MAXEOILG');
EAS(R,SR,AS,'MAXEOILG')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'MAXWOILG')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'MAXWOILG') + EAS(R,SR,AS,'MAXEWOILG');
EAS(R,SR,AS,'MAXEWOILG')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'MAXPEAS')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'MAXPEAS') + EAS(R,SR,AS,'MAXEPEAS');
EAS(R,SR,AS,'MAXEPEAS')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'MAXPOTATO')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'MAXPOTATO') + EAS(R,SR,AS,'MAXEPOTATO');
EAS(R,SR,AS,'MAXEPOTATO')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'MAXSUGAR')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'MAXSUGAR') + EAS(R,SR,AS,'MAXESUGAR');
EAS(R,SR,AS,'MAXESUGAR')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'MINNEWFOR')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'MINNEWFOR') + EAS(R,SR,AS,'MINENEWFOR');
EAS(R,SR,AS,'MINENEWFOR')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'MAXLATE')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'MAXLATE') + EAS(R,SR,AS,'MAXELATE');
EAS(R,SR,AS,'MAXELATE')$RSRAS(R,SR,AS) = 0;

EAS(R,SR,AS,SUPPORT) = 0;

EAS(R,SR,AS,'ORGCROPL')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'ORGPASTR')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'CBONDING')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'NH3')$RSRAS(R,SR,AS)      = 0;
EAS(R,SR,AS,'CO2')$RSRAS(R,SR,AS)      = 0;
EAS(R,SR,AS,'CH4')$RSRAS(R,SR,AS)      = 0;
EAS(R,SR,AS,'N2O')$RSRAS(R,SR,AS)      = 0;
EAS(R,SR,AS,'CO2EQ')$RSRAS(R,SR,AS)    = 0;
EAS(R,SR,AS,'N-LEAKAGE')$RSRAS(R,SR,AS)= 0;
EAS(R,SR,AS,'P-LEAKAGE')$RSRAS(R,SR,AS)= 0;

SUPPLYIS.UP(R,SR,'N-LEAKAGE')= 0;
SUPPLYIS.UP(R,SR,'P-LEAKAGE')= 0;

BIN('DIESEL','INTERCEPT')     = BIN('DIESEL','INTERCEPT')     + 1.712;
BIN('HERBICIDES','INTERCEPT') = BIN('HERBICIDES','INTERCEPT') +BIN('HERBICIDES','INTERCEPT')  * 0.25;
BIN('GLYFOSAT','INTERCEPT')   = BIN('GLYFOSAT','INTERCEPT')   + BIN('GLYFOSAT','INTERCEPT')   * 0.25;
BIN('FUNGICIDES','INTERCEPT') = BIN('FUNGICIDES','INTERCEPT') + BIN('FUNGICIDES','INTERCEPT') * 0.25;
BIN('INSECTICID','INTERCEPT') = BIN('INSECTICID','INTERCEPT') + BIN('INSECTICID','INTERCEPT') * 0.25;
BIN('OTHERFEED','INTERCEPT')  = BIN('OTHERFEED','INTERCEPT')  + BIN('OTHERFEED','INTERCEPT')  * 0.10;
BIN('PLASTIC','INTERCEPT')    = BIN('PLASTIC','INTERCEPT')    + 0.070;

BIR(R,'NITROGEN','INTERCEPT')   = BIR(R,'NITROGEN','INTERCEPT')   + 3.57 / (0.24+0.04+0.05);
BIR(R,'PHOSPHORUS','INTERCEPT') = BIR(R,'PHOSPHORUS','INTERCEPT') + 3.57 / (0.24+0.04+0.05);
BIR(R,'POTASSIUM','INTERCEPT')  = BIR(R,'POTASSIUM','INTERCEPT')  + 3.57 / (0.24+0.04+0.05);
BIR(R,'OILGRSEED','INTERCEPT') =BIR(R,'OILGRSEED','INTERCEPT') +BIR(R,'OILGRSEED','INTERCEPT') *0.25;
BIR(R,'POTATOSEED','INTERCEPT')=BIR(R,'POTATOSEED','INTERCEPT')+BIR(R,'POTATOSEED','INTERCEPT')*0.25;
BIR(R,'SUGARBSEED','INTERCEPT')=BIR(R,'SUGARBSEED','INTERCEPT')+BIR(R,'SUGARBSEED','INTERCEPT')*0.25;
BIR(R,'BETFOR','INTERCEPT')    =BIR(R,'BETFOR','INTERCEPT')    +BIR(R,'BETFOR','INTERCEPT')    *0.25;
BIR(R,'HP-MASSA','INTERCEPT')  =BIR(R,'HP-MASSA','INTERCEPT')  +BIR(R,'HP-MASSA','INTERCEPT')  *0.25;
BIR(R,'PROTFEED','INTERCEPT')=BIR(R,'PROTFEED','INTERCEPT')+BIR(R,'PROTFEED','INTERCEPT')*0.03+0.599;

BMR(R,'BREADGRAIN','ADJPRICE') = BMR(R,'BREADGRAIN','ADJPRICE') + 0.599;
BMR(R,'COARSGRAIN','ADJPRICE') = BMR(R,'COARSGRAIN','ADJPRICE') + 0.599;
BMR(R,'PEAS','ADJPRICE')       = BMR(R,'PEAS','ADJPRICE')       + 0.599;
BMR(R,'OILGRAIN','ADJPRICE')   = BMR(R,'OILGRAIN','ADJPRICE')   + 0.599;
BMR(R,'RAPEOIL','ADJPRICE')    = BMR(R,'RAPEOIL','ADJPRICE')    + 1.712 * 0.8;
BMR(R,'WHITESUGAR','ADJPRICE') = BMR(R,'WHITESUGAR','ADJPRICE') + BMR(R,'WHITESUGAR','ADJPRICE') * 0.20;

IMPORTPR.UP(R,'POTATOES') $RPRIM(R,'POTATOES') = 0; 
IMPORTPR.UP(R,'CHEESE') $RPRIM(R,'CHEESE') = 0; 
IMPORTPR.UP(R,'BUTTER') $RPRIM(R,'BUTTER') = 0; 
IMPORTPR.UP(R,'DRYMILK') $RPRIM(R,'DRYMILK') = 0; 
IMPORTPR.UP(R,'DRYMILK2') $RPRIM(R,'DRYMILK2') = 0; 
IMPORTPR.UP(R,'BEEF') $RPRIM(R,'BEEF') = 0; 
IMPORTPR.UP(R,'PORK') $RPRIM(R,'PORK') = 0; 
IMPORTPR.UP(R,'PLTRYMEAT') $RPRIM(R,'PLTRYMEAT') = 0;
IMPORTPR.UP(R,'SLGHSHEEP') $RPRIM(R,'SLGHSHEEP') = 0;
IMPORTPR.UP(R,'EGG') $RPRIM(R,'EGG') = 0;
IMPORTPR.UP(R,'WILDMEAT') $RPRIM(R,'WILDMEAT') = 0;
IMPORTPR.UP(R,'FISH') $RPRIM(R,'FISH') = 0;
IMPORTPR.UP(R,'FRUIT') $RPRIM(R,'FRUIT') = 0;
IMPORTPR.UP(R,'VEGETAB') $RPRIM(R,'VEGETAB') = 0;
EXPORTRP.UP(R,PR) $RPREX(R,PR) = 0;
EXPORTRP.FX(R,'BREADGRAIN') $RPREX(R,'BREADGRAIN') = EXPORTRP.L(R,'BREADGRAIN') * 0.60;
* Net export feb-juli = 280 kton (average 2021-2024). Ca 60 % before feb.

BIR(R,'MAXFISH','MAX')  = BIR(R,'MAXFISH','MAX')  * 0.9;
BIR(R,'MAXFRUIT','MAX') = BIR(R,'MAXFRUIT','MAX') * 0.8;
BIR(R,'MAXVEGET','MAX') = BIR(R,'MAXVEGET','MAX') * 0.25;

PROCR.UP(R,'R-BREADGR') = PROCR.L(R,'R-BREADGR') * 2; 
PROCR.UP(R,'R-COARSGR') = PROCR.L(R,'R-COARSGR') * 2;
PROCR.UP(R,'R-FLOUR')   = PROCR.L(R,'R-FLOUR')   * 2;
PROCR.UP(R,'R-RAPEOIL') = PROCR.L(R,'R-RAPEOIL') * 1.2;
PROCR.UP(R,'R-SUGAR')   = PROCR.L(R,'R-SUGAR')   * 1.2;
PROCR.UP(R,'R-BUTTER')  = PROCR.L(R,'R-BUTTER')  * 1.0;
PROCR.UP(R,'R-DRYMILK') = PROCR.L(R,'R-DRYMILK') * 1.0;
PROCR.LO(R,'R-KMILK')   = PROCR.L(R,'R-KMILK')   * 1.0;

*SUPPLYIN.UP('DIESEL')    = SUPPLYIN.L('DIESEL')    * RED;
*SUPPLYIN.UP('HERBICIDES')= SUPPLYIN.L('HERBICIDES')* RED;
*SUPPLYIN.UP('GLYFOSAT')  = SUPPLYIN.L('GLYFOSAT')  * RED;
*SUPPLYIN.UP('FUNGICIDES')= SUPPLYIN.L('FUNGICIDES')* RED;
*SUPPLYIN.UP('INSECTICID')= SUPPLYIN.L('INSECTICID')* RED;
*SUPPLYIN.UP('OTHERFEED') = SUPPLYIN.L('OTHERFEED') * RED;

*SUPPLYIR.UP(R,'NITROGEN')= (SUPPLYIR.L(R,'NITROGEN')
*     + SUM(SR $RSR(R,SR), SUPPLYIS.L(R,SR,'ECON'))) * RED;
*SUPPLYIR.UP(R,'PHOSPHORUS')= (SUPPLYIR.L(R,'PHOSPHORUS')
*     + SUM(SR $RSR(R,SR), SUPPLYIS.L(R,SR,'ECOP'))) * RED;
*SUPPLYIR.UP(R,'POTASSIUM') = (SUPPLYIR.L(R,'POTASSIUM')
*     + SUM(SR $RSR(R,SR), SUPPLYIS.L(R,SR,'ECOK'))) * RED;

*IMPORTPR.UP(R,PR) $RPRIM(R,PR) = IMPORTPR.L(R,PR) * RED; 
*EXPORTRP.UP(R,PR) $RPREX(R,PR) = EXPORTRP.L(R,PR) * RED; 

PRODSR.FX(R,SR,'USEMANURE')= 0;

PRODSR.LO(R,SR,'POULTRY') $RSRAS(R,SR,'POULTRY') = 0;

PRODSR.UP(R,SR,AS) $RSRAS(R,SR,AS) = PRODSR.L(R,SR,AS) + 0.0001;
PRODSR.FX(R,SR,WINTERCROP) $RSRAS(R,SR,WINTERCROP) = PRODSR.L(R,SR,WINTERCROP);
PRODSR.FX(R,SR,FORAGES) $RSRAS(R,SR,FORAGES) = PRODSR.L(R,SR,FORAGES);
PRODSR.LO(R,SR,LIVESTOCK) $RSRAS(R,SR,LIVESTOCK) = PRODSR.L(R,SR,LIVESTOCK);
*PRODSR.LO(R,SR,'POULTRY') $RSRAS(R,SR,'POULTRY') = PRODSR.L(R,SR,'POULTRY') * 0.5;
*PRODSR.LO(R,SR,'EPOULTRY') $RSRAS(R,SR,'EPOULTRY') = PRODSR.L(R,SR,'EPOULTRY') * 0.5;
*PRODSR.LO(R,SR,'CHICKEN') $RSRAS(R,SR,'CHICKEN') = PRODSR.L(R,SR,'CHICKEN') / 7;

BPS(R,SR,'MINSHEEP','MIN') = 0;

BPS(R,SR,'MINDCOW','MIN') = SUM(DCOWS $RSRAS(R,SR,DCOWS), PRODSR.L(R,SR,DCOWS));
PRODSR.UP(R,SR,DCOWS)= INF;
PRODSR.LO(R,SR,DCOWS)= PRODSR.L(R,SR,DCOWS) * 0.5;

BPS(R,SR,'MINBCOW','MIN') = SUM(BCOWS $RSRAS(R,SR,BCOWS), PRODSR.L(R,SR,BCOWS));
PRODSR.UP(R,SR,BCOWS)= INF;
PRODSR.LO(R,SR,BCOWS)= PRODSR.L(R,SR,BCOWS) * 0.5;

DEMANDPR.UP(R,FOODS) = 0;
*SUPPLYIR.UP(R,'HP-MASSA') = INF;
BIN('P-COST','INTERCEPT') = 0;

*EAS(R,SR,DCOWS,'DPTRANR')$RSRAS(R,SR,DCOWS) =  EAS(R,SR,DCOWS,'DPTRANR') * 1.04;
EAS(R,SR,DCOWS,'DPTRANR')$RSRAS(R,SR,DCOWS) =  0;
ECR(R,CR,'DPTRANC') = 0;

PRODSR.LO(R,SR,PASTURES) $RSRAS(R,SR,PASTURES) = PRODSR.L(R,SR,PASTURES);

SOLVE SASM USING NLP MAXIMIZING Z;


PRODSR.LO(R,SR,PASTURES) $RSRAS(R,SR,PASTURES) = 0;

SOLVE SASM USING NLP MAXIMIZING Z;
* Year 1

*$ONTEXT
RED = 1.00;
 
EAS(R,SR,CROPS3,'POWER')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'POWER')* (1-(1-RED)*0.5);
EAS(R,SR,CROPS3,'DIESEL')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'DIESEL')* (1-(1-RED)*0.5);
EAS(R,SR,CROPS3,'LABOR')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'LABOR')* (1-(1-RED)*0.4);
EAS(R,SR,CROPS3,PR)$RSRAS(R,SR,CROPS3)      = EAS(R,SR,CROPS3,PR)     * (1-(1-RED)*0.2);
EAS(R,SR,CROPS3,'NITROGEN')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'NITROGEN')* (1-(1-RED)*0.5);
EAS(R,SR,CROPS3,'PHOSPHORUS')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'PHOSPHORUS')* (1-(1-RED)*0.8);
EAS(R,SR,CROPS3,'POTASSIUM')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'POTASSIUM')* (1-(1-RED)*0.5);
EAS(R,SR,CROPS3,'PESTICIDES')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'PESTICIDES')* (1-(1-RED)*0.5);
EAS(R,SR,CROPS3,'HERBICIDES')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'HERBICIDES')* (1-(1-RED)*0.5);
EAS(R,SR,CROPS3,'FUNGICIDES')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'FUNGICIDES')* (1-(1-RED)*0.5);
EAS(R,SR,CROPS3,'INSECTICID')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'INSECTICID')* (1-(1-RED)*0.5);
EAS(R,SR,CROPS3,'GLYFOSAT')$RSRAS(R,SR,CROPS3)   = EAS(R,SR,CROPS3,'GLYFOSAT')  * (1-(1-RED)*0.5);
EAS(R,SR,CROPS3,PR)$RSRAS(R,SR,CROPS3)      = EAS(R,SR,CROPS3,PR)     * (1-(1-RED)*0.2);

EAS(R,SR,ECROPS3,'POWER')$RSRAS(R,SR,ECROPS3) = EAS(R,SR,ECROPS3,'POWER')* (1-(1-RED)*0.5);
EAS(R,SR,ECROPS3,'DIESEL')$RSRAS(R,SR,ECROPS3) = EAS(R,SR,ECROPS3,'DIESEL')* (1-(1-RED)*0.5);
EAS(R,SR,ECROPS3,'LABOR')$RSRAS(R,SR,ECROPS3) = EAS(R,SR,ECROPS3,'LABOR')* (1-(1-RED)*0.4);
EAS(R,SR,ECROPS3,PR)$RSRAS(R,SR,ECROPS3)      = EAS(R,SR,ECROPS3,PR)     * (1-(1-RED)*0.2);
EAS(R,SR,ECROPS3,'NITROGEN')$RSRAS(R,SR,ECROPS3) = EAS(R,SR,ECROPS3,'NITROGEN')* (1-(1-RED)*0.25);
EAS(R,SR,ECROPS3,'PHOSPHORUS')$RSRAS(R,SR,ECROPS3)= EAS(R,SR,ECROPS3,'PHOSPHORUS')* (1-(1-RED)*0.40);
EAS(R,SR,ECROPS3,'POTASSIUM')$RSRAS(R,SR,ECROPS3) = EAS(R,SR,ECROPS3,'POTASSIUM')* (1-(1-RED)*0.25);
EAS(R,SR,ECROPS3,PR)$RSRAS(R,SR,ECROPS3) = EAS(R,SR,ECROPS3,PR)* (1-(1-RED)*0.1);

BIN('DIESEL','INTERCEPT')     = BIN('DIESEL','INTERCEPT')     + 1.712;
BIN('HERBICIDES','INTERCEPT') = BIN('HERBICIDES','INTERCEPT') +BIN('HERBICIDES','INTERCEPT')  * 0.20;
BIN('GLYFOSAT','INTERCEPT')   = BIN('GLYFOSAT','INTERCEPT')   + BIN('GLYFOSAT','INTERCEPT')   * 0.20;
BIN('FUNGICIDES','INTERCEPT') = BIN('FUNGICIDES','INTERCEPT') + BIN('FUNGICIDES','INTERCEPT') * 0.20;
BIN('INSECTICID','INTERCEPT') = BIN('INSECTICID','INTERCEPT') + BIN('INSECTICID','INTERCEPT') * 0.20;
BIN('OTHERFEED','INTERCEPT')  = BIN('OTHERFEED','INTERCEPT')  + BIN('OTHERFEED','INTERCEPT')  *0.091;
BIN('PLASTIC','INTERCEPT')    = BIN('PLASTIC','INTERCEPT')    + 0.070;

BIR(R,'NITROGEN','INTERCEPT')   = BIR(R,'NITROGEN','INTERCEPT')   + 3.57 / (0.24+0.04+0.05);
BIR(R,'PHOSPHORUS','INTERCEPT') = BIR(R,'PHOSPHORUS','INTERCEPT') + 3.57 / (0.24+0.04+0.05);
BIR(R,'POTASSIUM','INTERCEPT')  = BIR(R,'POTASSIUM','INTERCEPT')  + 3.57 / (0.24+0.04+0.05);
BIR(R,'OILGRSEED','INTERCEPT') =BIR(R,'OILGRSEED','INTERCEPT') +BIR(R,'OILGRSEED','INTERCEPT') *0.20;
BIR(R,'POTATOSEED','INTERCEPT')=BIR(R,'POTATOSEED','INTERCEPT')+BIR(R,'POTATOSEED','INTERCEPT')*0.20;
BIR(R,'SUGARBSEED','INTERCEPT')=BIR(R,'SUGARBSEED','INTERCEPT')+BIR(R,'SUGARBSEED','INTERCEPT')*0.20;
BIR(R,'BETFOR','INTERCEPT')    =BIR(R,'BETFOR','INTERCEPT')    +BIR(R,'BETFOR','INTERCEPT')    *0.20;
BIR(R,'HP-MASSA','INTERCEPT')  =BIR(R,'HP-MASSA','INTERCEPT')  +BIR(R,'HP-MASSA','INTERCEPT')  *0.20;
BIR(R,'PROTFEED','INTERCEPT')=BIR(R,'PROTFEED','INTERCEPT')+BIR(R,'PROTFEED','INTERCEPT')*0.03+0.599;

BMR(R,'BREADGRAIN','ADJPRICE') = BMR(R,'BREADGRAIN','ADJPRICE') + 0.599;
BMR(R,'COARSGRAIN','ADJPRICE') = BMR(R,'COARSGRAIN','ADJPRICE') + 0.599;
BMR(R,'PEAS','ADJPRICE')       = BMR(R,'PEAS','ADJPRICE')       + 0.599;
BMR(R,'OILGRAIN','ADJPRICE')   = BMR(R,'OILGRAIN','ADJPRICE')   + 0.599;
BMR(R,'RAPEOIL','ADJPRICE')    = BMR(R,'RAPEOIL','ADJPRICE')    + 1.712 * 0.8;
BMR(R,'WHITESUGAR','ADJPRICE')=BMR(R,'WHITESUGAR','ADJPRICE')+BMR(R,'WHITESUGAR','ADJPRICE') * 0.167;

EXPORTRP.FX(R,'BREADGRAIN') = 0;

PRODSR.UP(R,SR,AS) $RSRAS(R,SR,AS) = INF;
PRODSR.LO(R,SR,WINTERCROP) $RSRAS(R,SR,WINTERCROP) = 0;
PRODSR.LO(R,SR,FORAGES) $RSRAS(R,SR,FORAGES) = 0;
*PRODSR.LO(R,SR,LIVESTOCK) $RSRAS(R,SR,LIVESTOCK) = PRODSR.L(R,SR,LIVESTOCK) * 0.8;
*PRODSR.LO(R,SR,'POULTRY') $RSRAS(R,SR,'POULTRY') = PRODSR.L(R,SR,'POULTRY') * 0.5;
*PRODSR.LO(R,SR,'EPOULTRY') $RSRAS(R,SR,'EPOULTRY') = PRODSR.L(R,SR,'EPOULTRY') * 0.5;
*PRODSR.LO(R,SR,'CHICKEN') $RSRAS(R,SR,'CHICKEN') = PRODSR.L(R,SR,'CHICKEN') / 7;
*PRODSR.LO(R,SR,DCOWS) $RSRAS(R,SR,DCOWS) = PRODSR.L(R,SR,DCOWS) * 0.5;

*EAS(R,SR,DCOWS,'DPTRANR')$RSRAS(R,SR,DCOWS) =  EAS(R,SR,DCOWS,'DPTRANR') * 1.00;

PRODSR.LO(R,SR,DCOWS)= 0;
PRODSR.LO(R,SR,BCOWS)= 0;

SOLVE SASM USING NLP MAXIMIZING Z;
* Year 2

*$ontext

BIN('DIESEL','INTERCEPT')     = BIN('DIESEL','INTERCEPT')     + 1.712;
BIN('HERBICIDES','INTERCEPT') = BIN('HERBICIDES','INTERCEPT') +BIN('HERBICIDES','INTERCEPT')  *0.167;
BIN('GLYFOSAT','INTERCEPT')   = BIN('GLYFOSAT','INTERCEPT')   + BIN('GLYFOSAT','INTERCEPT')   *0.167;
BIN('FUNGICIDES','INTERCEPT') = BIN('FUNGICIDES','INTERCEPT') + BIN('FUNGICIDES','INTERCEPT') *0.167;
BIN('INSECTICID','INTERCEPT') = BIN('INSECTICID','INTERCEPT') + BIN('INSECTICID','INTERCEPT') *0.167;
BIN('OTHERFEED','INTERCEPT')  = BIN('OTHERFEED','INTERCEPT')  + BIN('OTHERFEED','INTERCEPT')  *0.083;
BIN('PLASTIC','INTERCEPT')    = BIN('PLASTIC','INTERCEPT')    + 0.070;

BIR(R,'NITROGEN','INTERCEPT')   = BIR(R,'NITROGEN','INTERCEPT')   + 3.57 / (0.24+0.04+0.05);
BIR(R,'PHOSPHORUS','INTERCEPT') = BIR(R,'PHOSPHORUS','INTERCEPT') + 3.57 / (0.24+0.04+0.05);
BIR(R,'POTASSIUM','INTERCEPT')  = BIR(R,'POTASSIUM','INTERCEPT')  + 3.57 / (0.24+0.04+0.05);
BIR(R,'OILGRSEED','INTERCEPT') =BIR(R,'OILGRSEED','INTERCEPT') +BIR(R,'OILGRSEED','INTERCEPT') *0.167;
BIR(R,'POTATOSEED','INTERCEPT')=BIR(R,'POTATOSEED','INTERCEPT')+BIR(R,'POTATOSEED','INTERCEPT')*0.167;
BIR(R,'SUGARBSEED','INTERCEPT')=BIR(R,'SUGARBSEED','INTERCEPT')+BIR(R,'SUGARBSEED','INTERCEPT')*0.167;
BIR(R,'BETFOR','INTERCEPT')    =BIR(R,'BETFOR','INTERCEPT')    +BIR(R,'BETFOR','INTERCEPT')    *0.167;
BIR(R,'HP-MASSA','INTERCEPT')  =BIR(R,'HP-MASSA','INTERCEPT')  +BIR(R,'HP-MASSA','INTERCEPT')  *0.167;
BIR(R,'PROTFEED','INTERCEPT')=BIR(R,'PROTFEED','INTERCEPT')+BIR(R,'PROTFEED','INTERCEPT')*0.02+0.599;

BMR(R,'BREADGRAIN','ADJPRICE') = BMR(R,'BREADGRAIN','ADJPRICE') + 0.599;
BMR(R,'COARSGRAIN','ADJPRICE') = BMR(R,'COARSGRAIN','ADJPRICE') + 0.599;
BMR(R,'PEAS','ADJPRICE')       = BMR(R,'PEAS','ADJPRICE')       + 0.599;
BMR(R,'OILGRAIN','ADJPRICE')   = BMR(R,'OILGRAIN','ADJPRICE')   + 0.599;
BMR(R,'RAPEOIL','ADJPRICE')    = BMR(R,'RAPEOIL','ADJPRICE')    + 1.712 * 0.8;
BMR(R,'WHITESUGAR','ADJPRICE')=BMR(R,'WHITESUGAR','ADJPRICE')+BMR(R,'WHITESUGAR','ADJPRICE') * 0.143;


SOLVE SASM USING NLP MAXIMIZING Z;
* Year 3

$ontext

EAS(R,SR,AS,'CBONDING')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'NH3')$RSRAS(R,SR,AS)      = 0;
EAS(R,SR,AS,'CO2')$RSRAS(R,SR,AS)      = 0;
EAS(R,SR,AS,'CH4')$RSRAS(R,SR,AS)      = 0;
EAS(R,SR,AS,'N2O')$RSRAS(R,SR,AS)      = 0;
EAS(R,SR,AS,'CO2EQ')$RSRAS(R,SR,AS)    = 0;
EAS(R,SR,AS,'N-LEAKAGE')$RSRAS(R,SR,AS)= 0;
EAS(R,SR,AS,'P-LEAKAGE')$RSRAS(R,SR,AS)= 0;


SOLVE SASM USING NLP MAXIMIZING Z;
$ontext
DEMANDPR.LO(R,'ENERGY') = DEMANDPR.LO(R,'ENERGY')/1.1;

SOLVE SASM USING NLP MAXIMIZING Z;

DEMANDPR.LO(R,'ENERGY') = DEMANDPR.LO(R,'ENERGY')*1.1/1.25;

SOLVE SASM USING NLP MAXIMIZING Z;

$ontext
*PRODSR.UP(R,SR,CROPS) $RSRAS(R,SR,CROPS)           = PRODSR.L(R,SR,CROPS);
PRODSR.UP(R,SR,LIVESTOCK) $RSRAS(R,SR,LIVESTOCK)   = PRODSR.L(R,SR,LIVESTOCK);
PRODSR.UP(R,SR,FORAGES) $RSRAS(R,SR,FORAGES)       = PRODSR.L(R,SR,FORAGES);
*PRODSR.FX(R,SR,PASTURES) $RSRAS(R,SR,PASTURES)     = PRODSR.L(R,SR,PASTURES);
*PRODSR.FX(R,SR,GRAINS) $RSRAS(R,SR,GRAINS)         = PRODSR.L(R,SR,GRAINS);
*PRODSR.FX(R,SR,OILGRAINS) $RSRAS(R,SR,OILGRAINS)   = PRODSR.L(R,SR,OILGRAINS);
PRODSR.FX(R,SR,WINTERCROP) $RSRAS(R,SR,WINTERCROP) = 0;

*PRODSR.UP(R,SR,'LAY')  $RSRAS(R,SR,'LAY')  = inf;
*PRODSR.UP(R,SR,'ELAY') $RSRAS(R,SR,'ELAY') = inf;
*PRODSR.UP(R,SR,'NEWFOR')  $RSRAS(R,SR,'NEWFOR')  = inf;
*PRODSR.UP(R,SR,'ENEWFOR') $RSRAS(R,SR,'ENEWFOR') = inf;

*EAS(R,SR,AS,'MAXWRAY')$RSRAS(R,SR,AS)  = 0;
*EAS(R,SR,AS,'MAXEWRAY')$RSRAS(R,SR,AS) = 0;
*EAS(R,SR,AS,'MINNEWFOR')$RSRAS(R,SR,AS)  = 0;
*EAS(R,SR,AS,'MINENEWFOR')$RSRAS(R,SR,AS) = 0;
*EAS(R,SR,AS,'ACRMANURE')$RSRAS(R,SR,AS)  = 0;

SOLVE SASM USING NLP MAXIMIZING Z;

*$offtext

RED = 0.50;
 
EAS(R,SR,ECO,'ACRECO')$RSRAS(R,SR,ECO) = 0;
EAS(R,SR,'EDCOW1','MEDCOW')$RSRAS(R,SR,'EDCOW1') = 0;
EAS(R,SR,'EDCOW2','MEDCOW')$RSRAS(R,SR,'EDCOW2') = 0;
EAS(R,SR,'EDCOW3','MEDCOW')$RSRAS(R,SR,'EDCOW3') = 0;
EAS(R,SR,'EBEEFCATT','MEBEEFCATT')$RSRAS(R,SR,'EBEEFCATT') = 0;
EAS(R,SR,'EBEEFCAT2','MEBEEFCATT')$RSRAS(R,SR,'EBEEFCAT2') = 0;
EAS(R,SR,'ECOPIG','MECOPIG')$RSRAS(R,SR,'ECOPIG') = 0;
EAS(R,SR,'ESHEEP','MESHEEP')$RSRAS(R,SR,'ESHEEP') = 0;
EAS(R,SR,'EPOULTRY','MEPOULTRY')$RSRAS(R,SR,'EPOULTRY') = 0;

*EAS(R,SR,CROPS3,'POWER')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'POWER')* (1-(1-RED)*0.5);
*EAS(R,SR,CROPS3,'DIESEL')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'DIESEL')* (1-(1-RED)*0.5);
*EAS(R,SR,CROPS3,'LABOR')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'LABOR')* (1-(1-RED)*0.4);
*EAS(R,SR,CROPS3,PR)$RSRAS(R,SR,CROPS3)      = EAS(R,SR,CROPS3,PR)     * (1-(1-RED)*0.2);
*EAS(R,SR,CROPS3,'NITROGEN')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'NITROGEN')* (1-(1-RED)*0.5);
*EAS(R,SR,CROPS3,'PHOSPHORUS')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'PHOSPHORUS')* (1-(1-RED)*0.8);
*EAS(R,SR,CROPS3,'POTASSIUM')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'POTASSIUM')* (1-(1-RED)*0.5);
*EAS(R,SR,CROPS3,'PESTICIDES')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'PESTICIDES')* (1-(1-RED)*0.5);
*EAS(R,SR,CROPS3,'HERBICIDES')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'HERBICIDES')* (1-(1-RED)*0.5);
*EAS(R,SR,CROPS3,'FUNGICIDES')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'FUNGICIDES')* (1-(1-RED)*0.5);
*EAS(R,SR,CROPS3,'INSECTICID')$RSRAS(R,SR,CROPS3) = EAS(R,SR,CROPS3,'INSECTICID')* (1-(1-RED)*0.5);
*EAS(R,SR,CROPS3,'GLYFOSAT')$RSRAS(R,SR,CROPS3)   = EAS(R,SR,CROPS3,'GLYFOSAT')  * (1-(1-RED)*0.5);
*EAS(R,SR,CROPS3,PR)$RSRAS(R,SR,CROPS3)      = EAS(R,SR,CROPS3,PR)     * (1-(1-RED)*0.2);

*EAS(R,SR,ECROPS3,'POWER')$RSRAS(R,SR,ECROPS3) = EAS(R,SR,ECROPS3,'POWER')* (1-(1-RED)*0.5);
*EAS(R,SR,ECROPS3,'DIESEL')$RSRAS(R,SR,ECROPS3) = EAS(R,SR,ECROPS3,'DIESEL')* (1-(1-RED)*0.5);
*EAS(R,SR,ECROPS3,'LABOR')$RSRAS(R,SR,ECROPS3) = EAS(R,SR,ECROPS3,'LABOR')* (1-(1-RED)*0.4);
*EAS(R,SR,ECROPS3,PR)$RSRAS(R,SR,ECROPS3)      = EAS(R,SR,ECROPS3,PR)     * (1-(1-RED)*0.2);
*EAS(R,SR,ECROPS3,'ECON')$RSRAS(R,SR,ECROPS3) = EAS(R,SR,ECROPS3,'ECON')* (1-(1-RED)*0.25);
*EAS(R,SR,ECROPS3,'ECOP')$RSRAS(R,SR,ECROPS3) = EAS(R,SR,ECROPS3,'ECOP')* (1-(1-RED)*0.40);
*EAS(R,SR,ECROPS3,'ECOK')$RSRAS(R,SR,ECROPS3) = EAS(R,SR,ECROPS3,'ECOK')* (1-(1-RED)*0.25);
*EAS(R,SR,ECROPS3,PR)$RSRAS(R,SR,ECROPS3) = EAS(R,SR,ECROPS3,PR)* (1-(1-RED)*0.1);

EAS(R,SR,AS,'NITROGEN')$RSRAS(R,SR,AS)   = EAS(R,SR,AS,'NITROGEN')   + EAS(R,SR,AS,'ECON');
EAS(R,SR,AS,'PHOSPHORUS')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'PHOSPHORUS') + EAS(R,SR,AS,'ECOP');
EAS(R,SR,AS,'POTASSIUM')$RSRAS(R,SR,AS)  = EAS(R,SR,AS,'POTASSIUM')  + EAS(R,SR,AS,'ECOK');

EAS(R,SR,AS,'ECON') = 0;
EAS(R,SR,AS,'ECOP') = 0;
EAS(R,SR,AS,'ECOK') = 0;
EAS(R,SR,AS,ECOPROD) = 0;
EAS(R,SR,AS,'ACRECO') = 0;

EAS(R,SR,AS,'MAXWHEAT')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'MAXWHEAT') + EAS(R,SR,AS,'MAXEWHEAT');
EAS(R,SR,AS,'MAXEWHEAT')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'MAXWWHEAT')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'MAXWWHEAT') + EAS(R,SR,AS,'MAXEWWHEAT');
EAS(R,SR,AS,'MAXEWWHEAT')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'MAXWRAY')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'MAXWRAY') + EAS(R,SR,AS,'MAXEWRAY');
EAS(R,SR,AS,'MAXEWRAY')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'MAXOILG')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'MAXOILG') + EAS(R,SR,AS,'MAXEOILG');
EAS(R,SR,AS,'MAXEOILG')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'MAXWOILG')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'MAXWOILG') + EAS(R,SR,AS,'MAXEWOILG');
EAS(R,SR,AS,'MAXEWOILG')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'MAXPEAS')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'MAXPEAS') + EAS(R,SR,AS,'MAXEPEAS');
EAS(R,SR,AS,'MAXEPEAS')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'MAXPOTATO')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'MAXPOTATO') + EAS(R,SR,AS,'MAXEPOTATO');
EAS(R,SR,AS,'MAXEPOTATO')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'MAXSUGAR')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'MAXSUGAR') + EAS(R,SR,AS,'MAXESUGAR');
EAS(R,SR,AS,'MAXESUGAR')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'MINNEWFOR')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'MINNEWFOR') + EAS(R,SR,AS,'MINENEWFOR');
EAS(R,SR,AS,'MINENEWFOR')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'MAXLATE')$RSRAS(R,SR,AS) = EAS(R,SR,AS,'MAXLATE') + EAS(R,SR,AS,'MAXELATE');
EAS(R,SR,AS,'MAXELATE')$RSRAS(R,SR,AS) = 0;

EAS(R,SR,AS,'ORGCROPL')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'ORGPASTR')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'CBONDING')$RSRAS(R,SR,AS) = 0;
EAS(R,SR,AS,'NH3')$RSRAS(R,SR,AS)      = 0;
EAS(R,SR,AS,'CO2')$RSRAS(R,SR,AS)      = 0;
EAS(R,SR,AS,'CH4')$RSRAS(R,SR,AS)      = 0;
EAS(R,SR,AS,'N2O')$RSRAS(R,SR,AS)      = 0;
EAS(R,SR,AS,'CO2EQ')$RSRAS(R,SR,AS)    = 0;
EAS(R,SR,AS,'N-LEAKAGE')$RSRAS(R,SR,AS)= 0;
EAS(R,SR,AS,'P-LEAKAGE')$RSRAS(R,SR,AS)= 0;

SUPPLYIS.UP(R,SR,'N-LEAKAGE')= 0;
SUPPLYIS.UP(R,SR,'P-LEAKAGE')= 0;
*$offtext
RED = 0.50;

*SUPPLYIN.UP('DIESEL')    = SUPPLYIN.L('DIESEL')    * RED;
*SUPPLYIN.UP('HERBICIDES')= SUPPLYIN.L('HERBICIDES')* RED;
*SUPPLYIN.UP('GLYFOSAT')  = SUPPLYIN.L('GLYFOSAT')  * RED;
*SUPPLYIN.UP('FUNGICIDES')= SUPPLYIN.L('FUNGICIDES')* RED;
*SUPPLYIN.UP('INSECTICID')= SUPPLYIN.L('INSECTICID')* RED;
*SUPPLYIN.UP('OTHERFEED') = SUPPLYIN.L('OTHERFEED') * RED;
SUPPLYIN.UP('PLASTIC')   = SUPPLYIN.L('PLASTIC')   * (1-(1-RED)*0.25);

*SUPPLYIR.UP(R,'NITROGEN')= (SUPPLYIR.L(R,'NITROGEN')
*     + SUM(SR $RSR(R,SR), SUPPLYIS.L(R,SR,'ECON'))) * RED;
*SUPPLYIR.UP(R,'PHOSPHORUS')= (SUPPLYIR.L(R,'PHOSPHORUS')
*     + SUM(SR $RSR(R,SR), SUPPLYIS.L(R,SR,'ECOP'))) * RED;
*SUPPLYIR.UP(R,'POTASSIUM') = (SUPPLYIR.L(R,'POTASSIUM')
*     + SUM(SR $RSR(R,SR), SUPPLYIS.L(R,SR,'ECOK'))) * RED;

*SUPPLYIR.UP(R,'PROTFEED')  = SUPPLYIR.L(R,'PROTFEED')   * RED;
*SUPPLYIR.UP(R,'OILGRSEED') = SUPPLYIR.L(R,'OILGRSEED')  * RED;
*SUPPLYIR.UP(R,'POTATOSEED')= SUPPLYIR.L(R,'POTATOSEED') * RED;
*SUPPLYIR.UP(R,'SUGARBSEED')= SUPPLYIR.L(R,'SUGARBSEED') * RED;

*BIR(R,'MAXFISH','MAX')  = BIR(R,'MAXFISH','MAX')  * (1-(1-RED)*0.1);
*BIR(R,'MAXFRUIT','MAX') = BIR(R,'MAXFRUIT','MAX') * (1-(1-RED)*0.2);
*BIR(R,'MAXVEGET','MAX') = BIR(R,'MAXVEGET','MAX') * (1-(1-RED)*0.75);

*IMPORTPR.UP(R,PR) $RPRIM(R,PR) = IMPORTPR.L(R,PR) * RED; 
*EXPORTRP.UP(R,PR) $RPREX(R,PR) = EXPORTRP.L(R,PR) * RED; 

*PRODSR.FX(R,SR,'USEMANURE')= 0;
EAS(R,SR,DCOWS,'DPTRANR')$RSRAS(R,SR,DCOWS) =  EAS(R,SR,DCOWS,'DPTRANR') * 1.002;

PRODSR.FX(R,SR,PASTURES) $RSRAS(R,SR,PASTURES) = PRODSR.L(R,SR,PASTURES)/2;

SOLVE SASM USING NLP MAXIMIZING Z;

PRODSR.UP(R,SR,PASTURES) $RSRAS(R,SR,PASTURES) = PRODSR.L(R,SR,PASTURES)*2;
PRODSR.LO(R,SR,PASTURES) $RSRAS(R,SR,PASTURES) = 0;

SOLVE SASM USING NLP MAXIMIZING Z;
* halv import utan lager
$ontext
BIN('DIESEL','INTERCEPT')     = BIN('DIESEL','INTERCEPT')     + 1.712;
BIN('HERBICIDES','INTERCEPT') = BIN('HERBICIDES','INTERCEPT') +BIN('HERBICIDES','INTERCEPT')  * 0.25;
BIN('GLYFOSAT','INTERCEPT')   = BIN('GLYFOSAT','INTERCEPT')   + BIN('GLYFOSAT','INTERCEPT')   * 0.25;
BIN('FUNGICIDES','INTERCEPT') = BIN('FUNGICIDES','INTERCEPT') + BIN('FUNGICIDES','INTERCEPT') * 0.25;
BIN('INSECTICID','INTERCEPT') = BIN('INSECTICID','INTERCEPT') + BIN('INSECTICID','INTERCEPT') * 0.25;
*BIN('OTHERFEED','INTERCEPT')  = BIN('OTHERFEED','INTERCEPT')  + BIN('OTHERFEED','INTERCEPT')  * 0.10;
*BIN('PLASTIC','INTERCEPT')    = BIN('PLASTIC','INTERCEPT')    + 0.070;

BIR(R,'NITROGEN','INTERCEPT')   = BIR(R,'NITROGEN','INTERCEPT')   + 3.57 / (0.24+0.04+0.05);
BIR(R,'PHOSPHORUS','INTERCEPT') = BIR(R,'PHOSPHORUS','INTERCEPT') + 3.57 / (0.24+0.04+0.05);
BIR(R,'POTASSIUM','INTERCEPT')  = BIR(R,'POTASSIUM','INTERCEPT')  + 3.57 / (0.24+0.04+0.05);
*BIR(R,'OILGRSEED','INTERCEPT') =BIR(R,'OILGRSEED','INTERCEPT') +BIR(R,'OILGRSEED','INTERCEPT') *0.25;
*BIR(R,'POTATOSEED','INTERCEPT')=BIR(R,'POTATOSEED','INTERCEPT')+BIR(R,'POTATOSEED','INTERCEPT')*0.25;
*BIR(R,'SUGARBSEED','INTERCEPT')=BIR(R,'SUGARBSEED','INTERCEPT')+BIR(R,'SUGARBSEED','INTERCEPT')*0.25;
*BIR(R,'BETFOR','INTERCEPT')    =BIR(R,'BETFOR','INTERCEPT')    +BIR(R,'BETFOR','INTERCEPT')    *0.25;
*BIR(R,'HP-MASSA','INTERCEPT')  =BIR(R,'HP-MASSA','INTERCEPT')  +BIR(R,'HP-MASSA','INTERCEPT')  *0.25;
BIR(R,'PROTFEED','INTERCEPT')=BIR(R,'PROTFEED','INTERCEPT')+BIR(R,'PROTFEED','INTERCEPT')*0.03+0.599;

SUPPLYIN.UP('DIESEL')    = INF;
SUPPLYIN.UP('HERBICIDES')= INF;
SUPPLYIN.UP('GLYFOSAT')  = INF;
SUPPLYIN.UP('FUNGICIDES')= INF;
SUPPLYIN.UP('INSECTICID')= INF;

SUPPLYIR.UP(R,'NITROGEN')= INF;
SUPPLYIR.UP(R,'PHOSPHORUS')= INF;
SUPPLYIR.UP(R,'POTASSIUM') = INF;

SUPPLYIR.UP(R,'PROTFEED')  = INF;

EAS(R,SR,DCOWS,'DPTRANR')$RSRAS(R,SR,DCOWS) =  EAS(R,SR,DCOWS,'DPTRANR') / 1.4;

SOLVE SASM USING NLP MAXIMIZING Z;
* halv import med vissa lager




$ontext
$offtext 
$STITLE Solution report generation
DISPLAY 'Optimal value of the objective function', Z.L;
 
SET TH1  Column headers for product and input soln rpt tables
 /PRODUCTION, USE, SHIP-IN, SHIP-OUT, SHIPMENTS, DEMAND, FIXED-DEM, SUPPLY, FIXED-SUP,
  IMPORT, EXPORT, PRICE, SUBSIDY, TRANSFER, TOTAL/;
 
SET TH2  Column headers for general soln rpt tables
 /LOWER, LEVEL, UPPER, MARGINAL/;

SET PRIMP(P)  Primary products
 /BREADGRAIN, COARSGRAIN, FEEDGRAIN, OILGRAIN, POTATOES, SUGARBEET, SILAGE, GRASSPASTR,
  MILK, SLGHBEEF, SLGHPORK, SLGHPLTRY, SLGHSHEEP, EGG, PLTRYMEAT,
  EGRAIN, ERAPE, ESUGARB, EPOTATOES, EMILK, EBEEF, EPORK, ESHEEPM, EEGG/;

SET PRIMPFA(P)  Primary products in Output-regions
 /MILK, SLGHBEEF, SLGHPORK, SLGHPLTRY, EGG, SLGHSHEEP, BREADGRAIN, COARSGRAIN, OILGRAIN, POTATOES,
  SUGARBEET, SILAGE, GRASSPASTR/;

SET BIDRAG(P)  Paid supports
 /GACRSUB, COMP4SUB, FORSUB, CATTLESUB, SOWHLTSUB, ECOSUB, ES1*ES6, FARMSUB, NATSUB,
  COMPSUB, COMPSUBL, BIODIVSUB, BIODIVSUB2, BIODIVSUB3, BIODIVSUBA, BIODIVSUBF, BIODIVSUBM,
  BIODIVSUBG, BIODIVSUBC, BIODIVSUBS, MINPASTN/;

SET GBIDRAG(P)  General paid supports
 /GACRSUB, 
  ECOSUB,
  CATTLESUB, SOWHLTSUB/;

SET CROPACR(AS)  Land use: 1000 hectare
 /W-WHEAT, W-RAY, W-BARLEY, BARLEY, OATS, GRAINSIL, FEEDPEAS, FEEDPEASH, W-RAPE, S-RAPE,
  POTATO, SUGAR, FORAGE1*FORAGE4, PASTURE1, PASTURE2, NEWFOR, OTHERCROPS, SALIX, LAY, LONGLAY,
  EW-WHEAT, EW-RAY, EBARLEY, EOATS, EFEEDPEAS, EW-RAPE, ES-RAPE, EPOTATO, ESUGAR,
  EFORAGE1*EFORAGE4,EPASTURE1, EPASTURE2, ENEWFOR, EOTHRCROPS, ELAY, ENFIX, ECOPIG, EPOULTRY,
  SPAREFOR, ICR, NOUSE, PPASTR, PPASTRB, PPASTRT, PPASTRN, PPASTRH, PPASTRHB, PPASTRHT,
  PPASTRHN, PPASTRALV, PPASTRFOR, PPASTRMOS, PPASTRLOW, PPASTRCHAL, PPASTRMEAD,
  SPAPASTR, SPAPASTRB, SPAPASTRT, SPAPASTRH, SPAPASTRHB, SPAPASTRHT, UPGRPAST, UPGRPASTH,
  CROPTOPAST, LVSTKIN, LVSTKOUT/;	

SET SELI(I)  Selected inputs
 /LABOR, NITROGEN, PHOSPHORUS, POTASSIUM, PESTICIDES, POWER/;

PARAMETER RTBL1(R,SR,PS,TH1)  Results for subregional products: 1000 tons;
RTBL1(R,SR,PS,TH1) = 0.0;
RTBL1(R,SR,PS,'PRODUCTION') $RSRPS(R,SR,PS) =
  SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,PS) LT 0)), -EAS(R,SR,AS,PS)*PRODSR.L(R,SR,AS));
RTBL1(R,SR,PS,'USE') $RSRPS(R,SR,PS) =
  SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,PS) GT 0)), EAS(R,SR,AS,PS)*PRODSR.L(R,SR,AS));
RTBL1(R,SR,PS,'DEMAND') $PSED(R,SR,PS) = DEMANDPS.L(R,SR,PS);
RTBL1(R,SR,PS,'FIXED-DEM') $PSFD(R,SR,PS) = PRODUCTSF.LO(R,SR,PS);
RTBL1(R,SR,PS,'PRICE') $RSRPS(R,SR,PS) = - PRODUCTSE.M(R,SR,PS) $PSED(R,SR,PS)
                                         - PRODUCTSF.M(R,SR,PS) $PSFD(R,SR,PS);
 
PARAMETER RTBL1B(SR,PRIMP)  Total production by production region;
RTBL1B(SR,PRIMP) = 0.0;
RTBL1B(SR,PRIMP) = SUM(R $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,PRIMP) LT 0)),
                         -EAS(R,SR,AS,PRIMP)*PRODSR.L(R,SR,AS)));

PARAMETER RTBL1B2(UPR,PRIMP)  Total production by FA region: 1000 ton;
RTBL1B2(UPR,PRIMP) = SUM(SR $UPRSR(UPR,SR), RTBL1B(SR,PRIMP));


PARAMETER RTBL1C(SR,P)  Gross production value by production region: Million SEK;
RTBL1C(SR,P) = 0.0;
RTBL1C(SR,PR) $PRIMP(PR) =
  SUM(R $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,PR) LT 0)),
                         -EAS(R,SR,AS,PR)*PRODSR.L(R,SR,AS)*
                            (-PRODUCTRE.M(R,PR) -PRODUCTRF.M(R,PR))));
RTBL1C(SR,PS) $PRIMP(PS) =
  SUM(R $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,PS) LT 0)),
                         -EAS(R,SR,AS,PS)*PRODSR.L(R,SR,AS)*
                            (-PRODUCTSE.M(R,SR,PS) -PRODUCTSF.M(R,SR,PS))));

PARAMETER RTBL1C2(UPR,P)  Gross production value by FA region: Million SEK;
RTBL1C2(UPR,P) = SUM(SR $UPRSR(UPR,SR), RTBL1C(SR,P));


PARAMETER RTBL1D(SR,P)  Net production value by production region: Million SEK;
RTBL1D(SR,P) = 0.0;
RTBL1D(SR,PR) $PRIMP(PR) =
  SUM(R $RSR(R,SR), SUM(AS $RSRAS(R,SR,AS),
                         -EAS(R,SR,AS,PR)*PRODSR.L(R,SR,AS)*
                            (-PRODUCTRE.M(R,PR) -PRODUCTRF.M(R,PR))));
RTBL1D(SR,PS) $PRIMP(PS) =
  SUM(R $RSR(R,SR), SUM(AS $RSRAS(R,SR,AS),
                         -EAS(R,SR,AS,PS)*PRODSR.L(R,SR,AS)*
                            (-PRODUCTSE.M(R,SR,PS) -PRODUCTSF.M(R,SR,PS))));

PARAMETER RTBL1E(SR,P)  Total support by production region: Million SEK;
RTBL1E(SR,P) = 0.0;
RTBL1E(SR,PN) $BIDRAG(PN) =
  SUM(R $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,PN) LT 0)),
                         -EAS(R,SR,AS,PN)*PRODSR.L(R,SR,AS)*
                            (-PRODUCTNE.M(PN) -PRODUCTNF.M(PN))));
RTBL1E(SR,PR) $BIDRAG(PR) =
  SUM(R $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,PR) LT 0)),
                         -EAS(R,SR,AS,PR)*PRODSR.L(R,SR,AS)*
                            (-PRODUCTRE.M(R,PR) -PRODUCTRF.M(R,PR))));
RTBL1E(SR,PS) $BIDRAG(PS) =
  SUM(R $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,PS) LT 0)),
                         -EAS(R,SR,AS,PS)*PRODSR.L(R,SR,AS)*
                            (-PRODUCTSE.M(R,SR,PS) -PRODUCTSF.M(R,SR,PS))));

PARAMETER RTBL2(R,PR,TH1)  Results for regional products;
RTBL2(R,PR,TH1) = 0.0;
RTBL2(R,PR,'PRODUCTION') $RPR(R,PR) =
  SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,PR) LT 0)),
                         -EAS(R,SR,AS,PR)*PRODSR.L(R,SR,AS)))
  + SUM(CR $(RCR(R,CR) $(ECR(R,CR,PR) LT 0)), -ECR(R,CR,PR)*PROCR.L(R,CR));
RTBL2(R,PR,'USE') $RPR(R,PR) =
  SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,PR) GT 0)),
                         EAS(R,SR,AS,PR)*PRODSR.L(R,SR,AS)))
  + SUM(CR $(RCR(R,CR) $(ECR(R,CR,PR) GT 0)), ECR(R,CR,PR)*PROCR.L(R,CR));
RTBL2(R,PR,'SHIP-IN') $RPR(R,PR) = SUM(RS $TIP(RS,R,PR), TRANIP.L(RS,R,PR));
RTBL2(R,PR,'SHIP-OUT') $RPR(R,PR) = SUM(RD $TIP(R,RD,PR), TRANIP.L(R,RD,PR));
RTBL2(R,PR,'DEMAND') $PRED(R,PR) = DEMANDPR.L(R,PR);
RTBL2(R,PR,'FIXED-DEM') $PRFD(R,PR) = PRODUCTRF.LO(R,PR);
RTBL2(R,PR,'IMPORT') $RPRIM(R,PR) = IMPORTPR.L(R,PR);
RTBL2(R,PR,'EXPORT') $RPREX(R,PR) = EXPORTRP.L(R,PR);
RTBL2(R,PR,'PRICE') $RPR(R,PR) = - PRODUCTRE.M(R,PR) $PRED(R,PR) - PRODUCTRF.M(R,PR) $PRFD(R,PR);

PARAMETER RTBL3(PN,TH1)  Results for national products;
RTBL3(PN,TH1) = 0.0;
RTBL3(PN,'PRODUCTION') =
  SUM(R,SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,PN) LT 0)),
                               -EAS(R,SR,AS,PN)*PRODSR.L(R,SR,AS)))
        + SUM(CR $(RCR(R,CR) $(ECR(R,CR,PN) LT 0)), -ECR(R,CR,PN)*PROCR.L(R,CR)));
RTBL3(PN,'USE') =
  SUM(R,SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,PN) GT 0)),
                                               EAS(R,SR,AS,PN)*PRODSR.L(R,SR,AS)))
                        + SUM(CR $(RCR(R,CR) $(ECR(R,CR,PN) GT 0)), ECR(R,CR,PN)*PROCR.L(R,CR)));
RTBL3(PN,'DEMAND') $PNED(PN) = DEMANDPN.L(PN);
RTBL3(PN,'FIXED-DEM') $PNFD(PN) = PRODUCTNF.LO(PN);
RTBL3(PN,'PRICE') = - PRODUCTNE.M(PN) $PNED(PN) - PRODUCTNF.M(PN) $PNFD(PN);
 
PARAMETER RTBL4(P,TH1)  National summary for all products;
RTBL4(P,TH1) = 0.0;
RTBL4(PS,'PRODUCTION') = SUM(R, SUM(SR $RSRPS(R,SR,PS), RTBL1(R,SR,PS,'PRODUCTION')));
RTBL4(PR,'PRODUCTION') = SUM(R $RPR(R,PR), RTBL2(R,PR,'PRODUCTION'));
RTBL4(PN,'PRODUCTION') = RTBL3(PN,'PRODUCTION');
RTBL4(PS,'USE') = SUM(R, SUM(SR $RSRPS(R,SR,PS), RTBL1(R,SR,PS,'USE')));
RTBL4(PR,'USE') = SUM(R $RPR(R,PR), RTBL2(R,PR,'USE'));
RTBL4(PN,'USE') = RTBL3(PN,'USE');
RTBL4(PR,'SHIPMENTS') = SUM(R $RPR(R,PR), RTBL2(R,PR,'SHIP-OUT'));
RTBL4(PS,'DEMAND') = SUM(R, SUM(SR $PSED(R,SR,PS), RTBL1(R,SR,PS,'DEMAND')));
RTBL4(PR,'DEMAND') = SUM(R $PRED(R,PR), RTBL2(R,PR,'DEMAND'));
RTBL4(PN,'DEMAND') $PNED(PN) = RTBL3(PN,'DEMAND');
RTBL4(PS,'FIXED-DEM') = SUM(R, SUM(SR $PSFD(R,SR,PS), RTBL1(R,SR,PS,'FIXED-DEM')));
RTBL4(PR,'FIXED-DEM') = SUM(R $PRFD(R,PR), RTBL2(R,PR,'FIXED-DEM')); 
RTBL4(PN,'FIXED-DEM') $PNFD(PN) = RTBL3(PN,'FIXED-DEM');
RTBL4(PR,'IMPORT') = SUM(R $RPR(R,PR), RTBL2(R,PR,'IMPORT'));
RTBL4(PR,'EXPORT') = SUM(R $RPR(R,PR), RTBL2(R,PR,'EXPORT'));
RTBL4(PS,'PRICE') =
  SUM(R, SUM(SR $(RSRPS(R,SR,PS) $(RTBL4(PS,'PRODUCTION') GT 0)),

             RTBL1(R,SR,PS,'PRICE')*RTBL1(R,SR,PS,'PRODUCTION')/RTBL4(PS,'PRODUCTION')));
RTBL4(PR,'PRICE') =
  SUM(R $(RPR(R,PR) $(RTBL4(PR,'PRODUCTION') GT 0)),
      RTBL2(R,PR,'PRICE')*RTBL2(R,PR,'PRODUCTION')/RTBL4(PR,'PRODUCTION'));
RTBL4(PN,'PRICE') = RTBL3(PN,'PRICE');
 
PARAMETER RTBL5(R,PS,SR)  Subregional product prices;
RTBL5(R,PS,SR) = 0.0;
RTBL5(R,PS,SR) = RTBL1(R,SR,PS,'PRICE');
 
PARAMETER RTBL6(PR,R)  Regional product prices;
RTBL6(PR,R) = 0.0;

RTBL6(PR,R) = RTBL2(R,PR,'PRICE');

PARAMETER RTBL6A(PR,R)  Regional consumtion;
RTBL6A(PR,R) = 0.0;

RTBL6A(PR,R) = RTBL2(R,PR,'DEMAND');

PARAMETER RTBL6B(*,R)  Regional consumtion;
RTBL6B('ENERGY',R) = RTBL2(R,'ENERGY','PRODUCTION') - RTBL2(R,'ENERGY','USE');
RTBL6B('PROTEIN',R) = RTBL2(R,'PROTEIN','PRODUCTION') - RTBL2(R,'PROTEIN','USE');
RTBL6B('PROTEINA',R) = RTBL2(R,'PROTEINA','PRODUCTION') - RTBL2(R,'PROTEINA','USE');
RTBL6B('FAT',R) = RTBL2(R,'FAT','PRODUCTION') - RTBL2(R,'FAT','USE');
RTBL6B('CARBOH',R) = RTBL2(R,'CARBOH','PRODUCTION') - RTBL2(R,'CARBOH','USE');
RTBL6B('FEEDGRAINU',R) = RTBL2(R,'FEEDGRAIN','USE');

 
PARAMETER RTBL7(R,SR,IS,TH1)  Results for subregional inputs;
RTBL7(R,SR,IS,TH1) = 0.0;

RTBL7(R,SR,IS,'PRODUCTION') $RSRIS(R,SR,IS) =
  SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,IS) LT 0)), -EAS(R,SR,AS,IS)*PRODSR.L(R,SR,AS));
RTBL7(R,SR,IS,'USE') $RSRIS(R,SR,IS) =
  SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,IS) GT 0)), EAS(R,SR,AS,IS)*PRODSR.L(R,SR,AS));
RTBL7(R,SR,IS,'SUPPLY') $ISES(R,SR,IS) = SUPPLYIS.L(R,SR,IS);
RTBL7(R,SR,IS,'FIXED-SUP') $ISFS(R,SR,IS) = INPUTSF.UP(R,SR,IS);
RTBL7(R,SR,IS,'PRICE') $RSRIS(R,SR,IS) = INPUTSE.M(R,SR,IS) $ISES(R,SR,IS)
                                         + INPUTSF.M(R,SR,IS) $ISFS(R,SR,IS);
 
PARAMETER RTBL7B(SR,I)  Use of some inputs;
RTBL7B(SR,I) $SELI(I) =
  SUM(R $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,I) GT 0)),
                         EAS(R,SR,AS,I)*PRODSR.L(R,SR,AS)));

PARAMETER RTBL7B2(UPR,I)  Use of some inputs by FA region;
RTBL7B2(UPR,I) $SELI(I) =  SUM(SR $UPRSR(UPR,SR), RTBL7B(SR,I));

PARAMETER RTBL8(R,IR,TH1)  Results for regional inputs;
RTBL8(R,IR,TH1) = 0.0;
RTBL8(R,IR,'PRODUCTION') $RIR(R,IR) =
  SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,IR) LT 0)),
                         -EAS(R,SR,AS,IR)*PRODSR.L(R,SR,AS)))
  + SUM(CR $(RCR(R,CR) $(ECR(R,CR,IR) LT 0)), -ECR(R,CR,IR)*PROCR.L(R,CR));
RTBL8(R,IR,'USE') $RIR(R,IR) =
  SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,IR) GT 0)),
                         EAS(R,SR,AS,IR)*PRODSR.L(R,SR,AS)))
  + SUM(CR $(RCR(R,CR) $(ECR(R,CR,IR) GT 0)), ECR(R,CR,IR)*PROCR.L(R,CR));
RTBL8(R,IR,'SHIP-IN') $RIR(R,IR) = SUM(RS $TIP(RS,R,IR), TRANIP.L(RS,R,IR));
RTBL8(R,IR,'SHIP-OUT') $RIR(R,IR) = SUM(RD $TIP(R,RD,IR), TRANIP.L(R,RD,IR));
RTBL8(R,IR,'SUPPLY') $IRES(R,IR) = SUPPLYIR.L(R,IR);
RTBL8(R,IR,'FIXED-SUP') $IRFS(R,IR) = INPUTRF.UP(R,IR);

RTBL8(R,IR,'PRICE') $RIR(R,IR) = INPUTRE.M(R,IR) $IRES(R,IR) + INPUTRF.M(R,IR) $IRFS(R,IR);
 
PARAMETER RTBL9(IN,TH1)  Results for national inputs;
RTBL9(IN,TH1) = 0.0;
RTBL9(IN,'PRODUCTION') =
  SUM(R,SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,IN) LT 0)),
                               -EAS(R,SR,AS,IN)*PRODSR.L(R,SR,AS)))
        + SUM(CR $(RCR(R,CR) $(ECR(R,CR,IN) LT 0)), -ECR(R,CR,IN)*PROCR.L(R,CR)));
RTBL9(IN,'USE') =
  SUM(R,SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,IN) GT 0)),
                                               EAS(R,SR,AS,IN)*PRODSR.L(R,SR,AS)))
                        + SUM(CR $(RCR(R,CR) $(ECR(R,CR,IN) GT 0)), ECR(R,CR,IN)*PROCR.L(R,CR)));
RTBL9(IN,'SUPPLY') $INES(IN) = SUPPLYIN.L(IN);
RTBL9(IN,'FIXED-SUP') $INFS(IN) = INPUTNF.UP(IN);
RTBL9(IN,'PRICE') = INPUTNE.M(IN) $INES(IN) + INPUTNF.M(IN) $INFS(IN);
 
PARAMETER RTBL9A(*,*)  Summary for production and inputs;
RTBL9A(SR,'AGRLAND')   = SUM(R, RTBL7(R,SR,'CROPLAND','USE')
   + RTBL7(R,SR,'PRMPAST','USE') + RTBL7(R,SR,'PRMPASTB','USE') + RTBL7(R,SR,'PRMPASTT','USE')
   + RTBL7(R,SR,'PRMPASTN','USE') + RTBL7(R,SR,'PRMPASTH','USE') + RTBL7(R,SR,'PRMPASTHB','USE')
   + RTBL7(R,SR,'PRMPASTHT','USE') + RTBL7(R,SR,'PRMPASTHN','USE')+ RTBL7(R,SR,'PRMALV','USE')
   + RTBL7(R,SR,'PRMFOR','USE') + RTBL7(R,SR,'PRMMOS','USE') + RTBL7(R,SR,'PRMLOW','USE')
   + RTBL7(R,SR,'PRMCHAL','USE') + RTBL7(R,SR,'PRMMEAD','USE'));
RTBL9A(SR,'GROSSPROD') = SUM(P, RTBL1C(SR,P));
RTBL9A(SR,'NETPROD')   = SUM(P, RTBL1D(SR,P));
RTBL9A(SR,'DIRECTPAYM')= SUM(P, RTBL1E(SR,P));
RTBL9A(SR,'GENERALSUP')= SUM(P $GBIDRAG(P), RTBL1E(SR,P));
RTBL9A(SR,SELI)        = RTBL7B(SR,SELI);
RTBL9A('SWEDEN','AGRLAND')    = SUM(SR, RTBL9A(SR,'AGRLAND'));
RTBL9A('SWEDEN','GROSSPROD')  = SUM(SR, SUM(P, RTBL1C(SR,P)));
RTBL9A('SWEDEN','NETPROD')    = SUM(SR, SUM(P, RTBL1D(SR,P)));
RTBL9A('SWEDEN','DIRECTPAYM') = SUM(SR, SUM(P, RTBL1E(SR,P)));
RTBL9A('SWEDEN','GENERALSUP') = SUM(SR, SUM(P $GBIDRAG(P), RTBL1E(SR,P)));
RTBL9A('SWEDEN',SELI)         = SUM(SR, RTBL7B(SR,SELI));

PARAMETER RTBL9B(*,*)  Production and inputs per hour;

RTBL9B(SR,'AGRLAND')   = RTBL9A(SR,'AGRLAND')/RTBL9A(SR,'LABOR');
RTBL9B(SR,'GROSSPROD') = RTBL9A(SR,'GROSSPROD')/RTBL9A(SR,'LABOR');
RTBL9B(SR,'NETPROD')   = RTBL9A(SR,'NETPROD')/RTBL9A(SR,'LABOR');
RTBL9B(SR,'DIRECTPAYM')= RTBL9A(SR,'DIRECTPAYM')/RTBL9A(SR,'LABOR');
RTBL9B(SR,SELI)        = RTBL9A(SR,SELI)/RTBL9A(SR,'LABOR');
RTBL9B('SWEDEN','AGRLAND')   = RTBL9A('SWEDEN','AGRLAND')/RTBL9A('SWEDEN','LABOR');
RTBL9B('SWEDEN','GROSSPROD') = RTBL9A('SWEDEN','GROSSPROD')/RTBL9A('SWEDEN','LABOR');

RTBL9B('SWEDEN','NETPROD')   = RTBL9A('SWEDEN','NETPROD')/RTBL9A('SWEDEN','LABOR');
RTBL9B('SWEDEN','DIRECTPAYM')= RTBL9A('SWEDEN','DIRECTPAYM')/RTBL9A('SWEDEN','LABOR');
RTBL9B('SWEDEN',SELI)        = RTBL9A('SWEDEN',SELI)/RTBL9A('SWEDEN','LABOR');

PARAMETER RTBL9C(*,*)  Production and inputs per hectare of agricultural land;
RTBL9C(SR,'AGRLAND')   = RTBL9A(SR,'AGRLAND')/RTBL9A(SR,'AGRLAND');
RTBL9C(SR,'GROSSPROD') = RTBL9A(SR,'GROSSPROD')/RTBL9A(SR,'AGRLAND');
RTBL9C(SR,'NETPROD')   = RTBL9A(SR,'NETPROD')/RTBL9A(SR,'AGRLAND');
RTBL9C(SR,'DIRECTPAYM')= RTBL9A(SR,'DIRECTPAYM')/RTBL9A(SR,'AGRLAND');
RTBL9C(SR,SELI)        = RTBL9A(SR,SELI)/RTBL9A(SR,'AGRLAND');
RTBL9C('SWEDEN','AGRLAND')   = RTBL9A('SWEDEN','AGRLAND')/RTBL9A('SWEDEN','AGRLAND');
RTBL9C('SWEDEN','GROSSPROD') = RTBL9A('SWEDEN','GROSSPROD')/RTBL9A('SWEDEN','AGRLAND');

RTBL9C('SWEDEN','NETPROD')   = RTBL9A('SWEDEN','NETPROD')/RTBL9A('SWEDEN','AGRLAND');

RTBL9C('SWEDEN','DIRECTPAYM')= RTBL9A('SWEDEN','DIRECTPAYM')/RTBL9A('SWEDEN','AGRLAND');
RTBL9C('SWEDEN',SELI)        = RTBL9A('SWEDEN',SELI)/RTBL9A('SWEDEN','AGRLAND');

PARAMETER RTBL10(I,TH1)  National summary for all inputs;
RTBL10(I,TH1) = 0.0;

RTBL10(IS,'PRODUCTION') = SUM(R, SUM(SR $RSRIS(R,SR,IS), RTBL7(R,SR,IS,'PRODUCTION')));
RTBL10(IR,'PRODUCTION') = SUM(R $RIR(R,IR), RTBL8(R,IR,'PRODUCTION'));
RTBL10(IN,'PRODUCTION') = RTBL9(IN,'PRODUCTION');
RTBL10(IS,'USE') = SUM(R, SUM(SR $RSRIS(R,SR,IS), RTBL7(R,SR,IS,'USE')));
RTBL10(IR,'USE') = SUM(R $RIR(R,IR), RTBL8(R,IR,'USE'));
RTBL10(IN,'USE') = RTBL9(IN,'USE');
RTBL10(IR,'SHIPMENTS') = SUM(R $RIR(R,IR), RTBL8(R,IR,'SHIP-OUT'));
RTBL10(IS,'SUPPLY') = SUM(R, SUM(SR $ISES(R,SR,IS), RTBL7(R,SR,IS,'SUPPLY')));
RTBL10(IR,'SUPPLY') = SUM(R $IRES(R,IR), RTBL8(R,IR,'SUPPLY'));
RTBL10(IN,'SUPPLY') $INES(IN) = RTBL9(IN,'SUPPLY');
RTBL10(IS,'FIXED-SUP') = SUM(R, SUM(SR $RSRIS(R,SR,IS), RTBL7(R,SR,IS,'FIXED-SUP')));
RTBL10(IR,'FIXED-SUP') = SUM(R $IRFS(R,IR), RTBL8(R,IR,'FIXED-SUP'));
RTBL10(IN,'FIXED-SUP') $INFS(IN) = RTBL9(IN,'FIXED-SUP');
RTBL10(IS,'PRICE') =
  SUM(R, SUM(SR $(RSRIS(R,SR,IS) $(RTBL10(IS,'USE') GT 0)),
             RTBL7(R,SR,IS,'PRICE')*RTBL7(R,SR,IS,'USE')/RTBL10(IS,'USE')));
RTBL10(IR,'PRICE') =
  SUM(R $(RIR(R,IR) $(RTBL10(IR,'USE') GT 0)),
      RTBL8(R,IR,'PRICE')*RTBL8(R,IR,'USE')/RTBL10(IR,'USE'));
RTBL10(IN,'PRICE') = RTBL9(IN,'PRICE');
 

PARAMETER RTBL11(R,IS,SR)  Subregional input prices;
RTBL11(R,IS,SR) = 0.0;
RTBL11(R,IS,SR) = RTBL7(R,SR,IS,'PRICE');
 
PARAMETER RTBL12(IR,R)  Regional input prices;
RTBL12(IR,R) = 0.0;
RTBL12(IR,R) = RTBL8(R,IR,'PRICE');

 
PARAMETER RTBL13(R,AS,SR)  Subregional production activities;
RTBL13(R,AS,SR) = 0.0;


RTBL13(R,AS,SR) $RSRAS(R,SR,AS) = PRODSR.L(R,SR,AS);

PARAMETER RTBL13C(CROPACR,SR)  Crop acreage by subregion: 1000 ha;
RTBL13C(CROPACR,SR) = 0.0;
RTBL13C(CROPACR,SR) = SUM(R $RSRAS(R,SR,CROPACR), PRODSR.L(R,SR,CROPACR));

PARAMETER RTBL13C2(CROPACR, UPR)  Crop acreage by Output-region;
RTBL13C2(CROPACR,UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13C(CROPACR, SR)); 

PARAMETER RTBL13D(LIVESTOCK,SR)  Numbers of livestock by subregion: 1000 Head;
RTBL13D(LIVESTOCK,SR) = 0.0;
RTBL13D(LIVESTOCK,SR) = SUM(R $RSRAS(R,SR, LIVESTOCK), PRODSR.L(R,SR,LIVESTOCK));

PARAMETER RTBL13D2(LIVESTOCK, UPR)  Numbers of livestock by Output-region;
RTBL13D2(LIVESTOCK,UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13D(LIVESTOCK, SR)); 

PARAMETER RTBL13B(SR,AS)  Production activities by subregion;
RTBL13B(SR,AS) = 0.0;

RTBL13B(SR,AS) = SUM(R $RSRAS(R,SR,AS), PRODSR.L(R,SR,AS));

PARAMETER RTBL13E(*,*)  Crop acreage and numbers of livestock by subregion;
RTBL13E('VALL',SR)       = RTBL13C('FORAGE1',SR)+RTBL13C('FORAGE2',SR)+RTBL13C('FORAGE3',SR)+
                         RTBL13C('FORAGE4',SR)+RTBL13C('PASTURE1',SR)+RTBL13C('PASTURE2',SR)+
                         RTBL13C('EFORAGE1',SR)+RTBL13C('EFORAGE2',SR)+RTBL13C('EFORAGE3',SR)+
                         RTBL13C('EFORAGE4',SR)+RTBL13C('EPASTURE1',SR)+RTBL13C('EPASTURE2',SR)+
                         RTBL13C('ENEWFOR',SR)+
                         RTBL13C('NEWFOR',SR)+RTBL13C('SPAREFOR',SR);
RTBL13E('HOSTSAD',SR)    = RTBL13C('W-WHEAT',SR)+RTBL13C('W-RAY',SR)+RTBL13C('W-BARLEY',SR)+
                            RTBL13C('GRAINSIL',SR)/2
                         +RTBL13C('EW-WHEAT',SR)+RTBL13C('EW-RAY',SR);
RTBL13E('VARSAD',SR)     = RTBL13C('BARLEY',SR)+RTBL13C('OATS',SR)+RTBL13C('GRAINSIL',SR)/2
                         +RTBL13C('EBARLEY',SR)+RTBL13C('EOATS',SR);	
RTBL13E('OLJEVAXT',SR)   = RTBL13C('W-RAPE',SR)+RTBL13C('S-RAPE',SR)
                         +RTBL13C('EW-RAPE',SR)+RTBL13C('ES-RAPE',SR);
RTBL13E('UTTAG',SR)      = RTBL13C('LAY',SR)+RTBL13C('LONGLAY',SR)+RTBL13C('NOUSE',SR)
                         +RTBL13C('ELAY',SR)+RTBL13C('ENFIX',SR);
RTBL13E('OVGRODOR',SR)   = RTBL13C('POTATO',SR)+RTBL13C('SUGAR',SR)+RTBL13C('OTHERCROPS',SR)+
                         RTBL13C('FEEDPEAS',SR)+RTBL13C('FEEDPEASH',SR)+RTBL13C('SALIX',SR)+
                         RTBL13C('EFEEDPEAS',SR)+RTBL13C('EPOTATO',SR)+RTBL13C('ESUGAR',SR)+
                         RTBL13C('EOTHRCROPS',SR)+RTBL13C('ECOPIG',SR)+RTBL13C('EPOULTRY',SR)+
                         RTBL13C('ICR',SR);
RTBL13E('AKER',SR)       = RTBL13E('VALL',SR)+RTBL13E('HOSTSAD',SR)+RTBL13E('VARSAD',SR)+
                         RTBL13E('OLJEVAXT',SR)+RTBL13E('UTTAG',SR)+RTBL13E('OVGRODOR',SR);
RTBL13E('BETESMARK',SR)  = RTBL13C('PPASTR',SR)+RTBL13C('PPASTRT',SR)+RTBL13C('PPASTRN',SR)+
                         RTBL13C('PPASTRH',SR)+RTBL13C('PPASTRHT',SR)+RTBL13C('PPASTRHN',SR)+
                         RTBL13C('PPASTRALV',SR)+RTBL13C('PPASTRFOR',SR)+RTBL13C('PPASTRMOS',SR)+
                         RTBL13C('PPASTRLOW',SR)+RTBL13C('PPASTRCHAL',SR)+RTBL13C('PPASTRMEAD',SR);
RTBL13E('MJOLKKO',SR)    = RTBL13D('DCOW1',SR)+RTBL13D('DCOW2',SR)+RTBL13D('DCOW3',SR)+
                           RTBL13D('DCOW4',SR)
                           +RTBL13D('EDCOW1',SR)+RTBL13D('EDCOW2',SR)+RTBL13D('EDCOW3',SR);

RTBL13E('DIKO',SR)       = RTBL13D('BEEFCATTLE',SR) + RTBL13D('BEEFCATTL2',SR)
                           + RTBL13D('EBEEFCATT',SR) + RTBL13D('EBEEFCAT2',SR);
RTBL13E('REKKVIGA1',SR)  = RTBL13D('HEIFER',SR) + 
                           RTBL13D('EHEIFER',SR) + 
                           RTBL13E('DIKO',SR)*0.2*1.1; 
RTBL13E('REKKVIGA2',SR)  = RTBL13D('HEIFER',SR)*13/12 +
                           RTBL13D('EHEIFER',SR)*13/12 +
                           RTBL13E('DIKO',SR)*0.2*1.1; 
RTBL13E('SLAKTKVIG1',SR) = RTBL13D('SLGHHEIFER',SR)*12/12 +
                           RTBL13D('ESLGHHEIF',SR)*12/12 + 
                           RTBL13E('DIKO',SR)*0.2*1.1*12/12; 
RTBL13E('SLAKTKVIG2',SR) = RTBL13D('SLGHHEIFER',SR)*16.75/12 +
                           RTBL13D('ESLGHHEIF',SR)*16.75/12 + 
                           RTBL13E('DIKO',SR)*0.2*1.1*16.75/12; 
RTBL13E('TJUR1',SR)      = RTBL13D('DAIRYBULL1',SR)*12/12 +
                           RTBL13D('EDBULL1',SR)*12/12 + 
                           RTBL13D('BEEFCATTLE',SR)*0.4*1.1 + RTBL13D('EBEEFCATT',SR)*0.4*1.1;
RTBL13E('TJUR2',SR)      = RTBL13D('DAIRYBULL1',SR)*8.7/12  +
                           RTBL13D('EDBULL1',SR)*8.7/12  + 
                           RTBL13D('BEEFCATTLE',SR)*0.4*1.1*0.725 +
                           RTBL13D('EBEEFCATT',SR)*0.4*1.1*0.725;
RTBL13E('STUT1',SR)      = RTBL13D('DAIRYBULL2',SR)*12/12
                           + RTBL13D('EDBULL2',SR)*12/12 
                           + RTBL13D('BEEFCATTL2',SR)*0.4*1.1 + RTBL13D('EBEEFCAT2',SR)*0.4*1.1;
RTBL13E('STUT2',SR)      = RTBL13D('DAIRYBULL2',SR)*16.75/12
                           + RTBL13D('EDBULL2',SR)*16.75/12 
                           + RTBL13D('BEEFCATTL2',SR)*16.75/12*0.4*1.1
                           + RTBL13D('EBEEFCAT2',SR)*16.75/12*0.4*1.1;
RTBL13E('SUGGA',SR)      = RTBL13D('SOW1',SR)
                           + RTBL13D('ECOPIG',SR);
*RTBL13E('SLAKTSVIN',SR)  = RTBL13D('SLGHSWINE1',SR)*PRODCOS('SLGHSWINE1','SWINEFAC',SR)
*                          + RTBL13D('ECOPIG',SR)*20*0.4;

RTBL13E('GRAINPROD',SR)  =  SUM(R $RSR(R,SR), 
                                  SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,'BREADGRAIN') LT 0)),
                                    -EAS(R,SR,AS,'BREADGRAIN')*PRODSR.L(R,SR,AS)) +
                                  SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,'COARSGRAIN') LT 0)),
                                    -EAS(R,SR,AS,'COARSGRAIN')*PRODSR.L(R,SR,AS)));
RTBL13E('BEEFPROD',SR)   =  SUM(R $RSR(R,SR), 
                                  SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,'SLGHBEEF') LT 0)),
                                    -EAS(R,SR,AS,'SLGHBEEF')*PRODSR.L(R,SR,AS)));
RTBL13E('N-LACKAGE',SR)  =  SUM(R $RSRIS(R,SR,'N-LEAKAGE'), RTBL7(R,SR,'N-LEAKAGE','USE'));
RTBL13E('P-LACKAGE',SR)  =  SUM(R $RSRIS(R,SR,'P-LEAKAGE'), RTBL7(R,SR,'P-LEAKAGE','USE'));
*RTBL13E('N-PROD',SR)     =  SUM(R $RSRIS(R,SR,'N-PROD'), RTBL7(R,SR,'N-PROD','USE'));
*RTBL13E('P-PROD',SR)     =  SUM(R $RSRIS(R,SR,'P-PROD'), RTBL7(R,SR,'P-PROD','USE'));
*RTBL13E('AMMONIAK',SR)   =  SUM(R $RSRIS(R,SR,'CO2'),RTBL7(R,SR,'CO2','USE'));
RTBL13E('DIREKTBET',SR)  =  RTBL9A(SR,'DIRECTPAYM');
RTBL13E('AE&DB',SR)      =  RTBL9A(SR,'GENERALSUP');
RTBL13E('N-MANURE',SR)   =  SUM(R $RSR(R,SR), 
                                  SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,'NITROGEN') LT 0)),
                                    -EAS(R,SR,AS,'NITROGEN')*PRODSR.L(R,SR,AS)));
RTBL13E('N-USE',SR)      =  SUM(R $RSR(R,SR), 
                                  SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,'NITROGEN') GT 0)),
                                    EAS(R,SR,AS,'NITROGEN')*PRODSR.L(R,SR,AS)));
RTBL13E('N-BOUGHT',SR)   =  SUM(R $(RSR(R,SR) 
                          $(SUM(AS $RSRAS(R,SR,AS), EAS(R,SR,AS,'NITROGEN')*PRODSR.L(R,SR,AS)) GT 0)), 
                                   SUM(AS $RSRAS(R,SR,AS), EAS(R,SR,AS,'NITROGEN')*PRODSR.L(R,SR,AS)));
RTBL13E('P-MANURE',SR)   =  SUM(R $RSR(R,SR), 
                                  SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,'PHOSPHORUS') LT 0)),
                                    -EAS(R,SR,AS,'PHOSPHORUS')*PRODSR.L(R,SR,AS)));
RTBL13E('P-USE',SR)      =  SUM(R $RSR(R,SR), 
                                  SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,'PHOSPHORUS') GT 0)),
                                    EAS(R,SR,AS,'PHOSPHORUS')*PRODSR.L(R,SR,AS)));
RTBL13E('P-BOUGHT',SR)   =  SUM(R $(RSR(R,SR) 
                         $(SUM(AS $RSRAS(R,SR,AS), EAS(R,SR,AS,'PHOSPHORUS')*PRODSR.L(R,SR,AS)) GT 0)), 
                                 SUM(AS $RSRAS(R,SR,AS), EAS(R,SR,AS,'PHOSPHORUS')*PRODSR.L(R,SR,AS)));
RTBL13E('K-MANURE',SR)   =  SUM(R $RSR(R,SR), 
                                  SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,'POTASSIUM') LT 0)),
                                    -EAS(R,SR,AS,'POTASSIUM')*PRODSR.L(R,SR,AS)));
RTBL13E('K-USE',SR)      =  SUM(R $RSR(R,SR), 
                                  SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,'POTASSIUM') GT 0)),
                                    EAS(R,SR,AS,'POTASSIUM')*PRODSR.L(R,SR,AS)));
RTBL13E('K-BOUGHT',SR)   =  SUM(R $(RSR(R,SR) 
                          $(SUM(AS $RSRAS(R,SR,AS), EAS(R,SR,AS,'POTASSIUM')*PRODSR.L(R,SR,AS)) GT 0)), 
                                  SUM(AS $RSRAS(R,SR,AS), EAS(R,SR,AS,'POTASSIUM')*PRODSR.L(R,SR,AS)));

* More parameters after RTBL20

RTBL13E('VALL','RIKET')     = SUM(SR, RTBL13E('VALL',SR));
RTBL13E('HOSTSAD','RIKET')  = SUM(SR, RTBL13E('HOSTSAD',SR));
RTBL13E('VARSAD','RIKET')   = SUM(SR, RTBL13E('VARSAD',SR));
RTBL13E('OLJEVAXT','RIKET') = SUM(SR, RTBL13E('OLJEVAXT',SR));
RTBL13E('UTTAG','RIKET')    = SUM(SR, RTBL13E('UTTAG',SR));
RTBL13E('OVGRODOR','RIKET') = SUM(SR, RTBL13E('OVGRODOR',SR));
RTBL13E('AKER','RIKET')     = SUM(SR, RTBL13E('AKER',SR));
RTBL13E('BETESMARK','RIKET')= SUM(SR, RTBL13E('BETESMARK',SR));
RTBL13E('MJOLKKO','RIKET')  = SUM(SR, RTBL13E('MJOLKKO',SR));
RTBL13E('DIKO','RIKET')     = SUM(SR, RTBL13E('DIKO',SR));
RTBL13E('REKKVIGA1','RIKET')  = SUM(SR, RTBL13E('REKKVIGA1',SR));
RTBL13E('REKKVIGA2','RIKET')  = SUM(SR, RTBL13E('REKKVIGA2',SR));
RTBL13E('SLAKTKVIG1','RIKET') = SUM(SR, RTBL13E('SLAKTKVIG1',SR));
RTBL13E('SLAKTKVIG2','RIKET') = SUM(SR, RTBL13E('SLAKTKVIG2',SR));
RTBL13E('TJUR1','RIKET')    = SUM(SR, RTBL13E('TJUR1',SR));
RTBL13E('TJUR2','RIKET')    = SUM(SR, RTBL13E('TJUR2',SR));
RTBL13E('STUT1','RIKET')    = SUM(SR, RTBL13E('STUT1',SR));
RTBL13E('STUT2','RIKET')    = SUM(SR, RTBL13E('STUT2',SR));
RTBL13E('SUGGA','RIKET')    = SUM(SR, RTBL13E('SUGGA',SR));
RTBL13E('SLAKTSVIN','RIKET')= SUM(SR, RTBL13E('SLAKTSVIN',SR));
RTBL13E('GRAINPROD','RIKET')= SUM(SR, RTBL13E('GRAINPROD',SR));
RTBL13E('BEEFPROD','RIKET') = SUM(SR, RTBL13E('BEEFPROD',SR));
*RTBL13E('N-LACKAGE','RIKET')= SUM(SR, RTBL13E('N-LACKAGE',SR));
*RTBL13E('N-PROD','RIKET')   = SUM(SR, RTBL13E('N-PROD',SR));
*RTBL13E('P-PROD','RIKET')   = SUM(SR, RTBL13E('P-PROD',SR));
*RTBL13E('AMMONIAK','RIKET') = SUM(SR, RTBL13E('AMMONIAK',SR));
RTBL13E('DIREKTBET','RIKET')= SUM(SR, RTBL13E('DIREKTBET',SR));
RTBL13E('AE&DB','RIKET')    = SUM(SR, RTBL13E('AE&DB',SR));
RTBL13E('N-MANURE','RIKET') = SUM(SR, RTBL13E('N-MANURE',SR));
RTBL13E('N-USE','RIKET') = SUM(SR, RTBL13E('N-USE',SR));
RTBL13E('N-BOUGHT','RIKET') = SUM(SR, RTBL13E('N-BOUGHT',SR));
RTBL13E('P-MANURE','RIKET') = SUM(SR, RTBL13E('P-MANURE',SR));
RTBL13E('P-USE','RIKET') = SUM(SR, RTBL13E('P-USE',SR));
RTBL13E('P-BOUGHT','RIKET') = SUM(SR, RTBL13E('P-BOUGHT',SR));
RTBL13E('K-MANURE','RIKET') = SUM(SR, RTBL13E('K-MANURE',SR));
RTBL13E('K-USE','RIKET') = SUM(SR, RTBL13E('K-USE',SR));
RTBL13E('K-BOUGHT','RIKET') = SUM(SR, RTBL13E('K-BOUGHT',SR));
* More parameters after RTBL20
 
PARAMETER RTBL14(AS,R)  Production activities by region;
RTBL14(AS,R) = 0.0;
RTBL14(AS,R) = SUM(SR $RSRAS(R,SR,AS), PRODSR.L(R,SR,AS));
 
PARAMETER RTBL15(AS)  National totals for production activities;
RTBL15(AS) = 0.0;
RTBL15(AS) = SUM(R, SUM(SR $RSRAS(R,SR,AS), PRODSR.L(R,SR,AS)));
 
SET TH3  Column headers for net profit tables
 /PRODUCTS, SUPPORT, REVENUE, VARCOST, NETPROFIT/;

PARAMETER RTBL16(SR,CROPS2, TH3) Revenue - costs and net profit for crop activities;

RTBL16(SR,CROPS2,'REVENUE') = SUM(R $RSRAS(R,SR,CROPS2), BIS(R,SR,'CROPLAND','MAX') * 
 (SUM(PS $RSRPS(R,SR,PS), EAS(R,SR,CROPS2,PS) * 
                          (PRODUCTSE.M(R,SR,PS) $PSED(R,SR,PS) + PRODUCTSF.M(R,SR,PS) $PSFD(R,SR,PS)))
     + SUM(PR $RPR(R,PR), EAS(R,SR,CROPS2,PR) * 
                          (PRODUCTRE.M(R,PR) $PRED(R,PR) + PRODUCTRF.M(R,PR) $PRFD(R,PR)))
 ))/SUM(R $RSR(R,SR), BIS(R,SR,'CROPLAND','MAX'));
RTBL16(SR,CROPS2,'SUPPORT') = SUM(R $RSRAS(R,SR,CROPS2), BIS(R,SR,'CROPLAND','MAX') * 
 SUM(SUPPORTS $RSRPS(R,SR,SUPPORTS), EAS(R,SR,CROPS2,SUPPORTS) * 
     (PRODUCTSE.M(R,SR,SUPPORTS) $PSED(R,SR,SUPPORTS) 
      + PRODUCTSF.M(R,SR,SUPPORTS) $PSFD(R,SR, SUPPORTS))))
 /SUM(R $RSR(R,SR), BIS(R,SR,'CROPLAND','MAX'));
RTBL16(SR,CROPS2,'PRODUCTS') = RTBL16(SR,CROPS2,'REVENUE') - RTBL16(SR,CROPS2,'SUPPORT');
RTBL16(SR,CROPS2,'VARCOST') = SUM(R $RSRAS(R,SR,CROPS2), BIS(R,SR,'CROPLAND','MAX') * 
 SUM(IR $RIR(R,IR), EAS(R,SR,CROPS2,IR) * 
                          (INPUTRE.M(R,IR) $IRES(R,IR) + INPUTRF.M(R,IR) $IRFS(R,IR))))

 /SUM(R $RSR(R,SR), BIS(R,SR,'CROPLAND','MAX'));

RTBL16(SR,CROPS2,'NETPROFIT') = RTBL16(SR,CROPS2,'REVENUE') - RTBL16(SR,CROPS2,'VARCOST');

PARAMETER RTBL17(SR,LIVESTOCK, TH3) Revenue - costs and net profit for livestock activities;

RTBL17(SR,LIVESTOCK,'REVENUE') = SUM(R $RSRAS(R,SR,LIVESTOCK), BIS(R,SR,'CROPLAND','MAX') * 
 (SUM(PS $RSRPS(R,SR,PS), EAS(R,SR,LIVESTOCK,PS) * 
                          (PRODUCTSE.M(R,SR,PS) $PSED(R,SR,PS) + PRODUCTSF.M(R,SR,PS) $PSFD(R,SR,PS)))
     + SUM(PR $RPR(R,PR), EAS(R,SR,LIVESTOCK,PR) * 
                          (PRODUCTRE.M(R,PR) $PRED(R,PR) + PRODUCTRF.M(R,PR) $PRFD(R,PR)))
 ))/SUM(R $RSR(R,SR), BIS(R,SR,'CROPLAND','MAX'));
RTBL17(SR,LIVESTOCK,'SUPPORT') = SUM(R $RSRAS(R,SR,LIVESTOCK), BIS(R,SR,'CROPLAND','MAX') * 
 SUM(SUPPORTS $RSRPS(R,SR,SUPPORTS), EAS(R,SR,LIVESTOCK,SUPPORTS) * 
     (PRODUCTSE.M(R,SR,SUPPORTS) $PSED(R,SR,SUPPORTS) 
      + PRODUCTSF.M(R,SR,SUPPORTS) $PSFD(R,SR, SUPPORTS))))
 /SUM(R $RSR(R,SR), BIS(R,SR,'CROPLAND','MAX'));

RTBL17(SR,LIVESTOCK,'PRODUCTS') = RTBL17(SR,LIVESTOCK,'REVENUE') - RTBL17(SR,LIVESTOCK,'SUPPORT');
RTBL17(SR,LIVESTOCK,'VARCOST') = SUM(R $RSRAS(R,SR,LIVESTOCK), BIS(R,SR,'CROPLAND','MAX') * 
 SUM(IR $RIR(R,IR), EAS(R,SR,LIVESTOCK,IR) * 
                          (INPUTRE.M(R,IR) $IRES(R,IR) + INPUTRF.M(R,IR) $IRFS(R,IR))))
 /SUM(R $RSR(R,SR), BIS(R,SR,'CROPLAND','MAX'));
RTBL17(SR,LIVESTOCK,'NETPROFIT') = RTBL17(SR,LIVESTOCK,'REVENUE') - RTBL17(SR,LIVESTOCK,'VARCOST');

* DISPLAY RTBL'S
 
OPTION RTBL4:3:1:1; DISPLAY $OC('PRODUCTS')
'For the national summary, quantities are summed over subregions and regions',
'as appropriate. Prices for subregional and regional products are weighted',
'averages with relative quantities produced as the weights.',RTBL4;

OPTION RTBL10:3:1:1; DISPLAY $OC('INPUTS')

'For the national summary, quantities are summed over subregions and regions',
'as appropriate. Prices for subregional and regional inputs are weighted',
'averages with relative quantities used as the weights. For such inputs, the',
'average price may be positive although total use is less than total supply.',RTBL10;

SCALAR MILKBAL Difference in milk transfere balans (SEK per kg);
       MILKBAL =(RTBL4('DPTRANR','PRODUCTION') - RTBL10('DPTRANC','USE'))/RTBL4('MILK','PRODUCTION');
DISPLAY MILKBAL; 

OPTION RTBL15:3:0:1; DISPLAY $OC('PRODACT') RTBL15;


PARAMETER FIXPRIS(PRIMP) 
 /BREADGRAIN  1.100, COARSGRAIN  1.119, FEEDGRAIN  1.142, OILGRAIN  1.790, POTATOES  0.561,
  SUGARBEET   0.420, SILAGE      1.004, GRASSPASTR 0.623, MILK      2.859, SLGHBEEF 25.375,
  SLGHPORK   13.766, SLGHPLTRY   7.435, SLGHSHEEP 25.770, EGG       8.314/;

PARAMETER RTBL20(SR,*)  Miscellaneous by production region;
RTBL20(SR,'GPV') = 
    SUM(PR $PRIMP(PR), SUM(R $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,PR) LT 0)),
                         -EAS(R,SR,AS,PR)*PRODSR.L(R,SR,AS)*
                            (-PRODUCTRE.M(R,PR) -PRODUCTRF.M(R,PR))))) +
    SUM(PS $PRIMP(PS), SUM(R $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,PS) LT 0)),
                         -EAS(R,SR,AS,PS)*PRODSR.L(R,SR,AS)*
                            (-PRODUCTSE.M(R,SR,PS) -PRODUCTSF.M(R,SR,PS)))));
RTBL20(SR,'NPV') = 
    SUM(PR $PRIMP(PR), SUM(R $RSR(R,SR), SUM(AS $RSRAS(R,SR,AS),
                         -EAS(R,SR,AS,PR)*PRODSR.L(R,SR,AS)*

                            (-PRODUCTRE.M(R,PR) -PRODUCTRF.M(R,PR))))) +
    SUM(PS $PRIMP(PS), SUM(R $RSR(R,SR), SUM(AS $RSRAS(R,SR,AS),
                         -EAS(R,SR,AS,PS)*PRODSR.L(R,SR,AS)*
                            (-PRODUCTSE.M(R,SR,PS) -PRODUCTSF.M(R,SR,PS)))));
RTBL20(SR,'GPVF') = 
    SUM(PRIMP, SUM(R $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,PRIMP) LT 0)),
                         -EAS(R,SR,AS,PRIMP)*PRODSR.L(R,SR,AS)*FIXPRIS(PRIMP))));
RTBL20(SR,'NPVF') = 
    SUM(PRIMP, SUM(R $RSR(R,SR), SUM(AS $RSRAS(R,SR,AS),
                         -EAS(R,SR,AS,PRIMP)*PRODSR.L(R,SR,AS)*FIXPRIS(PRIMP))));
RTBL20(SR,'LABOUR') =

  SUM(R $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS) $(EAS(R,SR,AS,'LABOR') GT 0)),
                         EAS(R,SR,AS,'LABOR')*PRODSR.L(R,SR,AS)));
RTBL20(SR,'LANDRENTC') =
  SUM(R $RSR(R,SR), RTBL7(R,SR,'CROPLAND','USE')*RTBL7(R,SR,'CROPLAND','PRICE')
                    + 0.5*RTBL7(R,SR,'ACRCOST','USE')*RTBL7(R,SR,'ACRCOST','PRICE')
                    + RTBL7(R,SR,'ACRECO','USE')*RTBL7(R,SR,'ACRECO','PRICE'));
RTBL20(SR,'LANDRENTP') =
    SUM(R $RSR(R,SR), RTBL7(R,SR,'PRMPAST','USE')*RTBL7(R,SR,'PRMPAST','PRICE')
                    + RTBL7(R,SR,'PRMPASTB','USE')*RTBL7(R,SR,'PRMPASTB','PRICE')
                    + RTBL7(R,SR,'PRMPASTT','USE')*RTBL7(R,SR,'PRMPASTT','PRICE')
                    + RTBL7(R,SR,'PRMPASTH','USE')*RTBL7(R,SR,'PRMPASTH','PRICE')
                    + RTBL7(R,SR,'PRMPASTN','USE')*RTBL7(R,SR,'PRMPASTN','PRICE')
                    + RTBL7(R,SR,'PRMPASTHB','USE')*RTBL7(R,SR,'PRMPASTHB','PRICE')
                    + RTBL7(R,SR,'PRMPASTHT','USE')*RTBL7(R,SR,'PRMPASTHT','PRICE')
                    + RTBL7(R,SR,'PRMPASTHN','USE')*RTBL7(R,SR,'PRMPASTHN','PRICE')
                    + RTBL7(R,SR,'PRMALV','USE')*RTBL7(R,SR,'PRMALV','PRICE')
                    + RTBL7(R,SR,'PRMFOR','USE')*RTBL7(R,SR,'PRMFOR','PRICE')
                    + RTBL7(R,SR,'PRMMOS','USE')*RTBL7(R,SR,'PRMMOS','PRICE')
                    + RTBL7(R,SR,'PRMLOW','USE')*RTBL7(R,SR,'PRMLOW','PRICE')
                    + RTBL7(R,SR,'PRMCHAL','USE')*RTBL7(R,SR,'PRMCHAL','PRICE')
                    + RTBL7(R,SR,'PRMMEAD','USE')*RTBL7(R,SR,'PRMMEAD','PRICE')
                    + 0.5*RTBL7(R,SR,'ACRCOSTP','USE')*RTBL7(R,SR,'ACRCOSTP','PRICE')
                    + 0.5*RTBL7(R,SR,'ACRCOSTPB','USE')*RTBL7(R,SR,'ACRCOSTPB','PRICE')
                    + 0.5*RTBL7(R,SR,'ACRCOSTPT','USE')*RTBL7(R,SR,'ACRCOSTPT','PRICE')
                    + 0.5*RTBL7(R,SR,'ACRCOSTPN','USE')*RTBL7(R,SR,'ACRCOSTPN','PRICE')
                    + 0.5*RTBL7(R,SR,'ACRCOSTPH','USE')*RTBL7(R,SR,'ACRCOSTPH','PRICE')
                    + 0.5*RTBL7(R,SR,'ACRCOSTPHB','USE')*RTBL7(R,SR,'ACRCOSTPHB','PRICE')
                    + 0.5*RTBL7(R,SR,'ACRCOSTPHT','USE')*RTBL7(R,SR,'ACRCOSTPHT','PRICE')
                    + 0.5*RTBL7(R,SR,'ACRCOSTPHN','USE')*RTBL7(R,SR,'ACRCOSTPHN','PRICE')
                    + 0.5*RTBL7(R,SR,'ACRCOSTALV','USE')*RTBL7(R,SR,'ACRCOSTALV','PRICE')
                    + 0.5*RTBL7(R,SR,'ACRCOSTFOR','USE')*RTBL7(R,SR,'ACRCOSTFOR','PRICE')
                    + 0.5*RTBL7(R,SR,'ACRCOSTMOS','USE')*RTBL7(R,SR,'ACRCOSTMOS','PRICE')
                    + 0.5*RTBL7(R,SR,'ACRCOSTLOW','USE')*RTBL7(R,SR,'ACRCOSTLOW','PRICE')
                    + 0.5*RTBL7(R,SR,'ACRCOSTCHA','USE')*RTBL7(R,SR,'ACRCOSTCHA','PRICE')                    
                    + 0.5*RTBL7(R,SR,'ACRCOSTMEA','USE')*RTBL7(R,SR,'ACRCOSTMEA','PRICE'));

RTBL20(SR,'PRODSURPL') = RTBL20(SR,'LANDRENTC') + RTBL20(SR,'LANDRENTP') 
   + SUM(R $RSR(R,SR), SUM(FIXIS, RTBL7(R,SR,FIXIS,'FIXED-SUP')*RTBL7(R,SR,FIXIS,'PRICE')))
   + SUM(R $RSR(R,SR), SUM(FIXIS2, RTBL7(R,SR,FIXIS2,'USE')*RTBL7(R,SR,FIXIS2,'PRICE')))/2
   + SUM(R $RSR(R,SR), SUM(AS $RSRAS(R,SR,AS),
                       +  EAS(R,SR,AS,'MEDCOW')*PRODSR.L(R,SR,AS)*RTBL8(R,'MEDCOW','PRICE')
                       +  EAS(R,SR,AS,'MEBEEFCATT')*PRODSR.L(R,SR,AS)*RTBL8(R,'MEBEEFCATT','PRICE')
                       +  EAS(R,SR,AS,'MESHEEP')*PRODSR.L(R,SR,AS)*RTBL8(R,'MESHEEP','PRICE')
                       +  EAS(R,SR,AS,'MECOPIG')*PRODSR.L(R,SR,AS)*RTBL8(R,'MECOPIG','PRICE')
                       +  EAS(R,SR,AS,'MEPOULTRY')*PRODSR.L(R,SR,AS)*RTBL8(R,'MEPOULTRY','PRICE'))); 

RTBL13E('LANDVCROP',SR)  = RTBL20(SR,'LANDRENTC')/SUM(R $RSR(R,SR), RTBL7(R,SR,'CROPLAND','USE'))*1000;

RTBL13E('LANDVPAST',SR)  = RTBL20(SR,'LANDRENTP')/SUM(R $RSR(R,SR), 
                              (RTBL7(R,SR,'PRMPAST','USE')+ RTBL7(R,SR,'PRMPASTB','USE')
                              +RTBL7(R,SR,'PRMPASTT','USE')+RTBL7(R,SR,'PRMPASTN','USE')
                              +RTBL7(R,SR,'PRMPASTH','USE')+RTBL7(R,SR,'PRMPASTHB','USE')
                              +RTBL7(R,SR,'PRMPASTHT','USE')+RTBL7(R,SR,'PRMPASTHN','USE')
                              +RTBL7(R,SR,'PRMALV','USE')+RTBL7(R,SR,'PRMFOR','USE')
                              +RTBL7(R,SR,'PRMMOS','USE')+RTBL7(R,SR,'PRMLOW','USE')
                              +RTBL7(R,SR,'PRMCHAL','USE')+RTBL7(R,SR,'PRMMEAD','USE')))*1000;
RTBL13E('PRODSURPL',SR)  = RTBL20(SR,'PRODSURPL');

RTBL13E('LANDVCROP','RIKET')= SUM(SR, RTBL20(SR,'LANDRENTC')) /
                                SUM(SR, SUM(R $RSR(R,SR), RTBL7(R,SR,'CROPLAND','USE')))*1000;
RTBL13E('LANDVPAST','RIKET')= SUM(SR, RTBL20(SR,'LANDRENTP')) / SUM(SR, SUM(R $RSR(R,SR),
                               RTBL7(R,SR,'PRMPAST','USE')+ RTBL7(R,SR,'PRMPASTB','USE')
                              +RTBL7(R,SR,'PRMPASTT','USE')+ RTBL7(R,SR,'PRMPASTN','USE')
                              +RTBL7(R,SR,'PRMPASTH','USE')+RTBL7(R,SR,'PRMPASTHB','USE')
                              +RTBL7(R,SR,'PRMPASTHT','USE')+RTBL7(R,SR,'PRMPASTHN','USE')
                              +RTBL7(R,SR,'PRMALV','USE')+RTBL7(R,SR,'PRMFOR','USE')
                              +RTBL7(R,SR,'PRMMOS','USE')+RTBL7(R,SR,'PRMLOW','USE')
                              +RTBL7(R,SR,'PRMCHAL','USE')+RTBL7(R,SR,'PRMMEAD','USE')))*1000;
RTBL13E('PRODSURPL','RIKET')= SUM(SR, RTBL13E('PRODSURPL',SR));


PARAMETER RTBL13E2(*,*)  Crop acreage and numbers of livestock by Output-region;
RTBL13E2('VALL',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('VALL',SR)); 
RTBL13E2('HOSTSAD',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('HOSTSAD',SR)); 
RTBL13E2('VARSAD',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('VARSAD',SR)); 
RTBL13E2('OLJEVAXT',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('OLJEVAXT',SR)); 
RTBL13E2('UTTAG',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('UTTAG',SR)); 
RTBL13E2('OVGRODOR',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('OVGRODOR',SR)); 
RTBL13E2('AKER',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('AKER',SR)); 
RTBL13E2('BETESMARK',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('BETESMARK',SR)); 
RTBL13E2('MJOLKKO',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('MJOLKKO',SR)); 
RTBL13E2('DIKO',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('DIKO',SR)); 
RTBL13E2('REKKVIGA1',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('REKKVIGA1',SR)); 
RTBL13E2('REKKVIGA2',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('REKKVIGA2',SR)); 
RTBL13E2('SLAKTKVIG1',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('SLAKTKVIG1',SR)); 
RTBL13E2('SLAKTKVIG2',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('SLAKTKVIG2',SR)); 
RTBL13E2('TJUR1',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('TJUR1',SR)); 
RTBL13E2('TJUR2',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('TJUR2',SR)); 
RTBL13E2('STUT1',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('STUT1',SR)); 
RTBL13E2('STUT2',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('STUT2',SR)); 
RTBL13E2('SUGGA',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('SUGGA',SR)); 
RTBL13E2('DIREKTBET',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('DIREKTBET',SR)); 
RTBL13E2('AE&DB',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('AE&DB',SR)); 
RTBL13E2('N-BOUGHT',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('N-BOUGHT',SR)); 
RTBL13E2('P-BOUGHT',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('P-BOUGHT',SR)); 
RTBL13E2('K-BOUGHT',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('K-BOUGHT',SR)); 
*RTBL13E2('LANDVCROP',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('LANDVCROP',SR)); 
*RTBL13E2('LANDVPAST',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('LANDVPAST',SR)); 
RTBL13E2('LANDVCROP',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL20(SR,'LANDRENTC')) / SUM(SR $UPRSR(UPR,SR),
                                 SUM(R $RSR(R,SR), RTBL7(R,SR,'CROPLAND','USE')))*1000; 
RTBL13E2('LANDVPAST',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL20(SR,'LANDRENTP')) / 
                              SUM(SR $UPRSR(UPR,SR), SUM(R $RSR(R,SR),
                               RTBL7(R,SR,'PRMPAST','USE')+ RTBL7(R,SR,'PRMPASTB','USE')
                              +RTBL7(R,SR,'PRMPASTT','USE')+RTBL7(R,SR,'PRMPASTN','USE')
                              +RTBL7(R,SR,'PRMPASTH','USE')+RTBL7(R,SR,'PRMPASTHB','USE')
                              +RTBL7(R,SR,'PRMPASTHT','USE')+RTBL7(R,SR,'PRMPASTHN','USE')
                              +RTBL7(R,SR,'PRMALV','USE')+RTBL7(R,SR,'PRMFOR','USE')
                              +RTBL7(R,SR,'PRMMOS','USE')+RTBL7(R,SR,'PRMLOW','USE')
                              +RTBL7(R,SR,'PRMCHAL','USE')+RTBL7(R,SR,'PRMMEAD','USE')))*1000; 
RTBL13E2('PRODSURPL',UPR) = SUM(SR $UPRSR(UPR,SR), RTBL13E('PRODSURPL',SR)); 
RTBL13E2('VALL','RIKET')= RTBL13E('VALL','RIKET');
RTBL13E2('HOSTSAD','RIKET')= RTBL13E('HOSTSAD','RIKET');
RTBL13E2('VARSAD','RIKET')= RTBL13E('VARSAD','RIKET');
RTBL13E2('OLJEVAXT','RIKET')= RTBL13E('OLJEVAXT','RIKET');
RTBL13E2('UTTAG','RIKET')= RTBL13E('UTTAG','RIKET');
RTBL13E2('OVGRODOR','RIKET')= RTBL13E('OVGRODOR','RIKET');
RTBL13E2('AKER','RIKET')= RTBL13E('AKER','RIKET');
RTBL13E2('BETESMARK','RIKET')= RTBL13E('BETESMARK','RIKET');
RTBL13E2('MJOLKKO','RIKET')= RTBL13E('MJOLKKO','RIKET');
RTBL13E2('DIKO','RIKET')= RTBL13E('DIKO','RIKET');
RTBL13E2('REKKVIGA1','RIKET')= RTBL13E('REKKVIGA1','RIKET');
RTBL13E2('REKKVIGA2','RIKET')= RTBL13E('REKKVIGA2','RIKET');
RTBL13E2('SLAKTKVIG1','RIKET')= RTBL13E('SLAKTKVIG1','RIKET');
RTBL13E2('SLAKTKVIG2','RIKET')= RTBL13E('SLAKTKVIG2','RIKET');
RTBL13E2('TJUR1','RIKET')= RTBL13E('TJUR1','RIKET');
RTBL13E2('TJUR2','RIKET')= RTBL13E('TJUR2','RIKET');
RTBL13E2('STUT1','RIKET')= RTBL13E('STUT1','RIKET');
RTBL13E2('STUT2','RIKET')= RTBL13E('STUT2','RIKET');
RTBL13E2('SUGGA','RIKET')= RTBL13E('SUGGA','RIKET');
RTBL13E2('DIREKTBET','RIKET')= RTBL13E('DIREKTBET','RIKET');
RTBL13E2('AE&DB','RIKET')= RTBL13E('AE&DB','RIKET');
RTBL13E2('N-BOUGHT','RIKET')= RTBL13E('N-BOUGHT','RIKET');
RTBL13E2('P-BOUGHT','RIKET')= RTBL13E('P-BOUGHT','RIKET');
RTBL13E2('K-BOUGHT','RIKET')= RTBL13E('K-BOUGHT','RIKET');
RTBL13E2('LANDVCROP','RIKET')= RTBL13E('LANDVCROP','RIKET');
RTBL13E2('LANDVPAST','RIKET')= RTBL13E('LANDVPAST','RIKET');
RTBL13E2('PRODSURPL','RIKET')= RTBL13E('PRODSURPL','RIKET');


PARAMETER RTBL21(SR,*)  Miscellaneous pasture data by production region;

RTBL21(SR,'LVSTCAP')  = SUM(R $RSR(R,SR), RTBL1(R,SR,'USEPASTR','PRODUCTION'));
RTBL21(SR,'LVSTUSED') = SUM(R $RSR(R,SR), RTBL1(R,SR,'USEPASTR','USE'));
RTBL21(SR,'PASTGRUSED') = SUM(R $RSR(R,SR), RTBL1(R,SR,'GRASSPASTR','USE'));
RTBL21(SR,'UNNESSFOR')= SUM(R $RSR(R,SR), RTBL1(R,SR,'GRASSPASTF','PRODUCTION')-RTBL1(R,SR,'GRASSPASTF','USE'));
RTBL21(SR,'LVSTTRPT') = RTBL13B(SR,'LVSTKIN')-RTBL13B(SR,'LVSTKOUT');
RTBL21(SR,'PRICEPAST')= SUM(R $RSR(R,SR), RTBL1(R,SR,'GRASSPASTR','PRICE')-RTBL1(R,SR,'USEPASTR','PRICE'));
RTBL21(SR,'PRICEPASTF')=SUM(R $RSR(R,SR), RTBL1(R,SR,'GRASSPASTR','PRICE')+RTBL1(R,SR,'GRASSPASTF','PRICE'));
RTBL21(SR,'PASTUSED') = SUM(R $RSR(R,SR), RTBL7(R,SR,'PRMPAST','USE')+RTBL7(R,SR,'PRMPASTT','USE')
       + RTBL7(R,SR,'PRMPASTN','USE')+RTBL7(R,SR,'PRMPASTH','USE')+RTBL7(R,SR,'PRMPASTHT','USE')
       + RTBL7(R,SR,'PRMPASTHN','USE')+RTBL7(R,SR,'PRMALV','USE')+RTBL7(R,SR,'PRMFOR','USE')
       + RTBL7(R,SR,'PRMMOS','USE')+RTBL7(R,SR,'PRMLOW','USE')+RTBL7(R,SR,'PRMCHAL','USE')
       + RTBL7(R,SR,'PRMMEAD','USE')-RTBL7(R,SR,'PRMPAST','PRODUCTION')-RTBL7(R,SR,'PRMPASTT','PRODUCTION')
       - RTBL7(R,SR,'PRMPASTN','PRODUCTION')-RTBL7(R,SR,'PRMPASTH','PRODUCTION')-RTBL7(R,SR,'PRMPASTHT','PRODUCTION')
       - RTBL7(R,SR,'PRMPASTHN','PRODUCTION')-RTBL7(R,SR,'PRMALV','PRODUCTION')-RTBL7(R,SR,'PRMFOR','PRODUCTION')
       - RTBL7(R,SR,'PRMMOS','PRODUCTION')-RTBL7(R,SR,'PRMLOW','PRODUCTION')-RTBL7(R,SR,'PRMCHAL','PRODUCTION')
       - RTBL7(R,SR,'PRMMEAD','PRODUCTION'));
RTBL21(SR,'PASTAVAIL')= SUM(R $RSR(R,SR), RTBL7(R,SR,'PRMPAST','FIXED-SUP')+RTBL7(R,SR,'PRMPASTT','FIXED-SUP')
       + RTBL7(R,SR,'PRMPASTN','FIXED-SUP')+RTBL7(R,SR,'PRMPASTH','FIXED-SUP')+RTBL7(R,SR,'PRMPASTHT','FIXED-SUP')
       + RTBL7(R,SR,'PRMPASTHN','FIXED-SUP')+RTBL7(R,SR,'PRMALV','FIXED-SUP')+RTBL7(R,SR,'PRMFOR','FIXED-SUP')
       + RTBL7(R,SR,'PRMMOS','FIXED-SUP')+RTBL7(R,SR,'PRMLOW','FIXED-SUP')+RTBL7(R,SR,'PRMCHAL','FIXED-SUP')
       + RTBL7(R,SR,'PRMMEAD','FIXED-SUP'));
RTBL21(SR,'PASTPOT')  = RTBL21(SR,'PASTAVAIL') - RTBL21(SR,'PASTUSED');       

PARAMETER RTBL0(*,*)  Calculated surpluses;


*RTBL0(R,'PRODSUR') = SUM(PR $PRED(R,PR), (PRODUCTRE.M(R,PR)*(-DEMANDPR.L(R,PR))))
*         + SUM(SR $RSR(R,SR), SUM(PS $PSED(R,SR,PS), (PRODUCTSE.M(R,SR,PS)*(-DEMANDPS.L(R,SR,PS)))))
*         - SUM(IR $IRES(R,IR), (BIR(R,IR,'INTERCEPT')*SUPPLYIR.L(R,IR))+(0.5*BIR(R,IR,'SLOPE')
*                               *(SUPPLYIR.L(R,IR)**2)))
*         - SUM(SR $RSR(R,SR), SUM(IS $ISES(R,SR,IS), (BIS(R,SR,IS,'INTERCEPT')*SUPPLYIS.L(R,SR,IS))
*                                  +(0.5*BIS(R,SR,IS,'SLOPE')*(SUPPLYIS.L(R,SR,IS)**2))));
RTBL0(R,'PRODSUR') =
          SUM(PR $PRED(R,PR), (-PRODUCTRE.M(R,PR) *
                                           (RTBL2(R,PR,'PRODUCTION')- RTBL2(R,PR,'USE'))))
         + SUM(PR $PRFD(R,PR), (-PRODUCTRF.M(R,PR) *
                                           (RTBL2(R,PR,'PRODUCTION')- RTBL2(R,PR,'USE'))))
         + SUM(SR $RSR(R,SR), SUM(PS $PSED(R,SR,PS), (-PRODUCTSE.M(R,SR,PS) *
                                           (RTBL1(R,SR,PS,'PRODUCTION')- RTBL1(R,SR,PS,'USE')))))
         + SUM(PN $PNED(PN), -PRODUCTNE.M(PN) * (SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS)),
                               - EAS(R,SR,AS,PN)*PRODSR.L(R,SR,AS)))
                               + SUM(CR $(RCR(R,CR)), -ECR(R,CR,PN)*PROCR.L(R,CR))))       
         - SUM(IR $IRES(R,IR), (BIR(R,IR,'INTERCEPT')*SUPPLYIR.L(R,IR))+(0.5*BIR(R,IR,'SLOPE')
                               *(SUPPLYIR.L(R,IR)**2)))
         - SUM(SR $RSR(R,SR), SUM(IS $ISES(R,SR,IS), (BIS(R,SR,IS,'INTERCEPT')*SUPPLYIS.L(R,SR,IS))
                                  +(0.5*BIS(R,SR,IS,'SLOPE')*(SUPPLYIS.L(R,SR,IS)**2))))
         - SUM(IN $INES(IN), (BIN(IN,'INTERCEPT') * (SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS)),
                               + EAS(R,SR,AS,IN)*PRODSR.L(R,SR,AS)))
                               + SUM(CR $(RCR(R,CR)), +ECR(R,CR,IN)*PROCR.L(R,CR)))));
RTBL0(R,'PSURI') =
          SUM(PR $PRED(R,PR), (-PRODUCTRE.M(R,PR) *
                                           (RTBL2(R,PR,'PRODUCTION')- RTBL2(R,PR,'USE'))))
         + SUM(PR $PRFD(R,PR),(-PRODUCTRF.M(R,PR) *
                                           (RTBL2(R,PR,'PRODUCTION')- RTBL2(R,PR,'USE')))) 
         + SUM(SR $RSR(R,SR), SUM(PS $PSED(R,SR,PS), (-PRODUCTSE.M(R,SR,PS) *
                                           (RTBL1(R,SR,PS,'PRODUCTION')- RTBL1(R,SR,PS,'USE')))))
         + SUM(PN $PNED(PN), -PRODUCTNE.M(PN) * (SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS)),
                               - EAS(R,SR,AS,PN)*PRODSR.L(R,SR,AS)))
         + SUM(CR $(RCR(R,CR)), -ECR(R,CR,PN)*PROCR.L(R,CR))));
RTBL0(R,'PSURIN') =
         + SUM(PN $PNED(PN), -PRODUCTNE.M(PN) * (SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS)),
                               -EAS(R,SR,AS,PN)*PRODSR.L(R,SR,AS)))
         + SUM(CR $(RCR(R,CR)), -ECR(R,CR,PN)*PROCR.L(R,CR))));         
RTBL0(R,'PSURIR') =
          SUM(PR $PRED(R,PR),(-PRODUCTRE.M(R,PR) *
                (RTBL2(R,PR,'PRODUCTION')- RTBL2(R,PR,'USE'))))
         +SUM(PR $PRFD(R,PR),(-PRODUCTRF.M(R,PR) *
                (RTBL2(R,PR,'PRODUCTION')- RTBL2(R,PR,'USE')))); 
RTBL0(R,'PSURIS') =
         + SUM(SR $RSR(R,SR), SUM(PS $PSED(R,SR,PS), (-PRODUCTSE.M(R,SR,PS) *
                                           (RTBL1(R,SR,PS,'PRODUCTION')- RTBL1(R,SR,PS,'USE')))));
RTBL0(R,'PSURC') =
         - SUM(IR $IRES(R,IR), (BIR(R,IR,'INTERCEPT')*SUPPLYIR.L(R,IR))+(0.5*BIR(R,IR,'SLOPE')
                               *(SUPPLYIR.L(R,IR)**2)))
         - SUM(SR $RSR(R,SR), SUM(IS $ISES(R,SR,IS), (BIS(R,SR,IS,'INTERCEPT')*SUPPLYIS.L(R,SR,IS))
                                  +(0.5*BIS(R,SR,IS,'SLOPE')*(SUPPLYIS.L(R,SR,IS)**2))))
         - SUM(IN $INES(IN), INPUTNE.M(IN) * (SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS)),
                               + EAS(R,SR,AS,IN)*PRODSR.L(R,SR,AS)))
                               + SUM(CR $(RCR(R,CR)), +ECR(R,CR,IN)*PROCR.L(R,CR))));
RTBL0(R,'PSURCN') = SUM(IN $INES(IN), INPUTNE.M(IN) * (SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS)),
                               - EAS(R,SR,AS,IN)*PRODSR.L(R,SR,AS)))
                               + SUM(CR $(RCR(R,CR)), -ECR(R,CR,IN)*PROCR.L(R,CR)))); 
RTBL0(R,'PSURCN1') = SUM(IN $INES(IN), INPUTNE.M(IN) * SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS)),
                               - EAS(R,SR,AS,IN)*PRODSR.L(R,SR,AS))));
RTBL0(R,'PSURCN2') = SUM(IN $INES(IN), INPUTNE.M(IN) * 
                               SUM(CR $(RCR(R,CR)), -ECR(R,CR,IN)*PROCR.L(R,CR))); 
RTBL0(R,'PSURCR') =
         - SUM(IR $IRES(R,IR), (BIR(R,IR,'INTERCEPT')*SUPPLYIR.L(R,IR))+(0.5*BIR(R,IR,'SLOPE')
                               *(SUPPLYIR.L(R,IR)**2)));
RTBL0(R,'PSURCS') =
         - SUM(SR $RSR(R,SR), SUM(IS $ISES(R,SR,IS), (BIS(R,SR,IS,'INTERCEPT')*SUPPLYIS.L(R,SR,IS))
                                  +(0.5*BIS(R,SR,IS,'SLOPE')*(SUPPLYIS.L(R,SR,IS)**2))));


RTBL0(R,'CONSSUR') =  + SUM(PR $PRED(R,PR), (BPR(R,PR,'INTERCEPT')*DEMANDPR.L(R,PR))+(0.5*BPR(R,PR,'SLOPE')
                              *(DEMANDPR.L(R,PR)**2))-(PRODUCTRE.M(R,PR)*(-DEMANDPR.L(R,PR))))
    + SUM(SR $RSR(R,SR), SUM(PS $PSED(R,SR,PS), (BPS(R,SR,PS,'INTERCEPT')*DEMANDPS.L(R,SR,PS))
       +(0.5*BPS(R,SR,PS,'SLOPE')*(DEMANDPS.L(R,SR,PS)**2))-(PRODUCTSE.M(R,SR,PS)*(-DEMANDPS.L(R,SR,PS)))));

RTBL0(R,'VALFIXSUP') =  + SUM(IR $IRFS(R,IR), -(INPUTRF.M(R,IR)*BIR(R,IR,'MAX')))
           + SUM(SR $RSR(R,SR), SUM(IS $ISFS(R,SR,IS), -(INPUTSF.M(R,SR,IS)*BIS(R,SR,IS,'MAX'))))
           + SUM(IN $INFS(IN), -INPUTNF.M(IN) * (SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS)),
                          - EAS(R,SR,AS,IN)*PRODSR.L(R,SR,AS)))
                          + SUM(CR $(RCR(R,CR)), -ECR(R,CR,IN)*PROCR.L(R,CR))));
RTBL0(R,'VALFIXSUPS') =  
           + SUM(SR $RSR(R,SR), SUM(IS $ISFS(R,SR,IS), -(INPUTSF.M(R,SR,IS)*BIS(R,SR,IS,'MAX'))));
RTBL0(R,'VALFIXSUPR') =  + SUM(IR $IRFS(R,IR), -(INPUTRF.M(R,IR)*BIR(R,IR,'MAX')));
           
RTBL0(R,'VALFIXSUPN') =  SUM(IN $INFS(IN), -INPUTNF.M(IN) * (SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS)),
                          - EAS(R,SR,AS,IN)*PRODSR.L(R,SR,AS)))
                          + SUM(CR $(RCR(R,CR)), -ECR(R,CR,IN)*PROCR.L(R,CR))));

RTBL0(R,'COSTFIXDEM') =  + SUM(PR $PRFD(R,PR), -(PRODUCTRF.M(R,PR)*(PRODUCTRF.LO(R,PR))))
           + SUM(SR $RSR(R,SR), SUM(PS $PSFD(R,SR,PS), -(PRODUCTSF.M(R,SR,PS)*(PRODUCTSF.LO(R,SR,PS)))))
           + SUM(PN, -PRODUCTNF.M(PN) * (SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS)),
                          - EAS(R,SR,AS,PN)*PRODSR.L(R,SR,AS)))
                          + SUM(CR $(RCR(R,CR)), -ECR(R,CR,PN)*PROCR.L(R,CR))));
RTBL0(R,'CFIXDEMS') =  
           + SUM(SR $RSR(R,SR), SUM(PS $PSFD(R,SR,PS), -(PRODUCTSF.M(R,SR,PS)*(PRODUCTSF.LO(R,SR,PS)))));
RTBL0(R,'CFIXDEMR') =  SUM(PR $PRFD(R,PR), -(PRODUCTRF.M(R,PR)*(PRODUCTRF.LO(R,PR))));
RTBL0(R,'CFIXDEMN') =  SUM(PN, -PRODUCTNF.M(PN) * (SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS)),
                          - EAS(R,SR,AS,PN)*PRODSR.L(R,SR,AS)))
                          + SUM(CR $(RCR(R,CR)), -ECR(R,CR,PN)*PROCR.L(R,CR))));
RTBL0(RD,'TRANCOST') = SUM(RS, SUM(IP $TIP(RS,RD,IP), CT(RS,RD,IP)*TRANIP.L(RS,RD,IP)));
RTBL0(RD,'TRANCOSTP') = SUM(RS, SUM(PR $TIP(RS,RD,PR), CT(RS,RD,PR)*TRANIP.L(RS,RD,PR)));
rTBL0(RD,'TRANCOSTI') = SUM(RS, SUM(IR $TIP(RS,RD,IR), CT(RS,RD,IR)*TRANIP.L(RS,RD,IR)));

RTBL0(R,'EXPREV1') = SUM(PREX $RPREX(R,PREX), BXR(R,PREX,'ADJPRICE')*EXPORTRP.L(R,PREX));
RTBL0(R,'EXPREV2') = SUM(PREX $RPREX(R,PREX), -(PRODUCTRE.M(R,PREX)+PRODUCTRF.M(R,PREX))*EXPORTRP.L(R,PREX));
RTBL0(R,'EXPREV3') =  RTBL0(R,'EXPREV2') - RTBL0(R,'EXPREV1');
RTBL0(R,'IMPCOST1') =  SUM(PRIM $RPRIM(R,PRIM), BMR(R,PRIM,'ADJPRICE')*IMPORTPR.L(R,PRIM));
RTBL0(R,'IMPCOST2') =  SUM(PRIM $RPRIM(R,PRIM), -(PRODUCTRE.M(R,PRIM)+PRODUCTRF.M(R,PRIM))*IMPORTPR.L(R,PRIM));
RTBL0(R,'IMPCOST3') =  RTBL0(R,'IMPCOST2') - RTBL0(R,'IMPCOST1');

RTBL0(R,'OBJECTIV') =  RTBL0(R,'CONSSUR') + RTBL0(R,'PRODSUR'); 
RTBL0(R,'OBJ') = 
  - SUM(IR $IRES(R,IR), (BIR(R,IR,'INTERCEPT')*SUPPLYIR.L(R,IR))+(0.5*BIR(R,IR,'SLOPE')
                               *(SUPPLYIR.L(R,IR)**2)))
         - SUM(SR $RSR(R,SR), SUM(IS $ISES(R,SR,IS), (BIS(R,SR,IS,'INTERCEPT')*SUPPLYIS.L(R,SR,IS))
                                  +(0.5*BIS(R,SR,IS,'SLOPE')*(SUPPLYIS.L(R,SR,IS)**2))))
  + SUM(PR $PRED(R,PR), (BPR(R,PR,'INTERCEPT')*DEMANDPR.L(R,PR))+(0.5*BPR(R,PR,'SLOPE')
                              *(DEMANDPR.L(R,PR)**2)))
+ SUM(SR $RSR(R,SR), SUM(PS $PSED(R,SR,PS), (BPS(R,SR,PS,'INTERCEPT')*DEMANDPS.L(R,SR,PS))
                                  +(0.5*BPS(R,SR,PS,'SLOPE')*(DEMANDPS.L(R,SR,PS)**2))))
  - SUM(RS, SUM(IP $TIP(RS,R,IP), CT(RS,R,IP)*TRANIP.L(RS,R,IP)))
  + SUM(IN $INES(IN), INPUTNE.M(IN) * (SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS)),
                               - EAS(R,SR,AS,IN)*PRODSR.L(R,SR,AS)))
                               + SUM(CR $(RCR(R,CR)), -ECR(R,CR,IN)*PROCR.L(R,CR))))
  + SUM(PN $PNED(PN), -PRODUCTNE.M(PN) * (SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS)),
                               -EAS(R,SR,AS,PN)*PRODSR.L(R,SR,AS)))
         + SUM(CR $(RCR(R,CR)), -ECR(R,CR,PN)*PROCR.L(R,CR))))
  + SUM(PREX $RPREX(R,PREX), BXR(R,PREX,'ADJPRICE')*EXPORTRP.L(R,PREX))
  - SUM(PRIM $RPRIM(R,PRIM), BMR(R,PRIM,'ADJPRICE')*IMPORTPR.L(R,PRIM));

RTBL0(R,'OBJC') = 
  - SUM(IR $IRES(R,IR), (BIR(R,IR,'INTERCEPT')*SUPPLYIR.L(R,IR))+(0.5*BIR(R,IR,'SLOPE')
                               *(SUPPLYIR.L(R,IR)**2)))
         - SUM(SR $RSR(R,SR), SUM(IS $ISES(R,SR,IS), (BIS(R,SR,IS,'INTERCEPT')*SUPPLYIS.L(R,SR,IS))
                                  +(0.5*BIS(R,SR,IS,'SLOPE')*(SUPPLYIS.L(R,SR,IS)**2))));
RTBL0(R,'OBJI') = 
  + SUM(PR $PRED(R,PR), (BPR(R,PR,'INTERCEPT')*DEMANDPR.L(R,PR))+(0.5*BPR(R,PR,'SLOPE')
                              *(DEMANDPR.L(R,PR)**2)))
+ SUM(SR $RSR(R,SR), SUM(PS $PSED(R,SR,PS), (BPS(R,SR,PS,'INTERCEPT')*DEMANDPS.L(R,SR,PS))
                                  +(0.5*BPS(R,SR,PS,'SLOPE')*(DEMANDPS.L(R,SR,PS)**2))));


RTBL0(R,'OBJ1') = - SUM(RS, SUM(IP $TIP(RS,R,IP), CT(RS,R,IP)*TRANIP.L(RS,R,IP)));
RTBL0(R,'OBJ2') = + SUM(IN $INES(IN), INPUTNE.M(IN) * (SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS)),
                               - EAS(R,SR,AS,IN)*PRODSR.L(R,SR,AS)))
                               + SUM(CR $(RCR(R,CR)), -ECR(R,CR,IN)*PROCR.L(R,CR))));
RTBL0(R,'OBJ3') = + SUM(PN $PNED(PN), -PRODUCTNE.M(PN) * (SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS)),
                               -EAS(R,SR,AS,PN)*PRODSR.L(R,SR,AS)))
         + SUM(CR $(RCR(R,CR)), -ECR(R,CR,PN)*PROCR.L(R,CR))));
RTBL0(R,'OBJEXP') =  + SUM(PREX $RPREX(R,PREX), BXR(R,PREX,'ADJPRICE')*EXPORTRP.L(R,PREX));
RTBL0(R,'OBJIMP') =  - SUM(PRIM $RPRIM(R,PRIM), BMR(R,PRIM,'ADJPRICE')*IMPORTPR.L(R,PRIM));
RTBL0(R,'OBJTROUT') = - SUM(RD, SUM(PR $TIP(R,RD,PR), PRODUCTRE.M(R,PR)*TRANIP.L(R,RD,PR)));
RTBL0(R,'OBJTRIN') =  + SUM(RS, SUM(PR $TIP(RS,R,PR), PRODUCTRE.M(R,PR)*TRANIP.L(RS,R,PR)));

RTBL0('SWEDEN','PRODSUR') =  SUM(R, RTBL0(R,'PRODSUR'));
RTBL0('SWEDEN','PSURI') =  SUM(R, RTBL0(R,'PSURI'));
RTBL0('SWEDEN','PSURIN') =  SUM(R, RTBL0(R,'PSURIN'));                           
RTBL0('SWEDEN','PSURIR') =  SUM(R, RTBL0(R,'PSURIR'));
RTBL0('SWEDEN','PSURIS') =  SUM(R, RTBL0(R,'PSURIS'));
RTBL0('SWEDEN','PSURC') =  SUM(R, RTBL0(R,'PSURC'));
RTBL0('SWEDEN','PSURCN') =  SUM(R, RTBL0(R,'PSURCN'));
RTBL0('SWEDEN','PSURCN1') =  SUM(R, RTBL0(R,'PSURCN1'));
RTBL0('SWEDEN','PSURCN2') =  SUM(R, RTBL0(R,'PSURCN2'));
RTBL0('SWEDEN','PSURCR') =  SUM(R, RTBL0(R,'PSURCR'));
RTBL0('SWEDEN','PSURCS') =  SUM(R, RTBL0(R,'PSURCS'));
RTBL0('SWEDEN','CONSSUR') =  SUM(R, RTBL0(R,'CONSSUR'));
RTBL0('SWEDEN','VALFIXSUP') =  SUM(R, RTBL0(R,'VALFIXSUP'));
RTBL0('SWEDEN','VALFIXSUPS') =  SUM(R, RTBL0(R,'VALFIXSUPS'));
RTBL0('SWEDEN','VALFIXSUPR') =  SUM(R, RTBL0(R,'VALFIXSUPR'));
RTBL0('SWEDEN','VALFIXSUPN') =  SUM(R, RTBL0(R,'VALFIXSUPN'));
RTBL0('SWEDEN','COSTFIXDEM') =  SUM(R, RTBL0(R,'COSTFIXDEM'));
RTBL0('SWEDEN','CFIXDEMS') =  SUM(R, RTBL0(R,'CFIXDEMS'));
RTBL0('SWEDEN','CFIXDEMR') =  SUM(R, RTBL0(R,'CFIXDEMR'));
RTBL0('SWEDEN','CFIXDEMN') =  SUM(R, RTBL0(R,'CFIXDEMN'));
RTBL0('SWEDEN','TRANCOST') =  SUM(R, RTBL0(R,'TRANCOST'));
RTBL0('SWEDEN','EXPREV1') =  SUM(R, RTBL0(R,'EXPREV1'));
RTBL0('SWEDEN','EXPREV2') =  SUM(R, RTBL0(R,'EXPREV2'));
RTBL0('SWEDEN','EXPREV3') =  SUM(R, RTBL0(R,'EXPREV3'));
RTBL0('SWEDEN','IMPCOST1') =  SUM(R, RTBL0(R,'IMPCOST1'));
RTBL0('SWEDEN','IMPCOST2') =  SUM(R, RTBL0(R,'IMPCOST2'));
RTBL0('SWEDEN','IMPCOST3') =  SUM(R, RTBL0(R,'IMPCOST3'));
RTBL0('SWEDEN','OBJECTIV') =  SUM(R, RTBL0(R,'OBJECTIV'));
RTBL0('SWEDEN','OBJ') =  SUM(R, RTBL0(R,'OBJ'));
RTBL0('SWEDEN','OBJC') =  SUM(R, RTBL0(R,'OBJC'));
RTBL0('SWEDEN','OBJI') =  SUM(R, RTBL0(R,'OBJI'));
RTBL0('SWEDEN','OBJ1') =  SUM(R, RTBL0(R,'OBJ1'));
RTBL0('SWEDEN','OBJ2') =  SUM(R, RTBL0(R,'OBJ2'));
RTBL0('SWEDEN','OBJ3') =  SUM(R, RTBL0(R,'OBJ3'));
RTBL0('SWEDEN','OBJEXP') =  SUM(R, RTBL0(R,'OBJEXP'));
RTBL0('SWEDEN','OBJIMP') =  SUM(R, RTBL0(R,'OBJIMP'));
RTBL0('SWEDEN','OBJTROUT') =  SUM(R, RTBL0(R,'OBJTROUT'));
RTBL0('SWEDEN','OBJTRIN') =  SUM(R, RTBL0(R,'OBJTRIN'));



PARAMETER RTBL0B(*,*)  Calculated aggragated surpluses;

RTBL0B(R,'PRODSURP') = RTBL0(R,'PRODSUR') + RTBL0(R,'COSTFIXDEM');
RTBL0B(R,'CONSSURP') = RTBL0(R,'CONSSUR') - RTBL0(R,'COSTFIXDEM');
RTBL0B(R,'TAXPAYER') = SUM(SR $RSR(R,SR), RTBL13E('DIREKTBET',SR));
RTBL0B(R,'WELFARE')  = RTBL0B(R,'PRODSURP') + RTBL0B(R,'CONSSURP')-RTBL0B(R,'TAXPAYER');
RTBL0B(R,'OBJFCN')   = RTBL0B(R,'PRODSURP') + RTBL0B(R,'CONSSURP');

RTBL0B('SWEDEN','PRODSURP') =  SUM(R, RTBL0B(R,'PRODSURP'));
RTBL0B('SWEDEN','CONSSURP') =  SUM(R, RTBL0B(R,'CONSSURP'));
RTBL0B('SWEDEN','TAXPAYER') =  SUM(R, RTBL0B(R,'TAXPAYER'));
RTBL0B('SWEDEN','WELFARE') =  SUM(R, RTBL0B(R,'WELFARE'));
RTBL0B('SWEDEN','OBJFCN') =  SUM(R, RTBL0B(R,'OBJFCN'));
RTBL0B('SWEDEN','DIFFOBJF') = RTBL0B('SWEDEN','OBJFCN') - Z.L;

PARAMETER RTBL0C(*,*) Value of national fixed inputs;
RTBL0C(INFS,R) = - SUM(SR $RSR(R,SR), SUM(AS $(RSRAS(R,SR,AS)),
                          - EAS(R,SR,AS,INFS)*PRODSR.L(R,SR,AS))
                          + SUM(CR $(RCR(R,CR)), -ECR(R,CR,INFS)*PROCR.L(R,CR)) * INPUTNF.M(INFS));


PARAMETER RTBL0A(*)  Calculated surpluses;

RTBL0A('PRODSUR') = 0;
RTBL0A('PRODSUR') = - SUM(R,
 -SUM(PR $PRED(R,PR), (PRODUCTRE.M(R,PR)*(-DEMANDPR.L(R,PR))))
         - SUM(SR $RSR(R,SR), SUM(PS $PSED(R,SR,PS), (PRODUCTSE.M(R,SR,PS)*(-DEMANDPS.L(R,SR,PS)))))  
         + SUM(IR $IRES(R,IR), (BIR(R,IR,'INTERCEPT')*SUPPLYIR.L(R,IR))+(0.5*BIR(R,IR,'SLOPE')
                               *(SUPPLYIR.L(R,IR)**2)))
         + SUM(SR $RSR(R,SR), SUM(IS $ISES(R,SR,IS), (BIS(R,SR,IS,'INTERCEPT')*SUPPLYIS.L(R,SR,IS))
                                  +(0.5*BIS(R,SR,IS,'SLOPE')*(SUPPLYIS.L(R,SR,IS)**2)))));
RTBL0A('PRODSUR1') = 0;
RTBL0A('PRODSUR1') = - SUM(R,  
         + SUM(IR $IRES(R,IR), (BIR(R,IR,'INTERCEPT')*SUPPLYIR.L(R,IR))+(0.5*BIR(R,IR,'SLOPE')
                               *(SUPPLYIR.L(R,IR)**2)))
         + SUM(SR $RSR(R,SR), SUM(IS $ISES(R,SR,IS), (BIS(R,SR,IS,'INTERCEPT')*SUPPLYIS.L(R,SR,IS))
                                  +(0.5*BIS(R,SR,IS,'SLOPE')*(SUPPLYIS.L(R,SR,IS)**2)))));
RTBL0A('OBJ1P') = 0;
RTBL0A('OBJ1P') = 
  - SUM(R, SUM(IR $IRES(R,IR), (BIR(R,IR,'INTERCEPT')*SUPPLYIR.L(R,IR))+(0.5*BIR(R,IR,'SLOPE')
                               *(SUPPLYIR.L(R,IR)**2)))
         + SUM(SR $RSR(R,SR), SUM(IS $ISES(R,SR,IS), (BIS(R,SR,IS,'INTERCEPT')*SUPPLYIS.L(R,SR,IS))
                                  +(0.5*BIS(R,SR,IS,'SLOPE')*(SUPPLYIS.L(R,SR,IS)**2)))));

RTBL0A('PRODSUR2') = 0;
RTBL0A('PRODSUR2') = SUM(R, SUM(PR $PRED(R,PR), (PRODUCTRE.M(R,PR)*(-DEMANDPR.L(R,PR))))
         + SUM(SR $RSR(R,SR), SUM(PS $PSED(R,SR,PS), (PRODUCTSE.M(R,SR,PS)*(-DEMANDPS.L(R,SR,PS))))));                                  
RTBL0A('PRODSUR2S') = SUM(R, 
         + SUM(SR $RSR(R,SR), SUM(PS $PSED(R,SR,PS), (PRODUCTSE.M(R,SR,PS)*(-DEMANDPS.L(R,SR,PS))))));
RTBL0A('PRODSUR2R') = SUM(R, SUM(PR $PRED(R,PR), (PRODUCTRE.M(R,PR)*(-DEMANDPR.L(R,PR)))));
*RTBL0A('PRODSUR2R') = SUM(R, (PRODUCTRE.M(R,'BEEF')*(-DEMANDPR.L(R,'BEEF'))));
*RTBL0A('PRODSUR2R') = (PRODUCTRE.M('R6','BREADGRAIN')*(-DEMANDPR.L('R6','BREADGRAIN')));

RTBL0A('CONSSUR') = 0;
RTBL0A('CONSSUR') =  + SUM(R, SUM(PR $PRED(R,PR), (BPR(R,PR,'INTERCEPT')*DEMANDPR.L(R,PR))+(0.5*BPR(R,PR,'SLOPE')
                              *(DEMANDPR.L(R,PR)**2))-(PRODUCTRE.M(R,PR)*(-DEMANDPR.L(R,PR))))
+ SUM(SR $RSR(R,SR), SUM(PS $PSED(R,SR,PS), (BPS(R,SR,PS,'INTERCEPT')*DEMANDPS.L(R,SR,PS))
       +(0.5*BPS(R,SR,PS,'SLOPE')*(DEMANDPS.L(R,SR,PS)**2))-(PRODUCTSE.M(R,SR,PS)*(-DEMANDPS.L(R,SR,PS))))));
RTBL0A('CONSSUR1') = 0;
RTBL0A('CONSSUR1') =  + SUM(R, SUM(PR $PRED(R,PR), (BPR(R,PR,'INTERCEPT')*DEMANDPR.L(R,PR))+(0.5*BPR(R,PR,'SLOPE')
                              *(DEMANDPR.L(R,PR)**2)))
+ SUM(SR $RSR(R,SR), SUM(PS $PSED(R,SR,PS), (BPS(R,SR,PS,'INTERCEPT')*DEMANDPS.L(R,SR,PS))
       +(0.5*BPS(R,SR,PS,'SLOPE')*(DEMANDPS.L(R,SR,PS)**2)))));
RTBL0A('CONSSUR2') = 0;
RTBL0A('CONSSUR2') =  + SUM(R, SUM(PR $PRED(R,PR), -(PRODUCTRE.M(R,PR)*(-DEMANDPR.L(R,PR))))
+ SUM(SR $RSR(R,SR), SUM(PS $PSED(R,SR,PS), -(PRODUCTSE.M(R,SR,PS)*(-DEMANDPS.L(R,SR,PS))))));

RTBL0A('TRANCOST') = 0;
RTBL0A('TRANCOST') = SUM(RD, SUM(RS, SUM(IP $TIP(RS,RD,IP), CT(RS,RD,IP)*TRANIP.L(RS,RD,IP))));

RTBL0A('EXPREV') = 0;
RTBL0A('EXPREV') = SUM(R, SUM(PREX $RPREX(R,PREX), BXR(R,PREX,'ADJPRICE')*EXPORTRP.L(R,PREX)));

RTBL0A('IMPCOST') = 0;
RTBL0A('IMPCOST') =  SUM(R, SUM(PRIM $RPRIM(R,PRIM), BMR(R,PRIM,'ADJPRICE')*IMPORTPR.L(R,PRIM)));

RTBL0A('PRODSURN') = 0;
RTBL0A('PRODSURN') = SUM(PN $PNED(PN), PRODUCTNE.M(PN)*(-DEMANDPN.L(PN)))
                - SUM(IN $INES(IN), (BIN(IN,'INTERCEPT')*SUPPLYIN.L(IN))+(0.5*BIN(IN,'SLOPE')*(SUPPLYIN.L(IN)**2)));
RTBL0A('CONSSURN') = 0;
RTBL0A('CONSSURN') =  + SUM(PN $PNED(PN), (BPN(PN,'INTERCEPT')*DEMANDPN.L(PN))
                          +(0.5*BPN(PN,'SLOPE')*(DEMANDPN.L(PN)**2)) -(PRODUCTNE.M(PN)*(-DEMANDPN.L(PN))));
RTBL0A('CSURN') = 0;
RTBL0A('CSURN') =  + SUM(PN $PNED(PN), (BPN(PN,'INTERCEPT')*DEMANDPN.L(PN))
                          +(0.5*BPN(PN,'SLOPE')*(DEMANDPN.L(PN)**2)));
RTBL0A('PSURN') = 0;
RTBL0A('PSURN') = SUM(PN $PNED(PN), PRODUCTNE.M(PN)*(-DEMANDPN.L(PN)));
RTBL0A('PSURCOSTN') = 0;
RTBL0A('PSURCOSTN') = - SUM(IN $INES(IN), (BIN(IN,'INTERCEPT')*SUPPLYIN.L(IN))
                             +(0.5*BIN(IN,'SLOPE')*(SUPPLYIN.L(IN)**2)));
RTBL0A('OBJ') = 0;
RTBL0A('OBJ') = 
  - SUM(R, SUM(IR $IRES(R,IR), (BIR(R,IR,'INTERCEPT')*SUPPLYIR.L(R,IR))+(0.5*BIR(R,IR,'SLOPE')
                               *(SUPPLYIR.L(R,IR)**2)))
         + SUM(SR $RSR(R,SR), SUM(IS $ISES(R,SR,IS), (BIS(R,SR,IS,'INTERCEPT')*SUPPLYIS.L(R,SR,IS))
                                  +(0.5*BIS(R,SR,IS,'SLOPE')*(SUPPLYIS.L(R,SR,IS)**2)))))
  + SUM(R, SUM(PR $PRED(R,PR), (BPR(R,PR,'INTERCEPT')*DEMANDPR.L(R,PR))+(0.5*BPR(R,PR,'SLOPE')
                              *(DEMANDPR.L(R,PR)**2)))
+ SUM(SR $RSR(R,SR), SUM(PS $PSED(R,SR,PS), (BPS(R,SR,PS,'INTERCEPT')*DEMANDPS.L(R,SR,PS))
                                  +(0.5*BPS(R,SR,PS,'SLOPE')*(DEMANDPS.L(R,SR,PS)**2)))))
  - SUM(RS, SUM(RD, SUM(IP $TIP(RS,RD,IP), CT(RS,RD,IP)*TRANIP.L(RS,RD,IP))))
  - SUM(IN $INES(IN), (BIN(IN,'INTERCEPT')*SUPPLYIN.L(IN))+(0.5*BIN(IN,'SLOPE')*(SUPPLYIN.L(IN)**2)))
  + SUM(PN $PNED(PN), (BPN(PN,'INTERCEPT')*DEMANDPN.L(PN))+(0.5*BPN(PN,'SLOPE')*(DEMANDPN.L(PN)**2)))
  + SUM(R, SUM(PREX $RPREX(R,PREX), BXR(R,PREX,'ADJPRICE')*EXPORTRP.L(R,PREX)))
  - SUM(R, SUM(PRIM $RPRIM(R,PRIM), BMR(R,PRIM,'ADJPRICE')*IMPORTPR.L(R,PRIM)));

RTBL0A('OBJ1') = 0;
RTBL0A('OBJ1') = 
  - SUM(R, SUM(IR $IRES(R,IR), (BIR(R,IR,'INTERCEPT')*SUPPLYIR.L(R,IR))+(0.5*BIR(R,IR,'SLOPE')
                               *(SUPPLYIR.L(R,IR)**2)))
         + SUM(SR $RSR(R,SR), SUM(IS $ISES(R,SR,IS), (BIS(R,SR,IS,'INTERCEPT')*SUPPLYIS.L(R,SR,IS))
                                  +(0.5*BIS(R,SR,IS,'SLOPE')*(SUPPLYIS.L(R,SR,IS)**2)))))
  + SUM(R, SUM(PR $PRED(R,PR), (BPR(R,PR,'INTERCEPT')*DEMANDPR.L(R,PR))+(0.5*BPR(R,PR,'SLOPE')
                              *(DEMANDPR.L(R,PR)**2)))
+ SUM(SR $RSR(R,SR), SUM(PS $PSED(R,SR,PS), (BPS(R,SR,PS,'INTERCEPT')*DEMANDPS.L(R,SR,PS))
                                  +(0.5*BPS(R,SR,PS,'SLOPE')*(DEMANDPS.L(R,SR,PS)**2)))));
RTBL0A('OBJ1P') = 
  - SUM(R, SUM(IR $IRES(R,IR), (BIR(R,IR,'INTERCEPT')*SUPPLYIR.L(R,IR))+(0.5*BIR(R,IR,'SLOPE')
                               *(SUPPLYIR.L(R,IR)**2)))
         + SUM(SR $RSR(R,SR), SUM(IS $ISES(R,SR,IS), (BIS(R,SR,IS,'INTERCEPT')*SUPPLYIS.L(R,SR,IS))
                                  +(0.5*BIS(R,SR,IS,'SLOPE')*(SUPPLYIS.L(R,SR,IS)**2)))));
RTBL0A('PSURCR') = 
  - SUM(R, SUM(IR $IRES(R,IR), (BIR(R,IR,'INTERCEPT')*SUPPLYIR.L(R,IR))+(0.5*BIR(R,IR,'SLOPE')
                               *(SUPPLYIR.L(R,IR)**2))));
RTBL0A('PSURCS') = 
  - SUM(R, SUM(SR $RSR(R,SR), SUM(IS $ISES(R,SR,IS), (BIS(R,SR,IS,'INTERCEPT')*SUPPLYIS.L(R,SR,IS))
                                  +(0.5*BIS(R,SR,IS,'SLOPE')*(SUPPLYIS.L(R,SR,IS)**2)))));
RTBL0A('PSURCN') = - SUM(IN $INES(IN),
                 (BIN(IN,'INTERCEPT')*SUPPLYIN.L(IN))+(0.5*BIN(IN,'SLOPE')*(SUPPLYIN.L(IN)**2)));
RTBL0A('OBJ1C') = 0;
RTBL0A('OBJ1C') = 
    + SUM(R, SUM(PR $PRED(R,PR), (BPR(R,PR,'INTERCEPT')*DEMANDPR.L(R,PR))+(0.5*BPR(R,PR,'SLOPE')
                              *(DEMANDPR.L(R,PR)**2)))
+ SUM(SR $RSR(R,SR), SUM(PS $PSED(R,SR,PS), (BPS(R,SR,PS,'INTERCEPT')*DEMANDPS.L(R,SR,PS))
                                  +(0.5*BPS(R,SR,PS,'SLOPE')*(DEMANDPS.L(R,SR,PS)**2)))));
RTBL0A('PSURIRX') = 
    + SUM(R, SUM(PR $PRED(R,PR), (BPR(R,PR,'INTERCEPT')*DEMANDPR.L(R,PR))+(0.5*BPR(R,PR,'SLOPE')
                              *(DEMANDPR.L(R,PR)**2))));
RTBL0A('PSURISX') = 
    + SUM(R, SUM(SR $RSR(R,SR), SUM(PS $PSED(R,SR,PS), (BPS(R,SR,PS,'INTERCEPT')*DEMANDPS.L(R,SR,PS))
                                  +(0.5*BPS(R,SR,PS,'SLOPE')*(DEMANDPS.L(R,SR,PS)**2)))));
RTBL0A('PSURINX') = SUM(PN $PNED(PN),
                     (BPN(PN,'INTERCEPT')*DEMANDPN.L(PN))+(0.5*BPN(PN,'SLOPE')*(DEMANDPN.L(PN)**2)));
RTBL0A('OBJ2') = 0;
RTBL0A('OBJ2') = 
    - SUM(RS, SUM(RD, SUM(IP $TIP(RS,RD,IP), CT(RS,RD,IP)*TRANIP.L(RS,RD,IP))))
  - SUM(IN $INES(IN), (BIN(IN,'INTERCEPT')*SUPPLYIN.L(IN))+(0.5*BIN(IN,'SLOPE')*(SUPPLYIN.L(IN)**2)))
  + SUM(PN $PNED(PN), (BPN(PN,'INTERCEPT')*DEMANDPN.L(PN))+(0.5*BPN(PN,'SLOPE')*(DEMANDPN.L(PN)**2)))
  + SUM(R, SUM(PREX $RPREX(R,PREX), BXR(R,PREX,'ADJPRICE')*EXPORTRP.L(R,PREX)))
  - SUM(R, SUM(PRIM $RPRIM(R,PRIM), BMR(R,PRIM,'ADJPRICE')*IMPORTPR.L(R,PRIM)))+0.001;

DISPLAY RTBL0B;
*DISPLAY RTBL0C;
DISPLAY RTBL0;
DISPLAY RTBL0A;
DISPLAY RTBL21;
*DISPLAY RTBL20;
*DISPLAY RTBL13E;
DISPLAY RTBL13E2;
DISPLAY RTBL6A
DISPLAY RTBL6B
DISPLAY RTBL9;
DISPLAY RTBL9A;
DISPLAY RTBL9C;
DISPLAY RTBL1B2;
DISPLAY RTBL1C2;
*DISPLAY RTBL1D;
DISPLAY RTBL1E;
*DISPLAY RTBL7B;
DISPLAY RTBL7B2;
*DISPLAY RTBL13C;
DISPLAY RTBL13C2;
*DISPLAY RTBL13D;
DISPLAY RTBL13D2;
DISPLAY RTBL16;
DISPLAY RTBL17;
*DISPLAY VALIDATION.M;
OPTION RTBL2:3:1:1; DISPLAY $OC('PRODUCTS') RTBL2;
OPTION RTBL1:3:3:1; DISPLAY $OC('PRODUCTS') RTBL1;
OPTION RTBL6:3:1:1; DISPLAY $OC('PPRICES') RTBL6;
OPTION RTBL5:3:2:1; DISPLAY $OC('PPRICES') RTBL5;
OPTION RTBL8:3:2:1; DISPLAY $OC('INPUTS') RTBL8;
OPTION RTBL7:3:3:1; DISPLAY $OC('INPUTS') RTBL7;
OPTION RTBL12:3:1:1; DISPLAY $OC('IPRICES') RTBL12;
OPTION RTBL11:3:2:1; DISPLAY $OC('IPRICES') RTBL11;
OPTION RTBL14:3:1:1; DISPLAY $OC('PRODACT') RTBL14;
OPTION RTBL13B:3:1:1; DISPLAY $OC('PRODACT') RTBL13B;
OPTION RTBL13:3:2:1; DISPLAY $OC('PRODACT') RTBL13;
*OPTION RTBL17:3:1:1; DISPLAY $OC('CROPAREA') RTBL17;
*OPTION RTBL16:3:2:1; DISPLAY $OC('CROPAREA') RTBL16;
 
* Generate solution tables for dairy
SET DPROD(P)  Diary products
 /MILK, DCALFM, DCALFF, SKIMMILK, MILKFAT, KMILK, CHEESE, BUTTER, CREAM, DRYMILK, DRYMILK2/;
 
  
* Generate variable and constraint tables
 

PARAMETER VTBL1(R,SR,AS,TH2)  Subregional results for production activities;
VTBL1(R,SR,AS,TH2) = 0.0;
VTBL1(R,SR,AS,'LOWER') $RSRAS(R,SR,AS) = PRODSR.LO(R,SR,AS);
VTBL1(R,SR,AS,'LEVEL') $RSRAS(R,SR,AS) = PRODSR.L(R,SR,AS);
VTBL1(R,SR,AS,'UPPER') $RSRAS(R,SR,AS) = PRODSR.UP(R,SR,AS);
VTBL1(R,SR,AS,'MARGINAL') $RSRAS(R,SR,AS) = PRODSR.M(R,SR,AS);
OPTION VTBL1:3:1:1; DISPLAY $OC('VARS') VTBL1;
  
PARAMETER VTBL3(R,CR,TH2)  Regional results for processing activities;
VTBL3(R,CR,TH2) = 0.0;

VTBL3(R,CR,'LOWER') $RCR(R,CR) = PROCR.LO(R,CR);
VTBL3(R,CR,'LEVEL') $RCR(R,CR) = PROCR.L(R,CR);
VTBL3(R,CR,'UPPER') $RCR(R,CR) = PROCR.UP(R,CR);
VTBL3(R,CR,'MARGINAL') $RCR(R,CR) = PROCR.M(R,CR);
OPTION VTBL3:3:2:1; DISPLAY $OC('VARS') VTBL3;
 
PARAMETER VTBL6(R,IR,TH2)  Results for regional input supply activities;
VTBL6(R,IR,TH2) = 0.0;
VTBL6(R,IR,'LOWER') $IRES(R,IR) = SUPPLYIR.LO(R,IR);
VTBL6(R,IR,'LEVEL') $IRES(R,IR) = SUPPLYIR.L(R,IR);
VTBL6(R,IR,'UPPER') $IRES(R,IR) = SUPPLYIR.UP(R,IR);
VTBL6(R,IR,'MARGINAL') $IRES(R,IR) = SUPPLYIR.M(R,IR);
OPTION VTBL6:3:2:1; DISPLAY $OC('VARS') VTBL6;
 
PARAMETER VTBL5(R,SR,IS,TH2)  Results for subregional input supply activities;
VTBL5(R,SR,IS,TH2) = 0.0;
VTBL5(R,SR,IS,'LOWER') $ISES(R,SR,IS) = SUPPLYIS.LO(R,SR,IS);
VTBL5(R,SR,IS,'LEVEL') $ISES(R,SR,IS) = SUPPLYIS.L(R,SR,IS);
VTBL5(R,SR,IS,'UPPER') $ISES(R,SR,IS) = SUPPLYIS.UP(R,SR,IS);
VTBL5(R,SR,IS,'MARGINAL') $ISES(R,SR,IS) = SUPPLYIS.M(R,SR,IS);
OPTION VTBL5:3:3:1; DISPLAY $OC('VARS') VTBL5;
 
PARAMETER VTBL9(R,PR,TH2)  Results for regional product demand activities;

VTBL9(R,PR,TH2) = 0.0;
VTBL9(R,PR,'LOWER') $PRED(R,PR) = DEMANDPR.LO(R,PR);
VTBL9(R,PR,'LEVEL') $PRED(R,PR) = DEMANDPR.L(R,PR);
VTBL9(R,PR,'UPPER') $PRED(R,PR) = DEMANDPR.UP(R,PR);
VTBL9(R,PR,'MARGINAL') $PRED(R,PR) = DEMANDPR.M(R,PR);
OPTION VTBL9:3:2:1; DISPLAY $OC('VARS') VTBL9;
 
PARAMETER VTBL8(R,SR,PS,TH2)  Results for subregional product demand activities;
VTBL8(R,SR,PS,TH2) = 0.0;
VTBL8(R,SR,PS,'LOWER') $PSED(R,SR,PS) = DEMANDPS.LO(R,SR,PS);
VTBL8(R,SR,PS,'LEVEL') $PSED(R,SR,PS) = DEMANDPS.L(R,SR,PS);
VTBL8(R,SR,PS,'UPPER') $PSED(R,SR,PS) = DEMANDPS.UP(R,SR,PS);
VTBL8(R,SR,PS,'MARGINAL') $PSED(R,SR,PS) = DEMANDPS.M(R,SR,PS);
OPTION VTBL8:3:2:1; DISPLAY $OC('VARS') VTBL8;
 
PARAMETER VTBL11(R,PR,TH2)  Results for regional product export activities;
VTBL11(R,PR,TH2) = 0.0;
VTBL11(R,PR,'LOWER') $RPREX(R,PR) = EXPORTRP.LO(R,PR);
VTBL11(R,PR,'LEVEL') $RPREX(R,PR) = EXPORTRP.L(R,PR);
VTBL11(R,PR,'UPPER') $RPREX(R,PR) = EXPORTRP.UP(R,PR);
VTBL11(R,PR,'MARGINAL') $RPREX(R,PR) = EXPORTRP.M(R,PR);
OPTION VTBL11:3:2:1; DISPLAY $OC('VARS') VTBL11;
 
PARAMETER VTBL13(R,PR,TH2)  Results for regional product import activities;
VTBL13(R,PR,TH2) = 0.0;
VTBL13(R,PR,'LOWER') $RPRIM(R,PR) = IMPORTPR.LO(R,PR);
VTBL13(R,PR,'LEVEL') $RPRIM(R,PR) = IMPORTPR.L(R,PR);
VTBL13(R,PR,'UPPER') $RPRIM(R,PR) = IMPORTPR.UP(R,PR);
VTBL13(R,PR,'MARGINAL') $RPRIM(R,PR) = IMPORTPR.M(R,PR);
OPTION VTBL13:3:2:1; DISPLAY $OC('VARS') VTBL13;
 
PARAMETER VTBL15(RS,RD,IP,TH2)  Results for inter-regional transportation activities;
VTBL15(RS,RD,IP,TH2) = 0.0;
VTBL15(RS,RD,IP,'LOWER') $TIP(RS,RD,IP) = TRANIP.LO(RS,RD,IP);
VTBL15(RS,RD,IP,'LEVEL') $TIP(RS,RD,IP) = TRANIP.L(RS,RD,IP);
VTBL15(RS,RD,IP,'UPPER') $TIP(RS,RD,IP) = TRANIP.UP(RS,RD,IP);
VTBL15(RS,RD,IP,'MARGINAL') $TIP(RS,RD,IP) = TRANIP.M(RS,RD,IP);
VTBL15(RS,RD,IP,TH2) $(TRANIP.L(RS,RD,IP) EQ 0) = 0.0;
OPTION VTBL15:3:3:1; DISPLAY $OC('VARS') VTBL15;
 
PARAMETER CTBL2(R,PR,TH2)  Results for regional product balance equations;
CTBL2(R,PR,TH2) = 0.0;
CTBL2(R,PR,'LOWER') $RPR(R,PR) = PRODUCTRE.LO(R,PR) $PRED(R,PR) + PRODUCTRF.LO(R,PR) $PRFD(R,PR);

CTBL2(R,PR,'LEVEL') $RPR(R,PR) = PRODUCTRE.L(R,PR) $PRED(R,PR) + PRODUCTRF.L(R,PR) $PRFD(R,PR);
CTBL2(R,PR,'UPPER') $RPR(R,PR) = PRODUCTRE.UP(R,PR) $PRED(R,PR) + PRODUCTRF.UP(R,PR) $PRFD(R,PR);
CTBL2(R,PR,'MARGINAL') $RPR(R,PR) = PRODUCTRE.M(R,PR) $PRED(R,PR) + PRODUCTRF.M(R,PR) $PRFD(R,PR);
OPTION CTBL2:3:2:1; DISPLAY $OC('EQNS') CTBL2;
 
PARAMETER CTBL1(R,SR,PS,TH2)  Results for subregional product balance equations;
CTBL1(R,SR,PS,TH2) = 0.0;
CTBL1(R,SR,PS,'LOWER') $RSRPS(R,SR,PS) = PRODUCTSE.LO(R,SR,PS) $PSED(R,SR,PS)
                                       + PRODUCTSF.LO(R,SR,PS) $PSFD(R,SR,PS);
CTBL1(R,SR,PS,'LEVEL') $RSRPS(R,SR,PS) = PRODUCTSE.L(R,SR,PS) $PSED(R,SR,PS)
                                       + PRODUCTSF.L(R,SR,PS) $PSFD(R,SR,PS);
CTBL1(R,SR,PS,'UPPER') $RSRPS(R,SR,PS) = PRODUCTSE.UP(R,SR,PS) $PSED(R,SR,PS)
                                       + PRODUCTSF.UP(R,SR,PS) $PSFD(R,SR,PS);
CTBL1(R,SR,PS,'MARGINAL') $RSRPS(R,SR,PS) = PRODUCTSE.M(R,SR,PS) $PSED(R,SR,PS)
                                          + PRODUCTSF.M(R,SR,PS) $PSFD(R,SR,PS);
OPTION CTBL1:3:3:1; DISPLAY $OC('EQNS') CTBL1;
 
PARAMETER CTBL5(R,IR,TH2)  Results for regional input balance equations;
CTBL5(R,IR,TH2) = 0.0;

CTBL5(R,IR,'LOWER') $RIR(R,IR) = INPUTRE.LO(R,IR) $IRES(R,IR) + INPUTRF.LO(R,IR) $IRFS(R,IR);
CTBL5(R,IR,'LEVEL') $RIR(R,IR) = INPUTRE.L(R,IR) $IRES(R,IR) + INPUTRF.L(R,IR) $IRFS(R,IR);
CTBL5(R,IR,'UPPER') $RIR(R,IR) = INPUTRE.UP(R,IR) $IRES(R,IR) + INPUTRF.UP(R,IR) $IRFS(R,IR);
CTBL5(R,IR,'MARGINAL') $RIR(R,IR) = INPUTRE.M(R,IR) $IRES(R,IR) + INPUTRF.M(R,IR) $IRFS(R,IR);

OPTION CTBL5:3:2:1; DISPLAY $OC('EQNS') CTBL5;

PARAMETER CTBL4(R,SR,IS,TH2)  Results for subregional input balance equations;
CTBL4(R,SR,IS,TH2) = 0.0;
CTBL4(R,SR,IS,'LOWER') $RSRIS(R,SR,IS) = INPUTSE.LO(R,SR,IS) $ISES(R,SR,IS)
                                       + INPUTSF.LO(R,SR,IS) $ISFS(R,SR,IS);
CTBL4(R,SR,IS,'LEVEL') $RSRIS(R,SR,IS) = INPUTSE.L(R,SR,IS) $ISES(R,SR,IS)
                                       + INPUTSF.L(R,SR,IS) $ISFS(R,SR,IS);
CTBL4(R,SR,IS,'UPPER') $RSRIS(R,SR,IS) = INPUTSE.UP(R,SR,IS) $ISES(R,SR,IS)
                                       + INPUTSF.UP(R,SR,IS) $ISFS(R,SR,IS);
CTBL4(R,SR,IS,'MARGINAL') $RSRIS(R,SR,IS) = INPUTSE.M(R,SR,IS) $ISES(R,SR,IS)
                                          + INPUTSF.M(R,SR,IS) $ISFS(R,SR,IS);
OPTION CTBL4:3:3:1; DISPLAY $OC('EQNS') CTBL4;
 

Set dummy /Units/;
* ett dummy-index för att göra en kolumn

Parameter RTBL15_exp(AS,dummy);

* Fyll hjälpparametern
RTBL15_exp(AS,'Units') = RTBL15(AS);


$set ourFileName %system.fn%
execute_unload "%ourFileName%.gdx" RTBL4, RTBL10, RTBL15_exp, RTBL13E2, RTBL1B2, RTBL1C2;
execute "gdxxrw i=%ourFileName%.gdx par=RTBL4 rng=Products!A1 par=RTBL10 rng=Inputs!A1 par=RTBL15_exp rng=Activities!A1 par=RTBL13E2 rng=Regions!A1";
execute "gdxxrw i=%ourFileName%.gdx par=RTBL1B2 rng=Regions!A35 par=RTBL1C2 rng=Regions!A60";