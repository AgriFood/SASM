*===============================================================================
* SASM-inställningsfil
* ====================
* Den här filen styr alla användarinställningar för en modellkörning.
* Redigera den här filen för att konfigurera ett scenario -- huvudfilen
* (SASM2025.gms) ska sällan behöva ändras.
*
* Innehåll
* --------
* 1. Körningsidentitet        Körningsnamn och resultatmapp
* 2. Simuleringshorisont      Simuleringsår och lång-/kortsiktsanalys
* 3. Specialmoduler           AV/PÅ-switchar för valfria moduler
* 4. Makroparametrar          Växelkurs, KPI och handelsfaktorer
* 5. Mikroparametrar          Produktivitetstillväxt och sektorsspecifika parametrar
* 6. Stödbetalningar          Justeringar av direktstöd och landsbygdsstöd
* 7. Priser                   Procentuella prisjusteringar för insatsvaror och produkter
* 8. Utskriftskontroll        Vilka resultatblock som skrivs till lst och Excel
*===============================================================================


*===============================================================================
* 1. KÖRNINGSIDENTITET
*===============================================================================
* - Ge körningen ett namn (används som filnamn för resultatfiler; ersätt "baseline" nedan)
$setGlobal scenarioName baseline
* - Ange resultatmapp (relativ sökväg från modellens rotkatalog)
$setGlobal resultFolder output


*===============================================================================
* 2. SIMULERINGSHORISONT
*===============================================================================
* - Välj simuleringsår
* Möjliga år att välja: 2025-2055
YEAR = 2025;

* - Aktivera långsiktseffekter
LONGRUN  = no;
* yes = fysiska förändringar aktiverade enligt följande:
* - arealen åkermark minskar med 0.27 % per år och naturbetesmark minskar med 0.2 % per år
* - förslitning av stallbyggnader sker (kapaciteten minskar) med 5 % per år
* - investeringar i byggnader kan göras, reparation eller nybyggnation
* - omställning till ekologiskt tillåtet
* - arealen naturbetesmark kan öka med regionspecifika underutnyttjade arealer (POTPAST)
* - Sveriges befolkning och därmed efterfrågan stiger med 1 % per år, utom för mejeri som minskar med 0.5 % per år
LONGRUN1 = no;
* yes = prisförändringar aktiverade
LONGRUN2 = no;
* yes = produktivitetsutveckling aktiverad


* - Expansion av ekologisk produktion
* När LONGRUN = no spärras omställning från konventionell till ekologisk produktion till basårets nivåer. 
* Detta reglage spärrar även vid LONGRUN = yes. Gäller både växtodling och djur.
organicExp = yes;
* yes = omställning till ekologiskt tillåten (kräver LONGRUN = yes; ignoreras annars)
* no  = ekologisk andel spärrad vid basårsnivå även i långsiktsanalys


*===============================================================================
* 3. SPECIALMODULER
*===============================================================================
* - Scenariospecifik modul med fri kodning 
$setGlobal scenariosettings no
* yes = läser scenario_settings.gms sent i koden. Används till scenariospecifika inställingar som inte är förberedda i denna fil 

* - Importbegränsningsmodul
$setGlobal tradeReduction no
* yes = kör Trade_reduction.gms efter lösning (begränsar import av spannmål och mejeriprodukter)


*===============================================================================
* 4. MAKROPARAMETRAR
*===============================================================================
* - Växelkurs SEK/EUR
exchangeRate = 11.06;

* - Konsumentprisindex
CPI  = 1;
** förändring från basår

* - Växthusgasutsläpp i handlade varor
CO2IMP = no;
** yes = inkluderar utsläpp inbäddade i importerade insatsvaror och produkter

* - Reduktionsfaktor för handel och transport
* RED = 1.00;


*===============================================================================
* 5. MIKROPARAMETRAR
*===============================================================================
* Avkastning per hektar ökar över tid. Grundnivå: 1.005
prodGrowthYields      = 1.005;
* Avkastning per ko ökar över tid. Grundnivå: 1.015
prodGrowthMilkYield   = 1.010;
* Antal smågrisar per sugga ökar över tid. Grundnivå: 1.025
prodGrowthPiglets     = 1.025;

