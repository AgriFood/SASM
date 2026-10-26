$ontext
    Scenariofil för SASM_scen-histosol.

    Ändra activeScenario nedan för att välja vilket scenario som ska köras:
      0   baseline        Inga ändringar. Exporterar skuggpriser för användning i scenario 2, 4 och 5.
      1   rewet           Proportionell återvätning per delregion baserat på histFrac.
      2   rewet_opt       Greedy återvätning med skuggpriser från baseline-GDX.
                          Kräver att scenario 0 har körts först.
      3   rewet_convert           Proportionell återvätning (7,5 %) och åkermarkskonvertering (22,5 %).
                          Målen beräknas på arealen innan återvätning. Totalt: 30 %.
      4   rewet_convert_opt       Greedy återvätning (7,5 %) och greedy åkermarkskonvertering (22,5 %).
                          Målen baseras på den nationella histosol-UAA:n innan återvätning. Totalt: 30 %.
                          Kräver att scenario 0 har körts först.
      5   rewet_18_opt    Känslighetsvariant av scenario 2: greedy återvätning på 18 %
                          istället för 30 %. Kräver att scenario 0 har körts först.

    Mappning från histFrac-typer till BIS-marktyper:
      histCropland    -> CROPLAND
      histPermPasture -> PRMPAST, PRMPASTT, PRMPASTN, PRMPASTH, PRMPASTHT, PRMPASTHN
      histPermChalet  -> PRMCHAL
      histPermMeadow  -> PRMMEAD
      histUAA         -> andel av total UAA som är histosol per delregion

$offtext

* --- Välj aktivt scenario: 0-5 (kan överstyras från kommandoraden: gams SASM2025.gms --activeScenario=0)
$if not defined activeScenario $setGlobal activeScenario 0

* --- Definiera vilken mapp resultaten ska sparas i
$setGlobal resultFolder output

* --- Mappning från återvätningsbara betes-/betesmarktyper till deras parade ACRCOST*-
*     kostnadskurveresurs. Används för att hålla ACRCOSTx.MAX/QBAR (samt dess SLOPE/INTERCEPT)
*     synkat när ett scenario minskar PRMx.MAX, t.ex. vid histosolåtervätning.
Set histPastACR(IS,IS) "Betesmarktyp -> parad ACRCOST-resurs" /
    PRMPAST  .ACRCOSTP
    PRMPASTT .ACRCOSTPT
    PRMPASTN .ACRCOSTPN
    PRMPASTH .ACRCOSTPH
    PRMPASTHT.ACRCOSTPHT
    PRMPASTHN.ACRCOSTPHN
    PRMCHAL  .ACRCOSTCHA
    PRMMEAD  .ACRCOSTMEA
/;
Alias(IS,IS2);

*======================================================================
* SCENARIO 0: Baslinje
*======================================================================
$ifthen "%activeScenario%" == "0"

$setGlobal scenarioName baseline

* Inga ändringar i BIS - ren baslinje.
* Skuggpriser exporteras i report.gms för användning i scenario 2, 4 och 5.

$endif


*======================================================================
* SCENARIO 1: Proportionell återvätning (rewet)
*======================================================================
$ifthen "%activeScenario%" == "1"

$setGlobal scenarioName rewet

* Reduktionsandelar per histosol-marktyp (0 = ingen reduktion, 1 = ta bort all histosolareal)
Parameter histRed1 "Andel histosolareal att ta bort, per marktyp" /
    histCropland     0.3
    histPermPasture  0.3
    histPermChalet   0.3
    histPermMeadow   0.3
/;

BIS(R,SR,"CROPLAND",'MAX')$RSR(R,SR) =
    max(0, BIS(R,SR,"CROPLAND",'MAX') * (1 - histRed1("histCropland")   * histFrac(SR,"histCropland")));

* Reduktionsbeloppen för betes-/betesmarktyper beräknas mot markbasen innan POTPAST
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

* Håller varje parad ACRCOST*-resurs (MAX, QBAR samt dess SLOPE/INTERCEPT-kostnadskurva)
* synkad med PRMx-reduktionen ovan, på samma sätt som scenario 3/4 uppdaterar ACRCOSTPH
* när mark konverteras till PRMPASTH.
BIS(R,SR,IS2,'MAX')$(RSR(R,SR) AND SUM(IS$histPastACR(IS,IS2), histRedAmt1(R,SR,IS)) > 0) =
    max(0, BIS(R,SR,IS2,'MAX') - SUM(IS$histPastACR(IS,IS2), histRedAmt1(R,SR,IS)));
