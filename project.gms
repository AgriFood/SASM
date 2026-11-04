*===============================================================================
* PROJEKTFIL
*===============================================================================
* Projekt:       Histosoler - återvätning och konvertering av jordbruksmark på histosoler
* Ansvarig:      Cecilia Larsson
* Datum:         2026-10-26
* Modellversion: se Git commit i <scenarioName>_settings.txt för varje körning
*
* Körs med: projectFile och scenarioName i settings.gms, eller
*           gams SASM2025.gms --projectFile=project --scenarioName=<namn>
*           eller run_all_scenarios.bat för alla scenarier i tur och ordning.
*
* Scenarier i denna fil:
*   baseline           Inga ändringar. Körs med OC('DUAL') = yes i settings, så att
*                      skuggpriserna skrivs till baseline_shadowprices.gdx för
*                      användning i rewet_opt, convert_opt och rewet_convert_opt.
*   rewet              Proportionell återvätning (30 %) per delregion baserat på histFrac.
*   rewet_opt          Greedy återvätning (30 %) med skuggpriser från baslinjen.
*                      Kräver att baseline har körts först.
*   convert            Proportionell åkermarkskonvertering (30 %) per delregion baserat på histFrac.
*   convert_opt        Greedy åkermarkskonvertering (30 %) med skuggpriser från baslinjen.
*                      Kräver att baseline har körts först.
*   rewet_convert      Proportionell återvätning (4,5 %) och åkermarkskonvertering (13,5 %).
*                      Målen beräknas på arealen innan återvätning. Totalt: 18 %.
*   rewet_convert_opt  Greedy återvätning (4,5 %) och greedy åkermarkskonvertering (13,5 %).
*                      Målen baseras på den nationella histosol-UAA:n innan återvätning.
*                      Kräver att baseline har körts först.
*
* Mappning från histFrac-typer till BIS-marktyper:
*   histCropland    -> CROPLAND
*   histPermPasture -> PRMPAST, PRMPASTT, PRMPASTN, PRMPASTH, PRMPASTHT, PRMPASTHN
*   histPermChalet  -> PRMCHAL
*   histPermMeadow  -> PRMMEAD
*   histUAA         -> andel av total UAA som är histosol per delregion
*
* Allt ligger i del 1 (early). SLOPE, INTERCEPT och variabelgränser räknas ut av
* modellen (6.4 och 6.5) från de ändrade MAX- och QBAR-värdena.
* ACRCOST-kurvorna för betesmark följer med via ACRIS_PAST i SASM2025.gms.
*===============================================================================

* Varje scenarioblock nedan sätter scenarioFound. SASM2025.gms stoppar körningen
* om scenarioName inte matchar något block.


*===============================================================================
* DEL 1: EARLY (läses före 6.4)
*===============================================================================
$ifthen "%projectStage%" == "early"

*======================================================================
* SCENARIO: Baslinje (baseline)
*======================================================================
$ifthen "%scenarioName%" == "baseline"
$setGlobal scenarioFound yes

* Inga ändringar i BIS - ren baslinje.

* Ta bort skuggpriser från en tidigare körning. Om OC('DUAL') inte är på skrivs ingen ny
* fil, och greedy-scenarierna stoppas då i stället för att använda gamla skuggpriser.
$if exist "%resultFolder%\baseline_shadowprices.gdx" $call 'del "%resultFolder%\baseline_shadowprices.gdx"'

$endif


*======================================================================
* SCENARIO: Proportionell återvätning (rewet)
*======================================================================
$ifthen "%scenarioName%" == "rewet"
$setGlobal scenarioFound yes

* Reduktionsandelar per histosol-marktyp (0 = ingen reduktion, 1 = ta bort all histosolareal)
Parameter histRed1 "Andel histosolareal att ta bort, per marktyp" /
    histCropland     0.3
    histPermPasture  0.3
    histPermChalet   0.3
    histPermMeadow   0.3
/;

BIS(R,SR,"CROPLAND",'MAX')$RSR(R,SR) =
    max(0, BIS(R,SR,"CROPLAND",'MAX') * (1 - histRed1("histCropland")   * histFrac(SR,"histCropland")));

