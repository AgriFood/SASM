*===============================================================================
* PROJECT FILE
*===============================================================================
* Project:       <name>
* Responsible:   <name>
* Date:          <YYYY-MM-DD>
* Model version: <commit or date of main that the file was run against>
*
* Run with: gams SASM2025.gms --projectFile=project --activeScenario=<nr>
*
* Scenarios in this file:
*   0  <scenarioName>   <short description>
*   1  <scenarioName>   <short description>
*
* Own result folder (optional, default is output):
* $setGlobal resultFolder output\<project_name>
*
* Usage:
* - Copy this template to project.gms in the model root folder and fill in above.
* - Before the PR: move project.gms to projects\<name>.gms and replace project.gms
*   with a new copy of this template.
*
* The file is read twice by SASM2025.gms. Write the code between $ifthen and
* $endif in the right part. Code outside the parts runs both times.
* Declarations (Set, Parameter, Alias) may only appear in one part, preferably part 1.
*
* If the file has several scenarios, put each scenario in its own block, e.g.
*   $ifthen "%activeScenario%" == "1"
*   $setGlobal scenarioName my_scenario
*   ...
*   $endif
*===============================================================================


*===============================================================================
* PART 1: EARLY (read before 6.4)
* Changes to input data: BIS/BIN/BPN MAX, QBAR, PBAR, ELAS, EAS etc.
* SLOPE, INTERCEPT and variable bounds are calculated automatically afterwards.
*===============================================================================
$ifthen "%projectStage%" == "early"

$endif


*===============================================================================
* PART 2: LATE (read after 6.5, before MODEL/SOLVE)
* Variable bounds (.fx/.up/.lo) and own SLOPE/INTERCEPT.
* NOTE: if MAX/QBAR are changed here, SLOPE, INTERCEPT and .up must be
* recalculated by hand.
*===============================================================================
$ifthen "%projectStage%" == "late"

$endif