BIS(R,SR,IS2,'QBAR')$(RSR(R,SR) AND SUM(IS$histPastACR(IS,IS2), histRedAmt1(R,SR,IS)) > 0) =
    max(0, BIS(R,SR,IS2,'QBAR') - SUM(IS$histPastACR(IS,IS2), histRedAmt1(R,SR,IS)));

BIS(R,SR,IS2,'SLOPE')
    $(RSR(R,SR)$ISES(R,SR,IS2)$(SUM(IS$histPastACR(IS,IS2), histRedAmt1(R,SR,IS)) > 0)
      $((BIS(R,SR,IS2,'ELAS') LT 99) AND (BIS(R,SR,IS2,'QBAR') GT 0)))
    = BIS(R,SR,IS2,'PBAR') / (BIS(R,SR,IS2,'ELAS') * BIS(R,SR,IS2,'QBAR'));
BIS(R,SR,IS2,'INTERCEPT')
    $(RSR(R,SR)$ISES(R,SR,IS2)$(SUM(IS$histPastACR(IS,IS2), histRedAmt1(R,SR,IS)) > 0))
    = BIS(R,SR,IS2,'PBAR') - BIS(R,SR,IS2,'SLOPE') * BIS(R,SR,IS2,'QBAR');

* Uppdatera kvarvarande organogen areal efter återvätning
histOrgIS(R,SR,'CROPLAND')$RSR(R,SR) =
    max(0, histOrgIS(R,SR,'CROPLAND') * (1 - histRed1('histCropland')));
histOrgIS(R,SR,IS)$(RSR(R,SR) AND histRedAmt1(R,SR,IS) > 0) =
    max(0, histOrgIS(R,SR,IS) - histRedAmt1(R,SR,IS));

$endif


*======================================================================
* SCENARIO 2: Greedy återvätning med skuggpriser från baslinjen (rewet_opt)
* Kräver att scenario 0 (baslinjen) har körts först.
*======================================================================
$ifthen "%activeScenario%" == "2"

$setGlobal scenarioName rewet_opt

* Andel av total nationell histosolareal att ta bort (0 = ingen, 1 = all)
Scalar histRedNat2 "Nationell histosolreduktionsandel" / 0.3 /;

* Läs in markpriser från baslinjekörningen (kräver att scenario 0 har körts först)
Parameter landPrice_baseline(R,SR,IS) "Markpriser från baslinjekörningen (1000 SEK/ha, från RTBL7)";
execute_load "output\baseline_shadowprices.gdx", landPrice_baseline=shadowPricesIS;

Parameter histAvail2(R,SR,IS) "Tillgänglig histosolareal per marktyp (tusen ha)";
Parameter histPrice2(R,SR,IS) "Markpris per histosol-lokal från baslinjen";
Parameter histElim2(R,SR,IS)  "Histosolareal att eliminera (tusen ha)";
Parameter allocated2(R,SR,IS) "1 om lokalen är fullt allokerad i greedy-algoritmen";
Scalar totalHist2, remaining2, minPrice2;

Set iter2 /i1*i500/;

* Tillgänglig histosolareal för betes-/betesmarktyper beräknas mot markbasen innan POTPAST
* slogs ihop (BISF), inte mot den aktuella BIS MAX, som vid denna punkt redan inkluderar
* outnyttjad POTPAST-baserad marginal. Att storleksbestämma/lokalisera greedy-borttagningen
* mot denna uppblåsta pool skulle överskatta vad som faktiskt är använd betesmark vid varje
* lokal. CROPLAND påverkas inte av POTPAST-sammanslagningen och kan därför använda den
* aktuella MAX direkt.
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

* Håller varje parad ACRCOST*-resurs (MAX, QBAR samt dess SLOPE/INTERCEPT-kostnadskurva)
* synkad med PRMx-reduktionen ovan, på samma sätt som scenario 3/4 uppdaterar ACRCOSTPH
* när mark konverteras till PRMPASTH.
BIS(R,SR,IS2,'MAX')$(RSR(R,SR) AND SUM(IS$histPastACR(IS,IS2), histElim2(R,SR,IS)) > 0) =
    max(0, BIS(R,SR,IS2,'MAX') - SUM(IS$histPastACR(IS,IS2), histElim2(R,SR,IS)));
