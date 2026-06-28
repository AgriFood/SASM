$ontext
    scenario file for sasm

$offtext


* --- This file is included in the main sasm file and contains settings for the scenario to be run. It is read in at the beginning of the main file, before any calculations are done. This allows you to easily change settings for different scenarios without having to edit the main file.

* --- Define which folder to store results in
$setGlobal resultFolder output

* --- Give results a name
$setGlobal scenarioName baseline