## ============================================================
## Kategorier: mappning från produkt/aktivitet/input -> typ
## Läses in i huvudskriptet histosol_resultat.R med source("analysis/kategorier.R")
##
## Antaganden (RÄTTA om fel!):
##   E-prefix  = ekologisk  (EMILK, EW-WHEAT ...) -> kategoriseras efter bas
##   C-suffix  = konsumtion (BEEFC, FRUITC ...)
##   ...SUB    = stöd/utbetalning
##   MAX/MIN   = modellbegränsningar (constraint)
##   ME...     = metabolisk energi / foderbehov (satt till feed - KOLLA)
##   MIN... (produkter) = osäkra, satta till "other"
## ============================================================

# --- PRODUCTS ---
produkt_typ <- c(
  # Spannmål & fältgrödor (crop)
  BREADGRAIN = "crop",  COARSGRAIN = "crop",  ENERBGR    = "crop",
  ENERCGR    = "crop",  PEAS       = "crop",  EPEAS      = "crop",
  OILGRAIN   = "crop",  ENEROILG   = "crop",  POTATOES   = "crop",
  SUGARBEET  = "crop",  OTHRCROPPR = "crop",  ICRPR      = "crop",
  FRUIT      = "crop",  VEGETAB    = "crop",  WBERRY     = "crop",
  EGRAIN     = "crop",  ERAPE      = "crop",  EPOTATOES  = "crop",
  MINSALIX   = "crop",
  # Foder (feed)
  FEEDGRAIN  = "feed",  FPEAS      = "feed",  USEPASTR   = "feed",
  SILAGE     = "feed",  SILAGEHQ   = "feed",  HAY        = "feed",
  GRASSPASTR = "feed",  GRASSPASTF = "feed",  ESILAGE    = "feed",
  ESILAGEHQ  = "feed",  EGRASSPAST = "feed",  EGRASSPASF = "feed",
  RAPEMEAL   = "feed",  RAPSKAKA   = "feed",
  # Förädlat (processed)
  RAPEOIL    = "processed",
  WHITESUGAR = "processed", SKIMMILK = "processed", MILKFAT   = "processed",
  KMILK      = "processed", CHEESE   = "processed", BUTTER    = "processed",
  CREAM      = "processed", DRYMILK  = "processed", DRYMILK2  = "processed",
  BEEF       = "processed", PORK     = "processed", PLTRYMEAT = "processed",
  WILDMEAT   = "processed", FISH     = "processed", EBEEF     = "processed",
  EPORK      = "processed", ESHEEPM  = "processed",
  # Djur & animalieproduktion (livestock)
  MILK     = "livestock", DCALFM    = "livestock", DCALFF    = "livestock",
  DHEIFER  = "livestock", PIGLETS   = "livestock", GILTS     = "livestock",
  EDCALFM  = "livestock", EDCALFF   = "livestock", EDHEIFER  = "livestock",
  SLGHBEEF = "livestock", SLGHPORK  = "livestock", SLGHPLTRY = "livestock",
  SLGHSHEEP= "livestock", EGG       = "livestock", RIDING    = "livestock",
  EMILK    = "livestock", EEGG      = "livestock",
  # Näringsinnehåll (nutrient)
  ENERGY = "nutrient", PROTEIN = "nutrient", PROTEINA = "nutrient",
  FAT    = "nutrient", CARBOH  = "nutrient",
  # Konsumtion (consumption, C-suffix)
  BREADGRC  = "consumption", COARSGRC  = "consumption", FLOURC    = "consumption",
  RAPEOILC  = "consumption", POTATOESC = "consumption", SUGARC    = "consumption",
  SHEEPC    = "consumption", EGGC      = "consumption", KMILKC    = "consumption",
  CHEESEC   = "consumption", BUTTERC   = "consumption", CREAMC    = "consumption",
  DRYMILKC  = "consumption", BEEFC     = "consumption", PORKC     = "consumption",
  PLTRYMEATC= "consumption", WILDMEATC = "consumption", FISHC     = "consumption",
  VEGETABC  = "consumption", FRUITC    = "consumption", WBERRYC   = "consumption",
  FLOUR     = "consumption",
  # Stöd & utbetalningar (payment)
  ECOSUB    = "payment", GACRSUB    = "payment", COMP4SUB  = "payment",
  FORSUB    = "payment", CATTLESUB  = "payment", SOWHLTSUB = "payment",
  NATSUB    = "payment", COMPSUB    = "payment", COMPSUBL  = "payment",
  ES3       = "payment", ES4        = "payment", ES5       = "payment",
  ES6       = "payment",
  BIODIVSUBL= "payment", BIODIVSUBH = "payment", BIODIVSUB = "payment",
  BIODIVSUB2= "payment", BIODIVSUB3 = "payment", BIODIVSUBA= "payment",
  BIODIVSUBF= "payment", BIODIVSUBM = "payment", BIODIVSUBG= "payment",
  BIODIVSUBC= "payment", BIODIVSUBS = "payment",
  # Osäkra / övrigt (other) - KOLLA!
  CBONDING = "other", DPTRANR = "other", MISCRCPT = "other",
  UNDEFUSE = "other", MINSHEEP = "other", MINDCOW  = "other",
  MINBCOW  = "other",  MINLFOR  = "other", MINPAST  = "other",
  MINPASTN = "other",  MINKONVM = "other"
)