BIS(R,SR,IS2,'QBAR')$(RSR(R,SR) AND SUM(IS$histPastACR(IS,IS2), histElim2(R,SR,IS)) > 0) =
    max(0, BIS(R,SR,IS2,'QBAR') - SUM(IS$histPastACR(IS,IS2), histElim2(R,SR,IS)));

BIS(R,SR,IS2,'SLOPE')
    $(RSR(R,SR)$ISES(R,SR,IS2)$(SUM(IS$histPastACR(IS,IS2), histElim2(R,SR,IS)) > 0)
      $((BIS(R,SR,IS2,'ELAS') LT 99) AND (BIS(R,SR,IS2,'QBAR') GT 0)))
    = BIS(R,SR,IS2,'PBAR') / (BIS(R,SR,IS2,'ELAS') * BIS(R,SR,IS2,'QBAR'));
BIS(R,SR,IS2,'INTERCEPT')
    $(RSR(R,SR)$ISES(R,SR,IS2)$(SUM(IS$histPastACR(IS,IS2), histElim2(R,SR,IS)) > 0))
    = BIS(R,SR,IS2,'PBAR') - BIS(R,SR,IS2,'SLOPE') * BIS(R,SR,IS2,'QBAR');

* Uppdatera kvarvarande organogen areal efter greedy-återvätning
histOrgIS(R,SR,IS)$(histElim2(R,SR,IS) > 0) =
    max(0, histOrgIS(R,SR,IS) - histElim2(R,SR,IS));

$endif


*======================================================================
* SCENARIO 3: Proportionell återvätning (1/4) + åkermarkskonvertering (3/4)
* Båda målen beräknas på arealen innan återvätning.
*======================================================================
$ifthen "%activeScenario%" == "3"

$setGlobal scenarioName rewet_convert

Scalar histRedRewet3 "Andel histosolareal att återväta per marktyp" / 0.045 /;
Scalar histRedConv3  "Andel histosol-UAA att konvertera (åkermark -> PRMPASTH) per delregion" / 0.135 /;

* Beräkna konverteringsmålet INNAN återvätning tillämpas
Parameter totalUAA3(SR) "Total jordbruksmark per delregion (tusen ha)";
totalUAA3(SR) = SUM((R,IS)$(RSR(R,SR) AND LAND(IS)), BIS(R,SR,IS,'MAX'));

Parameter histTargetSR3(SR) "Histosolareal att konvertera per delregion (tusen ha)";
histTargetSR3(SR) = histRedConv3 * histFrac(SR,"histUAA") * totalUAA3(SR);

* --- Del 1: Proportionell återvätning på 7,5 % ---
* Reduktionsbeloppen för betes-/betesmarktyper beräknas mot markbasen innan POTPAST
* slogs ihop (BISF), inte mot den aktuella BIS MAX, som vid denna punkt redan
* inkluderar outnyttjad POTPAST-baserad marginal. Att skära en andel av denna uppblåsta
* MAX skulle delvis ta bort oanvänd kapacitet istället för verklig betesmark, med liten
* eller ingen effekt på den optimerade lösningen.
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

* Håller varje parad ACRCOST*-resurs (MAX, QBAR samt dess SLOPE/INTERCEPT-kostnadskurva)
* synkad med PRMx-reduktionen ovan.
BIS(R,SR,IS2,'MAX')$(RSR(R,SR) AND SUM(IS$histPastACR(IS,IS2), histRedAmt3(R,SR,IS)) > 0) =
    max(0, BIS(R,SR,IS2,'MAX') - SUM(IS$histPastACR(IS,IS2), histRedAmt3(R,SR,IS)));
BIS(R,SR,IS2,'QBAR')$(RSR(R,SR) AND SUM(IS$histPastACR(IS,IS2), histRedAmt3(R,SR,IS)) > 0) =
    max(0, BIS(R,SR,IS2,'QBAR') - SUM(IS$histPastACR(IS,IS2), histRedAmt3(R,SR,IS)));

