*===============================================================================
* PROJECT FILE
*===============================================================================
* Project:       <name>
* Responsible:   <name>
* Date:          <YYYY-MM-DD>
* Model version: <commit or date of main that the file was run against>
*
* Run one scenario:  set projectFile and scenarioName in settings.gms, or
*                    gams SASM2025.gms --projectFile=project --scenarioName=<scenarioName>
* Run all scenarios: list the names in run_all_scenarios.bat and run it
*
* Scenarios in this file (the name is also the name of the result files):
*   <scenarioName>   <short description>
*   <scenarioName>   <short description>
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
* Each scenario has its own block, selected by the name. The block in part 1 must
* set scenarioFound, even if the scenario has no changes there:
*   $ifthen "%scenarioName%" == "my_scenario"
*   $setGlobal scenarioFound yes
*   ...
*   $endif
* scenarioFound marks that the scenario exists in this file; only whether it is set
* is checked, the value itself is not used. A run whose scenarioName matches no block
* stops with an error, so a misspelled name cannot run without the project changes.
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
