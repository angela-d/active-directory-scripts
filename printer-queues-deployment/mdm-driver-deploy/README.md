# MDM Deployment of Printer Drivers for Windows
This script negates the need for the classic method of GPO printer deployment (although strictly GPO is superior in *every way*, aside from reliability, as of late!)

It also does not require any immediate communication to the print server in order to obtain the drivers.


This very ugly approach needs to be modified, set the following variables to suit your environment:
```bat
SET debug=0
SET addAll=1
SET deleteAll=0
SET printServer=172.31.0.1
SET printOpt=lpr
SET adminScripts=%SystemRoot%\system32\Printing_Admin_Scripts\en-US
SET driverStore=%SystemRoot%\system32\DriverStore\FileRepository
```
- debug = self-explanatory; use when testing or when you encounter issues for more verbose output
- addAll = also useful in testing, you can do a clean sweep of adding each time
- deleteAll = see above
- printServer = if using something like Papercut, put the server IP here
- printOpt = lpr or raw
- adminScripts = leave it be, unless using a lang other than `en-US` - it's used to reduce code clutter

###  Set the paths to your setup files, here:
```bat
SET tempPath=%PUBLIC%\AppData\Local\PrinterDrivers\%driverOpt%\Drivers\PS\EN\Win_x64
...
IF %driverOpt% == Color (
  SET driverName=KOAXPA__.inf
)
IF %driverOpt% == BW (
  SET driverName=KOAXOA__.INF
)
IF %driverOpt% == 650i (
  SET driverName=KOAXCA__.inf
)
```
- see main README for an explanation of how I built my `%tempPath` directory; this is where the MDM will deploy the driver files to, before installation
- driverName = This is the singular filename to the .inf that's specific to the driver for your Color, BW or 650i machines; pay attention to case.

I left mine in the code as an example; yours will vary based on drivers used.  If you have more than 3, simply add additional `IF ()` conditions, in similar format.

### Add Your Port & Driver Connections
A unique port per queue will be created, I do such in this manner to make it easier for removal, should they be renamed or deleted at a future date.
```bat
:MAIN
REM method name "queue" "mdm driver directory" "driver"
call:setupPrinter "1stFloorColor" "650i" "KONICA MINOLTA C650iSeriesPS"
call:setupPrinter "2ndFloorBW" "BW" "KONICA MINOLTA 368SeriesPS"
call:setupPrinter "CafeteriaColor" "Color" "KONICA MINOLTA C658SeriesPS"
call:setupPrinter "Mailroom" "BW" "KONICA MINOLTA 368SeriesPS"
```
What you'll need to modify:
- `1stFloorColor` & `2ndFloorBW` are the queue names
- `650i` & `BW` determine which driver variables are used in the script; see main readme for how I structured my drivers
- `KONICA MINOLTA C650iSeriesPS` is the **Driver Name** field obtained from the Print Management tool on the Papercut server - this determines what driver gets installed to the client machine, from the setup .inf
