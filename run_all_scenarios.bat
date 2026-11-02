@echo off
rem Runs all scenarios in the project file, in order.
rem List the scenario names in SCENARIOS, separated by spaces.
rem If the first scenario fails, the rest are not run, since later scenarios may use its results.
set PROJECT=project
set SCENARIOS=scenario_a scenario_b

set FIRST=
set FAILED=
for %%s in (%SCENARIOS%) do if not defined FIRST set FIRST=%%s

echo ============================================================
echo  Running scenarios in %PROJECT%.gms: %SCENARIOS%
echo ============================================================

for %%s in (%SCENARIOS%) do (
    echo.
    echo [%%s]
    gams SASM2025.gms --projectFile=%PROJECT% --scenarioName=%%s
    if errorlevel 1 (
        echo ERROR: Scenario %%s failed.
        set FAILED=yes
        if "%%s"=="%FIRST%" (
            echo Later scenarios may use its results. Stopping.
            exit /b 1
        )
    )
)

echo.
echo ============================================================
if defined FAILED (
    echo  Finished, but one or more scenarios failed. See ERROR above.
    echo ============================================================
    exit /b 1
)
echo  All scenarios completed.
echo ============================================================