* Reduktionsbeloppen för betesmarktyper beräknas mot markbasen innan POTPAST
* slogs ihop (BISF), inte mot den aktuella BIS MAX, som vid denna punkt redan
* inkluderar outnyttjad POTPAST-baserad marginal. Att skära en andel av denna uppblåsta
* MAX skulle delvis ta bort oanvänd kapacitet istället för verklig betesmark, med liten
* eller ingen effekt på den optimerade lösningen.
Parameter histRedAmt1(R,SR,IS) "Absolut markreduktion från återvätning (1000 ha)";
histRedAmt1(R,SR,"PRMPAST")  $RSR(R,SR) = BISF(R,SR,"PRMPAST")   * histRed1("histPermPasture") * histFrac(SR,"histPermPasture");
histRedAmt1(R,SR,"PRMPASTT") $RSR(R,SR) = BISF(R,SR,"PRMPASTT")  * histRed1("histPermPasture") * histFrac(SR,"histPermPasture");
histRedAmt1(R,SR,"PRMPASTN") $RSR(R,SR) = BISF(R,SR,"PRMPASTN")  * histRed1("histPermPasture") * histFrac(SR,"histPermPasture");
histRedAmt1(R,SR,"PRMPASTH") $RSR(R,SR) = BISF(R,SR,"PRMPASTH")  * histRed1("histPermPasture") * histFrac(SR,"histPermPasture");
histRedAmt1(R,SR,"PRMPASTHT")$RSR(R,SR) = BISF(R,SR,"PRMPASTHT") * histRed1("histPermPasture") * histFrac(SR,"histPermPasture");
histRedAmt1(R,SR,"PRMPASTHN")$RSR(R,SR) = BISF(R,SR,"PRMPASTHN") * histRed1("histPermPasture") * histFrac(SR,"histPermPasture");
histRedAmt1(R,SR,"PRMCHAL")  $RSR(R,SR) = BISF(R,SR,"PRMCHAL")   * histRed1("histPermChalet")  * histFrac(SR,"histPermChalet");
histRedAmt1(R,SR,"PRMMEAD")  $RSR(R,SR) = BISF(R,SR,"PRMMEAD")   * histRed1("histPermMeadow")  * histFrac(SR,"histPermMeadow");

BIS(R,SR,IS,'MAX')$(RSR(R,SR) AND histRedAmt1(R,SR,IS) > 0) =
    max(0, BIS(R,SR,IS,'MAX') - histRedAmt1(R,SR,IS));

* Parad ACRCOST-resurs (IS2) minskas lika mycket som betesmarken (IS)
BIS(R,SR,IS2,'MAX')$(RSR(R,SR) AND SUM(IS$ACRIS_PAST(IS2,IS), histRedAmt1(R,SR,IS)) > 0) =
    max(0, BIS(R,SR,IS2,'MAX') - SUM(IS$ACRIS_PAST(IS2,IS), histRedAmt1(R,SR,IS)));
BIS(R,SR,IS2,'QBAR')$(RSR(R,SR) AND SUM(IS$ACRIS_PAST(IS2,IS), histRedAmt1(R,SR,IS)) > 0) =
    max(0, BIS(R,SR,IS2,'QBAR') - SUM(IS$ACRIS_PAST(IS2,IS), histRedAmt1(R,SR,IS)));

* Uppdatera kvarvarande histosolareal efter återvätning
histArea(R,SR,'CROPLAND')$RSR(R,SR) =
    max(0, histArea(R,SR,'CROPLAND') * (1 - histRed1('histCropland')));
histArea(R,SR,IS)$(RSR(R,SR) AND histRedAmt1(R,SR,IS) > 0) =
    max(0, histArea(R,SR,IS) - histRedAmt1(R,SR,IS));

$endif


*======================================================================
* SCENARIO: Greedy återvätning med skuggpriser från baslinjen (rewet_opt)
* Kräver att baseline har körts först.
*======================================================================
$ifthen "%scenarioName%" == "rewet_opt"
$setGlobal scenarioFound yes

* Andel av total nationell histosolareal att ta bort (0 = ingen, 1 = all)
Scalar histRedNat2 "Nationell histosolreduktionsandel" / 0.3 /;

* Läs in markpriser från baslinjekörningen (kräver att baseline har körts först)
Parameter landPrice_baseline(R,SR,IS) "Markpriser från baslinjekörningen (1000 SEK/ha, från RTBL7)";
$if not exist "%resultFolder%\baseline_shadowprices.gdx" $abort "Skuggpriser saknas: kör baseline med OC('DUAL') = yes först"
execute_load "%resultFolder%\baseline_shadowprices.gdx", landPrice_baseline=shadowPricesIS;

Parameter histAvail2(R,SR,IS) "Tillgänglig histosolareal per marktyp (tusen ha)";
Parameter histPrice2(R,SR,IS) "Markpris per histosol-lokal från baslinjen";
Parameter histElim2(R,SR,IS)  "Histosolareal att eliminera (tusen ha)";
Parameter allocated2(R,SR,IS) "1 om lokalen är fullt allokerad i greedy-algoritmen";
Scalar totalHist2, remaining2, minPrice2;

