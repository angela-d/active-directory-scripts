# User Printer Queue Deployment
Automate deployment of printers to a user for each machine they logon to, across your entire domain.

## GPO Setup
First, set up a GPO this script will be associated with. (Done as a logon script, not a printer deployment group policy)

- Create a Login GPO and assign it to your **users**:
  - User objects that you want these queues to apply to
  - User Configuration / Windows Settings / Scripts (Logon/Logoff)
    - Worth noting: Put the **script name** only: `setup-queues.bat` - not a path
    - Click the **Show Files** button to get the path for the scripts directory for this GPO
    - Mine defaulted to a network path (not writable, by default):

      was:
      ```bat
      \\example.com\SysVol\example.com\Policies\{policy-uuid}\User\Scripts\Logon
      ```

      change to:

      ```bat
      C:\Windows\SYSVOL\domain\Policies\{policy-uuid}\User\Scripts\Logon
      ```
      - put `setup-queues.bat` in the **Logon** directory

## Customize setup-ports.bat
Modify the following sections to suit your environment

### Config
```bat
SET printServer=172.31.0.1
SET printOpt=lpr
SET adminScripts=C:\WINDOWS\system32\Printing_Admin_Scripts\en-US
```
- printServer = IP of your print / Papercut server
- printOpt = lpr or raw
- adminScripts = Ensure this path exists on your client/test machines; if you use a locale other than `en-US`, set appropriately

### Print Queues
```bat
call:setupPrinter "1stFloorColor" "650i" "KONICA MINOLTA C650iSeriesPS"
call:setupPrinter "2ndFloorBW" "bw" "KONICA MINOLTA 368SeriesPS"
call:setupPrinter "CafeteriaColor" "color" "KONICA MINOLTA C658SeriesPS"
call:setupPrinter "Mailroom" "bw" "KONICA MINOLTA 368SeriesPS"
```
- `call:setupPrinter` - this triggers the function that "loops" for each printer specified, necessary for each new printer specified
- 1st argument: `"1stFloorColor"` - Queue name
- 2nd argument: `"650i"` - this is holdover from the mdm script; since it's functionally the same thing & this script just doesn't need it, I left it here for copy/paste's sake so I don't have to waste time removing it for each printer - it's ignored by *this* script (see **driverOpt** in both scripts)
- 3rd argument: `"KONICA MINOLTA C650iSeriesPS"` - The driver used by this printer (see main README for how to obtain, if unsure)
