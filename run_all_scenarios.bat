@echo off
rem Runs all scenarios in the project file, in order.
rem Scenario names and descriptions are in the project file.
set PROJECT=project
set LAST=5

echo ============================================================
echo  Running scenarios 0-%LAST% in %PROJECT%.gms
echo ============================================================

echo.
echo [0/%LAST%] scenario 0
gams SASM2025.gms --projectFile=%PROJECT% --activeScenario=0
if %ERRORLEVEL% neq 0 (
    echo ERROR: Scenario 0 failed. Later scenarios need its results. Stopping.
    exit /b 1
)

for /L %%i in (1,1,%LAST%) do (
    echo.
    echo [%%i/%LAST%] scenario %%i
    gams SASM2025.gms --projectFile=%PROJECT% --activeScenario=%%i
)

echo.
echo ============================================================
echo  All scenarios completed.
echo ============================================================