Set iter2 /i1*i500/;

* Tillgänglig histosolareal för betesmarktyper beräknas mot markbasen innan POTPAST
* slogs ihop (BISF), inte mot den aktuella BIS MAX, som vid denna punkt redan inkluderar
* outnyttjad POTPAST-baserad marginal. CROPLAND påverkas inte av POTPAST-sammanslagningen
* och kan därför använda den aktuella MAX direkt.
histAvail2(R,SR,"CROPLAND")$RSR(R,SR)  = histFrac(SR,"histCropland")   * BIS(R,SR,"CROPLAND",'MAX');
histAvail2(R,SR,"PRMPAST")$RSR(R,SR)   = histFrac(SR,"histPermPasture") * BISF(R,SR,"PRMPAST");
histAvail2(R,SR,"PRMPASTT")$RSR(R,SR)  = histFrac(SR,"histPermPasture") * BISF(R,SR,"PRMPASTT");
histAvail2(R,SR,"PRMPASTN")$RSR(R,SR)  = histFrac(SR,"histPermPasture") * BISF(R,SR,"PRMPASTN");
histAvail2(R,SR,"PRMPASTH")$RSR(R,SR)  = histFrac(SR,"histPermPasture") * BISF(R,SR,"PRMPASTH");
histAvail2(R,SR,"PRMPASTHT")$RSR(R,SR) = histFrac(SR,"histPermPasture") * BISF(R,SR,"PRMPASTHT");
histAvail2(R,SR,"PRMPASTHN")$RSR(R,SR) = histFrac(SR,"histPermPasture") * BISF(R,SR,"PRMPASTHN");
histAvail2(R,SR,"PRMCHAL")$RSR(R,SR)   = histFrac(SR,"histPermChalet")  * BISF(R,SR,"PRMCHAL");
histAvail2(R,SR,"PRMMEAD")$RSR(R,SR)   = histFrac(SR,"histPermMeadow")  * BISF(R,SR,"PRMMEAD");

* Markpriser från RTBL7 är redan positiva
histPrice2(R,SR,IS)$(histAvail2(R,SR,IS) > 0) = landPrice_baseline(R,SR,IS);

* Nationellt mål
totalHist2 = SUM((R,SR,IS)$RSR(R,SR), histAvail2(R,SR,IS));
remaining2 = histRedNat2 * totalHist2;

* Greedy-algoritm: ta bort billigaste histosol först
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

* Tillämpa reduktioner
BIS(R,SR,IS,'MAX')$(histElim2(R,SR,IS) > 0) = max(0, BIS(R,SR,IS,'MAX') - histElim2(R,SR,IS));

* Parad ACRCOST-resurs (IS2) minskas lika mycket som betesmarken (IS)
BIS(R,SR,IS2,'MAX')$(RSR(R,SR) AND SUM(IS$ACRIS_PAST(IS2,IS), histElim2(R,SR,IS)) > 0) =
    max(0, BIS(R,SR,IS2,'MAX') - SUM(IS$ACRIS_PAST(IS2,IS), histElim2(R,SR,IS)));
BIS(R,SR,IS2,'QBAR')$(RSR(R,SR) AND SUM(IS$ACRIS_PAST(IS2,IS), histElim2(R,SR,IS)) > 0) =
    max(0, BIS(R,SR,IS2,'QBAR') - SUM(IS$ACRIS_PAST(IS2,IS), histElim2(R,SR,IS)));

* Uppdatera kvarvarande histosolareal efter greedy-återvätning
histArea(R,SR,IS)$(histElim2(R,SR,IS) > 0) =
    max(0, histArea(R,SR,IS) - histElim2(R,SR,IS));

$endif


*======================================================================
* SCENARIO: Proportionell konvertering av histosolåker till betesmark (convert)
* 30 % av histosolåkern i varje delregion blir permanent betesmark med hög
* avkastning (PRMPASTH).
*======================================================================
$ifthen "%scenarioName%" == "convert"
$setGlobal scenarioFound yes

Scalar histConvShareC "Andel histosolåker att konvertera till PRMPASTH per delregion" / 0.30 /;

Parameter histConvC(R,SR) "Histosolåker som konverteras till PRMPASTH (tusen ha)";
histConvC(R,SR)$RSR(R,SR) = histConvShareC * histArea(R,SR,'CROPLAND');

BIS(R,SR,"CROPLAND",'MAX')$(histConvC(R,SR) > 0) =
    max(0, BIS(R,SR,"CROPLAND",'MAX') - histConvC(R,SR));
