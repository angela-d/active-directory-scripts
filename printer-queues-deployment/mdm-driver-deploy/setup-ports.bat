@echo off
setlocal
REM install a network printer
REM ports per machine
REM queues per user via dc login script

REM set debug to 1 for more cli output
SET debug=0
SET addAll=1
SET deleteAll=0
SET printServer=172.31.0.1
SET printOpt=lpr
SET adminScripts=%SystemRoot%\system32\Printing_Admin_Scripts\en-US
SET driverStore=%SystemRoot%\system32\DriverStore\FileRepository

GOTO:MAIN

:setupPrinter
setlocal
  REM var has double quotes by default; remove them w/ :"=%
  REM has to be processed 2x; the regex can't be processed on numeric vars
  SET printerName=%1
  SET printerName=%printerName:"=%
  SET driverOpt=%2
  SET driverOpt=%driverOpt:"=%
  SET driverSelection=%3
  SET tempPath=%PUBLIC%\AppData\Local\PrinterDrivers\%driverOpt%\Drivers\PS\EN\Win_x64


  REM set the driver variable based on the 2nd argument of the :MAIN function
  IF %driverOpt% == Color (
    SET driverName=KOAXPA__.inf
  )
  IF %driverOpt% == BW (
    SET driverName=KOAXOA__.INF
  )
  IF %driverOpt% == 650i (
    SET driverName=KOAXCA__.inf
  )
  SET "driver=%tempPath%\%driverName%"

  echo == SANITY CHECK: %printerName%; Driver option: %driverOpt% ==
  if %debug% == 1 (
    echo DRIVER SELECTION: %driver%
    echo TEMP DRIVER PATH: %tempPath%
  )

  call:portCheck %printerName% setup

  call:driverCheck %driver% %driverSelection% setup


  REM queue setup
  REM since you have to add printers on a user basis, a login script needs to be setup independent of this script

    echo:
    echo:
  )
  endlocal
EXIT /B 0


:deletePrinter
setlocal
  call:portCheck %1 remove
  REM add a dummy var because this function also serves to check for existence before adding it, as well
  call:driverCheck "removeonly" %2 remove %3 %4

  REM delete the queue
  cscript /Nologo %adminScripts%\prnmngr.vbs -d -p %1
endlocal
EXIT /B 0

:driverCheck
setlocal
  SET driver=%1
  SET driver=%driver:"=%
  set driverSelection=%2
  SET toDo=%3
  SET toDo=%toDo:"=%
  SET driverVer=%4
  SET driverEnv=%5

  REM see if the driver is already installed to %driverStore% path
  REM some printer drivers use the same driver; no need to redo
  cscript /nologo %adminScripts%\prndrvr.vbs -l | findstr /i /c:%driverSelection% > nul 2>&1

  if %ERRORLEVEL% == 0 (
    SET driverExists=yes
  ) else (
    SET driverExists=no
  )

  if %debug% == 1 (
    echo DEBUG: Checking for driver: %driverSelection% to %toDo%
    echo DEBUG: Driver exists: %driverExists%
  )

  REM setup the driver if it's not yet there
  if %driverExists% == no (
    if %toDo% == setup cscript /Nologo %adminScripts%\prndrvr.vbs -a -m %driverSelection% -h %tempPath% -i %driver%
  ) else (
    if %toDo% == setup (
       echo %driverSelection% driver already exists; skipping
    )
  )

  REM remove the driver, if it exists
  if %driverExists% == yes (
    REM this bit is tricky and may not work on the first removal attempt if any queues are still using it
    if %toDo% == remove net stop spooler & net start spooler & cscript /nologo %adminScripts%\prndrvr.vbs -d -m %driverSelection% -v %driverVer% -e %driverEnv%
  ) else (
    if %toDo% == remove (
      echo %driverSelection% not installed, nothing to remove
    )
  )

endlocal
EXIT /B 0

:portCheck
setlocal
  REM handles adding and removing of ports based on the 2nd argument
  SET printerName=%1
  SET printerName=%printerName:"=%
  SET toDo=%2
  SET toDo=%toDo:"=%

  REM check for an existing port by capturing the errorcode of a query
  cscript /Nologo %adminScripts%\prnport.vbs -l | findstr ^%printerName%$ > nul 2>&1

  if %debug% == 1 (
    echo DEBUG: Checking for port: %printerName% to %toDo%
    echo DEBUG: Port error level: %ERRORLEVEL%
  )

  REM port does not exist and setup argument is set
  if not %ERRORLEVEL% == 0 (
    if %toDo% == setup cscript /Nologo %adminScripts%\prnport.vbs -a -r %printerName% -h %printServer% -o lpr -q %printerName%
  ) else (
    if %toDo% == setup (
       echo %printerName% port already exists; skipping
    )
  )

  REM port exists and removal was requested
  if %ERRORLEVEL% == 0 (
    REM port removal
    if %toDo% == remove cscript /Nologo %adminScripts%\prnport.vbs -d -r %printerName% -s %COMPUTERNAME%
  ) else (
    if %toDo% == remove (
       echo INFO: %printerName% port does not exist; nothing to remove
    )
  )

endlocal
EXIT /B 0

:MAIN


if %addAll% == 1 (
  REM method name "queue" "driver"
  call:setupPrinter "1stFloorColor" "650i" "KONICA MINOLTA C650iSeriesPS"
  call:setupPrinter "2ndFloorBW" "BW" "KONICA MINOLTA 368SeriesPS"
  call:setupPrinter "CafeteriaColor" "Color" "KONICA MINOLTA C658SeriesPS"
  call:setupPrinter "Mailroom" "BW" "KONICA MINOLTA 368SeriesPS"
)

if %deleteAll% == 1 (
  REM optionally delete old queues
  REM arg values: queue, driver, driver version, driver environment
  REM find your version & env: cscript /nologo %SystemRoot%\system32\Printing_Admin_Scripts\en-US\prndrvr.vbs -l | findstr /i "KONICA MINOLTA 368SeriesPS"
  call:deletePrinter "1stFloorColor" "KONICA MINOLTA C650iSeriesPS" "3" "Windows x64"
  call:deletePrinter "2ndFloorBW" "KONICA MINOLTA 368SeriesPS" "3" "Windows x64"
  call:deletePrinter "CafeteriaColor" "KONICA MINOLTA C658SeriesPS" "3" "Windows x64"
  call:deletePrinter "Mailroom" "KONICA MINOLTA 368SeriesPS" "3" "Windows x64"
)
REM only wanna delete one? uncomment (remove REM)
REM call:deletePrinter "2ndFloorBW" "KONICA MINOLTA 368SeriesPS" "3" "Windows x64"
endlocal
exit 0