* Faktorproduktiviteten ökar över tid.
* Grundnivåer:
** Arbetskraft: 0.985
** Inputs: 0.995
** Energi: 0.985
prodGrowthInputs = 0.995;
prodGrowthLabour = 0.985;
prodGrowthPower  = 0.985;


*===============================================================================
* 6. STÖDBETALNINGAR
*===============================================================================
* supportPct: procentuell förändring i decimal, t.ex. 0.10 = +10%, -0.05 = -5%
* supportAdd: absolut förändring i EUR/ha eller SEK/ha (valuta framgår per rad nedan)

* -- CAP: Direktstöd
* Grundläggande inkomststöd för hållbarhet (BISS). Basvärde: 138 EUR
supportPct('GACRSUB') = 0;
supportAdd('GACRSUB') = 0;

* Kopplat stöd för nötkreatur (CIS). Basvärde: 91 EUR
supportPct('CATTLESUB') = 0;
supportAdd('CATTLESUB') = 0;

* - Eco-schemes: Åtgärder för klimat, miljö och djurvälfärd
* Eco-scheme 1: ej i bruk
supportPct('ES1') = 0;
supportAdd('ES1') = 0;
* Eco-scheme 2: ej i bruk
supportPct('ES2') = 0;
supportAdd('ES2') = 0;
* Eco-scheme 3: precisionsjordbruk. Basvärde 2025: 41 EUR
supportPct('ES3') = 0;
supportAdd('ES3') = 0;
* Eco-scheme 4: mellangröda. Basvärde 2025: 141 EUR
supportPct('ES4') = 0;
supportAdd('ES4') = 0;
* Eco-scheme 5: fånggröda. Basvärde 2025: 156 EUR
supportPct('ES5') = 0;
supportAdd('ES5') = 0;
* Eco-scheme 6: vårplöjning. Basvärde 2025: 72 EUR
supportPct('ES6') = 0;
supportAdd('ES6') = 0;

* Eco-scheme för ekologisk produktion.
* Satser i EUR per enhet; omräkningsfaktorerna per djurslag följer satsen automatiskt.
* Basvärden: 162, 541, 195 EUR.
ecosubCrop      = 162;
ecosubPotato    = 541;
ecosubLivestock = 195;

* Eco-scheme för vallproduktion. Basvärde: 0 EUR (Ej aktivt 2025; från 2026: 54 EUR)
supportPct('FORSUB') = 0;
supportAdd('FORSUB') = 0;


* -- CAP: Landsbygdsutveckling
* - Miljö-, klimatåtaganden och andra skötselåtaganden (ENVCLIM)
* Djurvälfärdsstöd för suggors hälsa. Basvärde: 2100 SEK
supportPct('SOWHLTSUB') = 0;
supportAdd('SOWHLTSUB') = 0;

* Grundersättning för betesmarker. Basvärde: 1850 SEK
supportPct('BIODIVSUB') = 0;
supportAdd('BIODIVSUB') = 0;
* Förhöjd ersättning för betesmarker. Basvärde: 2100 SEK
supportPct('BIODIVSUB2') = 0;
supportAdd('BIODIVSUB2') = 0;
* Högsta ersättning för betesmarker med höga värden. Basvärde: 3950 SEK
supportPct('BIODIVSUB3') = 0;
supportAdd('BIODIVSUB3') = 0;
* Ersättning för betesvård på alvaret. Basvärde: 1400 SEK
supportPct('BIODIVSUBA') = 0;
supportAdd('BIODIVSUBA') = 0;
* Ersättning för skogsbetesmark. Basvärde: 3500 SEK
supportPct('BIODIVSUBF') = 0;
supportAdd('BIODIVSUBF') = 0;
* Ersättning för mosaikbetesmark. Basvärde: 2700 SEK
supportPct('BIODIVSUBM') = 0;
supportAdd('BIODIVSUBM') = 0;
* Ersättning för gräsfattig betesmark. Basvärde: 2700 SEK
supportPct('BIODIVSUBG') = 0;
supportAdd('BIODIVSUBG') = 0;
* Ersättning för fäbodbete. Basvärde: 2000 SEK
supportPct('BIODIVSUBC') = 0;
supportAdd('BIODIVSUBC') = 0;
* Ersättning för slåtterängar. Basvärde: 5500 SEK
supportPct('BIODIVSUBS') = 0;
supportAdd('BIODIVSUBS') = 0;