BIS(R,SR,"PRMPASTH",'MAX')$(histConvC(R,SR) > 0) =
    BIS(R,SR,"PRMPASTH",'MAX') + histConvC(R,SR);
* Parad ACRCOST-resurs ökar lika mycket som betesmarken, både QBAR och taket MAX
BIS(R,SR,"ACRCOSTPH",'QBAR')$(histConvC(R,SR) > 0) =
    BIS(R,SR,"ACRCOSTPH",'QBAR') + histConvC(R,SR);
BIS(R,SR,"ACRCOSTPH",'MAX')$(histConvC(R,SR) > 0) =
    BIS(R,SR,"ACRCOSTPH",'MAX') + histConvC(R,SR);

* Spåra konverterad åkermark (nationell totalsumma, tusen ha) för diagnostik
Scalar histConvTotalC "Åkermark konverterad, nationell totalsumma (tusen ha)";
histConvTotalC = SUM((R,SR), histConvC(R,SR));
DISPLAY histConvTotalC;

* Uppdatera histosolareal: konverterad histosolåker flyttas till PRMPASTH
histArea(R,SR,'CROPLAND')$(histConvC(R,SR) > 0) =
    max(0, histArea(R,SR,'CROPLAND') - histConvC(R,SR));
histArea(R,SR,'PRMPASTH')$(histConvC(R,SR) > 0) =
    histArea(R,SR,'PRMPASTH') + histConvC(R,SR);

$endif


*======================================================================
* SCENARIO: Greedy konvertering av histosolåker till betesmark (convert_opt)
* 30 % av den nationella histosolåkern blir PRMPASTH. Åkern med lägst
* skuggpris i baslinjen konverteras först. Kräver att baseline har körts först.
*======================================================================
$ifthen "%scenarioName%" == "convert_opt"
$setGlobal scenarioFound yes

Scalar histConvShareCO "Andel av den nationella histosolåkern att konvertera till PRMPASTH" / 0.30 /;

* Läs in markpriser från baslinjekörningen (kräver att baseline har körts först)
Parameter landPrice_baselineCO(R,SR,IS) "Markpriser från baslinjekörningen (1000 SEK/ha)";
$if not exist "%resultFolder%\baseline_shadowprices.gdx" $abort "Skuggpriser saknas: kör baseline med OC('DUAL') = yes först"
execute_load "%resultFolder%\baseline_shadowprices.gdx", landPrice_baselineCO=shadowPricesIS;

Parameter histAvailCO(R,SR)  "Tillgänglig histosolåker (tusen ha)";
Parameter histPriceCO(R,SR)  "Åkermarkens skuggpris från baslinjen (1000 SEK/ha)";
Parameter histConvCO(R,SR)   "Histosolåker som konverteras till PRMPASTH (tusen ha)";
Parameter allocatedCO(R,SR)  "1 om delregionen är fullt allokerad i greedy-algoritmen";
Scalar remainingCO, minPriceCO;
Set iterCO /i1*i500/;

histAvailCO(R,SR)$RSR(R,SR) = histArea(R,SR,'CROPLAND');
histPriceCO(R,SR)$(histAvailCO(R,SR) > 0) = landPrice_baselineCO(R,SR,'CROPLAND');

* Nationellt mål
remainingCO = histConvShareCO * SUM((R,SR), histAvailCO(R,SR));

* Greedy-algoritm: konvertera billigaste histosolåkern först
histConvCO(R,SR)  = 0;
allocatedCO(R,SR) = 0;

Loop(iterCO$(remainingCO > 1e-6),
    minPriceCO = Smin((R,SR)$(histAvailCO(R,SR) > 0 AND NOT allocatedCO(R,SR)), histPriceCO(R,SR));
    Loop((R,SR)$(histPriceCO(R,SR) = minPriceCO AND NOT allocatedCO(R,SR) AND remainingCO > 1e-6),
        if(histAvailCO(R,SR) <= remainingCO,
            histConvCO(R,SR) = histAvailCO(R,SR);
            remainingCO = remainingCO - histAvailCO(R,SR);
        else
            histConvCO(R,SR) = remainingCO;
            remainingCO = 0;
        );
        allocatedCO(R,SR) = 1;
    );
);

BIS(R,SR,"CROPLAND",'MAX')$(histConvCO(R,SR) > 0) =
    max(0, BIS(R,SR,"CROPLAND",'MAX') - histConvCO(R,SR));
BIS(R,SR,"PRMPASTH",'MAX')$(histConvCO(R,SR) > 0) =
    BIS(R,SR,"PRMPASTH",'MAX') + histConvCO(R,SR);