BIS(R,SR,IS2,'SLOPE')
    $(RSR(R,SR)$ISES(R,SR,IS2)$(SUM(IS$histPastACR(IS,IS2), histRedAmt3(R,SR,IS)) > 0)
      $((BIS(R,SR,IS2,'ELAS') LT 99) AND (BIS(R,SR,IS2,'QBAR') GT 0)))
    = BIS(R,SR,IS2,'PBAR') / (BIS(R,SR,IS2,'ELAS') * BIS(R,SR,IS2,'QBAR'));
BIS(R,SR,IS2,'INTERCEPT')
    $(RSR(R,SR)$ISES(R,SR,IS2)$(SUM(IS$histPastACR(IS,IS2), histRedAmt3(R,SR,IS)) > 0))
    = BIS(R,SR,IS2,'PBAR') - BIS(R,SR,IS2,'SLOPE') * BIS(R,SR,IS2,'QBAR');

* Uppdatera kvarvarande organogen areal efter återvätning (del 1)
histOrgIS(R,SR,IS)$(RSR(R,SR) AND histRedAmt3(R,SR,IS) > 0) =
    max(0, histOrgIS(R,SR,IS) - histRedAmt3(R,SR,IS));

* --- Del 2: Proportionell konvertering på 22,5 % (begränsad av tillgänglig histosol-åkermark) ---
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

* Spåra konverterad åkermark (nationell totalsumma, tusen ha) för diagnostik
Scalar histConvertedTotal3c "Åkermark konverterad, nationell totalsumma (tusen ha)";
histConvertedTotal3c = SUM((R,SR), histCropConv3(R,SR));
DISPLAY histConvertedTotal3c;

* Uppdatera ACRCOSTPH.SLOPE och ACRCOSTPH.INTERCEPT efter ändringen i ACRCOSTPH.QBAR.
BIS(R,SR,"ACRCOSTPH",'SLOPE')
    $(RSR(R,SR)$ISES(R,SR,"ACRCOSTPH")$((BIS(R,SR,"ACRCOSTPH",'ELAS') LT 99) AND (BIS(R,SR,"ACRCOSTPH",'QBAR') GT 0)))
    = BIS(R,SR,"ACRCOSTPH",'PBAR') / (BIS(R,SR,"ACRCOSTPH",'ELAS') * BIS(R,SR,"ACRCOSTPH",'QBAR'));
BIS(R,SR,"ACRCOSTPH",'INTERCEPT')
    $(RSR(R,SR)$ISES(R,SR,"ACRCOSTPH"))
    = BIS(R,SR,"ACRCOSTPH",'PBAR') - BIS(R,SR,"ACRCOSTPH",'SLOPE') * BIS(R,SR,"ACRCOSTPH",'QBAR');

* Uppdatera organogen areal: konverterad organogen åkermark skiftas till PRMPASTH (del 2)
histOrgIS(R,SR,'CROPLAND')$(histCropConv3(R,SR) > 0) =
    max(0, histOrgIS(R,SR,'CROPLAND') - histCropConv3(R,SR));
histOrgIS(R,SR,'PRMPASTH')$(histCropConv3(R,SR) > 0) =
    histOrgIS(R,SR,'PRMPASTH') + histCropConv3(R,SR);

$endif


*======================================================================
* SCENARIO 4: Greedy återvätning (1/4) + greedy åkermarkskonvertering (3/4)
* Båda målen baseras på den nationella histosol-UAA:n innan återvätning.
* Kräver att scenario 0 (baslinjen) har körts först.
*======================================================================
$ifthen "%activeScenario%" == "4"

$setGlobal scenarioName rewet_convert_opt

Scalar histRedRewet4 "Andel av nationell histosol att återväta" / 0.045 /;
Scalar histRedConv4  "Andel av nationell histosol att konvertera" / 0.135 /;

* Läs in markpriser från baslinjekörningen
Parameter landPrice_baseline4(R,SR,IS) "Markpriser från baslinjekörningen (1000 SEK/ha)";
execute_load "output\baseline_shadowprices.gdx", landPrice_baseline4=shadowPricesIS;