# --- ACTIVITIES ---
aktivitet_typ <- c(
  # Grödor (crop)
  "W-WHEAT"="crop", "W-RAY"="crop", "W-BARLEY"="crop", BARLEY="crop",
  OATS="crop", "W-RAPE"="crop", "S-RAPE"="crop", POTATO="crop",
  SUGAR="crop", SALIX="crop", OTHERCROPS="crop", ENFIX="crop",
  CROPTOPAST="crop",
  "EW-WHEAT"="crop", EBARLEY="crop", EOATS="crop", "EW-RAPE"="crop",
  "ES-RAPE"="crop", EPOTATO="crop", EOTHRCROPS="crop",
  SPAREFOR="crop", ICR="crop", NOUSE="crop",
  # Foder (feed)
  FEEDPEASH="feed", FORAGE1="feed", FORAGE3="feed", FORAGE4="feed",
  LAY="feed", LONGLAY="feed", EFEEDPEAS="feed", EFORAGE1="feed",
  EFORAGE3="feed", ELAY="feed",
  PASTURE1="feed", PASTURE2="feed", EPASTURE1="feed", EPASTURE2="feed",
  # Bete (pasture)
  PPASTR="pasture", PPASTRB="pasture", PPASTRT="pasture", PPASTRN="pasture",
  PPASTRH="pasture", PPASTRHB="pasture", PPASTRHT="pasture", PPASTRHN="pasture",
  PPASTRALV="pasture", PPASTRFOR="pasture", PPASTRMOS="pasture", PPASTRLOW="pasture",
  PPASTRCHAL="pasture", PPASTRMEAD="pasture", UPGRPAST="pasture", UPGRPASTH="pasture",
  SPAPASTR="pasture", SPAPASTRT="pasture", SPAPASTRH="pasture", SPAPASTRHT="pasture",
  # Djur (livestock)
  DCOW1="livestock", DCOW2="livestock", DCOW3="livestock", DCOW4="livestock",
  HEIFER="livestock", DAIRYBULL1="livestock", SLGHHEIFER="livestock",
  BEEFCATTLE="livestock", SHEEP="livestock", SOW1="livestock", GILT="livestock",
  SLGHSWINE1="livestock", POULTRY="livestock", CHICKEN="livestock",
  EDCOW1="livestock", EDCOW2="livestock", EDCOW3="livestock", EHEIFER="livestock",
  EDBULL1="livestock", EDBULL2="livestock", ESLGHHEIF="livestock",
  EBEEFCATT="livestock", EBEEFCAT2="livestock", ESHEEP="livestock",
  ECOPIG="livestock", EPOULTRY="livestock", HORSES="livestock",
  # Byggnader (building) - FEXR/FEXN
  DAIRYFEXR="building", DAIRYFEXN="building", BULLFEXR="building",
  BULLFEXN="building", BEEFCFEXR="building", SOWFEXR="building",
  SOWFEXN="building", SWINEFEXR="building", SWINEFEXN="building",
  PLTRYFEXR="building", PLTRYFEXN="building", CHICKFEXR="building",
  # Skötsel/åtgärder (management)
  MAKEHAY="management", SPRINGTILL="management", ESPRINGTIL="management",
  USEMANURE="management", COVERCROP="management", CATCHCROP="management",
  ECOVERCROP="management", ECATCHCROP="management",
  # Övrigt (other)
  FGFORSIL="other", LVSTKIN="other", LVSTKOUT="other",
  useHistCrop="other", useHistPast="other"
)

