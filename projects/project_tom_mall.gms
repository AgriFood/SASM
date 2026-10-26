*===============================================================================
* PROJEKTFIL
*===============================================================================
* Projekt:       <namn>
* Ansvarig:      <namn>
* Datum:         <ÅÅÅÅ-MM-DD>
* Modellversion: <commit eller datum för main som filen kördes mot>
*
* Körs med: gams SASM2025.gms --projectFile=project --activeScenario=<nr>
*
* Scenarier i denna fil:
*   0  <scenarioName>   <kort beskrivning>
*   1  <scenarioName>   <kort beskrivning>
*
* Användning:
* - Kopiera denna mall till project.gms i modellens rotkatalog och fyll i ovan.
* - Före PR: flytta project.gms till projects\<namn>.gms och ersätt project.gms
*   med en ny kopia av denna mall.
*
* Filen läses in två gånger av SASM2025.gms. Koden skrivs mellan $ifthen och
* $endif i rätt del. Kod utanför delarna körs båda gångerna.
* Deklarationer (Set, Parameter, Alias) får bara stå i en del, helst del 1.
*
* Om filen har flera scenarier: lägg varje scenario i ett eget block, t.ex.
*   $ifthen "%activeScenario%" == "1"
*   $setGlobal scenarioName mitt_scenario
*   ...
*   $endif
*===============================================================================


*===============================================================================
* DEL 1: EARLY (läses före 6.4)
* Ändringar av indata: BIS/BIN/BPN MAX, QBAR, PBAR, ELAS, EAS m.m.
* SLOPE, INTERCEPT och variabelgränser räknas ut automatiskt efteråt.
*===============================================================================
$ifthen "%projectStage%" == "early"

$endif


*===============================================================================
* DEL 2: LATE (läses efter 6.5, före MODEL/SOLVE)
* Variabelgränser (.fx/.up/.lo) och egna SLOPE/INTERCEPT.
* OBS: ändras MAX/QBAR här måste SLOPE, INTERCEPT och .up räknas om för hand.
*===============================================================================
$ifthen "%projectStage%" == "late"

$endif