* --- Del 1: Greedy återvätning på 7,5 % (samma algoritm som scenario 2) ---
Parameter histAvail4(R,SR,IS) "Tillgänglig histosolareal per marktyp (tusen ha)";
Parameter histPrice4(R,SR,IS) "Skuggpris per histosol-lokal från baslinjen";
Parameter histElim4(R,SR,IS)  "Histosolareal att ta bort genom återvätning (tusen ha)";
Parameter allocated4r(R,SR,IS) "1 om lokalen är fullt allokerad i återvätningsloopen";
Scalar totalHist4, remaining4r, minPrice4r;
Set iter4r /i1*i500/;

* Tillgänglig histosolareal för betes-/betesmarktyper beräknas mot markbasen innan POTPAST
* slogs ihop (BISF), inte mot den aktuella BIS MAX, som vid denna punkt redan inkluderar
* outnyttjad POTPAST-baserad marginal. CROPLAND påverkas inte av POTPAST-sammanslagningen
* och kan därför använda den aktuella MAX direkt.
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

* Total histosol innan återvätning — bas för återvätningsmålet
totalHist4 = SUM((R,SR,IS)$RSR(R,SR), histAvail4(R,SR,IS));
remaining4r = histRedRewet4 * totalHist4;

* Total jordbruksmark per delregion innan återvätning — bas för konverteringsmålet
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

* Håller varje parad ACRCOST*-resurs (MAX, QBAR samt dess SLOPE/INTERCEPT-kostnadskurva)
* synkad med PRMx-reduktionen ovan.
BIS(R,SR,IS2,'MAX')$(RSR(R,SR) AND SUM(IS$histPastACR(IS,IS2), histElim4(R,SR,IS)) > 0) =
    max(0, BIS(R,SR,IS2,'MAX') - SUM(IS$histPastACR(IS,IS2), histElim4(R,SR,IS)));
BIS(R,SR,IS2,'QBAR')$(RSR(R,SR) AND SUM(IS$histPastACR(IS,IS2), histElim4(R,SR,IS)) > 0) =
    max(0, BIS(R,SR,IS2,'QBAR') - SUM(IS$histPastACR(IS,IS2), histElim4(R,SR,IS)));

BIS(R,SR,IS2,'SLOPE')
    $(RSR(R,SR)$ISES(R,SR,IS2)$(SUM(IS$histPastACR(IS,IS2), histElim4(R,SR,IS)) > 0)
      $((BIS(R,SR,IS2,'ELAS') LT 99) AND (BIS(R,SR,IS2,'QBAR') GT 0)))
    = BIS(R,SR,IS2,'PBAR') / (BIS(R,SR,IS2,'ELAS') * BIS(R,SR,IS2,'QBAR'));
BIS(R,SR,IS2,'INTERCEPT')
    $(RSR(R,SR)$ISES(R,SR,IS2)$(SUM(IS$histPastACR(IS,IS2), histElim4(R,SR,IS)) > 0))
    = BIS(R,SR,IS2,'PBAR') - BIS(R,SR,IS2,'SLOPE') * BIS(R,SR,IS2,'QBAR');

* Spåra återvätt areal per marktyp (nationell totalsumma, tusen ha) för diagnostik
Parameter histRewetByType4(IS) "Areal återvätt per marktyp, nationell totalsumma (tusen ha)";
histRewetByType4(IS) = SUM((R,SR)$RSR(R,SR), histElim4(R,SR,IS));
DISPLAY histRewetByType4;

* Uppdatera kvarvarande organogen areal efter greedy-återvätning (del 1)
histOrgIS(R,SR,IS)$(histElim4(R,SR,IS) > 0) =
    max(0, histOrgIS(R,SR,IS) - histElim4(R,SR,IS));

* --- Del 2: Greedy åkermarkskonvertering på 22,5 % (målet baseras på totalsumman innan återvätning, matchar scenario 4) ---
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

* Spåra konverterad åkermark (nationell totalsumma, tusen ha) för diagnostik
Scalar histConvertedTotal4c "Åkermark konverterad, nationell totalsumma (tusen ha)";
histConvertedTotal4c = SUM((R,SR), histElim4c(R,SR));
DISPLAY histConvertedTotal4c;