* - Kompensationsstöd för naturliga begränsningar (LFA) ändras per stödområde, se avsnitt 6b.
* - Nationella stöd ändras per stödområde i avsnitt 6c.


*===============================================================================
* 6b. KOMPENSATIONSSTÖD (LFA)
*===============================================================================

* supportPctSub: procentuell förändring i decimal, t.ex. 0.10 = +10%
* supportAddSub: absolut förändring i SEK/ha (COMPSUBL: SEK per djurenhet)
* Positivt värde = höjt stöd, för båda reglagen.
* Observera att supportPctSub inte kan införa ett stöd där basvärdet är noll.

* - Kompensationsstöd 4 (COMP4SUB). Basvärden (SEK/ha):
*   SA01-SA05 1900, SA06-SA12 800
supportPctSub('COMP4SUB','SA01') = 0;   supportAddSub('COMP4SUB','SA01') = 0;
supportPctSub('COMP4SUB','SA02') = 0;   supportAddSub('COMP4SUB','SA02') = 0;
supportPctSub('COMP4SUB','SA03') = 0;   supportAddSub('COMP4SUB','SA03') = 0;
supportPctSub('COMP4SUB','SA04') = 0;   supportAddSub('COMP4SUB','SA04') = 0;
supportPctSub('COMP4SUB','SA05') = 0;   supportAddSub('COMP4SUB','SA05') = 0;
supportPctSub('COMP4SUB','SA06') = 0;   supportAddSub('COMP4SUB','SA06') = 0;
supportPctSub('COMP4SUB','SA07') = 0;   supportAddSub('COMP4SUB','SA07') = 0;
supportPctSub('COMP4SUB','SA08') = 0;   supportAddSub('COMP4SUB','SA08') = 0;
supportPctSub('COMP4SUB','SA09') = 0;   supportAddSub('COMP4SUB','SA09') = 0;
supportPctSub('COMP4SUB','SA10') = 0;   supportAddSub('COMP4SUB','SA10') = 0;
supportPctSub('COMP4SUB','SA11') = 0;   supportAddSub('COMP4SUB','SA11') = 0;
supportPctSub('COMP4SUB','SA12') = 0;   supportAddSub('COMP4SUB','SA12') = 0;

* - Kompensationsstöd areal (COMPSUB). Basvärden (SEK/ha):
*  SA01: 329, SA02: 377, SA03: 358, SA04: 106, SA05: 15, SA06: 0,
*  SA07: 0, SA08: 8, SA09: 0, SA10: 0, SA11: 0, SA12: 0
supportPctSub('COMPSUB','SA01')  = 0;   supportAddSub('COMPSUB','SA01')  = 0;
supportPctSub('COMPSUB','SA02')  = 0;   supportAddSub('COMPSUB','SA02')  = 0;
supportPctSub('COMPSUB','SA03')  = 0;   supportAddSub('COMPSUB','SA03')  = 0;
supportPctSub('COMPSUB','SA04')  = 0;   supportAddSub('COMPSUB','SA04')  = 0;
supportPctSub('COMPSUB','SA05')  = 0;   supportAddSub('COMPSUB','SA05')  = 0;
supportPctSub('COMPSUB','SA06')  = 0;   supportAddSub('COMPSUB','SA06')  = 0;
supportPctSub('COMPSUB','SA07')  = 0;   supportAddSub('COMPSUB','SA07')  = 0;
supportPctSub('COMPSUB','SA08')  = 0;   supportAddSub('COMPSUB','SA08')  = 0;
supportPctSub('COMPSUB','SA09')  = 0;   supportAddSub('COMPSUB','SA09')  = 0;
supportPctSub('COMPSUB','SA10')  = 0;   supportAddSub('COMPSUB','SA10')  = 0;
supportPctSub('COMPSUB','SA11')  = 0;   supportAddSub('COMPSUB','SA11')  = 0;
supportPctSub('COMPSUB','SA12')  = 0;   supportAddSub('COMPSUB','SA12')  = 0;