* Parad ACRCOST-resurs ökar lika mycket som betesmarken, både QBAR och taket MAX
BIS(R,SR,"ACRCOSTPH",'QBAR')$(histConvCO(R,SR) > 0) =
    BIS(R,SR,"ACRCOSTPH",'QBAR') + histConvCO(R,SR);
BIS(R,SR,"ACRCOSTPH",'MAX')$(histConvCO(R,SR) > 0) =
    BIS(R,SR,"ACRCOSTPH",'MAX') + histConvCO(R,SR);

* Spåra konverterad åkermark (nationell totalsumma, tusen ha) för diagnostik
Scalar histConvTotalCO "Åkermark konverterad, nationell totalsumma (tusen ha)";
histConvTotalCO = SUM((R,SR), histConvCO(R,SR));
DISPLAY histConvTotalCO;

* Uppdatera histosolareal: konverterad histosolåker flyttas till PRMPASTH
histArea(R,SR,'CROPLAND')$(histConvCO(R,SR) > 0) =
    max(0, histArea(R,SR,'CROPLAND') - histConvCO(R,SR));
histArea(R,SR,'PRMPASTH')$(histConvCO(R,SR) > 0) =
    histArea(R,SR,'PRMPASTH') + histConvCO(R,SR);

$endif


*======================================================================
* SCENARIO: Proportionell återvätning (1/4) + åkermarkskonvertering (3/4) (rewet_convert)
* Båda målen beräknas på arealen innan återvätning.
*======================================================================
$ifthen "%scenarioName%" == "rewet_convert"
$setGlobal scenarioFound yes

Scalar histRedRewet3 "Andel histosolareal att återväta per marktyp" / 0.045 /;
Scalar histRedConv3  "Andel histosol-UAA att konvertera (åkermark -> PRMPASTH) per delregion" / 0.135 /;

* Beräkna konverteringsmålet INNAN återvätning tillämpas
Parameter totalUAA3(SR) "Total jordbruksmark per delregion (tusen ha)";
totalUAA3(SR) = SUM((R,IS)$(RSR(R,SR) AND LAND(IS)), BIS(R,SR,IS,'MAX'));

Parameter histTargetSR3(SR) "Histosolareal att konvertera per delregion (tusen ha)";
histTargetSR3(SR) = histRedConv3 * histFrac(SR,"histUAA") * totalUAA3(SR);

* --- Del 1: Proportionell återvätning på 4,5 % ---
* Reduktionsbeloppen för betesmarktyper beräknas mot markbasen innan POTPAST
* slogs ihop (BISF), se kommentar i rewet.
Parameter histRedAmt3(R,SR,IS) "Absolut markreduktion från återvätning (1000 ha)";
histRedAmt3(R,SR,"CROPLAND") $RSR(R,SR) = BIS(R,SR,"CROPLAND",'MAX') * histRedRewet3 * histFrac(SR,"histCropland");
histRedAmt3(R,SR,"PRMPAST")  $RSR(R,SR) = BISF(R,SR,"PRMPAST")   * histRedRewet3 * histFrac(SR,"histPermPasture");
histRedAmt3(R,SR,"PRMPASTT") $RSR(R,SR) = BISF(R,SR,"PRMPASTT")  * histRedRewet3 * histFrac(SR,"histPermPasture");
histRedAmt3(R,SR,"PRMPASTN") $RSR(R,SR) = BISF(R,SR,"PRMPASTN")  * histRedRewet3 * histFrac(SR,"histPermPasture");
histRedAmt3(R,SR,"PRMPASTH") $RSR(R,SR) = BISF(R,SR,"PRMPASTH")  * histRedRewet3 * histFrac(SR,"histPermPasture");
histRedAmt3(R,SR,"PRMPASTHT")$RSR(R,SR) = BISF(R,SR,"PRMPASTHT") * histRedRewet3 * histFrac(SR,"histPermPasture");
histRedAmt3(R,SR,"PRMPASTHN")$RSR(R,SR) = BISF(R,SR,"PRMPASTHN") * histRedRewet3 * histFrac(SR,"histPermPasture");
histRedAmt3(R,SR,"PRMCHAL")  $RSR(R,SR) = BISF(R,SR,"PRMCHAL")   * histRedRewet3 * histFrac(SR,"histPermChalet");
histRedAmt3(R,SR,"PRMMEAD")  $RSR(R,SR) = BISF(R,SR,"PRMMEAD")   * histRedRewet3 * histFrac(SR,"histPermMeadow");

* Spåra återvätt areal per marktyp (nationell totalsumma, tusen ha) för diagnostik
Parameter histRewetByType3(IS) "Areal återvätt per marktyp, nationell totalsumma (tusen ha)";
histRewetByType3(IS) = SUM((R,SR)$RSR(R,SR), histRedAmt3(R,SR,IS));
DISPLAY histRewetByType3;

