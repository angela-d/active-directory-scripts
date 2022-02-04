@echo off
REM install queues per user
REM global vars
SET printServer=172.31.0.1
SET printOpt=lpr
SET adminScripts=C:\WINDOWS\system32\Printing_Admin_Scripts\en-US

GOTO:MAIN

:setupPrinter
SET printerName=%1
REM driverOpt is not used here, but holdover from copy/paste of the mdm script
SET driverOpt=%2
SET driverSelection=%3
SET unquoted=%printerName:"=%

REM queue setup
cscript /Nologo %adminScripts%\prnmngr.vbs -a -p %printerName% -m %driverSelection% -r %printerName%

echo %unquoted% should be setup, now

EXIT /B 0


:MAIN
REM method name "queue" "driver"
call:setupPrinter "1stFloorColor" "650i" "KONICA MINOLTA C650iSeriesPS"
call:setupPrinter "2ndFloorBW" "BW" "KONICA MINOLTA 368SeriesPS"
call:setupPrinter "CafeteriaColor" "Color" "KONICA MINOLTA C658SeriesPS"
call:setupPrinter "Mailroom" "BW" "KONICA MINOLTA 368SeriesPS"

exit 0