* - Kompensationsstöd djur (COMPSUBL). Basvärden (SEK per djurenhet):
*   SA01 6088, SA02 4444, SA03 3792, SA04 3504, SA05 3097, SA06 1813,
*   SA07 1304, SA08 1160, SA09 852, SA10 793, SA11 1080, SA12 1490
* (Arealbegränsning på COMPSUBL: 1000 stödenheter)
supportPctSub('COMPSUBL','SA01') = 0;   supportAddSub('COMPSUBL','SA01') = 0;
supportPctSub('COMPSUBL','SA02') = 0;   supportAddSub('COMPSUBL','SA02') = 0;
supportPctSub('COMPSUBL','SA03') = 0;   supportAddSub('COMPSUBL','SA03') = 0;
supportPctSub('COMPSUBL','SA04') = 0;   supportAddSub('COMPSUBL','SA04') = 0;
supportPctSub('COMPSUBL','SA05') = 0;   supportAddSub('COMPSUBL','SA05') = 0;
supportPctSub('COMPSUBL','SA06') = 0;   supportAddSub('COMPSUBL','SA06') = 0;
supportPctSub('COMPSUBL','SA07') = 0;   supportAddSub('COMPSUBL','SA07') = 0;
supportPctSub('COMPSUBL','SA08') = 0;   supportAddSub('COMPSUBL','SA08') = 0;
supportPctSub('COMPSUBL','SA09') = 0;   supportAddSub('COMPSUBL','SA09') = 0;
supportPctSub('COMPSUBL','SA10') = 0;   supportAddSub('COMPSUBL','SA10') = 0;
supportPctSub('COMPSUBL','SA11') = 0;   supportAddSub('COMPSUBL','SA11') = 0;
supportPctSub('COMPSUBL','SA12') = 0;   supportAddSub('COMPSUBL','SA12') = 0;


*===============================================================================
* 6c. NATIONELLT STÖD (NATSUB)
*===============================================================================

* natsubPct: procentuell förändring i decimal, t.ex. 0.10 = +10%
* natsubAdd: absolut förändring i SEK per hektar eller djur
* Positivt värde = höjt stöd, för båda reglagen.

* Omräkningen till modellens enheter sköts automatiskt.
* Använd bara SA01, SA02, SA03, SA04a, SA04b, SA05 — värden på SA04 ignoreras tyst.

* - Potatis. Basvärden (SEK/ha):
*   SA01 4400, SA02 4100, SA03 3900, SA04a 3200, SA04b 3200, SA05 2100
natsubPct('POTATO','SA01')  = 0;   natsubAdd('POTATO','SA01')  = 0;
natsubPct('POTATO','SA02')  = 0;   natsubAdd('POTATO','SA02')  = 0;
natsubPct('POTATO','SA03')  = 0;   natsubAdd('POTATO','SA03')  = 0;
natsubPct('POTATO','SA04a') = 0;   natsubAdd('POTATO','SA04a') = 0;
natsubPct('POTATO','SA04b') = 0;   natsubAdd('POTATO','SA04b') = 0;
natsubPct('POTATO','SA05')  = 0;   natsubAdd('POTATO','SA05')  = 0;

* - Suggor. Basvärden (SEK per sugga):
*   SA01 930, SA02 930, SA03 930, SA04a 860, SA04b 860, SA05 850
natsubPct('SOW1','SA01')  = 0;     natsubAdd('SOW1','SA01')  = 0;
natsubPct('SOW1','SA02')  = 0;     natsubAdd('SOW1','SA02')  = 0;
natsubPct('SOW1','SA03')  = 0;     natsubAdd('SOW1','SA03')  = 0;
natsubPct('SOW1','SA04a') = 0;     natsubAdd('SOW1','SA04a') = 0;
natsubPct('SOW1','SA04b') = 0;     natsubAdd('SOW1','SA04b') = 0;
natsubPct('SOW1','SA05')  = 0;     natsubAdd('SOW1','SA05')  = 0;

* - Slaktsvin. Basvärden (SEK/hd):
*   SA01 200, SA02 200, SA03 190, SA04a 180, SA04b 180, SA05 160
natsubPct('SLGHSWINE1','SA01')  = 0;  natsubAdd('SLGHSWINE1','SA01')  = 0;
natsubPct('SLGHSWINE1','SA02')  = 0;  natsubAdd('SLGHSWINE1','SA02')  = 0;
natsubPct('SLGHSWINE1','SA03')  = 0;  natsubAdd('SLGHSWINE1','SA03')  = 0;
natsubPct('SLGHSWINE1','SA04a') = 0;  natsubAdd('SLGHSWINE1','SA04a') = 0;
natsubPct('SLGHSWINE1','SA04b') = 0;  natsubAdd('SLGHSWINE1','SA04b') = 0;
natsubPct('SLGHSWINE1','SA05')  = 0;  natsubAdd('SLGHSWINE1','SA05')  = 0;