BIS(R,SR,IS,'MAX')$(RSR(R,SR) AND histRedAmt3(R,SR,IS) > 0) =
    max(0, BIS(R,SR,IS,'MAX') - histRedAmt3(R,SR,IS));

* Parad ACRCOST-resurs (IS2) minskas lika mycket som betesmarken (IS)
BIS(R,SR,IS2,'MAX')$(RSR(R,SR) AND SUM(IS$ACRIS_PAST(IS2,IS), histRedAmt3(R,SR,IS)) > 0) =
    max(0, BIS(R,SR,IS2,'MAX') - SUM(IS$ACRIS_PAST(IS2,IS), histRedAmt3(R,SR,IS)));
BIS(R,SR,IS2,'QBAR')$(RSR(R,SR) AND SUM(IS$ACRIS_PAST(IS2,IS), histRedAmt3(R,SR,IS)) > 0) =
    max(0, BIS(R,SR,IS2,'QBAR') - SUM(IS$ACRIS_PAST(IS2,IS), histRedAmt3(R,SR,IS)));

* Uppdatera kvarvarande histosolareal efter återvätning (del 1)
histArea(R,SR,IS)$(RSR(R,SR) AND histRedAmt3(R,SR,IS) > 0) =
    max(0, histArea(R,SR,IS) - histRedAmt3(R,SR,IS));

* --- Del 2: Proportionell konvertering på 13,5 % (begränsad av tillgänglig histosol-åkermark) ---
Parameter histCropConv3(R,SR) "Histosol-åkermark att konvertera (tusen ha)";
histCropConv3(R,SR)$RSR(R,SR) =
    min(histFrac(SR,"histCropland") * BIS(R,SR,"CROPLAND",'MAX'),
        histTargetSR3(SR));

BIS(R,SR,"CROPLAND",'MAX')$RSR(R,SR) =
    max(0, BIS(R,SR,"CROPLAND",'MAX') - histCropConv3(R,SR));
BIS(R,SR,"PRMPASTH",'MAX')$RSR(R,SR) =
    BIS(R,SR,"PRMPASTH",'MAX') + histCropConv3(R,SR);
BIS(R,SR,"ACRCOSTPH",'QBAR')$RSR(R,SR) =
    BIS(R,SR,"ACRCOSTPH",'QBAR') + histCropConv3(R,SR);
BIS(R,SR,"ACRCOSTPH",'MAX')$RSR(R,SR) =
    BIS(R,SR,"ACRCOSTPH",'MAX') + histCropConv3(R,SR);

* Spåra konverterad åkermark (nationell totalsumma, tusen ha) för diagnostik
Scalar histConvertedTotal3c "Åkermark konverterad, nationell totalsumma (tusen ha)";
histConvertedTotal3c = SUM((R,SR), histCropConv3(R,SR));
DISPLAY histConvertedTotal3c;

* Uppdatera histosolareal: konverterad histosolåkermark skiftas till PRMPASTH (del 2)
histArea(R,SR,'CROPLAND')$(histCropConv3(R,SR) > 0) =
    max(0, histArea(R,SR,'CROPLAND') - histCropConv3(R,SR));
histArea(R,SR,'PRMPASTH')$(histCropConv3(R,SR) > 0) =
    histArea(R,SR,'PRMPASTH') + histCropConv3(R,SR);

$endif


*======================================================================
* SCENARIO: Greedy återvätning (1/4) + greedy åkermarkskonvertering (3/4) (rewet_convert_opt)
* Båda målen baseras på den nationella histosol-UAA:n innan återvätning.
* Kräver att baseline har körts först.
*======================================================================
$ifthen "%scenarioName%" == "rewet_convert_opt"
$setGlobal scenarioFound yes

Scalar histRedRewet4 "Andel av nationell histosol att återväta" / 0.045 /;
Scalar histRedConv4  "Andel av nationell histosol att konvertera" / 0.135 /;

* Läs in markpriser från baslinjekörningen
Parameter landPrice_baseline4(R,SR,IS) "Markpriser från baslinjekörningen (1000 SEK/ha)";
$if not exist "%resultFolder%\baseline_shadowprices.gdx" $abort "Skuggpriser saknas: kör baseline med OC('DUAL') = yes först"
execute_load "%resultFolder%\baseline_shadowprices.gdx", landPrice_baseline4=shadowPricesIS;

