$ontext
    scenario file for sasm

    This scenario reduces the area of histosol by 50% in region SR020. This is done by reducing the maximum area of cropland in that region by the specified reduction rate multiplied by the area of histosol in that region. The results of this scenario will be stored in the "output" folder and will be named "histred50".

$offtext


* --- This file is included in the main sasm file and contains settings for the scenario to be run. It is read in at the beginning of the main file, before any calculations are done. This allows you to easily change settings for different scenarios without having to edit the main file.

* --- Define which folder to store results in
$setGlobal resultFolder output

* --- Give results a name
$setGlobal scenarioName histred50

* --- Define reduction rate for histosol
scalar histRed "Reduction rate for histosol" / 0.5 /;

* --- Data on amount of histosol in each region, in thousands of hectares.
parameter histArea(SR) "Area of histosol in each region, in thousands of hectares" /
    SR001   0
    SR002   0
    SR003   0
    SR004   0
    SR005   0
    SR006   0
    SR007   0
    SR008   0
    SR009   0
    SR010   0
    SR011   0
    SR012   0
    SR013   0
    SR014   0
    SR015   0
    SR016   0
    SR017   0
    SR018   0
    SR019   0
    SR020   20
    SR021   0
    SR022   0
    SR023   0
    SR024   0
    SR025   0
    SR026   0
    SR027   0
    SR028   0
    SR029   0
    SR030   0
    SR031   0
    SR032   0
    SR033   0
    SR034   0
    SR035   0
    SR036   0
    SR037   0
    SR038   0
    SR039   0
    SR040   0
    SR041   0
    SR042   0
    SR043   0
    SR044   0
    SR045   0
    SR046   0
    SR047   0
    SR048   0
    SR049   0
    SR050   0
    SR051   0
    SR052   0
    SR053   0
    SR054   0
    SR055   0
    SR056   0
    SR057   0
    SR058   0
    SR059   0
    SR060   0
    SR061   0
    SR062   0
    SR063   0
    SR064   0
    SR065   0
    SR066   0
    SR067   0
    SR068   0
    SR069   0
    SR070   0
    SR071   0
    SR072   0
    SR073   0
    SR074   0
    SR075   0
    SR076   0
    SR077   0
    SR078   0
    SR079   0
    SR080   0
    SR081   0     /;

* --- Reduce the area of histosol in each region by the specified reduction rate
BIS(R,SR,"CROPLAND",'MAX') = max(0, BIS(R,SR,"CROPLAND",'MAX') - histRed * histArea(SR));