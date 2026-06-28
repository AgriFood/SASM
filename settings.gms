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
* 3. Makroparametrar          Växelkurs, KPI och handelsfaktorer
* 4. Mikroparametrar          Produktivitetstillväxt och sektorsspecifika parametrar
* 5. Stödbetalningar          Justeringar av direktstöd och landsbygdsstöd
* 6. Utskriftskontroll        Vilka resultatblock som skrivs till lst och Excel
*===============================================================================


*===============================================================================
* 1. KÖRNINGSIDENTITET
*===============================================================================
* - Ge körningen ett namn (används som filnamn för resultatfiler)
$setGlobal scenarioName baseline
* - Ange resultatmapp (relativ sökväg från modellens rotkatalog)
$setGlobal resultFolder output


*===============================================================================
* 2. SIMULERINGSHORISONT
*===============================================================================
* - Välj simuleringsår
YEAR = 2025;
* Tidsparametrar beräknas i SASM2025.gms:
*   YR  = YEAR - 2025   (år från basår 2025)
*   YRA = YEAR - 2022   (år från basår för arealer, 2022)
*   YRT = YEAR - 2020   (år från basår för tekniska koefficienter, 2020)

* - Aktivera långsiktseffekter
LONGRUN  = no;
* LONGRUN = yes --> kortsiktsanalys med avskrivning av byggnader och investeringar
LONGRUN1 = yes;
* yes = prisförändringar aktiverade (kräver LONGRUN = yes)
LONGRUN2 = yes;
* yes = produktivitetsutveckling aktiverad


*===============================================================================
* 3. MAKROPARAMETRAR
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
RED = 1.00;


*===============================================================================
* 4. MIKROPARAMETRAR
*===============================================================================
prodGrowthYields = 1.005;
prodGrowthInputs = 0.995;
prodGrowthLabour = 0.985;
prodGrowthPower  = 0.985;


*===============================================================================
* 5. STÖDBETALNINGAR
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
* Skattereduktion på försäljning istället för dieselskatt
supportPct('FARMSUB') = 0;
supportAdd('FARMSUB') = 0;


*===============================================================================
* 6. UTSKRIFTSKONTROLL
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
* VARS         Alla variabelresultat                   (stor utskrift)
* EQNS         Alla ekvationsresultat                  (stor utskrift)
* DSETS        Dynamiska mängder                       (PNED, PNFD, PRED, PRFD, PSED, PSFD, INES, INFS, IRES, IRFS ...)
* PARAM        Alla parametrar                         (BIN, BIR, BIS, BISF, BISFA, BPN, BPR, BPS, BXR, BMR)
* PRODIO       Produktionsaktivitetskoefficienter      (EAS, ECR)
* CONST        Arealbegränsningar för grödor           (CONST)
* UTCOST       Enhetstransportkostnader                (CT, DT, UT)
* DATA         Gödsel, näring med mera                 (MANURE, NSUB, NUTRIENT, POP, DPTR, DPTC, MS)