* --- Del 1: Greedy återvätning på 4,5 % (samma algoritm som rewet_opt) ---
Parameter histAvail4(R,SR,IS) "Tillgänglig histosolareal per marktyp (tusen ha)";
Parameter histPrice4(R,SR,IS) "Skuggpris per histosol-lokal från baslinjen";
Parameter histElim4(R,SR,IS)  "Histosolareal att ta bort genom återvätning (tusen ha)";
Parameter allocated4r(R,SR,IS) "1 om lokalen är fullt allokerad i återvätningsloopen";
Scalar totalHist4, remaining4r, minPrice4r;
Set iter4r /i1*i500/;

* Tillgänglig histosolareal för betesmarktyper beräknas mot markbasen innan POTPAST
* slogs ihop (BISF), se kommentar i rewet_opt.
histAvail4(R,SR,"CROPLAND")$RSR(R,SR)  = histFrac(SR,"histCropland")   * BIS(R,SR,"CROPLAND",'MAX');
histAvail4(R,SR,"PRMPAST")$RSR(R,SR)   = histFrac(SR,"histPermPasture") * BISF(R,SR,"PRMPAST");
histAvail4(R,SR,"PRMPASTT")$RSR(R,SR)  = histFrac(SR,"histPermPasture") * BISF(R,SR,"PRMPASTT");
histAvail4(R,SR,"PRMPASTN")$RSR(R,SR)  = histFrac(SR,"histPermPasture") * BISF(R,SR,"PRMPASTN");
histAvail4(R,SR,"PRMPASTH")$RSR(R,SR)  = histFrac(SR,"histPermPasture") * BISF(R,SR,"PRMPASTH");
histAvail4(R,SR,"PRMPASTHT")$RSR(R,SR) = histFrac(SR,"histPermPasture") * BISF(R,SR,"PRMPASTHT");
histAvail4(R,SR,"PRMPASTHN")$RSR(R,SR) = histFrac(SR,"histPermPasture") * BISF(R,SR,"PRMPASTHN");
histAvail4(R,SR,"PRMCHAL")$RSR(R,SR)   = histFrac(SR,"histPermChalet")  * BISF(R,SR,"PRMCHAL");
histAvail4(R,SR,"PRMMEAD")$RSR(R,SR)   = histFrac(SR,"histPermMeadow")  * BISF(R,SR,"PRMMEAD");

histPrice4(R,SR,IS)$(histAvail4(R,SR,IS) > 0) = landPrice_baseline4(R,SR,IS);

* Total histosol innan återvätning - bas för återvätningsmålet
totalHist4 = SUM((R,SR,IS)$RSR(R,SR), histAvail4(R,SR,IS));
remaining4r = histRedRewet4 * totalHist4;

* Total jordbruksmark per delregion innan återvätning - bas för konverteringsmålet
Parameter totalUAA4(SR) "Total jordbruksmark per delregion (tusen ha)";
totalUAA4(SR) = SUM((R,IS)$(RSR(R,SR) AND LAND(IS)), BIS(R,SR,IS,'MAX'));

histElim4(R,SR,IS)   = 0;
allocated4r(R,SR,IS) = 0;

Loop(iter4r$(remaining4r > 1e-6),
    minPrice4r = Smin((R,SR,IS)$(histAvail4(R,SR,IS) > 0 AND NOT allocated4r(R,SR,IS)), histPrice4(R,SR,IS));
    Loop((R,SR,IS)$(histPrice4(R,SR,IS) = minPrice4r AND NOT allocated4r(R,SR,IS) AND remaining4r > 1e-6),
        if(histAvail4(R,SR,IS) <= remaining4r,
            histElim4(R,SR,IS) = histAvail4(R,SR,IS);
            remaining4r = remaining4r - histAvail4(R,SR,IS);
        else
            histElim4(R,SR,IS) = remaining4r;
            remaining4r = 0;
        );
        allocated4r(R,SR,IS) = 1;
    );
);

BIS(R,SR,IS,'MAX')$(histElim4(R,SR,IS) > 0) = max(0, BIS(R,SR,IS,'MAX') - histElim4(R,SR,IS));

* Parad ACRCOST-resurs (IS2) minskas lika mycket som betesmarken (IS)
BIS(R,SR,IS2,'MAX')$(RSR(R,SR) AND SUM(IS$ACRIS_PAST(IS2,IS), histElim4(R,SR,IS)) > 0) =
    max(0, BIS(R,SR,IS2,'MAX') - SUM(IS$ACRIS_PAST(IS2,IS), histElim4(R,SR,IS)));
BIS(R,SR,IS2,'QBAR')$(RSR(R,SR) AND SUM(IS$ACRIS_PAST(IS2,IS), histElim4(R,SR,IS)) > 0) =
    max(0, BIS(R,SR,IS2,'QBAR') - SUM(IS$ACRIS_PAST(IS2,IS), histElim4(R,SR,IS)));

