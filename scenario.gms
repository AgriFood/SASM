$ontext
    Scenario file for SASM_scen-histosol.

    Change activeScenario below to select which scenario to run:
      0   hist_baseline   No changes. Exports shadow prices for use in Scenarios 2 and 4.
      1   hist_rewet      Proportional rewetting per subregion based on histFrac.
      2   hist_rewet_opt  Greedy rewetting using shadow prices from hist_baseline GDX.
                          Requires Scenario 0 to have been run first.
      3   hist_convert    Proportional conversion of histosol cropland to PRMPASTH.
                          Target: 30% of histosol UAA per subregion.
      4   hist_convert_opt Greedy conversion of cheapest histosol cropland to PRMPASTH.
                          Target: 30% of total national histosol UAA.
                          Requires Scenario 0 to have been run first.

    Mapping from histFrac types to BIS land types:
      histCropland    -> CROPLAND
      histPermPasture -> PRMPAST, PRMPASTT, PRMPASTN, PRMPASTH, PRMPASTHT, PRMPASTHN
      histPermChalet  -> PRMCHAL
      histPermMeadow  -> PRMMEAD
      histUAA         -> share of total UAA that is histosol per subregion

$offtext

* --- Select active scenario: 0, 1, 2, 3, or 4 (can be overridden from command line: gams SASM2025.gms --activeScenario=0)
$if not defined activeScenario $setGlobal activeScenario 4

* --- Define which folder to store results in
$setGlobal resultFolder output

*======================================================================
* SCENARIO 0: Baseline
*======================================================================
$ifthen "%activeScenario%" == "0"

$setGlobal scenarioName hist_baseline

* No changes to BIS - pure baseline.
* Shadow prices are exported in report.gms for use in Scenarios 2 and 4.

$endif


*======================================================================
* SCENARIO 1: Proportional rewetting (hist_rewet)
*======================================================================
$ifthen "%activeScenario%" == "1"

$setGlobal scenarioName hist_rewet

* Reduction rates per histosol land type (0 = no reduction, 1 = remove all histosol area)
Parameter histRed1 "Fraction of histosol area to remove, by land type" /
    histCropland     0.3
    histPermPasture  0.3
    histPermChalet   0.3
    histPermMeadow   0.3
/;

BIS(R,SR,"CROPLAND",'MAX')$RSR(R,SR) =
    max(0, BIS(R,SR,"CROPLAND",'MAX') * (1 - histRed1("histCropland")   * histFrac(SR,"histCropland")));

BIS(R,SR,"PRMPAST",'MAX')$RSR(R,SR) =
    max(0, BIS(R,SR,"PRMPAST",'MAX')  * (1 - histRed1("histPermPasture") * histFrac(SR,"histPermPasture")));

BIS(R,SR,"PRMPASTT",'MAX')$RSR(R,SR) =
    max(0, BIS(R,SR,"PRMPASTT",'MAX') * (1 - histRed1("histPermPasture") * histFrac(SR,"histPermPasture")));

BIS(R,SR,"PRMPASTN",'MAX')$RSR(R,SR) =
    max(0, BIS(R,SR,"PRMPASTN",'MAX') * (1 - histRed1("histPermPasture") * histFrac(SR,"histPermPasture")));

BIS(R,SR,"PRMPASTH",'MAX')$RSR(R,SR) =
    max(0, BIS(R,SR,"PRMPASTH",'MAX') * (1 - histRed1("histPermPasture") * histFrac(SR,"histPermPasture")));

BIS(R,SR,"PRMPASTHT",'MAX')$RSR(R,SR) =
    max(0, BIS(R,SR,"PRMPASTHT",'MAX')* (1 - histRed1("histPermPasture") * histFrac(SR,"histPermPasture")));

BIS(R,SR,"PRMPASTHN",'MAX')$RSR(R,SR) =
    max(0, BIS(R,SR,"PRMPASTHN",'MAX')* (1 - histRed1("histPermPasture") * histFrac(SR,"histPermPasture")));

BIS(R,SR,"PRMCHAL",'MAX')$RSR(R,SR) =
    max(0, BIS(R,SR,"PRMCHAL",'MAX')  * (1 - histRed1("histPermChalet")  * histFrac(SR,"histPermChalet")));

BIS(R,SR,"PRMMEAD",'MAX')$RSR(R,SR) =
    max(0, BIS(R,SR,"PRMMEAD",'MAX')  * (1 - histRed1("histPermMeadow")  * histFrac(SR,"histPermMeadow")));

$endif


*======================================================================
* SCENARIO 2: Greedy rewetting using baseline shadow prices (hist_rewet_opt)
* Requires Scenario 0 (hist_baseline) to have been run first.
*======================================================================
$ifthen "%activeScenario%" == "2"

$setGlobal scenarioName hist_rewet_opt

