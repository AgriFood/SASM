@echo off
echo ============================================================
echo  Running all SASM_scen-histosol scenarios
echo ============================================================

echo.
echo [0/5] baseline
gams SASM2025.gms --activeScenario=0
if %ERRORLEVEL% neq 0 (
    echo ERROR: Scenario 0 failed. Scenarios 2, 4, and 5 require it. Stopping.
    exit /b 1
)

echo.
echo [1/5] rewet
gams SASM2025.gms --activeScenario=1

echo.
echo [2/5] rewet_opt
gams SASM2025.gms --activeScenario=2

echo.
echo [3/5] combo
gams SASM2025.gms --activeScenario=3

echo.
echo [4/5] combo_opt
gams SASM2025.gms --activeScenario=4

echo.
echo [5/5] rewet_18_opt
gams SASM2025.gms --activeScenario=5

echo.
echo ============================================================
echo  All scenarios completed.
echo ============================================================