* Spåra återvätt areal per marktyp (nationell totalsumma, tusen ha) för diagnostik
Parameter histRewetByType4(IS) "Areal återvätt per marktyp, nationell totalsumma (tusen ha)";
histRewetByType4(IS) = SUM((R,SR)$RSR(R,SR), histElim4(R,SR,IS));
DISPLAY histRewetByType4;

* Uppdatera kvarvarande histosolareal efter greedy-återvätning (del 1)
histArea(R,SR,IS)$(histElim4(R,SR,IS) > 0) =
    max(0, histArea(R,SR,IS) - histElim4(R,SR,IS));

* --- Del 2: Greedy åkermarkskonvertering på 13,5 % (målet baseras på totalsumman innan återvätning) ---
Scalar totalHistTarget4c "Nationellt konverteringsmål (tusen ha)";
totalHistTarget4c = SUM(SR, histRedConv4 * histFrac(SR,"histUAA") * totalUAA4(SR));

* Tillgänglig histosol-åkermark efter att återvätning har tillämpats
Parameter histAvailCrop4(R,SR) "Tillgänglig histosol-åkermark efter återvätning (tusen ha)";
histAvailCrop4(R,SR)$RSR(R,SR) = histFrac(SR,"histCropland") * BIS(R,SR,"CROPLAND",'MAX');

Parameter histPrice4c(R,SR) "Åkermarkens skuggpris från baslinjen (1000 SEK/ha)";
histPrice4c(R,SR)$(histAvailCrop4(R,SR) > 0) = landPrice_baseline4(R,SR,"CROPLAND");

Parameter histElim4c(R,SR) "Histosol-åkermark att konvertera (tusen ha)";
Parameter allocated4c(R,SR) "1 om lokalen är fullt allokerad i konverteringsloopen";
Scalar remaining4c, minPrice4c;
Set iter4c /i1*i500/;

histElim4c(R,SR)  = 0;
allocated4c(R,SR) = 0;
remaining4c = totalHistTarget4c;

Loop(iter4c$(remaining4c > 1e-6),
    minPrice4c = Smin((R,SR)$(histAvailCrop4(R,SR) > 0 AND NOT allocated4c(R,SR)), histPrice4c(R,SR));
    Loop((R,SR)$(histPrice4c(R,SR) = minPrice4c AND NOT allocated4c(R,SR) AND remaining4c > 1e-6),
        if(histAvailCrop4(R,SR) <= remaining4c,
            histElim4c(R,SR) = histAvailCrop4(R,SR);
            remaining4c = remaining4c - histAvailCrop4(R,SR);
        else
            histElim4c(R,SR) = remaining4c;
            remaining4c = 0;
        );
        allocated4c(R,SR) = 1;
    );
);

BIS(R,SR,"CROPLAND",'MAX')$(histElim4c(R,SR) > 0) =
    max(0, BIS(R,SR,"CROPLAND",'MAX') - histElim4c(R,SR));
BIS(R,SR,"PRMPASTH",'MAX')$(histElim4c(R,SR) > 0) =
    BIS(R,SR,"PRMPASTH",'MAX') + histElim4c(R,SR);
BIS(R,SR,"ACRCOSTPH",'QBAR')$(histElim4c(R,SR) > 0) =
    BIS(R,SR,"ACRCOSTPH",'QBAR') + histElim4c(R,SR);
BIS(R,SR,"ACRCOSTPH",'MAX')$(histElim4c(R,SR) > 0) =
    BIS(R,SR,"ACRCOSTPH",'MAX') + histElim4c(R,SR);

* Spåra konverterad åkermark (nationell totalsumma, tusen ha) för diagnostik
Scalar histConvertedTotal4c "Åkermark konverterad, nationell totalsumma (tusen ha)";
histConvertedTotal4c = SUM((R,SR), histElim4c(R,SR));
DISPLAY histConvertedTotal4c;

* Uppdatera histosolareal: konverterad histosolåkermark skiftas till PRMPASTH (del 2)
histArea(R,SR,'CROPLAND')$(histElim4c(R,SR) > 0) =
    max(0, histArea(R,SR,'CROPLAND') - histElim4c(R,SR));
histArea(R,SR,'PRMPASTH')$(histElim4c(R,SR) > 0) =
    histArea(R,SR,'PRMPASTH') + histElim4c(R,SR);

$endif


$endif


*===============================================================================
* DEL 2: LATE (läses efter 6.5, före MODEL/SOLVE)
*===============================================================================
$ifthen "%projectStage%" == "late"

$endif