* Share of total national histosol area to remove (0 = none, 1 = all)
Scalar histRedNat2 "National histosol reduction rate" / 0.3 /;

* Load land prices from baseline run (requires Scenario 0 to have been run first)
Parameter landPrice_baseline(R,SR,IS) "Land prices from hist_baseline run (1000 SEK/ha, from RTBL7)";
execute_load "output\hist_baseline_shadowprices.gdx", landPrice_baseline=shadowPricesIS;

Parameter histAvail2(R,SR,IS) "Available histosol area per land type (thousand ha)";
Parameter histPrice2(R,SR,IS) "Land price per histosol location from baseline";
Parameter histElim2(R,SR,IS)  "Histosol area to eliminate (thousand ha)";
Parameter allocated2(R,SR,IS) "1 if location fully allocated in greedy algorithm";
Scalar totalHist2, remaining2, minPrice2;

Set iter2 /i1*i500/;

* Compute available histosol area
histAvail2(R,SR,"CROPLAND")$RSR(R,SR)  = histFrac(SR,"histCropland")   * BIS(R,SR,"CROPLAND",'MAX');
histAvail2(R,SR,"PRMPAST")$RSR(R,SR)   = histFrac(SR,"histPermPasture") * BIS(R,SR,"PRMPAST",'MAX');
histAvail2(R,SR,"PRMPASTT")$RSR(R,SR)  = histFrac(SR,"histPermPasture") * BIS(R,SR,"PRMPASTT",'MAX');
histAvail2(R,SR,"PRMPASTN")$RSR(R,SR)  = histFrac(SR,"histPermPasture") * BIS(R,SR,"PRMPASTN",'MAX');
histAvail2(R,SR,"PRMPASTH")$RSR(R,SR)  = histFrac(SR,"histPermPasture") * BIS(R,SR,"PRMPASTH",'MAX');
histAvail2(R,SR,"PRMPASTHT")$RSR(R,SR) = histFrac(SR,"histPermPasture") * BIS(R,SR,"PRMPASTHT",'MAX');
histAvail2(R,SR,"PRMPASTHN")$RSR(R,SR) = histFrac(SR,"histPermPasture") * BIS(R,SR,"PRMPASTHN",'MAX');
histAvail2(R,SR,"PRMCHAL")$RSR(R,SR)   = histFrac(SR,"histPermChalet")  * BIS(R,SR,"PRMCHAL",'MAX');
histAvail2(R,SR,"PRMMEAD")$RSR(R,SR)   = histFrac(SR,"histPermMeadow")  * BIS(R,SR,"PRMMEAD",'MAX');

* Land prices from RTBL7 are already positive
histPrice2(R,SR,IS)$(histAvail2(R,SR,IS) > 0) = landPrice_baseline(R,SR,IS);

* National target
totalHist2 = SUM((R,SR,IS)$RSR(R,SR), histAvail2(R,SR,IS));
remaining2 = histRedNat2 * totalHist2;

* Greedy algorithm: remove cheapest histosol first
histElim2(R,SR,IS)  = 0;
allocated2(R,SR,IS) = 0;

Loop(iter2$(remaining2 > 1e-6),
    minPrice2 = Smin((R,SR,IS)$(histAvail2(R,SR,IS) > 0 AND NOT allocated2(R,SR,IS)), histPrice2(R,SR,IS));
    Loop((R,SR,IS)$(histPrice2(R,SR,IS) = minPrice2 AND NOT allocated2(R,SR,IS) AND remaining2 > 1e-6),
        if(histAvail2(R,SR,IS) <= remaining2,
            histElim2(R,SR,IS) = histAvail2(R,SR,IS);
            remaining2 = remaining2 - histAvail2(R,SR,IS);
        else
            histElim2(R,SR,IS) = remaining2;
            remaining2 = 0;
        );
        allocated2(R,SR,IS) = 1;
    );
);

* Apply reductions
BIS(R,SR,IS,'MAX')$(histElim2(R,SR,IS) > 0) = max(0, BIS(R,SR,IS,'MAX') - histElim2(R,SR,IS));

$endif


*======================================================================
* SCENARIO 3: Proportional conversion of histosol cropland to PRMPASTH (hist_convert)
* Target: 30% of histosol UAA per subregion, converted from cropland.
* Capped at available histosol cropland per subregion.
*======================================================================
$ifthen "%activeScenario%" == "3"

$setGlobal scenarioName hist_convert

* Share of total histosol UAA to convert per subregion
Scalar histRedNat3 "Share of total histosol UAA to convert (cropland -> PRMPASTH)" / 0.3 /;

* Total agricultural land and histosol target per subregion
Parameter totalUAA3(SR) "Total agricultural land per subregion (thousand ha)";
totalUAA3(SR) = SUM((R,IS)$(RSR(R,SR) AND LAND(IS)), BIS(R,SR,IS,'MAX'));