* Uppdatera ACRCOSTPH.SLOPE och ACRCOSTPH.INTERCEPT efter ändringen i ACRCOSTPH.QBAR.
BIS(R,SR,"ACRCOSTPH",'SLOPE')
    $(RSR(R,SR)$ISES(R,SR,"ACRCOSTPH")$((BIS(R,SR,"ACRCOSTPH",'ELAS') LT 99) AND (BIS(R,SR,"ACRCOSTPH",'QBAR') GT 0)))
    = BIS(R,SR,"ACRCOSTPH",'PBAR') / (BIS(R,SR,"ACRCOSTPH",'ELAS') * BIS(R,SR,"ACRCOSTPH",'QBAR'));
BIS(R,SR,"ACRCOSTPH",'INTERCEPT')
    $(RSR(R,SR)$ISES(R,SR,"ACRCOSTPH"))
    = BIS(R,SR,"ACRCOSTPH",'PBAR') - BIS(R,SR,"ACRCOSTPH",'SLOPE') * BIS(R,SR,"ACRCOSTPH",'QBAR');

* Uppdatera organogen areal: konverterad organogen åkermark skiftas till PRMPASTH (del 2)
histOrgIS(R,SR,'CROPLAND')$(histElim4c(R,SR) > 0) =
    max(0, histOrgIS(R,SR,'CROPLAND') - histElim4c(R,SR));
histOrgIS(R,SR,'PRMPASTH')$(histElim4c(R,SR) > 0) =
    histOrgIS(R,SR,'PRMPASTH') + histElim4c(R,SR);

$endif


*======================================================================
* SCENARIO 5: Känslighetsvariant av scenario 2 - greedy återvätning på 18 % (rewet_18_opt)
* Kräver att scenario 0 (baslinjen) har körts först.
*======================================================================
$ifthen "%activeScenario%" == "5"

$setGlobal scenarioName rewet_18_opt

* Andel av total nationell histosolareal att ta bort (0 = ingen, 1 = all)
Scalar histRedNat5 "Nationell histosolreduktionsandel" / 0.18 /;

* Läs in markpriser från baslinjekörningen (kräver att scenario 0 har körts först)
Parameter landPrice_baseline5(R,SR,IS) "Markpriser från baslinjekörningen (1000 SEK/ha, från RTBL7)";
execute_load "output\baseline_shadowprices.gdx", landPrice_baseline5=shadowPricesIS;

Parameter histAvail5(R,SR,IS) "Tillgänglig histosolareal per marktyp (tusen ha)";
Parameter histPrice5(R,SR,IS) "Markpris per histosol-lokal från baslinjen";
Parameter histElim5(R,SR,IS)  "Histosolareal att eliminera (tusen ha)";
Parameter allocated5(R,SR,IS) "1 om lokalen är fullt allokerad i greedy-algoritmen";
Scalar totalHist5, remaining5, minPrice5;

Set iter5 /i1*i500/;

* Tillgänglig histosolareal för betes-/betesmarktyper beräknas mot markbasen innan POTPAST
* slogs ihop (BISF), inte mot den aktuella BIS MAX, som vid denna punkt redan inkluderar
* outnyttjad POTPAST-baserad marginal. CROPLAND påverkas inte av POTPAST-sammanslagningen
* och kan därför använda den aktuella MAX direkt.
histAvail5(R,SR,"CROPLAND")$RSR(R,SR)  = histFrac(SR,"histCropland")   * BIS(R,SR,"CROPLAND",'MAX');
histAvail5(R,SR,"PRMPAST")$RSR(R,SR)   = histFrac(SR,"histPermPasture") * BISF(R,SR,"PRMPAST");
histAvail5(R,SR,"PRMPASTT")$RSR(R,SR)  = histFrac(SR,"histPermPasture") * BISF(R,SR,"PRMPASTT");
histAvail5(R,SR,"PRMPASTN")$RSR(R,SR)  = histFrac(SR,"histPermPasture") * BISF(R,SR,"PRMPASTN");
histAvail5(R,SR,"PRMPASTH")$RSR(R,SR)  = histFrac(SR,"histPermPasture") * BISF(R,SR,"PRMPASTH");
histAvail5(R,SR,"PRMPASTHT")$RSR(R,SR) = histFrac(SR,"histPermPasture") * BISF(R,SR,"PRMPASTHT");
histAvail5(R,SR,"PRMPASTHN")$RSR(R,SR) = histFrac(SR,"histPermPasture") * BISF(R,SR,"PRMPASTHN");
histAvail5(R,SR,"PRMCHAL")$RSR(R,SR)   = histFrac(SR,"histPermChalet")  * BISF(R,SR,"PRMCHAL");
histAvail5(R,SR,"PRMMEAD")$RSR(R,SR)   = histFrac(SR,"histPermMeadow")  * BISF(R,SR,"PRMMEAD");