* - Värphöns. Basvärden (SEK/hd):
*   SA01 20.3, SA02 17.1, SA03 17.1, SA04a 12.7, SA04b 12.7, SA05 5.8
natsubPct('POULTRY','SA01')  = 0;  natsubAdd('POULTRY','SA01')  = 0;
natsubPct('POULTRY','SA02')  = 0;  natsubAdd('POULTRY','SA02')  = 0;
natsubPct('POULTRY','SA03')  = 0;  natsubAdd('POULTRY','SA03')  = 0;
natsubPct('POULTRY','SA04a') = 0;  natsubAdd('POULTRY','SA04a') = 0;
natsubPct('POULTRY','SA04b') = 0;  natsubAdd('POULTRY','SA04b') = 0;
natsubPct('POULTRY','SA05')  = 0;  natsubAdd('POULTRY','SA05')  = 0;

* - Mjölkstöd. Satsen anges per kilo mjölk och bokförs som NATSUB på mjölkkoaktiviteterna.
* milkSubAdd anges i SEK per kg. 
* Basvärden: SA01: 1.64, SA02: 1.33, SA03 1.08, SA04 0.73, SA05 0.48
milkSubPct('SA01')  = 0;           milkSubAdd('SA01')  = 0;
milkSubPct('SA02')  = 0;           milkSubAdd('SA02')  = 0;
milkSubPct('SA03')  = 0;           milkSubAdd('SA03')  = 0;
milkSubPct('SA04a') = 0;           milkSubAdd('SA04a') = 0;
milkSubPct('SA04b') = 0;           milkSubAdd('SA04b') = 0;
milkSubPct('SA05')  = 0;           milkSubAdd('SA05')  = 0;


*===============================================================================
* 7. PRISER
*===============================================================================
* Procentuell justering i decimal, t.ex. 0.10 = +10%, -0.05 = -5%.
* Noll innebär att priset från prisdata används oförändrat.

* -- Insatsvarupriser
inputPricePct('NITROGEN')   = 0;
inputPricePct('PHOSPHORUS') = 0;
inputPricePct('POTASSIUM')  = 0;
inputPricePct('DIESEL')     = 0;
inputPricePct('LABOR')      = 0;
inputPricePct('SOJA')       = 0;
inputPricePct('BETFOR')     = 0;
inputPricePct('HPMASSA')    = 0;
inputPricePct('PROTFEED')   = 0;

* -- Exportpriser (PEX: BREADGRAIN, COARSGRAIN, OILGRAIN, RAPEOIL, POTATOES, WHITESUGAR,
*                       CHEESE, BUTTER, DRYMILK, DRYMILK2, BEEF, PORK, PLTRYMEAT, SLGHSHEEP, EGG)
exportPricePct('BREADGRAIN') = 0;
exportPricePct('COARSGRAIN') = 0;
exportPricePct('OILGRAIN')   = 0;
exportPricePct('RAPEOIL')    = 0;
exportPricePct('POTATOES')   = 0;
exportPricePct('WHITESUGAR') = 0;
exportPricePct('CHEESE')     = 0;
exportPricePct('BUTTER')     = 0;
exportPricePct('DRYMILK')    = 0;
exportPricePct('DRYMILK2')   = 0;
exportPricePct('BEEF')       = 0;
exportPricePct('PORK')       = 0;
exportPricePct('PLTRYMEAT')  = 0;
exportPricePct('SLGHSHEEP')  = 0;
exportPricePct('EGG')        = 0;