# --- INPUTS ---
input_typ <- c(
  # Mark (land)
  CROPLAND="land", PRMPAST="land", PRMPASTT="land", PRMPASTN="land",
  PRMPASTH="land", PRMPASTHT="land", PRMPASTHN="land", PRMALV="land",
  PRMFOR="land", PRMMOS="land", PRMLOW="land", PRMCHAL="land",
  PRMMEAD="land", PRMPASTUP="land", PRMPASTHUP="land", histCropArea="land",
  histPastArea="land", ACRECO="land",
  # Arealkostnader (cost)
  ACRCOSTP="cost", ACRCOSTPT="cost", ACRCOSTPN="cost", ACRCOSTPH="cost",
  ACRCOSTPHT="cost", ACRCOSTPHN="cost", ACRCOSTALV="cost", ACRCOSTFOR="cost",
  ACRCOSTMOS="cost", ACRCOSTLOW="cost", ACRCOSTCHA="cost", ACRCOSTMEA="cost",
  OTHRVARCST="cost", PCOST="cost", MISCCOST="cost",
  INCONVCOV="cost", INCONVCAT="cost", INCONVLAT="cost",
  INCONVECOV="cost", INCONVECAT="cost", INCONVELAT="cost",
  # Förädlings-/anläggningskapacitet (capacity)
  PCAPKMILK="capacity", PCAPCHEESE="capacity", PCAPBUTTER="capacity",
  PCAPDRYMLK="capacity", PCAPBEEF="capacity", PCAPPORK="capacity",
  PCAPPLTRY="capacity", PCAPMILL="capacity", PCAPFEED="capacity",
  PCAPPOTS="capacity",
  DAIRYFAC="capacity", DAIRYFACR="capacity", BULLFAC="capacity",
  BULLFACR="capacity", BEEFCFAC="capacity", BEEFCFACR="capacity",
  SOWFAC="capacity", SOWFACR="capacity", SWINEFAC="capacity",
  SWINEFACR="capacity", PLTRYFAC="capacity", PLTRYFACR="capacity",
  CHICKFAC="capacity", CHICKFACR="capacity", HORSEFAC="capacity",
  SHEEPFAC="capacity",
  # Produktionsmedel (inputs)
  CAPITAL="inputs", LABOR="inputs", LABOR2="inputs",
  POWER="inputs", DIESEL="inputs",
  NITROGEN="inputs", PHOSPHORUS="inputs", POTASSIUM="inputs",
  ECON="inputs", ECOP="inputs", ECOK="inputs",
  PESTICIDES="inputs", HERBICIDES="inputs", GLYFOSAT="inputs",
  FUNGICIDES="inputs", INSECTICID="inputs",
  PLASTIC="inputs",
  GRAINSEED="inputs", OILGRSEED="inputs", PEASSEED="inputs", POTATOSEED="inputs",
  SUGARBSEED="inputs",
  # Foder (feed)
  SOJA="feed", BETFOR="feed", HPMASSA="feed", PROTFEED="feed",
  OTHERFEED="feed",
  # Utsläpp & läckage (emission)
  NLEAKAGE="emission", PLEAKAGE="emission", CO2="emission", CH4="emission",
  N2O="emission", CO2EQ="emission", NH3="emission",
  # Begränsningar (constraint, MAX/MIN m.fl.)
  SUGARQUOTA="constraint",
  MAXWHEAT="constraint", MAXWWHEAT="constraint", MAXWRAY="constraint",
  MAXOILG="constraint", MAXWOILG="constraint", MAXPEAS="constraint",
  MAXPOTATO="constraint", MAXPOTACR="constraint", MAXSUGAR="constraint",
  MINNEWFOR="constraint", MAXLATE="constraint", MAXSALIX="constraint",
  MAXEWHEAT="constraint", MAXEWWHEAT="constraint", MAXEWRAY="constraint",
  MAXEOILG="constraint", MAXEWOILG="constraint", MAXEPEAS="constraint",
  MAXEPOTATO="constraint", MAXESUGAR="constraint", MINENEWFOR="constraint",
  MAXELATE="constraint", MAXMANURE="constraint", MINSILAGE="constraint",
  MAXCRTOPST="constraint", LVSTKBAL1="constraint", LVSTKBAL2="constraint",
  MAXREIND="constraint", MAXWILDM="constraint", MAXFISH="constraint",
  MAXFRUIT="constraint", MAXVEGET="constraint", MAXWBERRY="constraint",
  MEDCOW="constraint", MEBEEFCATT="constraint", MESHEEP="constraint",
  MECOPIG="constraint", MEPOULTRY="constraint",
  # Övrigt (other) - KOLLA!
  YIELDRIRE1="other", YIELDRIRE2="other", YIELDRIRE3="other",
  ACRMANURE="other", DPTRANC="other"
)