Parameter histTargetSR3(SR) "Histosol area to convert per subregion (thousand ha)";
histTargetSR3(SR) = histRedNat3 * histFrac(SR,"histUAA") * totalUAA3(SR);

* Actual conversion: capped at available histosol cropland per subregion
Parameter histCropConv3(R,SR) "Histosol cropland area to convert (thousand ha)";
histCropConv3(R,SR)$RSR(R,SR) =
    min(histFrac(SR,"histCropland") * BIS(R,SR,"CROPLAND",'MAX'),
        histTargetSR3(SR));

* Remove from cropland
BIS(R,SR,"CROPLAND",'MAX')$RSR(R,SR) =
    max(0, BIS(R,SR,"CROPLAND",'MAX') - histCropConv3(R,SR));

* Add to high-production permanent pasture and update cost bound accordingly
BIS(R,SR,"PRMPASTH",'MAX')$RSR(R,SR) =
    BIS(R,SR,"PRMPASTH",'MAX') + histCropConv3(R,SR);
BIS(R,SR,"ACRCOSTPH",'QBAR')$RSR(R,SR) =
    BIS(R,SR,"ACRCOSTPH",'QBAR') + histCropConv3(R,SR);

$endif


*======================================================================
* SCENARIO 4: Greedy conversion of cheapest histosol cropland to PRMPASTH (hist_convert_opt)
* Target: 30% of total national histosol UAA, selecting lowest shadow price first.
* Requires Scenario 0 (hist_baseline) to have been run first.
*======================================================================
$ifthen "%activeScenario%" == "4"

$setGlobal scenarioName hist_convert_opt

* Share of total national histosol UAA to convert
Scalar histRedNat4 "Share of total national histosol UAA to convert (cropland -> PRMPASTH)" / 0.3 /;

* Load land prices from baseline run
Parameter landPrice_baseline4(R,SR,IS) "Land prices from hist_baseline run (1000 SEK/ha, from RTBL7)";
execute_load "output\hist_baseline_shadowprices.gdx", landPrice_baseline4=shadowPricesIS;

* Total agricultural land per subregion and national histosol target
Parameter totalUAA4(SR) "Total agricultural land per subregion (thousand ha)";
totalUAA4(SR) = SUM((R,IS)$(RSR(R,SR) AND LAND(IS)), BIS(R,SR,IS,'MAX'));

Scalar totalHistTarget4 "National histosol conversion target (thousand ha)";
totalHistTarget4 = SUM(SR, histRedNat4 * histFrac(SR,"histUAA") * totalUAA4(SR));

* Available histosol cropland and its shadow price per (R,SR)
Parameter histAvailCrop4(R,SR) "Histosol cropland available (thousand ha)";
histAvailCrop4(R,SR)$RSR(R,SR) = histFrac(SR,"histCropland") * BIS(R,SR,"CROPLAND",'MAX');

Parameter histPrice4(R,SR) "Cropland shadow price from baseline (1000 SEK/ha)";
histPrice4(R,SR)$(histAvailCrop4(R,SR) > 0) = landPrice_baseline4(R,SR,"CROPLAND");

* Greedy algorithm: convert cheapest histosol cropland first
Parameter histElim4(R,SR) "Histosol cropland area to convert (thousand ha)";
Parameter allocated4(R,SR) "1 if location fully allocated in greedy algorithm";
Scalar remaining4, minPrice4;
Set iter4 /i1*i500/;

histElim4(R,SR)   = 0;
allocated4(R,SR)  = 0;
remaining4 = totalHistTarget4;

Loop(iter4$(remaining4 > 1e-6),
    minPrice4 = Smin((R,SR)$(histAvailCrop4(R,SR) > 0 AND NOT allocated4(R,SR)), histPrice4(R,SR));
    Loop((R,SR)$(histPrice4(R,SR) = minPrice4 AND NOT allocated4(R,SR) AND remaining4 > 1e-6),
        if(histAvailCrop4(R,SR) <= remaining4,
            histElim4(R,SR) = histAvailCrop4(R,SR);
            remaining4 = remaining4 - histAvailCrop4(R,SR);
        else
            histElim4(R,SR) = remaining4;
            remaining4 = 0;
        );
        allocated4(R,SR) = 1;
    );
);

* Apply conversion
BIS(R,SR,"CROPLAND",'MAX')$(histElim4(R,SR) > 0) =
    max(0, BIS(R,SR,"CROPLAND",'MAX') - histElim4(R,SR));
BIS(R,SR,"PRMPASTH",'MAX')$(histElim4(R,SR) > 0) =
    BIS(R,SR,"PRMPASTH",'MAX') + histElim4(R,SR);
BIS(R,SR,"ACRCOSTPH",'QBAR')$(histElim4(R,SR) > 0) =
    BIS(R,SR,"ACRCOSTPH",'QBAR') + histElim4(R,SR);

$endif