* Markpriser från RTBL7 är redan positiva
histPrice5(R,SR,IS)$(histAvail5(R,SR,IS) > 0) = landPrice_baseline5(R,SR,IS);

* Nationellt mål
totalHist5 = SUM((R,SR,IS)$RSR(R,SR), histAvail5(R,SR,IS));
remaining5 = histRedNat5 * totalHist5;

* Greedy-algoritm: ta bort billigaste histosol först
histElim5(R,SR,IS)  = 0;
allocated5(R,SR,IS) = 0;

Loop(iter5$(remaining5 > 1e-6),
    minPrice5 = Smin((R,SR,IS)$(histAvail5(R,SR,IS) > 0 AND NOT allocated5(R,SR,IS)), histPrice5(R,SR,IS));
    Loop((R,SR,IS)$(histPrice5(R,SR,IS) = minPrice5 AND NOT allocated5(R,SR,IS) AND remaining5 > 1e-6),
        if(histAvail5(R,SR,IS) <= remaining5,
            histElim5(R,SR,IS) = histAvail5(R,SR,IS);
            remaining5 = remaining5 - histAvail5(R,SR,IS);
        else
            histElim5(R,SR,IS) = remaining5;
            remaining5 = 0;
        );
        allocated5(R,SR,IS) = 1;
    );
);

* Tillämpa reduktioner
BIS(R,SR,IS,'MAX')$(histElim5(R,SR,IS) > 0) = max(0, BIS(R,SR,IS,'MAX') - histElim5(R,SR,IS));

* Håller varje parad ACRCOST*-resurs (MAX, QBAR samt dess SLOPE/INTERCEPT-kostnadskurva)
* synkad med PRMx-reduktionen ovan.
BIS(R,SR,IS2,'MAX')$(RSR(R,SR) AND SUM(IS$histPastACR(IS,IS2), histElim5(R,SR,IS)) > 0) =
    max(0, BIS(R,SR,IS2,'MAX') - SUM(IS$histPastACR(IS,IS2), histElim5(R,SR,IS)));
BIS(R,SR,IS2,'QBAR')$(RSR(R,SR) AND SUM(IS$histPastACR(IS,IS2), histElim5(R,SR,IS)) > 0) =
    max(0, BIS(R,SR,IS2,'QBAR') - SUM(IS$histPastACR(IS,IS2), histElim5(R,SR,IS)));

BIS(R,SR,IS2,'SLOPE')
    $(RSR(R,SR)$ISES(R,SR,IS2)$(SUM(IS$histPastACR(IS,IS2), histElim5(R,SR,IS)) > 0)
      $((BIS(R,SR,IS2,'ELAS') LT 99) AND (BIS(R,SR,IS2,'QBAR') GT 0)))
    = BIS(R,SR,IS2,'PBAR') / (BIS(R,SR,IS2,'ELAS') * BIS(R,SR,IS2,'QBAR'));
BIS(R,SR,IS2,'INTERCEPT')
    $(RSR(R,SR)$ISES(R,SR,IS2)$(SUM(IS$histPastACR(IS,IS2), histElim5(R,SR,IS)) > 0))
    = BIS(R,SR,IS2,'PBAR') - BIS(R,SR,IS2,'SLOPE') * BIS(R,SR,IS2,'QBAR');

* Spåra återvätt areal per marktyp (nationell totalsumma, tusen ha) för diagnostik
Parameter histRewetByType5(IS) "Areal återvätt per marktyp, nationell totalsumma (tusen ha)";
histRewetByType5(IS) = SUM((R,SR)$RSR(R,SR), histElim5(R,SR,IS));
DISPLAY histRewetByType5;

* Uppdatera kvarvarande organogen areal efter greedy-återvätning
histOrgIS(R,SR,IS)$(histElim5(R,SR,IS) > 0) =
    max(0, histOrgIS(R,SR,IS) - histElim5(R,SR,IS));

$endif
