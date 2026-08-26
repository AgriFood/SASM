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
* Tidsparametrar beräknas i SASM2025.gms:
*   YR  = YEAR - 2025   (år från basår 2025)
*   YRA = YEAR - 2022   (år från basår för arealer, 2022)
*   YRT = YEAR - 2025   (år från basår för tekniska koefficienter, 2020)

* - Aktivera långsiktseffekter
LONGRUN  = no;
* yes = fysiska förändringar aktiverade enligt följande:
* - arealen åkermark minskar med 0.27 % per år och naturbetesmark minskar med 0.2 % per år
* - förslitning av stallbyggnader sker (kapaciteten minskar) med 5 % per år
* - investeringar i byggnader kan göras, reparation eller nybyggnation
* - omställning till ekologiskt tillåtet
* - arealen naturbetesmark kan öka med regionspecifika underutnyttjade arealer (POTPAST)
* - Sveriges befolkning och därmed efterfrågan stiger med 1 % per år, utom för mejeri som minskar med 0.5 % per år
LONGRUN1 = yes;
* yes = prisförändringar aktiverade (kräver LONGRUN = yes)
LONGRUN2 = yes;
* yes = produktivitetsutveckling aktiverad

* - Expansion av ekologisk produktion
* När LONGRUN = no spärras expansion av ekologisk produktion till basårets nivåer. Detta reglage spärrar även vid LONGRUN = yes.
* Gäller både växtodling och djur.
organicExp = yes;
* yes = omställning till ekologiskt tillåten (kräver LONGRUN = yes; ignoreras annars)
* no  = ekologisk andel spärrad vid basårsnivå även i långsiktsanalys


*===============================================================================
* 3. SPECIALMODULER
*===============================================================================
* - Importbegränsningsmodul
$setGlobal tradeReduction no
* yes = kör Trade_reduction.gms efter lösning (begränsar import av spannmål och mejeriprodukter)


*===============================================================================
* 4. MAKROPARAMETRAR
*===============================================================================
* - Växelkurs SEK/EUR
KURS = 11.2;

* - Konsumentprisindex
KPI  = 1.267;
** förändring från basår
KPI2 = 1.034;
** förändring från 2023
KPI3 = 1.248;
** räknar om alla priser från basår till 2024 års penningvärde

* - Växthusgasutsläpp i handlade varor
CO2IMP = no;
** yes = inkluderar utsläpp inbäddade i importerade insatsvaror och produkter

* - Reduktionsfaktor för handel och transport
* RED = 1.00;


*===============================================================================
* 5. MIKROPARAMETRAR
*===============================================================================
* Avkastning per hektar ökar över tid. Grundnivå: 1.005
prodGrowthYields = 1.005;

* Faktorproduktiviteten ökar över tid.
* Grundnivåer:
** Inputs: 0.995
** Arbetskraft: 0.985
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
* Eco-scheme 3: precisionsjordbruk. Basvärde: 25 EUR
supportPct('ES3') = 0;
supportAdd('ES3') = 0;
* Eco-scheme 4: fånggröda. Basvärde: 128 EUR
supportPct('ES4') = 0;
supportAdd('ES4') = 0;
* Eco-scheme 5: mellansgröda. Basvärde: 147 EUR
supportPct('ES5') = 0;
supportAdd('ES5') = 0;
* Eco-scheme 6: vårplöjning. Basvärde: 69 EUR
supportPct('ES6') = 0;
supportAdd('ES6') = 0;
* Stöd för ekologisk produktion. Basvärde: 1000 EUR
supportPct('ECOSUB') = 0;
supportAdd('ECOSUB') = 0;
* Stöd för vallproduktion. Basvärde: 500 SEK
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

* - Kompensationsstöd för naturliga begränsningar (ANC)
*supportPct('COMPSUB') = 0;
*supportAdd('COMPSUB') = 0;
*supportPct('COMPSUBL') = 0;
*supportAdd('COMPSUBL') = 0;
* (Arealbegränsning på COMPSUBL: 1000 stödenheter)
*supportPct('COMPSUBF') = 0;
*supportAdd('COMPSUBF') = 0;
*supportPct('COMP4SUB') = 0;
*supportAdd('COMP4SUB') = 0;

* -- Nationellt stöd
* Nationellt stöd för mindre gynnade områden. Basvärde: 1
supportPct('NATSUB') = 0;
supportAdd('NATSUB') = 0;


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
