* ======================================================================
* HISTOSOL LAND SCENARIOS
* ======================================================================
* 40 % of agricultural histosol area taken out of production.
*
* Usage (GAMS command line):
*   --SCENARIO=1   Proportional reduction in every subregion
*   --SCENARIO=2   Economically optimal: global area constraint lets
*                  the model idle land where opportunity cost is lowest
*
* Default (no --SCENARIO argument): baseline, no modification.
* ======================================================================

$if not set SCENARIO $set SCENARIO 1    
$ifi %SCENARIO%==0 $goto end_scenarios

SET HISTIS(IS) 'Histosol land types'
  / histCropland,
    histPermPasture, histPermPastTopSup, histPermPastN2k,
    histPermPastProd, histPermPastProdTopSup, histPermPastProdN2k,
    histPermMeadow, histPermChalet /;

$ifi %SCENARIO%==1 $goto scen1
$ifi %SCENARIO%==2 $goto scen2
$goto end_scenarios

* ----------------------------------------------------------------------
$label scen1
* Scenario 1: Proportional 40 % reduction in every subregion
* ----------------------------------------------------------------------
BISF(R,SR,HISTIS)$RSR(R,SR)        = BISF(R,SR,HISTIS) * 0.6;
BIS(R,SR,HISTIS,'MAX')$RSR(R,SR)   = BISF(R,SR,HISTIS);

* Update HORSES lower bound which depends on histCropland area
PRODSR.LO(R,SR,'HORSES')$RSRAS(R,SR,'HORSES') =
    (BISF(R,SR,'CROPLAND') + BISF(R,SR,'histCropland')) * 0.1;

SOLVE SASM USING NLP MAXIMIZING Z;
$goto end_scenarios

* ----------------------------------------------------------------------
$label scen2
* Scenario 2: Economically optimal global reduction
* A single global constraint on total histosol use allows the model to
* concentrate the reduction where opportunity cost is lowest.
* ----------------------------------------------------------------------
SCALAR TOTAL_HIST_AREA 'Total histosol agricultural area (1000 ha)';
TOTAL_HIST_AREA = SUM((R,SR)$RSR(R,SR), SUM(HISTIS, BISF(R,SR,HISTIS)));

EQUATION HISTLIM 'Global histosol use at most 60 pct of original area';
HISTLIM..
    SUM((R,SR,HISTIS)$RSR(R,SR),
        SUM(AS$RSRAS(R,SR,AS), EAS(R,SR,AS,HISTIS) * PRODSR(R,SR,AS))
    ) =L= 0.6 * TOTAL_HIST_AREA;

MODEL SASM_SCEN2 /ALL/;
SOLVE SASM_SCEN2 USING NLP MAXIMIZING Z;

$label end_scenarios