* -- Importpriser (PIM: BREADGRAIN, COARSGRAIN, PEAS, OILGRAIN, POTATOES, WHITESUGAR,
*                       CHEESE, BUTTER, DRYMILK, DRYMILK2, BEEF, PORK, PLTRYMEAT, SLGHSHEEP, EGG,
*                       WILDMEAT, FISH, FRUIT, VEGETAB, WBERRY, EGRAIN, EPEAS)
importPricePct('BREADGRAIN') = 0;
importPricePct('COARSGRAIN') = 0;
importPricePct('PEAS')       = 0;
importPricePct('OILGRAIN')   = 0;
importPricePct('POTATOES')   = 0;
importPricePct('WHITESUGAR') = 0;
importPricePct('CHEESE')     = 0;
importPricePct('BUTTER')     = 0;
importPricePct('DRYMILK')    = 0;
importPricePct('DRYMILK2')   = 0;
importPricePct('BEEF')       = 0;
importPricePct('PORK')       = 0;
importPricePct('PLTRYMEAT')  = 0;
importPricePct('SLGHSHEEP')  = 0;
importPricePct('EGG')        = 0;
importPricePct('WILDMEAT')   = 0;
importPricePct('FISH')       = 0;
importPricePct('FRUIT')      = 0;
importPricePct('VEGETAB')    = 0;
importPricePct('WBERRY')     = 0;
importPricePct('EGRAIN')     = 0;
importPricePct('EPEAS')      = 0;


*===============================================================================
* 8. UTSKRIFTSKONTROLL
*===============================================================================
* OC styr vilka resultatblock som skrivs till lst-filen och exporteras till Excel.
* Se beskrivningar av blocken nedanför.
* --- Resultatutskrift (skrivs till resultat-Excel) ---
  OC('PRODUCTS')    =  yes;
  OC('INPUTS')      =  yes;
  OC('ACTIVITIES')  =  yes;
  OC('PRICES')      =  yes;
  OC('PAYMENTS')    =  yes;
  OC('TRADE')       =  yes;
  OC('ECONOMY')     =  yes;
  OC('NATIONAL')    =  yes;
  OC('UPR_SUMMARY') =  yes;
  OC('REGIONAL')    =  yes;
  OC('SUBREGIONAL') =  yes;
* --- Diagnostikutskrift (lst-fil och kontrollfil) ---
  OC('VARS')        =  no;
  OC('EQNS')        =  no;
  OC('DSETS')       =  no;
  OC('PARAM')       =  no;
  OC('PRODIO')      =  no;
  OC('CONST')       =  no;
  OC('UTCOST')      =  no;
  OC('DATA')        =  no;

* PRODUCTS     Nationella produktsammanfattningar      -> Excel: Products
* INPUTS       Nationella insatssammanfattningar       -> Excel: Inputs
* ACTIVITIES   Nationella aktivitetssammanfattningar   -> Excel: Activities
* PRICES       Produkt- och insatspriser               -> Excel: R_product_prices, SR_product_prices, R_input_prices, SR_input_prices
* PAYMENTS     Stödbetalningar per delregion           -> Excel: SR_payments_mSEK
* TRADE        Handelssammanfattningar                 -> Excel: Trade
* ECONOMY      Producentöverskott, lönsamhet           -> Excel: SR_producerSurplus, SR_cropProfitability, SR_livestockProfitability
* NATIONAL     Nationella sammanfattningstabeller
* UPR_SUMMARY  Resultat per utskriftsregion (UPR)      -> Excel: UPR
* REGIONAL     Tabeller på FA-regionnivå               -> Excel: R_products, R_inputs
* SUBREGIONAL  Tabeller på delregionnivå               -> Excel: SR_activities, SR_products, SR_gross_value, SR_net_value, SR_inputs
* VARS         Alla variabelresultat                   -> .lst & Excel: Z, PRODSR, SUPPLYIN, DEMANDPN, etc. (stor utskrift)
* EQNS         Alla ekvationsresultat                  -> .lst & Excel: OBJECTIVE, PRODUCTNE, INPUTNE, etc. (stor utskrift)
* DSETS        Dynamiska mängder                       -> .lst & Excel: PNED, PNFD, PRED, PRFD, PSED, PSFD, INES, INFS, IRES, IRFS etc.
* PARAM        Alla parametrar                         -> .lst & Excel: BIN, BIR, BIS, BISF, BISFA, BPN, BPR, BPS, BXR, BMR
* PRODIO       Produktionsaktivitetskoefficienter      -> .lst & Excel: EAS, ECR
* CONST        Arealbegränsningar för grödor           -> .lst & Excel: CONST
* UTCOST       Enhetstransportkostnader                -> .lst & Excel: CT, DT, UT
* DATA         Gödsel, näring med mera                 -> .lst & Excel: MANURE, NSUB, NUTRIENT, POP, DPTR, DPTC, MS
